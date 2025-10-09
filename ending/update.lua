function update_ending()
    ending_timer = ending_timer + 1
    local phase_time = ending_timer / 60


    if ending_timer == 1 then
        local current_total = frames + (seconds * 60) + (minutes * 3600) + (hours * 216000)
        if best_time == 0 or current_total < best_time then
            is_new_record = true
            best_time = current_total
            dset(0, best_time)
        end
    end

    if phase_time < 4 then
        ending_phase = 1
        phase_progress = min(phase_time, 1)
    elseif phase_time < 8 then
        ending_phase = 2
        phase_progress = phase_time - 4
    else
        ending_phase = 3
        phase_progress = phase_time - 8
        if btnp(⬅️) or btnp(➡️) or btnp(⬆️) or btnp(⬇️) or btnp(🅾️) or btnp(❎) then
            reset_game_state()
            _update60, _draw = update_menu, draw_menu
        end
    end
end

function reset_game_state()
    frames, seconds, minutes, hours, jump_counter, fall_counter = 0, 0, 0, 0, 0, 0
    ending_timer, ending_phase = 0, 1
    timer_stopped = false

    p.x, p.y, p.dx, p.dy, p.boost, p.sp = 60, 496, 0, 0, 0, 1
    p.grounded, p.jumping, p.falling, p.splat, p.landing, p.slammed, p.hit, p.crouching = false, false, false, false, false, false, false, false
    p.ice_slide_speed, p.ice_acc_timer = 0, 0
    p.was_on_ice, p.ice_sliding = false, false

    init_lvl, current_lvl, last_lvl = 1, 1, 1

    camera(0, 0)
end