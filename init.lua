
function _init()
    --init state--
    _update=update_title
    _draw=draw_title

    --496,50 start
    --debug
    debug = true

    --initialize save data
    cartdata("jumpking_demake")
    best_time = dget(0)  --best time in total frames
    run_count = dget(1)  --number of runs started
    is_new_record = false  --flag for new record

    --physics
    gravity = 0.24
    friction = 0.2
    ice_decel = 0.1
    ice_counter = 0.16
    ice_ramp = 0.24
    ice_thresh = 0.08
    charge_rate = 0.07
    anim_rate = 0.1
    bounce_factor = 0.6
    slam_thresh = 5.4

    --wind/weather
    snow_count = 60
    snow_spd_min = 0.5
    snow_spd_max = 1.0
    snow_wind_factor = 4.0
    wind_max = 1.5
    wind_player_force = 0.08
    wind_ground_force = 0.1
    wind_ground_max = 2.0
    wind_ramp_time = 0.2
    wind_blow_time = 5

    --clouds
    cloud_count = 8
    cloud_spd_min = 0.04
    cloud_spd_max = 0.2
    cloud_size_min = 32
    cloud_size_max = 64

    --levels
    snow_only_levels = {17, 18, 19}
    snow_wind_levels = {20, 21, 22, 23, 24}

    --lookup tables for O(1) level checks
    snow_only_lookup = {}
    snow_wind_lookup = {}
    for i=1,#snow_only_levels do snow_only_lookup[snow_only_levels[i]] = true end
    for i=1,#snow_wind_levels do snow_wind_lookup[snow_wind_levels[i]] = true end

    --game
    fps = 30
    world_size = 1024
    screen_size = 128

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
        max_walk_dx=1.4,
        max_dx=2,
        max_dy=6,
        max_slide=3.5,
        acc=1.4,
        move_acc=0.3,
        jump_acc=1.9,
        boost=0,
        boost_max=4.0,
        anim=0,
        grounded=false,
        running=false,
        crouching=false,
        jumping=false,
        falling=false,
        splat=false,
        landing=false,
        slammed=false,
        dir=false,
        hit=false,
        lock_jump=false,
        air_moved=false,
        wind_timer=0,
        wind_ramp=0,
        ground_wind_timer=0,
        ground_wind_ramp=0,
        ice_slide_speed=0,
        ice_acc_timer=0,
        was_on_ice=false,
        ice_sliding=false,
        was_on_diagonal=false,
        diagonal_started=false,
        jump_btn_held=false
    }

    --clouds
    reset_clouds()

    menu_pos=1
    blink_c=7
    blink_c1=7
    blink_c2=6
    blink_rate=0
    blink_speed=5
    
    frames=0
    seconds=0
    minutes=0
    hours=0
    
    menu_music=false
    game_music=false
    show_time=true
    max_menu=0
    init_lvl=7
    s=0

    
    air_time=0
    jump_counter=0
    fall_counter=0

    --camera (will be initialized when game starts)
    current_level_column=0
    cam_x=0
    cam_y=0

    map_start=0
    map_end=world_size
    
    --current level tracking
    current_lvl = 1
    last_lvl = 1  --track previous level to detect level changes
    level_entry_time = 0  --time since entering current level
    
    --weather--
    
    --snow
    snow = {}
    for i=0,snow_count do
        snow[i]={
            x=rnd(screen_size),
            y=rnd(screen_size),
            spd=snow_spd_min+rnd(snow_spd_max-snow_spd_min)
        }
    end

    --wind
    wind_timer = 0
    wind_phase = 0
    wind_strength = 0
    wind_direction = -1
    max_wind_speed = wind_max
    initial_wind_delay_done = false
    player_wind_ramp = 0
    player_wind_timer = 0


    --background progress tracking
    min_tile_y_reached = nil  -- tracks highest point reached (lowest y value)

    --level-based background colors
    level_bg = {}
    for i=1,5 do level_bg[i] = 13 end     --forest
    for i=6,7 do level_bg[i] = 0 end      --sewers
    for i=8,11 do level_bg[i] = 2 end     --mansion
    for i=12,15 do level_bg[i] = 6 end    --town
    for i=16,19 do level_bg[i] = 13 end   --guard posts
    for i=20,24 do level_bg[i] = 1 end    --snow
    for i=25,26 do level_bg[i] = 13 end   --chapel
    for i=27,30 do level_bg[i] = 1 end    --iceland
    for i=31,32 do level_bg[i] = 15 end   --tower

    --level-based cloud colors (nil = no clouds)
    level_clouds = {}
    for i=1,5 do level_clouds[i] = 6 end      --forest: dark gray
    for i=6,7 do level_clouds[i] = nil end    --sewers: no clouds
    for i=8,11 do level_clouds[i] = 6 end     --mansion: dark gray
    for i=12,15 do level_clouds[i] = 7 end    --town: light gray
    for i=16,19 do level_clouds[i] = 13 end   --guard: white
    for i=20,24 do level_clouds[i] = 13 end   --snow: white
    for i=25,26 do level_clouds[i] = nil end  --chapel: no clouds
    for i=27,30 do level_clouds[i] = nil end  --iceland: no clouds
    for i=31,32 do level_clouds[i] = 9 end    --tower: orange

    --custom background rectangles
    custom_bg_rects = {
        --sewers (x016 y050 to x031 y005)
        {x_start = 16, y_start = 50, x_end = 31, y_end = 5, bg_color = 0},
        --mansion overlays (keeping existing ones)
        {x_start = 37, y_start = 62, x_end = 47, y_end = 37, bg_color = 5},
        {x_start = 40, y_start = 36, x_end = 47, y_end = 23, bg_color = 5},
        {x_start = 38, y_start = 37, x_end = 47, y_end = 36, bg_color = 5},
        --chapel (x094 y027 to x107 y028)
        {x_start = 94, y_start = 27, x_end = 107, y_end = 28, bg_color = 13}
    }


    --ending state variables
    ending_timer = 0
    ending_phase = 1
    phase_progress = 0
    timer_stopped = false

    -- Position save/restore variables
    saved_pos_x = nil
    saved_pos_y = nil
    o_button_press_time = 0
    o_button_held = false
    position_saved = false

    --princess variables
    princess_x = 984  --tile x123 * 8
    princess_y = 24   --tile y3 * 8
    princess_sprite = 11
    princess_anim_timer = 0

    --animated sprite timer
    anim_sprite_timer = 0
    anim_sprite_current = 38

    --transition variables
    ending_transition_timer = 0
    map_offset_y = 0
    player_end_x = 54
    player_end_y = 60
    princess_end_x = 74
    princess_end_y = 60
    transition_player_x = 0
    transition_player_y = 0
    transition_princess_x = 0
    transition_princess_y = 0

end

function reset_clouds()
    clouds = {}
    local cloud_layers = {20, 45, 70}
    for i=0,cloud_count do
        local layer = flr(rnd(3)) + 1
        local h = 4 + flr(rnd(3))  --height between 4-6
        local w = cloud_size_min+rnd(cloud_size_max-cloud_size_min)

        clouds[i]={
            x=rnd(screen_size),
            y=cloud_layers[layer] + rnd(12) - 6,
            spd=cloud_spd_min+rnd(cloud_spd_max-cloud_spd_min),
            w=w,
            h=h
        }
    end
end

function in_levels(lvl, list)
    if list == snow_only_levels then return snow_only_lookup[lvl] or false end
    if list == snow_wind_levels then return snow_wind_lookup[lvl] or false end
    for i=1,#list do
        if list[i]==lvl then return true end
    end
    return false
end

function update_ramp(timer, ramp_time)
    local new_timer = timer + 1/fps
    local ramp_value = min(1, new_timer / ramp_time)
    return new_timer, ramp_value
end
