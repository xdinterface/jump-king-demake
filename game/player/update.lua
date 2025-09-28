function p_update()
        --cache wind level check for this frame (used across multiple functions)
        has_wind_this_level = false
        for i=1,#snow_wind_levels do
                if snow_wind_levels[i] == current_lvl then
                        has_wind_this_level = true
                        break
                end
        end

        p_movement()

        --cache collision results for this frame (consistent state)
        local slide1 = collide_map(p, "slide", 1)
        local slide2 = collide_map(p, "slide", 2)

        --handle diagonal collision and physics
        if slide1 or slide2 then
                local slide_dir = slide1 and -1 or 1

                --check if this is initial contact with diagonal
                if not p.was_on_diagonal then
                        --first contact: handle opposite direction movement
                        if p.dx != 0 and sgn(p.dx) != sgn(slide_dir) then
                                --moving opposite to slide direction: reset momentum
                                reset_all_momentum()
                        end
                end

                --apply gravity to both axes for synchronized 45-degree slide
                if slide1 then
                        --slide left (flag 1: top-right to bottom-left)
                        p.dx = p.dx - gravity
                else
                        --slide right (flag 2: top-left to bottom-right)
                        p.dx = p.dx + gravity
                end
                p.dy = p.dy + gravity  --match vertical to horizontal movement

                --limit diagonal slide speed to prevent skipping collision
                p.dx = mid(-2.5, p.dx, 2.5)
                p.dy = mid(0, p.dy, 2.5)

                --reset ice sliding state when on diagonal
                p.ice_slide_speed = 0
                p.ice_acc_timer = 0
                --maintain hard fall state while sliding
                p.lying = true
                p.smash = true
                p.grounded = false  --player is sliding, not grounded
        else
                --not on diagonal: normal gravity only to dy
                p.dy = p.dy + gravity
        end

        if collide_map(p,"down",7) then
                p.dx=p.dx*friciton
        end

        --hard fall
        if p.dy>=p.max_dy then
                p.lying=true
                p.smash=true
                p.landing=false
        end
    
        --check collision up/down
        if p.dy>0 then
                p.falling=true
                p.grounded=false
                p.jumping=false
                if not p.smash and p.dy>1 then
                        p.landing=true
                end

                if not slide1 and not slide2 then
                        p.dy=limit_speed(p.dy,p.max_dy)
                else
                        p.dy=limit_speed(p.dy,p.max_slide)
                end

                if collide_map(p,"down",0) then
                        --standard snapping for all tiles
                        p.y=p.y-(((p.y+p.h+1)%8)-1)

                        if not slide1 and not slide2 then
                                if p.smash then
                                        sfx(-1,1)
                                        sfx(3,1)
                                        p.smash=false
                                elseif p.landing then
                                        sfx(-1,1)
                                        sfx(1,1)
                                        p.landing=false
                                end
                                p.falling=false
                                p.grounded=true
                                p.hit=false
                                p.dy=0
                                p.air_moved=false  --reset air movement flag on landing

                                --preserve momentum when landing on ice (only if significant movement)
                                if on_ice(p) then
                                        if abs(p.dx) > physics_config.ice_slide_threshold then
                                                p.ice_slide_speed = p.dx
                                        else
                                                p.ice_slide_speed = 0
                                        end
                                        --reset acceleration timer for fresh start
                                        p.ice_acc_timer = 0
                                elseif p.was_on_ice then
                                        --transitioning from ice to normal ground
                                        p.ice_slide_speed = 0
                                        p.ice_acc_timer = 0
                                end
                        end
                end
        elseif p.dy<0 then
                p.jumping=true
                if collide_map(p,"up",0)
                or collide_map(p,"up",3)
                or collide_map(p,"up",4) then
                        p.dy=0
                end		
        end

