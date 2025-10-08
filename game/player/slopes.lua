function on_diagonal_slope(px, py, tile_x, tile_y, flag)
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
		return rel_y == 0 or rel_x >= rel_y
	elseif flag == 4 then
		return rel_y == 0 or rel_x <= (7 - rel_y)
	end

	return false
end