function p_update()
        has_wind_this_level = in_levels(current_lvl, snow_wind_levels)

        p_movement()

        local hit_ceiling = false
        local slide1 = collide_map(p, "slide", 1)
        local slide2 = collide_map(p, "slide", 2)
        local slide3 = collide_map(p, "slide", 3)
        local slide4 = collide_map(p, "slide", 4)

        if slide1 or slide2 then
                local slide_dir = slide1 and -1 or 1

                if not p.was_on_diagonal then
                        if p.dx != 0 and sgn(p.dx) != sgn(slide_dir) then
                                reset_all_momentum()
                        end
                end

                if slide1 then
                        p.dx = p.dx - gravity
                else
                        p.dx = p.dx + gravity
                end
                p.dy = p.dy + gravity

                --force dx/dy sync to prevent falling through diagonals
                local target_speed = min(abs(p.dy), 2.5)
                p.dx = slide_dir * target_speed
                p.dy = abs(target_speed)

                --limit diagonal speed to prevent collision skipping
                p.dx = mid(-2.5, p.dx, 2.5)
                p.dy = mid(0, p.dy, 2.5)

                p.ice_slide_speed = 0
                p.ice_acc_timer = 0

                --only go into lying/smashing state if moving fast enough
                local total_speed = abs(p.dx) + abs(p.dy)
                local lying_threshold = 1.8

                if total_speed >= lying_threshold then
                        p.splat = true
                        p.slammed = true
                else
                        p.splat = false
                        p.slammed = false
                        p.falling = true  --gentle falling state instead
                end

                p.grounded = false
        elseif slide3 or slide4 then
                --upward diagonal handling
                local slide_dir = slide3 and -1 or 1

                --share momentum reset logic with flags 1&2
                if not p.was_on_diagonal then
                        if p.dx != 0 and sgn(p.dx) != sgn(slide_dir) then
                                reset_all_momentum()
                        end
                end

                --apply gravity to vertical only
                p.dy = p.dy + gravity

                --sync horizontal to vertical magnitude (maintaining 45° angle)
                p.dx = slide_dir * abs(p.dy)

                --share speed limiting with 1&2
                p.dx = mid(-2.5, p.dx, 2.5)
                p.dy = mid(-2.5, p.dy, 2.5)

                --state management for upward diagonals
                p.ice_slide_speed = 0
                p.ice_acc_timer = 0

                --upward diagonals should NOT automatically cause splat/slam
                if p.was_on_diagonal then
                        --continuing on diagonal, maintain current state
                        p.splat = false
                        p.slammed = false
                else
                        --just landed on diagonal - check fall speed
                        if abs(p.dy) >= p.max_dy then
                                p.splat = true
                                p.slammed = true
                        else
                                p.splat = false
                                p.slammed = false
                        end
                end

                --key difference: player can be "grounded" on upward diagonals
                if p.dy >= 0 then
                        p.grounded = true
                        p.falling = false
                        p.jumping = false
                else
                        p.grounded = false
                        p.jumping = true
                        p.falling = false
                end
        else
                if not hit_ceiling then
                        p.dy = p.dy + gravity
                end
        end

        if collide_map(p,"down",7) then
                p.dx=p.dx*friction
        end

        if p.dy>=p.max_dy then
                p.splat=true
                p.slammed=true
                p.landing=false
        end
    
        if p.dy>0 then
                p.falling=true
                p.grounded=false
                p.jumping=false
                if not p.slammed and p.dy>1 then
                        p.landing=true
                end

                if not slide1 and not slide2 then
                        p.dy=limit_speed(p.dy,p.max_dy)
                else
                        p.dy=limit_speed(p.dy,p.max_slide)
                end

                if collide_map_respect_diagonals(p,"down",0) then
                        p.y=p.y-(((p.y+p.h+1)%8)-1)

                        if not slide1 and not slide2 then
                                if p.slammed then
                                        sfx(-1,1)
                                        sfx(3,1)
                                        p.slammed=false
                                        fall_counter=fall_counter+1
                                elseif p.landing then
                                        sfx(-1,1)
                                        sfx(1,1)
                                        p.landing=false
                                end
                                p.falling=false
                                p.grounded=true
                                p.hit=false
                                p.dy=0
                                p.air_moved=false

                                --preserve momentum when landing on ice
                                if on_ice(p) then
                                        if abs(p.dx) > ice_thresh then
                                                p.ice_slide_speed = p.dx
                                        else
                                                p.ice_slide_speed = 0
                                        end
                                        p.ice_acc_timer = 0
                                elseif p.was_on_ice then
                                        p.ice_slide_speed = 0
                                        p.ice_acc_timer = 0
                                end
                        end
                end
        elseif p.dy<0 then
                p.jumping=true
                if collide_map(p,"up",0) then
                        --stop upward movement and let gravity naturally take over
                        p.dy = 0
                        --reduce horizontal velocity like walls do
                        p.dx = p.dx * bounce_factor
                        hit_ceiling = true
                end
        end

        if p.dx<0 then
                handle_speed(slide1, slide2)

                if collide_map(p,"left",0) then
                        if p.grounded then
                                p.dx=0
                                p.ice_slide_speed = 0
                                p.ice_acc_timer = 0

                                local left_edge = p.x + p.hb_x_off
                                local found_wall = false
                                local wall_x = 0

                                for check_offset = 0, 4 do
                                        local check_x = left_edge - check_offset
                                        local check_y = p.y + p.hb_y_off + (p.hb_h or p.h)/2
                                        local tile_x = flr(check_x / 8)
                                        local tile_y = flr(check_y / 8)
                                        local tile_id = mget(tile_x, tile_y)

                                        if fget(tile_id, 0) or (tile_id >= 118 and tile_id <= 121) or tile_id == 36 or tile_id == 37 or tile_id == 48 or tile_id == 49 or tile_id == 110 then
                                                found_wall = true
                                                --custom snapping for column/row tiles
                                                if tile_id == 119 or tile_id == 37 or tile_id == 49 then
                                                        wall_x = tile_x * 8 + 2
                                                elseif tile_id == 118 or tile_id == 36 or tile_id == 48 then
                                                        wall_x = tile_x * 8 + 6
                                                elseif tile_id == 120 or tile_id == 121 then
                                                        return
                                                else
                                                        wall_x = (tile_x + 1) * 8
                                                end
                                                break
                                        end
                                end

                                if found_wall then
                                        p.x = wall_x - p.hb_x_off
                                end
                        else
                                sfx(-1,1)
                                sfx(2,1)
                                p.ice_slide_speed = 0
                                p.ice_acc_timer = 0
                                --wind cushioning
                                local wind_contribution = calculate_wind_contribution()
                                if wind_contribution < 0 then
                                        p.dx = -1 * (p.dx - wind_contribution) * bounce_factor
                                else
                                        p.dx = -1 * p.dx * bounce_factor
                                end
                                p.dy = p.dy * 0.8
                                p.hit=true
                        end
                end
                stop_running()
        elseif p.dx>0 then
                handle_speed(slide1, slide2)

                if collide_map(p,"right",0) then
                        if p.grounded then
                                p.dx=0
                                p.ice_slide_speed = 0
                                p.ice_acc_timer = 0

                                local right_edge = p.x + p.hb_x_off + p.hb_w
                                local found_wall = false
                                local wall_x = 0

                                for check_offset = 0, 4 do
                                        local check_x = right_edge + check_offset
                                        local check_y = p.y + p.hb_y_off + (p.hb_h or p.h)/2
                                        local tile_x = flr(check_x / 8)
                                        local tile_y = flr(check_y / 8)
                                        local tile_id = mget(tile_x, tile_y)

                                        if fget(tile_id, 0) or (tile_id >= 118 and tile_id <= 121) or tile_id == 36 or tile_id == 37 or tile_id == 48 or tile_id == 49 or tile_id == 110 then
                                                found_wall = true
                                                --custom snapping for column/row tiles
                                                if tile_id == 118 or tile_id == 36 then
                                                        wall_x = tile_x * 8 + 7
                                                elseif tile_id == 119 or tile_id == 37 then
                                                        wall_x = tile_x * 8 + 1
                                                elseif tile_id == 120 or tile_id == 121 then
                                                        return
                                                else
                                                        wall_x = tile_x * 8
                                                end
                                                break
                                        end
                                end

                                if found_wall then
                                        p.x = wall_x - p.hb_w - p.hb_x_off
                                end
                        else
                                sfx(-1,1)
                                sfx(2,1)
                                p.ice_slide_speed = 0
                                p.ice_acc_timer = 0
                                --wind cushioning
                                local wind_contribution = calculate_wind_contribution()
                                if wind_contribution > 0 then
                                        p.dx = -1 * (p.dx - wind_contribution) * bounce_factor
                                else
                                        p.dx = -1 * p.dx * bounce_factor
                                end
                                p.dy = p.dy * 0.8
                                p.hit=true
                        end
                end
                stop_running()
        end

        --limit movement per frame to prevent collision skipping
        local collision_safe_limit = 7.5
        if abs(p.dx) > collision_safe_limit then
            p.dx = sgn(p.dx) * collision_safe_limit
        end
        if abs(p.dy) > collision_safe_limit then
            p.dy = sgn(p.dy) * collision_safe_limit
        end

        p.x=p.x+p.dx
        p.y=p.y+p.dy

        if p.dx < -0.1 then
                p.flp = true
        elseif p.dx > 0.1 then
                p.flp = false
        end

        p.was_on_ice = on_ice(p)
        p.was_on_diagonal = slide1 or slide2 or slide3 or slide4

        if p.splat and p.grounded and abs(p.dx) < 0.1 then
                p.splat = false
        end

        if not p.grounded then
                if p.air_moved then
                        p.ice_slide_speed = 0
                end
                p.ice_acc_timer = 0
        end

        if p.grounded then
                p.was_on_diagonal = false
                p.diagonal_started = false
        end

