MoveState = {mName="move"}
MoveState.__index = MoveState
function MoveState:Create(character,map)
	local this =
	{
		mCharacter = character,
		mMap = map,
		mTileWidth = map.mTileWidth,
		mEntity = character.mEntity,
		mController = character.mController,
		-- direction to move
		mMoveX = 0,
		mMoveY = 0,
		mTween = Tween:Create(0,0,1),
		mMoveSpeed = 0.3, -- in seconds
	}

	-- animation object, initialize with default frame
	this.mAnim = Animation:Create({this.mEntity.mStartFrame})

	setmetatable(this,self)
	return this
end

function MoveState:Enter(data)
	
	local frames = nil

	-- check direction character is moving and set animation frames
	if data.x == -1 then
		frames = self.mCharacter.mAnims.left
		self.mCharacter.mFacing = 'left'
	elseif data.x == 1 then
		frames = self.mCharacter.mAnims.right
		self.mCharacter.mFacing = 'right'
	elseif data.y == -1 then
		frames = self.mCharacter.mAnims.up
		self.mCharacter.mFacing = 'up'
	elseif data.y == 1 then
		frames = self.mCharacter.mAnims.down
		self.mCharacter.mFacing = 'down'
	end

	self.mAnim:SetFrames(frames)
	
	-- move the player to the tile with tween
	self.mMoveX = data.x
	self.mMoveY = data.y
	local pixelPos = self.mEntity.mSprite:GetPosition()
	self.mPixelX = pixelPos:X()
	self.mPixelY = pixelPos:Y()
	self.mTween = Tween:Create(0,self.mTileWidth,self.mMoveSpeed)
	
	-- check if tile is blocked
	local targetX = self.mEntity.mTileX + data.x
	local targetY = self.mEntity.mTileY + data.y
	if self.mMap:IsBlocked(1,targetX,targetY) then
		self.mMoveX = 0
		self.mMoveY = 0
		self.mEntity:SetFrame(self.mAnim:Frame())
		self.mController:Change(self.mCharacter.mDefaultState)
	end

	-- to check if there is already an entity on the tile
	-- or moving to the tile
	if self.mMoveX ~= 0 or self.mMoveY ~= 0 then
		local trigger = self.mMap:GetTrigger(self.mEntity.mLayer,
											self.mEntity.mTileX,
											self.mEntity.mTileY)
		if trigger then
			trigger:OnExit(self.mEntity)
		end
	end

	self.mEntity:SetTilePos(self.mEntity.mTileX + self.mMoveX,
							self.mEntity.mTileY + self.mMoveY,
							self.mEntity.mLayer,
							self.mMap)
	self.mEntity.mSprite:SetPosition(pixelPos)
end

-- called when a character finishes entering a tile
function MoveState:Exit()
	
	local trigger = self.mMap:GetTrigger(self.mEntity.mLayer,
										self.mEntity.mTileX,
										self.mEntity.mTileY)
	if trigger then
		trigger:OnEnter(self.mEntity, x, y, layer)
	end	
end

function MoveState:Render(renderer) end

function MoveState:Update(dt)

	self.mAnim:Update(dt)
	self.mEntity:SetFrame(self.mAnim:Frame())

	self.mTween:Update(dt)

	local value = self.mTween:Value()
	local x = self.mPixelX + (value * self.mMoveX)
	local y = self.mPixelY - (value * self.mMoveY)
	self.mEntity.mX = x
	self.mEntity.mY = y
	self.mEntity.mSprite:SetPosition(x,y)

	if self.mTween:IsFinished() then
		self.mController:Change(self.mCharacter.mDefaultState)
	end
end
