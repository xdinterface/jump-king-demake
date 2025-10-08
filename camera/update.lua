function camera_update()
	local screen_y = max(0, flr(p.y / 128))

	current_level_column = current_lvl >= 30 and 7 or max(0, min(7, current_level_column))

	cam_x, cam_y = current_level_column * 128, screen_y * 128
	camera(cam_x, cam_y)

	update_current_level()

	if p.y < 0 then p_lvl_up() elseif p.y >= 512 then p_lvl_down() end
end

function update_current_level()
	if current_lvl >= 30 then
		local py_tile = flr(max(0, p.y) / 128)
		current_lvl = max(30, min(7 * 4 + 4 - py_tile, 32))
	else
		local py_tile = flr(p.y / 128)
		local new_lvl = max(1, min(flr(p.x / 128) * 4 + 4 - py_tile, 32))
		if new_lvl != current_lvl then current_lvl = new_lvl end
	end
end


function p_lvl_up()
	if current_lvl >= 30 then return end
	local new_x = p.x + 128
	if new_x < 1024 then
		p.x, p.y, current_level_column = new_x, p.y + 512, current_level_column + 1
	else
		p.y = 0
	end
end

function p_lvl_down()
	local new_x = p.x - 128
	if new_x >= 0 then
		p.x, p.y, current_level_column = new_x, p.y - 512, current_level_column - 1
	else
		p.y = 511
	end
end

