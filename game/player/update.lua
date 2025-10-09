function p_update()
	has_wind_this_level=in_levels(current_lvl,snow_wind_levels)
	p_movement()
	local ceiling=false

	if not handle_diagonal_physics() and not ceiling then
		p.dy=p.dy+gravity
	end

	if collide_map(p,"down",7) then p.dx=p.dx*(1-friction) end

	if p.dy>=slam_thresh then
		p.slammed,p.landing=true,false
	end

	if p.dy>0 then
		p.falling,p.grounded,p.jumping=true,false,false
		if not p.slammed and p.dy>1 then p.landing=true end

		local slide1,slide2=collide_map(p,"slide",1),collide_map(p,"slide",2)
		p.dy=limit_spd(p.dy,(slide1 or slide2) and p.max_slide or p.max_dy)

		if collide_map_diag(p,"down",0) then
			p.y=p.y-(((p.y+p.h+1)%8)-1)
			if not slide1 and not slide2 then
				if p.dy>=slam_thresh then
					sfx(3)
					fall_counter=fall_counter+1
					p.splat=true
				elseif p.dy>1 then
					sfx(1)
				end
				p.slammed,p.landing,p.falling,p.hit,p.air_moved=false,false,false,false,false
				p.grounded=true
				p.dy=0
				if on_ice(p) then
					p.ice_slide_speed=abs(p.dx)>ice_thresh and p.dx or 0
					p.ice_acc_timer=0
				elseif p.was_on_ice then
					p.ice_slide_speed,p.ice_acc_timer=0,0
				end
			end
		end
	elseif p.dy<0 then
		p.jumping=true
		if collide_map(p,"up",0) then
			p.dy=0
			-- Ceiling hit: reduce horizontal momentum but preserve jump timing
			p.dx=p.dx*bounce_factor
			ceiling=true
			sfx(2)
		end
	end

	local slide1,slide2 = collide_map(p, "slide", 1),collide_map(p, "slide", 2)
	if p.dx<0 then
		handle_spd(slide1,slide2)
		if collide_map(p,"left",0) then handle_wall_collision(-1) end
		stop_running()
	elseif p.dx>0 then
		handle_spd(slide1,slide2)
		if collide_map(p,"right",0) then handle_wall_collision(1) end
		stop_running()
	end

	if abs(p.dx)>7.5 then p.dx=sgn(p.dx)*7.5 end
	if abs(p.dy)>7.5 then p.dy=sgn(p.dy)*7.5 end

	p.x=p.x+p.dx*movement_speed
	p.y=p.y+p.dy*movement_speed

	if current_lvl>=30 then
		p.x=max(896,min(1023,p.x))
	end

	p.was_on_ice=on_ice(p)
	local slide1,slide2,slide3,slide4=collide_map(p,"slide",1),collide_map(p,"slide",2),collide_map(p,"slide",3),collide_map(p,"slide",4)
	p.was_on_diagonal=slide1 or slide2 or slide3 or slide4

	if not p.was_on_diagonal then p.diagonal_sliding=false end

	if p.grounded then
		p.wall_hit,p.wall_hit_timer,p.diagonal_sliding=false,0,false
	end

	if not p.grounded then
		if p.air_moved then p.ice_slide_speed=0 end
		p.ice_acc_timer=0
	end

	if p.grounded then
		p.was_on_diagonal,p.diagonal_started=false,false
	end
end