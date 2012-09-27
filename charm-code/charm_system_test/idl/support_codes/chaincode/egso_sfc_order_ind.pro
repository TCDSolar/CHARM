;+
; NAME:
;         EGSO_SFC_ORDER_IND
;
; PURPOSE:
;         
;   Order subscripts of a 1 pixel thick chain (ex:pruned skeleton)
;   from a first one to the successive neighbors
;   In the case of a boundary (ie no end points), the first point
;   is the smallest indice
;   Pixels MUST be M-connected (see egso_sfc_m_connect)             
; 
; AUTHOR:
;
;       Fuller Nicolas
;       LESIA / POLE SOLAIRE
;       Observatoire de MEUDON
;       5 place Jules Janssen
;       92190 MEUDON
;       E-mail: nicolas.fuller@obspm.fr
;       copyright (C) 2005 Nicolas Fuller, Observatoire de Paris
;       This program is free software; you can redistribute it and/or modify it under the terms of the
;       GNU General Public License as published by the Free Software Foundation;
;
; PROJECT:
;
;       EGSO (European Grid of Solar Observations)
;       Solar Feature Catalog 
;
; CALLING SEQUENCE:
;         res = egso_sfc_order_ind(indices,xsize,ysize)
;
; INPUT
;         indices      subscripts of non-null pixels
;         xsize        1st dim of the array
;         ysize        2nd dim of the array
;
; OUTPUTS
;         Output is the ordered input array
;
; HISTORY:
;
;       NF Mar 2005 last rev.
;-

FUNCTION EGSO_SFC_ORDER_IND,indices,xsize,ysize

  ind        = indices
  nele       = N_ELEMENTS(ind)
  order      = LONARR(nele,/NOZERO)

  ;#### Give a value to each connected pixel function of its
  ;#### neighbors count
  valuesmap  = EGSO_SFC_PIXCUMUL(ind,xsize,ysize) ;(value 2 or 3)

  IF nele LT 2 THEN RETURN,-1

  IF MAX(valuesmap) GT 3 THEN BEGIN
     PRINT,'EGSO_SFC_ORDER_IND: Not a pruned or m_connected pixel chain!'
     RETALL
  ENDIF

  where2     = WHERE(valuesmap EQ 2,nv) ;(end points)
  
  ;#### if boundary, change it to skeleton
  IF nv NE 2 THEN BEGIN 
    ind        = ind[1:nele-1]
    nele       = nele-1
    order      = LONARR(nele,/NOZERO)
    valuesmap  = EGSO_SFC_PIXCUMUL(ind,xsize,ysize) 
    where2     = WHERE(valuesmap EQ 2,nv)
    lake       = 1
  ENDIF ELSE lake = 0

  ;#### Check the neighborhood of each pixel to find
  ;#### the next one 
  set = [-xsize-1,-xsize,-xsize+1,-1,1,xsize-1,xsize,1+xsize]
  order[nele-1] = where2[1] 
  ep = where2[0]

  FOR ii=0,nele-2 DO BEGIN
   order[ii]     = ep
   valuesmap[ep] = 0
   wnewpt        = WHERE(valuesmap[set+ep])
   ep            = ep + set[wnewpt[0]]
  ENDFOR

  IF lake EQ 1 THEN order=[indices[0],order]

RETURN,order
END
