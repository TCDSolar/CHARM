FUNCTION DATE_STANDARD, date,err_msg=err_msg
progname='DATE_STANDARD'

MONTHS = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', $
          'SEP', 'OCT', 'NOV', 'DEC']
error=progname + ' error: month is not in 3 character type, i.e. "JAN","FEB",...'
err_msg=''


;search if the date contain any of the months
VALUE=0
for i=0,11 do begin
   pos_month=strpos(STRUPCASE(date),months[i])
   value=value+pos_month
endfor

IF value EQ -12 THEN BEGIN
   err_msg=error
   return,-1
ENDIF ELSE return,1

END

FUNCTION LAMBERT_PROJECT, image,xycen,pxs,DATE=date,B0=b0,RSUN=rsun,PHIK=phik,XYREF=xyref,INFO=INFO,DEBUG=debug,SOHO=soho
;+
;NAME:
;    LAMBERT_PROJECT.PRO
;PURPOSE:
;     Project a solar image onto an area preserving longitude,SIN(latitude)
;     cylindrical map. The projection is referred to as a Lambert
;     projection in geographic literature and as a Carrington projection
;     in heliographic work. Meridians and latitude lines are perpendicular
;     the output image.
;     Preserves pixel scale so it returns an image that may be
;     substantially larger than the input image if the input image
;     is near the limb.
;     Assumes the Sun is a sphere and that image is oriented solar-north
;     (P angle = 0).
;CATEGORY: mapping
;CALLING SEQUENCE:
;     image = map_carrington(image,xycen,pxs,[date=date,B0=b0,RSUN=rsun,XYREF=XYREF,PHIK=phik,INFO=info,/DEBUG])
;
;INPUTS:
; IMAGE = image to be mapped onto a cylindrical projection
; XYCEN = FLTARR(2): E/W & N/S arcsecond angle of image center from Solar disk
;         center. W and N are positive.
; PxS   = pixel size: arcseconds/pixel image scale.
;
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS:
; DATE  = date of image in any of the accepted CDS date forms (just
;         for earth-sun line spacecraft obs). With month in 3 character.
; B0    = B0 angle (in degrees), when DATE is not provided. Default: 0
; RSUN  = Solar radius (in arcsec), when DATE is not provided. Default: half of
;         smaller dimmension of the image.
; XYREF = LONARR[2], coordinates of a reference point in the original
;         image. If provided, the point is returned as the coordinates
;         in the remapped image. Useful for keeping track of a
;         sunspot, etc.
; PHIK = latitude of unity linear scale in cylindrical equal area
;        projection, in degrees. See "Map Projections" by Bugayevskiy and
;        Snyder, Ch. 2.
; SOHO = if Soho is set then when date is input the rsun and b0 is
;        calculated from SOHO point of view
;
;OUTPUTS:
; Warped image using cubic interpolation in POLY_2D. Note that the
; platescale of the warped image is the same as the input image. This
; means that the warped image may be substantially larger in format
; than the original, especially for near-limb images.
;
;CALLS:
;     DATE_STANDARD, VALID_TIME, PB0R, 
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;     Assumes image is oriented with Solar North UP.
;     Does not remap any pixels that are off the limb of the
;     Sun for the date given.
;PROCEDURE:
;EXAMPLE:
;     for TRACE images:
;     IDL> read_trace,filename,-1,index,image
;     IDL> traceplate = 0.4993  ;arcsec per pixel
;     IDL> warp_image =
;           lambert_project(image,[index.xcen,index.ycen],traceplate,DATE=index.date)
;
;MODIFICATION HISTORY:
; Written by Tom Berger, LMSAL, 8.13.02
; Added reference point capability, TEB 8.16.02
; Bug fix for near the limb, S.MORITA, USRA/GSFC  8.20.04
; Bug fix for bug fix for near the limb, J.MCATEER, NRC/GSFC  2.24.05
; Moddified for a more general use, D.Perez-Suarez, TCD/HELIO 11.9.09
;       Bug fix for B0 calculation.
;       Info output option added.
;       Date standarization.
;-


