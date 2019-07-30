local utils = require "colyseus.utils"
local storage = require "colyseus.storage"
local EventEmitter = require('colyseus.eventemitter')
local json = require( "json" )

local Auth = {}
Auth.__index = Auth

function Auth.new (endpoint)
  local instance = EventEmitter:new({
    use_https = not system.getInfo("environment") == "simulator",
    endpoint = endpoint:gsub("ws", "http"),
    http_timeout = 10,
    token = storage.get_item("token"),

    ping_interval = 20,
    ping_service_handle = nil
  })

  setmetatable(instance, Auth)
  return instance
end

--
-- PRIVATE METHODS
--

function Auth:build_url(segments)
  return self.endpoint .. segments
end

function Auth:has_token()
  return self.token ~= nil and self.token ~= ""
end

function Auth:get_platform_id()
  if system.getInfo("platform") == "ios" then
    return "ios"

  elseif system.getInfo("platform") == "android" then
    return "android"
  end
end

function Auth:get_device_id()
  if self:get_platform_id() ~= nil then
		return system.getInfo( "deviceID" )
  else
		local unique_id = storage.get_item("device_id")
		if type(unique_id) ~= "string" then
      unique_id = tostring(math.random(0, 9999)) .. tostring(os.time(os.date("!*t")))
      storage.set_item("device_id", unique_id)
		end
		return unique_id
	end
end

function Auth:request(method, segments, params, callback, headers, body)
  if not headers then headers = {} end

  local has_query_string = false
  local query_params = {}
  for k, v in pairs(params) do
    if v ~= nil then
      table.insert(query_params, k .. "=" .. utils.urlencode(tostring(v)))
      has_query_string = true
    end
  end

  if has_query_string then
    segments = segments .. "?" .. table.concat(query_params, "&")
  end

  local function networkListener( event )
    local data = event.response ~= '' and json.decode(event.response)
    local has_error = event.isError
    local err = nil

    if has_error then
      err = event.response
      data = ''
    end

    callback(err, data)
  end

  local params = {}
  params.headers = headers
  params.body = body or ""
  params.timeout = self.http_timeout

  network.request(self:build_url(segments), method, params)
end

function Auth:login_request (query_params, success_cb)
  if self:has_token() then
    query_params['token'] = self.token
  end

  query_params['deviceId'] = self:get_device_id()
  query_params['platform'] = self:get_platform_id()

  self:request("POST", "/auth", query_params, function(err, response)
    if err then
      print("@colyseus/social: " .. tostring(err))
    else
      -- TODO: cache and check token expiration on every call
      -- response.expiresIn

      -- cache token locally
      storage.set_item("token", response.token)
      for field, value in pairs(response) do
        self[field] = value
      end

      -- initialize auto-ping
      self:register_ping_service()
    end

    success_cb(err, self)
  end)
end

--
-- PUBLIC METHODS
--

function Auth:login(query_params_or_success_cb, success_cb)
  local query_params = {}
  if not success_cb then
    success_cb = query_params_or_success_cb
  else
    query_params = query_params_or_success_cb
  end
  self:login_request(query_params, success_cb)
end

function Auth:facebook_login(success_cb, permissions)
  local _self = self
  if not facebook then
    error ("Facebook login is not supported on '" .. system.getInfo( "platform" ) .. "' platform")
  end

  facebook.login_with_read_permissions(permissions or { "public_profile", "email", "user_friends" }, function(self, data)
    if data.status == facebook.STATE_OPEN then
      _self:login_request({ accessToken = facebook.access_token() }, success_cb)

    elseif data.status == facebook.STATE_CLOSED_LOGIN_FAILED then
      -- Do something to indicate that login failed
      print("@colyseus/social => FACEBOOK LOGIN FAILED")
    end

    -- An error occurred
    if data.error then
      print("@colyseus/social => FACEBOOK ERROR")
      pprint(data.error)
    end
  end)
end

function Auth:save(success_cb)
  local body_fields = {}

  local allowed_fields = {'username', 'displayName', 'avatarUrl', 'lang', 'location', 'timezone'}
  for i, field in ipairs(allowed_fields) do
    if self[field] then table.insert(body_fields, [["]] .. field .. [[":"]] .. self[field] .. [["]]) end
  end

  self:request("PUT", "/auth", {}, function(err, response)
    if err then print("@colyseus/social: " .. tostring(err)) end
    success_cb(err, response)
  end, {
    ["content-type"] = 'application/json',
    authorization = "Bearer " .. self.token
  }, "{" .. table.concat(body_fields, ",") .. "}")
end


function Auth:register_ping_service()
  -- prevent from having more than one ping services
  if self.ping_service_handle ~= nil then
    self:unregister_ping_service()
  end
  self.ping_service_handle = timer.delay(self.ping_interval, true, function() self:ping() end)
end

function Auth:unregister_ping_service()
  timer.cancel(self.ping_service_handle)
end

function Auth:ping(success_cb)
  self:request("GET", "/auth", {}, function(err, response)
    if err then print("@colyseus/social: " .. tostring(err)) end
    if success_cb then
      success_cb(err, response)
    end
  end, { authorization = "Bearer " .. self.token })
end

function Auth:get_friend_requests(success_cb)
  self:request("GET", "/friends/requests", {}, function(err, response)
    if err then print("@colyseus/social: " .. tostring(err)) end
    success_cb(err, response)
  end, { authorization = "Bearer " .. self.token })
end

function Auth:accept_friend_request(user_id, success_cb)
  self:request("PUT", "/friends/requests", { userId = user_id }, function(err, response)
    if err then print("@colyseus/social: " .. tostring(err)) end
    success_cb(err, response)
  end, { authorization = "Bearer " .. self.token })
end

function Auth:decline_friend_request(user_id, success_cb)
  self:request("DELETE", "/friends/requests", { userId = user_id }, function(err, response)
    if err then print("@colyseus/social: " .. tostring(err)) end
    success_cb(err, response)
  end, { authorization = "Bearer " .. self.token })
end

function Auth:send_friend_request(user_id, success_cb)
  self:request("POST", "/friends/requests", { userId = user_id }, function(err, response)
    if err then print("@colyseus/social: " .. tostring(err)) end
    success_cb(err, response)
  end, { authorization = "Bearer " .. self.token })
end

function Auth:get_friends(success_cb)
  self:request("GET", "/friends/all", {}, function(err, response)
    if err then print("@colyseus/social: " .. tostring(err)) end
    success_cb(err, response)
  end, { authorization = "Bearer " .. self.token })
end

function Auth:get_online_friends(success_cb)
  self:request("GET", "/friends/online", {}, function(err, response)
    if err then print("@colyseus/social: " .. tostring(err)) end
    success_cb(err, response)
  end, { authorization = "Bearer " .. self.token })
end

function Auth:block_user(user_id, success_cb)
  self:request("POST", "/friends/block", { userId = user_id }, function(err, response)
    if err then print("@colyseus/social: " .. tostring(err)) end
    success_cb(err, response)
  end, { authorization = "Bearer " .. self.token })
end

function Auth:unblock_user(user_id, success_cb)
  self:request("PUT", "/friends/block", { userId = user_id }, function(err, response)
    if err then print("@colyseus/social: " .. tostring(err)) end
    success_cb(err, response)
  end, { authorization = "Bearer " .. self.token })
end

function Auth:logout()
  self.token = nil
  self:unregister_ping_service()
end

return Auth
