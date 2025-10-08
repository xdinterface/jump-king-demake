function blink()
	blink_rate = blink_rate + 1
	if blink_rate > blink_speed then
		blink_rate = 0
		blink_c = blink_c == blink_c1 and blink_c2 or blink_c1
	end
end

