function update_game()
    frames=((frames+1)%30)
    if frames==0 then
      seconds=((seconds+1)%60)
        if seconds==0 then
            minutes=minutes+1
        end
    end

    
    p_update()
    p_animate()
    update_game_music()
    camera_update()
    
    --update_rain()
end