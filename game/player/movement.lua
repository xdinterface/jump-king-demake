function p_movement()
    --wind effect on player with ramping (only for snow+wind levels, not snow-only)
    local wind_force = 0
    --cache wind level check for this frame
    local has_snow_wind = has_wind_this_level

    if has_snow_wind then
        --update player wind ramp timer when in air
        if not p.grounded then
            p.wind_timer, p.wind_ramp = update_ramp(p.wind_timer, weather_config.wind.ramp_time)
            --reset ground wind ramp when airborne
            p.ground_wind_timer = 0
            p.ground_wind_ramp = 0
        else
            --reset air wind ramp when grounded
            p.wind_timer = 0
            p.wind_ramp = 0
            --update ground wind ramp when grounded
            if not in_deep_snow(p) then
                p.ground_wind_timer, p.ground_wind_ramp = update_ramp(p.ground_wind_timer, weather_config.wind.ramp_time)
            else
                p.ground_wind_timer = 0
                p.ground_wind_ramp = 0
            end
        end

        wind_force = wind_direction * wind_strength * p.wind_ramp * weather_config.wind.player_force
    end
    
    --horizontal movement
    local move_dir = (btn(➡️) and 1 or 0) - (btn(⬅️) and 1 or 0)
    if move_dir != 0 and p.grounded then
        p.flp = move_dir < 0
        p.dir = true
        if not p.crouching then
            --apply slower movement if X button is held
            local walk_speed = btn(❎) and (p.walk_acc * 0.5) or p.walk_acc
            p.dx = p.dx + move_dir * walk_speed
            p.lying = false
            p.running = true
        else
            p.running = false
        end
    end

    --stop running
    if not btn(⬅️) and not btn(➡️) and p.grounded then
        p.running = false
        p.dir = false
    end

    --crouch
    if btn(🅾️)
    and p.grounded
    and not p.lock_jump then
        p.crouching=true
        p.lying=false

        --charge jump while crouching
        if time()-air_time > physics_config.charge_rate then
            air_time = time()
            if p.boost < p.boost_max then
                p.boost=p.boost+0.4
            end
        end

        if p.boost > p.boost_max then
            p.boost = p.boost_max
        end

        if not btn(⬅️)
        and not btn(➡️) then
                p.dir=false
        end
        if btn(❎) then
            p.crouching=false
            p.boost=0
            p.lock_jump=true
        end
    end

    if btnp(🅾️)
    and p.grounded then
        p.lock_jump = false
    end

    --jump
    if not btn(🅾️)
    and p.crouching then			
        sfx(0)	
        air_time=0
        p.dy=p.dy-p.boost
        p.boost=0
        p.landing=true
        p.jumping=true
        p.grounded=false
        p.crouching=false
        p.running=false
        jump_counter=jump_counter+1
    end

    --move to side in air (apply initial momentum only once)
    if not p.grounded and p.dir and not p.air_moved then
        local slide1, slide2 = collide_map(p, "slide", 1), collide_map(p, "slide", 2)
        if not slide1 and not slide2 then
            local air_dir = p.flp and -1 or 1

            if p.lying or p.running then
                p.dx = p.dx + air_dir * p.acc
            else
                p.dx = p.dx + air_dir * p.jump_acc
            end
            p.air_moved = true  --mark that we've applied air movement
        elseif slide1 or slide2 then
            p.flp = slide1
            --when hitting a diagonal, split momentum properly for 45-degree angle
            --for game feel, make horizontal match vertical exactly
            local slide_dir = slide1 and -1 or 1
            p.dx = slide_dir * abs(p.dy)  --match speeds
            --keep vertical speed as is for smooth sliding
            p.lying, p.smash, p.landing = true, true, false
            p.air_moved = true  --also mark for slide case
        end
    end

    --apply wind force when airborne
    if not p.grounded and wind_force != 0 then
        p.dx = p.dx + wind_force
    end

    --apply ground wind when grounded (slower, capped)
    --disable if player feet are in deep snow (flag 5) or if against a wall
    if p.grounded and has_snow_wind and not in_deep_snow(p) then
        local ground_wind_force = wind_direction * wind_strength * p.ground_wind_ramp * weather_config.wind.ground_force

        --check if player is against a wall in the direction of wind
        local blocked_by_wall = false
        if wind_direction < 0 and collide_map(p, "left", 0) then
            blocked_by_wall = true  --wind blowing left but wall on left
        elseif wind_direction > 0 and collide_map(p, "right", 0) then
            blocked_by_wall = true  --wind blowing right but wall on right
        end

        if not blocked_by_wall then
            p.dx = p.dx + ground_wind_force
            --cap ground wind speed
            p.dx = mid(-weather_config.wind.ground_max_speed, p.dx, weather_config.wind.ground_max_speed)
        end
    end

end
