
function conv_h2c, helio, time, dc=dc, behind=behind, $
  qs=qs

;+
;NAME:
;	conv_h2c
;PURPOSE:
;	To convert from heliocentric coordinates to Carrington coordinates
;SAMPLE CALLING SEQUENCE:
;       carr_coords = conv_h2c(-75, time)
;       carr_coords = conv_h2c([-75,25], time)
;       carr_coords = conv_h2c([-75,25], time, /dc)
;       carr_coords = conv_h2c(helio, time)
;       carr_coords = conv_h2c([ew,ns], time, /dc)
;INPUT:
;       helio   - The heliocentric angle in degrees
;                       (0,*) = longitude (degrees) W positive
;                       (1,*) = latitude (degrees) N positive
;OPTIONAL INPUT:
;	time	- The time for the conversion in question.  This is needed
;		  for SXT so that the pixel location of the center of the sun
;		  can be determined.  It may be an index structure.
;OUTPUT:
;	carr_coords - The Carrington longitude or decimal Carrington
;		  rotation number (and heliographic latitude, if it was
;		  input - heliographic latitude will be carried through
;		  unchanged for convenience).
;                       (0,*) = longitude (degrees) or decimal Carrington
;				rotation number
;                       (1,*) = latitude (degrees) N positive
;OPTIONAL KEYWORD INPUT:
;	dc	- If set output longitude is in decimal Carrington rotation
;		  number
;OPTIONAL KEYWORD OUTPUT:
;       behind -  A flag which is set to 1 when there are points behind limb
;HISTORY:
;	Written 14-Feb-94 by G.L. Slater using Morrison's CONV_P2H as a
;		template
;TODO:
;-

if n_elements(time) eq 0 then time = !stime
out = helio
carr = tim2carr(time,dc=dc)
if keyword_set(dc) eq 1 then $
  out(0,*) =  replicate(carr(0),n_elements(out(0,*))) - out(0,*)/360. else $
  out(0,*) = (replicate(carr(0),n_elements(out(0,*))) + out(0,*)) mod 360

if keyword_set(qs) eq 1 then stop
return, out

end

