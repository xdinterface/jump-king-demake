function tile_to_pixel(tile_coord)
	return tile_coord * 8
end

function pixel_to_tile(pixel_coord)
	return flr(pixel_coord / 8)
end


local brick = 0xa050.8
local dots = 0x4040.8
local lines = 0xf0f0.8
local grid = 0xf888.8
local mesh = 0x5555.8

function draw_pattern_rect(x1, y1, x2, y2, colors, pattern)
	rectfill(x1, y1, x2, y2, colors[1])
	fillp(pattern or brick)
	rectfill(x1, y1, x2, y2, colors[2])
	fillp()
end

function draw_background()

	local bg = level_bg[current_lvl] or 1
	local screen_x2, screen_y2 = cam_x + screen_size, cam_y + screen_size


	if bg == "stars" then

		rectfill(cam_x, cam_y, screen_x2, screen_y2, 0)


		srand(current_lvl * 17)


		for i = 1, 8 do
			local x = cam_x + rnd(screen_size)
			local y = cam_y + rnd(screen_size)
			pset(x, y, 3)
		end


		for i = 1, 72 do
			local x = cam_x + rnd(screen_size)
			local y = cam_y + rnd(screen_size)
			local col = ({7, 1, 13})[flr(rnd(3)) + 1]
			pset(x, y, col)
		end


		for i = 1, 3 do
			local cx = cam_x + rnd(screen_size - 4) + 2
			local cy = cam_y + rnd(screen_size - 4) + 2

			pset(cx, cy, 7)

			pset(cx - 1, cy, 12)
			pset(cx + 1, cy, 12)
			pset(cx, cy - 1, 12)
			pset(cx, cy + 1, 12)
		end

	elseif type(bg) == "table" then

		local pattern = (current_lvl >= 20 and current_lvl <= 24) and dots or nil
		draw_pattern_rect(cam_x, cam_y, screen_x2, screen_y2, bg, pattern)
	else

		rectfill(cam_x, cam_y, screen_x2, screen_y2, bg)
	end
end

function draw_custom_backgrounds()

	for rect in all(custom_bg_rects) do
		local x_start = rect.x1
		local y_start = rect.y1
		local x_end = rect.x2
		local y_end = rect.y2

		local screen_left = cam_x
		local screen_right = cam_x + screen_size - 1
		local screen_top = cam_y
		local screen_bottom = cam_y + screen_size - 1

		if screen_right >= x_start and screen_left <= x_end and screen_bottom >= y_start and screen_top <= y_end then
			local draw_left = max(screen_left, x_start)
			local draw_right = min(screen_right, x_end)
			local draw_top = max(screen_top, y_start)
			local draw_bottom = min(screen_bottom, y_end)

			if draw_left <= draw_right and draw_top <= draw_bottom then

				if type(rect.bg_color) == "table" then
					draw_pattern_rect(draw_left, draw_top, draw_right, draw_bottom, rect.bg_color, rect.pattern)
				else
					rectfill(draw_left, draw_top, draw_right, draw_bottom, rect.bg_color)
				end
			end
		end
	end
end

function draw_custom_towers()

	for tower in all(custom_towers) do
		local screen_left = cam_x
		local screen_right = cam_x + screen_size - 1
		local screen_top = cam_y
		local screen_bottom = cam_y + screen_size - 1


		for row = 0, tower.y_end - tower.y_start do
			local y_tile = tower.y_start + row
			local y_pixel = y_tile * 8


			if y_pixel >= screen_top - 8 and y_pixel <= screen_bottom then

				local pixel_shift = tower.shifts[(row % #tower.shifts) + 1]
				local x_pixel = tower.base_x * 8 + pixel_shift


				if screen_right >= x_pixel and screen_left <= x_pixel + 15 then

					spr(52, x_pixel, y_pixel, 1, 1, false)
					spr(53, x_pixel + 8, y_pixel, 1, 1, false)
				end
			end
		end
	end
end
