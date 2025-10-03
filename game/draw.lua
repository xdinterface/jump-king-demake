function draw_game()
	cls()
	draw_background()
	draw_clouds()
	palt(0, false)
	draw_rectangles()
	palt(14, true)
	palt(0, false)
	map(0, 0)
	spr(p.sp, p.x, p.y, 1, 1, p.flp)

	--draw princess in final level
	if current_lvl == 32 then
		spr(princess_sprite, princess_x, princess_y, 1, 1, false)
	end

	palt()

	if show_time then
		draw_time()
	end

	
	--draw snow last so it's in front of everything
	draw_snow()
end

function draw_time()
	local s = seconds
	local m = minutes
	local h = flr(minutes / 60)

	print(
		(h < 10 and "0" .. h or h) .. ":" .. (m < 10 and "0" .. m or m) .. ":" .. (s < 10 and "0" .. s or s),
		cam_x + 1,
		cam_y + 1,
		7
	)
end

