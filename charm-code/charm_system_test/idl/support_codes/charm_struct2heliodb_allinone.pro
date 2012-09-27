pro obs_table,inst=inst,fits_file=fits_file,orig_file=orig_file,file_num=file_num,file_obs=file_obs,infile_search=infile_search,check_num=check_num,save_path=save_path,pathinstr=pathinstr 
;+
;-
;; General properties
  if not keyword_set(file_num) then file_num=1l
  if not keyword_set(save_path) then save_path='./'
 
  entry='>'
  if not keyword_set(file_obs) then begin
     fileobs=save_path+'obs_table_'+inst+'_'+time2file(systim(/utc))+'.csv'
  endif else begin
     fileobs=save_path+file_obs  
     if file_test(fileobs) then begin 
        entry='>>'
        if keyword_set(infile_search) then begin
           ;Look if inst_filename entry exist
           spawn,"grep "+fits_file+" "+fileobs+ " | awk -F ';' '{print $1}' | sed 's/;//'",out
           file_num=(out+0l ne 0)?(out+0l):file_num    ;file_NUM changes if entry was found.
           entry=(out+0 ne 0)?'x':entry        ;entry is not created if file entry exist
        endif
        if (keyword_set(check_num) and entry eq '>>') then begin
           ;Look if eit_num is the proper one
           ;spawn,"wc -l "+file_obs, out
           spawn,"tail -n1 "+fileobs+ " | awk -F ';' '{print $1}' | sed 's/;//'",out
           file_num=(out+1l eq file_num)?file_num:(out+1l)
          ; print,'obs_table: '+string(file_num)
        endif
     endif 
  endelse
  

  if entry ne 'x' then begin
     extract_fits_info,inst=inst,fits_file=fits_file,orig_file=orig_file,outdataline=outdataline,file_num=file_num,tags=tags,pathinstr=pathinstr
     if entry eq '>' then begin
        spawn,'echo ''#'+strjoin(tags,';')+''' ' + entry + fileobs
        entry='>>'
     endif
     spawn,'echo '''+strjoin(outdataline,';')+''' ' + entry + fileobs
  endif
end

;======================================================================================================
;======================================================================================================

pro extract_fits_info,inst=inst,fits_file=fits_file,orig_file=orig_file,outdataline=outdataline,file_num=file_num,tags=tags, $
					  pathinstr=instpath
;+
;-
;; Check if instpath has a slash at the end
instpath=((strpos(instpath,'/',/reverse_search))[0] eq strlen(instpath)-1)?instpath:instpath+'/'

;;
  if inst eq 'mdi' then begin
     ;inst_path='../';***
     obs_id=2
     r_sun='r_sun'
     center_x='center_x'
     center_y='center_y'
     parts=str_sep(orig_file,'.')
     mdi_dir=parts[0]+'.'+string(parts[1]+0,format='(I6.6)')+'/'
     url='"http://soi.Stanford.EDU/magnetic/mag//"+mdi_dir+orig_file'
;     mdi_dir=''
     inst_path=instpath;+mdi_dir
;     parts2=str_sep(fits_file,'.') ; Trying to write the proper filename. Lar's code writes up a part of it.
;     fits_file=(parts2[1] eq 'fits')?'s'+fits_file+'.gz':'s'+fits_file+'.fits.gz'
	 fits_file = orig_file
  endif
  if inst eq 'eit' then begin
     ;inst_path='../';***
     obs_id=3
     r_sun='solar_r'
     center_x='crpix1'
     center_y='crpix2'
     url='"http://sohodata.nascom.nasa.gov//archive/soho/private/data/processed/eit/lz/"+yyyy+"/"+mm+"/"+fits_file'
     yyyy=strmid(fits_file,3,4)
     mm=strmid(fits_file,7,2)
     inst_path=instpath;+yyyy+'/'+mm+'/'
  endif

  obsstr={id:0l,observatory_id:0l,date_obs:'',date_end:'',jdint:0d, jdfrac:0.,exp_time:0l,c_rotation:0., $
          bscale:0l,bzero:0l,bitpix:0l,naxis1:0l,naxis2:0l,r_sun:0.,center_x:0.,center_y:0.,cdelt1:0.,$
          cdelt2:0.,quality:'',filename:'',date_obs_string:'',date_end_string:'',comment:'',loc_filename:'',id2:'',url:''}

  mreadfits,inst_path+fits_file,remoteind


  obsstr.id=file_num
  obsstr.observatory_id=obs_id

  if (where(strlowcase(tag_names(remoteind)) eq 'date_obs'))[0] eq -1 then begin
     mreadfits,'/Volumes/LaCie/data/mdi_mag_orig/fd_M_96m_01d.1461.0000.fits',remoteind
     remoteind=clear_struct(remoteind) 
     obsstr.date_obs=time 
     obsstr.date_end=time
  endif else begin
     obsstr.date_obs=anytim(remoteind.date_obs,/ccsds)
     obsstr.date_end=anytim(remoteind.date_obs,/ccsds)
  endelse
  
  time=obsstr.date_obs

  ftime=time2file(time,/second)
  yyyy=strmid(ftime,0,4) & mm=strmid(ftime,4,2) & dd=strmid(ftime,6,2) & hh=strmid(ftime,9,2) & mn=strmid(ftime,11,2) & ss=strmid(ftime,13,2)
  julian=julday(mm,dd,yyyy,hh,mn,ss)
  obsstr.jdint=long(julian)
  obsstr.jdfrac=julian-long(julian)
  obsstr.exp_time=(inst eq 'mdi')?0l:remoteind.exptime            ;remoteind.exp_time  !!Check!!
  obsstr.c_rotation=tim2carr(time, /dc)
  obsstr.bscale=(inst eq 'mdi')?1l:remoteind.bscale  
  obsstr.bzero=(inst eq 'mdi')?0l:remoteind.bzero    
  obsstr.bitpix=remoteind.bitpix
  obsstr.naxis1=remoteind.naxis1
  obsstr.naxis2=remoteind.naxis2
  a=execute('obsstr.r_sun=remoteind.'+r_sun)  
  a=execute('obsstr.center_x=remoteind.'+center_x)
  a=execute('obsstr.center_y=remoteind.'+center_y)
  obsstr.cdelt1=remoteind.cdelt1
  obsstr.cdelt2=remoteind.cdelt2
  obsstr.quality=''
  obsstr.filename=fits_file
  obsstr.date_obs_string=remoteind.date_obs
  obsstr.date_end_string=remoteind.date_obs
  obsstr.comment=''             ;remoteind.comment
  a=execute('obsstr.loc_filename='+url)
  obsstr.id2='" "'
  obsstr.URL=obsstr.loc_filename

outdataline=strarr(n_elements(tag_names(obsstr)))
tags=tag_names(obsstr)

;print,'extracts_fits_info: '+strtrim(obsstr.(0),2)

for i=0,n_elements(tags)-1 do outdataline[i]=strtrim(obsstr.(i),2)



end

;======================================================================================================
;======================================================================================================
pro grp_table,grp_str=grp_str,file_grp=file_grp,grp_nst=grp_nst,grp_num=grp_num,save_path=save_path,check_num=check_num,file_str=infostr
;+
;-
;; General properties
  if not keyword_set(grp_nst) then grp_nst=1l
  if not keyword_set(save_path) then save_path='./'
 
  entry='>'
  if not keyword_set(file_grp) then begin
     filegrp=save_path+'grp_table_'+time2file(systim(/utc))+'.csv'
  endif else begin
     filegrp=save_path+file_grp
     if file_test(filegrp) then begin
        entry='>>'
     endif
     if (keyword_set(check_num) and entry eq '>>') then begin
           ;Look if eit_num is the proper one
           ;spawn,"wc -l "+file_obs, out
        spawn,"tail -n1 "+filegrp+ " | awk -F ';' '{print $1}' | sed 's/;//'",out
        grp_nst=(out+1 eq grp_nst)?grp_nst:(out+1)
     endif

  endelse

  grp_num=indgen(n_elements(grp_str))+grp_nst
  for i=0,n_elements(grp_num)-1 do begin
     extract_grp_info,grpstr=grp_str[i],num=grp_num[i],outdataline=outdataline,tags=tags,file_str=infostr
     if entry eq '>' then begin
        spawn,'echo ''#'+strjoin(tags,';')+''' ' + entry + filegrp
        entry='>>'
     endif
     spawn,'echo '''+strjoin(outdataline,';')+''' ' + entry + filegrp
  endfor

  grp_nst=grp_num[n_elements(grp_num)-1]+1
end

;======================================================================================================
;======================================================================================================
pro extract_grp_info,grpstr=grpstr,num=grpnum,outdataline=outdataline,tags=tags,file_str=infostr
;+
;-

  group={id:0l,ch_nums:'',$
         chgr_br_arc_x0:0.,chgr_br_arc_y0:0.,chgr_br_arc_x1:0.,chgr_br_arc_y1:0.,$
         chgr_br_arc_x2:0.,chgr_br_arc_y2:0.,chgr_br_arc_x3:0.,chgr_br_arc_y3:0.,$
         chgr_br_pix_x0:0.,chgr_br_pix_y0:0.,chgr_br_pix_x1:0.,chgr_br_pix_y1:0.,$
         chgr_br_pix_x2:0.,chgr_br_pix_y2:0.,chgr_br_pix_x3:0.,chgr_br_pix_y3:0.,$
         chgr_br_hgdeg_long0:0.,chgr_br_hgdeg_lat0:0.,chgr_br_hgdeg_long1:0.,chgr_br_hgdeg_lat1:0.,$
         chgr_br_hgdeg_long2:0.,chgr_br_hgdeg_lat2:0.,chgr_br_hgdeg_long3:0.,chgr_br_hgdeg_lat3:0.,$
         chgr_br_carrdeg_long0:0.,chgr_br_carrdeg_lat0:0.,chgr_br_carrdeg_long1:0.,chgr_br_carrdeg_lat1:0.,$
         chgr_br_carrdeg_long2:0.,chgr_br_carrdeg_lat2:0.,chgr_br_carrdeg_long3:0.,chgr_br_carrdeg_lat3:0.,$
         chgr_cbr_arc_x:0.,chgr_cbr_arc_y:0.,$
         chgr_cbr_pix_x:0.,chgr_cbr_pix_y:0.,$
         chgr_cbr_hgdeg_long:0.,chgr_cbr_hgdeg_lat:0.,$
         chgr_cbr_carrdeg_long:0.,chgr_cbr_carrdeg_lat:0.,$
         chgr_long_width_arc:0.,chgr_lat_width_arc:0.,chgr_long_width_pix:0.,chgr_lat_width_pix:0.,$
         chgr_long_width_hgdeg:0.,chgr_lat_width_hgdeg:0.,chgr_long_width_carrdeg:0.,chgr_lat_width_carrdeg:0.,$
         chgr_area_pix:0l,chgr_area_mm:0.,chgr_area_deg2:0.,chgr_mean_bz:0.}
  
  group.id=grpnum
  group.ch_nums=strcompress(strjoin(grpstr.ch_nums[where(grpstr.ch_nums ne 0)],','),/remove_all)
;------------------------------------------------------------------------------------------
  group.chgr_br_arc_x0=grpstr.chgr_br_arc[0]  &   group.chgr_br_arc_y0=grpstr.chgr_br_arc[1]
  group.chgr_br_arc_x1=grpstr.chgr_br_arc[0]  &   group.chgr_br_arc_y1=grpstr.chgr_br_arc[3]
  group.chgr_br_arc_x2=grpstr.chgr_br_arc[2]  &   group.chgr_br_arc_y2=grpstr.chgr_br_arc[1]
  group.chgr_br_arc_x3=grpstr.chgr_br_arc[2]  &   group.chgr_br_arc_y3=grpstr.chgr_br_arc[3]
;------------------------------------------------------------------------------------------
  group.chgr_br_pix_x0=grpstr.chgr_br_pix[0]  &   group.chgr_br_pix_y0=grpstr.chgr_br_pix[1]
  group.chgr_br_pix_x1=grpstr.chgr_br_pix[0]  &   group.chgr_br_pix_y1=grpstr.chgr_br_pix[3]
  group.chgr_br_pix_x2=grpstr.chgr_br_pix[2]  &   group.chgr_br_pix_y2=grpstr.chgr_br_pix[1]
  group.chgr_br_pix_x3=grpstr.chgr_br_pix[2]  &   group.chgr_br_pix_y3=grpstr.chgr_br_pix[3]
;------------------------------------------------------------------------------------------
  group.chgr_br_hgdeg_long0=grpstr.chgr_br_HG_LATLON_DEG_DISK[1,0]  &   group.chgr_br_hgdeg_lat0=grpstr.chgr_br_HG_LATLON_DEG_DISK[0,0]
  group.chgr_br_hgdeg_long1=grpstr.chgr_br_HG_LATLON_DEG_DISK[1,1]  &   group.chgr_br_hgdeg_lat1=grpstr.chgr_br_HG_LATLON_DEG_DISK[0,1]
  group.chgr_br_hgdeg_long2=grpstr.chgr_br_HG_LATLON_DEG_DISK[1,2]  &   group.chgr_br_hgdeg_lat2=grpstr.chgr_br_HG_LATLON_DEG_DISK[0,2]
  group.chgr_br_hgdeg_long3=grpstr.chgr_br_HG_LATLON_DEG_DISK[1,3]  &   group.chgr_br_hgdeg_lat3=grpstr.chgr_br_HG_LATLON_DEG_DISK[0,3]
;------------------------------------------------------------------------------------------
  group.chgr_br_carrdeg_long0=grpstr.chgr_br_carr_LONLAT_DEG_DISK[0,0]  &   group.chgr_br_carrdeg_lat0=grpstr.chgr_br_carr_LONLAT_DEG_DISK[1,0]
  group.chgr_br_carrdeg_long1=grpstr.chgr_br_carr_LONLAT_DEG_DISK[0,1]  &   group.chgr_br_carrdeg_lat1=grpstr.chgr_br_carr_LONLAT_DEG_DISK[1,1]
  group.chgr_br_carrdeg_long2=grpstr.chgr_br_carr_LONLAT_DEG_DISK[0,2]  &   group.chgr_br_carrdeg_lat2=grpstr.chgr_br_carr_LONLAT_DEG_DISK[1,2]
  group.chgr_br_carrdeg_long3=grpstr.chgr_br_carr_LONLAT_DEG_DISK[0,3]  &   group.chgr_br_carrdeg_lat3=grpstr.chgr_br_carr_LONLAT_DEG_DISK[1,3]
;------------------------------------------------------------------------------------------
  group.chgr_cbr_arc_x=grpstr.chgr_cbr_arc[0]   &   group.chgr_cbr_arc_y=grpstr.chgr_cbr_arc[1]
;------------------------------------------------------------------------------------------
  group.chgr_cbr_pix_x=grpstr.chgr_cbr_pix[0]   &   group.chgr_cbr_pix_y=grpstr.chgr_cbr_pix[1]
;------------------------------------------------------------------------------------------
  group.chgr_cbr_hgdeg_long=grpstr.chgr_cbr_deg[1]  &  group.chgr_cbr_hgdeg_lat=grpstr.chgr_cbr_deg[0]
;------------------------------------------------------------------------------------------
  group.chgr_cbr_carrdeg_long=grpstr.chgr_cbr_carr_disk[0]  &  group.chgr_cbr_carrdeg_lat=grpstr.chgr_cbr_carr_disk[1]
;------------------------------------------------------------------------------------------
  group.chgr_long_width_arc = grpstr.CHGR_LON_WIDTH_ARC &   group.chgr_lat_width_arc = grpstr.CHGR_LAT_WIDTH_ARC 
;------------------------------------------------------------------------------------------
  group.chgr_long_width_pix = grpstr.CHGR_LON_WIDTH_PX &   group.chgr_lat_width_pix = grpstr.CHGR_LAT_WIDTH_PX 
;------------------------------------------------------------------------------------------
  group.chgr_long_width_hgdeg = grpstr.CHGR_LON_WIDTH_HG_DEG &   group.chgr_lat_width_hgdeg = grpstr.CHGR_LAT_WIDTH_HG_DEG 
;------------------------------------------------------------------------------------------
  group.chgr_long_width_carrdeg = grpstr.CHGR_LON_WIDTH_CARR_DEG &   group.chgr_lat_width_carrdeg = grpstr.CHGR_LAT_WIDTH_CARR_DEG 
;------------------------------------------------------------------------------------------
  group.chgr_area_pix=grpstr.chgr_area_pix  &   group.chgr_area_mm=grpstr.chgr_area_mm   &   group.chgr_area_deg2=grpstr.chgr_area_deg2
  group.chgr_mean_bz=grpstr.chgr_mean_bz


outdataline=strarr(n_elements(tag_names(group)))
tags=tag_names(group)
for i=0,n_elements(tags)-1 do outdataline[i]=strtrim(group.(i),2)

end

;======================================================================================================
;======================================================================================================

pro chs_table,ch_str=ch_str,file_chs=file_chs,chs_nst=chs_nst,grp_num=grp_num, $
			  eit_file=eit_num,mdi_file=mdi_num,save_path=save_path,check_num=check_num,file_str=infostr
;+
;-
;; General properties
  if not keyword_set(chs_nst) then chs_nst=1l
  if not keyword_set(save_path) then save_path='./'
 
  entry='>'
  if not keyword_set(file_chs) then begin
     filechs=save_path+'chs_table_'+time2file(systim(/utc))+'.csv'
  endif else begin
     filechs=save_path+file_chs
     if file_test(filechs) then begin
         entry='>>'
     endif
     if (keyword_set(check_num) and entry eq '>>') then begin
           ;Look if eit_num is the proper one
           ;spawn,"wc -l "+file_obs, out
        spawn,"tail -n1 "+filechs+ " | awk -F ';' '{print $1}' | sed 's/;//'",out
        chs_nst=(out+1 eq chs_nst)?chs_nst:(out+1)
     endif

  endelse

  chs_num=indgen(n_elements(ch_str))+chs_nst
  for i=0,n_elements(chs_num)-1 do begin
     extract_chs_info,chstr=ch_str[i],num=chs_num[i],grp_num=grp_num,eit_file=eit_num,mdi_file=mdi_num,outdataline=outdataline,tags=tags,infostr=infostr
     if entry eq '>' then begin
        spawn,'echo ''#'+strjoin(tags,';')+''' ' + entry + filechs
        entry='>>'
     endif
     spawn,'echo '''+strjoin(outdataline,';')+''' ' + entry + filechs
  endfor

  chs_nst=chs_num[n_elements(chs_num)-1]+1
end

;======================================================================================================
;======================================================================================================

pro extract_chs_info,chstr=chstr,num=num, $
                     grp_num=grp_num,eit_file=eit_file,mdi_file=mdi_file, $
                     outdataline=outdataline,tags=tags,infostr=infostr
;+
;-

  CH={id:0l,chg_num:0l,ch_numi:0,chg_numi:0, $
         frc_info:0l,eit_file:0l,mdi_file:0l,run_date:'',obs_date:'',$
         ch_thresh:0., $
         ch_br_arc_x0:0.,ch_br_arc_y0:0.,ch_br_arc_x1:0.,ch_br_arc_y1:0.,$
         ch_br_arc_x2:0.,ch_br_arc_y2:0.,ch_br_arc_x3:0.,ch_br_arc_y3:0.,$
         ch_br_pix_x0:0.,ch_br_pix_y0:0.,ch_br_pix_x1:0.,ch_br_pix_y1:0.,$
         ch_br_pix_x2:0.,ch_br_pix_y2:0.,ch_br_pix_x3:0.,ch_br_pix_y3:0.,$
         ch_br_hgdeg_long0:0.,ch_br_hgdeg_lat0:0.,ch_br_hgdeg_long1:0.,ch_br_hgdeg_lat1:0.,$
         ch_br_hgdeg_long2:0.,ch_br_hgdeg_lat2:0.,ch_br_hgdeg_long3:0.,ch_br_hgdeg_lat3:0.,$
         ch_br_carrdeg_long0:0.,ch_br_carrdeg_lat0:0.,ch_br_carrdeg_long1:0.,ch_br_carrdeg_lat1:0.,$
         ch_br_carrdeg_long2:0.,ch_br_carrdeg_lat2:0.,ch_br_carrdeg_long3:0.,ch_br_carrdeg_lat3:0.,$
         chc_arc_x:0.,chc_arc_y:0.,$
         chc_pix_x:0.,chc_pix_y:0.,$
         chc_hgdeg_long:0.,chc_hgdeg_lat:0.,$
         chc_carrdeg_long:0.,chc_carrdeg_lat:0.,$
         ch_long_width_arc:0.,ch_lat_width_arc:0.,ch_long_width_pix:0.,ch_lat_width_pix:0.,$
         ch_long_width_hgdeg:0.,ch_lat_width_hgdeg:0.,ch_long_width_carrdeg:0.,ch_lat_width_carrdeg:0.,$
         ch_area_pix:0l,ch_area_mm:0.,ch_area_deg2:0.,$
         ch_min_int:0.,ch_max_int:0.,ch_mean_int:0.,ch_mean2qsun:0., $
         ch_min_bz:0., ch_max_bz:0.,ch_mean_bz:0.,ch_bz_skew:0., $
         enc_met:'',cc_pix_x:0,cc_pix_y:0,cc_arc_x:0,cc_arc_y:0,chain_code:'',cc_length:0l, $
         snapshot_filename:'',snapshot_path:''}
  
  ch.id=num
  ch.chg_num=grp_num[chstr.chgr_num-1]
  ch.ch_numi=chstr.ch_num
  ch.chg_numi=chstr.chgr_num
  ch.ch_thresh=chstr.thresh
;------------------------------------------------------------------------------------------
  ch.ch_br_arc_x0=chstr.ch_br_arc[0]  &   ch.ch_br_arc_y0=chstr.ch_br_arc[1]
  ch.ch_br_arc_x1=chstr.ch_br_arc[0]  &   ch.ch_br_arc_y1=chstr.ch_br_arc[1]
  ch.ch_br_arc_x2=chstr.ch_br_arc[2]  &   ch.ch_br_arc_y2=chstr.ch_br_arc[3]
  ch.ch_br_arc_x3=chstr.ch_br_arc[2]  &   ch.ch_br_arc_y3=chstr.ch_br_arc[3]
;------------------------------------------------------------------------------------------
  ch.ch_br_pix_x0=chstr.ch_br_pix[0]  &   ch.ch_br_pix_y0=chstr.ch_br_pix[1]
  ch.ch_br_pix_x1=chstr.ch_br_pix[0]  &   ch.ch_br_pix_y1=chstr.ch_br_pix[1]
  ch.ch_br_pix_x2=chstr.ch_br_pix[2]  &   ch.ch_br_pix_y2=chstr.ch_br_pix[3]
  ch.ch_br_pix_x3=chstr.ch_br_pix[2]  &   ch.ch_br_pix_y3=chstr.ch_br_pix[3]
;------------------------------------------------------------------------------------------
  ch.ch_br_hgdeg_long0=chstr.ch_br_HG_LATLON_deg_disk[1,0]  &   ch.ch_br_hgdeg_lat0=chstr.ch_br_HG_LATLON_deg_disk[0,0]
  ch.ch_br_hgdeg_long1=chstr.ch_br_HG_LATLON_deg_disk[1,1]  &   ch.ch_br_hgdeg_lat1=chstr.ch_br_HG_LATLON_deg_disk[0,1]
  ch.ch_br_hgdeg_long2=chstr.ch_br_HG_LATLON_deg_disk[1,2]  &   ch.ch_br_hgdeg_lat2=chstr.ch_br_HG_LATLON_deg_disk[0,2]
  ch.ch_br_hgdeg_long3=chstr.ch_br_HG_LATLON_deg_disk[1,3]  &   ch.ch_br_hgdeg_lat3=chstr.ch_br_HG_LATLON_deg_disk[0,3]
;------------------------------------------------------------------------------------------
  ch.ch_br_carrdeg_long0=chstr.ch_br_CARR_LONLAT_deg_disk[0,0]  &   ch.ch_br_carrdeg_lat0=chstr.ch_br_CARR_LONLAT_deg_disk[1,0]
  ch.ch_br_carrdeg_long1=chstr.ch_br_CARR_LONLAT_deg_disk[0,1]  &   ch.ch_br_carrdeg_lat1=chstr.ch_br_CARR_LONLAT_deg_disk[1,1]
  ch.ch_br_carrdeg_long2=chstr.ch_br_CARR_LONLAT_deg_disk[0,2]  &   ch.ch_br_carrdeg_lat2=chstr.ch_br_CARR_LONLAT_deg_disk[1,2]
  ch.ch_br_carrdeg_long3=chstr.ch_br_CARR_LONLAT_deg_disk[0,3]  &   ch.ch_br_carrdeg_lat3=chstr.ch_br_CARR_LONLAT_deg_disk[1,3]
;------------------------------------------------------------------------------------------
  ch.chc_arc_x=chstr.chc_arc[0]   &   ch.chc_arc_y=chstr.chc_arc[1]
;------------------------------------------------------------------------------------------
  ch.chc_pix_x=chstr.chc_pix_disk[0]   &   ch.chc_pix_y=chstr.chc_pix_disk[1]
;------------------------------------------------------------------------------------------
  ch.chc_hgdeg_long=chstr.chc_latlon_deg_disk[1]   &   ch.chc_hgdeg_lat=chstr.chc_latlon_deg_disk[0]
;------------------------------------------------------------------------------------------
  ch.chc_carrdeg_long=chstr.CHC_CARR_DISK[0]   &   ch.chc_carrdeg_lat=chstr.CHC_CARR_DISK[1]
;------------------------------------------------------------------------------------------
  ch.ch_long_width_arc = chstr.CH_LON_WIDTH_ARC &   ch.ch_lat_width_arc = chstr.CH_LAT_WIDTH_ARC 
;------------------------------------------------------------------------------------------
  ch.ch_long_width_pix = chstr.CH_LON_WIDTH_PX &   ch.ch_lat_width_pix = chstr.CH_LAT_WIDTH_PX 
;------------------------------------------------------------------------------------------
  ch.ch_long_width_hgdeg = chstr.CH_LON_WIDTH_HG_DEG &   ch.ch_lat_width_hgdeg = chstr.CH_LAT_WIDTH_HG_DEG 
;------------------------------------------------------------------------------------------
  ch.ch_long_width_carrdeg = chstr.CH_LON_WIDTH_CARR_DEG &   ch.ch_lat_width_carrdeg = chstr.CH_LAT_WIDTH_CARR_DEG 
;------------------------------------------------------------------------------------------
  ch.ch_area_pix = chstr.CH_AREA_PX_DISK  &   ch.ch_area_mm = chstr.ch_area_mm  &  ch.ch_area_deg2  = chstr.CH_AREA_DEG2
;------------------------------------------------------------------------------------------
  ch.ch_min_int = chstr.ch_min_int  &  ch.ch_max_int = chstr.ch_max_int  &    ch.ch_mean_int = chstr.ch_mean_int
  ch.ch_mean2qsun = chstr.ch_mean2qsun
;------------------------------------------------------------------------------------------
  ch.ch_min_bz = chstr.ch_min_bz  &  ch.ch_max_bz = chstr.ch_max_bz  &  ch.ch_mean_bz = chstr.ch_mean_bz
  ch.ch_bz_skew = chstr.CH_BZ_SKEW
;------------------------------------------------------------------------------------------
  ch.enc_met  =  chstr.enc_met
  parts = str_sep(chstr.cc_pix_xy,',')
    ch.cc_pix_x  =  parts[0]       ;chstr.cc_pix_xy[0]
    ch.cc_pix_y  =  parts[1]       ;chstr.cc_pix_xy[1]
  ch.cc_arc_x   =  chstr.cc_arc_x
  ch.cc_arc_y   =  chstr.cc_arc_y
  ch.chain_code =  chstr.chain_code
  ch.cc_length  =  chstr.ccode_length
;------------------------------------------------------------------------------------------
  ch.frc_info=3
  ch.eit_file=eit_file
  ch.mdi_file=mdi_file
  ch.run_date=anytim(infostr.run_date,/ccsds)
  ch.obs_date=anytim(infostr.date_obs,/ccsds)

  ch.snapshot_filename='charm'+strmid(infostr.ch_filename,4,14)+'_chmap.png'
  ch.snapshot_path='http://solarmonitor.org/data/charm/'

outdataline=strarr(n_elements(tag_names(ch)))
tags=tag_names(ch)
for i=0,n_elements(tags)-1 do outdataline[i]=strtrim(ch.(i),2)

end
;======================================================================================================
;======================================================================================================

pro grp_webtable,grp_str=grp_str,file_str=file_str,web_path=web_path
;+
;
;-
;file_name
date=strmid(file_str.euv_filename,3,13) ;efz20080103.103609 => 20080103.1036
date=str_replace(date,'.','_')  ; 20080103.1036 => 20080103_1036

outfile=web_path+'charm_'+date+'_chgrp.csv'


;writing file
 ;writing header
;	spawn,'echo "<html>" > '+outfile
;	spawn,'echo "<body>" >> '+outfile
;        spawn,'echo "<div class=charmt>" >> ' + outfile
;	spawn,'echo "<table rules=rows width=100% align=center cellspacing=0 cellpadding=0 bgcolor=#f0f0f0>" >> '+outfile
;        spawn,'echo "<tr align=center class=chtit background=common_files/brushed-metal.jpg><td colspan=6 border=0> CHARM Coronal Holes Groups </td></tr>" >> '+outfile
;        spawn,'echo "<tr align=center class=chcolumns background=common_files/brushed-metal.jpg><td>Group ID</td><td> HG Lon,Lat</td><td>E/W-most points [Deg]</td><td>Area [10<sup>7</sup>Mm<sup>2</sup>]</td><td>B<sub>z</sub> [G]</td><td>&Phi; [10<sup>23</sup>Mx]</td></tr>"  >> '+outfile
spawn,'echo "# GroupID	; HGLon,Lat ; E/W-most points [Deg] ;  Area [10^4Mm2]; Bz [G] ; Phi[10^20Mx] " > ' + outfile

 ;writing data
	ngr=n_elements(grp_str)
	for i=0,ngr-1 do begin
		thisgr=grp_str[i]
;                spawn,'echo "<tr class=chresults align=center><td>'+string(thisgr.chgr_num,format='(I2)')+'</td><td>'+string(thisgr.chgr_cbr_DEG[0],form='(F5.1)')+','+string(thisgr.chgr_cbr_DEG[1],form='(F5.1)')+'</td><td>'+string(thisgr.chgr_br_deg[0])+'/'+string(thisgr.chgr_br_deg[2])+'</td><td>'+string(thisgr.chgr_area_mm/1e7,format='(F7.2)')+'</td><td>'+string(thisgr.chgr_mean_bz,form='(F7.2)')+'</td><td>'+string(thisgr.chgr_mean_bz*thisgr.chgr_area_mm/1e7,form='(F7.2)')+'</td></tr>" >> '+outfile
                heliocentric_coords=strcompress(((thisgr.chgr_cbr_DEG[1] lt 0)?'S':'N')+string(abs(thisgr.chgr_cbr_DEG[1]),form='(I2.2)')+  $
                                                ((thisgr.chgr_cbr_DEG[0] lt 0)?'E':'W')+string(abs(thisgr.chgr_cbr_DEG[0]),form='(I2.2)'),/remove_all)
                EWlimits=strcompress(((thisgr.chgr_br_DEG[0] lt 0)?'E':'W')+string(abs(thisgr.chgr_br_DEG[0]),form='(I2.2)')+'-'+  $
                                                ((thisgr.chgr_br_DEG[2] lt 0)?'E':'W')+string(abs(thisgr.chgr_br_DEG[2]),form='(I2.2)'),/remove_all)
                spawn, 'echo " '+string(thisgr.chgr_num,format='(I2)')+';'+heliocentric_coords+ $
                               ';'+EWlimits+';'+string(thisgr.chgr_area_mm/1e4,format='(F7.2)')+ $
                               ';'+string(thisgr.chgr_mean_bz,form='(F7.2)')+';' +string(thisgr.chgr_mean_bz*thisgr.chgr_area_mm/1e4,form='(F7.2)')+ $
                               '" >> '+ outfile
	endfor
 ;writing footer
;	spawn,'echo "</table>" >> '+outfile
;	spawn,'echo "</div>" >> '+outfile		
;	spawn,'echo "</body>" >> '+outfile
;	spawn,'echo "</html>" >> '+outfile



end

;======================================================================================================
;======================================================================================================
pro charm_struct2heliodb_frcinfo,outfrc=outfrc

frc={id:0l,institut:'',name_code:'',version_code:'',feature:'',Person:'',Reference:''}

frc.id=   3
frc.institut='TCD'
frc.name_code='CHARM'
frc.version_code='1.0'
frc.feature='CORONAL HOLES'
frc.Person='LARISZA KRISTA / DAVID PEREZ-SUAREZ'
frc.Reference='doi:10.1007/s11207-009-9357-2'

outdataline=strarr(n_elements(tag_names(frc)))
tags=tag_names(frc)
for i=0,n_elements(tags)-1 do outdataline[i]=strtrim(frc.(i),2)


spawn,'echo ''#'+strjoin(tags,';')+''' ' + '>' + outfrc
spawn,'echo '''+strjoin(outdataline,';')+''' ' + '>>' + outfrc
 

end

;======================================================================================================
;======================================================================================================


pro charm_struct2heliodb_obsinfo,outobs=outobs

obs={id:0l,Observat:'',Instrument:'',Telescope:'',Units:'',Wavemin:0.,Wavemax:0.,Wavename:'',Waveunit:'',Spectral_name:'',Obs_type:'',Comment:''}

obs.id=   2
obs.Observat='SoHO'
obs.Instrument='MDI'
obs.Telescope='Magnetogram'
obs.Units='Gauss'
obs.Wavemin=676.8
obs.Wavemax=obs.Wavemin
obs.wavename='Ni I'
obs.waveunit='nm'
obs.Spectral_name='line_of_sight magnetic field'
obs.Obs_type='Remote-sensing'
obs.Comment='96-min fd'

outdataline=strarr(n_elements(tag_names(obs)))
tags=tag_names(obs)
for i=0,n_elements(tags)-1 do outdataline[i]=strtrim(obs.(i),2)


spawn,'echo ''#'+strjoin(tags,';')+''' ' + '>' + outobs
spawn,'echo '''+strjoin(outdataline,';')+''' ' + '>>' + outobs

obs.id=   3
obs.Observat='SoHO'
obs.Instrument='EIT'
obs.Telescope='EIT'
obs.Units='Counts'
obs.Wavemin=19.5
obs.Wavemax=obs.Wavemin
obs.wavename='Fe XII'
obs.waveunit='nm'
obs.Spectral_name='Extreme Ultraviolet'
obs.Obs_type='Remote-sensing'
obs.Comment='12-min fd'


outdataline=strarr(n_elements(tag_names(obs)))
tags=tag_names(obs)
for i=0,n_elements(tags)-1 do outdataline[i]=strtrim(obs.(i),2)


spawn,'echo '''+strjoin(outdataline,';')+''' ' + '>>' + outobs
 
end


;======================================================================================================
;======================================================================================================


pro charm_struct2heliodb_allinone,struct_filename=struct_filename,save_path=save_path, $
                         eit_num=eit_num,eit_file_obs=eit_file_obs,eit_insearch=eit_insearch,eit_check_num=eit_check_num, eit_data_dir=eitpath,eit_save_path=eit_save_path, $ ;EIT inputs
                         mdi_num=mdi_num,mdi_file_obs=mdi_file_obs,mdi_insearch=mdi_insearch,mdi_check_num=mdi_check_num, mdi_data_dir=mdipath,mdi_save_path=mdi_save_path, $ ;MDI inputs
                         file_grp=file_grp,grp_nst=grp_nst,group_check_num=group_check, $;GR inputs
                         file_chs=file_chs,chs_nst=chs_nst,chs_check_num=chs_check, $;CH inputs
                         solarmonitor=solarmonitor,web_path=web_path,sm_archive=sm_archive

;;TODO: add area in Mm (Lar has added to the structures).


;+
;-


;; General properties
  if not keyword_set(save_path) then save_path='./'
  if not keyword_set(web_path) then web_path=save_path


;; Reading structure sav file
  if not keyword_set(struct_filename) then begin
     print,'Needed file!'
     ;TODO: allow to ask for a file..
  endif
  restore,struct_filename

if s_f.mdi_filename_date eq '' then begin
   print,'************ '+ struct_filename

   goto,fin
endif
;; EIT FILE NUMBERING AND OUTPUT
  obs_table,inst='eit',fits_file=s_f.euv_filename,orig_file=s_f.euv_filename,file_num=eit_num,file_obs=eit_file_obs,infile_search=eit_insearch,check_num=eit_check_num,save_path=eit_save_path,pathinstr=eitpath
;; MDI FILE NUMBERING AND OUTPUT
  obs_table,inst='mdi',fits_file=s_f.mdi_filename_date,orig_file=s_f.mdi_filename_nodate,file_num=mdi_num,file_obs=mdi_file_obs,infile_search=mdi_insearch,check_num=mdi_check_num,save_path=mdi_save_path,pathinstr=mdipath

;; Group numbering and output
  grp_table,grp_str=s_gr,file_grp=file_grp,grp_nst=grp_nst,grp_num=grp_num,save_path=save_path,check_num=group_check,file_str=s_f

;; CHs numbering and output
  chs_table,ch_str=s_ch,file_chs=file_chs,chs_nst=chs_nst,grp_num=grp_num,eit_file=eit_num,mdi_file=mdi_num,file_str=s_f,save_path=save_path,check_num=chs_check

;; Create files for solar monitor
 if keyword_set(solarmonitor) then grp_webtable,grp_str=s_gr,file_str=s_f,web_path=web_path


;; Rest of program...

eit_num+=1l
mdi_num+=1l  ;unless file from other source used.
fin:
end


;; for i=0,n_elements(files)-1 do begin &$
;;     restore,files[i] &$
;;     grp_webtable,grp_str=s_gr,file_str=s_f,web_path='~/tmp/web/' &$
;; endfor
