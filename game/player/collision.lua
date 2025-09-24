function collide_map(obj, aim, flag)
	local x = obj.x
	local y = obj.y
	local w = obj.w
	local h = obj.h

	local x1 = 0
	local x2 = 0
	local y1 = 0
	local y2 = 0

	if aim == "left" then
		x1 = x - 1
		x2 = x - 1
		y1 = y + 2
		y2 = y + h - 1
	elseif aim == "right" then
		x1 = x + w
		x2 = x + w
		y1 = y + 2
		y2 = y + h - 1
	elseif aim == "up" then
		x1 = x + 1
		x2 = x + w - 2
		if flag == 0 then
			y1 = y - 2
			y2 = y - 2
		elseif flag == 3 or flag == 4 then
			y1 = y + 1
			y2 = y + h
		end
	elseif aim == "down" then
		x1 = x + 1
		x2 = x + w - 2
		y1 = y + h + 1
		y2 = y + h + 1
	elseif aim == "slide" then
		x1 = x + 1
		x2 = x + w - 2
		y1 = y + 1
		y2 = y + h - 1
	end

	-- pixels to tiles
	x1 = x1 / 8
	x2 = x2 / 8
	y1 = y1 / 8
	y2 = y2 / 8

	if flag == 0 then
		return fget(mget(x1, y1), flag)
			or fget(mget(x1, y2), flag)
			or fget(mget(x2, y1), flag)
			or fget(mget(x2, y2), flag)
	elseif flag == 1 then
		return fget(mget(x1, y1), flag) or fget(mget(x1, y2), flag) or fget(mget(x2, y1), flag)
	elseif flag == 2 then
		return fget(mget(x1, y1), flag) or fget(mget(x2, y1), flag) or fget(mget(x2, y2), flag)
	elseif flag == 3 then
		return fget(mget(x1, y1), flag) or fget(mget(x1, y2), flag) or fget(mget(x2, y2), flag)
	elseif flag == 4 then
		return fget(mget(x1, y2), flag) or fget(mget(x2, y1), flag) or fget(mget(x2, y2), flag)
	end
end

function in_deep_snow(obj)
	--check if player's feet (bottom edge) are touching flag 5 (snow pile)
	local x = obj.x
	local y = obj.y + obj.h  --bottom edge of player
	local w = obj.w

	--convert to tile coordinates
	local x1 = (x + 1) / 8
	local x2 = (x + w - 2) / 8
	local y_check = y / 8

	--check if bottom edge is touching flag 5 tiles
	return fget(mget(x1, y_check), 5) or fget(mget(x2, y_check), 5)
end

function collide_diagonal_wall(obj, aim)
	--check if diagonal tiles should act as solid walls from this direction
	local x = obj.x
	local y = obj.y
	local w = obj.w
	local h = obj.h

	local x1, x2, y1, y2 = 0, 0, 0, 0

	if aim == "left" then
		x1 = x - 1
		x2 = x - 1
		y1 = y + 2
		y2 = y + h - 1
	elseif aim == "right" then
		x1 = x + w
		x2 = x + w
		y1 = y + 2
		y2 = y + h - 1
	elseif aim == "up" then
		x1 = x + 1
		x2 = x + w - 2
		y1 = y - 2
		y2 = y - 2
	elseif aim == "down" then
		x1 = x + 1
		x2 = x + w - 2
		y1 = y + h + 1
		y2 = y + h + 1
	end

	-- pixels to tiles
	x1 = x1 / 8
	x2 = x2 / 8
	y1 = y1 / 8
	y2 = y2 / 8

	--check if hitting diagonal tiles from solid side
	for tx = flr(min(x1, x2)), flr(max(x1, x2)) do
		for ty = flr(min(y1, y2)), flr(max(y1, y2)) do
			if fget(mget(tx, ty), 1) then
				--flag 1: solid from top-left and bottom-right
				if (aim == "right" and obj.x % 8 < 4) or (aim == "left" and obj.x % 8 > 4) or
				   (aim == "down" and obj.y % 8 < 4) or (aim == "up" and obj.y % 8 > 4) then
					return true
				end
			elseif fget(mget(tx, ty), 2) then
				--flag 2: solid from top-right and bottom-left
				if (aim == "left" and obj.x % 8 < 4) or (aim == "right" and obj.x % 8 > 4) or
				   (aim == "down" and obj.y % 8 > 4) or (aim == "up" and obj.y % 8 < 4) then
					return true
				end
			end
		end
	end

	return false
end

