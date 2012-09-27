;---------------------------------------------------------------------->

function smart_paths, mdip=mdip, hmip=hmip, calmdip=calmdip, logp=logp,savp=savp,fitsp=fitsp, resavetrackp=resavetrackp, arsavp=arsavp, $
	resmapp=resmapp, plotp=plotp, arplotsp=arplotsp, voevents=voevents, $ ;htmlp=htmlp, $
	nardb=nardb, calibp=calibp, flarep=flarep, psplotp=psplotp, summaryp=summaryp, $
	pngp=pngp, statplotp=statplotp, date=date, $
	no_calib=no_calib

if keyword_set(calibp) then begin 
	retval='docalib.tmp.sav' 
	return,retval
endif

if not keyword_set(no_calib) then restore,smart_paths(/calibp)

;FULL SOLAR CYCLE ARCHIVE
if keyword_set(mdip) then retval='/Volumes/LaCie/data/mdi_mag2/'
if keyword_set(logp) then retval='/Volumes/IOMEGA HDD/data/smart/logs/'
if keyword_set(savp) then retval='/Volumes/IOMEGA HDD/data/smart/sav/'
;;if keyword_set(plotp) then retval='/Volumes/LaCie/data/smart2/plots/tracked/'
if keyword_set(plotp) then retval='/Volumes/IOMEGA HDD/data/smart/plots/'
if keyword_set(voevents) then retval='/Volumes/IOMEGA HDD/data/smart/voevents/'
if keyword_set(fitsp) then retval='/Volumes/IOMEGA HDD/data/smart/fits/'
;;if keyword_set(resavetrackp) then retval='/Volumes/LaCie/data/smart2/sav_tracked/'
if keyword_set(resavetrackp) then retval='/Volumes/IOMEGA HDD/data/smart/sav_arstr/'
if keyword_set(arsavp) then retval='/Volumes/IOMEGA HDD/data/smart/ars/'
if keyword_set(arplotsp) then retval='/Volumes/IOMEGA HDD/data/smart/arplots/'


;DESKTOP ARCHIVE
;if keyword_set(mdip) then retval='~/science/data/smart2/mdi/'
;if keyword_set(logp) then retval='~/science/data/smart2/logs/'
;if keyword_set(savp) then retval='~/science/data/smart2/sav/'
;if keyword_set(plotp) then retval='~/science/data/smart2/plots/'

;BRADFORD STUFF
;if keyword_set(mdip) then retval='~/science/data/temp_mdi_data2/'
;;if keyword_set(mdip) then retval='~/science/data/temp_mdi_data/'
;if keyword_set(savp) then retval='~/science/bradford/sipwork_paper/smart_sav2/'
;;if keyword_set(savp) then retval='~/science/bradford/sipwork_paper/smart_sav/'
;if keyword_set(logp) then retval='~/science/bradford/sipwork_paper/smart_logs/'
;if keyword_set(plotp) then retval='~/science/bradford/sipwork_paper/smart_plots/'
;if keyword_set(resavetrackp) then retval='~/science/bradford/sipwork_paper/smart_sav/'

;ISSI STUFF
;if keyword_set(savp) then retval='/Volumes/LaCie/data/smart2/issi2/'
;if keyword_set(logp) then retval='/Volumes/LaCie/data/smart2/issi2/'
;if keyword_set(plotp) then retval='/Volumes/LaCie/data/smart2/issi_plots/rotation/'
;if keyword_set(resavetrackp) then retval='/Volumes/LaCie/data/smart2/issi2/'

;OTHER ARCHIVES
if keyword_set(resmapp) then retval='~/science/data/restore_maps/'
if keyword_set(flarep) then retval='~/Sites/phiggins/smart/flare/'
if keyword_set(hmip) then retval='~/science/data/sdo/hmi/'

;summaryp=summaryp

if keyword_set(no_calib) then goto,skipgrian
skipgrian:

return, retval

end

;---------------------------------------------------------------------->
