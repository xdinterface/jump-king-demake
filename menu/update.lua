function update_menu()
    update_menu_music()
    blink()
    
    max_menu = debug and 4 or 3

    if btnp(⬇️) and menu_pos < max_menu then menu_pos = menu_pos + 1 end
    if btnp(⬆️) and menu_pos > 1 then menu_pos = menu_pos - 1 end
    
    local menu_actions = {
        function() if btnp(🅾️) then set_lvl(); _update, _draw = update_game, draw_game end end,
        function() 
            if btnp(⬅️) or btnp(➡️) or btnp(🅾️) then
                game_music = not game_music
                if game_music then menu_music = true end
            end
        end,
        function() if btnp(⬅️) or btnp(➡️) or btnp(🅾️) then show_time = not show_time end end,
        function()
            if not debug then return end
            if btnp(➡️) or btnp(🅾️) then
                init_lvl = init_lvl < 28 and init_lvl + 1 or 1
                set_lvl()
            elseif btnp(⬅️) or btnp(❎) then
                init_lvl = init_lvl > 1 and init_lvl - 1 or 28
                set_lvl()
            end
        end
    }
    
    menu_actions[menu_pos]()
end
