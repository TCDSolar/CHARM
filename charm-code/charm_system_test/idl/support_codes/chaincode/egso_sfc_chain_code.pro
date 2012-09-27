;+
; NAME:
;         EGSO_SFC_CHAIN_CODE
;
; PURPOSE:
;         Computes the chain code (freeman's code) of the 
;         chain pixels corresponding to indices. Could be
;         a boundary or a pruned skeleton
;         subscripts MUST be ordered (egso_sfc_order_ind)
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
;         res = egso_sfc_chain_code(indices,xsize,ysize
;                [,START_RIGHT=start_right])
;
; INPUT
;         indices      subscripts of non-null pixels
;         xsize        1st dim of the array
;         ysize        2nd dim of the array
;
;
; OUTPUTS
;         Output is the chain code array
;
; KEYWORD
;         START_RIGHT see explainations below
;
; HISTORY:
;         NF last revision Mar 2005
;-

FUNCTION EGSO_SFC_CHAIN_CODE,indices,xsize,ysize,START_RIGHT=start_right

   
   nele  = N_ELEMENTS(indices)
   chain = BYTARR(nele)+255b

   ;#### We compute the coordinates difference corresponding
   ;#### to the original subscripts and the shifted subscripts, ie
   ;#### btw 1 pixel and its neighbor

   tab1  = SHIFT(indices,-1)
   tab2  = indices
    
   difX  = tab1 MOD FIX(xsize) - tab2 MOD FIX(xsize)
   difY  = tab1 / FIX(xsize)   - tab2 / FIX(xsize)

   ;#### We define numbers corresponding to each direction
   ;#### in trigonometric way, starting on the right or left
   ;####
   ;####  right 3 2 1  left   7 6 5  
   ;####        4 x 0         0 x 4
   ;####        5 6 7         1 2 3
   ;####
   ;#### ex: direction 7 corresponds to
   ;####     dx=1  and dy=-1 (right)
   ;####     dx=-1 and dy=1  (left)

   IF KEYWORD_SET(START_RIGHT) THEN BEGIN
     trigoX = [1, 1, 0,-1,-1,-1, 0, 1] ;trigo starts right
     trigoY = [0, 1, 1, 1, 0,-1,-1,-1]
   ENDIF ELSE BEGIN 
     trigoX = [-1,-1, 0, 1, 1, 1, 0,-1] ;trigo starts left
     trigoY = [ 0,-1,-1,-1, 0, 1, 1, 1]
   ENDELSE


   FOR ii = 0,7 DO BEGIN
    wt = WHERE(difX EQ trigoX[ii] AND difY EQ trigoY[ii],nt)
    IF nt GT 0 THEN chain[wt]=ii
   ENDFOR

  ;#### Discard last difference for skeletons
   chain = chain[WHERE(chain NE 255b)]

RETURN,chain

END
