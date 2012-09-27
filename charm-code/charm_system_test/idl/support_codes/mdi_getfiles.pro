pro mdi_getfiles,filename=filename,start_date=start_date,end_date=end_date,dirname=dirname,grid=grid

;start_date='2-apr-2004'
;end_date='3-apr-2004'
;dirname='smart_dataset'
;grid=0

storage_dir=(~keyword_set(grid))?'/tmp/smart_storage/mdi_data/':'/grid/vo.helio-vo.eu/data/mdi_mag/'
mkdir_command=(~keyword_set(grid))?'mkdir -p ':'lfc-mkdir -p '
;cp_command=(~keyword_set(grid))?'cp ':'lfc-cp '
wget_command='wget -N -i ';'/sw/bin/wget -i '
local = file_exist('/tmp/'+dirname)
if local eq  0 then spawn,'mkdir -p /tmp/'+dirname

if (keyword_set(start_date) and keyword_set(end_date)) then begin
   file_urls=mdi_time2file(start_date,end_date,/stanford)
   dates=mdi_file2date(file_urls,filenames=filenames)
endif

if keyword_set(filename) then begin
   dates=mdi_file2date(filename,filenames=filenames,url_stanf=file_urls)
endif

;All related with the PATHS
    grid_path=strcompress(storage_dir+dates+'/',/remove_all)

    ; check if the paths exist
    paths2check=grid_path[uniq(grid_path)]
    paths_exist=(~keyword_set(grid))?file_exist(paths2check):file_exist_gridstorage(paths2check)

    ;create those that do not exist
    tocreate=where(paths_exist eq 0,n2create,compl=exist,ncomple=exist_n)
    if n2create gt 0 then for i=0,n2create-1 do spawn,mkdir_command+paths2check[tocreate[i]]

; All related with the files
    ;check if the files needed have to be downloaded
    grid_files=strcompress(grid_path+filenames+'.gz',/remove_all)
    files_exist=(~keyword_set(grid))?file_exist(grid_files):file_exist_gridstorage(grid_files)

    ;download those that does not exist...
    todownload=where(files_exist eq 0, n2down, compl=nodownl,ncompl=n2nodown)
    if n2down gt 0 then begin
       openw,unit,'/tmp/'+dirname+'/filelist.dat',/get_lun
       printf,unit,file_urls[todownload]
       close,unit
       spawn,wget_command+'/tmp/'+dirname+'/filelist.dat -P /tmp/'+dirname
    ;...and copy them to the grid
       for i=0,n2down-1 do begin
          transferfile = '/tmp/'+dirname+'/'+filenames[todownload[i]]
          spawn,'gzip -c '+transferfile + ' > ' + transferfile+'.gz'
          spawn,copy_order(local=transferfile +'.gz',remote=grid_files[todownload[i]],/to,grid=grid)
       endfor
    endif


    ; copy to the local directory does that have been downloaded before
    if n2nodown gt 0 then begin
    	for i=0,n2nodown-1 do begin
           transferfile = '/tmp/'+dirname+'/'+filenames[nodownl[i]] + '.gz'
           spawn,copy_order(local=transferfile,remote=grid_files[nodownl[i]],/from,grid=grid)
           spawn,'gunzip '+transferfile
        endfor
     endif
end
