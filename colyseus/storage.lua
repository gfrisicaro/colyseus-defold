local m = {}
local data = {}

function m.get_item (key)
  return system.getPreference("app", key, "string")
end

function m.set_item (key, value)

  local appPrefs = {}
  appPrefs[key] = value

  system.setPreferences("app" , appPrefs)
end

return m
