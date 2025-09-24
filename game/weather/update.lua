function update_snow_wind()
    --check if current level has snow (with or without wind)
    local has_snow_only = false
    local has_snow_wind = false

    for i=1,#snow_only_levels do
        if snow_only_levels[i] == current_lvl then
            has_snow_only = true
            break
        end
    end

    for i=1,#snow_wind_levels do
        if snow_wind_levels[i] == current_lvl then
            has_snow_wind = true
            break
        end
    end

    if not has_snow_only and not has_snow_wind then return end
    
    --update wind cycle (only for snow+wind levels)
    if has_snow_wind then
        wind_timer = wind_timer + 1/game_config.fps

        --wind phases: 0=ramp up left, 1=blow left, 2=ramp down left, 3=ramp up right, 4=blow right, 5=ramp down right
        if wind_phase == 0 then --ramp up left
            wind_direction = -1
            wind_strength = wind_timer
            if wind_timer >= weather_config.wind.ramp_time then
                wind_phase = 1
                wind_timer = 0
            end
        elseif wind_phase == 1 then --blow left
            wind_strength = 1
            if wind_timer >= weather_config.wind.blow_time then
                wind_phase = 2
                wind_timer = 0
            end
        elseif wind_phase == 2 then --ramp down left
            wind_strength = 1 - wind_timer
            if wind_timer >= weather_config.wind.ramp_time then
                wind_phase = 3
                wind_timer = 0
            end
        elseif wind_phase == 3 then --ramp up right
            wind_direction = 1
            wind_strength = wind_timer
            if wind_timer >= weather_config.wind.ramp_time then
                wind_phase = 4
                wind_timer = 0
            end
        elseif wind_phase == 4 then --blow right
            wind_strength = 1
            if wind_timer >= weather_config.wind.blow_time then
                wind_phase = 5
                wind_timer = 0
            end
        elseif wind_phase == 5 then --ramp down right
            wind_strength = 1 - wind_timer
            if wind_timer >= weather_config.wind.ramp_time then
                wind_phase = 0
                wind_timer = 0
            end
        end
    else
        --no wind for snow-only levels - but keep global wind cycle running
        --wind effects simply won't be applied in these levels
    end
    
    --update snow particles (using foreach like clouds)
    foreach(snow, function(flake)
        --fall down
        flake.y = flake.y + flake.spd
        
        --wind effect (horizontal movement same speed as falling)
        if has_snow_wind then
            flake.x = flake.x + wind_direction * wind_strength * flake.spd * weather_config.snow.wind_factor
        end
        
        --wrap around screen (like clouds do)
        if flake.y > game_config.screen_size then
            flake.y = -8
            flake.x = rnd(game_config.screen_size)
        end
        if flake.x < 0 then flake.x = game_config.screen_size end
        if flake.x > game_config.screen_size then flake.x = 0 end
    end)
end