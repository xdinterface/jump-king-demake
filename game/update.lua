function update_game()
	--check for victory condition first (before timer update)
	if check_victory() then
		timer_stopped = true
		_update = update_ending_transition
		_draw = draw_ending_transition
		return
	end

	--only update timer if not stopped
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

	--animate princess if player is near
	local px_tile = flr(p.x / 8)
	if px_tile >= 118 and px_tile <= 127 and p.y < 100 then
		princess_anim_timer = princess_anim_timer + 1
		if princess_anim_timer >= 15 then  --switch every 0.5s
			princess_anim_timer = 0
			if princess_sprite == 12 then
				princess_sprite = 13
			else
				princess_sprite = 12
			end
		end
	end

	p_update()
	p_animate()
	update_game_music()
	camera_update()

	--update background progress tracking
	update_background_progress()

	update_rain()
	update_clouds()
	update_snow_wind()
end

function check_victory()
	--only check if player is grounded
	if not p.grounded then
		return false
	end

	local px_tile = flr(p.x / 8)
	local py_tile = flr((p.y + p.h) / 8)  --check bottom of player

	--check if player is standing on top of tiles x121-124, y4
	--player's feet should be at y=32 (tile y=4), meaning player is at y=24 (tile y=3)
	if px_tile >= 121 and px_tile <= 124 and py_tile == 4 then
		return true
	end
	return false
end

function update_background_progress()
	--update player's highest tile reached (lower tile_y = higher in world)
	local current_tile_y = pixel_to_tile(p.y)
	--track lowest tile_y reached (which is highest point)
	if not min_tile_y_reached then
		min_tile_y_reached = current_tile_y
	else
		min_tile_y_reached = min(min_tile_y_reached, current_tile_y)
	end
end

