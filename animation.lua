Animation = {}
Animation.__index = Animation
function Animation:Create(frames, loop, spf)

	-- if no loop is set, true by default
	if loop == nil then
		loop = true
	end

	-- spf = seconds per frame
	local this =
	{
		mFrames = frames or {1},
		mIndex = 1,
		mSPF = spf or 0.12,
		mTime = 0,
		mLoop = loop,
	}

	setmetatable(this,self)
	return this
end

function Animation:Update(dt)
	self.mTime = self.mTime + dt

	if self.mTime >= self.mSPF then

		self.mIndex = self.mIndex + 1
		self.mTime = 0

		-- reached the end of frames
		if self.mIndex > #self.mFrames then
			-- loop
			if self.mLoop then
				self.mIndex = 1
			-- don't loop
			else
				self.mIndex = #self.mFrames
			end
		end
	end
end

-- change frame list
-- can swap animation being played
function Animation:SetFrames(frames)
	self.mFrames = frames
	-- reset table length to fit number of frames
	self.mIndex = math.min(self.mIndex, #self.mFrames)
end

-- get current frame
function Animation:Frame()
	return self.mFrames[self.mIndex]
end

-- true if animation is NOT looping
function Animation:IsFinished()
	return self.mLoop == false
		and self.mIndex == #self.mFrames
end
