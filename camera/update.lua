function camera_update()
	local screen_x = flr(p.x / 128)
	local screen_y = flr(p.y / 128)

	cam_x = screen_x * 128
	cam_y = screen_y * 128
	camera(cam_x, cam_y)
	
	--update current level based on position
	update_current_level()

	if p.y < 0 then
		p_lvl_up()
	elseif p.y >= 512 then
		p_lvl_down()
	end
end

function update_current_level()
	--calculate level based on player position (basic mapping)
	local level_x = flr(p.x / 128) + 1
	local level_y = 4 - flr(p.y / 128) --invert y since levels go up
	current_lvl = (level_x - 1) * 4 + level_y
	current_lvl = max(1, min(current_lvl, 28)) --clamp between 1-28
end


function p_lvl_up()
	--only transition if going to a valid level area
	--check if destination would be in bounds
	local new_x = p.x + 128
	if new_x < 1024 then  --within map bounds
		p.x = new_x
		p.y = p.y + 512
	else
		--prevent going off map, snap to top edge
		p.y = 0
	end
end

function p_lvl_down()
	--only transition if coming from a valid level area
	--check if destination would be in bounds
	local new_x = p.x - 128
	if new_x >= 0 then  --within map bounds
		p.x = new_x
		p.y = p.y - 512
	else
		--prevent going off map, snap to bottom edge
		p.y = 511
	end
end

