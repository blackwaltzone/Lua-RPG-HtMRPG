LoadLibrary("Renderer")
LoadLibrary("Sprite")
LoadLibrary("System")
LoadLibrary("Texture")
LoadLibrary("Vector")
LoadLibrary("Asset")
LoadLibrary("Keyboard")

Asset.Run("util.lua")
Asset.Run("testmap.lua")
Asset.Run("map.lua")
Asset.Run("entity.lua")
Asset.Run("state_machine.lua")
Asset.Run("tween.lua")
Asset.Run("actions.lua")
Asset.Run("trigger.lua")
Asset.Run("move_state.lua")
Asset.Run("wait_state.lua")
Asset.Run("npc_stand_state.lua")
Asset.Run("plain_stroll_state.lua")
Asset.Run("animation.lua")
Asset.Run("character.lua")
Asset.Run("entity_defs.lua")

local mapDef = CreateMap()
mapDef.on_wake =
{
	{
		id = "AddNPC",
		params = {{ def = "strolling_npc", x=9, y=7 }},
	},
	{
		id = "AddNPC",
		params = {{ def = "standing_npc", x=6, y=8 }},
	}
}
-- separate trigger definitions from placement in case multiple
-- tiles need to trigger same action -> one big trigger
mapDef.actions =
{
	tele_south = { id = "Teleport", params = {8,5} },
	tele_north = { id = "Teleport", params = {4,1} }
}
mapDef.trigger_types =
{
	north_door_trigger = { OnEnter = "tele_south" },
	south_door_trigger = { OnEnter = "tele_north" }
}
mapDef.triggers =
{
	{ trigger = "north_door_trigger", x=4, y=0 },
	{ trigger = "south_door_trigger", x=8, y=5 }
}
local gMap = Map:Create(mapDef)

gRenderer = Renderer.Create()

gMap:GotoTile(7,7)

gHero = Character:Create(gCharacters.hero, gMap)

--gUpDoorTeleport = Actions.Teleport(gMap, 4, 1)
--gDownDoorTeleport = Actions.Teleport(gMap, 8, 5)


gHero.mEntity:SetTilePos(4,1,1,gMap)

--[[
gTriggerTop = Trigger:Create
{
	OnEnter = gDownDoorTeleport,
}
gTriggerBottom = Trigger:Create
{
	OnEnter = gUpDoorTeleport,
}
gTriggerStart = Trigger:Create
{
	OnExit = function() gMessage = "OnExit: Left the start position" end
}
gTriggerTile = Trigger:Create
{
	OnUse = function() gMessage = "OnUse: Trigger Tile!" end
}

gMap.mTriggers =
{
	-- Layer 1
	{
		[gMap:CoordToIndex(8, 5)] = gTriggerBottom,
		[gMap:CoordToIndex(4, 0)] = gTriggerTop,
		[gMap:CoordToIndex(4, 1)] = gTriggerStart,
		[gMap:CoordToIndex(6, 8)] = gTriggerTile,
	}
}
]]--
function GetFacedTileCoords(character)
	 -- Change the facing information into a tile offset
	 local xInc = 0
	 local yInc = 0

	 if character.mFacing == "left" then
	 	xInc = -1
	 elseif character.mFacing == "right" then
	 	xInc = 1
	 elseif character.mFacing == "up" then
	 	yInc = -1
	 elseif character.mFacing == "down" then
	 	yInc = 1
	 end

	 local x = character.mEntity.mTileX + xInc
	 local y = character.mEntity.mTileY + yInc

	 return x, y
end

gMessage = "Hello"

function update()

	local dt = GetDeltaTime()

	local playerPos = gHero.mEntity.mSprite:GetPosition()
	gMap.mCamX = math.floor(playerPos:X())
	gMap.mCamY = math.floor(playerPos:Y())

    gRenderer:Translate(-gMap.mCamX, -gMap.mCamY)

    local layerCount = gMap:LayerCount()

    for i = 1, layerCount do

    	local heroEntity = nil

    	if i == gHero.mEntity.mLayer then
    		--gRenderer:DrawSprite(gHero.mEntity.mSprite)
    		heroEntity = gHero.mEntity
    	end

    	gMap:RenderLayer(gRenderer, i, heroEntity)
    end

    gHero.mController:Update(dt)
    --gNPC.mController:Update(dt)

    for k, v in ipairs(gMap.mNPCs) do
    	v.mController:Update(dt)
    end

    if Keyboard.JustPressed(KEY_SPACE) then
    	-- which way is player facing?
    	local x, y = GetFacedTileCoords(gHero)
    	local trigger = gMap:GetTrigger(gHero.mEntity.mLayer, x, y)
    	if trigger then
    		trigger:OnUse(gHero)
    	end
    end

    gRenderer:DrawRect2d(
    	gMap.mCamX - System.ScreenWidth() / 2,
    	gMap.mCamY + System.ScreenHeight() / 2,
    	gMap.mCamX + System.ScreenWidth() / 2,
    	gMap.mCamY + System.ScreenHeight() / 2 - 60,
    	Vector.Create(0, 0, 0, 1)
    )

    local y = gMap.mCamY + System.ScreenHeight() / 2 - 30
    gRenderer:AlignText("center", "center")
    gRenderer:DrawText2d(gMap.mCamX, y, gMessage, Vector.Create(1, 1, 1, 1))

    gRenderer:AlignTextX("left")
    gRenderer:DrawText2d(-30, 150, "Try using the pot (USE = <space> key)", Vector.Create(1, 1, 1, 1), 175)
    
end