--check collision left/right
        if p.dx<0 then
                handle_speed(slide1, slide2)

                if collide_map(p,"left",0) then
                        if p.grounded then
                                p.dx=0
                                --reset ice sliding state when hitting wall
                                p.ice_slide_speed = 0
                                p.ice_acc_timer = 0
                                --check if we're colliding with a custom hitbox tile
                                local check_x = p.x + p.hb_x_off - 1
                                local check_y = p.y + p.hb_y_off + (p.hb_h or p.h)/2
                                local tile_x = flr(check_x / 8)
                                local tile_y = flr(check_y / 8)
                                local tile_id = mget(tile_x, tile_y)

                                --custom snapping for different tile types
                                if tile_id == 119 or tile_id == 37 then
                                        --left column tile: snap to right edge of the column (x=1)
                                        p.x = tile_x * 8 + 1 - p.hb_x_off
                                elseif tile_id == 118 or tile_id == 36 then
                                        --right column tile: snap to left edge of the column (x=7)
                                        p.x = tile_x * 8 + 7 - p.hb_x_off
                                elseif tile_id == 120 or tile_id == 121 then
                                        --top row tiles: no horizontal snapping needed
                                        --just stop movement
                                else
                                        --standard tiles: normal snapping
                                        tile_x = flr((p.x + p.hb_x_off - 1) / 8) + 1
                                        p.x = tile_x * 8 - p.hb_x_off
                                end
                        else
                                sfx(-1,1)
                                sfx(2,1)
                                --reset ice sliding state when bouncing off wall
                                p.ice_slide_speed = 0
                                p.ice_acc_timer = 0
                                --calculate wind contribution for cushioning
                                local wind_contribution = calculate_wind_contribution()
                                --cushion bounce if wind is pushing into wall
                                if wind_contribution < 0 then --wind blowing left, same as movement
                                        p.dx = -1 * (p.dx - wind_contribution) * physics_config.bounce_factor
                                else
                                        p.dx = -1 * p.dx * physics_config.bounce_factor
                                end
                                p.hit=true
                        end
                end
                stop_running()
        elseif p.dx>0 then
                handle_speed(slide1, slide2)

                if collide_map(p,"right",0) then
                        if p.grounded then
                                p.dx=0
                                --reset ice sliding state when hitting wall
                                p.ice_slide_speed = 0
                                p.ice_acc_timer = 0
                                --check if we're colliding with a custom hitbox tile
                                local check_x = p.x + p.hb_x_off + p.hb_w
                                local check_y = p.y + p.hb_y_off + (p.hb_h or p.h)/2
                                local tile_x = flr(check_x / 8)
                                local tile_y = flr(check_y / 8)
                                local tile_id = mget(tile_x, tile_y)

                                --custom snapping for different tile types
                                if tile_id == 118 or tile_id == 36 then
                                        --right column tile: snap to left edge of the column (x=7)
                                        p.x = tile_x * 8 + 7 - p.hb_w - p.hb_x_off
                                elseif tile_id == 119 or tile_id == 37 then
                                        --left column tile: shouldn't happen when moving right, but handle it
                                        p.x = tile_x * 8 + 1 - p.hb_w - p.hb_x_off
                                elseif tile_id == 120 or tile_id == 121 then
                                        --top row tiles: no horizontal snapping needed
                                        --just stop movement
                                else
                                        --standard tiles: normal snapping
                                        tile_x = flr((p.x + p.hb_x_off + p.hb_w) / 8)
                                        p.x = tile_x * 8 - p.hb_w - p.hb_x_off
                                end
                        else
                                sfx(-1,1)
                                sfx(2,1)
                                --reset ice sliding state when bouncing off wall
                                p.ice_slide_speed = 0
                                p.ice_acc_timer = 0
                                --calculate wind contribution for cushioning
                                local wind_contribution = calculate_wind_contribution()
                                --cushion bounce if wind is pushing into wall
                                if wind_contribution > 0 then --wind blowing right, same as movement
                                        p.dx = -1 * (p.dx - wind_contribution) * physics_config.bounce_factor
                                else
                                        p.dx = -1 * p.dx * physics_config.bounce_factor
                                end
                                p.hit=true
                        end
                end
                stop_running()
        end

        --limit movement per frame to prevent collision skipping
        local max_frame_movement = 4  --pixels per frame
        p.dx = mid(-max_frame_movement, p.dx, max_frame_movement)
        p.dy = mid(-max_frame_movement, p.dy, max_frame_movement)

        p.x=p.x+p.dx
        p.y=p.y+p.dy

        --update facing direction based on velocity
        if p.dx < -0.1 then
                p.flp = true  --face left when moving left
        elseif p.dx > 0.1 then
                p.flp = false --face right when moving right
        end
        --keep current facing if velocity is near zero

        --track ice state for next frame
        p.was_on_ice = on_ice(p)

        --track diagonal state for next frame
        p.was_on_diagonal = slide1 or slide2

        --clear lying state when stopped after diagonal slide
        if p.lying and p.grounded and abs(p.dx) < 0.1 then
                p.lying = false
        end

        --reset ice state when leaving ground (but preserve for jump calculation)
        if not p.grounded then
                --only reset if we've already used the ice speed for jumping
                if p.air_moved then
                        p.ice_slide_speed = 0
                end
                p.ice_acc_timer = 0
        end

        --reset diagonal state when grounded (not sliding)
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
                --on ice, preserve sliding momentum
                if on_ice(p) and abs(p.ice_slide_speed) > physics_config.ice_slide_threshold then
                        p.dx = p.ice_slide_speed
                else
                        --preserve ground wind effect when stopping
                        local ground_wind_force = calculate_ground_wind_force()
                        p.dx = ground_wind_force
                end
        end
end

function handle_speed(slide1, slide2)
        --use cached wind level check
        local max_speed = has_wind_this_level and 4.5 or p.max_dx --allow higher speed in wind levels

        if not slide1 and not slide2 then
                if  p.running then
                        if (btn(❎)) then
                                p.dx=limit_speed(p.dx,p.max_walk_dx/2)
                        else
                                p.dx=limit_speed(p.dx,p.max_walk_dx)
                        end
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
        return wind_direction * wind_strength * weather_config.wind.player_force
end

function calculate_ground_wind_force()
        if not has_wind_this_level or not p.grounded or in_deep_snow(p) then
                return 0
        end

        --check if player is against a wall in the direction of wind
        local blocked_by_wall = false
        if wind_direction < 0 and collide_map(p, "left", 0) then
                blocked_by_wall = true  --wind blowing left but wall on left
        elseif wind_direction > 0 and collide_map(p, "right", 0) then
                blocked_by_wall = true  --wind blowing right but wall on right
        end

        if blocked_by_wall then
                return 0
        end

        return wind_direction * wind_strength * p.ground_wind_ramp * weather_config.wind.ground_force
end
