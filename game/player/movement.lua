function reset_all_momentum()
    p.dx,p.dy,p.ice_slide_speed,p.ice_acc_timer = 0,0,0,0
    p.running,p.dir,p.air_moved = false,false,false
end

function reset_player_state()
    p.dx,p.dy,p.ice_slide_speed,p.ice_acc_timer = 0,0,0,0
    p.boost,p.wind_timer,p.wind_ramp = 0,0,0
    p.ground_wind_timer,p.ground_wind_ramp = 0,0
    p.running,p.dir,p.air_moved,p.grounded = false,false,false,false
    p.crouching,p.jumping,p.splat = false,false,false
    p.landing,p.slammed,p.hit = false,false,false
    p.falling = true
end

function p_movement()

    local o_btn = btn(🅾️)
    if o_btn then
        if not o_button_held then o_button_press_time,o_button_held = time(),true
        elseif time()-o_button_press_time > 0.5 and not position_saved then
            saved_pos_x,saved_pos_y,position_saved = p.x,p.y,true
        end
    elseif o_button_held then
        if time()-o_button_press_time <= 0.5 and saved_pos_x then
            p.x,p.y = saved_pos_x,saved_pos_y reset_player_state()
        end
        o_button_held,position_saved = false,false
    end

    local wind_force = 0
    local has_snow_wind = has_wind_this_level

    if has_snow_wind then
        if not p.grounded then
            p.wind_timer,p.wind_ramp = update_ramp(p.wind_timer, wind_ramp_time)
            p.ground_wind_timer,p.ground_wind_ramp = 0,0
        else
            p.wind_timer,p.wind_ramp = 0,0
            if not in_deep_snow(p) then
                p.ground_wind_timer,p.ground_wind_ramp = update_ramp(p.ground_wind_timer, wind_ramp_time)
            else
                p.ground_wind_timer,p.ground_wind_ramp = 0,0
            end
        end

        wind_force = wind_direction * wind_strength * p.wind_ramp * wind_player_force
    end
    
    local is_on_ice = on_ice(p)
    p.ice_sliding = is_on_ice and abs(p.ice_slide_speed) > ice_thresh

    local left,right = btn(⬅️),btn(➡️)
    local move_dir = (right and 1 or 0) - (left and 1 or 0)
    if move_dir != 0 and p.grounded then
        if move_dir < 0 then p.flp = true
        elseif move_dir > 0 then p.flp = false
        end
        p.dir = true

        if not p.crouching then
            if is_on_ice then
                if p.ice_slide_speed != 0 and sgn(move_dir) != sgn(p.ice_slide_speed) then

                    update_ice_decel(ice_counter)
                else

                    if p.ice_acc_timer == 0 then
                        p.ice_acc_timer = 0.2
                    end
                    p.ice_acc_timer = min(p.ice_acc_timer + 1/60, 1)
                    local ice_acc = ice_ramp * p.ice_acc_timer
                    p.dx = p.dx + move_dir * ice_acc
                    p.dx = mid(-p.max_dx, p.dx, p.max_dx)
                    p.ice_slide_speed = p.dx
                end
            else
                p.dx = move_dir * p.max_walk_dx
            end
            p.running = true
        else
            p.running = false
        end
    end

    if not left and not right and p.grounded then
        p.running = false
        p.dir = false
        if is_on_ice and abs(p.ice_slide_speed) > ice_thresh then
            update_ice_decel(ice_decel)
        end
    end

    local jump_btn = btn(❎)
    p.jump_btn_held = jump_btn


    if p.splat and p.grounded and (left or right or jump_btn or o_btn) then
        p.splat = false
        p.sp = 1
    end


    if jump_btn
    and p.grounded
    and not p.lock_jump
    and not p.splat then
        p.crouching=true

        if is_on_ice and abs(p.ice_slide_speed) > ice_thresh then
            update_ice_decel(ice_decel)
        end

        if time()-air_time > charge_rate then
            air_time = time()
            if p.boost < p.boost_max then
                p.boost=p.boost+0.11
            end
        end

        p.boost = min(p.boost, p.boost_max)

        if p.boost >= p.min_charge_threshold then
            p.min_charge_met = true
        end

        if not left and not right then
                p.dir=false
        end

        if p.boost >= p.boost_max then
            execute_jump(move_dir, is_on_ice)
        end
    end

    if btnp(❎)
    and p.grounded then
        p.lock_jump = false
        p.min_charge_met = false
    end

    if not jump_btn and p.crouching then
        if p.min_charge_met then
            execute_jump(move_dir, is_on_ice)
        else
            if time()-air_time > charge_rate then
                air_time = time()
                if p.boost < p.boost_max then
                    p.boost=p.boost+0.11
                end
            end
            p.boost = min(p.boost, p.boost_max)
            if p.boost >= p.min_charge_threshold then
                p.min_charge_met = true
                execute_jump(move_dir, is_on_ice)
            end
        end
    end


    if not p.grounded and p.dir and not p.air_moved then
        local slide1,slide2 = collide_map(p,"slide",1),collide_map(p,"slide",2)
        if not slide1 and not slide2 then
            local air_dir = p.flp and -1 or 1


            if p.was_on_ice and abs(p.ice_slide_speed) > ice_thresh then
                if sgn(air_dir) != sgn(p.ice_slide_speed) then

                    local reduction = abs(p.ice_slide_speed) * 0.5
                    local acc = (p.splat or p.running) and p.acc or p.jump_acc
                    p.dx = p.dx + air_dir * max(acc - reduction, acc * 0.3)
                else

                    p.dx = p.dx + air_dir * ((p.splat or p.running) and p.acc or p.jump_acc)
                end
            else

                p.dx = p.dx + air_dir * ((p.splat or p.running) and p.acc or p.jump_acc)
            end
            p.air_moved = true
        elseif slide1 or slide2 then
            p.flp = slide1
            local slide_dir = slide1 and -1 or 1


            p.dx = slide_dir * abs(p.dy)
            p.slammed,p.landing = true,false
            p.air_moved = true
        end
    end

    if not p.grounded and wind_force != 0 and not in_deep_snow(p) then
        p.dx = p.dx + wind_force
    end


    if p.grounded and has_snow_wind and not in_deep_snow(p) then
        local ground_wind_force = wind_direction * wind_strength * p.ground_wind_ramp * wind_ground_force


        local blocked_by_wall = (wind_direction < 0 and collide_map(p,"left",0)) or (wind_direction > 0 and collide_map(p,"right",0))

        if not blocked_by_wall then
            p.dx = p.dx + ground_wind_force
            p.dx = mid(-wind_ground_max, p.dx, wind_ground_max)
        end
    end

end

function update_ice_decel(rate)
    p.ice_slide_speed = p.ice_slide_speed - sgn(p.ice_slide_speed) * rate
    if abs(p.ice_slide_speed) < ice_thresh then
        p.ice_slide_speed,p.ice_acc_timer = 0,0
    end
    p.dx = p.ice_slide_speed
end

function execute_jump(move_dir, is_on_ice)
    sfx(0)
    air_time=0
    p.dy=p.dy-p.boost
    p.boost=0
    p.landing,p.jumping,p.grounded,p.crouching,p.running=true,true,false,false,false
    jump_counter=jump_counter+1

    if move_dir != 0 then p.flp = move_dir < 0 end

    if is_on_ice and abs(p.ice_slide_speed) > ice_thresh then
        p.dx = p.ice_slide_speed
    end
end
