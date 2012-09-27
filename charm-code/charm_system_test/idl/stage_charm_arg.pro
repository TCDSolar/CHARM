pro stage_charm_arg,start_date,end_date,grid=grid,runname=runname,update=update
;-
; STAGE_CHARM_ARG
;    1. Creates working directory in tmp folder
;    2a). Run detection code      =>  charmcode (??)
;    2b). /update -> Update values from previous run  =>  RUN_UPDATE_CHARM
;    3. Cleans directory
;
;+

; Variables:
charm_db_storage = '/grid/vo.helio-vo.eu/data/charm_output/database/'


;======================================================
;    1. Creates working directory in tmp folder
;===========================
;datadir=string(systime(/utc,/s)/100000.,format='(I6.6)')
;but more sofisticated is how is done in make_str.pro
;sec10yr=315360000
;datadir='charm_'+string(long(systime(2)) mod sec10yr, format='(i9.9)')+string(get_rid())

datadir = 'charm_' + $
          string(anytim(start_date) - anytim('13-June-1982'),format='(I10.10)')

mdidir='/tmp/'+datadir

spawn,'mkdir -p '+mdidir
print,mdidir

if ~keyword_set(update) then begin
;======================================================
;    2a). Run detection code 
;===========================
;=========== Normal Run!
;TODO: fill it with the proper programs...
;mdi_getfiles,start_date=start_date,end_date=end_date,dirname=datadir,grid=grid

;filelist=file_search('/tmp/'+datadir+'/'+['*fits','*fits.gz'])
;run_smart_arg,filelist=filelist,mdidir=mdidir,runname=runname

;filelist=file_search(smart_paths(/savp,/no_calib)+'*.sav')
;smart_sav_getfiles,savfiles=filelist,grid=grid

endif else begin
;======================================================
;    2b). Update values from previous run 
;===========================
;============ Update values
run_update_charm,start_date=start_date,end_date=end_date,mdidir=mdidir,runname=runname,datadir=datadir,grid=grid,charm_db_storage=charm_db_storage

endelse

;======================================================
;    1. Cleans directory
;===========================
spawn,'rm -rf '+mdidir

end
