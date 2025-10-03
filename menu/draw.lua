function draw_menu()
	cls()
	
	local menu_items = {
		{text = "웃 start", y = 50},
		{text = "♪ music: " .. (game_music and "on" or "off"), y = 60},
		{text = "⧗ time: " .. (show_time and "on" or "off"), y = 70},
		{text = "level: " .. init_lvl, y = 80, debug_only = true}
	}
	
	for i = 1, max_menu do
		local item = menu_items[i]
		if not item.debug_only or max_menu == 4 then
			print(item.text, 30, item.y, menu_pos == i and blink_c or 7)
		end
	end

end

