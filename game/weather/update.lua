
function reset_clouds()
    clouds = {}
    local cloud_layers = {20, 45, 70}
    for i=0,cloud_count do
        local layer = flr(rnd(3)) + 1
        local h_mult = 0.7 + rnd(0.8)
        local w = cloud_size_min+rnd(cloud_size_max-cloud_size_min)
        local cloud_h = flr(6 * h_mult)
        local w_adjust = (h_mult > 1.2) and -4 or 0
        local adj_w = w + w_adjust

        clouds[i]={
            x=rnd(screen_size),
            y=cloud_layers[layer] + rnd(12) - 6,
            layer=layer,
            spd=cloud_spd_min+rnd(cloud_spd_max-cloud_spd_min),
            w=w,
            cloud_w=w,
            cloud_h=cloud_h,
            adj_w=adj_w,
            h_mult=h_mult
        }
    end
end

function update_clouds()
    if not last_cloud_lvl then last_cloud_lvl = current_lvl end
    if current_lvl != last_cloud_lvl then
        last_cloud_lvl = current_lvl
        reset_clouds()
    end

    foreach(clouds, function(c)
        c.x += c.spd
        if c.x > screen_size + c.w then
            c.x = -c.w
        end
    end)
end

function update_snow_wind()
    if current_lvl != last_lvl then
        last_lvl = current_lvl
        level_entry_time = 0

        if not in_levels(current_lvl, snow_wind_levels) then
            wind_strength = 0
        end
    end

    level_entry_time = level_entry_time + 1/fps

    local has_snow_only = in_levels(current_lvl, snow_only_levels)
    local has_snow_wind = in_levels(current_lvl, snow_wind_levels)

    if not has_snow_only and not has_snow_wind then return end

    wind_timer = wind_timer + 1/fps

    if wind_phase == 0 then
        wind_direction = -1
        if wind_timer >= wind_ramp_time then
            wind_phase = 1
            wind_timer = 0
        end
    elseif wind_phase == 1 then
        if wind_timer >= wind_blow_time then
            wind_phase = 2
            wind_timer = 0
        end
    elseif wind_phase == 2 then
        if wind_timer >= wind_ramp_time then
            wind_phase = 3
            wind_timer = 0
        end
    elseif wind_phase == 3 then
        wind_direction = 1
        if wind_timer >= wind_ramp_time then
            wind_phase = 4
            wind_timer = 0
        end
    elseif wind_phase == 4 then
        if wind_timer >= wind_blow_time then
            wind_phase = 5
            wind_timer = 0
        end
    elseif wind_phase == 5 then
        if wind_timer >= wind_ramp_time then
            wind_phase = 0
            wind_timer = 0
        end
    end

    if has_snow_wind then
        --2s delay for first wind level (level 20)
        local apply_wind = true
        if current_lvl == 20 and not initial_wind_delay_done then
            if level_entry_time < 2.0 then
                apply_wind = false
                wind_strength = 0
            else
                initial_wind_delay_done = true
            end
        end

        if apply_wind then
            if wind_phase == 0 then
                wind_strength = wind_timer / wind_ramp_time
            elseif wind_phase == 1 then
                wind_strength = 1
            elseif wind_phase == 2 then
                wind_strength = 1 - (wind_timer / wind_ramp_time)
            elseif wind_phase == 3 then
                wind_strength = wind_timer / wind_ramp_time
            elseif wind_phase == 4 then
                wind_strength = 1
            elseif wind_phase == 5 then
                wind_strength = 1 - (wind_timer / wind_ramp_time)
            end
        end
    end
    
    foreach(snow, function(flake)
        flake.y = flake.y + flake.spd

        if has_snow_wind then
            flake.x = flake.x + wind_direction * wind_strength * flake.spd * snow_wind_factor
        end

        if flake.y > screen_size then
            flake.y = -8
            flake.x = rnd(screen_size)
        end
        if flake.x < 0 then flake.x = screen_size end
        if flake.x > screen_size then flake.x = 0 end
    end)
end