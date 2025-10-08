function p_animate()
        if p.splat then
                p.sp=9
        elseif p.jumping then
                p.sp=7
        elseif p.falling then
                p.sp=8
        elseif p.crouching then
                p.sp=6
        elseif (btn(⬅️) or btn(➡️)) and p.grounded and not p.crouching then
                local t = time()
                if t-p.anim>anim_rate then
                        p.anim=t
                        if p.sp < 2 or p.sp > 5 then p.sp = 2 end
                        p.sp=p.sp==5 and 2 or p.sp+1
                end
        else
                p.sp=1
        end
end
