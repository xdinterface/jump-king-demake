function update_game()

	if check_victory() then
		timer_stopped = true
		_update = update_ending_transition
		_draw = draw_ending_transition
		return
	end


	if not timer_stopped then
		frames = ((frames + 1) % fps)
		if frames == 0 then
			seconds = ((seconds + 1) % 60)
			if seconds == 0 then
				minutes = ((minutes + 1) % 60)
				if minutes == 0 then
					hours = hours + 1
				end
			end
		end
	end



	local px_tile = flr(p.x / 8)
	if px_tile >= 118 and px_tile <= 127 and p.y < 100 then
		princess_anim_timer = princess_anim_timer + 1
		if princess_anim_timer >= 15 then
			princess_anim_timer = 0
			princess_sprite = princess_sprite == 12 and 13 or 12
		end
	end


	if current_lvl == 1 then
		animate_sprite_at_pos()
	end

	p_update()
	p_animate()
	update_game_music()
	camera_update()


	update_background_progress()

	update_rain()
	update_clouds()
	update_snow_wind()
end

function check_victory()

	if not p.grounded then
		return false
	end

	local px_tile, py_tile = flr(p.x / 8), flr((p.y + p.h) / 8)



	return px_tile >= 121 and px_tile <= 124 and py_tile == 4
end

function update_background_progress()

	local current_tile_y = pixel_to_tile(p.y)

	if not min_tile_y_reached then
		min_tile_y_reached = current_tile_y
	else
		min_tile_y_reached = min(min_tile_y_reached, current_tile_y)
	end
end

function animate_sprite_at_pos()
	anim_sprite_timer = anim_sprite_timer + 1
	if anim_sprite_timer >= 15 then
		anim_sprite_timer, anim_sprite_current = 0, anim_sprite_current == 38 and 39 or 38
	end
end

