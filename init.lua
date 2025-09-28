
function _init()
    --init state--
    _update=update_title
    _draw=draw_title

    --496,50 start
    debug_mode = true  --master toggle for all debug features
    debug_print = false  --toggle for on-screen debug info (requires debug_mode)
    debug_coords = false
    debug_level = true
    debug_grounded = true
    debug_wind = true
    debug_snow = true
    debug_world = false
    debug_charge = true
    
    --configuration objects--
    physics_config = {
        gravity = 0.24,
        friction = 0.2,
        friction_ice = 0.6,
        charge_rate = 0.06,
        anim_rate = 0.1,
        bounce_factor = 0.7
    }
    
    weather_config = {
        snow = {
            count = 60,
            speed_min = 0.5,
            speed_max = 1.0,
            wind_factor = 4.0
        },
        wind = {
            max_speed = 1.5,
            player_force = 0.08,  --reduced from 0.1 to 0.08
            ground_force = 0.1,
            ground_max_speed = 2.0,
            ramp_time = 0.2,
            blow_time = 5
        },
        clouds = {
            count = 8,        --more clouds
            speed_min = 0.06,
            speed_max = 0.2,
            size_min = 32,
            size_max = 64
        },
        snow_only_levels = {17, 18, 19},
        snow_wind_levels = {20, 21, 22, 23, 24}
    }
    
    game_config = {
        fps = 30,
        world_size = 1024,
        screen_size = 128
    }

    p={
        sp=1,
        x=60,
        y=496,
        w=8,
        h=8,
        --hitbox properties (narrower than sprite)
        hb_x_off=1,  --1 pixel offset from left
        hb_y_off=0,  --no vertical offset
        hb_w=6,      --6 pixels wide (1 pixel less on each side)
        hb_h=8,      --full height
        flp=false,
        dx=0,
        dy=0,
        max_walk_dx=1,
        max_dx=2,
        max_dy=6,
        max_slide=3.5,
        acc=1.4,
        walk_acc=0.4,
        jump_acc=1.9,
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
        hit=false,
        lock_jump=false,
        air_moved=false,
        wind_timer=0,
        wind_ramp=0,
        ground_wind_timer=0,
        ground_wind_ramp=0,
        jump_canceled=false,
        jump_btn_held=false
    }

    clouds = {}
    --cloud grouping layers
    local cloud_layers = {20, 45, 70}  --3 height bands for natural grouping
    for i=0,weather_config.clouds.count do
        local layer = flr(rnd(3)) + 1  --choose random layer (1-3)
        clouds[i]={
            x=rnd(game_config.screen_size),
            y=cloud_layers[layer] + rnd(12) - 6,  --layer position ± 6px variation
            layer=layer,  --remember which layer for wrapping
            spd=weather_config.clouds.speed_min+rnd(weather_config.clouds.speed_max-weather_config.clouds.speed_min),
            w=weather_config.clouds.size_min+rnd(weather_config.clouds.size_max-weather_config.clouds.size_min),
            h_mult=0.7 + rnd(0.8)  --height multiplier: 0.7 to 1.5 (some taller, some shorter)
        }
    end

    menu_pos=1
    blink_c=7
    blink_c1=7
    blink_c2=6
    blink_rate=0
    blink_speed=5
    
    frames=0
    seconds=0
    minutes=0
    
    menu_music=false
    game_music=false
    show_time=true
    max_menu=0
    init_lvl=28
    s=0

    gravity=physics_config.gravity
    friction=physics_config.friction
    friciton_ice=physics_config.friction_ice
    
    air_time=0
    jump_counter=0
    
    --camera
    cam_x=0
    cam_y=0

    map_start=0
    map_end=game_config.world_size
    
    --current level tracking
    current_lvl = 1
    last_lvl = 1  --track previous level to detect level changes
    level_entry_time = 0  --time since entering current level
    
    --weather--
    rain ={}
    
    --snow and wind system--
    snow = {}
    for i=0,weather_config.snow.count do 
        snow[i]={
            x=rnd(game_config.screen_size),
            y=rnd(game_config.screen_size),
            spd=weather_config.snow.speed_min+rnd(weather_config.snow.speed_max-weather_config.snow.speed_min)
        } 
    end
    
    --wind cycle: 1s ramp up, 5s blow, 1s ramp down, repeat other direction
    wind_timer = 0
    wind_phase = 0 -- 0=ramp up left, 1=blow left, 2=ramp down left, 3=ramp up right, 4=blow right, 5=ramp down right
    wind_strength = 0 -- 0 to 1
    wind_direction = -1 -- -1 left, 1 right
    max_wind_speed = weather_config.wind.max_speed
    initial_wind_delay_done = false -- tracks if initial 2s delay for level 20 has been done
    
    --player wind ramp tracking
    player_wind_ramp = 0 -- 0 to 1, builds up over time in air
    player_wind_timer = 0
    
    --levels with snow only
    snow_only_levels = weather_config.snow_only_levels
    --levels with snow/wind effect
    snow_wind_levels = weather_config.snow_wind_levels

    --world height background system
    max_world_height_reached = 128  -- start with enough to show initial forest zone

    --background zones defined by world heights (based on environment transitions)
    world_bg_zones = {
        {world_height_start = 0,    world_height_end = 624,  color = 3},  -- forest (environment 1)
        {world_height_start = 624,  world_height_end = 888,  color = 5},  -- underground (environment 2)
        {world_height_start = 888,  world_height_end = 1320, color = 2},  -- deep underground (environment 3)
        {world_height_start = 1320, world_height_end = 1624, color = 4},  -- pre-peak (environment 4)
        {world_height_start = 1624, world_height_end = 9999, color = 0}   -- sky/peaks (environment 5)
    }
end

function update_ramp(timer, ramp_time)
    --generic ramp function: returns new_timer, ramp_value
    local new_timer = timer + 1/game_config.fps
    local ramp_value = min(1, new_timer / ramp_time)
    return new_timer, ramp_value
end
