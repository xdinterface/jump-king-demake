
function _init()
    --init state--
    _update=update_title
    _draw=draw_title

    --496,50 start
    --debug
    debug_mode = true
    debug_print = false
    debug_coords = false
    debug_level = true
    debug_grounded = true
    debug_wind = true
    debug_snow = true
    debug_world = false
    debug_charge = true

    --physics
    gravity = 0.24
    friction = 0.2
    ice_decel = 0.08
    ice_counter = 0.15
    ice_ramp = 0.25
    ice_thresh = 0.08
    charge_rate = 0.07
    anim_rate = 0.1
    bounce_factor = 0.6

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
    cloud_spd_min = 0.06
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
        ice_slide_speed=0,
        ice_acc_timer=0,
        was_on_ice=false,
        ice_sliding=false,
        was_on_diagonal=false,
        diagonal_started=false,
        jump_btn_held=false
    }

    --clouds
    clouds = {}
    local cloud_layers = {20, 45, 70}
    for i=0,cloud_count do
        local layer = flr(rnd(3)) + 1
        local h_mult = 0.7 + rnd(0.8)
        local w = cloud_size_min+rnd(cloud_size_max-cloud_size_min)
        local cloud_h = flr(6 * h_mult)
        local w_adjust = (h_mult > 1.2) and -4 or 0
        local adj_w = w + w_adjust

        clouds[i]={
            x=rnd(screen_size),
            y=cloud_layers[layer] + rnd(12) - 6,
            layer=layer,
            spd=cloud_spd_min+rnd(cloud_spd_max-cloud_spd_min),
            w=w,
            cloud_w=w,
            cloud_h=cloud_h,
            adj_w=adj_w,
            h_mult=h_mult
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
    hours=0
    
    menu_music=false
    game_music=false
    show_time=true
    max_menu=0
    init_lvl=16
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
    rain ={}
    
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

    world_bg_zones = {
        {tile_x = 31, tile_y = 51, bg_color = 13, cloud_color = 6},   -- forest
        {tile_x = 31, tile_y = 3, bg_color = 0, cloud_color = nil},   -- sewers
        {tile_x = 47, tile_y = 18, bg_color = 2, cloud_color = 6},    -- mansions
        {tile_x = 63, tile_y = 17, bg_color = 6, cloud_color = 7},    -- town
        {tile_x = 79, tile_y = 17, bg_color = 13, cloud_color = 13},  -- guard posts
        {tile_x = 95, tile_y = 0, bg_color = 1, cloud_color = 13},    -- snow
        {tile_x = 111, tile_y = 16, bg_color = 13, cloud_color = nil}, -- church
        {tile_x = 127, tile_y = 47, bg_color = 1, cloud_color = nil},  -- iceland
        {tile_x = 127, tile_y = 0, bg_color = 15, cloud_color = 9}     -- tower
    }

    mansion_overlays = {
        {x_start = 37, y_start = 62, x_end = 47, y_end = 37, bg_color = 5},
        {x_start = 40, y_start = 36, x_end = 47, y_end = 23, bg_color = 5},
        {x_start = 38, y_start = 37, x_end = 47, y_end = 36, bg_color = 5}
    }

    custom_bg_rects = {}


    --ending state variables
    ending_timer = 0
    ending_phase = 1
    phase_progress = 0

    --princess variables
    princess_x = 984  --tile x123 * 8
    princess_y = 24   --tile y3 * 8
    princess_sprite = 11
    princess_anim_timer = 0

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

    custom_bg_rects = generate_bg_rectangles()
end


function generate_bg_rectangles()
    local rects = {}
    local col_filled = {}
    for i = 0, 7 do
        col_filled[i] = 64
    end

    for i = 1, #world_bg_zones do
        local zone = world_bg_zones[i]
        local target_x = zone.tile_x
        local target_y = zone.tile_y
        local bg_color = zone.bg_color
        local target_col = flr(target_x / 16)

        for col = 0, target_col do
            local col_start_x = col * 16
            local col_end_x = (col == target_col) and target_x or ((col + 1) * 16 - 1)
            local y_start = (col_filled[col] == 64) and 63 or col_filled[col]
            local y_end = (col == target_col) and target_y or 0

            if y_start >= y_end then
                add(rects, {
                    x_start = col_start_x,
                    y_start = y_start,
                    x_end = col_end_x + 1,
                    y_end = y_end,
                    bg_color = bg_color
                })
                col_filled[col] = y_end
            end
        end
    end

    for i = 1, #mansion_overlays do
        add(rects, mansion_overlays[i])
    end

    return rects
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
