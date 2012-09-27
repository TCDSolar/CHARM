;Calculates minimum distance between two polygons

function poly_dist, v1, v2

min_delta = sqrt((v1[0,0] - v2[0,0])^2+(v1[1,0] - v2[1,0])^2)

vo=fltarr(n_elements(v1[0,*]))

loc = 0
for i=0, n_elements(v1[0,*])-1 do begin
	delta_x = v1[0, i] - v2[0, *]
	delta_y = v1[1, i] - v2[1, *]
	delta = sqrt(delta_x^2+delta_y^2)
	temp = min(delta, /nan)
	if temp le min_delta then begin
		min_delta = temp
		loc = i
	endif
endfor

distance=[min_delta, loc]

return, distance

end