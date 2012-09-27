pro get_files,start_date=start_date,end_date=end_date,dirname=dirname
;+
; start_date: 1-4-2004
; end_date: 1-5-2004
;-
;  TODO: grid keyword
storage_dir='/tmp/smart_storage/mdi_data/' ;this should be input as: $MDI_MAGS in the cshrc file!
;Get the list of files needed:
file_list=mdi_time2file(start_date,end_date)
;First, check if the files exists
locals=file_exist(file_list+'*')
fex=where(locals eq 1,nfex,comp=fnex,ncomp=nfnex)
file_list=mdi_time2file(start_date,end_date,/stanford)
for i=0,n_elements(file_list)-1 do $    ;extract just the file names.
    list=(i eq 0)?(str_sep(file_list[i],'/'))[7]:[list,(str_sep(file_list[i],'/'))[7]]

;comparing list: make a lslist and compare with the list I have. Probably no very quick
;spawn,'ls '+storage_dir,lslist
;COPYSET = CMSET_OP(list,'AND', lslist)

;Check which files have already been download
locals=file_exist(storage_dir+list+'*')
;print,storage_dir
;print,locals


exist=where(locals,count,comple=nexist,ncomple=ncount)


if count gt 0 then begin
;Copy those files to the tmp directory
    ;  TODO:change to commands used on the grid
    copyfiles=strjoin(storage_dir+list[exist]+'* ')
    spawn,'cp '+copyfiles+' /tmp/'+dirname
endif

if ncount gt 0 then begin
;download the other files
openw,unit,'/tmp/'+dirname+'/filelist.dat',/get_lun
printf,unit,file_list[nexist]
close,unit
spawn,'wget -i /tmp/'+dirname+'/filelist.dat -P /tmp/'+dirname

;copy the download files into the storage
copyfiles=strjoin('/tmp/'+dirname+'/'+list[nexist]+' ')
spawn,'gzip '+copyfiles
copyfiles=strjoin('/tmp/'+dirname+'/'+list[nexist]+'.gz ')
spawn,'cp '+copyfiles+' '+storage_dir
endif

end
