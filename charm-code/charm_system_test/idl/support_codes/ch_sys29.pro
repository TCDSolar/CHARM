pro ch_sys29, image, framed_image, time_, c, chs_ab, s_f, s_ch
;Lambert_map size updated. (L. Krista/TCD 13 Apr 2010)

	spechs_=chs_ab[0,*]
	
	cc=arr2str(c)	
	sizep=size(image)
	num=0
	rad=696000.0								;solar radius [km] 
	time_f=time2file(time_)
	
	surface_km=1.75*rad^2*!pi				;visible surface! Instead of !pi we use (160.*!DTOR) as we havent a full 180 degree after the Lambert projection. (see calc. in notes)
	surface_px=sizep[1]*sizep[2]				;visible surface!

	contour, alog(framed_image), level=alog(c), path_info = path_info, path_xy = path_xy, /path_data_coords	
	;contour, alog(framed_image), level=alog(c), /over, c_color=255
	
	all_members=intarr(1)
	gr_elems=fltarr(1)			
	
	siz=size(image)
	tmpdir = STRMID(time_f, 0,8)
	plotdir='Users/ldkrista/idl/0bin/forecast0/RESULTS/'+tmpdir+'/plots'
	datadir='Users/ldkrista/idl/0bin/forecast0/RESULTS/'+tmpdir+'/0data'
	
	;Distance based pairing of CHs (actual groups asigned later)
	
	for yok=0, n_elements(spechs_)-1 do begin
		
		pr=spechs_[yok] 	;group
			
		if num eq 0. then all_members=pr else all_members=[all_members,pr] 						;CH number stored so as not to be grouped repeatedly.
						
		x=path_xy[ 0, path_info[pr].offset : path_info[pr].offset+path_info[pr].n-1 ]
		y=path_xy[ 1, path_info[pr].offset : path_info[pr].offset+path_info[pr].n-1 ]			
						
		for buk=0, n_elements(spechs_)-1 do begin
				
			rr=spechs_[buk]		;group-member
			
			rx=path_xy[ 0, path_info[rr].offset : path_info[rr].offset+path_info[rr].n-1 ]
			ry=path_xy[ 1, path_info[rr].offset : path_info[rr].offset+path_info[rr].n-1 ]
																																	
			if rr eq pr then begin					;CH and its member is the same CH, store		
		
				if num eq 0. then gr_nums=pr else gr_nums=[gr_nums,pr]				;CH group numbers and CH numbers stored for later modifications depending on distance
				if num eq 0. then gr_chs=rr else gr_chs=[gr_chs,rr]
				num=1. 
			endif else begin							
			
				v_1=fltarr(2, n_elements(x))
				v_2=fltarr(2, n_elements(rx))
				v_1[0,*]=[x]
				v_1[1,*]=[y]
				v_2[0,*]=[rx]
				v_2[1,*]=[ry]

				dist_=polydist_lambert1(v_1,v_2, sizep[1], sizep[2])		
				
				if dist_[0] lt 10. then begin	;CHs grouped if within 10 degrees distance (polydist_lambert1 determines distance in angles)					
					
						if num eq 0. then gr_nums=pr else gr_nums=[gr_nums,pr]
						if num eq 0. then gr_chs=rr else gr_chs=[gr_chs,rr]
						num=1.
				endif
				
			endelse									
		endfor
	endfor

	;Asigning groups (checking pairs and seeing if here are multiple member groups)
	
	new_gr=fltarr(n_elements(gr_nums))
	chs_grs=fltarr(2,n_elements(gr_nums))
	chs_grs[0,*]=gr_nums     ;group head            
	chs_grs[1,*]=gr_chs		 ;group members, original ch numbers
	;print, chs_grs
	
	;grouping algorithm, outputs head numbers in gr_chs order
	chs_grs_=group_ch(spechs_, chs_grs)
	
	;member sorting into ascending order:
	chs_grs_f=fltarr(2,n_elements(chs_grs_))
	chs_grs_f[0,*]=chs_grs_[sort(gr_chs)]
	chs_grs_f[1,*]=gr_chs[sort(gr_chs)]
	
	;getting rid of member repetitions
	regr=uniq(chs_grs_f[1,*])
	chs_grs_f1=chs_grs_f[*,regr]
	
	;sorting based on the group heads
	chs_grs_f2=chs_grs_f1
	chs_grs_f2[0,*]=chs_grs_f1[0,sort(chs_grs_f1[0,*])]
	chs_grs_f2[1,*]=chs_grs_f1[1,sort(chs_grs_f1[0,*])]
	
	;group head numbers are made consecutive numbers starting with number 1
	groups=chs_grs_f2
	ll=uniq(chs_grs_f2[0,*])
	for h=0,n_elements(ll)-1 do	begin
		groups[0,where(chs_grs_f2[0,*] eq chs_grs_f2[0,ll[h]])]=h+1
	endfor
	
	plot_image, alog(image), subtitle='Threshold intensity:'+cc, min=1, max=7, title='EIT '+ STRMID(time_, 0,17), xtitle="Longitude (degrees)", ytitle="Latitude (degrees)",xticks=4, xtickname=['-80','-40','0','40','80'], yticks=4, ytickname=['-80','-30','0','30','80'] ; lambert_project.pro limits projection too +/- 80 deg lat and long.
	loadct, 0
	;horline, siz[2]/2, thick=1, color=150
	PLOTS,[min(siz[1]),max(siz[1])], [siz[2]/2,siz[2]/2], color=150
	verline, siz[1]/2, thick=1, color=150
	verline, siz[1]*1/4, thick=1, color=150
	verline, siz[1]*3/4, thick=1, color=150
	
	loadct, 12, ncolors=20
	
	;Displaying correct, consecutive CH group numbers
	for kk=0, n_elements(groups[0,*])-1 do begin
		kr=groups[1,kk]
		ch_gr=groups[0,kk]
		fx=path_xy[ 0, path_info[kr].offset : path_info[kr].offset+path_info[kr].n-1 ]
		fy=path_xy[ 1, path_info[kr].offset : path_info[kr].offset+path_info[kr].n-1 ]		
		oplot, fx, fy, color=5+ch_gr*2
		grname=round(ch_gr)
		grname=arr2str(grname)
		grname=strtrim(grname,2)
		gclx=min(fx)
		gcly=max(fy)
		if min(fx) gt siz[1]-30 then gclx=gclx-30
		if max(fx) gt siz[2]-30 then gclx=gclx-30
		XYOUTS, gclx, gcly, [grname], charsize=2, charthick=2, color=11	

	endfor

	x2jpeg,  filepath(time_f+'_chmap.jpg',root_dir='$Home',subdir=plotdir) 	
	
	;Plot for HELIO
	;Displaying correct, consecutive CH group numbers
	!p.multi=0
	window,0, xsize=1000, ysize=700			
	eit_colors, '195'
	plot_image, alog(image), min=1, max=7, title='EIT Fe XII (195 !sA!r!u!9 %!3!n ) '+ time_, xtitle="Longitude (degrees)", ytitle="Latitude (degrees)",xticks=4, xtickname=['-80','-40','0','40','80'], yticks=4, ytickname=['-80','-30','0','30','80'], charsize=1.7, charthick=1 ; lambert_project.pro limits projection too +/- 80 deg lat and long.
	loadct, 0
	;horline, siz[2]/2, thick=1, color=150
	PLOTS, [0, siz[1]], [siz[2]/2,siz[2]/2], color=150
	PLOTS, [siz[1]/2, siz[1]/2], [0, siz[2]], color=150
	PLOTS, [siz[1]*1/4, siz[1]*1/4], [0, siz[2]], color=150
	PLOTS, [siz[1]*3/4, siz[1]*3/4], [0, siz[2]], color=150
	
	loadct, 12, ncolors=20

	for kk=0, n_elements(groups[0,*])-1 do begin
		kr=groups[1,kk]
		ch_gr=groups[0,kk]
		fx=path_xy[ 0, path_info[kr].offset : path_info[kr].offset+path_info[kr].n-1 ]
		fy=path_xy[ 1, path_info[kr].offset : path_info[kr].offset+path_info[kr].n-1 ]		
		oplot, fx, fy, color=5+ch_gr*2
		grname=round(ch_gr)
		grname=arr2str(grname)
		grname=strtrim(grname,2)
		gclx=min(fx)
		gcly=max(fy)
		if min(fx) gt siz[1]-30 then gclx=gclx-40
		if max(fy) gt siz[2]-30 then gcly=gcly-40
		XYOUTS, gclx, gcly, [grname], charsize=2, charthick=2, color=11	

	endfor
	im=tvrd(true=1)

	WRITE_PNG,filepath('chgr_'+time_f+'.png',root_dir='$Home',subdir='$Home/Users/ldkrista/idl/0bin/forecast0/HELIO/PLOTS') ,im
	;x2jpeg,  filepath(time_f+'_chmap.jpg',root_dir='$Home',subdir='$Home/Users/ldkrista/idl/0bin/forecast0/HELIO') 
	
	;for SolMon do:	
	;spawn,'convert ~/idl/0bin/2009/region_grown/region_grown'+time_+'.jpg ~/idl/0bin/2009/region_grown/region_grown'+time_+'.png'
	;-------------------------------------------------------------------

	;Finishing up, generating data for the CH groups, making forecasts, linking to HSSW streams
	
	kp=0.
	lp=0.
	
	for d=0, max(groups[0,*])-1 do begin						;for all groups
		
		grnum=d+1.
		
		eastbo=0.
		westbo=0.
		northbo=0.
		southbo=0.
		
		peastbo=0.
		pwestbo=0.
		
		eeastbo=0.
		ewestbo=0.
		
		
		nop_gr_eastbo=0.
		nop_gr_westbo=0.
		nop_gr_northbo=0.
		nop_gr_southbo=0.
			
		nop_gr_eastbo_coo=0.
		nop_gr_westbo_coo=0.
		nop_gr_northbo_coo=0.
		nop_gr_southbo_coo=0.

		gr_eastbo=0.
		gr_westbo=0.
		gr_northbo=0.
		gr_southbo=0.	

		gr_eastbo_coo=0.
		gr_westbo_coo=0.
		gr_northbo_coo=0.
		gr_southbo_coo=0.
		
		gr_area=0.
		bz=0.
		dc=0.
		ja=0.
		jan=0.	;(non-polar, non-extension)
		jae=0.	;(extension only)
		jap=0.	;(no-extension polar only)
		tom=0.
		
		for z=0, n_elements(groups[0,*])-1 do begin						;for all elements of the groups
						
			if groups[0,z] eq grnum then begin	
				
				chnum=groups[1,z]
					
				for kh=0, n_elements(groups[0,*])-1 do begin	
					
					if chs_ab[0,kh] eq chnum then begin
						if tom eq 0. then gr_area=chs_ab[1,kh] else gr_area=[gr_area,chs_ab[1,kh]]
						if tom eq 0. then gr_bz=chs_ab[2,kh] else gr_bz=[gr_bz,chs_ab[2,kh]]
						tom=1.
					endif
					
				endfor
					
				if dc eq 0. then cch=chnum else cch=[cch, chnum]
				dc=1.
				
				crx=path_xy[ 0, path_info[chnum].offset : path_info[chnum].offset+path_info[chnum].n-1 ]
				cry=path_xy[ 1, path_info[chnum].offset : path_info[chnum].offset+path_info[chnum].n-1 ]
					
				n=path_info[chnum].offset
				m=path_info[chnum].offset+path_info[chnum].n-1
				npath=contour_nogap([[round(path_xy[*,n:m])],[round(path_xy[*,n])]])

				npath_ind=coord2ind(npath,[siz[1],siz[2]])
				npath_cc=egso_sfc_chain_code(npath_ind,siz[1],siz[2])
				out_cc=string(npath_cc,format='('+strtrim(n_elements(npath_cc),2)+'I1)')
				chain_length=n_elements(npath_cc)
				out_xy=string(npath[*,0],format='(I4.3,",",I4.3)')
				
				openw, 1, filepath("gr_chain_"+time_f+".dat", root_dir='$Home',subdir=datadir), width=100000, /append
				if lp eq 0. then printf, 1, '#grnum' ,'; ', 'chnum' ,'; ','chain_length','; ',  'out_xy','; ', 'out_cc'
				printf, 1, round(groups[0,z]) ,'; ', round(groups[1,z]),'; ',chain_length,'; ', out_xy,'; ', out_cc
				close,1											
				lp=1.
				
				;Determining the East/West/North/South-most boundary positions for different types of CHs (polar only, polar extension and non-polar -> 'normal')
				
				;'EXTENSIONS' - polar holes with extensions only (cut-off at 45 degrees!)
				if (max(cry) ge 0.86*sizep[2] and min(cry) le 0.86*sizep[2]) or (min(cry) le 0.14*sizep[2] and max(cry) ge 0.14*sizep[2]) then begin	
				
					if ja eq 0. and jae eq 0. then northbo=max(cry) else northbo=[northbo,max(cry)]
					if ja eq 0. and jae eq 0. then southbo=min(cry) else southbo=[southbo,min(cry)]
					if jap eq 0. then peastbo=min(crx) else peastbo=[peastbo,min(crx)]	;'real' E/W-most polar boundary coordinates
					if jap eq 0. then pwestbo=max(crx) else pwestbo=[pwestbo,max(crx)]
					jap=1.
					
					if (max(cry) ge 0.86*sizep[2] and min(cry) le 0.86*sizep[2]) then ind=where(cry lt 0.86*sizep[2])	
					if (min(cry) le 0.14*sizep[2] and max(cry) ge 0.14*sizep[2]) then ind=where(cry gt 0.14*sizep[2])	
					gre=min(crx[ind])
					grw=max(crx[ind])								
					if jae eq 0. then eeastbo=gre else eeastbo=[eeastbo,gre]	;E/W-most boundary coordinates of the extension only
					if jae eq 0. then ewestbo=grw else ewestbo=[ewestbo,grw]
					jae=1.
					ja=1.
				
				;'NO-EXTENSIONS' - polar holes without extensions and normal holes
				endif else begin 
					
					;only 'POLAR'
					if (min(cry) and max(cry) le 0.14*sizep[2]) or (max(cry) and min(cry) ge 0.86*sizep[2]) then begin	;strictly polar CHs (holes both attached and not-attached to the pole)

						if ja eq 0. and jap eq 0. then northbo=max(cry) else northbo=[northbo,max(cry)]	;northern and southern points of polar holes are unaltered and included in all groups.
						if ja eq 0. and jap eq 0. then southbo=min(cry) else southbo=[southbo,min(cry)]	
						
						if jap eq 0. then peastbo=min(crx) else peastbo=[peastbo,min(crx)]	;'real' E/W polar boundary coordinates
						if jap eq 0. then pwestbo=max(crx) else pwestbo=[pwestbo,max(crx)]
						jap=1.
						ja=1.
					
					;only 'NORMAL'
					endif else begin	;'normal holes': all CHs except polar and extended polar holes
				
						if ja eq 0. then northbo=max(cry) else northbo=[northbo,max(cry)]
						if ja eq 0. then southbo=min(cry) else southbo=[southbo,min(cry)]	
						if jan eq 0. then eastbo=min(crx) else eastbo=[eastbo,min(crx)]
						if jan eq 0. then westbo=max(crx) else westbo=[westbo,max(crx)]				
						ja=1.
						jan=1.
					
					endelse
				
				endelse
					
			endif
		
		endfor
		
		if jap eq 1. then begin		;if there are polar CHs in the group (POLAR+EXT + maybe NORMAL)
			
			;normal CHs and polar (general purpose)
			if jan eq 0. then gr_eastbo=min(peastbo) else gr_eastbo=min([eastbo,peastbo])	;for when there are only polar CHs 'AND' for when there are both polar and non-polar
			if jan eq 0. then gr_westbo=max(pwestbo) else gr_westbo=max([westbo,pwestbo])
			gr_northbo=max(northbo)
			gr_southbo=min(southbo)
			
			gr_eastbo_coo=round( (gr_eastbo-sizep[1]/2.0)*(160.0/sizep[1]) )
			gr_westbo_coo=round( (gr_westbo-sizep[1]/2.0)*(160.0/sizep[1]) )	
			gr_northbo_coo=round( (180./!pi) * asin( ( gr_northbo/(sizep[2]/2.0) - 1.) * ( sin(80.*!DTOR ) ) ) )
			gr_southbo_coo=round( (180./!pi) * asin( ( gr_southbo/(sizep[2]/2.0) - 1.) * ( sin(80.*!DTOR ) ) ) )			
		
			;changing them to float so there's no structure conflict..
			nop_gr_eastbo_coo=round(nop_gr_eastbo_coo)
			nop_gr_westbo_coo=round(nop_gr_westbo_coo)	
			nop_gr_northbo_coo=round(nop_gr_northbo_coo)
			nop_gr_southbo_coo=round(nop_gr_southbo_coo)
			
			;normal and polar extensions (forecasting purpose)
			if jae eq 1. then begin
				
				if jan eq 0. then nop_gr_eastbo=min(eeastbo) else nop_gr_eastbo=min([eastbo, eeastbo])  
				if jan eq 0. then nop_gr_westbo=max(ewestbo) else nop_gr_westbo=max([westbo, ewestbo])
				nop_gr_northbo=max(northbo)
				nop_gr_southbo=min(southbo)
				
				nop_gr_eastbo_coo=round( (nop_gr_eastbo-sizep[1]/2.0)*(160.0/sizep[1]) )
				nop_gr_westbo_coo=round( (nop_gr_westbo-sizep[1]/2.0)*(160.0/sizep[1]) )	
				nop_gr_northbo_coo=round( (180./!pi) * asin( ( nop_gr_northbo/(sizep[2]/2.0) - 1.) * ( sin(80.*!DTOR ) ) ) )
				nop_gr_southbo_coo=round( (180./!pi) * asin( ( nop_gr_southbo/(sizep[2]/2.0) - 1.) * ( sin(80.*!DTOR ) ) ) )
			
			;'normal' satellite holes
			endif else begin 
				
				if jan eq 1 then begin	;if there are any 'normal' satellite holes. Otherwise keep E/W values at 0 (only polar holes are in the group).
					nop_gr_eastbo=min(eastbo)
					nop_gr_westbo=max(westbo)
					nop_gr_eastbo_coo=round( (nop_gr_eastbo-sizep[1]/2.0)*(160.0/sizep[1]) )
					nop_gr_westbo_coo=round( (nop_gr_westbo-sizep[1]/2.0)*(160.0/sizep[1]) )	
				endif
				
				nop_gr_northbo=max(northbo)
				nop_gr_southbo=min(southbo)
				
				nop_gr_northbo_coo=round( (180./!pi) * asin( ( nop_gr_northbo/(sizep[2]/2.0) - 1.) * ( sin(80.*!DTOR ) ) ) )
				nop_gr_southbo_coo=round( (180./!pi) * asin( ( nop_gr_southbo/(sizep[2]/2.0) - 1.) * ( sin(80.*!DTOR ) ) ) )
			
			
			endelse
		
		endif else begin	;no polar holes (only NORMAL)
		
			nop_gr_eastbo=min(eastbo)
			nop_gr_westbo=max(westbo)
			nop_gr_northbo=max(northbo)
			nop_gr_southbo=min(southbo)
				
			nop_gr_eastbo_coo=round( (nop_gr_eastbo-sizep[1]/2.0)*(160.0/sizep[1]) )
			nop_gr_westbo_coo=round( (nop_gr_westbo-sizep[1]/2.0)*(160.0/sizep[1]) )	
			nop_gr_northbo_coo=round( (180./!pi) * asin( ( nop_gr_northbo/(sizep[2]/2.0) - 1.) * ( sin(80.*!DTOR ) ) ) )
			nop_gr_southbo_coo=round( (180./!pi) * asin( ( nop_gr_southbo/(sizep[2]/2.0) - 1.) * ( sin(80.*!DTOR ) ) ) )

			gr_eastbo=nop_gr_eastbo
			gr_westbo=nop_gr_westbo
			gr_northbo=nop_gr_northbo
			gr_southbo=nop_gr_southbo	

			gr_eastbo_coo=nop_gr_eastbo_coo
			gr_westbo_coo=nop_gr_westbo_coo
			gr_northbo_coo=nop_gr_northbo_coo
			gr_southbo_coo=nop_gr_southbo_coo	
				
		endelse		
	
		;area_km=(surface_km*gr_area)/surface_px		;Area in km^2 
		;gr_area_pc=100.0*area_km/surface_km		;Area as a percentage of the total solar surface					
		
		cbr_x=gr_westbo_coo-abs(gr_westbo_coo-gr_eastbo_coo)/2.		;ch group box center (x)
		cbr_y=gr_northbo_coo-abs(gr_northbo_coo-gr_southbo_coo)/2.	;ch group box center (y)
		gr_arccent=conv_h2a([cbr_x, cbr_x], time_)	;same in arcs
		
		gr_arctop=conv_h2a([gr_westbo_coo, gr_northbo_coo], time_)	;ch group box upper right corner
		gr_arcbottom=conv_h2a([gr_eastbo_coo, gr_southbo_coo], time_)	;ch group box lower left corner
		
		;chs has to be an array of the same length for each structure:
		chs=intarr(n_elements(groups[0,*]))
		haj=0.
		for sej=0, n_elements(cch)-1 do begin
			chs[haj]=cch[sej]
			haj=haj+1.
		endfor
		
		gr_area_px=total(gr_area)														
		
		rad=696000.0								;solar radius [km] 
		surface_km=1.75*rad^2*!pi					;visible surface! Instead of !pi we use (160.*!DTOR) as we havent a full 180 degree after the Lambert projection. (see calc. in notes)	
		surface_px=sizep[1]*sizep[2]
		gr_area_km=(surface_km*gr_area_px)/surface_px		;Area in km^2 

		;*******
		sgr=create_struct('CHGR_NUM', grnum, $
		'CH_NUMS', chs, $
		'CHGR_BR_PIX', [gr_eastbo, gr_southbo, gr_westbo, gr_northbo], $
		'CHGR_BR_DEG', [gr_eastbo_coo, gr_southbo_coo, gr_westbo_coo, gr_northbo_coo], $
		'NP_CHGR_BR_DEG', [nop_gr_eastbo_coo, nop_gr_southbo_coo, nop_gr_westbo_coo, nop_gr_northbo_coo], $ ;no-polar holes included (east/westmost point determined from groupmembers above\below 14% bottom/top of image. Southmost/northmost point is of polar-included group - indicator that originally group includes polar hole!)
		'CHGR_BR_ARC', [gr_arctop, gr_arcbottom], $
		'CHGR_CBR_PIX',  [gr_westbo-abs(gr_westbo-gr_eastbo)/2., gr_northbo-abs(gr_northbo-gr_southbo)/2.], $
		'CHGR_CBR_DEG', [cbr_x, cbr_y], $
		'CHGR_CBR_ARC', gr_arccent, $
		'CHGR_LAT_WIDTH_DEG', abs(gr_westbo_coo-gr_eastbo_coo), $
		'NP_CHGR_LAT_WIDTH_DEG', abs(nop_gr_westbo_coo-nop_gr_eastbo_coo), $	
		'CHGR_LON_WIDTH_DEG', abs(gr_northbo_coo-gr_southbo_coo), $
		'CH_LAT_WIDTH_ARC', gr_arctop[1]-gr_arcbottom[1], $
		'CH_LON_WIDTH_ARC', gr_arctop[0]-gr_arcbottom[0], $
		'CHGR_AREA_PIX', gr_area_px, $
		'CHGR_AREA_MM', gr_area_km/1000., $
		'CHGR_MEAN_BZ', mean(gr_bz)	)			
		if kp eq 0. then s_gr=sgr else s_gr=[s_gr, sgr]
		;*******

		openw, 2, filepath("chgr_props"+time_f+".dat", root_dir='$Home',subdir=datadir), width=256, /append
		if kp eq 0 then printf, 2, '#grnum' ,'; ',  'gr_bz','; ', 'gr_area','; ', 'gr_westbo','; ', 'gr_eastbo','; ', 'gr_northbo','; ', 'gr_southbo'
		printf, 2, round(grnum) ,'; ', round(mean(gr_bz)),'; ', round(mean(gr_area)),'; ', round(gr_westbo),'; ', round(gr_eastbo),'; ', round(gr_northbo),'; ', round(gr_southbo)
		close,2											
		kp=1.
		
		;hssw_finder13, time_, gr_eastbo_coo, gr_westbo_coo, gr_northbo_coo, gr_southbo_coo, gr_area, gr_bz, grnum
		
	endfor
	
	for ka=0, n_elements(groups[1,*])-1 do begin	
		for ga=0 , n_elements(s_ch)-1 do begin
			if s_ch[ga].ch_num eq groups[1,ka] then s_ch[ga].chgr_num=groups[0,ka]
		endfor
	endfor
	
	
save, s_f, s_ch, s_gr, filename='$Home/Users/ldkrista/idl/0bin/forecast0/HELIO/SAV/chgr_'+time_f+'.sav'

;horline, 0.86*sizep[2]
;horline, 0.14*sizep[2]

end
