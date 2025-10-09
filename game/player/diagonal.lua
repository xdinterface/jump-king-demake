function handle_diagonal_physics()
	local slide1,slide2,slide3,slide4=collide_map(p,"slide",1),collide_map(p,"slide",2),collide_map(p,"slide",3),collide_map(p,"slide",4)

	if slide1 or slide2 or slide3 or slide4 then
		local slide_dir=(slide1 or slide3) and -1 or 1
		local is_downward_only=slide1 or slide2

		p.dy=p.dy+gravity*(is_downward_only and 0.5 or 1.0)

		if not p.was_on_diagonal then
			local h_ratio=abs(p.dx)/(abs(p.dx)+abs(p.dy)+0.1)
			local alignment=(slide_dir>0) and h_ratio or (1-h_ratio)

			local retain=0.05+alignment*0.9

			local speed=max(sqrt(p.dx*p.dx+p.dy*p.dy)*retain,0.2)

			if is_downward_only then
				p.dx=slide_dir*speed*0.3
				p.dy=abs(p.dx)
			else
				p.dx=slide_dir*abs(p.dy)*0.6
				p.dy=p.dy*0.6
			end
		else
			if is_downward_only then
				p.dx=slide_dir*abs(p.dy)
			else
				p.dx=slide_dir*abs(p.dy)*0.6
				p.dy=p.dy*0.6
			end
		end

		p.diagonal_sliding,p.wall_hit=true,true

		if is_downward_only then
			p.splat,p.slammed,p.grounded,p.jumping=false,false,false,false
			p.falling=true
		else
			p.splat,p.slammed,p.grounded,p.falling=false,false,false,false
			p.jumping=true
		end

		p.dx=mid(-2.5,p.dx,2.5)
		p.dy=mid(-2.5,p.dy,2.5)

		p.ice_slide_speed,p.ice_acc_timer=0,0

		return true
	end
	return false
end