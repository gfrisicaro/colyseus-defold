<div align="center">
  <a href="https://github.com/gamestdio/colyseus">
    <img src="https://github.com/gamestdio/colyseus/blob/master/media/header.png?raw=true" />
  </a>
  <br>
  <br>
  <a href="https://npmjs.com/package/colyseus">
    <img src="https://img.shields.io/npm/dm/colyseus.svg">
  </a>
  <a href="https://patreon.com/endel" title="Donate to this project using Patreon">
    <img src="https://img.shields.io/badge/patreon-donate-yellow.svg" alt="Patreon donate button" />
  </a>
  <a href="http://discuss.colyseus.io" title="Discuss on Forum">
    <img src="https://img.shields.io/badge/discuss-on%20forum-brightgreen.svg?style=flat&colorB=b400ff" alt="Discussion forum" />
  </a>
  <a href="https://gitter.im/gamestdio/colyseus">
    <img src="https://badges.gitter.im/gamestdio/colyseus.svg">
  </a>
  <h3>
     Multiplayer Game Client for <a href="https://www.defold.com/">Defold Engine</a>. <br/><a href="http://colyseus.io/docs/">View documentation</a>
  <h3>
</div>

# Supported platforms (See [usage](#usage))

- [Defold Engine](#defold-engine)
- [CoronaSDK](#corona-sdk)

## [Defold Engine](https://www.defold.com/)

[Defold](https://defold.com) is a multi-platform game engine made by [King.com](https://king.com/).

### Installation

You can use the modules from this project in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your game.project file and in the `dependencies` field under `project` add:

	https://github.com/gamestdio/colyseus-defold/archive/master.zip

Or point to the ZIP file of a [specific release](https://github.com/gamestdio/colyseus-defold/releases).

### Dependencies

This project depends on the WebSocket, LuaSocket and LuaSec projects:

* [defold-websocket](https://github.com/britzl/defold-websocket/archive/master.zip)
* [defold-luasocket](https://github.com/britzl/defold-luasocket/archive/0.11.zip)
* [defold-luasec](https://github.com/subsoap/defold-luasec/archive/master.zip)

You need to add these as dependencies in your game.project file, along with the dependency to this project itself.

## [Corona SDK](https://coronalabs.com/)

Corona is a software development kit (SDK) developed by Corona Labs Inc. Corona allows software programmers to build 2D mobile applications for iOS, Android, and Kindle, desktop applications for Windows and OS X, and connected TV applications for Apple TV and Android TV.

### Installation

- Copy [`coronasdk/example/dmc_corona`](#d) folder into your project structure.
- Add [openssl](https://docs.coronalabs.com/plugin/openssl/) and [bit](https://docs.coronalabs.com/plugin/bit/) plugins into your `build.settings` file:

```
settings =
{
    -- ...

    plugins =
    {
        ["plugin.bit"] = { publisherId = "com.coronalabs" },
        ["plugin.openssl"] = { publisherId = "com.coronalabs" },
    },

    -- ...
}
```

# Usage

```lua
local ColyseusClient = require "colyseus.client"

local client
local room

function init(self)
    -- Add initialization code here
    client = ColyseusClient.new("ws://localhost:3553")

    -- join chat room
    room = client:join("chat")
end

function update(self, dt)
   client:loop()
end
```

See [client-side documentation](http://colyseus.io/docs/client-overview/).

## Contributors

Big thanks to [Björn Ritzl](https://github.com/britzl). Without his efforts on
the WebSocket library this client wouldn't exist.

## License

MIT
