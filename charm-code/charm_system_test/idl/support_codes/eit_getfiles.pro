pro eit_getfiles,filename=filename,start_date=start_date,end_date=end_date,dirname=dirname,grid=grid,_extra=_extra
;TODO:
;check condition between filename and start_date one or the other
;if start_date => end_date eq +1 if not provided
;add search by date!
;if dirname not exist? use a default one... and output info!
;storage_dir if not /grid? input or $EIT_files system variable or /tmp/HELIO/data/EIT_195


;start_date='2-apr-2004'
;end_date='3-apr-2004'
;dirname='smart_dataset'
;grid=0

storage_dir=(~keyword_set(grid))?'/tmp/smart_storage/mdi_data/':'/grid/vo.helio-vo.eu/data/eit_195/'
mkdir_command=(~keyword_set(grid))?'mkdir -p ':'lfc-mkdir -p '
;cp_command=(~keyword_set(grid))?'cp ':'lfc-cp '
wget_command='wget -N -i ';'/sw/bin/wget -i '


;TODO: make available start and end date to get data.
if keyword_set(filename) then begin
	;TODO: Allow multiple files
	YYYYMMDD= strmid(filename,3,8)
	YYYY 	= strmid(YYYYMMDD,0,4)
	MM 		= strmid(YYYYMMDD,4,2)
	DD		= strmid(YYYYMMDD,6,2)
	filelist="http://sohodata.nascom.nasa.gov//archive/soho/private/data/processed/eit/lz/" + YYYY + "/" + MM + "/" + filename
	
	;Check whether the path exist already on the grid storage.
    ; Check the path
    paths2check=strcompress(storage_dir+YYYY+'/'+MM+'/'+DD+'/',/remove_all)
    paths_exist=(~keyword_set(grid))?file_exist(paths2check):file_exist_gridstorage(paths2check,_extra=_extra)

    ;create those that do not exist
    tocreate=where(paths_exist eq 0,n2create,compl=exist,ncomple=exist_n)
    if n2create gt 0 then for i=0,n2create-1 do spawn,mkdir_command+paths2check[tocreate[i]]
    
    ;Check whether the file exist on the grid storage
    files2check=strcompress(paths2check+filename+'.gz',/remove_all)
    files_exist=(~keyword_set(grid))?file_exist(files2check):file_exist_gridstorage(files2check,_extra=_extra)

    ;download those that does not exist...
    todownload=where(files_exist eq 0, n2down, compl=nodown,ncompl=n2nodown)
    if n2down gt 0 then begin
       openw,unit,'/tmp/'+dirname+'/filelist.dat',/get_lun
       printf,unit,filelist[todownload]
       close,unit
       spawn,wget_command+'/tmp/'+dirname+'/filelist.dat -P /tmp/'+dirname
    ;...and copy them to the grid
       for i=0,n2down-1 do begin
          transferfile = '/tmp/'+dirname+'/'+filename[todownload[i]]
          spawn,'gzip -c '+transferfile+' > '+transferfile+'.gz'
          spawn,copy_order(local=transferfile+'.gz',remote=files2check[todownload[i]],/to,grid=grid)
          spawn,'rm '+transferfile+'.gz'
        endfor
    endif

    ; copy to the local directory does that have been downloaded before
    if n2nodown gt 0 then begin
    	for i=0,n2nodown-1 do begin
           transferfile = '/tmp/'+dirname+'/'+filename[nodown[i]]+'.gz'
           spawn,copy_order(local=transferfile,remote=files2check[nodown[i]],/from,grid=grid)
           spawn,'gunzip '+transferfile
     	endfor
	endif

    

endif

end
