function in_deep_snow(obj)
	local x = obj.x + (obj.hb_x_off or 0)
	local y = obj.y + (obj.hb_y_off or 0)
	local w = obj.hb_w or obj.w
	local h = obj.hb_h or obj.h

	local tile_x1 = flr(x / 8)
	local tile_x2 = flr((x + w - 1) / 8)
	local tile_y1 = flr(y / 8)
	local tile_y2 = flr((y + h - 1) / 8)

	for ty = tile_y1, tile_y2 do
		for tx = tile_x1, tile_x2 do
			local sprite_id = mget(tx, ty)
			if fget(sprite_id, 5) then
				local tile_top = ty * 8
				local snow_top = tile_top + 6
				local snow_bottom = tile_top + 8
				local tile_left = tx * 8
				local tile_right = tile_left + 8
				if x < tile_right and x + w > tile_left and y < snow_bottom and y + h > snow_top then
					return true
				end
			end
		end
	end
	return false
end

function on_ice(obj)
	if not obj.grounded then
		return false
	end

	local x = obj.x + (obj.hb_x_off or 0)
	local y = obj.y + (obj.hb_y_off or 0)
	local w = obj.hb_w or obj.w
	local h = obj.hb_h or obj.h

	local tile_x1 = flr(x / 8)
	local tile_x2 = flr((x + w - 1) / 8)
	local tile_y = flr((y + h + 1) / 8)

	for tx = tile_x1, tile_x2 do
		local sprite_id = mget(tx, tile_y)
		if fget(sprite_id, 6) then
			return true
		end
	end
	return false
end