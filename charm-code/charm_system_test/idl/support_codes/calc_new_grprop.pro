function calc_new_grprop,chstr,grstr,mask,los_map,eit_map = eit_map
	print,n_elements(chstr),' CHs in this group'

for i=0,1 do begin
	grstr.CHGR_BR_ARC[i]   = min(chstr.ch_br_arc[i])
	grstr.CHGR_BR_ARC[i+2] = max(chstr.ch_br_arc[i+2])
		
	grstr.CHGR_BR_PIX[i]   = min(chstr.CH_BR_PIX[i])
	grstr.CHGR_BR_PIX[i+2] = max(chstr.CH_BR_PIX[i+2])
	
endfor

 indexx = [0,0,2,2]
 indexy = [1,3,1,3]
 for j=0,3 do begin  & $
     latlon = arcmin2hel(grstr.CHGR_BR_ARC[indexx[j]]/60.,grstr.CHGR_BR_ARC[indexy[j]]/60.,date=eit_map.time,/soho)  & $
     grstr.chgr_br_HG_LATLON_deg_disk[*,j]=latlon  & $
     car_lonlat = conv_h2c([grstr.chgr_br_HG_LATLON_deg_disk[1,j],grstr.chgr_br_HG_LATLON_deg_disk[0,j]],eit_map.time)  & $
     grstr.chgr_br_CARR_LONLAT_deg_disk[*,j]=car_lonlat  & $
 endfor

;=========================================================================================
;========================   update center ================================================
;=========================================================================================
	XX=GET_MAP_XP(eit_map)
	YY=GET_MAP_YP(eit_map)
	newx=total(xx*los_map*mask)/total(los_map*mask)
	newy=total(yy*los_map*mask)/total(los_map*mask)
	 arr=findgen(1024)            
	 x_px=rebin(arr,1024,1024)
	 y_px=rebin(rotate(arr,1),1024,1024)
	newx_px=total(x_px*los_map*mask)/total(los_map*mask)
	newy_px=total(y_px*los_map*mask)/total(los_map*mask)

	GRSTR.CHGR_CBR_ARC = [newx,newy]
	grstr.CHGR_CBR_DEG = arcmin2hel(newx/60.,newy/60.,date=eit_map.time,/soho)
	grstr.CHGR_CBR_PIX = [newx_px,newy_px]
	grstr.chgr_cbr_carr_disk = conv_h2c([grstr.CHGR_CBR_DEG[1],grstr.CHGR_CBR_DEG[0]],eit_map.time) 

;=========================================================================================
;========================   update WIDTH ================================================
;=========================================================================================
 	grstr.CHGR_LON_WIDTH_ARC = grstr.CHGR_BR_ARC[2] - grstr.CHGR_BR_ARC[0] 
 	grstr.CHGR_LAT_WIDTH_ARC = grstr.CHGR_BR_ARC[3] - grstr.CHGR_BR_ARC[1] 
	grstr.CHGR_LON_WIDTH_PX  = grstr.CHGR_BR_PIX[2] - grstr.CHGR_BR_PIX[0]
 	grstr.CHGR_LAT_WIDTH_PX  = grstr.CHGR_BR_PIX[3] - grstr.CHGR_BR_PIX[1]
 	grstr.CHGR_LON_WIDTH_HG_DEG = $
 		max(grstr.chgr_br_HG_LATLON_deg_disk[1,*])-min(grstr.chgr_br_HG_LATLON_deg_disk[1,*])
	grstr.CHGR_LAT_WIDTH_HG_DEG = $
 		max(grstr.chgr_br_HG_LATLON_deg_disk[0,*])-min(grstr.chgr_br_HG_LATLON_deg_disk[0,*])
 	grstr.CHGR_LON_WIDTH_CARR_DEG  = $
 		max(grstr.chgr_br_CARR_LONLAT_deg_disk[0,*])-min(grstr.chgr_br_CARR_LONLAT_deg_disk[0,*])
 	grstr.CHGR_LAT_WIDTH_CARR_DEG  = $
 		max(grstr.chgr_br_CARR_LONLAT_deg_disk[1,*])-min(grstr.chgr_br_CARR_LONLAT_deg_disk[1,*])


;=========================================================================================
;========================   update area ================================================
;=========================================================================================
	grstr.CHGR_AREA_PIX = total(chstr.ch_area_px_disk)
	grstr.CHGR_AREA_Deg2 = total(chstr.CH_AREA_Deg2)
	grstr.CHGR_AREA_MM = total(chstr.CH_AREA_MM)
return,grstr	
end
