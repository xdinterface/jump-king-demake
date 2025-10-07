function is_point_on_diagonal_slope(px, py, tile_x, tile_y, flag)
	local tile_px = tile_x * 8
	local tile_py = tile_y * 8
	local rel_x = px - tile_px
	local rel_y = py - tile_py

	if rel_x < 0 or rel_x >= 8 or rel_y < 0 or rel_y >= 8 then
		return false
	end

	if flag == 1 then
		if rel_y == 7 then
			return true
		else
			return rel_x >= (7 - rel_y)
		end
	elseif flag == 2 then
		if rel_y == 7 then
			return true
		else
			return rel_x <= rel_y
		end
	elseif flag == 3 then
		return rel_y <= (7 - rel_x)
	elseif flag == 4 then
		return rel_y <= rel_x
	end

	return false
end

function is_point_in_custom_tile(px, py, tile_x, tile_y, tile_id)
	local tile_px = tile_x * 8
	local tile_py = tile_y * 8
	local rel_x = px - tile_px
	local rel_y = py - tile_py

	if rel_x < 0 or rel_x >= 8 or rel_y < 0 or rel_y >= 8 then
		return false
	end

	if tile_id == 118 or tile_id == 36 or tile_id == 48 then
		return rel_x >= 6
	elseif tile_id == 119 or tile_id == 37 or tile_id == 49 then
		return rel_x < 2
	elseif tile_id == 120 or tile_id == 121 then
		return rel_y < 3
	elseif tile_id == 110 then
		return rel_y < 4
	end

	return false
end

function is_custom_tile(tile_id)
	return (tile_id >= 118 and tile_id <= 121) or tile_id == 36 or tile_id == 37 or tile_id == 48 or tile_id == 49 or tile_id == 110
end

function collide_map(obj, aim, flag)
	--use hitbox properties if available, otherwise fall back to sprite dimensions
	local x = obj.x + (obj.hb_x_off or 0)
	local y = obj.y + (obj.hb_y_off or 0)
	local w = obj.hb_w or obj.w
	local h = obj.hb_h or obj.h

	--check right edge boundary (invisible wall past tile x=127)
	if aim == "right" and flag == 0 then
		if x + w >= 1024 then
			return true
		end
	end

	local x1 = 0
	local x2 = 0
	local y1 = 0
	local y2 = 0

	if aim == "left" then
		local check_dist = min(abs(obj.dx), 4)
		x1 = x - check_dist
		x2 = x - check_dist
		y1 = y + 1
		y2 = y + h - 1
	elseif aim == "right" then
		local check_dist = min(abs(obj.dx), 4)
		x1 = x + w + check_dist - 1
		x2 = x + w + check_dist - 1
		y1 = y + 1
		y2 = y + h - 1
	elseif aim == "up" then
		x1 = x
		x2 = x + w - 1
		if flag == 0 then
			y1 = y - 2
			y2 = y - 2
		elseif flag == 3 or flag == 4 then
			y1 = y + 1
			y2 = y + h
		end
	elseif aim == "down" then
		x1 = x
		x2 = x + w - 1
		local check_dist = 1
		if obj.dy and obj.dy > 0 then
			check_dist = min(ceil(obj.dy), 6)
		end
		y1 = y + h + 1
		y2 = y + h + check_dist
	elseif aim == "slide" then
		x1 = x
		x2 = x + w - 1
		y1 = y
		y2 = y + h - 1
	end

	x1 = x1 / 8
	x2 = x2 / 8
	y1 = y1 / 8
	y2 = y2 / 8

	if flag == 0 then
		--save original pixel coordinates before tile conversion
		local orig_x1 = x1 * 8
		local orig_y1 = y1 * 8
		local orig_x2 = x2 * 8
		local orig_y2 = y2 * 8

		--check the four corner check_points (original system for standard tiles)
		local corners = {
			{x1, y1, orig_x1, orig_y1},
			{x1, y2, orig_x1, orig_y2},
			{x2, y1, orig_x2, orig_y1},
			{x2, y2, orig_x2, orig_y2}
		}

		for i = 1, #corners do
			local tx = flr(corners[i][1])
			local ty = flr(corners[i][2])
			local tile_px = corners[i][3]  --use original pixel coordinates
			local tile_py = corners[i][4]
			local tile_id = mget(tx, ty)

			--check if it's a custom hitbox tile
			if is_custom_tile(tile_id) then
				--high-speed mode: treat thin platform tiles as full solid tiles
				if aim == "down" and obj.dy and abs(obj.dy) > 4 and (tile_id == 110 or tile_id == 120 or tile_id == 121) then
					return true  --treat thin platforms as solid blocks when falling fast
				elseif is_point_in_custom_tile(tile_px, tile_py, tx, ty, tile_id) then
					return true
				end
			elseif fget(tile_id, flag) then
				--standard collision for normal tiles
				return true
			end
		end

		--additional thorough check for custom tiles when corner checks might miss
		if aim == "up" or aim == "down" then
			local tile_x1 = flr(orig_x1 / 8)
			local tile_x2 = flr(orig_x2 / 8)
			local tile_y1 = flr(orig_y1 / 8)
			local tile_y2 = flr(orig_y2 / 8)

			--check all tiles in the range (important for thin platforms when falling)
			for ty = tile_y1, tile_y2 do
				for tx = tile_x1, tile_x2 do
					local tile_id = mget(tx, ty)
					if is_custom_tile(tile_id) then
						--high-speed mode: treat thin platform tiles as full solid tiles
						if aim == "down" and obj.dy and abs(obj.dy) > 4 and (tile_id == 110 or tile_id == 120 or tile_id == 121) then
							return true  --treat thin platforms as solid blocks when falling fast
						else
							--normal mode: check horizontal span for narrow columns
							for check_x = orig_x1, orig_x2 do
								--check each y position in the range
								for check_y = orig_y1, orig_y2 do
									if is_point_in_custom_tile(check_x, check_y, tx, ty, tile_id) then
										return true
									end
								end
							end
						end
					end
				end
			end
		end
		return false
	elseif flag >= 1 and flag <= 4 then
		-- Precise diagonal collision detection
		-- Convert tile coordinates back to pixels
		local tile_px1, tile_py1 = x1 * 8, y1 * 8
		local tile_px2, tile_py2 = x2 * 8, y2 * 8

		-- Check multiple check_points along hitbox edges, not just corners
		local check_points = {}

		-- Top and bottom edges
		for tile_px = tile_px1, tile_px2 do
			add(check_points, {tile_px, tile_py1})  -- top edge
			add(check_points, {tile_px, tile_py2})  -- bottom edge
		end

		-- Left and right edges
		for tile_py = tile_py1, tile_py2 do
			add(check_points, {tile_px1, tile_py})  -- left edge
			add(check_points, {tile_px2, tile_py})  -- right edge
		end

		for i = 1, #check_points do
			local tile_px, tile_py = check_points[i][1], check_points[i][2]
			local tile_x = flr(tile_px / 8)
			local tile_y = flr(tile_py / 8)
			local tile = mget(tile_x, tile_y)

			if fget(tile, flag) then
				-- Check if point is actually on the diagonal slope
				if is_point_on_diagonal_slope(tile_px, tile_py, tile_x, tile_y, flag) then
					return true
				end
			end
		end

		return false
	end