;;!!!CHECK TIME (AND OTHER INPUTS) FORMAT!!!
progname='LAMBERT_PROJECT'
;Constants:
arcsec2rad = !DTOR/3600
sz =  SIZE(image)
xs =  sz[1]
ys =  sz[2]

;paramaters and keywords:
IF N_ELEMENTS(xyref) GT 0 THEN BEGIN
   xref = xyref[0,*]
   yref = xyref[1,*]
   refpoint = 1
END ELSE refpoint = 0

IF N_ELEMENTS(info) eq 0 THEN info=progname+' at '+systime() ELSE info=[info,progname+' at '+systime()]

IF KEYWORD_SET(phik) THEN phi = phik*!DTOR ELSE phi = 0.

;Get solar parameters for date of observation:
IF (KEYWORD_SET(DEBUG)) THEN print,(KEYWORD_SET(date)-KEYWORD_SET(b0)-KEYWORD_SET(RSUN))
CASE (KEYWORD_SET(date)-KEYWORD_SET(b0)-KEYWORD_SET(RSUN)) OF
    1: BEGIN
       ch_date=valid_time(date,err)+date_standard(date,err=err2)
       IF ch_date EQ 2 THEN BEGIN
          info=[info,progname+' DATE set: '+STRUPCASE(date)]
          rbp = PB0R(date,/arc,soho=soho)
          srad = DOUBLE(rbp[2])   ;solar radius in arcseconds
          b0 =  DOUBLE(rbp[1]*!DTOR) ;B0 angle in radians
       ENDIF ELSE BEGIN
          info=[info,progname+' error: '+err+' '+STRUPCASE(date),progname+' error: '+err2]
          IF (KEYWORD_SET(DEBUG)) THEN hprint,info
          return,-1
       ENDELSE

    END

    0: BEGIN
       IF (not KEYWORD_SET(DATE)) THEN BEGIN
          b0=0
          srad=(xs<ys)*pxs/2.  
         ; message,'using b0=0 and Rsun=whole image'
          ENDIF ELSE BEGIN
             PRINT,'You cannot set date and rsun or b0 all together. Exit...'
             info=[info,progname+' error:  Incorrect number of parameters']
             return,-1
          ENDELSE

    END

    -1: BEGIN
       IF (KEYWORD_SET(rsun) and (NOT KEYWORD_SET(DATE))) THEN BEGIN
          srad=rsun
          b0=0
       ENDIF ELSE IF (KEYWORD_SET(B0) and (NOT KEYWORD_SET(DATE))) THEN BEGIN
          B0=B0*!DTOR
          srad=(xs<ys)*pxs/2.
       ENDIF ELSE IF (KEYWORD_SET(DATE) AND (KEYWORD_SET(RSUN) OR KEYWORD_SET(B0))) THEN BEGIN
          print, 'You cannot set date and rsun or b0 all together. Exit...'
          info=[info,progname+' error:  Incorrect number of parameters']
          return,-1
       ENDIF
    END

    -2: BEGIN
       b0=b0*!DTOR
       srad=rsun
    END

ENDCASE

;p = 0                        ;NOTE! Assumes solar north is up in image! P
;angle = 0.
info=[info,progname+' b0='+string(b0),progname+' rsun='+string(srad)]
IF KEYWORD_SET(DEBUG) THEN hprint,info

;arcsec from DiskCenter (DC) arrays:
x =  (LINDGEN(xs, ys) MOD xs) - xs/2
x =  xycen[0] + pxs*x
y =  (LINDGEN(xs, ys)/xs) - ys/2
y =  xycen[1] + pxs*y
;rho1 and rho angles in SMART, "Spherical Astronomy", sec. 103
rho1 =  SQRT(x^2 + y^2)
offlimb =  WHERE(rho1 GT srad, noff)
rho1rad = rho1*arcsec2rad                  ; S. MORITA 20-Aug-2004
IF noff GT 0 THEN rho1[offlimb] =  -1e7
; rho =  ASIN((rho1/srad) > (-1)) - rho1*arcsec2rad
rho =  ASIN((rho1/srad) > (-1)) - rho1rad  ; S. MORITA 20-Aug-2004
;error in not using SIN(rho1)/SIN(srad) ~3.5x10-6 near the limb.
;IF noff GT 0 THEN rho[offlimb] = -1 ; S. MORITA 20-Aug-2004
IF noff GT 0 THEN rho[offlimb] = !pi ; S. MORITA 20-Aug-2004

