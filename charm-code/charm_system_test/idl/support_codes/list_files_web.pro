function list_files_web,start_date=start_date,end_date=end_date,path=path,smart=smart,charm=charm

;  if keyword_set(smart) then path='/grid/vo.helio-vo.eu/data/smart_output/savfiles/'
  base_url='http://solarmonitor.org/data/charms_sav/'
  if keyword_set(charm) then list_url='http://solarmonitor.org/data/charm_list'
  sock_list,list_url,all_files
  if n_elements(all_files) lt 100 then begin
     print,'%% list_files_web may not be working as expected'
     return,-1
  endif

;set start and end date as default... if not setted
  all_dates=date_interval(start_date=start_date,end_date=end_date,cadence=1,/dir)
  for i=0,n_elements(all_dates)-1 do dates=(i eq 0)?strjoin(strsplit(all_dates[i],'/',/extr)):[dates,strjoin(strsplit(all_dates[i],'/',/extr))]
  dates_url=strmid(all_files,5,8)

;match which ones need to download.
  match,dates_url,dates,suburl,subdates,count=number
  
  if number eq 0 then begin
  	print,'%% No files match the dates searched'
  	return,-1
  endif
  
  list=base_url+all_files[suburl]
  
return,list
end

