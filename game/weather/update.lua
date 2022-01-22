function update_rain()
    for i=0,30 do
        add(rain,{
            x=rnd(128),
            y=rnd(514),
            spd=10+rnd(4),
            w=0.1
            })
    end
end