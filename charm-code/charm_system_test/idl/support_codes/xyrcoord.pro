pro xyrcoord, imgsz, xcoord, ycoord, rcoord

xcoord=congrid(reform(findgen(imgsz[1]),imgsz[1],1),imgsz[1],imgsz[2])
;rot(congrid(transpose(findgen(imgsz[1])),imgsz[1],imgsz[2]),90)

ycoord=congrid(transpose(findgen(imgsz[2])),imgsz[1],imgsz[2])
;rot(xcoord,-90)

rcoord=sqrt((xcoord-imgsz[1]/2.)^2.+(ycoord-imgsz[2]/2.)^2)

end