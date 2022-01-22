function draw_rain()
    foreach(rain, function(c)
        c.y =c.y+ c.spd
        rectfill(
        c.x,c.y,
        c.x+c.w,
        c.y+4+(1-c.w/64)*12,1)
        if c.y > cam_y+128 then
            c.y = cam_y-128   
            c.x = rnd(128)   
        end
    end)
end