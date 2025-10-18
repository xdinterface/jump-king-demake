function handle_diagonal_physics()
	local slide1,slide2,slide3,slide4=collide_map(p,"slide",1),collide_map(p,"slide",2),collide_map(p,"slide",3),collide_map(p,"slide",4)

	if not (slide1 or slide2 or slide3 or slide4) then
		return false
	end

	local flag=slide1 and 1 or (slide2 and 2 or (slide3 and 3 or 4))
	local is_downward_slope=(flag==1 or flag==2)

	local down_dir_x,down_dir_y
	if flag==1 then
		down_dir_x,down_dir_y=-1,1
	elseif flag==2 then
		down_dir_x,down_dir_y=1,1
	elseif flag==3 then
		down_dir_x,down_dir_y=1,-1
	else
		down_dir_x,down_dir_y=-1,-1
	end

	if is_downward_slope then
		p.dy=p.dy+gravity*0.5
	else
		p.dy=p.dy+gravity
	end

	local momentum=p.dx*down_dir_x+p.dy*down_dir_y

	if not p.was_on_diagonal then
		p.dx=p.dx*bounce_factor
		p.dy=p.dy*bounce_factor
		sfx(2)
		p.wall_hit=true
		momentum=p.dx*down_dir_x+p.dy*down_dir_y
	end

	if momentum>=0 then
		p.dx=down_dir_x*abs(p.dy)
	else
		p.dx=-down_dir_x*abs(p.dy)
	end

	p.dx=mid(-2.5,p.dx,2.5)
	p.dy=mid(-2.5,p.dy,2.5)

	p.ice_slide_speed,p.ice_acc_timer=0,0
	p.diagonal_sliding=true

	if is_downward_slope then
		p.splat,p.slammed,p.grounded,p.jumping=false,false,false,false
		p.falling=true
	else
		if p.dy>=0 then
			p.grounded=true
			p.falling=false
			p.jumping=false
		else
			p.grounded=false
			p.jumping=true
			p.falling=false
		end
		p.splat,p.slammed=false,false
	end

	return true
end