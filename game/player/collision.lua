function collide_map(obj, aim, flag)
	--use hitbox properties if available, otherwise fall back to sprite dimensions
	local x = obj.x + (obj.hb_x_off or 0)
	local y = obj.y + (obj.hb_y_off or 0)
	local w = obj.hb_w or obj.w
	local h = obj.hb_h or obj.h

	local x1 = 0
	local x2 = 0
	local y1 = 0
	local y2 = 0

	if aim == "left" then
		x1 = x - 1
		x2 = x - 1
		y1 = y + 1  --small offset to avoid ceiling collision
		y2 = y + h - 1
	elseif aim == "right" then
		x1 = x + w
		x2 = x + w
		y1 = y + 1  --small offset to avoid ceiling collision
		y2 = y + h - 1
	elseif aim == "up" then
		x1 = x + 1
		x2 = x + w - 2
		if flag == 0 then
			y1 = y - 2
			y2 = y - 2
		elseif flag == 3 or flag == 4 then
			y1 = y + 1
			y2 = y + h
		end
	elseif aim == "down" then
		x1 = x + 1
		x2 = x + w - 2
		y1 = y + h + 1
		y2 = y + h + 1
	elseif aim == "slide" then
		x1 = x + 1
		x2 = x + w - 2
		y1 = y + 1
		y2 = y + h - 1
	end

	-- pixels to tiles
	x1 = x1 / 8
	x2 = x2 / 8
	y1 = y1 / 8
	y2 = y2 / 8

	if flag == 0 then
		return fget(mget(x1, y1), flag)
			or fget(mget(x1, y2), flag)
			or fget(mget(x2, y1), flag)
			or fget(mget(x2, y2), flag)
	elseif flag == 1 then
		return fget(mget(x1, y1), flag) or fget(mget(x1, y2), flag) or fget(mget(x2, y1), flag)
	elseif flag == 2 then
		return fget(mget(x1, y1), flag) or fget(mget(x2, y1), flag) or fget(mget(x2, y2), flag)
	elseif flag == 3 then
		return fget(mget(x1, y1), flag) or fget(mget(x1, y2), flag) or fget(mget(x2, y2), flag)
	elseif flag == 4 then
		return fget(mget(x1, y2), flag) or fget(mget(x2, y1), flag) or fget(mget(x2, y2), flag)
	end
end

function in_deep_snow(obj)
	--check if any part of player hitbox intersects with bottom 2px of flag 5 tiles
	local x = obj.x + (obj.hb_x_off or 0)
	local y = obj.y + (obj.hb_y_off or 0)
	local w = obj.hb_w or obj.w
	local h = obj.hb_h or obj.h

	--get all tiles that player hitbox could overlap
	local tile_x1 = flr(x / 8)
	local tile_x2 = flr((x + w - 1) / 8)
	local tile_y1 = flr(y / 8)
	local tile_y2 = flr((y + h - 1) / 8)

	for ty = tile_y1, tile_y2 do
		for tx = tile_x1, tile_x2 do
			local sprite_id = mget(tx, ty)
			if fget(sprite_id, 5) then
				--calculate deep snow area (bottom 2px of this tile)
				local tile_top = ty * 8
				local snow_top = tile_top + 6  --bottom 2px start at pixel 6
				local snow_bottom = tile_top + 8  --tile bottom
				local tile_left = tx * 8
				local tile_right = tile_left + 8

				--check if player hitbox intersects with deep snow area
				if x < tile_right and x + w > tile_left and y < snow_bottom and y + h > snow_top then
					return true
				end
			end
		end
	end
	return false
end


