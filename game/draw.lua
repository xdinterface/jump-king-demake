function draw_game()
    cls()
    draw_clouds()
    palt(0,false)
    draw_rectangles()
    palt()
    map(0,0)
    palt(14,true)
    palt(0,false)
    spr(p.sp,p.x,p.y,1,1,p.flp)
    
    palt()
    
    if show_time then
            draw_time()
    end
    --draw_rain()
    
    --test--
    if (debug==true) then
        print('x: '..tostr(p.x),cam_x,cam_y+8,7)
        print('y: '..tostr(p.y),cam_x,cam_y+14,7)
    --print("left:"..(p.hit and 'true' or 'false'),p.x,p.y+10,7)
    end
end

function draw_time()
    local s=seconds
    local m=minutes
    local h=flr(minutes/60)
    
    print((h<10 and "0"..h or h)..":"..(m<10 and "0"..m or m)..":"..(s<10  and "0"..s or s),cam_x+1,cam_y+1,7)
end