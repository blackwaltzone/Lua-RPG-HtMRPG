Map = {}
Map.__index = Map

-- each map layer has 3 sections:
--	1. base
--  2. decoration
--  3. collision

function Map:Create(mapDef)

	local layer = mapDef.layers[1]
    local this =
    {

        mX = 0,
        mY = 0,

        -- To Track camera position
        mCamX = 0,
        mCamY = 0,

        mMapDef = mapDef,
        mTextureAtlas = Texture.Find(mapDef.tilesets[1].image),

        mTileSprite = Sprite.Create(),
        mLayer = layer,
        mWidth = layer.width,
        mHeight = layer.height,

        mTiles = layer.data,
        mTileWidth = mapDef.tilesets[1].tilewidth,
        mTileHeight = mapDef.tilesets[1].tileheight,
        mTriggers = {},
        mEntities = {},
        mNPCs = {}
    }
    this.mTileSprite:SetTexture(this.mTextureAtlas)

	-- Top left corner of map
	-- Position the map so it's topleft, is flush with the topleft of the
    -- display
    this.mX = -System.ScreenWidth() / 2 --+ this.mTileWidth / 2
    this.mY = System.ScreenHeight() / 2 --- this.mTileHeight / 2

    this.mOffsetX = 0
    this.mOffsetY = 0

    this.mWidthPixel = this.mWidth * this.mTileWidth
    this.mHeightPixel = this.mHeight * this.mTileHeight

    this.mUVs = GenerateUVs(mapDef.tilesets[1].tilewidth,
                            mapDef.tilesets[1].tileheight,
                            this.mTextureAtlas )

    --
    -- assign blocking tile ID
    --
    for _,v in ipairs(mapDef.tilesets) do
    	if v.name == 'collision_graphic' then
    		this.mBlockingTile = v.firstgid
    	end
    end
    assert(this.mBlockingTile)

    --
    -- create actions from the definitions
    --
    this.mActions = {}
    for name, def in pairs(mapDef.actions or {}) do

    	-- look up the action and create the action-function
    	-- the action takes in the map as the first param
    	assert(Actions[def.id])
    	local action = Actions[def.id](this, unpack(def.params))
    	this.mActions[name] = action
    end

    --
    -- create the trigger types from the definition
    --
    this.mTriggerTypes = {}
    for k,v in pairs(mapDef.trigger_types or {}) do
    	local triggerParams = {}
    	for callback, action in pairs(v) do
    		print(callback, action)
    		triggerParams[callback] = this.mActions[action]
    		assert(triggerParams[callback])
    	end
    	this.mTriggerTypes[k] = Trigger:Create(triggerParams)
    end

    setmetatable(this, self)

    --
    -- place triggers on the map
    --
    this.mTriggers = {}
    for k,v in ipairs(mapDef.triggers) do
    	local x = v.x
    	local y = v.y
    	local layer = v.layer or 1

    	if not this.mTriggers[layer] then
    		this.mTriggers[layer] = {}
    	end

    	local targetLayer = this.mTriggers[layer]
    	local trigger = this.mTriggerTypes[v.trigger]
    	assert(trigger)
    	targetLayer[this:CoordToIndex(x,y)] = trigger
    end

    -- parse and execute the on_wake table
    -- constructing actions from defs
    for _,v in ipairs(mapDef.on_wake or {}) do
    	local action = Actions[v.id]
    	action(this, unpack(v.params))()
    end

    return this
end


function Map:PointToTile(x,y)

	-- Tiles are rendered from the center so we adjust for this
	x = x + self.mTileWidth / 2
	y = y - self.mTileHeight / 2

	-- Clamp the point to the bounds of the map
	x = math.max(self.mX, x)
	y = math.min(self.mY, y)
	x = math.min(self.mX + self.mWidthPixel - 1, x)
	y = math.max(self.mY - self.mHeightPixel + 1, y)

	-- Map from the bounded point to a tile
	local tileX = math.floor((x - self.mX) / self.mTileWidth)
	local tileY = math.floor((self.mY - y) / self.mTileHeight)

	return tileX, tileY
end

function Map:IsBlocked(layer, tileX, tileY)
	-- collision layer should always be 2 above official layer
	local tile = self:GetTile(tileX, tileY, layer + 2)
	local entity = self:GetEntity(tileX, tileY, layer)

	return tile == self.mBlockingTile or entity ~= nil
end

