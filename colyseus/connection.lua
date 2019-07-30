local protocol = require('colyseus.protocol')
local EventEmitter = require('colyseus.eventemitter')

local msgpack = require('colyseus.messagepack.MessagePack')
local WebSocket = require "dmc_corona.dmc_websockets"

local connection = {}
connection.__index = connection

function connection.new ( endpoint )
  local instance = EventEmitter:new()
  setmetatable(instance, connection)
  instance:init(endpoint)
  return instance
end

function connection:init()
  self._enqueuedCalls = {}
end

function connection:open(endpoint)
  self.endpoint = endpoint

  -- skip if connection is already open
  if self.state == 'OPEN' then
    return
  end

  local params = {}
  params.uri = endpoint

  self.ws = WebSocket(params)

  self.ws:addEventListener(WebSocket.EVENT, function(event)
    if event.type == WebSocket.ONOPEN then
      for i, cmd in ipairs(self._enqueuedCalls) do
        local method = self[ cmd[1] ]
        local arguments = cmd[2]
        method(self, unpack(arguments))
      end

      self:emit("open")

    elseif event.type == WebSocket.ONMESSAGE then
      self:emit("message", event.message)

    elseif event.type == WebSocket.ONCLOSE then
      self:emit("close", event)

    elseif event.type == WebSocket.ONERROR then
      self:emit('error', event)
      self:close()
    end
  end)
end

function connection:send(data)

  if self.ws and self.ws.readyState == WebSocket.ESTABLISHED then
    self.ws:send(msgpack.pack(data), { type = WebSocket.BINARY })

  else
    -- WebSocket not connected.
    -- Enqueue data to be sent when readyState is OPEN
    table.insert(self._enqueuedCalls, { 'send', { data } })
  end
end

function connection:close()
  self.ws:close()
  self.ws = nil
end

return connection
