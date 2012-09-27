pro ch_finder24_hd ;, time1
;THIS IS THE MAIN CODE.
;The fits files are obtained from the hard-drive.
;Lambert_map size updated. (L. Krista/TCD 13 Apr 2010)

ch_dates=['18-feb-1997']	;this is the analysis start-date

start_n_ch=13				;number of CHs to be analysed in one Lambert map
n_days=1.					;number of days to be analysed ffrom start-date

mdihd='LARA_WORK' ;'SOHO_EIT'	;choose hard-drive to work from 

for ihaj=0, n_elements(ch_dates)-1 do begin	

	time=ch_dates[ihaj]
	c=-1.

	instru1='STEREO_A'
	instru2='STEREO_B'
	instru3='SOHO EIT'
	s1_secchi=6 												;median filter width - this filter is applied at the start to get rid of hot/dead pixels
	s2_secchi=20												;smoothing before applying the contours in the final plot
	s1_seit=4 												;median filter width - this filter is applied at the start to get rid of hot/dead pixels
	s2_seit=12
	minarea_secchi=400											;minimum area that defines a CH
	minarea_seit=100											;minimum area that defines a CH;smoothing before applying the contours in the final plot
	grow_factor=1.2									;region-growing factor (1.1 -> 10% growth)
	wavelength='195 Angstrom'
	mdi_go=0.

	fov=40
	center=[0,0]
	times=strarr(n_days)
	for ds=0, n_days-1 do begin
		times[ds]=anytim(anytim(time)+ds*86400.,/ATIME)
	endfor
	;ds=1.
	etims=fltarr(1)
	
	for lp=0, n_days-1 do begin
	
		time1=times[lp]

		tmpdir = STRMID(time2file(time1), 0,8)
		crcmd = 'mkdir ' + ' ~/IDL/0bin/forecast0/HELIO' + ' ~/IDL/0bin/forecast0/HELIO/SAV' + ' ~/IDL/0bin/forecast0/HELIO/PLOTS' + ' ~/IDL/0bin/forecast0/RESULTS/'+' ~/IDL/0bin/forecast0/RESULTS/'+tmpdir+' ~/IDL/0bin/forecast0/RESULTS/' + tmpdir + '/0data'+ ' ~/IDL/0bin/forecast0/RESULTS/' + tmpdir +'/plots'
		spawn, crcmd
		datadir='Users/ldkrista/idl/0bin/forecast0/RESULTS/'+tmpdir+'/0data'
		plotdir='Users/ldkrista/idl/0bin/forecast0/RESULTS/'+tmpdir+'/plots'
	
		m_start=anytim(anytim(time1),/ATIME)
		m_end=anytim(anytim(time1)+86399.,/ATIME)
		
		if mdihd eq 'LARA_WORK' then begin
			mdate=strmid(time2file(anytim(m_start, /atime)), 0,6)
			mdifiles=findfile('$Home/Volumes/LARA_WORK/MDI/mdi_mag2/smdi*'+mdate+'*.fits.gz')
			mdimags=fff(mdifiles,m_start,m_end)
		endif else begin	
			mdimags=mdi_time2file(m_start, m_end ,/stanford)
		endelse

		igenis=0.
		no_ch=0.
		no_mch=0.
		ja=0.
		ma=0.
		na=0.
		
		for mdf=0, n_elements(mdimags)-1 do begin
		
			if igenis eq 0. and no_mch lt 5 then begin	;igenis=1 -> one good CH map has been created, can move on to the next day! If repeatedly no CHs are found (no_mch) using 4 consecutive magnetogram times, then move to next day
			
				print, 'MDF: ', mdf
				f1=strmid(tmpdir,0,4)
					
				if mdihd eq 'LARA_WORK' then begin					
					mdi_fl=mdimags[mdf]
				endif else begin
					if strmid(mdimags[mdf], 0,4) ne 'http' then mdi_go=1.
					mdi_fil = reverse( strsplit( mdimags[mdf], '/', /ext ) )	
					mdi_fil = mdi_file[ 0 ]
					f2=strmid(mdi_fil,0,13)
					f3=strmid(mdi_fil,13,4)
					mdidir='$Home/Volumes/SOHO_EIT/MDI/fd_M_96m_01d_'+f1+'/'+f2+'00'+f3+'/' 
					mdi_fl=findfile(mdidir+mdi_fil)	
				endelse
					
				if mdi_go eq 0. then begin
				
					if mdi_fl eq '' then print, 'No MDI files.'
					if mdi_fl ne '' then begin	
					
						fits2map, mdi_fl, mdi_map, header=mdi_header
					
						t_int=sxpar(mdi_header,'INTERVAL') ;integration time
						if mdihd eq 'LARA_WORK' then mdi_file=sxpar(mdi_header,'DATAFILE') ;integration time
						
						ti=arr2str((t_int)/60.)
						
						if ti ne 5. then print, "MDI file not 5min."
						if ti eq 5. then begin ;making sure the magnetograms are all the same type (5 minute integrated images are less noisy than the half minute ones, so the 5min images are used)
	
							start_d=strmid( mdi_map.time, 0,11)
							start_t=strmid( mdi_map.time, 12,8)
							starttime=start_d+' '+start_t
							starttime_e=anytim(anytim(starttime)-2880.,/ATIME) 		;MDI is every 96mins, so +/-48mins to find the closest in time
							endtime=anytim(anytim(starttime)+2880.,/ATIME)
							f4=strmid(tmpdir,4,2)
							
							eit_fls=findfile('$Home/Volumes/SOHO_EIT/EIT/lz/'+f1+'/'+f4+'/ef*')	;Off
							eit_files=fff(eit_fls,starttime_e,endtime)		;Off
							eit_filenum=size(eit_files)	;Off
		
							if eit_filenum[0] eq 0 then print, 'No EIT files.'
							if eit_filenum[0] ne 0 then begin	;Off
								
								henry=-1.
								ha=0.
								
								;making sure (before threshlding) that there is at least one "good" EIT image within +- 30 min of the MDI file 
								for yaho=0, n_elements(eit_files)-1 do begin								  
									
									eit_header=headfits(eit_files[yaho])
									eit_object=sxpar(eit_header,'OBJECT')	
									eit_size=sxpar(eit_header,'NAXIS1')	
									wavelen=sxpar(eit_header,'WAVELNTH')
																																	
									if wavelen eq '195' and eit_size eq 1024.000 and eit_object eq 'full FOV' then begin									
										if henry[0] eq -1. then begin
											print, 'Decent EIT image found.'
											henry=yaho 
										endif else begin
											henry=[henry,yaho]	;noting which EIT images are 'good'																																
										endelse
									endif
								
								endfor	
						
								;Thresholding:		

								if henry[0] ne -1. then c=ch_thresh_hd1(mdi_map.time, tmpdir, 5)	;thresholds are found from the date_obs until (mdi_map.time+1day) using only 'good' EIT images
								if henry[0] eq -1. then print, 'No decent EIT images within 30min of MDI observation.'
								
								if c ne -1 and henry[0] ne -1. then begin
								
									for zsa=0, n_elements(henry)-1 do begin	;we go through the EIT files within the time-range of the MDI file and find the closest 'good' image in time (faulty images excluded and those with no CHs)	

										zsazsa=henry[zsa]	;only going throught the 'good' EIT files
										
										if igenis eq 0. and no_ch lt 4 then begin ;igenis=1 -> one good CH map has been created, can move on to the next day! If repeatedly no CHs are found (no_ch) using 3 consecutive eit times, then move to next day
											
											eit_prep,eit_files[zsazsa],eit_header,da		;prepping the file closest to the start time

											date_obs=sxpar(eit_header,'DATE-OBS')
											eit_flnm=sxpar(eit_header,'FILENAME')											
															
											index2map,eit_header,da,eit_map	
											
											sizem=size(eit_map.data)
											
											print, 'MAIN MDI TIME', anytim(starttime,/atime)
											print, 'MAIN EIT TIME', eit_map.time
										
											time_=STRMID(eit_map.time, 0,17)
											date=time2file(eit_map.time)																				

											ts=anytim(eit_map.time)
											
											filnam1=tmpdir + '_thresh.dat'
											openw, 1, filepath( filnam1, root_dir='$Home',subdir=datadir), width=1000., /append
											if ja eq 0. then printf, 1, '#Time','; ', 'thresh'
											printf, 1, anytim(ts,/vms), '; ' , fix(c)
											close, 1
											ja=1.
	
											st1=strmid(systime(),4,3)
											st2=strmid(systime(),8,2)
											st3=strmid(systime(),11,8)
											st4=strmid(systime(),22,2)
											st=st2+'-'+st1+'-'+st4+' '+st3
											mdi_file_date=reverse( strsplit( mdimags[mdf], '/', /ext ) )
											
											s_f=create_struct('MDI_FILENAME_DATE' ,mdi_file_date[0], 'MDI_FILENAME_NODATE' ,mdi_file, 'EIT_FILENAME', eit_flnm, 'DATE_OBS', eit_map.time, 'RUN_DATE', st, 'CH_FILENAME', 'chgr_'+date+'.png')
																					
											solar_r=sxpar(eit_header, 'SOLAR_R')
											crpix1=sxpar(eit_header, 'CRPIX1')
											crpix2=sxpar(eit_header, 'CRPIX2')

											;Getting the EIT image
											eit_map_rot = rot_map( eit_map, eit_map.roll_angle ) 	
											eitmasked=eit_map_rot.data
											for i=0, sizem[1]-1 do begin
												for j=0, sizem[2]-1 do begin
													if ((i - crpix1)^2 + (j - crpix2)^2) gt solar_r^2 then eitmasked[i,j]=1000.
												endfor
											endfor
										
											eit_plane=lambert_project(eitmasked,[eit_map.xc,eit_map.yc],eit_map.dx,date=eit_map.time) 
											
											sizep=size(eit_plane)
										
											;Getting the MDI image
											mdi_map_rot = rot_map( mdi_map, mdi_map.roll_angle )
											mdi_drot=drot_map(mdi_map_rot,time=eit_map.time)		;diff-rotating the magnetogram to the time of the eit map		
											sun_mdi=lambert_project(mdi_drot.data,[mdi_map_rot.xc,mdi_map_rot.yc],mdi_map_rot.dx,date=mdi_map_rot.time)		;Lambert equal-area projection
											congr_mdi=congrid(sun_mdi,sizep[1], sizep[2],/INTERP)	;resizing magnetogram so it is the same size as the eit map
			
											framed=median(eit_plane,s2_seit)
											maxval=round(max(eitmasked))+1000.
							
											for gg=0, sizep[1]-1 do begin	;detaching image from the "frame" or image edge, so polar CHs are detached
												for hh=0, sizep[2]-1 do begin
													if gg LT 2 then framed[gg,hh]=maxval
													if gg GT sizep[1]-3 then framed[gg,hh]=maxval
													if hh LT 2 then framed[gg,hh]=maxval
													if hh GT sizep[2]-3 then framed[gg,hh]=maxval	
												endfor
											endfor									
											
											if n_elements(where(framed lt str2arr(c))) ne 1 then framed(where(framed lt str2arr(c)))=c-1.
											contour, alog(framed), level=alog(c), path_info = path_info, path_xy = path_xy, /path_data_coords
											
											window,0, xsize=1200, ysize=800			
											eit_colors, '195'
											!p.multi = [ 0, 2, 2 ] 
											!p.background = 255
											!p.color = 0   
											!p.charthick=1
											!p.charsize = 2
											plot_image, alog(eit_plane), min=1, max=7, title='EIT '+time_, xtitle="Longitude (degrees)", ytitle="Latitude (degrees)",xticks=4, xtickname=['-80','-40','0','40','80'], yticks=4, ytickname=['-80','-30','0','30','80'] ; lambert_project.pro limits projection too +/- 80 deg lat and long.
											contour, alog(framed), level=alog(c), /over, c_color=255, thick=1

											x2jpeg,  filepath(date+'_chmap.jpg',root_dir='$Home',subdir=plotdir) ;image is saved even if faulty, for record
											
											loadct, 12, ncolors=20	
											
											;if question1() eq -1 then stop			
											
											n_ch=start_n_ch	
											if n_ch ge n_elements(path_info) then n_ch=n_elements(path_info)
											
											;plotting the large enough CHs
											for pr = 1, n_ch-1 do begin 
												px=path_xy[ 0, path_info[pr].offset : path_info[pr].offset+path_info[pr].n-1 ]
												py=path_xy[ 1, path_info[pr].offset : path_info[pr].offset+path_info[pr].n-1 ]
												object_ch = Obj_New('IDLanROI', px, py)
												bla=object_ch->ComputeGeometry(AREA=area)
												if area GT minarea_seit then begin
													plots, px, py, color=5, thick=2		
													plx=min(px)
													ply=max(py)
													if min(px) gt sizep[1]-30 then plx=plx-40
													if max(py) gt sizep[2]-30 then ply=ply-40
													prr=arr2str(round(pr))
													prr=strtrim(prr,2)
													XYOUTS, plx, ply, [prr], charsize=1.5, charthick=1, color=11	
												endif
											endfor
				
											plot_image, alog(eit_plane), min=1, max=7, title='EIT '+time_, xtitle="Longitude (degrees)", ytitle="Latitude (degrees)",xticks=4, xtickname=['-80','-40','0','40','80'], yticks=4, ytickname=['-80','-30','0','30','80'] ; lambert_project.pro limits projection too +/- 80 deg lat and long.
											contour, alog(framed), level=alog(c), /over, c_color=255, thick=1	
											
											chs=fltarr(1)						;storing only the number of the selected CHs (in the ROI box) for the grouping method
											chs_a=fltarr(1)
											chs_b=fltarr(1)
											ik=0.
											
											;***Selecting the right CHs***
											
											for pr = 1, n_ch-1 do begin 															
												if path_info[pr].high_low eq 0 then begin				;excluding contoured regions withing CHs (bright spots etc.)
						
													px=path_xy[ 0, path_info[pr].offset : path_info[pr].offset+path_info[pr].n-1 ]
													py=path_xy[ 1, path_info[pr].offset : path_info[pr].offset+path_info[pr].n-1 ]
																															
													px=round(px)
													py=round(py)	
																		
													westbo=max(px)
													eastbo=min(px)
													northbo=max(py)
													southbo=min(py)
																			
													eastbo_coo=( (eastbo-sizep[1]/2.0)*(160.0/sizep[1]) )
													westbo_coo=( (westbo-sizep[1]/2.0)*(160.0/sizep[1]) )		
													northbo_coo=round( (180./!pi) * asin( ( northbo/(sizep[2]/2.0) - 1.) * ( sin(80.*!DTOR ) ) ) )
													southbo_coo=round( (180./!pi) * asin( ( southbo/(sizep[2]/2.0) - 1.) * ( sin(80.*!DTOR ) ) ) )											
													long_width=westbo_coo-eastbo_coo
													lat_width=northbo_coo-southbo_coo
													
													object_ch = Obj_New('IDLanROI', px, py)
													bla=object_ch->ComputeGeometry(AREA=area, CENTROID=chcr)
													
													if area LT minarea_seit	and area GT (sizep[1]*sizep[2])/2. then print, 'CH too small or too large!'
													if area GT minarea_seit and area LT (sizep[1]*sizep[2])/2. then begin	
														
														object = Obj_New('IDLanROI', px, py)
								
														area1=0L
														b_sum=0L
														i_sum=0L
														mdi_pix=fltarr(1)
														mdi_rad=fltarr(1)
														i_min=eit_plane[0,0]
														i_max=eit_plane[0,0]
						
														for y = min(py), max(py) do begin
															for x = min(px), max(px) do begin
																if object->ContainsPoints(x, y) eq 1 or object->ContainsPoints(x, y) eq 2 or object->ContainsPoints(x, y) eq 3 then begin													
																	;b_sum=b_sum+congr_mdi[x ,y]
																	i_sum=i_sum+eit_plane[x ,y]
																	if eit_plane[x ,y] lt i_min then i_min=eit_plane[x,y]
																	if eit_plane[x ,y] gt i_max then i_max=eit_plane[x,y]
																	if area1 eq 0. then mdi_pix=congr_mdi[x ,y] else mdi_pix=[mdi_pix,congr_mdi[x ,y]]	
																	alpha=(round( (180./!pi) * asin( (y/(sizep[2]/2.0) - 1.) * ( sin(80.*!DTOR ) ) ) ))
																	if area1 eq 0. then mdi_rad=(congr_mdi[x ,y])/cos(!DTOR*alpha) else mdi_rad=[mdi_rad,congr_mdi[x ,y]/cos(!DTOR*alpha)]	
																	area1=area1+1.
																endif
															endfor
														endfor

														i_mean=((i_sum/area)*10.)/10.
														i_mean=arr2str(i_mean)   				
														i_mean=strtrim(i_mean,2)
														
														if i_mean gt 1 then begin ;excluding missing blocks
														
															Br_mean=(round(mean(mdi_rad)*10.))/10.
															Br_mean=arr2str(Br_mean)   				
															Br_mean=strtrim(Br_mean,2)														
														
															sk=(round(skewness(mdi_rad)*100.))/100.
															skew=arr2str(sk)   				
															skew=strtrim(skew,2)
									
															Bz_mean=(round(mean(mdi_pix)*10.))/10.
															Bz_mean=arr2str(Bz_mean)   				
															Bz_mean=strtrim(Bz_mean,2)
															
															area1=arr2str(area1)   				
															area1=strtrim(area1,2)
															
															openw, 9, filepath(tmpdir+'_ch_all.dat', root_dir='$Home', subdir=datadir),  width=256, /append
															if na eq 0. then printf, 9, '#Time','; ', 'CH_num','; ', 'Bz_mean','; ', 'Br_mean','; ', 'B_skew','; ', 'CH_area','; ', 'long_width','; ', 'lat_width','; ', 'eastbo_coo','; ', 'westbo_coo','; ', 'northbo_coo','; ', 'southbo_coo'
															printf, 9, anytim(ts,/vms), '; ', pr, '; ', string(Bz_mean,format='(F6.2)'), '; ', string(Br_mean,format='(F6.2)'),'; ', string(skew,format='(F6.2)'), '; ', string(area1,format='(F8.2)'),'; ', round(long_width),'; ', round(lat_width),'; ', round(eastbo_coo),'; ', round(westbo_coo),'; ', round(northbo_coo),'; ', round(southbo_coo)
															close,9	
															na=1.
															
															if abs(skew) LE 0.5 then print, 'SKewness too small!'
															if abs(skew) GT 0.5 then begin
																
																;plotting CHs with large enough area and skewed B_r
																plots, px, py, color=5, thick=2
																flx=min(px)
																fly=max(py)
																if min(px) gt sizep[1]-30 then flx=flx-40
																if max(py) gt sizep[2]-30 then fly=fly-40
																prr=arr2str(round(pr))
																prr=strtrim(prr,2)
																XYOUTS, flx, fly, [prr], charsize=2, charthick=2, color=11
																													
																if ik eq 0. then chs[ik]=pr else chs=[chs,pr]
																if ik eq 0. then chs_a[ik]=area1 else chs_a=[chs_a,area1]	
																if ik eq 0. then chs_b[ik]=Bz_mean else chs_b=[chs_b,Bz_mean]
																ik=ik+1.	
																	
																openw, 8, filepath(tmpdir+'_ch_select.dat', root_dir='$Home', subdir=datadir), width=256, /append
																if ma eq 0. then printf, 8, '#Time',' ; ', 'CH_num','; ', 'Bz_mean','; ', 'Br_mean','; ', 'B_skew','; ', 'CH_area','; ', 'long_width','; ', 'lat_width','; ', 'eastbo_coo','; ', 'westbo_coo','; ', 'northbo_coo','; ', 'southbo_coo'
																printf, 8, anytim(ts,/vms), '; ', pr, '; ', string(Bz_mean,format='(F6.2)'),'; ', string(Br_mean,format='(F6.2)'),'; ', string(skew,format='(F6.2)'),'; ', string(area1,format='(F10.2)'),'; ', round(long_width),'; ', round(lat_width),'; ', round(eastbo_coo),'; ', round(westbo_coo),'; ', round(northbo_coo),'; ', round(southbo_coo)
																close,8	
																ma=1.
																
																;******
																n=path_info[pr].offset
																m=path_info[pr].offset+path_info[pr].n-1
																npath=contour_nogap([[round(path_xy[*,n:m])],[round(path_xy[*,n])]])			
																npath_ind=coord2ind(npath,[sizep[1],sizep[2]])
																npath_cc=egso_sfc_chain_code(npath_ind,sizep[1],sizep[2])
																out_cc=string(npath_cc,format='('+strtrim(n_elements(npath_cc),2)+'I1)')
																chain_length=n_elements(npath_cc)
																out_xy=string(npath[*,0],format='(I4.3,",",I4.3)')
		
																;Sort this out later to plot on disk images
																;xcoo_deg= (px-sizep[1]/2.0)*(160.0/sizep[1])
																;ycoo_deg= asin((py-sizep[2]/2.0)*(2.0/sizep[2]))*160.0/!pi
																;arc_coo=conv_h2a([xcoo_deg, ycoo_deg], eit_map.time)
																;pix = conv_a2p(arc_coo, eit_map.time, suncenter=[eit_map.xc,eit_map.yc], radius=eit_map.rsun, pix_size=eit_map.dx, roll=eit_map.roll_angle )
															
																object_ = Obj_New('IDLanROI', px, py)
																bla=object_->ComputeGeometry(CENTROID=chcr)			
																chcr_xcoo=round( (chcr[0]-sizep[1]/2.0)*(160.0/sizep[1]) )
																chcr_ycoo=round( asin((chcr[1]-sizep[2]/2.0)*(2.0/sizep[2]))*160.0/!pi )
																
																arctop=conv_h2a([westbo_coo, northbo_coo], eit_map.time)
																arcbottom=conv_h2a([eastbo_coo, southbo_coo], eit_map.time)
																arccent=conv_h2a([chcr_xcoo, chcr_ycoo], eit_map.time)
																
																rad=696000.0								;solar radius [km] 
																surface_km=1.75*rad^2*!pi					;visible surface! Instead of !pi we use (160.*!DTOR) as we havent a full 180 degree after the Lambert projection. (see calc. in notes)	
																surface_px=sizep[1]*sizep[2]
																area_km=(surface_km*area1)/surface_px		;Area in km^2 
																
																sch=create_struct('CH_NUM', prr, $
																'CHGR_NUM', 0, $	;atirva kesobb ch_sys-ben
																'THRESH', c, $
																'CH_BR_PIX', [eastbo, southbo, westbo, northbo], $
																'CH_BR_DEG', [eastbo_coo, southbo_coo, westbo_coo, northbo_coo], $
																'CH_BR_ARC', [arctop, arcbottom], $
																'CHC_PIX', [chcr_xcoo, chcr_ycoo], $
																'CHC_LATLON_DEG', [chcr_xcoo,chcr_ycoo], $
																'CHC_ARC', arccent, $
																'CH_LAT_WIDTH_DEG', long_width, $
																'CH_LON_WIDTH_DEG', lat_width, $
																'CH_LAT_WIDTH_ARC', arctop[1]-arcbottom[1], $
																'CH_LON_WIDTH_ARC', arctop[0]-arcbottom[0], $
																'CH_AREA_PIX', area1, $
																'CH_AREA_MM', area_km/1000., $
																'CH_MIN_INT', i_min, $
																'CH_MAX_INT', i_max, $
																'CH_MEAN_INT', i_mean, $
																'CH_MEAN2QSUN', i_mean/mean(eit_plane), $
																'CH_MIN_B_R', min(mdi_rad), $
																'CH_MAX_B_R', max(mdi_rad), $
																'CH_MEAN_B_R', Br_mean, $
																'CH_MIN_BZ', min(mdi_pix), $
																'CH_MAX_BZ', max(mdi_pix), $
																'CH_MEAN_BZ', Bz_mean, $
																'CH_BZ_SKEW', sk, $
																'ENC_MET', 'CHAIN CODE', $
																'CC_PIX_XY', out_xy, $
																'CHAIN_CODE', out_cc, $
																'CCODE_LENGTH',chain_length)
																
																if ik eq 1. then s_ch=sch else s_ch=[s_ch, sch] 
																;*******
																
															endif
														
														endif
					
													endif 
														
												endif	 
											
											endfor
											
											if ik eq 0. then no_ch=no_ch+1
											if ik eq 0. then no_mch=no_mch+1
										
											if ik ne 0. then begin	;if no CHs were found in image, go to next image.
												
												chs_ab=fltarr(3, n_elements(chs))
												chs_ab[0,*]=chs
												chs_ab[1,*]=chs_a
												chs_ab[2,*]=chs_b
											
												ch_sys29, eit_plane, framed, eit_map.time, c, chs_ab, s_f, s_ch
												
												igenis=1.0
											endif
											
										endif
									
									endfor
								endif
							endif
						endif
					endif
				endif
			endif
		endfor
		
	endfor

	
endfor
stop
end