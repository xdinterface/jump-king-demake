function blink()
    blink_rate=blink_rate+1
    if blink_rate>blink_speed then
        blink_rate=0
        if blink_c==blink_c1 then
                blink_c=blink_c2
        else
                blink_c=blink_c1
        end
    end
end