function Map:GetTile(x, y, layer)
	local layer = layer or 1
	local tiles = self.mMapDef.layers[layer].data
    x = x + 1 -- change from  1 -> rowsize
              -- to           0 -> rowsize - 1
    return tiles[x + y * self.mWidth]
end

function Map:GetTileFoot(x,y)
	return self.mX + (x * self.mTileWidth),
		   self.mY - (y * self.mTileHeight) - self.mTileHeight / 2
end

function Map:CoordToIndex(x,y)
	x = x + 1	-- change from  1 -> rowsize
				-- to 			0 -> rowsize - 1
	return x + y * self.mWidth
end

function Map:GetTrigger(layer, x, y)
	-- Get the triggers on the same layer as the entity
	local triggers = self.mTriggers[layer]

	if not triggers then
		return
	end

	local index = self:CoordToIndex(x,y)
	return triggers[index]
end

function Map:Goto(x,y)
	self.mCamX = x - System.ScreenWidth() / 2
	self.mCamY = -y + System.ScreenHeight() / 2
end

function Map:GotoTile(x,y)
	self:Goto((x * self.mTileWidth) + self.mTileWidth /2,
			   (y * self.mTileHeight) + self.mTileHeight / 2)
end

function Map:GetEntity(x, y, layer)
	if not self.mEntities[layer] then
		return nil
	end
	local index = self:CoordToIndex(x, y)
	return self.mEntities[layer][index]
end

function Map:AddEntity(entity)

    -- Add the layer if it doesn't exist
    if not self.mEntities[entity.mLayer] then
        self.mEntities[entity.mLayer] = {}
    end

    local layer = self.mEntities[entity.mLayer]
    local index = self:CoordToIndex(entity.mTileX, entity.mTileY)

    assert(layer[index] == entity or layer[index] == nil)
    layer[index] = entity
end

function Map:RemoveEntity(entity)
	-- the layer should exist
	assert(self.mEntities[entity.mLayer])
	local layer = self.mEntities[entity.mLayer]
	local index = self:CoordToIndex(entity.mTileX, entity.mTileY)
	-- the entity should be at the position
	assert(entity == layer[index])
	layer[index] = nil
end

function Map:Teleport(entity)
	local x, y = GetTileFoot(entity.mTileX, entity.mTileY)
	--entity.mSprite:SetPosition(x,y+heroHeight/2)
end

function Map:LayerCount()
	-- number of layers should always be a factor of 3
	assert(#self.mMapDef.layers % 3 == 0)
	return #self.mMapDef.layers / 3
end

function Map:Render(renderer)
	self:RenderLayer(renderer, 1)
end

function Map:RenderLayer(renderer,layer)

	-- each map can have multiple layers (walk under bridges, etc)
	-- each layer has 3 sections: base, decoration, collision
	-- index points to base section of a given layer

	local layerIndex = (layer * 3) - 2

	--local x = self.mX - self.mOffsetX
	--local y = self.mY + self.mOffsetY

	-- Get the topleft and bottomright pixel of the camera
	-- and use to get the tile
	local tileLeft, tileBottom = 
		self:PointToTile(self.mCamX - System.ScreenWidth() / 2,
						 self.mCamY - System.ScreenHeight() / 2)

	local tileRight, tileTop = 
		self:PointToTile(self.mCamX + System.ScreenWidth() / 2,
		 				 self.mCamY + System.ScreenHeight() / 2)

	for j = tileTop, tileBottom do
		for i = tileLeft, tileRight do

			local tile = self:GetTile(i,j,layerIndex)
			local uvs = {}

			self.mTileSprite:SetPosition(self.mX + i * self.mTileWidth,
										 self.mY - j * self.mTileHeight)

			-- Base Layer
			if tile > 0 then
				uvs = self.mUVs[tile]
				self.mTileSprite:SetUVs(unpack(uvs))
				renderer:DrawSprite(self.mTileSprite)
			end

			-- Decoration layer
			tile = self:GetTile(i,j,layerIndex + 1)

			-- if the decoration tile exists
			if tile > 0 then
				uvs = self.mUVs[tile]
				self.mTileSprite:SetUVs(unpack(uvs))
				renderer:DrawSprite(self.mTileSprite)
			end
		end

		local entityLayer = self.mEntities[layer] or {}
		local drawList = { hero }

		for _,j in pairs(entityLayer) do
			table.insert(drawList, j)
		end

		table.sort(drawList, function(a,b) return a.mTileY < b.mTileY end)
		for _,j in ipairs(drawList) do
			renderer:DrawSprite(j.mSprite)
		end
	end
end