-- world height calculation system
function get_world_height(x, y)
	-- calculate absolute height in the game world
	-- each level column (128px wide) adds 512 to the total height
	local layer = flr(x / 128) -- which vertical layer (0, 1, 2, 3...)
	local layer_height = layer * 512
	local height_in_layer = 512 - y -- height from bottom of current layer
	return layer_height + height_in_layer
end

-- fill background based on world height range
function fill_background_by_world_height(world_height_start, world_height_end, color)
	-- get current camera bounds
	local screen_left = cam_x
	local screen_right = cam_x + game_config.screen_size
	local screen_top = cam_y
	local screen_bottom = cam_y + game_config.screen_size

	-- fill all level columns between the specified world heights
	for layer = 0, 7 do -- support up to 8 vertical layers
		local x_start = layer * 128
		local x_end = (layer + 1) * 128
		local layer_base_height = layer * 512

		-- only draw if this layer intersects with our height range
		if world_height_end > layer_base_height and world_height_start < layer_base_height + 512 then
			-- convert world heights to Y coordinates for this layer
			local relative_start = world_height_start - layer_base_height
			local relative_end = world_height_end - layer_base_height

			-- clamp to layer bounds (0-512)
			relative_start = max(0, min(512, relative_start))
			relative_end = max(0, min(512, relative_end))

			-- convert to Y coordinates (inverted because Y increases downward)
			local y_bottom = 512 - relative_start
			local y_top = 512 - relative_end

			-- check if visible on screen
			if screen_right > x_start and screen_left < x_end and screen_bottom > y_top and screen_top < y_bottom then
				-- clip to screen bounds
				local draw_left = max(screen_left, x_start)
				local draw_right = min(screen_right, x_end - 1)
				local draw_top = max(screen_top, y_top)
				local draw_bottom = min(screen_bottom, y_bottom)

				-- draw the rectangle
				if draw_left <= draw_right and draw_top <= draw_bottom then
					rectfill(draw_left, draw_top, draw_right, draw_bottom, color)
				end
			end
		end
	end
end

function draw_background()
	-- check for snow override first
	local has_snow = false
	for i = 1, #snow_only_levels do
		if snow_only_levels[i] == current_lvl then
			has_snow = true
			break
		end
	end
	if not has_snow then
		for i = 1, #snow_wind_levels do
			if snow_wind_levels[i] == current_lvl then
				has_snow = true
				break
			end
		end
	end

	if has_snow then
		-- for snow levels, fill entire screen with black
		rectfill(cam_x, cam_y, cam_x + game_config.screen_size, cam_y + game_config.screen_size, 0)
		return
	end

	-- debug: print which zones we're drawing
	if debug then
		local current_world_height = get_world_height(p.x, p.y)
		local zones_drawn = 0
		for i = 1, #world_bg_zones do
			local zone = world_bg_zones[i]
			if max_world_height_reached >= zone.world_height_start then
				zones_drawn = zones_drawn + 1
			end
		end
		print("bg_zones:" .. zones_drawn, cam_x, cam_y + 62, 7)
	end

	-- draw backgrounds using world height system
	-- when player reaches a zone, show the entire zone (not just up to current height)
	local current_world_height = get_world_height(p.x, p.y)

	for i = 1, #world_bg_zones do
		local zone = world_bg_zones[i]
		-- draw full zones that player has reached or is currently in
		if max_world_height_reached >= zone.world_height_start then
			-- if player has entered this zone, show it completely
			-- add 64 pixels of "lookahead" to make transitions smoother
			if current_world_height >= zone.world_height_start - 64 then
				-- show full zone
				fill_background_by_world_height(zone.world_height_start, zone.world_height_end, zone.color)
			else
				-- for zones not yet reached, only show up to max reached + buffer
				local draw_end = min(zone.world_height_end, max_world_height_reached + 64)
				fill_background_by_world_height(zone.world_height_start, draw_end, zone.color)
			end
		end
	end
end

