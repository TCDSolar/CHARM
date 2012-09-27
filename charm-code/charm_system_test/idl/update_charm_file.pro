function update_charm_file,file,localpath=localpath,remotepath=remotepath,grid=grid,err=err,verbose=verbose,datadir=datadir
;-
; UPDATE_CHARM_FILE
;    1. Open Sav file and get EIT/MDI files used
;    2  Update: CC
;    3. Get list of download files
;    4. Update each individual file   => UPDATE_CHARM_FILE
;    5. Generate DB files -> HELIODB_META 
;    6. Save DB files on storage  
;

; Variables:
  mdi_storage = '/grid/vo.helio-vo.eu/data/mdi_mag/'
  eit_storage = '/grid/vo.helio-vo.eu/data/eit_195/'
  charm_storage='/grid/vo.helio-vo.eu/data/charm_output/savfiles/'
  mkdir_command=(~keyword_set(grid))?'mkdir -p ':'lfc-mkdir -p '
  
  if ~keyword_set(localpath) then localpath='.'

  if file eq '' then begin
     print,'$$ UPDATE_CHARM_FILE: Not file set'
     return,-1
  endif

;======================================================
;    1. Open Sav file and get EIT/MDI files used
;===========================
; Open the sav file to update
  restore,file,verbose=verbose

; Get the EIT file used on the detection
	eit_getfiles,filename=s_f.euv_filename,grid=grid,verbose=verbose,dirname=datadir
	YYYYMMDD = anytim(s_f.date_obs,/ecs,/date)
	YYYYMM = strmid(YYYYMMDD,0,8)

; online
;	EIT_URL= "http://sohodata.nascom.nasa.gov//archive/soho/private/data/processed/eit/lz/"+ YYYYMM + s_f.EIT_FILENAME
;	spawn,'wget '+eit_url + ' -P '+ localpath
;	if keyword_set(verbose) then print,'EIT file downloaded: '+s_f.EIT_FILENAME
; local
;    EIT_URL=eit_storage+YYYYMMDD+'/'+s_f.EIT_FILENAME+'.gz'
;    eit_file = localpath+'/'+s_f.eit_filename
;    spawn,copy_order(local=eit_file+'.gz',remote=EIT_URL,/from,grid=grid)
;    spawn,'gunzip '+ eit_file +'.gz'


; Get MDI file used on the detection (from Grid)
        mdi_getfiles,filename=s_f.MDI_FILENAME_NODATE,dirname=datadir,grid=grid

	;; dates=mdi_file2date(s_f.MDI_FILENAME_NODATE)
	
	;; ; Check if the file exist in the grid and copy it
	;;     mdi_file_exist=file_exist_gridstorage(mdi_storage+dates+'/'+s_f.MDI_FILENAME_NODATE+'.gz')
	;;     if mdi_file_exist then begin
	;;   		spawn,copy_order(local=localpath+'/'+s_f.MDI_FILENAME_NODATE+'.gz',remote=mdi_storage+dates+'/'+s_f.MDI_FILENAME_NODATE+'.gz',/from,grid=grid)
   	;; 		spawn,'gunzip '+localpath+'/'+s_f.MDI_FILENAME_NODATE+'.gz'
	;;     	if keyword_set(verbose) then print,'$$ UPDATE_CHARM_FILE: MDI file copied locally: '+s_f.MDI_FILENAME_NODATE
	;; 	endif else begin
	;; 		print,'$$ UPDATE_CHARM_FILE: Not MDI file found '+s_f.MDI_FILENAME_NODATE +' '+ s_f.MDI_FILENAME_DATE
	;; 		return,-1
	;; 	endelse	    

;======================================================
;    2. Update: CC
;===========================
;TODO: Have to be included on ch_finder

