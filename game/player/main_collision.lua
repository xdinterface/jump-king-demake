function collide_map(obj, aim, flag)
	local x = obj.x + (obj.hb_x_off or 0)
	local y = obj.y + (obj.hb_y_off or 0)
	local w = obj.hb_w or obj.w
	local h = obj.hb_h or obj.h

	if flag == 0 then
		local player_x = obj.x + (obj.hb_x_off or 0)
		local player_y = obj.y + (obj.hb_y_off or 0)

		if player_x >= 896 and player_x < 1024 and player_y < 384 then
			if aim == "left" and x <= 896 then
				return true
			end
			if aim == "right" and x + w >= 1024 then
				return true
			end
		else
			if aim == "right" and x + w >= 1024 then
				return true
			end
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
		local orig_x1 = x1 * 8
		local orig_y1 = y1 * 8
		local orig_x2 = x2 * 8
		local orig_y2 = y2 * 8

		local corners = {
			{x1, y1, orig_x1, orig_y1},
			{x1, y2, orig_x1, orig_y2},
			{x2, y1, orig_x2, orig_y1},
			{x2, y2, orig_x2, orig_y2}
		}

		for i = 1, #corners do
			local tx = flr(corners[i][1])
			local ty = flr(corners[i][2])
			local tile_px = corners[i][3]
			local tile_py = corners[i][4]
			local tile_id = mget(tx, ty)

			if is_custom_tile(tile_id) then
				if aim == "down" and obj.dy and abs(obj.dy) > 4 and (tile_id == 110 or tile_id == 120 or tile_id == 121) then
					return true
				elseif in_custom_tile(tile_px, tile_py, tx, ty, tile_id) then
					return true
				end
			elseif fget(tile_id, flag) then
				return true
			end
		end

		if aim == "up" or aim == "down" then
			local tile_x1 = flr(orig_x1 / 8)
			local tile_x2 = flr(orig_x2 / 8)
			local tile_y1 = flr(orig_y1 / 8)
			local tile_y2 = flr(orig_y2 / 8)

			for ty = tile_y1, tile_y2 do
				for tx = tile_x1, tile_x2 do
					local tile_id = mget(tx, ty)
					if is_custom_tile(tile_id) then
						if aim == "down" and obj.dy and abs(obj.dy) > 4 and (tile_id == 110 or tile_id == 120 or tile_id == 121) then
							return true
						else
							for check_x = orig_x1, orig_x2 do
								for check_y = orig_y1, orig_y2 do
									if in_custom_tile(check_x, check_y, tx, ty, tile_id) then
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
		local tile_px1, tile_py1 = x1 * 8, y1 * 8
		local tile_px2, tile_py2 = x2 * 8, y2 * 8

		local check_points = {}

		for tile_px = tile_px1, tile_px2 do
			add(check_points, {tile_px, tile_py1})
			add(check_points, {tile_px, tile_py2})
		end

		for tile_py = tile_py1, tile_py2 do
			add(check_points, {tile_px1, tile_py})
			add(check_points, {tile_px2, tile_py})
		end

		for i = 1, #check_points do
			local tile_px, tile_py = check_points[i][1], check_points[i][2]
			local tile_x = flr(tile_px / 8)
			local tile_y = flr(tile_py / 8)
			local tile = mget(tile_x, tile_y)

			if fget(tile, flag) then
				if on_diagonal_slope(tile_px, tile_py, tile_x, tile_y, flag) then
					return true
				end
			end
		end

		return false
	end
end