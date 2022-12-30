function p_update()
        p_movement()
        --physics
        p.dy=p.dy+gravity

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

                if not collide_map(p, "slide", 1)
                and not collide_map(p, "slide", 2) then		
                        p.dy=limit_speed(p.dy,p.max_dy)
                else
                        p.dy=limit_speed(p.dy,p.max_slide)
                end

                if collide_map(p,"down",0) then
                        p.y=p.y-(((p.y+p.h+1)%8)-1)
                        if not collide_map(p, "slide", 1)
                        and not collide_map(p, "slide", 2) then
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
                handle_speed()
                
                if collide_map(p,"left",0) then
                        if p.grounded then
                                p.dx=0
                        else
                                sfx(-1,1)
                                sfx(2,1)
                                p.flp=not p.flp
                                p.dx=-1*p.dx
                                p.hit=true
                        end
                end 
                stop_running()           
        elseif p.dx>0 then
                handle_speed()
                
                if collide_map(p,"right",0) then
                        if p.grounded then
                                p.dx=0
                        else
                                sfx(-1,1)
                                sfx(2,1)
                                p.flp=not p.flp
                                p.dx=-1*p.dx
                                p.hit=true
                        end
                end
                stop_running()
        end		
    
        p.x=p.x+p.dx
        p.y=p.y+p.dy
    
end

function limit_speed(num, maximum)
        return	mid(-maximum, num, maximum)
end

function stop_running()
        if p.grounded and not p.running then
                p.dx=0
        end
end

function handle_speed()
        if not collide_map(p, "slide", 1)
        and not collide_map(p, "slide", 2) then
                if  p.running then
                        if (btn(🅾️)) then
                                p.dx=limit_speed(p.dx,p.max_walk_dx/2)
                        else
                                p.dx=limit_speed(p.dx,p.max_walk_dx)
                        end
                else	
                        p.dx=limit_speed(p.dx,p.max_dx)
                end
        else
                p.dx=limit_speed(p.dx,p.max_slide)
        end
end