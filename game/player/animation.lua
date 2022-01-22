function p_animate()
        if p.lying then
                p.sp=9
        elseif p.jumping then
                p.sp=7
        elseif p.falling then
                p.sp=8
        elseif p.crouching then
                p.sp=6
        elseif (btn(⬅️)
        or btn(➡️))
        and p.grounded
        and not p.crouching then
                if time()-p.anim>.1 then
                        p.anim=time()
                        p.sp=p.sp+1
                        if p.sp>5 then
                                p.sp=2
                        end
                end
        else
                p.sp=1
        end
end