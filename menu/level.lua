function set_lvl()
	local effective_lvl = debug and init_lvl or 1
	if effective_lvl == 1 then
		p.x = 60
		p.y = 496
	elseif effective_lvl == 2 then
		p.x = 45
		p.y = 344
	elseif effective_lvl == 3 then
		p.x = 40
		p.y = 232
	elseif effective_lvl == 4 then
		p.x = 17
		p.y = 104
	elseif effective_lvl == 5 then
		p.x = 195
		p.y = 464
	elseif effective_lvl == 6 then
		p.x = 140
		p.y = 368
	elseif effective_lvl == 7 then
		p.x = 164
		p.y = 240
	elseif effective_lvl == 8 then
		p.x = 174
		p.y = 104
	elseif effective_lvl == 9 then
		p.x = 304
		p.y = 488
	elseif effective_lvl == 10 then
		p.x = 360
		p.y = 368
	elseif effective_lvl == 11 then
		p.x = 320
		p.y = 216
	elseif effective_lvl == 12 then
		p.x = 292
		p.y = 104
	elseif effective_lvl == 13 then
		p.x = 486
		p.y = 488
	elseif effective_lvl == 14 then
		p.x = 394
		p.y = 352
	elseif effective_lvl == 15 then
		p.x = 482
		p.y = 200
	elseif effective_lvl == 16 then
		p.x = 441
		p.y = 88
	elseif effective_lvl == 17 then
		p.x = 543
		p.y = 496
	elseif effective_lvl == 18 then
		p.x = 587
		p.y = 352
	elseif effective_lvl == 19 then
		p.x = 548
		p.y = 232
	elseif effective_lvl == 20 then
		p.x = 554
		p.y = 112
	elseif effective_lvl == 21 then
		p.x = 704
		p.y = 496
	elseif effective_lvl == 22 then
		p.x = 704
		p.y = 392
	elseif effective_lvl == 23 then
		p.x = 680
		p.y = 128
	elseif effective_lvl == 24 then
		p.x = 680
		p.y = 128
	elseif effective_lvl == 25 then
		p.x = 848
		p.y = 472
	elseif effective_lvl == 26 then
		p.x = 820
		p.y = 372
	elseif effective_lvl == 27 then
		p.x = 812
		p.y = 244
	elseif effective_lvl == 28 then
		p.x = 880
		p.y = 112
	elseif effective_lvl == 29 then
		p.x = 944  -- 118 * 8
		p.y = 496  -- 62 * 8
	elseif effective_lvl == 30 then
		p.x = 968  -- 121 * 8
		p.y = 344  -- 43 * 8
	elseif effective_lvl == 31 then
		p.x = 944  -- 118 * 8
		p.y = 248  -- 31 * 8
	elseif effective_lvl == 32 then
		p.x = 928  -- 116 * 8
		p.y = 72   -- 9 * 8
	end
end

