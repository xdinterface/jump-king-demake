function draw_ending()
    camera(0, 0)
    palt(14, true) palt(0, false)
    cls(0)

    if ending_phase == 1 then

        local fade = phase_progress
        local col = get_fade_color(fade)
        print_centered("he made it to the top!", 55, col)
        print_centered("the prince has ascended!", 65, col)
    end

    if ending_phase == 2 then
        local time_str = format_time_with_ms()


        if phase_progress > 0 then
            local fade = min((phase_progress - 0) * 2, 1)
            print_centered("your run:", 40, get_fade_color(fade))
        end
        if phase_progress > 0.5 then
            local fade = min((phase_progress - 0.5) * 2, 1)
            print_centered(time_str, 50, get_fade_color(fade))
        end
        if phase_progress > 1 then
            local fade = min((phase_progress - 1) * 2, 1)
            print_centered("jumps: " .. jump_counter, 60, get_fade_color(fade))
        end
        if phase_progress > 1.5 then
            local fade = min((phase_progress - 1.5) * 2, 1)
            print_centered("falls: " .. fall_counter, 70, get_fade_color(fade))
        end
    elseif ending_phase == 3 then

        local time_str = format_time_with_ms()
        print_centered("your run:", 40, 7)
        print_centered(time_str, 50, 7)
        print_centered("jumps: " .. jump_counter, 60, 7)
        print_centered("falls: " .. fall_counter, 70, 7)


        if is_new_record then
            print_centered("new record!", 80, 10)
        elseif best_time > 0 then
            print_centered("best: " .. format_frames_to_time(best_time), 80, 6)
        end


        if phase_progress > 0 then
            local fade = min(phase_progress * 2, 1)
            print_centered("press any button to continue", 95, get_fade_color(fade))
        end
    end

    palt()
end

function get_fade_color(fade)

    if fade < 0.2 then
        return 0
    elseif fade < 0.4 then
        return 1
    elseif fade < 0.6 then
        return 5
    elseif fade < 0.8 then
        return 6
    else
        return 7
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
    local h, m, s = flr(total_seconds / 3600), flr((total_seconds % 3600) / 60), total_seconds % 60

    local function pad(x) return x < 10 and "0" .. x or tostr(x) end

    return pad(h) .. ":" .. pad(m) .. ":" .. pad(s) .. "." .. pad(ms)
end