local is_defold = sys
local m = {}

function m.save_table(filename, data)
  if is_defold then
    --
    -- defold engine
    --
    local colyseus_id_file = sys.get_save_file("colyseus", filename)
    if not sys.save(colyseus_id_file, data) then
      print("colyseus.client: set_colyseus_id couldn't set colyseus_id locally.")
    end

  else
    --
    -- corona sdk
    --
    local json = require("json")
    local loc = system.DocumentsDirectory
    local path = system.pathForFile( filename, loc )
    local file, err = io.open( path, "w" )

    file:write( json.encode( t ) )
    io.close( file )
  end

  return true
end

function m.load_table(filename)
  if is_defold then
    -- defold engine
    --
    local colyseus_id_file = sys.get_save_file("colyseus", filename)
    return sys.load(colyseus_id_file)

  else
    --
    -- corona sdk
    --
    local json = require("json")
    local loc = system.DocumentsDirectory
    local path = system.pathForFile( filename, loc )

    if not file then
      return {}
    end

    -- Open the file handle
    local file, err = io.open( path, "r" )
    local contents = file:read( "*a" )
    local t = json.decode( contents )
    io.close( file )

    return t
  end
end

return m
