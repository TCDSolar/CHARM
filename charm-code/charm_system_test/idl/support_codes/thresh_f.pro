function thresh_f, instru, s1, s2, plane, maxval, time, tmpdir
;"Fast" - and shorter version.
;Correction: input is plane not eit_map.data. Added input: time  (L. Krista 4 Jan 2010)
;Correction: multiple max threshold: use median (excluding 0s)  (L. Krista 8 Apr 2010)

	lo_thr=0.3											;lowest intesnsity limit (0.3 -> 30% of mode intensity ) 
	hi_thr=0.7											;upper intensity limit (0.7 -> 70% of mode intensity )	

	ss1=arr2str(s1)
	ss1=strtrim(ss1,2)
	ss2=arr2str(s2)
	ss2=strtrim(ss2,2)
	datadir='Users/ldkrista/idl/0bin/forecast0/RESULTS/'+tmpdir+'/0data'
	plotdir='Users/ldkrista/idl/0bin/forecast0/RESULTS/'+tmpdir+'/plots'

	!p.multi=0

	dipmin=fltarr(1)		;threshold values are to be stored in this array			
	
	sizep=size(plane)
		
	sm_plane = MEDIAN ( plane , s1)					;for histogram analysis
	sm_plane2 = MEDIAN ( plane , s2)					;for histogram analysis
	
	plane1=plane(where(strtrim(plane,2) ne maxval)) ;only feeding in disk data for thresholding (off-disk corners due to B_0 angle variation is excluded)
 	
	chp=histogram (plane1, loc=crx)				;we use 'loc' to have the right value locations for plotting purposes (basically corrects the offset of the default histogram, which would start with the first lowest value in the histogram)
	chp_off=min(plane1)							;shift of the histogram (histogram starts with lowest value, not 0)
	chpmax=where(chp eq max(chp))
		
	if n_elements(chpmax) ne 1 then chpmax=mean(chpmax)
		
	adj_chpmax=chpmax+chp_off		;the adjusted intensity value of the histogram mode (this value will be similar to the values obtained from other days)			
	
	c=-1.

	if adj_chpmax lt 1000. then begin

		lolim=lo_thr*adj_chpmax	;wider range specified
		uplim=hi_thr*adj_chpmax	
	
		;------Local histogram analysis:--------
		
		FOR k=1, 5 do begin									;k determines how many parts the image is devided into. Total number of image-parts (including overlaying parts): k^2+(k-1)*k*2
															;k^2 is the initial number of parts the image is devided into, (k-1)*k is 
															;the overaying images in one direction, and /*2 is to include the other directon.			
					
			;Here we start to examine parts of the Carr. map:
			m=2*k-2 										;number of parts in one row (k:initial no. of boxes + k-2 overlapping boxes)
		
			for j=0, m do begin 						;going through rows (starting from the bottom of the image)
	
				for i=0, m do begin
			
					if j EQ m or i EQ m then p=1 else p=0 	;this is necessary for the end of the loops
			
					jj=arr2str(j)   						;for the titles...				
					jj=strtrim(jj,2)						;for the titles...
			
					a1=i*(sizep[1]/(2*k))					;row 'from'
					a2=(i+2)*(sizep[1]/(2*k))-p				;row 'to'
					b1=(j)*(sizep[2]/(2*k))				;coloumn 'from'
					b2=(j+2)*(sizep[2]/(2*k))-p 					;coloumn 'to'		
	
					;print, 'Box:', a1, a2, b1, b2 			;Note: coordinate (0,0) is the lower left corner!
					picpart=plane(a1:a2,b1:b2) 	;coordinates of box, b2>b1 ->has to go from big to small		
					hp=histogram (picpart,loc=px)			;we use 'loc' to have the right value locations for plotting purposes (basically corrects the offset of the default histogram, which would start with the first lowest value in the histogram)
					hp_off=min(picpart)	
;eit_colors,'195'
;!p.multi=[0,2,1]
;plot_image, picpart, min=-100, max=300
;plot, px, hp, xrange=[0,30]
;verline, lolim
;verline, uplim
					
					;Finding the dip:			
						
					hp_nu=n_elements(hp)
					
					if hp_nu ge 3 then begin
						
						hp_v=smooth(hp,3)
						
						start_nu=lolim[0]-hp_off
						end_nu=uplim[0]-hp_off				
						if start_nu lt 4. then start_nu=4
					
						for nu=start_nu, end_nu do begin		;Here we examine the local histogram to find troughs and their minima
																;we only examine the local histogram at lower values than the mode of the total Carr. map histogram. (Because the CH is definitely of lower intensity than the quiet Sun or ARs.)
							IF hp[nu-3] GE hp[nu-2] and $		;Here we try to find a 'clean' dip, which means that the the dip value has to be lower or equal to 4 the values on each of its side.
							hp[nu-2] GE hp[nu-1] and $
							hp[nu-1] GE hp[nu] and $
							hp[nu-4] GT hp[nu] and $			;Making sure we do not mistake a flat part of the histogram for a dip. The 4th value on each side must be greater than the dip minimum value.
							hp[nu] LE hp[nu+1] and $ 
							hp[nu+1] LE hp[nu+2] and $
							hp[nu+2] LE hp[nu+3] and $
							hp[nu+3] LE hp[nu+4] and $
							hp[nu] LT hp[nu+4] THEN BEGIN
							if hp[nu] LT 50. then goto, jump1	;avoiding dips values of near 0 counts
							real_nu=nu+hp_off					;correcting the intensity value with the histogram offset value			
							dipmin=[dipmin,real_nu]				;storing the minima (-> possible CH boundary intensity), this value is already corrected with the offset value
							jump1:
							ENDIF
						
							IF hp_v[nu-3] GE hp_v[nu-2] and $
							hp_v[nu-2] GE hp_v[nu-1] and $
							hp_v[nu-1] GE hp_v[nu] and $
							hp_v[nu-3] GT hp_v[nu] and $
							hp_v[nu] LE hp_v[nu+1] and $ 
							hp_v[nu+1] LE hp_v[nu+2] and $
							hp_v[nu+2] LE hp_v[nu+3] and $
							hp_v[nu] LT hp_v[nu+3] and $
							hp_v[nu] LT hp_v[nu+4] THEN BEGIN
							if hp_v[nu] LT 50 then goto, jump2	;avoiding dip values of near 0 counts
							real_nu=nu+hp_off					;correcting the intensity value with the histogram offset value
							dipmin=[dipmin,real_nu]				;storing the minima (-> possible CH boundary intensity), this value is already corrected with the offset value
							jump2:
							ENDIF
							
						endfor
					
					endif
;print, dipmin					
;stop										
				endfor
	
			endfor	
	
		ENDFOR		

		;----Final part----

		if n_elements(dipmin) eq 1 then c=-1
	
		if n_elements(dipmin) ne 1 then begin  				;if no minima were found, we got to the next image					
	
			hmina=histogram(dipmin)
			
			if max(hmina) eq 0.0 then c=-1	
			if max(hmina) eq 0.0 then print, 'Frequency of minima: 0.'
			if max(hmina) eq 0.0 then goto, jump4			;if there are still no results, we jump to the next image
			c0=where(hmina eq max(hmina))  					;we find the most frequent min value = CH intensity threshold (ideally there would be one most frequent min value, but if not:)
						
			if n_elements(c0) gt 1 then begin
				ind = WHERE(c0, count)  				
				c_=fltarr(n_elements(ind))
				IF count NE 0 THEN c_=c0[ind]
				c0=median(c_,/even)
			endif
			
			;if n_elements(c) gt 1 then begin
			;	print, "Threshold ambiguity! Skipping!" 
			;	c=-1 
			;	goto, jump5
			;endif
			
			;index_ = WHERE(c0[*], count)  				;getting rid of 0-s (spechs are the 'good' CHs: positioned away from the poles and with large enough skewness)
			;c=fltarr(n_elements(index_))
			;if count ne 0 then c[*] = c0[index_]
			;if count ne 0 then c=median(c)									;in cases when there are equally frequent min values, take the median)
			
			c=round(c0)
			
			perc=c/adj_chpmax
	
			perc=arr2str(perc)
			perc=strtrim(perc,2)			
			cc=arr2str(c)
			cc=strtrim(cc,2)			
			a_max=arr2str(adj_chpmax)
			a_max=strtrim(adj_chpmax,2)
			
			openw, 7, filepath(time2file(time)+'_thresh.dat', root_dir='$Home',subdir=datadir), width=256, /append	;get info on the minima
			;if pa eq 0. then printf, 7, 'Date', ', ', 'Threshold', ', ', 'Tot hist max', ', ', 'Percent', ', 'Maxval'
			printf, 7, anytim(time,/vms) , '; ', cc, '; ',  string(a_max,format='(F5.2)'), '; ', string(perc,format='(F5.2)'), '; ', maxval
			close,7	
			
			;hm_arr=fltarr(1)
			;for c4=0, n_elements(hm)-1 do begin				
			;	if hm[c4] NE 0.0 then begin				
			;		if hm_arr eq 0.0 then hm_arr=hm[c4] else hm_arr=[hm_arr, hm[c4]]	;creating an array with non-zero, equally frequent min values
			;	endif
			;endfor		
			;mn=(total(hm_arr)-max(hm_arr))/(n_elements(hm_arr)-1)		;mean of the non-max points
			;peak_pc=100*mn/max(hm_arr)									;percentage of the (mean of non-max points) to the max value		
			;peak_pc_=arr2str(peak_pc)
			;peak_pc_=strtrim(peak_pc_,2)
			
			window,0
			!p.background = 255
			!p.color = 0   
			!p.charsize = 2
			ll=lindgen(2.0*max(hp))	
			lobord=0*ll+lolim[0]	 ;displaying the range within which we are looking for the local min
			upbord=0*ll+uplim[0]
			plot, hmina, psym=10, title='Thresh. histogram '+ strmid(time,0,17), xrange=[0,80], yrange=[0,30], subtitle='Threshold:'+cc+'   
			oplot, lobord,ll, color=2, thick=2, linestyle=2	;the plotted range is the narrow one unless a wide one was needed
			oplot, upbord,ll, color=2, thick=2, linestyle=2
			x2JPEG, filepath(time2file(time)+'_thrhist_.jpg',root_dir='$Home',subdir=plotdir)
					
		endif		
		;jump5:
		jump4:
	
	endif
;stop
return, c

end