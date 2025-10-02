function update_menu()
    update_menu_music()
    blink()
    
    max_menu = debug_mode and 4 or 3

    if btnp(⬇️) and menu_pos < max_menu then menu_pos = menu_pos + 1 end
    if btnp(⬆️) and menu_pos > 1 then menu_pos = menu_pos - 1 end
    
    local menu_actions = {
        function()
            if btnp(🅾️) then
                set_lvl()
                frames = 0
                seconds = 0
                minutes = 0
                hours = 0
                jump_counter = 0
                fall_counter = 0
                current_level_column = flr(p.x / 128)
                cam_x = current_level_column * 128
                cam_y = flr(p.y / 128) * 128
                camera(cam_x, cam_y)
                _update, _draw = update_game, draw_game
            end
        end,
        function() 
            if btnp(⬅️) or btnp(➡️) or btnp(🅾️) then
                game_music = not game_music
                if game_music then menu_music = true end
            end
        end,
        function() if btnp(⬅️) or btnp(➡️) or btnp(🅾️) then show_time = not show_time end end,
        function()
            if not debug_mode then return end
            if btnp(➡️) or btnp(🅾️) then
                init_lvl = init_lvl < 32 and init_lvl + 1 or 1
                set_lvl()
            elseif btnp(⬅️) or btnp(❎) then
                init_lvl = init_lvl > 1 and init_lvl - 1 or 32
                set_lvl()
            end
        end
    }
    
    menu_actions[menu_pos]()
end
