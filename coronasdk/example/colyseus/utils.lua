local storage = require("colyseus.storage")
local m = {}

--
-- String to byte array
--
function m.string_to_byte_array (str)
  local arr = {}
  for i = 1, #str do
    table.insert(arr, string.byte(str, i, i))
  end
  return arr
end

function m.byte_array_to_string (arr)
  local str = ''
  for i = 1, #arr do
    print(arr[i])
    str = str .. string.char(arr[i])
  end
  return str
end

--
-- Persist colyseusid locally.
--
function m.get_colyseus_id ()
  local data = storage.load_table("colyseusid")
  return data[1] or ""
end

function m.set_colyseus_id(colyseus_id)
  local data = {}
  table.insert(data, colyseus_id)
  storage.save_table("colyseusid", data)
end


return m
