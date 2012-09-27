function ch_thresh_hd1, time2, tmpdir, im_num
;The fits files are obtained from the hard-drive.
;Lambert_map size updated. (L. Krista/TCD 13 Apr 2010)
;time2: start of good MDI files (EIT files are only mached within +- half day of this time)	

	instru3='SOHO EIT'
	s1_seit=4 												;median filter width - this filter is applied at the start to get rid of hot/dead pixels
	s2_seit=12
	chthresh=-1
	numcs=0.
	c_med=-1.
	
	f1=strmid(tmpdir,0,4)
	f4=strmid(tmpdir,4,2)

	eit_fls=findfile('$Home/Volumes/SOHO_EIT/EIT/lz/'+f1+'/'+f4+'/ef*')		
	eit_files_=fff(eit_fls,anytim(anytim(time2)-43199.,/ATIME), anytim(anytim(time2)+43199.,/ATIME))	;thresholds can be found from +- half day from mdi image obs. time		
	eit_filenum=size(eit_files_)	;Off
	
	henry=-1.
	
	for yaho=0, n_elements(eit_files_)-1 do begin								  
		
		eit_head=headfits(eit_files_[yaho])
		eit_object=sxpar(eit_head,'OBJECT')	
		eit_size=sxpar(eit_head,'NAXIS1')	
		wavelen=sxpar(eit_head,'WAVELNTH')
																										
		if wavelen eq '195' and eit_size eq 1024.000 and eit_object eq 'full FOV' then begin									
			if henry[0] eq -1. then begin
				print, 'Decent EIT image found.'
				henry=yaho 
			endif else begin
				henry=[henry,yaho]	;noting which EIT images are 'good'																																
			endelse
		endif
	
	endfor		

	if henry[0] ne -1 then begin
	
		for ya=0, n_elements(henry)-1 do begin		;On/all elements
	
			goo=henry[ya]
	
			if numcs lt im_num then begin
	
				eit_prep,'/Volumes/SOHO_EIT/EIT/lz/1996/04/efz19960424.152212',hh,dd 	;Black magic! Leave it, otherwise eit_prep screws up in loop! (check out mean(im) in a loop and outside loop)
				
				eit_prep,eit_files_[goo],eit_head,im		;prepping the file closest to the start time

				eit_prep,'/Volumes/SOHO_EIT/EIT/lz/1996/04/efz19960424.152212',hh,dd	;Black magic! Leave it, otherwise eit_prep screws up in loop! 

				index2map,eit_head,im,eit_map	
				
				print, 'Thresh EIT time: ', eit_map.time
				
				time_=STRMID(eit_map.time, 0,17)									
				sizem=size(eit_map.data)
											
				;Getting the EIT image
				eit_map_rot = rot_map( eit_map, eit_map.roll_angle ) ;correcting for the roll-angle
				;eit_drot=drot_map(eit_map_rot,time=t_cent)													
				eitmasked=eit_map_rot.data

				solarr=sxpar(eit_head, 'SOLAR_R')
				hcrpix1=sxpar(eit_head, 'CRPIX1')
				kcrpix2=sxpar(eit_head, 'CRPIX2')
				maxval=round(max(eitmasked))+1000.	;1000 is added to nicely separate the on-disk values from the value the off-disk is set to

				;off-disk corners due to B_0 angle variation is excluded:
				for ri=0, sizem[1]-1 do begin
					for pi=0, sizem[2]-1 do begin
						if ((ri - hcrpix1)^2 + (pi - kcrpix2)^2) gt solarr^2 then eitmasked[ri,pi]=maxval		
					endfor
				endfor
								
				eit_plane=lambert_project(eitmasked,[eit_map.xc,eit_map.yc],eit_map.dx,date=eit_map.time) 

				sizep=size(eit_plane)
				
				c=thresh_f(instru3, s1_seit, s2_seit, eit_plane, maxval, eit_map.time, tmpdir)

				print, "C:", c
			
				if c ne -1 then begin
					if numcs eq 0. then chthresh=c else chthresh=[chthresh,c]
					numcs=numcs+1.
				endif	
			endif
		endfor
		
		zsazsa=[0,chthresh]
		c_hist=histogram(zsazsa)
		c_med=where(c_hist eq max(c_hist))
	
		if n_elements(c_med) gt 1 then begin
			ind = WHERE(c_med, count)  				
			c_=fltarr(n_elements(ind))
			IF count NE 0 THEN c_=c_med[ind]
			c_med=median(c_,/even)
		endif

	print, "Thresh:", chthresh
	print, "Final thresh:", c_med

	endif
	
return, c_med

end