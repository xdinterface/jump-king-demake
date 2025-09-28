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
        --physics
        p.dy=p.dy+gravity

        --cache collision results for this frame
        local slide1 = collide_map(p, "slide", 1)
        local slide2 = collide_map(p, "slide", 2)

        --apply horizontal slide acceleration if on diagonal slopes
        --this matches the vertical gravity acceleration to maintain slope angle
        if slide1 then
                --slide left (flag 1: top-right to bottom-left)
                p.dx = p.dx - gravity
                --ensure speeds stay matched for proper diagonal movement
                if abs(p.dx) < abs(p.dy) then
                        p.dx = -abs(p.dy)  --force horizontal to match vertical
                end
                --maintain hard fall state while sliding
                p.lying = true
                p.smash = true
                p.grounded = false  --player is sliding, not grounded
        elseif slide2 then
                --slide right (flag 2: top-left to bottom-right)
                p.dx = p.dx + gravity
                --ensure speeds stay matched for proper diagonal movement
                if abs(p.dx) < abs(p.dy) then
                        p.dx = abs(p.dy)  --force horizontal to match vertical
                end
                --maintain hard fall state while sliding
                p.lying = true
                p.smash = true
                p.grounded = false  --player is sliding, not grounded
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
    
        p.x=p.x+p.dx
        p.y=p.y+p.dy

        --update facing direction based on velocity
        if p.dx < -0.1 then
                p.flp = true  --face left when moving left
        elseif p.dx > 0.1 then
                p.flp = false --face right when moving right
        end
        --keep current facing if velocity is near zero

end

function limit_speed(num, maximum)
        return	mid(-maximum, num, maximum)
end

function stop_running()
        if p.grounded and not p.running then
                --preserve ground wind effect when stopping
                local ground_wind_force = calculate_ground_wind_force()
                p.dx = ground_wind_force
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
