function camera_update()
	camera(cam_x,cam_y)
	if 0<p.x and p.x<128 then
			if 384<p.y and p.y<512 then
					lvl(1)
			elseif 256<p.y and p.y<384 then
					lvl(2)
			elseif 128<p.y and p.y<256 then
					lvl(3)
			elseif -1<p.y and p.y<128 then
					lvl(4)
			elseif p.y< -1 then
					p_lvl_up()
			end
	elseif 128<p.x and p.x<256 then
			if 512<p.y then
					p_lvl_down()
			elseif 384<p.y and p.y<512 then
					lvl(5)
			elseif 256<p.y and p.y<384 then
					lvl(6)
			elseif 128<p.y and p.y<256 then
					lvl(7)
			elseif -1<p.y and p.y<128 then
					lvl(8)
			elseif p.y<0 then
					p_lvl_up()
			end
	elseif 256<p.x and p.x<384 then
			if 512<p.y then
					p_lvl_down()
			elseif 384<p.y and p.y<512 then
					lvl(9)
			elseif 256<p.y and p.y<384 then
					lvl(10)
			elseif 128<p.y and p.y<256 then
					lvl(11)
			elseif -1<p.y and p.y<128 then
					lvl(12)
			elseif p.y< -1 then
					p_lvl_up()
			end
	elseif 384<p.x and p.x<512 then
			if 512<p.y then
					p_lvl_down()
			elseif 384<p.y and p.y<512 then
					lvl(13)
			elseif 256<p.y and p.y<384 then
					lvl(14)
			elseif 128<p.y and p.y<256 then
					lvl(15)
			elseif -1<p.y and p.y<128 then
					lvl(16)
			elseif p.y< -1 then
					p_lvl_up()
			end
	end
end

function lvl(level)
	if level==1 then
		cam_x=0
		cam_y=384
	elseif level==2 then
		cam_x=0
		cam_y=256	
	elseif level==3 then
		cam_x=0
		cam_y=128
	elseif level==4 then
		cam_x=0
		cam_y=0	
	elseif level==5 then
		cam_x=128
		cam_y=384
	elseif level==6 then
		cam_x=128
		cam_y=256	
	elseif level==7 then
		cam_x=128
		cam_y=128	
	elseif level==8 then
		cam_x=128
		cam_y=0	
	elseif level==9 then
		cam_x=256
		cam_y=384	
	elseif level==10 then
		cam_x=256
		cam_y=256	
	elseif level==11 then
		cam_x=256
		cam_y=128	
	elseif level==12 then
		cam_x=256
		cam_y=0
	elseif level==13 then
		cam_x=384
		cam_y=384	
	elseif level==14 then
		cam_x=384
		cam_y=256	
	elseif level==15 then
		cam_x=384
		cam_y=128	
	elseif level==16 then
		cam_x=384
		cam_y=0	
	end
end

function p_lvl_up()
	p.x=p.x+128
	p.y=p.y+512
end

function p_lvl_down()
	p.x=p.x-128
	p.y=p.y-512
end