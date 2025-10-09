function p_animate()
	if p.splat and p.grounded then
		p.sp=9
	elseif p.diagonal_sliding or p.wall_hit then
		p.sp=10
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
			p.sp=(p.sp<2 or p.sp>5) and 2 or (p.sp==5 and 2 or p.sp+1)
		end
	else
		p.sp=1
	end
end
