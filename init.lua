
function _init()
    --init state--
    _update=update_title
    _draw=draw_title

    --496,50 start

    p={
        sp=1,
        x=50+164,
        y=496-400,
        w=8,
        h=8,
        flp=false,
        dx=0,
        dy=0,
        max_walk_dx=1,
        max_dx=2,
        max_dy=6,
        max_slide=4,
        acc=1.4,
        jump_acc=2,
        boost=0,
        boost_max=4.8,
        anim=0,
        grounded=false,
        running=false,
        crouching=false,
        jumping=false,
        falling=false,
        lying=false,
        landing=false,
        smash=false,
        dir=false,
        hit=false
    }
    
    menu_pos=1
    blink_c=7
    blink_c1=7
    blink_c2=6
    blink_rate=0
    blink_speed=5
    
    frames=0
    seconds=0
    minutes=0
    
    menu_music=true
    game_music=true
    show_time=true

    gravity=0.24
    friction=0.2
    friciton_ice=0.6
    
    air_time=0
    jump_counter=0
    
    --camera
    cam_x=0
    cam_y=0

    map_start=0
    map_end=1024
    
    --weather--
    rain ={}
end