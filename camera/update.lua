function camera_update()
	local screen_x = flr(p.x / 128)
	local screen_y = flr(p.y / 128)

	cam_x = screen_x * 128
	cam_y = screen_y * 128
	camera(cam_x, cam_y)

	if p.y < 0 then
		p_lvl_up()
	elseif p.y >= 512 then
		p_lvl_down()
	end
end


function p_lvl_up()
	p.x = p.x + 128
	p.y = p.y + 512
end

function p_lvl_down()
	p.x = p.x - 128
	p.y = p.y - 512
end

