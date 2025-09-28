function reset_all_momentum()
    --reset all movement and momentum states
    p.dx = 0
    p.dy = 0
    p.ice_slide_speed = 0
    p.ice_acc_timer = 0
    p.running = false
    p.dir = false
    p.air_moved = false
end

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
    
    --check if on ice
    local is_on_ice = on_ice(p)

    --update ice sliding flag
    p.ice_sliding = is_on_ice and abs(p.ice_slide_speed) > physics_config.ice_slide_threshold

    --horizontal movement
    local move_dir = (btn(➡️) and 1 or 0) - (btn(⬅️) and 1 or 0)
    if move_dir != 0 and p.grounded then
        p.flp = move_dir < 0
        p.dir = true
        if not p.crouching then
            if is_on_ice then
                --on ice: gradual acceleration with ramp-up
                if p.ice_slide_speed != 0 and sgn(move_dir) != sgn(p.ice_slide_speed) then
                    --moving opposite to slide direction: faster deceleration
                    p.ice_slide_speed = p.ice_slide_speed - sgn(p.ice_slide_speed) * physics_config.ice_counter_decel
                    if abs(p.ice_slide_speed) < physics_config.ice_slide_threshold then
                        p.ice_slide_speed = 0
                        p.ice_acc_timer = 0
                    end
                    p.dx = p.ice_slide_speed  --update actual velocity
                else
                    --accelerate with ramp-up on ice
                    if p.ice_acc_timer == 0 then
                        p.ice_acc_timer = 0.2  --start at 20% for instant initial movement
                    end
                    p.ice_acc_timer = min(p.ice_acc_timer + 1/15, 1)  --ramp up over ~0.5 seconds
                    local ice_acc = physics_config.ice_acc_ramp * p.ice_acc_timer
                    local walk_speed = btn(❎) and (ice_acc * 0.5) or ice_acc
                    p.dx = p.dx + move_dir * walk_speed
                    --limit ice speed to normal walking limits
                    local max_speed = btn(❎) and (p.max_walk_dx * 0.5) or p.max_walk_dx
                    p.dx = mid(-max_speed, p.dx, max_speed)
                    p.ice_slide_speed = p.dx
                end
            else
                --normal movement on regular ground
                local walk_speed = btn(❎) and (p.walk_acc * 0.5) or p.walk_acc
                p.dx = p.dx + move_dir * walk_speed
            end
            --only clear lying state if stopped moving (from diagonal slide)
            if not p.lying or (abs(p.dx) < 0.1 and abs(p.dy) < 0.1) then
                p.lying = false
            end
            p.running = true
        else
            p.running = false
        end
    end

    --stop running (but handle ice sliding)
    if not btn(⬅️) and not btn(➡️) and p.grounded then
        p.running = false
        p.dir = false
        if is_on_ice and abs(p.ice_slide_speed) > physics_config.ice_slide_threshold then
            --continue sliding on ice when no input
            p.ice_slide_speed = p.ice_slide_speed - sgn(p.ice_slide_speed) * physics_config.ice_decel
            if abs(p.ice_slide_speed) < physics_config.ice_slide_threshold then
                p.ice_slide_speed = 0
                p.ice_acc_timer = 0
            end
            p.dx = p.ice_slide_speed
        end
    end

    --detect jump button release (was pressed last frame but not this frame)
    if p.jump_btn_held and not btn(🅾️) then
        p.jump_canceled = false  --reset cancel flag on button release
    end
    p.jump_btn_held = btn(🅾️)  --store current button state for next frame

    --crouch (prevent if lying from diagonal slide)
    if btn(🅾️)
    and p.grounded
    and not p.lock_jump
    and not p.jump_canceled
    and not p.lying then  --can't crouch/jump while lying
        p.crouching=true

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
            p.jump_canceled=true  --cancel jump, disable until button release
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
        --add sliding velocity to jump if on ice
        if is_on_ice and abs(p.ice_slide_speed) > physics_config.ice_slide_threshold then
            p.dx = p.ice_slide_speed
        end
    end

    --move to side in air (apply initial momentum only once)
    if not p.grounded and p.dir and not p.air_moved then
        local slide1, slide2 = collide_map(p, "slide", 1), collide_map(p, "slide", 2)
        if not slide1 and not slide2 then
            local air_dir = p.flp and -1 or 1

            --check if jumping opposite to ice slide direction
            if p.was_on_ice and abs(p.ice_slide_speed) > physics_config.ice_slide_threshold then
                if sgn(air_dir) != sgn(p.ice_slide_speed) then
                    --jumping opposite to slide: reduce jump strength based on slide speed
                    local reduction = abs(p.ice_slide_speed) * 0.5  --reduce by half of slide speed
                    if p.lying or p.running then
                        p.dx = p.dx + air_dir * max(p.acc - reduction, p.acc * 0.3)
                    else
                        p.dx = p.dx + air_dir * max(p.jump_acc - reduction, p.jump_acc * 0.3)
                    end
                else
                    --jumping in same direction as slide: normal behavior
                    if p.lying or p.running then
                        p.dx = p.dx + air_dir * p.acc
                    else
                        p.dx = p.dx + air_dir * p.jump_acc
                    end
                end
            else
                --normal jump (not from ice)
                if p.lying or p.running then
                    p.dx = p.dx + air_dir * p.acc
                else
                    p.dx = p.dx + air_dir * p.jump_acc
                end
            end
            p.air_moved = true  --mark that we've applied air movement
        elseif slide1 or slide2 then
            p.flp = slide1
            local slide_dir = slide1 and -1 or 1

            --when hitting a diagonal, split momentum properly for 45-degree angle
            --for game feel, make horizontal match vertical exactly
            p.dx = slide_dir * abs(p.dy)  --match speeds
            --keep vertical speed as is for smooth sliding
            p.lying, p.smash, p.landing = true, true, false
            p.air_moved = true  --also mark for slide case
        end
    end

    --apply wind force when airborne (blocked by deep snow)
    if not p.grounded and wind_force != 0 and not in_deep_snow(p) then
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
