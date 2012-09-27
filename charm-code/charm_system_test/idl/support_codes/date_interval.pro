function date_interval,start_date=start_date,end_date=end_date,cadence=cadence,unit=unit,dir=dir
;+
; Produces the time in seconds as made by anytim between the dates given.
; If /dir then produces yyyy/mm/dd format of the interval asked.
; Unit default is 1 day
; Cadence in Days
;-
  startt=anytim(start_date)
  endt=anytim(end_date)
  if ~keyword_set(unit) then unit=3600.*24.
  nelements=fix((endt-startt)/(unit*cadence))
  unit=(nelements lt 0)?-1*unit:unit
  dates=(findgen(abs(nelements)+1)*cadence*unit)+startt

  if keyword_set(dir) then begin
     datess=strarr(n_elements(dates))
     for i=0,n_elements(dates)-1 do datess[i]=(strsplit(anytim(dates[i],/ecs),/extract))[0]
     dates=datess
  endif
  return,dates
end
