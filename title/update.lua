function update_title()
    blink()
    if btnp(⬅️) or btnp(➡️) or btnp(⬆️) or btnp(⬇️) or btnp(🅾️) or btnp(❎) then
            _update, _draw = update_menu, draw_menu
    end
end
