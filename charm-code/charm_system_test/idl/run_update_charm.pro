pro run_update_charm,start_date=start_date,end_date=end_date,mdidir=mdidir,runname=runname,datadir=datadir,grid=grid,charm_db_storage=charm_db_storage
;-
; RUN_UPDATE_CHARM
;    1. Get list of files from web  => LIST_FILES_WEB
;    2  Download files to working directory
;    3. Get list of download files
;    4. Update each individual file   => UPDATE_CHARM_FILE
;    5. Generate DB files -> HELIODB_META 
;    6. Save DB files on storage  
;
;+

localpath=mdidir
verbose=1
mkdir_command=(~keyword_set(grid))?'mkdir -p ':'lfc-mkdir -p '

;======================================================
;    1. Get list of files from web
;===========================
savlist=list_files_web(start_date=start_date,end_date=end_date,/charm)
if (string(savlist[0]) eq '') or (string(savlist[0]) eq "-1") then begin
   print,'Files missing, skipping rest of the program'
   goto,fin
endif

;======================================================
;    2. Download files to working directory
;===========================
	openw,unit,mdidir+'/filelist.dat',/get_lun
	printf,unit,savlist
	close,unit
	spawn,'wget -nv -nc -i '+mdidir+'/filelist.dat -P '+mdidir
	
;======================================================
;    3. Get list of download files
;===========================
; Get the list of local files:
    savlist_local=file_search(mdidir,'chgr*sav',count=n_savlist_local)

;for each sav name: update
	if (n_savlist_local eq 0) then begin
		print,'$$ RUN_UPDATE_CHARM: There is not files on the working directory '+mdidir
		goto,fin
	endif
	
	print,string(n_savlist_local, format='("$$ RUN_UPDATE_CHARM: ",I3," files downloaded")')
;======================================================
;    4. Update each individual file  
;===========================
	for i=0,n_elements(savlist_local)-1 do begin
           aa=update_charm_file(savlist_local[i],localpath=mdidir,grid=grid,err=err,verbose=verbose,datadir=datadir)
           if aa ne 1 then print,'$$ RUN_UPDATE_CHARM: file '+savlist_local[i]+' failed!!!'
	endfor
	
;======================================================
;    5. Generate DB files 
;===========================
	heliodb_meta,savlist_local,runname=runname,mdidir=mdidir

;======================================================
;    6. Save DB files on storage  
;===========================
	spawn,mkdir_command+charm_db_storage
	dblist_local=file_search(mdidir+'/db/','*csv')
	for i=0,n_elements(dblist_local)-1 do justdbfiles=(i eq 0)?(reverse(strsplit(dblist_local[i],'/',/extract)))[0]:[justdbfiles,(reverse(strsplit(dblist_local[i],'/',/extract)))[0]]
	for i=0,n_elements(dblist_local)-1 do spawn,copy_order(local=dblist_local[i],remote=charm_db_storage+justdbfiles[i],/to,grid=grid)

fin:

end
