function collide_map_diag(obj, aim, flag)
	if aim != "down" or flag != 0 then
		return collide_map(obj, aim, flag)
	end

	local x = obj.x + (obj.hb_x_off or 0)
	local y = obj.y + (obj.hb_y_off or 0)
	local w = obj.hb_w or obj.w
	local h = obj.hb_h or obj.h

	local left_x = x
	local check_y = y + h + 1
	local tile_y = flr(check_y / 8)

	local has_valid_ground = false

	for pixel_x = 0, w - 1 do
		local check_x = left_x + pixel_x
		local tile_x = flr(check_x / 8)
		local ground_tile = mget(tile_x, tile_y)

		local is_solid = fget(ground_tile, 0)
		if not is_solid and is_custom_tile(ground_tile) then
			if obj.dy and abs(obj.dy) > 4 and (ground_tile == 110 or ground_tile == 120 or ground_tile == 121) then
				is_solid = true
			else
				is_solid = in_custom_tile(check_x, check_y, tile_x, tile_y, ground_tile)
			end
		end

		if is_solid then
			local player_tile_y = flr((y + h) / 8)
			local diagonal_tile = mget(tile_x, player_tile_y)

			local blocked_by_diagonal = false

			if fget(diagonal_tile, 1) or fget(diagonal_tile, 2) then
				local rel_x = check_x % 8
				local rel_y = (y + h) % 8

				if on_diagonal_slope(check_x, y + h, tile_x, player_tile_y, fget(diagonal_tile, 1) and 1 or 2) then
					blocked_by_diagonal = true
				end
			end

			if not blocked_by_diagonal then
				has_valid_ground = true
				break
			end
		end
	end

	return has_valid_ground
end