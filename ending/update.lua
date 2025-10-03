function update_ending()
    ending_timer = ending_timer + 1
    local phase_time = ending_timer / 30

    --check for new record on first frame
    if ending_timer == 1 then
        local current_total = frames + (seconds * 30) + (minutes * 1800) + (hours * 108000)
        if best_time == 0 or current_total < best_time then
            is_new_record = true
            best_time = current_total
            dset(0, best_time)
        end
    end

    if phase_time < 4 then
        ending_phase = 1
        phase_progress = min(phase_time, 1)  --fade in during first second
    elseif phase_time < 8 then
        ending_phase = 2
        phase_progress = phase_time - 4  --0 to 4 within phase
    else
        ending_phase = 3
        phase_progress = phase_time - 8  --0+ within phase
        if btnp(⬅️) or btnp(➡️) or btnp(⬆️) or btnp(⬇️) or btnp(🅾️) or btnp(❎) then
            reset_game_state()
            _update = update_menu
            _draw = draw_menu
        end
    end
end

function reset_game_state()
    frames = 0
    seconds = 0
    minutes = 0
    hours = 0
    jump_counter = 0
    fall_counter = 0
    ending_timer = 0
    ending_phase = 1
    timer_stopped = false

    p.x = 60
    p.y = 496
    p.dx = 0
    p.dy = 0
    p.boost = 0
    p.grounded = false
    p.jumping = false
    p.falling = false
    p.splat = false
    p.landing = false
    p.slammed = false
    p.hit = false
    p.crouching = false
    p.ice_slide_speed = 0
    p.ice_acc_timer = 0
    p.was_on_ice = false
    p.ice_sliding = false

    init_lvl = 1
    current_lvl = 1
    last_lvl = 1

    camera(0, 0)
end