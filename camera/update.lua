function camera_update()
	local screen_y = flr(p.y / 128)

	cam_x = current_level_column * 128
	cam_y = screen_y * 128
	camera(cam_x, cam_y)
	
	update_current_level()

	if p.y < 0 then
		p_lvl_up()
	elseif p.y >= 512 then
		p_lvl_down()
	end
end

function update_current_level()
	local level_x = flr(p.x / 128) + 1
	local level_y = 4 - flr(p.y / 128) --invert y since levels go up
	local new_lvl = (level_x - 1) * 4 + level_y
	new_lvl = max(1, min(new_lvl, 32)) --clamp between 1-32

	if new_lvl != current_lvl then
		current_lvl = new_lvl
	end
end


function p_lvl_up()
	local new_x = p.x + 128
	if new_x < 1024 then  --within map bounds
		p.x = new_x
		p.y = p.y + 512
		current_level_column = current_level_column + 1  --move camera to new column
	else
		p.y = 0
	end
end

function p_lvl_down()
	local new_x = p.x - 128
	if new_x >= 0 then  --within map bounds
		p.x = new_x
		p.y = p.y - 512
		current_level_column = current_level_column - 1  --move camera to new column
	else
		p.y = 511
	end
end

