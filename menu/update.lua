function update_menu()
    update_menu_music()
    blink()

    max_menu = debug and 3 or 2

    local up, down, left, right, x_btn, o_btn = btnp(⬆️), btnp(⬇️), btnp(⬅️), btnp(➡️), btnp(❎), btnp(🅾️)

    if down and menu_pos < max_menu then menu_pos += 1
    elseif up and menu_pos > 1 then menu_pos -= 1 end

    local menu_actions = {
        function()
            if x_btn then
                set_lvl()
                frames, seconds, minutes, hours, jump_counter, fall_counter = 0, 0, 0, 0, 0, 0
                timer_stopped, is_new_record = false, false
                run_count += 1
                dset(1, run_count)
                current_level_column = flr(p.x / 128)
                cam_x, cam_y = current_level_column * 128, flr(p.y / 128) * 128
                camera(cam_x, cam_y)
                _update, _draw = update_game, draw_game
            end
        end,
        function()
            if left or right or x_btn then
                game_music = not game_music
                if game_music then menu_music = true end
            end
        end,
        function()
            if not debug then return end
            if right or x_btn then
                init_lvl = init_lvl < 32 and init_lvl + 1 or 1
                set_lvl()
            elseif left or o_btn then
                init_lvl = init_lvl > 1 and init_lvl - 1 or 32
                set_lvl()
            end
        end
    }
    
    menu_actions[menu_pos]()
end