eit_file=localpath+'/'+s_f.EUV_FILENAME
	eit_prep,eit_file,eit_header,eit_data
	index2map,eit_header,eit_data,eit_map
	sizem    =  size(eit_data)
	date_obs =  sxpar(eit_header,'DATE-OBS')
	eit_flnm =  sxpar(eit_header,'FILENAME')
	solar_r  =  sxpar(eit_header,'SOLAR_R')
	crpix1   =  sxpar(eit_header,'CRPIX1')
	crpix2   =  sxpar(eit_header,'CRPIX2')
	s2_seit  =  12
	eit_map_rot = rot_map( eit_map, eit_map.roll_angle ) 	;TODO: this need to be fixed on ch_finder and here. For v.2.
	XX=GET_MAP_XP(eit_map_rot)
	YY=GET_MAP_YP(eit_map_rot)
XX_plane=lambert_project(XX,[eit_map.xc,eit_map.yc],eit_map.dx,date=eit_map.time)
YY_plane=lambert_project(YY,[eit_map.xc,eit_map.yc],eit_map.dx,date=eit_map.time)
sizep=size(xx_plane)
temp = add_tag(s_ch,0.,'cc_arc_x')
temp = add_tag(temp,0.,'cc_arc_y')
temp = add_tag(temp,fltarr(2,4),'ch_br_HG_LATLON_deg_disk',/no_pair)
temp = add_tag(temp,fltarr(2,4),'ch_br_CARR_LONLAT_deg_disk',/no_pair)
temp = add_tag(temp,0.,'ch_lat_width_px')
temp = add_tag(temp,0.,'ch_lon_width_px')
temp = add_tag(temp,0.,'ch_lat_width_hg_deg')
temp = add_tag(temp,0.,'ch_lon_width_hg_deg')
temp = add_tag(temp,0.,'ch_lat_width_carr_deg')
temp = add_tag(temp,0.,'ch_lon_width_carr_deg')
temp = add_tag(temp,0.,'CH_AREA_Deg2')
temp = add_tag(temp,0l,'CH_AREA_px_disk')
temp = add_tag(temp,[0.,0.],'chc_latlon_deg_disk',/no_pair)
temp = add_tag(temp,[0.,0.],'chc_pix_disk',/no_pair)
temp = add_tag(temp,[0.,0.],'chc_carr_disk',/no_pair)
new_s_ch = temp

all_mask = bytarr(sizem[1],sizem[2])
smart_hmi_make_resmaps,eit_map,/nosave, outlos=los_map

for i=0,n_elements(s_ch)-1 do begin
   bound=egso_sfc_chain2ind(strsplit(s_ch[i].cc_pix_xy,',',/extract)+0,s_ch[i].chain_code,sizep[1],sizep[2])
   XX1=XX_PLANE[bound]
   YY1=YY_PLANE[bound]
   for j=0,n_elements(xx1)-1 do begin & $
      kk=min(abs(xx[*,0]-xx1[j]),ll)& $
      mm=(j eq 0)?kk:[mm,kk] & $
      indx=(j eq 0)?ll:[indx,ll] & $ 
      kk=min(abs(yy[0,*]-yy1[j]),ll) & $
      nn=(j eq 0)?kk:[nn,kk] & $
      indy=(j eq 0)?ll:[indy,ll] & $
   endfor
   path_xy=transpose([[indx],[indy]])
   npath=contour_nogap(path_xy)
   npath_ind=coord2ind(npath,[sizem[1],sizem[2]])
   npath_cc=egso_sfc_chain_code(npath_ind,sizem[1],sizem[2])
   out_cc=string(npath_cc,format='('+strtrim(n_elements(npath_cc),2)+'I1)')
   new_s_ch[i].CHAIN_CODE=out_cc
   chain_length=n_elements(npath_cc)
   new_s_ch[i].CCODE_LENGTH = chain_length
   out_xy=string(npath[*,0],format='(I4.3,",",I4.3)')
   new_s_ch[i].CC_PIX_XY = out_xy
   new_s_ch[i].CC_ARC_X = xx[indx[0],0]
   new_s_ch[i].CC_ARC_Y = yy[0,indy[0]]

