;Calculates minimum distance between two polygons on the cylindrical Lambert map
;Euclidean distance, see distance_measure.pro
;Lambert cylindrical surface produced by lambert_project.pro - limited to +/-80 degrees lat &long.

function polydist_lambert1, v1_, v2_, xsize, ysize
lat=80.
long=80.

;Distance will e given in angles.

;Converting to spherical coordinates:
v1_x=( (v1_[0, 0]-xsize/2.0)*((2.*long)/xsize) )
v2_x=( (v2_[0, 0]-xsize/2.0)*((2.*long)/xsize) )
v1_y=( asin((v1_[1, 0]-ysize/2.0)*(2.0/ysize))*(2.*lat)/!pi )
v2_y=( asin((v2_[1, 0]-ysize/2.0)*(2.0/ysize))*(2.*lat)/!pi )

min_delta = sqrt((v1_x - v2_x)^2+(v1_y - v2_y)^2)	;distance btw any two points is the temporary minimum distance (Pythagoras)

vo=fltarr(n_elements(v1_[0,*]))

v1=v1_
v2=v2_
for i=0, n_elements(v1_[0,*])-1 do begin
	v1[0, i]=( (v1_[0, i]-xsize/2.0)*((2.*long)/xsize) )
	v1[1, i]=( asin((v1_[1, i]-ysize/2.0)*(2.0/ysize))*(2.*lat)/!pi )
endfor
for i=0, n_elements(v2_[0,*])-1 do begin
	v2[0, i]=( (v2_[0, i]-xsize/2.0)*((2.*long)/xsize) )
	v2[1, i]=( asin((v2_[1, i]-ysize/2.0)*(2.0/ysize))*(2.*lat)/!pi )
endfor

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