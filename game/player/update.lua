function p_update()
	has_wind_this_level = in_levels(current_lvl, snow_wind_levels)
	p_movement()
	local ceiling = false

	if not handle_diagonal_physics() then
		if not ceiling then
			p.dy = p.dy + gravity
		end
	end

	if collide_map(p,"down",7) then
		p.dx=p.dx*friction
	end

	if p.dy>=slam_thresh then
		p.splat,p.slammed,p.landing=true,true,false
	end

	if p.dy>0 then
		p.falling,p.grounded,p.jumping=true,false,false
		if not p.slammed and p.dy>1 then
			p.landing=true
		end

		local slide1,slide2 = collide_map(p, "slide", 1),collide_map(p, "slide", 2)
		if not slide1 and not slide2 then
			p.dy=limit_spd(p.dy,p.max_dy)
		else
			p.dy=limit_spd(p.dy,p.max_slide)
		end

		if collide_map_diag(p,"down",0) then
			p.y=p.y-(((p.y+p.h+1)%8)-1)
			if not slide1 and not slide2 then
				if p.slammed then
					sfx(3,1)
					p.slammed=false
					fall_counter=fall_counter+1
				elseif p.landing then
					sfx(1,1)
					p.landing=false
				end
				p.falling=false
				p.grounded=true
				p.hit=false
				p.dy=0
				p.air_moved=false
				if on_ice(p) then
					if abs(p.dx) > ice_thresh then
						p.ice_slide_speed = p.dx
					else
						p.ice_slide_speed = 0
					end
					p.ice_acc_timer = 0
				elseif p.was_on_ice then
					p.ice_slide_speed = 0
					p.ice_acc_timer = 0
				end
			end
		end
	elseif p.dy<0 then
		p.jumping=true
		if collide_map(p,"up",0) then
			p.dy = 0
			p.dx = p.dx * bounce_factor
			ceiling = true
		end
	end

	local slide1,slide2 = collide_map(p, "slide", 1),collide_map(p, "slide", 2)
	if p.dx<0 then
		handle_spd(slide1, slide2)
		if collide_map(p,"left",0) then
			handle_wall_collision(-1)
		end
		stop_running()
	elseif p.dx>0 then
		handle_spd(slide1, slide2)
		if collide_map(p,"right",0) then
			handle_wall_collision(1)
		end
		stop_running()
	end

	if abs(p.dx) > 7.5 then p.dx = sgn(p.dx) * 7.5 end
	if abs(p.dy) > 7.5 then p.dy = sgn(p.dy) * 7.5 end

	p.x=p.x+p.dx
	p.y=p.y+p.dy

	if current_lvl >= 30 then
		p.x = max(896, min(1023, p.x))
	end

	p.was_on_ice = on_ice(p)
	local slide1,slide2,slide3,slide4 = collide_map(p, "slide", 1),collide_map(p, "slide", 2),collide_map(p, "slide", 3),collide_map(p, "slide", 4)
	p.was_on_diagonal = slide1 or slide2 or slide3 or slide4

	if not p.grounded then
		if p.air_moved then
			p.ice_slide_speed = 0
		end
		p.ice_acc_timer = 0
	end

	if p.grounded then
		p.was_on_diagonal = false
		p.diagonal_started = false
	end
end