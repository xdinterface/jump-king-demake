function camera_update()
	camera(cam_x,cam_y)
	if 0<p.x and p.x<128 then
			cam_x=0
			if 384<p.y and p.y<512 then
					cam_y=384
			elseif 256<p.y and p.y<384 then
					cam_y=256
			elseif 128<p.y and p.y<256 then
					cam_y=128
			elseif -1<p.y and p.y<128 then
					cam_y=0
			elseif p.y<-1 then
					p.x=p.x+128
					p.y=p.y+512
					cam_x=cam_x+128
					cam_y=cam_y+512
			end
	elseif 128<p.x and p.x<256 then
			cam_x=128
			if 512<p.y then
					p.x=p.x-128
					p.y=p.y-512
					cam_x=cam_x-128
					cam_y=cam_y-512
			elseif 384<p.y and p.y<512 then
					cam_y=384
			elseif 256<p.y and p.y<384 then
					cam_y=256
			elseif 128<p.y and p.y<256 then
					cam_y=128
			elseif -1<p.y and p.y<128 then
					cam_y=0
			elseif p.y<0 then
					p.x=p.x+128
					p.y=p.y+512
			end
	elseif 256<p.x and p.x<384 then
			cam_x=256
			if 512<p.y then
					p.x=p.x-128
			elseif 384<p.y and p.y<512 then
					cam_y=384
			elseif 256<p.y and p.y<384 then
					cam_y=256
			elseif 128<p.y and p.y<256 then
					cam_y=128
			elseif -1<p.y and p.y<128 then
					cam_y=0
			elseif p.y<-1 then
					p.x=p.x+128
					p.y=p.y+512
			end
	end
end