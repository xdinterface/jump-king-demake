function draw_clouds()

    local cloud_color = level_clouds[current_lvl]


    if not cloud_color then return end


    local has_snow = in_levels(current_lvl, snow_only_levels) or in_levels(current_lvl, snow_wind_levels)
    if has_snow then return end

    foreach(clouds, function(c)
        local cloud_x, cloud_y = c.x + cam_x, c.y + cam_y


        rectfill(cloud_x+2, cloud_y+1, cloud_x+c.w-2, cloud_y+c.h-1, cloud_color)
        rectfill(cloud_x, cloud_y+2, cloud_x+c.w, cloud_y+c.h-2, cloud_color)
    end)
end


function draw_rain()

    if current_lvl < 8 or current_lvl > 11 then return end

    foreach(rain, function(drop)
        local x, y = drop.x + cam_x, drop.y + cam_y

        line(x, y, x, y + 2, 5)
    end)
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