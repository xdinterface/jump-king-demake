function update_game()
	frames = ((frames + 1) % game_config.fps)
	if frames == 0 then
		seconds = ((seconds + 1) % 60)
		if seconds == 0 then
			minutes = minutes + 1
		end
	end

	p_update()
	p_animate()
	update_game_music()
	camera_update()

	--update background progress tracking
	update_background_progress()

	--update_rain()
	update_snow_wind()
end

function update_background_progress()
	--update maximum world height reached
	local current_world_height = get_world_height(p.x, p.y)
	max_world_height_reached = max(max_world_height_reached, current_world_height)
end

