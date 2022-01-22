function  update_game_music()
    if game_music then
            music(0,120)
            game_music=false
    --elseif not stop_music then
            --music(-1,300)
    end
end

function update_menu_music()
    if menu_music then
            music(11,120)
            menu_music=false
    end
    if not game_music then
            music(-1,300)
    end
end