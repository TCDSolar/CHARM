function latlon_area,lat0,lat1,lon0,lon1,radius=radius
;+
;  Calculates the area of a lat-lon rectangle on a sphere
;  with radius R (if not, it's calculated on the solar surface)
;  in the same units as R.
;  Values for latitude and longigute in degrees.
;-
if n_elements(radius) eq 0 then radius= 6.955e2 ; solar radius in Mm

; latitudes converted to radians
lat0 = lat0 * !DtoR
lat1 = lat1 * !DtoR

; final area, in Mm2
; http://mathforum.org/library/drmath/view/63767.html
   area = 2 * !pi * radius^2 * abs(sin(lat0)-sin(lat1)) * abs(lon0 - lon1)/360.

 
return,area
end
pro plots_box,y0,y1,x0,x1
  plots,[x0,x0,x1,x1,x0],[y0,y1,y1,y0,y0]
end
pro checking_area,directory

files=findfile(directory+'/*.sav')
window,0
plot,[-90,90],[-90,90],/nodata,xstyle=1,ystyle=1
for i=0,n_elements(files)-1 do begin
   
   restore,files[i]
   area = latlon_area(s_gr.chgr_br_deg[0],s_gr.chgr_br_deg[2],s_gr.chgr_br_deg[1],s_gr.chgr_br_deg[3])

   area_lar = (i eq 0)?s_gr.chgr_area_mm:[area_lar,s_gr.chgr_area_mm]
   area_chk = (i eq 0)?area:[area_chk,area]

   gtarea = where(s_gr.chgr_area_mm gt area,ngt)
   if ngt gt 0 then begin
      for j=0,ngt-1 do begin
         print,files[i],gtarea[j],s_gr[gtarea[j]].chgr_br_deg,s_gr[gtarea[j]].chgr_area_mm,area[gtarea[j]]
         plots_box,s_gr[gtarea[j]].chgr_br_deg[0],s_gr[gtarea[j]].chgr_br_deg[2],s_gr[gtarea[j]].chgr_br_deg[1],s_gr[gtarea[j]].chgr_br_deg[3]
      endfor
   endif
   
endfor

openw,lun,'testing_area.txt',/get_lun
for i=0,n_elements(area_lar)-1 do $
   printf,lun,area_lar[i],area_chk[i],format='(2(f11.2,x))'
close,lun

window,1
plot,area_lar-area_chk
chk_gt = where(area_chk lt area_lar,nn)
print,nn
print,nn*100./n_elements(area_lar),'% have areas larger than bounding box'
end
