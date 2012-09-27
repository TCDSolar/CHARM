@charm_struct2heliodb_allinone.pro
pro heliodb_meta,filelist,runname=runname,mdidir=mdidir

pathdb=mdidir+'/db/'
spawn,'mkdir -p '+pathdb

if runname eq '' then runname=time2file(systim(/utc))

savdir=mdidir
eitdir=mdidir
mdidir=mdidir
spath=pathdb


outfrc=runname+'_ch_frc.csv'
outfits=runname+'_ch_observation.csv'     ;done!
outobservatory=runname+'_ch_observatory.csv'
outresults=runname+'_ch_results.csv'
grpresults=runname+'_ch_grp_results.csv'

web=0
solarmonitor=0
sm_archive=0

for i=0,n_elements(filelist)-1 do begin

   charm_struct2heliodb_allinone,struct_filename=filelist[i],save_path=pathdb, $
                          eit_num=eit_num,eit_file_obs=outfits,eit_data_dir=eitdir,eit_save_path=pathdb,/eit_insearch,/eit_check_num,$
                          mdi_num=mdi_num,mdi_file_obs=outfits,/mdi_insearch,/mdi_check_num,mdi_data_dir=mdidir,mdi_save_path=pathdb, $
                          file_grp=grpresults,grp_nst=grp_nst, $
                          file_chs=outresults,chs_nst=chs_nst, $
                          solarmonitor=solarmonitor,web_path=web

endfor

charm_struct2heliodb_frcinfo,outfrc=pathdb+outfrc

charm_struct2heliodb_obsinfo,outobs=pathdb+outobservatory


print,'DBs files DONE!!'
print,'files are here: '+pathdb


end
