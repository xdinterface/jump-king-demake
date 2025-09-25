function draw_clouds()
    --don't draw clouds during snow levels (snow-only or snow+wind)
    local has_snow = false

    for i=1,#snow_only_levels do
        if snow_only_levels[i] == current_lvl then
            has_snow = true
            break
        end
    end

    if not has_snow then
        for i=1,#snow_wind_levels do
            if snow_wind_levels[i] == current_lvl then
                has_snow = true
                break
            end
        end
    end

    if has_snow then return end
    
    foreach(clouds, function(c)
        c.x += c.spd

        --draw solid clouds with variable height and smooth sub-pixel movement
        local cloud_x = c.x + cam_x
        local cloud_y = c.y + cam_y
        local cloud_w = c.w
        local cloud_h = flr(6 * c.h_mult)  --variable height based on multiplier

        --adjust width slightly based on height for natural proportions
        local w_adjust = (c.h_mult > 1.2) and -4 or 0  --taller clouds are slightly slimmer
        local adj_w = cloud_w + w_adjust

        --main cloud body (rectangle with rounded ends)
        rectfill(cloud_x + 4, cloud_y + 2, cloud_x + adj_w - 4, cloud_y + cloud_h - 2, 13)

        --add some irregular edges for natural shape (scaled with height)
        if cloud_h > 4 then
            rectfill(cloud_x + 2, cloud_y + 3, cloud_x + adj_w - 2, cloud_y + cloud_h - 3, 13)
        end
        if cloud_h > 3 then
            rectfill(cloud_x + 6, cloud_y + 1, cloud_x + adj_w - 6, cloud_y + cloud_h - 1, 13)
        end

        if c.x > game_config.screen_size then
            c.x = -c.w
            --maintain cloud grouping by staying in same layer
            local cloud_layers = {20, 45, 70}
            c.y = cloud_layers[c.layer] + rnd(12) - 6  --stay in same layer ± 6px variation
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
    --check if current level has snow (snow-only or snow+wind)
    local has_snow = false

    for i=1,#snow_only_levels do
        if snow_only_levels[i] == current_lvl then
            has_snow = true
            break
        end
    end

    if not has_snow then
        for i=1,#snow_wind_levels do
            if snow_wind_levels[i] == current_lvl then
                has_snow = true
                break
            end
        end
    end

    if not has_snow then return end
    
    --draw snowflakes (using foreach like clouds)
    local drawn_count = 0
    foreach(snow, function(flake)
        --draw white snowflake with camera offset (like clouds)
        pset(flake.x + cam_x, flake.y + cam_y, 7)
        drawn_count = drawn_count + 1
    end)
    
    --debug: snow count moved to main debug system
    snow_drawn_count = drawn_count
end