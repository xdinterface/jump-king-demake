local right_walls = {[118]=true,[36]=true,[48]=true}
local left_walls = {[119]=true,[37]=true,[49]=true}
local thin_platforms = {[110]=true,[120]=true,[121]=true}
local custom_tiles = {[36]=true,[37]=true,[48]=true,[49]=true,[110]=true,[118]=true,[119]=true,[120]=true,[121]=true}

function is_custom_tile(tile_id)
	return custom_tiles[tile_id]
end

function in_custom_tile(px, py, tile_x, tile_y, tile_id)
	local tile_px = tile_x * 8
	local tile_py = tile_y * 8
	local rel_x = px - tile_px
	local rel_y = py - tile_py

	if rel_x < 0 or rel_x >= 8 or rel_y < 0 or rel_y >= 8 then
		return false
	end

	if right_walls[tile_id] then
		return rel_x >= 6
	elseif left_walls[tile_id] then
		return rel_x < 2
	elseif tile_id == 120 or tile_id == 121 then
		return rel_y < 3
	elseif tile_id == 110 then
		return rel_y < 4
	end

	return false
end