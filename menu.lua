-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------
local ColyseusConnection = require "colyseus.connection"
ColyseusConnection.config = { connect_timeout = 10 }

local ColyseusClient = require "colyseus.client"

local client = ColyseusClient.new("ws://localhost:2567", false)


client:on("open", function()
	print("colyseus-defold: connection opened!")
end)

client:on("close", function()
	print("colyseus-defold: connection closed!")
end)

client:on("error", function(err)
	print("colyseus-defold: error")
	print(err)
end)

-- forward declarations and other locals
local connectBtn
local roomBtn

local function loginCallback(call)
  print(call)
end

-- 'onRelease' event listener for playBtn
local function onConnectBtnRelease()

  client:connect()

  return true	-- indicates successful touch
end

local function loginResponseCallback(err, auth) 
	print(auth)
  	print(err)
end

local function onLoginBtnRelease()

	local queryParams = {}
	client.auth:login_request( queryParams, loginResponseCallback )

end

local function onRoomBtnRelease()

	local room = client:join("chat_schema", { create = true })

	room:on("statechange", function(state)
  	  print("new state:", state)
  	  print("players:", state.numberOfPots)
	end)

	room:on("message", function(message)
	  print("server just sent this message:")
	  print(message)
	end)

	room:on("join", function()
  	  print("client joined successfully")
	end)

	room:on("leave", function()
	  print("client left the room")
	end)

	room:on("error", function()
	  print("oops, error ocurred:")
	  print(e)
	end)

	return true
end 

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( "background.jpg", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX
	background.y = 0 + display.screenOriginY

	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newImageRect( "logo.png", 264, 42 )
	titleLogo.x = display.contentCenterX
	titleLogo.y = 100

	-- create a widget button (which will loads level1.lua on release)
	connectBtn = widget.newButton{
		label="Connect",
		labelColor = { default={255}, over={128} },
		default="button.png",
		over="button-over.png",
		width=154, height=40,
		onRelease = onConnectBtnRelease	-- event listener function
	}
	connectBtn.x = display.contentCenterX
	connectBtn.y = display.contentHeight - 125

	-- create a widget button (which will loads level1.lua on release)
	loginBtn = widget.newButton{
		label="Login",
		labelColor = { default={255}, over={128} },
		default="button.png",
		over="button-over.png",
		width=154, height=40,
		onRelease = onLoginBtnRelease	-- event listener function
	}
	loginBtn.x = display.contentCenterX
	loginBtn.y = connectBtn.y + 50

	-- create a widget button (which will loads level1.lua on release)
	roomBtn = widget.newButton{
		label="Join room",
		labelColor = { default={255}, over={128} },
		default="button.png",
		over="button-over.png",
		width=154, height=40,
		onRelease = onRoomBtnRelease	-- event listener function
	}
	roomBtn.x = display.contentCenterX
	roomBtn.y = loginBtn.y + 50

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( connectBtn )
	sceneGroup:insert( roomBtn )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end 
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.

	if connectBtn then
		connectBtn:removeSelf()	-- widgets must be manually removed
		connectBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
