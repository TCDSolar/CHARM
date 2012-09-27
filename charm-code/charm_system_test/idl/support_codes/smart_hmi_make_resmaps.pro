pro smart_hmi_make_resmaps,inmap,onek=onek, nosave=nosave, outlos=outlos

map=inmap

if keyword_set(onek) then begin
	add_prop,map,data=rebin(map.data,1024,1024),/replace
	map.dx=map.dx*4.
	map.dx=map.dy*4.
endif

imgsz=size(map.data)

rsunmm=695.5
rsunasec=973.159
rsunpx=rsunasec/map.dx
mmppx=rsunmm/rsunasec*map.dx

resmapp=smart_paths(/resmap,/no_cal)

xyrcoord,imgsz, xcoord, ycoord, rcoord

;plot_image,rcoord

limbmask=fltarr(imgsz[1],imgsz[2])
loscormap=fltarr(imgsz[1],imgsz[2])
pxareamap=fltarr(imgsz[1],imgsz[2])
rorsunmap=fltarr(imgsz[1],imgsz[2])

limbmask[where(finite(map.data) eq 1)]=1.
if not keyword_set(nosave) then save,limbmask,file=resmapp+'mdi_limbmask_map.sav',/compress

loscor=1./cos(asin(rcoord/rsunpx)) < 1./cos(86.32*!dtor)
if (where(finite(loscor) ne 1))[0] ne -1 then loscor[where(finite(loscor) ne 1)]=0
if not keyword_set(nosave) then save,loscor,file=resmapp+'mdi_loscor_map.sav',/compress

;pxareamap
cosmap=(loscormap*rsunmm/rsunpx)^2.
if (where(finite(cosmap) ne 1))[0] ne -1 then cosmap[where(finite(cosmap) ne 1)]=0
if not keyword_set(nosave) then save,cosmap,file=resmapp+'mdi_px_area_map.sav',/compress

rorsun=rcoord/rsunpx
if (where(finite(rorsun) ne 1))[0] ne -1 then rorsun[where(finite(rorsun) ne 1)]=0
if not keyword_set(nosave) then save,rorsun,file=resmapp+'mdi_rorsun_map.sav',/compress

degmap=asin(rorsunmap)/!dtor
if (where(finite(degmap) ne 1))[0] ne -1 then degmap[where(finite(degmap) ne 1)]=0
if not keyword_set(nosave) then save,degmap,file=resmapp+'mdi_degmap_rad.sav',/compress

outlos=loscor

;plot,degmap[*,2048]
;oplot,limbmask[*,2048]*10.,lines=2
;oplot,loscormap[*,2048]*10.,lines=2,color=150

;stop

end