function tile_to_pixel(tile_coord)
	return tile_coord * 8
end

function pixel_to_tile(pixel_coord)
	return flr(pixel_coord / 8)
end

function get_current_zone(x, y)
	local tile_x = pixel_to_tile(x)
	local tile_y = pixel_to_tile(y)
	local col = flr(tile_x / 16) -- which column (0-7)

	local prev_x = 0
	local prev_y = 63 -- bottom of map

	for i = 1, #world_bg_zones do
		local zone = world_bg_zones[i]
		local zone_col = flr(zone.tile_x / 16)

		if col <= zone_col then
			if col == zone_col then
				if tile_y >= zone.tile_y then
					return zone
				end
			else
				return zone
			end
		end
	end
	return world_bg_zones[#world_bg_zones] -- default to last zone
end

function fill_background_rect(col_start, col_end, y_start_tile, y_end_tile, color)
	local y_start = tile_to_pixel(y_start_tile)
	local y_end = tile_to_pixel(y_end_tile)

	local screen_left = cam_x
	local screen_right = cam_x + screen_size
	local screen_top = cam_y
	local screen_bottom = cam_y + screen_size

	for col = col_start, col_end do
		local x_start = col * 128
		local x_end = (col + 1) * 128

		if screen_right > x_start and screen_left < x_end then
			if screen_bottom > y_end and screen_top < y_start then
								local draw_left = max(screen_left, x_start)
				local draw_right = min(screen_right, x_end - 1)
				local draw_top = max(screen_top, y_end)
				local draw_bottom = min(screen_bottom, y_start)

				if draw_left <= draw_right and draw_top <= draw_bottom then
					rectfill(draw_left, draw_top, draw_right, draw_bottom, color)
				end
			end
		end
	end
end

function draw_background()
	local has_snow = in_levels(current_lvl, snow_only_levels) or in_levels(current_lvl, snow_wind_levels)

	if has_snow then
		rectfill(cam_x, cam_y, cam_x + screen_size, cam_y + screen_size, 0)
		return
	end


	--default background
	rectfill(cam_x, cam_y, cam_x + screen_size, cam_y + screen_size, 1)

	for rect in all(custom_bg_rects) do
		local x_start = tile_to_pixel(rect.x_start)
		local y_start = tile_to_pixel(rect.y_start)
		local x_end = tile_to_pixel(rect.x_end)
		local y_end = tile_to_pixel(rect.y_end)

		local screen_left = cam_x
		local screen_right = cam_x + screen_size
		local screen_top = cam_y
		local screen_bottom = cam_y + screen_size

		if screen_right > x_start and screen_left < x_end and screen_bottom > y_end and screen_top < y_start then
						local draw_left = max(screen_left, x_start)
			local draw_right = min(screen_right, x_end)
			local draw_top = max(screen_top, y_end)
			local draw_bottom = min(screen_bottom, y_start)

			if draw_left <= draw_right and draw_top <= draw_bottom then
				rectfill(draw_left, draw_top, draw_right, draw_bottom, rect.bg_color)
			end
		end
	end
end

