function draw_game()
    cls()
    map(0,0)
    palt(0,false)
    palt(14,true)
    spr(p.sp,p.x,p.y,1,1,p.flp)
    palt()
    
    if show_time then
            draw_time()
    end
    --draw_rain()

    --test--
    --print(tostr(p.dy),p.x,p.y-10,7)
    --print("left:"..(p.hit and 'true' or 'false'),p.x,p.y+10,7)
end

function draw_time()
    local s=seconds
    local m=minutes
    local h=flr(minutes/60)
    
    print((h<10 and "0"..h or h)..":"..(m<10 and "0"..m or m)..":"..(s<10  and "0"..s or s),cam_x+1,cam_y+1,7)
end