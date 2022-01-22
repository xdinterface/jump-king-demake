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
        y1 = y - 2
        y2 = y - 2

    elseif aim == "down" then
        x1 = x + 1
        x2 = x + w - 2
        y1 = y + h
        y2 = y + h

    elseif aim == "slide" then
        if flag == 1 then
            x1 = x + 1
            x2 = x + w
            y1 = y + 1
            y2 = y + h

        elseif flag == 2 then
            x1 = x
            x2 = x + w - 1
            y1 = y - 1
            y2 = y + h

        elseif flag == 3 then
            x1 = x + 1
            x2 = x + w
            y1 = y
            y2 = y + h - 1

        elseif flag == 4 then
            x1 = x
            x2 = x + w - 1
            y1 = y
            y2 = y + h - 1
        end
    end

    -- pixels to tiles
	x1=x1/8
	x2=x2/8
	y1=y1/8
	y2=y2/8

    if flag == 0 then
        if fget(mget(x1, y1), flag)
        or fget(mget(x1, y2), flag)
        or fget(mget(x2, y1), flag)
        or fget(mget(x2, y2), flag)
        then
            return true
        else
            return false
        end
    elseif flag == 1 then
        if fget(mget(x1, y1), flag)
        or fget(mget(x1, y2), flag)
        or fget(mget(x2, y1), flag) then
            return true
        else
            return false
        end
    elseif flag == 2 then
        if fget(mget(x1, y1), flag)
        or fget(mget(x1, y2), flag)
        or fget(mget(x2, y2), flag)
        then
            return true
        else
            return false
        end
    elseif flag == 3 then
        if fget(mget(x1, y1), flag) or fget(mget(x2, y1), flag) or fget(mget(x2, y2), flag) then
            return true
        else
            return false
        end
    elseif flag == 4 then
        if fget(mget(x2, y1), flag) or fget(mget(x1, y2), flag) or fget(mget(x2, y2), flag) then
            return true
        else
            return false
        end
    end
end

function slide_left(p)
    if collide_map(p, "slide", 1) then
        return true
    else
        return false
    end
end

function slide_right(p)
    if collide_map(p, "slide", 2) then
        return true
    else
        return false
    end
end
