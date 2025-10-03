function draw_clouds()
    local has_snow = in_levels(current_lvl, snow_only_levels) or in_levels(current_lvl, snow_wind_levels)

    if current_lvl == 25 or current_lvl == 26 or (current_lvl >= 13 and current_lvl <= 16) then
        return
    end

    if has_snow then return end

    --get current background color (simplified lookup)
    local bg_color = get_bg_color_at(p.x, p.y)
    local cloud_color = bg_to_cloud[bg_color]

    if not cloud_color then return end

    foreach(clouds, function(c)
        local cloud_x = c.x + cam_x
        local cloud_y = c.y + cam_y

        --simplified cloud shape: 2 overlapping rectangles
        rectfill(cloud_x+2, cloud_y+1, cloud_x+c.w-2, cloud_y+c.h-1, cloud_color)
        rectfill(cloud_x, cloud_y+2, cloud_x+c.w, cloud_y+c.h-2, cloud_color)
    end)
end

function get_bg_color_at(x, y)
    --simplified bg color lookup for cloud coloring
    local tile_x = flr(x/8)
    local tile_y = flr(y/8)

    --check custom rectangles first (mansion overlays)
    for rect in all(custom_bg_rects) do
        if tile_x >= rect.x_start and tile_x <= rect.x_end and
           tile_y <= rect.y_start and tile_y >= rect.y_end then
            return rect.bg_color
        end
    end

    return 1  --default background
end


function draw_snow()
    local has_snow = in_levels(current_lvl, snow_only_levels) or in_levels(current_lvl, snow_wind_levels)
    if not has_snow then return end

    local drawn_count = 0
    foreach(snow, function(flake)
        pset(flake.x + cam_x, flake.y + cam_y, 7)
        drawn_count = drawn_count + 1
    end)

    snow_drawn_count = drawn_count
end