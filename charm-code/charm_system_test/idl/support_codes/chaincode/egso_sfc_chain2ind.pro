; +
; NAME:
;         EGSO_SFC_CHAIN2IND
;
; PURPOSE:
;
;          From a first point (first) and a chain code (chainc),
;          find the corresponding indices in the array
;          of size (xsize,ysize)  
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
;
;         res = egso_sfc_chain2ind(first,chainc,xsize,ysize)
;
; INPUT
;
;         first  is the coordinates of the pixel corresponding to
;                to the chain starting position
;
;         chainc is the chain code (string) 
;
;         xsize and ysize are the sizes of the array where the
;               chain code is displayed
; 
; OUTPUTS
;         subscripts in an array (xsize*ysize) of the chain code positions
;
;
; KEYWORDS
;         START_RIGHT set if chain code 0 direction is right instead
;         of left (see EGSO_SFC_CHAIN_CODE)
;
; EXAMPLE
;   
;  IDL> ind1 = EGSO_SFC_CHAIN2IND([10,10],'6666666666',50,50)
;  IDL> ind2 = EGSO_SFC_CHAIN2IND([14,10],'66666666664443332222111000',50,50)
;  IDL> ind3 = EGSO_SFC_CHAIN2IND([29,10],'444442222222222',50,50,/start_r)
;  IDL> imi = BYTARR(50,50)                                                  
;  IDL> imi[[ind1,ind2,ind3]] = 1b                                           
;  IDL> TVSCL,REBIN(imi,200,200,/SAMPLE) 
;
; HISTORY:
;
;         NF Last revision Mar 2005
;-

FUNCTION EGSO_SFC_CHAIN2IND,first,chainc,xsize,ysize,START_RIGHT=start_right


   ind    = first[1]*LONG(xsize) + first[0]
   length = STRLEN(chainc)
   set    = [-1,-xsize-1,-xsize,-xsize+1,1,xsize+1,xsize,xsize-1]
   IF KEYWORD_SET(START_RIGHT) THEN set = -1*set
   newind = ind

   FOR jj = 0,length-1 DO BEGIN
      next   = FIX(STRMID(chainc,jj,1))
      newind = newind + set[next]
      ind    = [ind,newind]
   ENDFOR      
   
RETURN,ind
END

