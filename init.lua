function _init()

	_update60 = update_title
	_draw = draw_title



	debug = true


	cartdata("jumpking_demake")
	best_time = dget(0)
	run_count = dget(1)
	is_new_record = false


	gravity = 0.12
	friction = 0.8
	movement_speed = 0.7
	ice_decel = 0.16
	ice_counter = 0.16
	ice_ramp = 0.12
	ice_thresh = 0.08
	charge_rate = 0.01
	anim_rate = 0.1
	bounce_factor = 0.6
	slam_thresh = 5.2


	snow_count = 60
	snow_spd_min = 0.25
	snow_spd_max = 0.5
	snow_wind_factor = 4.0
	wind_max = 1.5
	wind_player_force = 0.08
	wind_ground_force = 0.1
	wind_ground_max = 2.0
	wind_ramp_time = 0.2
	wind_blow_time = 5


	cloud_count = 8
	cloud_spd_min = 0.02
	cloud_spd_max = 0.1
	cloud_size_min = 32
	cloud_size_max = 64


	snow_only_levels = { 17, 18, 19 }
	snow_wind_levels = { 20, 21, 22, 23, 24 }


	snow_only_lookup = {}
	snow_wind_lookup = {}
	for i = 1, #snow_only_levels do
		snow_only_lookup[snow_only_levels[i]] = true
	end
	for i = 1, #snow_wind_levels do
		snow_wind_lookup[snow_wind_levels[i]] = true
	end


	fps = 60
	world_size = 1024
	screen_size = 128

	p = {
		sp = 1,
		x = 60,
		y = 496,
		w = 8,
		h = 8,

		hb_x_off = 1,
		hb_y_off = 0,
		hb_w = 6,
		hb_h = 8,
		flp = false,
		dx = 0,
		dy = 0,
		max_walk_dx = 0.45,
		max_dx = 2,
		max_dy = 5.7,
		max_slide = 2.5,
		acc = 0.7,
		jump_acc = 1.6,
		boost = 0,
		boost_max = 4.2,
		anim = 0,
		grounded = false,
		running = false,
		crouching = false,
		jumping = false,
		falling = false,
		splat = false,
		landing = false,
		slammed = false,
		dir = false,
		hit = false,
		lock_jump = false,
		air_moved = false,
		wind_timer = 0,
		wind_ramp = 0,
		ground_wind_timer = 0,
		ground_wind_ramp = 0,
		ice_slide_speed = 0,
		ice_acc_timer = 0,
		was_on_ice = false,
		ice_sliding = false,
		was_on_diagonal = false,
		diagonal_started = false,
		jump_btn_held = false,
		min_charge_met = false,
		min_charge_threshold = 0.63,
	}


	reset_clouds()

	menu_pos = 1
	blink_c, blink_c1, blink_c2 = 7, 7, 6
	blink_rate, blink_speed = 0, 10

	frames, seconds, minutes, hours = 0, 0, 0, 0

	menu_music, game_music = true, true
	show_time = true
	max_menu, init_lvl, s = 0, 1, 0

	air_time, jump_counter, fall_counter = 0, 0, 0


	current_level_column, cam_x, cam_y = 0, 0, 0

	map_start, map_end = 0, world_size


	current_lvl, last_lvl = 1, 1
	level_entry_time = 0




	snow = {}
	for i = 0, snow_count do
		snow[i] = {
			x = rnd(screen_size),
			y = rnd(screen_size),
			spd = snow_spd_min + rnd(snow_spd_max - snow_spd_min),
		}
	end


	rain = {}
	for i = 0, 40 do
		rain[i] = {
			x = rnd(screen_size),
			y = rnd(screen_size),
			spd = 1.25 + rnd(0.75),
		}
	end


	wind_timer = 0
	wind_phase = 0
	wind_strength = 0
	wind_direction = -1
	max_wind_speed = wind_max
	initial_wind_delay_done = false
	player_wind_ramp = 0
	player_wind_timer = 0


	min_tile_y_reached = nil


	level_bg = {}
	for i = 1, 2 do
		level_bg[i] = 13
	end
	for i = 3, 5 do
		level_bg[i] = 13
	end
	for i = 6, 7 do
		level_bg[i] = { 13, 0 }
	end
	for i = 8, 11 do
		level_bg[i] = { 2, 1 }
	end
	for i = 12, 15 do
		level_bg[i] = 6
	end
	for i = 16, 19 do
		level_bg[i] = 13
	end
	for i = 20, 24 do
		level_bg[i] = { 1, 0 }
	end
	for i = 25, 26 do
		level_bg[i] = { 4, 0 }
	end
	level_bg[27] = 13
	for i = 28, 29 do
		level_bg[i] = "stars"
	end
	for i = 30, 32 do
		level_bg[i] = 15
	end


	level_clouds = {}
	for i = 1, 5 do
		level_clouds[i] = 6
	end
	for i = 6, 7 do
		level_clouds[i] = nil
	end
	for i = 8, 11 do
		level_clouds[i] = nil
	end
	for i = 12, 15 do
		level_clouds[i] = 7
	end
	for i = 16, 19 do
		level_clouds[i] = 13
	end
	for i = 20, 24 do
		level_clouds[i] = 13
	end
	for i = 25, 26 do
		level_clouds[i] = nil
	end
	for i = 27, 29 do
		level_clouds[i] = nil
	end
	for i = 30, 32 do
		level_clouds[i] = 9
	end


	custom_bg_rects = {

		{ x1 = 129, y1 = 24, x2 = 256, y2 = 407, bg_color = { 13, 0 } },

		{ x1 = 296, y1 = 296, x2 = 376, y2 = 496, bg_color = { 4, 0 } },
		{ x1 = 320, y1 = 184, x2 = 376, y2 = 288, bg_color = { 4, 0 } },
		{ x1 = 304, y1 = 288, x2 = 376, y2 = 296, bg_color = { 4, 0 } },

		{ x1 = 800, y1 = 224, x2 = 863, y2 = 255, bg_color = { 4, 0 } },
	}


	custom_towers = {}


	function generate_tower_shifts(base_x, y_start, y_end)
		local shifts = {}
		local current_shift = 0

		for row = 0, y_end - y_start do

			local change = rnd(3) - 1
			current_shift = mid(-3, current_shift + change, 3)
			shifts[row + 1] = current_shift
		end

		return {
			base_x = base_x,
			y_start = y_start,
			y_end = y_end,
			shifts = shifts,
			colors = { 2, 14 },
		}
	end


	add(custom_towers, generate_tower_shifts(67, 51, 53))
	add(custom_towers, generate_tower_shifts(73, 49, 51))


	ending_timer = 0
	ending_phase = 1
	phase_progress = 0
	timer_stopped = false


	saved_pos_x = nil
	saved_pos_y = nil
	o_button_press_time = 0
	o_button_held = false
	position_saved = false


	princess_x = 984
	princess_y = 24
	princess_sprite = 11
	princess_anim_timer = 0


	anim_sprite_timer = 0
	anim_sprite_current = 38


	ending_transition_timer = 0
	map_offset_y = 0
	player_end_x = 54
	player_end_y = 60
	princess_end_x = 74
	princess_end_y = 60
	transition_player_x = 0
	transition_player_y = 0
	transition_princess_x = 0
	transition_princess_y = 0
end

function reset_clouds()
	clouds = {}
	local cloud_layers = { 20, 45, 70 }
	for i = 0, cloud_count do
		local layer = flr(rnd(3)) + 1
		local h = 4 + flr(rnd(3))
		local w = cloud_size_min + rnd(cloud_size_max - cloud_size_min)

		clouds[i] = {
			x = rnd(screen_size),
			y = cloud_layers[layer] + rnd(12) - 6,
			spd = cloud_spd_min + rnd(cloud_spd_max - cloud_spd_min),
			w = w,
			h = h,
		}
	end
end

function in_levels(lvl, list)
	if list == snow_only_levels then
		return snow_only_lookup[lvl] or false
	end
	if list == snow_wind_levels then
		return snow_wind_lookup[lvl] or false
	end
	for i = 1, #list do
		if list[i] == lvl then
			return true
		end
	end
	return false
end

function update_ramp(timer, ramp_time)
	local new_timer = timer + 1 / fps
	local ramp_value = min(1, new_timer / ramp_time)
	return new_timer, ramp_value
end
