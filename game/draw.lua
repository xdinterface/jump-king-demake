function draw_game()
	cls()
	draw_background()
	draw_clouds()
	draw_rain()
	draw_custom_backgrounds()
	draw_custom_towers()

	palt(0, false) palt(14, true)
	map(0, 0)


	if current_lvl == 1 then
		spr(anim_sprite_current, 48, 496, 1, 1, false)
	end


	if current_lvl == 32 then
		spr(princess_sprite, princess_x, princess_y, 1, 1, false)
	end

	spr(p.sp, p.x, p.y, 1, 1, p.flp)

	palt()

	if show_time then
		draw_time()
	end


	draw_snow()

end

function draw_time()
	local s, m, h = seconds, minutes, hours

	print(
		(h < 10 and "0" .. h or h) .. ":" .. (m < 10 and "0" .. m or m) .. ":" .. (s < 10 and "0" .. s or s),
		cam_x + 1,
		cam_y + 1,
		7
	)
end

