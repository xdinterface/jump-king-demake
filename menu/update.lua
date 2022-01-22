function update_menu()
    update_menu_music()
    blink()
    
    if btnp(⬇️) then
            if menu_pos<3 then
                    menu_pos=menu_pos+1
            end
    end
    
    if btnp(⬆️) then
            if menu_pos>1  then
              menu_pos=menu_pos-1
            end
    end
    
    if menu_pos==1 then
            if btnp(❎) then
                    _update=update_game
                    _draw=draw_game
            end
    elseif menu_pos==2 then
            if btnp(⬅️)
            or btnp(➡️)
            or btnp(❎) then
                    game_music=not game_music
                    if game_music then
                            menu_music=true
                    end
            end
    elseif menu_pos==3 then
            if btnp(⬅️)
            or btnp(➡️)
            or btnp(❎) then
                    show_time=not show_time
            end
    end
end