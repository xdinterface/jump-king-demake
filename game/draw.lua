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
	--draw_rain()

	--debug system--
	if debug_mode and debug_print then
		local debug_info = {}
		local y_offset = 8

		--coordinates debug
		if debug_coords then
			add(debug_info, "x: " .. tostr(p.x))
			add(debug_info, "y: " .. tostr(p.y))
		end

		--level debug
		if debug_level then
			add(debug_info, "lvl: " .. tostr(current_lvl))
		end

		--grounded debug
		if debug_grounded then
			add(debug_info, "grounded: " .. tostr(p.grounded))
		end

		--wind debug
		if debug_wind then
			local has_snow_wind = false
			for i=1,#snow_wind_levels do
				if snow_wind_levels[i] == current_lvl then
					has_snow_wind = true
					break
				end
			end

			local ground_wind_force = 0
			if p.grounded and has_snow_wind and not in_deep_snow(p) then
				ground_wind_force = wind_direction * wind_strength * p.ground_wind_ramp * wind_ground_force
			end

			add(debug_info, "wind_str: " .. tostr(wind_strength))
			add(debug_info, "wind_dir: " .. tostr(wind_direction))
			add(debug_info, "air_ramp: " .. tostr(p.wind_ramp))
			add(debug_info, "gnd_ramp: " .. tostr(p.ground_wind_ramp))
			add(debug_info, "has_wind: " .. tostr(has_snow_wind))
			add(debug_info, "gnd_force: " .. tostr(ground_wind_force))
		end

		--snow debug
		if debug_snow then
			add(debug_info, "deep_snow: " .. tostr(in_deep_snow(p)))
			if snow_drawn_count then
				add(debug_info, "snow_drawn: " .. tostr(snow_drawn_count))
			end
		end

		--world debug
		if debug_world then
			local tile_y = pixel_to_tile(p.y)
			add(debug_info, "tile_y: " .. tostr(tile_y))
			if min_tile_y_reached then
				add(debug_info, "min_ty: " .. tostr(min_tile_y_reached))
			end
		end

		--draw all debug info
		for i=1,#debug_info do
			print(debug_info[i], cam_x, cam_y + y_offset, 7)
			y_offset = y_offset + 6
		end
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

