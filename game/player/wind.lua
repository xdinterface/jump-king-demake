function calc_wind_contrib()
	if not has_wind_this_level then
		return 0
	end
	return wind_direction * wind_strength * wind_player_force
end

function calc_gwforce()
	if not has_wind_this_level or not p.grounded or in_deep_snow(p) then
		return 0
	end
	local wallblck = false
	if wind_direction < 0 and collide_map(p, "left", 0) then
		wallblck = true
	elseif wind_direction > 0 and collide_map(p, "right", 0) then
		wallblck = true
	end
	if wallblck then
		return 0
	end
	return wind_direction * wind_strength * p.ground_wind_ramp * wind_ground_force
end