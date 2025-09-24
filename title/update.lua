function update_title()
    blink()
    if btnp(⬅️) or btnp(➡️) or btnp(⬆️) or btnp(⬇️) or btnp(🅾️) or btnp(❎) then
            _update=update_menu
            _draw=draw_menu
    end
end
