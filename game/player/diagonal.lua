function handle_diagonal_physics()
	local slide1,slide2,slide3,slide4 = collide_map(p, "slide", 1),collide_map(p, "slide", 2),collide_map(p, "slide", 3),collide_map(p, "slide", 4)
	if slide1 or slide2 then
		local slide_dir = slide1 and -1 or 1
		p.dy = p.dy + gravity * 0.5
		local momentum_penalty = 0
		local abs_dx = abs(p.dx)
		if abs_dx > 0 then
			if sgn(p.dx) != sgn(slide_dir) then
				momentum_penalty = abs_dx * 1.2 + (abs_dx + abs(p.dy)) * 0.4
			else
				momentum_penalty = abs_dx * 0.3 * (1 - min(abs_dx / max(abs(p.dy), 0.1) * 0.3, 0.7))
			end
		end
		p.dx = slide_dir * max(abs(p.dy) - momentum_penalty, 0.2)
		p.dx = mid(-2.5, p.dx, 2.5)
		p.dy = mid(0, p.dy, 2.5)
		p.ice_slide_speed,p.ice_acc_timer = 0,0
		if abs(p.dx) + abs(p.dy) >= 1.8 then
			p.splat,p.slammed = true,true
		else
			p.splat,p.slammed,p.falling = false,false,true
		end
		p.grounded = false
		return true
	elseif slide3 or slide4 then
		local slide_dir = slide3 and -1 or 1
		p.dy = p.dy + gravity
		p.dx = slide_dir * abs(p.dy)
		p.dx = mid(-2.5, p.dx, 2.5)
		p.dy = mid(-2.5, p.dy, 2.5)
		p.ice_slide_speed,p.ice_acc_timer = 0,0
		if p.was_on_diagonal then
			p.splat = false
			p.slammed = false
		else
			if abs(p.dy) >= slam_thresh then
				p.splat = true
				p.slammed = true
			else
				p.splat = false
				p.slammed = false
			end
		end
		if p.dy >= 0 then
			p.grounded = true
			p.falling = false
			p.jumping = false
		else
			p.grounded = false
			p.jumping = true
			p.falling = false
		end
		return true
	end
	return false
end