end

function limit_speed(num, maximum)
        return	mid(-maximum, num, maximum)
end

function stop_running()
        if p.grounded and not p.running then
                if on_ice(p) and abs(p.ice_slide_speed) > ice_thresh then
                        p.dx = p.ice_slide_speed
                else
                        p.dx = p.dx * friction
                        local ground_wind_force = calculate_ground_wind_force()
                        p.dx = p.dx + ground_wind_force
                end
        end
end

function handle_speed(slide1, slide2)
        local max_speed = has_wind_this_level and 4.5 or p.max_dx

        if not slide1 and not slide2 then
                if p.running then
                        p.dx=limit_speed(p.dx,p.max_walk_dx)
                else
                        p.dx=limit_speed(p.dx,max_speed)
                end
        else
                p.dx=limit_speed(p.dx,p.max_slide)
        end
end

function calculate_wind_contribution()
        if not has_wind_this_level then
                return 0
        end
        return wind_direction * wind_strength * wind_player_force
end

function calculate_ground_wind_force()
        if not has_wind_this_level or not p.grounded or in_deep_snow(p) then
                return 0
        end

        --check if player blocked by wall
        local blocked_by_wall = false
        if wind_direction < 0 and collide_map(p, "left", 0) then
                blocked_by_wall = true
        elseif wind_direction > 0 and collide_map(p, "right", 0) then
                blocked_by_wall = true
        end

        if blocked_by_wall then
                return 0
        end

        return wind_direction * wind_strength * p.ground_wind_ramp * wind_ground_force
end