;======================================================
;    3. Update: Coordinates
;===========================
   ;Bounding box
   new_s_ch[i].ch_br_arc=[min(xx1),min(yy1),max(xx1),max(yy1)]
   new_s_ch[i].ch_br_pix=[min(npath[0,*]),min(npath[1,*]),max(npath[0,*]),max(npath[1,*])]
   
   indexx = [0,0,2,2]
   indexy = [1,3,1,3]
   for j=0,3 do begin  & $
      latlon = arcmin2hel(new_s_ch[i].ch_br_arc[indexx[j]]/60.,new_s_ch[i].ch_br_arc[indexy[j]]/60.,date=eit_map_rot.time,/soho)  & $
      new_s_ch[i].ch_br_HG_LATLON_deg_disk[*,j]=latlon  & $
      car_lonlat = conv_h2c([new_s_ch[i].ch_HG_LATLON_DEG_disk[1,j],new_s_ch[i].ch_HG_LATLON_DEG_disk[0,j]],eit_map_rot.time)  & $
      new_s_ch[i].ch_br_CARR_LONLAT_deg_disk[*,j]=car_lonlat  & $
   endfor
      
   ;Width
      new_s_ch[i].CH_LON_WIDTH_ARC = new_s_ch[i].ch_br_arc[2]-new_s_ch[i].ch_br_arc[0]
      new_s_ch[i].CH_LAT_WIDTH_ARC = new_s_ch[i].ch_br_arc[3]-new_s_ch[i].ch_br_arc[1]
      new_s_ch[i].CH_LON_WIDTH_PX  = new_s_ch[i].ch_br_pix[2]-new_s_ch[i].ch_br_pix[0]
      new_s_ch[i].CH_LAT_WIDTH_PX  = new_s_ch[i].ch_br_pix[3]-new_s_ch[i].ch_br_pix[1]
      new_s_ch[i].CH_LON_WIDTH_HG_DEG = $
         max(new_s_ch[i].ch_br_HG_LATLON_deg_disk[1,*]) - min(new_s_ch[i].ch_br_HG_LATLON_deg_disk[1,*])
      new_s_ch[i].CH_LAT_WIDTH_HG_DEG = $
         max(new_s_ch[i].ch_br_HG_LATLON_deg_disk[0,*]) - min(new_s_ch[i].ch_br_HG_LATLON_deg_disk[0,*])
      new_s_ch[i].CH_LON_WIDTH_CARR_DEG = $
         max(new_s_ch[i].ch_br_CARR_LONLAT_deg_disk[0,*]) - min(new_s_ch[i].ch_br_CARR_LONLAT_deg_disk[0,*])
      new_s_ch[i].CH_LAT_WIDTH_CARR_DEG = $
         max(new_s_ch[i].ch_br_CARR_LONLAT_deg_disk[1,*]) - min(new_s_ch[i].ch_br_CARR_LONLAT_deg_disk[1,*])




;=========================================================================================
;========================   update area ==================================================
;=========================================================================================
;TODO: Have to be included on ch_finder
	;new_s_ch[i].CH_AREA_MM=s_ch[i].CH_AREA_MM/1000.
;Area surface Sun: A_s=4*!pi*R_sun^2.  1" = 715 km = 0.715 Mm
;Sq degree => whole sphere: 4*!pi (180/!pi)^2
; areasqd_ch= A_mm * Whole_Sphere_SQdeg/A_s = CH_AREA_MM * ((180./!pi)/(map.rsun*0.715))^2.
	new_s_ch[i].CH_AREA_DEG2=new_s_ch[i].CH_AREA_MM* ((180./!pi)/(eit_map.rsun*0.715))^2.

