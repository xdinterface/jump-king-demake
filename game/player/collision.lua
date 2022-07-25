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

    elseif aim=="right" then
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
	x1=x1/8
	x2=x2/8
	y1=y1/8
	y2=y2/8

    if flag == 0 then
        return fget(mget(x1, y1), flag)
        or fget(mget(x1, y2), flag)
        or fget(mget(x2, y1), flag)
        or fget(mget(x2, y2), flag)

    elseif flag == 1 then
        return fget(mget(x1, y1), flag)
        or fget(mget(x1, y2), flag)
        or fget(mget(x2, y1), flag)

    elseif flag == 2 then
        return fget(mget(x1, y1), flag)
        or fget(mget(x2, y1), flag)
        or fget(mget(x2, y2), flag)

    elseif flag == 3 then
        return fget(mget(x1, y1), flag)
        or fget(mget(x1, y2), flag)
        or fget(mget(x2, y2), flag)

    elseif flag == 4 then
        return fget(mget(x1, y2), flag)
        or fget(mget(x2, y1), flag)
        or fget(mget(x2, y2), flag)
    end
end
