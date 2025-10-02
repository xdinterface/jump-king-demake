function reset_all_momentum()
    p.dx = 0
    p.dy = 0
    p.ice_slide_speed = 0
    p.ice_acc_timer = 0
    p.running = false
    p.dir = false
    p.air_moved = false
end

function p_movement()
    local wind_force = 0
    local has_snow_wind = has_wind_this_level

    if has_snow_wind then
        if not p.grounded then
            p.wind_timer, p.wind_ramp = update_ramp(p.wind_timer, wind_ramp_time)
            p.ground_wind_timer = 0
            p.ground_wind_ramp = 0
        else
            p.wind_timer = 0
            p.wind_ramp = 0
            if not in_deep_snow(p) then
                p.ground_wind_timer, p.ground_wind_ramp = update_ramp(p.ground_wind_timer, wind_ramp_time)
            else
                p.ground_wind_timer = 0
                p.ground_wind_ramp = 0
            end
        end

        wind_force = wind_direction * wind_strength * p.wind_ramp * wind_player_force
    end
    
    local is_on_ice = on_ice(p)
    p.ice_sliding = is_on_ice and abs(p.ice_slide_speed) > ice_thresh

    local move_dir = (btn(➡️) and 1 or 0) - (btn(⬅️) and 1 or 0)
    if move_dir != 0 and p.grounded then
        p.flp = move_dir < 0
        p.dir = true
        --stand up from splat if trying to move
        if p.splat then
            p.splat = false
        end
        if not p.crouching then
            if is_on_ice then
                if p.ice_slide_speed != 0 and sgn(move_dir) != sgn(p.ice_slide_speed) then
                    --opposite direction: faster decel
                    p.ice_slide_speed = p.ice_slide_speed - sgn(p.ice_slide_speed) * ice_counter
                    if abs(p.ice_slide_speed) < ice_thresh then
                        p.ice_slide_speed = 0
                        p.ice_acc_timer = 0
                    end
                    p.dx = p.ice_slide_speed
                else
                    --ice acceleration with ramp-up
                    if p.ice_acc_timer == 0 then
                        p.ice_acc_timer = 0.2
                    end
                    p.ice_acc_timer = min(p.ice_acc_timer + 1/15, 1)
                    local ice_acc = ice_ramp * p.ice_acc_timer
                    p.dx = p.dx + move_dir * ice_acc
                    p.dx = mid(-p.max_dx, p.dx, p.max_dx)
                    p.ice_slide_speed = p.dx
                end
            else
                p.dx = p.dx + move_dir * p.move_acc
            end
            p.running = true
        else
            p.running = false
        end
    end

    if not btn(⬅️) and not btn(➡️) and p.grounded then
        p.running = false
        p.dir = false
        if is_on_ice and abs(p.ice_slide_speed) > ice_thresh then
            p.ice_slide_speed = p.ice_slide_speed - sgn(p.ice_slide_speed) * ice_decel
            if abs(p.ice_slide_speed) < ice_thresh then
                p.ice_slide_speed = 0
                p.ice_acc_timer = 0
            end
            p.dx = p.ice_slide_speed
        end
    end

    p.jump_btn_held = btn(🅾️)

    --crouch (can't while splat)
    if btn(🅾️)
    and p.grounded
    and not p.lock_jump
    and not p.splat then
        p.crouching=true

        if is_on_ice and abs(p.ice_slide_speed) > ice_thresh then
            p.ice_slide_speed = p.ice_slide_speed - sgn(p.ice_slide_speed) * ice_decel
            if abs(p.ice_slide_speed) < ice_thresh then
                p.ice_slide_speed = 0
                p.ice_acc_timer = 0
            end
            p.dx = p.ice_slide_speed
        end

        if time()-air_time > charge_rate then
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
        --auto-jump at max charge
        if p.boost >= p.boost_max then
            sfx(0)
            air_time=0
            p.dy=p.dy-(p.boost+0.8)
            p.boost=0
            p.landing=true
            p.jumping=true
            p.grounded=false
            p.crouching=false
            p.running=false
            jump_counter=jump_counter+1
            --add ice velocity to jump
            if is_on_ice and abs(p.ice_slide_speed) > ice_thresh then
                p.dx = p.ice_slide_speed
            end
        end
    end

    if btnp(🅾️)
    and p.grounded then
        p.lock_jump = false
    end

    if not btn(🅾️)
    and p.crouching then
        sfx(0)
        air_time=0
        p.dy=p.dy-(p.boost+0.8)
        p.boost=0
        p.landing=true
        p.jumping=true
        p.grounded=false
        p.crouching=false
        p.running=false
        jump_counter=jump_counter+1
        --add ice velocity to jump
        if is_on_ice and abs(p.ice_slide_speed) > ice_thresh then
            p.dx = p.ice_slide_speed
        end
    end

    --air movement (once per jump)
    if not p.grounded and p.dir and not p.air_moved then
        local slide1, slide2 = collide_map(p, "slide", 1), collide_map(p, "slide", 2)
        if not slide1 and not slide2 then
            local air_dir = p.flp and -1 or 1

            --ice jump direction handling
            if p.was_on_ice and abs(p.ice_slide_speed) > ice_thresh then
                if sgn(air_dir) != sgn(p.ice_slide_speed) then
                    --opposite to slide: reduce strength
                    local reduction = abs(p.ice_slide_speed) * 0.5
                    if p.splat or p.running then
                        p.dx = p.dx + air_dir * max(p.acc - reduction, p.acc * 0.3)
                    else
                        p.dx = p.dx + air_dir * max(p.jump_acc - reduction, p.jump_acc * 0.3)
                    end
                else
                    --same direction: normal
                    if p.splat or p.running then
                        p.dx = p.dx + air_dir * p.acc
                    else
                        p.dx = p.dx + air_dir * p.jump_acc
                    end
                end
            else
                --normal jump
                if p.splat or p.running then
                    p.dx = p.dx + air_dir * p.acc
                else
                    p.dx = p.dx + air_dir * p.jump_acc
                end
            end
            p.air_moved = true
        elseif slide1 or slide2 then
            p.flp = slide1
            local slide_dir = slide1 and -1 or 1

            --diagonal collision: match speeds for 45° angle
            p.dx = slide_dir * abs(p.dy)
            p.splat, p.slammed, p.landing = true, true, false
            p.air_moved = true
        end
    end

    if not p.grounded and wind_force != 0 and not in_deep_snow(p) then
        p.dx = p.dx + wind_force
    end

    --ground wind (capped, blocked by walls/snow)
    if p.grounded and has_snow_wind and not in_deep_snow(p) then
        local ground_wind_force = wind_direction * wind_strength * p.ground_wind_ramp * wind_ground_force

        --check wall blocking
        local blocked_by_wall = false
        if wind_direction < 0 and collide_map(p, "left", 0) then
            blocked_by_wall = true
        elseif wind_direction > 0 and collide_map(p, "right", 0) then
            blocked_by_wall = true
        end

        if not blocked_by_wall then
            p.dx = p.dx + ground_wind_force
            p.dx = mid(-wind_ground_max, p.dx, wind_ground_max)
        end
    end

end