end

function in_deep_snow(obj)
	--check if any part of player hitbox intersects with bottom 2tile_px of flag 5 tiles
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
				--calculate deep snow area (bottom 2tile_px of this tile)
				local tile_top = ty * 8
				local snow_top = tile_top + 6  --bottom 2tile_px start at pixel 6
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

function on_ice(obj)
	--check if player is standing on ice tiles (flag 6)
	if not obj.grounded then
		return false
	end

	local x = obj.x + (obj.hb_x_off or 0)
	local y = obj.y + (obj.hb_y_off or 0)
	local w = obj.hb_w or obj.w
	local h = obj.hb_h or obj.h

	--check tiles directly beneath player
	local tile_x1 = flr(x / 8)
	local tile_x2 = flr((x + w - 1) / 8)
	local tile_y = flr((y + h + 1) / 8)  --check one pixel below player

	for tx = tile_x1, tile_x2 do
		local sprite_id = mget(tx, tile_y)
		if fget(sprite_id, 6) then
			return true
		end
	end
	return false
end

function collide_map_respect_diagonals(obj, aim, flag)
	if aim != "down" or flag != 0 then
		return collide_map(obj, aim, flag)
	end

	--use hitbox properties if available, otherwise fall back to sprite dimensions
	local x = obj.x + (obj.hb_x_off or 0)
	local y = obj.y + (obj.hb_y_off or 0)
	local w = obj.hb_w or obj.w
	local h = obj.hb_h or obj.h

	--check each pixel position in the player's bottom edge
	local left_x = x
	local check_y = y + h + 1  --one pixel below player
	local tile_y = flr(check_y / 8)

	local has_valid_ground = false

	for pixel_x = 0, w - 1 do
		local check_x = left_x + pixel_x
		local tile_x = flr(check_x / 8)
		local ground_tile = mget(tile_x, tile_y)

		--check if this position has solid ground
		local is_solid = fget(ground_tile, 0)
		if not is_solid and is_custom_tile(ground_tile) then
			--high-speed mode: treat thin platform tiles as full solid tiles
			if obj.dy and abs(obj.dy) > 4 and (ground_tile == 110 or ground_tile == 120 or ground_tile == 121) then
				is_solid = true  --treat thin platforms as solid blocks when falling fast
			else
				--normal mode: use precise custom tile collision zones
				is_solid = is_point_in_custom_tile(check_x, check_y, tile_x, tile_y, ground_tile)
			end
		end

		if is_solid then
			--check if there's a diagonal tile at the same position that would block access
			local player_tile_y = flr((y + h) / 8)  --player's bottom edge tile
			local diagonal_tile = mget(tile_x, player_tile_y)

			local blocked_by_diagonal = false

			--check if diagonal tile blocks access to the solid below
			if fget(diagonal_tile, 1) or fget(diagonal_tile, 2) then
				--get the exact pixel position within the diagonal tile
				local rel_x = check_x % 8
				local rel_y = (y + h) % 8

				--check if this pixel position is solid in the diagonal
				if is_point_on_diagonal_slope(check_x, y + h, tile_x, player_tile_y, fget(diagonal_tile, 1) and 1 or 2) then
					blocked_by_diagonal = true
				end
			end

			--only count as valid ground if not blocked by diagonal
			if not blocked_by_diagonal then
				has_valid_ground = true
				break
			end
		end
	end

	return has_valid_ground
end