;Pixesl on disk, using mask and contour from previous steps.
	oROI = OBJ_NEW('IDLanROI',NPATH[0,*],NPATH[1,*])
	mask = oroi -> computemask(dimensions =[sizem[1],sizem[2]])/255b
	all_mask=all_mask+mask*s_ch[i].chgr_num
	OBJ_DESTROY, oROI
	hist_mask = histogram(mask)
	new_s_ch[i].CH_AREA_px_disk = hist_mask[1]

;=========================================================================================
;========================   update center ================================================
;=========================================================================================

	newx=total(xx*los_map*mask)/total(los_map*mask)
	newy=total(yy*los_map*mask)/total(los_map*mask)
	 arr=findgen(sizem[1])            
	 x_px=rebin(arr,sizem[1],sizem[2])
	 y_px=rebin(rotate(arr,1),sizem[1],sizem[2])
	newx_px=total(x_px*los_map*mask)/total(los_map*mask)
	newy_px=total(y_px*los_map*mask)/total(los_map*mask)

	new_s_ch[i].chc_arc = [newx,newy]
	new_s_ch[i].chc_latlon_deg_disk = arcmin2hel(newx/60.,newy/60.,date=eit_map_rot.time,/soho)
	new_s_ch[i].chc_pix_disk = [newx_px,newy_px]
	new_s_ch[i].chc_carr_disk = conv_h2c([new_s_ch[i].chc_latlon_deg_disk[1],new_s_ch[i].chc_latlon_deg_disk[0]],eit_map_rot.time] 
	
ENDFOR
;=========================================================================================
;========================   CHs updated ================================================
;=========================================================================================
print,'CHs updated'
s_ch = new_s_ch


;=========================================================================================
;========================   Update Group ================================================
;=========================================================================================
;updategroup using s_ch.chgr_num ( group place..) => mask => add them...
;all_mask contains the masks, and los_map the geometry correction.
temp = add_tag(s_gr,fltarr(2,4),'chgr_br_HG_LATLON_deg_disk',/no_pair)
temp = add_tag(temp,fltarr(2,4),'chgr_br_CARR_LONLAT_deg_disk',/no_pair)
temp = add_tag(temp,[0.,0.],'chgr_cbr_carr_disk',/no_pair)
temp = add_tag(temp,0.,'chgr_lat_width_arc')
temp = add_tag(temp,0.,'chgr_lon_width_arc')
temp = add_tag(temp,0.,'chgr_lat_width_px')
temp = add_tag(temp,0.,'chgr_lon_width_px')
temp = add_tag(temp,0.,'chGR_lat_width_hg_deg')
temp = add_tag(temp,0.,'chGR_lon_width_hg_deg')
temp = add_tag(temp,0.,'chGR_lat_width_carr_deg')
temp = add_tag(temp,0.,'chGR_lon_width_carr_deg')
temp = add_tag(temp,0.,'CHGR_AREA_Deg2')
new_s_gr = temp

for i=0,n_elements(s_gr)-1 do begin
	k = where(s_ch.chgr_num eq i+1,count)
	if count gt 1 then $
		s_gr_temp=calc_new_grprop(s_ch[k],new_s_gr[i],(all_mask eq i+1),los_map,eit_map=eit_map_rot) $
		else $
		s_gr_temp=copychtogr(s_ch[k],new_s_gr[i])
	new_s_gr[i]=s_gr_temp
endfor

;=========================================================================================
;========================   GROUPs updated ================================================
;=========================================================================================
print,'GROUPs updated'
s_gr = new_s_gr

;=========================================================================================
;========================  Saving file================================================
;=========================================================================================
print,'saving file '+file
save,file=file,s_f,s_ch,s_gr,/compress
;=========================================================================================

; New sav files, save them to the grid storage
	spawn,mkdir_command+charm_storage+YYYYMMDD
	justfile=(reverse(strsplit(file,'/',/extract)))[0]
    spawn,copy_order(local=file,remote=charm_storage+YYYYMMDD+'/'+justfile,/to,grid=grid)
	
return,1
end
