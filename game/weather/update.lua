
function update_clouds()
    last_cloud_lvl = last_cloud_lvl or current_lvl
    if current_lvl != last_cloud_lvl then
        last_cloud_lvl = current_lvl
        reset_clouds()
    end

    foreach(clouds, function(c)
        c.x += c.spd
        if c.x > screen_size + c.w then c.x = -c.w end
    end)
end

function update_rain()
    if current_lvl < 8 or current_lvl > 11 then return end

    foreach(rain, function(drop)
        drop.y += drop.spd
        if drop.y > screen_size then
            drop.y, drop.x = -4, rnd(screen_size)
        end
    end)
end

function update_snow_wind()
    if current_lvl != last_lvl then
        last_lvl, level_entry_time = current_lvl, 0
        if not in_levels(current_lvl, snow_wind_levels) then wind_strength = 0 end
    end

    level_entry_time += 1/fps

    local has_snow_only, has_snow_wind = in_levels(current_lvl, snow_only_levels), in_levels(current_lvl, snow_wind_levels)

    if not has_snow_only and not has_snow_wind then return end

    wind_timer += 1/fps
    wind_direction = wind_phase < 3 and -1 or 1

    local phase_times, next_phases = {wind_ramp_time, wind_blow_time, wind_ramp_time, wind_ramp_time, wind_blow_time, wind_ramp_time}, {1, 2, 3, 4, 5, 0}

    if wind_timer >= phase_times[wind_phase + 1] then
        wind_phase, wind_timer = next_phases[wind_phase + 1], 0
    end

    if has_snow_wind then
        local apply_wind = true
        if current_lvl == 20 and not initial_wind_delay_done then
            if level_entry_time < 2.0 then
                apply_wind, wind_strength = false, 0
            else
                initial_wind_delay_done = true
            end
        end

        if apply_wind then
            wind_strength = (wind_phase == 1 or wind_phase == 4) and 1 or
                          (wind_phase == 0 or wind_phase == 3) and wind_timer / wind_ramp_time or
                          1 - (wind_timer / wind_ramp_time)
        end
    end
    
    foreach(snow, function(flake)
        flake.y += flake.spd

        if has_snow_wind then
            flake.x += wind_direction * wind_strength * flake.spd * snow_wind_factor
        end

        if flake.y > screen_size then
            flake.y, flake.x = -8, rnd(screen_size)
        end
        if flake.x < 0 then flake.x = screen_size
        elseif flake.x > screen_size then flake.x = 0 end
    end)
end