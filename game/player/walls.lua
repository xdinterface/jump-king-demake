local right_walls = {[118]=true,[36]=true,[48]=true}
local left_walls = {[119]=true,[37]=true,[49]=true}

function wall_hit_sfx()
	sfx(2)
end

function handle_wall_collision(dir)
	if p.grounded then
		p.dx,p.ice_slide_speed,p.ice_acc_timer=0,0,0
		local edge=dir<0 and p.x+p.hb_x_off or p.x+p.hb_x_off+p.hb_w
		local found_wall,wall_x=false,0
		for check_offset=0,4 do
			local check_x=edge+dir*check_offset
			local check_y=p.y+p.hb_y_off+(p.hb_h or p.h)/2
			local tile_x,tile_y=flr(check_x/8),flr(check_y/8)
			local tile_id=mget(tile_x,tile_y)
			if fget(tile_id,0) or is_custom_tile(tile_id) then
				found_wall=true
				if tile_id==120 or tile_id==121 then return end
				if dir<0 then
					wall_x=left_walls[tile_id] and tile_x*8+2 or (right_walls[tile_id] and tile_x*8+6 or (tile_x+1)*8)
					p.x=wall_x-p.hb_x_off
				else
					wall_x=right_walls[tile_id] and tile_x*8+7 or (left_walls[tile_id] and tile_x*8+1 or tile_x*8)
					p.x=wall_x-p.hb_w-p.hb_x_off
				end
				break
			end
		end
	else
		wall_hit_sfx()
		p.ice_slide_speed,p.ice_acc_timer=0,0
		p.wall_hit=true
		local wind_contrib=calc_wind_contrib()
		-- Wall bounce: reverse horizontal with bounce_factor, preserve vertical
		p.dx=((dir<0 and wind_contrib<0) or (dir>0 and wind_contrib>0)) and -(p.dx-wind_contrib)*bounce_factor or -p.dx*bounce_factor
		p.hit=true
	end
end