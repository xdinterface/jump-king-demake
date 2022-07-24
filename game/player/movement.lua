function p_movement()
    --move left
    if btn(⬅️)
    and p.grounded then
        p.flp=true
        p.dir=true
        if not p.crouching then
                p.dx=p.dx-p.walk_acc
                p.lying=false
                p.running=true
        elseif p.crouching then
            p.running=false
        end
    end

    --move right
    if btn(➡️)
    and p.grounded then
        p.flp=false
        p.dir=true
        if not p.crouching then
                p.dx=p.dx+p.walk_acc
                p.lying=false
                p.running=true
        elseif p.crouching then
                p.running=false
        end
    end

    --stop running
    if not btn(⬅️) and not btn(➡️) and p.grounded then
        p.running = false
    end

    --crouch
    if btn(❎)
    and p.grounded then
        p.crouching=true
        p.lying=false
        charge_jump()
        
        if not btn(⬅️)
        and not btn(➡️) then
                p.dir=false
        end
    end

    --jump
    if not btn(❎)
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

    --move to side in air
    if not p.grounded
    and p.dir
    and not collide_map(p, "slide", 1)
    and not collide_map(p, "slide", 2) then
        if p.hit
        or p.lying then
            if not p.flp then
                p.dx=p.acc
            else
                p.dx=-p.acc
            end
        elseif p.running then
            if not p.flp then
                p.dx=p.walk_acc*2
            else
                p.dx=-p.walk_acc*2
            end
        else
            if not p.flp then
                p.dx=p.dx+p.jump_acc
            else 
                p.dx=p.dx-p.jump_acc
            end
        end
    elseif collide_map(p, "slide", 1) then
        p.flp=true
        p.dx=-p.dy
        p.lying=true
        p.smash=true
        p.landing=false
    elseif collide_map(p, "slide", 2) then
        p.flp=false
        p.dx=p.dy
        p.lying=true
        p.smash=true
        p.landing=false
    end

    function charge_jump()
        if time()-air_time > .06 then
            air_time = time()
            if p.boost < p.boost_max then
                p.boost=p.boost+0.5
            end
        end
    
        if p.boost > p.boost_max then
        p.boost = p.boost_max
        end
    end
end