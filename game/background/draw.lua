function tile_to_pixel(tile_coord)
	return tile_coord * 8
end

function pixel_to_tile(pixel_coord)
	return flr(pixel_coord / 8)
end

function draw_background()
	--get background color for current level
	local bg_color = level_bg[current_lvl] or 1

	--fill screen with level's background color
	rectfill(cam_x, cam_y, cam_x + screen_size, cam_y + screen_size, bg_color)
end

function draw_custom_backgrounds()
	--draw custom background rectangles
	for rect in all(custom_bg_rects) do
		local x_start = tile_to_pixel(rect.x_start)
		local y_start = tile_to_pixel(rect.y_start)
		local x_end = tile_to_pixel(rect.x_end + 1) - 1
		local y_end = tile_to_pixel(rect.y_end)

		local screen_left = cam_x
		local screen_right = cam_x + screen_size - 1
		local screen_top = cam_y
		local screen_bottom = cam_y + screen_size - 1

		if screen_right >= x_start and screen_left <= x_end and screen_bottom >= y_end and screen_top <= y_start then
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

