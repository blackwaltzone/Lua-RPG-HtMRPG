PlainStrollState = {mName = "plain_stroll"}
PlainStrollState.__index = PlainStrollState
function PlainStrollState:Create(character,map)
    local this =
    {
        mCharacter = character,
        mMap = map,
        mEntity = character.mEntity,
        mController = character.mController,

        mFrameResetSpeed = 0.05,
        mFrameCount = 0,

        mCountDown = math.random(0,3)
    }

    setmetatable(this, self)
    return this
end

function PlainStrollState:Enter()
    self.mFrameCount = 0
    self.mCountDown = math.random(0.3)
end

function PlainStrollState:Exit() end

function PlainStrollState:Update(dt)
    self.mCountDown = self.mCountDown - dt
    if self.mCountDown <=0 then
        -- choose a random direction and try to move that way
        local choice = math.random(4)
        if choice == 1 then
            self.mController:Change("move", {x=-1,y=0})
        elseif choice == 2 then
            self.mController:Change("move", {x=1,y=0})
        elseif choice == 3 then
            self.mController:Change("move", {x=0,y=-1})
        elseif choice == 4 then
            self.mController:Change("move", {x=0,y=1})
        end
    end

    -- if we're in the stroll state a few frames, reset the frame to
    -- the starting frame
    if self.mFrameCount ~= -1 then
        self.mFrameCount = self.mFrameCount + dt
        if self.mFrameCount >= self.mFrameResetSpeed then
            self.mFrameCount = -1
            self.mEntity:SetFrame(self.mEntity.mStartFrame)
            --self.mCharacter.mFacing = "down"
        end
    end
end

function PlainStrollState:Render(renderer) end
