function list_files_grid,start_date=start_date,end_date=end_date,path=path,smart=smart,charm=charm

  if keyword_set(smart) then path='/grid/vo.helio-vo.eu/data/smart_output/savfiles/'
  if keyword_set(charm) then path='/grid/vo.helio-vo.eu/data/charm_output/savfiles/'
    if path eq '' then begin
     print,'%% get_files_grid needs a path definition'
     return,-1
  endif

;set start and end date as default... if not setted
  directories=date_interval(start_date=start_date,end_date=end_date,cadence=1,/dir)
  directories=path+directories

  list=''
  for i=0,n_elements(directories)-1 do begin
     spawn,'lfc-ls '+directories[i],out
     if out[0] ne '' then list=(i eq 0)?directories[i]+'/'+out:[list,directories[i]+'/'+out]
  endfor

return,list
end

