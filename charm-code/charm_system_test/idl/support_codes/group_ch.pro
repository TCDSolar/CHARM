function group_ch, spechs_, chs_grs_

chs_grs=chs_grs_

;spechs_ are the original selected CHs in growing sequence
;chs_grs are the CH pairs based on distances

	for i=n_elements(spechs_)-1,0,-1 do begin
	
		a0=where(chs_grs[0,*] eq spechs_[i])	; spechs_[i] is the original CH number
		a1=where(chs_grs[1,*] eq spechs_[i])
		b=min([chs_grs[1,a0],chs_grs[0,a1]])
		chs_grs[0,a0]=b
		chs_grs[1,a1]=b
		
	endfor 
	
	new_gr=reform(chs_grs[0,*])

	return, new_gr
stop
end