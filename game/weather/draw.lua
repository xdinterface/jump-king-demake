function draw_clouds()
    local has_snow = in_levels(current_lvl, snow_only_levels) or in_levels(current_lvl, snow_wind_levels)

    if current_lvl == 25 or current_lvl == 26 or (current_lvl >= 13 and current_lvl <= 16) then
        return
    end

    if has_snow then return end

    foreach(clouds, function(c)
        local cloud_zone = get_current_zone(c.x, c.y)
        local cloud_color = cloud_zone and cloud_zone.cloud_color or 13

        if not cloud_color then return end

        local cloud_x = c.x + cam_x
        local cloud_y = c.y + cam_y

        rectfill(cloud_x + 4, cloud_y + 2, cloud_x + c.adj_w - 4, cloud_y + c.cloud_h - 2, cloud_color)

        if c.cloud_h > 4 then
            rectfill(cloud_x + 2, cloud_y + 3, cloud_x + c.adj_w - 2, cloud_y + c.cloud_h - 3, cloud_color)
        end
        if c.cloud_h > 3 then
            rectfill(cloud_x + 6, cloud_y + 1, cloud_x + c.adj_w - 6, cloud_y + c.cloud_h - 1, cloud_color)
        end
    end)
end

function draw_rain()
    foreach(rain, function(c)
        c.y =c.y+ c.spd
        rectfill(
        c.x,c.y,
        c.x+c.w,
        c.y+4+(1-c.w/64)*12,1)
        if c.y > cam_y+128 then
            c.y = cam_y-128   
            c.x = rnd(128)   
        end
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