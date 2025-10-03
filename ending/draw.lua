function draw_ending()
    camera(0, 0)
    palt(14, true)   --make pink transparent
    palt(0, false)  --make black opaque
    cls(0)

    if ending_phase == 1 then
        --both sentences fade in together
        local fade = phase_progress
        local col = get_fade_color(fade)
        print_centered("he made it to the top!", 55, col)
        print_centered("the prince has ascended!", 65, col)
    end

    if ending_phase == 2 then
        local time_str = format_time_with_ms()

        --fade in stats sequentially
        if phase_progress > 0 then
            local fade = min((phase_progress - 0) * 2, 1)  --0-0.5s
            print_centered("your run:", 40, get_fade_color(fade))
        end
        if phase_progress > 0.5 then
            local fade = min((phase_progress - 0.5) * 2, 1)  --0.5-1s
            print_centered(time_str, 50, get_fade_color(fade))
        end
        if phase_progress > 1 then
            local fade = min((phase_progress - 1) * 2, 1)  --1-1.5s
            print_centered("jumps: " .. jump_counter, 60, get_fade_color(fade))
        end
        if phase_progress > 1.5 then
            local fade = min((phase_progress - 1.5) * 2, 1)  --1.5-2s
            print_centered("falls: " .. fall_counter, 70, get_fade_color(fade))
        end
    elseif ending_phase == 3 then
        --show all stats fully visible
        local time_str = format_time_with_ms()
        print_centered("your run:", 40, 7)
        print_centered(time_str, 50, 7)
        print_centered("jumps: " .. jump_counter, 60, 7)
        print_centered("falls: " .. fall_counter, 70, 7)

        --show best time or new record
        if is_new_record then
            print_centered("new record!", 80, 10)
        elseif best_time > 0 then
            print_centered("best: " .. format_frames_to_time(best_time), 80, 6)
        end

        --fade in continue prompt
        if phase_progress > 0 then
            local fade = min(phase_progress * 2, 1)  --fade in over 0.5s
            print_centered("press any button to continue", 95, get_fade_color(fade))
        end
    end

    palt()  --reset palette
end

function get_fade_color(fade)
    --map fade progress (0-1) to color values
    if fade < 0.2 then
        return 0  --black (invisible)
    elseif fade < 0.4 then
        return 1  --dark blue
    elseif fade < 0.6 then
        return 5  --dark gray
    elseif fade < 0.8 then
        return 6  --light gray
    else
        return 7  --white
    end
end

function print_centered(text, y, col)
    local x = 64 - (#text * 2)
    print(text, x, y, col)
end

function format_time_with_ms()
    local total_frames = frames + (seconds * 30) + (minutes * 1800) + (hours * 108000)
    return format_frames_to_time(total_frames)
end

function format_frames_to_time(total_frames)
    local ms = flr((total_frames % 30) * 33.33)
    local total_seconds = flr(total_frames / 30)
    local h = flr(total_seconds / 3600)
    local m = flr((total_seconds % 3600) / 60)
    local s = total_seconds % 60

    local h_str = h < 10 and "0" .. h or tostr(h)
    local m_str = m < 10 and "0" .. m or tostr(m)
    local s_str = s < 10 and "0" .. s or tostr(s)
    local ms_str = ms < 10 and "0" .. ms or tostr(ms)

    return h_str .. ":" .. m_str .. ":" .. s_str .. "." .. ms_str
end