function update_ending_transition()
 ending_transition_timer+=1
 local t=ending_transition_timer/30
 if ending_transition_timer%15==0 then
  princess_sprite=princess_sprite==12 and 13 or 12
 end
 if t>6 then
  _update, _draw = update_ending, draw_ending
 end
end

function draw_ending_transition()
 local t=min(ending_transition_timer/60,1)
 camera(0,0)
 cls(15)

 if t<1 then
  camera(cam_x,cam_y-t*128)
  map(0,0)
  camera(0,0)
 end

 local px, py = p.x+(54-p.x)*t, p.y+(60-p.y)*t
 local prx, pry = princess_x+(74-princess_x)*t, princess_y+(60-princess_y)*t

 palt(14,true) palt(0,false)
 spr(p.sp,px,py,1,1,p.flp)
 spr(15,px,py-1,1,1,p.flp)
 spr(princess_sprite,prx,pry)
 palt()
end