theta = ATAN(DOUBLE(x),y)

;Smart, equation 43, sec. 103
slat = SIN(b0)*COS(rho) + COS(b0)*SIN(rho)*COS(theta)
bad = WHERE(slat GT 1.0d0,nb)
if nb GT 0 then slat[bad] = 1.0d0
bad = WHERE(slat LT -1.0d0,nb)
if nb GT 0 then slat[bad] = -1.0d0
lat = ASIN(slat)
;eqn. 44
slon =  SIN(rho)*SIN(theta)/COS(lat) ;sign of theta makes longitude decrease
;                                                          to -90 east of DC.
bad = WHERE(slon GT 1.0d0, nb)
IF nb GT 0 THEN slon[bad] = 1.0d0
bad =  WHERE(slon LT -1.0d0, nb)
IF nb GT 0 THEN slon[bad] = -1.d0
lon = ASIN(slon)


;Cylindrical projection:
;new x-values based on longitude, image pixel units:
;limit the projection to useful range:
lon = lon > (-80*!DTOR) < 80*!DTOR
lat = lat > (-80*!DTOR) < 80*!DTOR
xn = srad*lon*COS(phi)/pxs
yn = srad*SIN(lat)/COS(phi)/pxs

;Map all off-limb points to (0,0) to guard against runaway warping:
IF noff GT 0 THEN BEGIN
   xn[offlimb] = 0
   yn[offlimb] = 0
END

xn = FIX(xn - MIN(xn))
yn = FIX(yn - MIN(yn))

;Final range of values:
xr = MAX(xn) - MIN(xn) + 1
yr = MAX(yn) - MIN(yn) + 1

;Map all off-limb points to large number to guard against runaway warping:
IF noff GT 0 THEN BEGIN    
   xn[offlimb] = (2^15)-1       
   yn[offlimb] = (2^15)-1       
END                        


;; +  for test +++  S. MORITA 20-Aug-2004
;out=fltarr(max(xn)+1,max(yn)+1)
;
;for i=0,1023 do begin
;    for j=0, 1023 do begin
;        out(xn(i,j),yn(i,j)) = image(i,j)
;    endfor
;endfor
;; -  for test ---  S. MORITA 20-Aug-2004

;Get the DC and reference points in the new image:
xcen = xn[xs/2, ys/2]
ycen = yn[xs/2, ys/2]
xycen[0] = xycen[0] + (xcen - xr/2)*pxs
xycen[1] = xycen[1] + (ycen - yr/2)*pxs
IF refpoint THEN BEGIN
   xyref[0,*] = xn[xref, yref]
   xyref[1,*] = yn[xref, yref]
END

;Get the polynomial warping arrays:
;redo the coordinate arrays in image pixel coordinates:
x =  (LINDGEN(xs, ys) MOD xs)
y =  (LINDGEN(xs, ys)/xs)
;ni x ni subsampling of the arrays to speed things up:
ni = 100.
ngx = xs/ni
ngy = ys/ni
gx = ROUND( (FINDGEN(ni)*ngx + ngx/2)#(INTARR(ni)+1) )
gy = ROUND( (INTARR(ni)+1)#(FINDGEN(ni)*ngy + ngy/2) )
sam =  REFORM(gy*xs + gx, ni*ni)

sam=where(xn NE (2^15)-1)  ; and yn will be the same

;stop
POLYWARP, x[sam], y[sam], xn[sam], yn[sam], 3, p, q
;POLYWARP, x, y, xn, yn, 3, p, q

RETURN, POLY_2d(image, p, q, 2, xr, yr, CUBIC=-0.5)
END

