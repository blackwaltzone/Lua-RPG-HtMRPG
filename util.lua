
-- chops up an image into regular sized tiles of tilesize
-- and returns a table of uv coordinates
-- coordinates are percentage of texture size
function GenerateUVs(tileWidth,tileHeight,texture)

	-- This is the table we'll fill with UVs and return
	local uvs = {}

	local textureWidth = texture:GetWidth()
	local textureHeight = texture:GetHeight()
	local width = tileWidth / textureWidth
	local height = tileHeight / textureHeight
	local cols = textureWidth / tileWidth
	local rows = textureHeight / tileHeight

	local ux = 0
	local uy = 0
	local vx = width
	local vy = height

	for j=0,rows-1 do
		for i=0,cols-1 do
			
			table.insert(uvs,{ux,uy,vx,vy})

			-- advance UVs to next col
			ux = ux + width
			vx = vx + width
		end

		-- put UVs back to start of next row
		ux = 0
		vx = width
		uy = uy + height
		vy = vy + height
	end

	return uvs
end

function Teleport(entity,map)
	local x, y = map:GetTileFoot(entity.mTileX, entity.mTileY)
	entity.mSprite:SetPosition(x, y +entity.mHeight / 2)
end
