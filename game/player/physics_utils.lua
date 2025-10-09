function limit_spd(num, maximum)
	return	mid(-maximum, num, maximum)
end

function stop_running()
	if p.grounded and not p.running then
		if on_ice(p) and abs(p.ice_slide_speed) > ice_thresh then
			p.dx = p.ice_slide_speed
		else
			p.dx = p.dx * (1 - friction)
			local gwforce = calc_gwforce()
			p.dx = p.dx + gwforce
		end
	end
end

function handle_spd(slide1, slide2)
	local max_spd = has_wind_this_level and 4.5 or p.max_dx
	if not slide1 and not slide2 then
		if p.running then
			p.dx=limit_spd(p.dx,p.max_walk_dx)
		else
			p.dx=limit_spd(p.dx,max_spd)
		end
	else
		p.dx=limit_spd(p.dx,p.max_slide)
	end
end