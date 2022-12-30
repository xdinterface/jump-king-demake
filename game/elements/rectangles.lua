rects={
{x1=0,y1=0,x2=7,y2=512}, -- borders
{x1=120,y1=0,x2=128,y2=512},
{x1=129,y1=0,x2=135,y2=512},
{x1=248,y1=0,x2=256,y2=512},
{x1=0,y1=472,x2=39,y2=512}, -- bottom level 1
{x1=88,y1=472,x2=128,y2=512},
{x1=0,y1=504,x2=128,y2=512},
{x1=129,y1=24,x2=256,y2=407}} -- sewers

function draw_rectangles()
    foreach(rects, function(r)
        rectfill(
        r.x1,r.y1,r.x2,r.y2,r.c~=nil and r.c or 0)
    end)
end