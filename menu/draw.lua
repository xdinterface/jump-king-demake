function draw_menu()
    cls()

    if menu_pos==1 then
            print("웃 start",30,50,blink_c)
    else
            print("웃 start",30,50,7)
    end
    
    if menu_pos==2 then
            print("♪ music: "..(game_music  and  "on"  or "off"),30,60,blink_c)
    else
            print("♪ music: "..(game_music  and  "on"  or "off"),30,60,7)
    end
    
    if menu_pos==3 then
            print("⧗ time: "..(show_time  and  "on"  or "off"),30,70,blink_c)
    else
            print("⧗ time: "..(show_time  and  "on"  or "off"),30,70,7)
    end

    if max_menu==4 then
            if menu_pos==4 then
                    print("level: "..init_lvl,30,80,blink_c)
            else
                    print("level: "..init_lvl,30,80,7)
            end
     end
end