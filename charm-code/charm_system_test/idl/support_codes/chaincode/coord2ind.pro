function coord2ind,array_coord,array
;+
; NAME:
;         COORD2IND
;
; PURPOSE:
;         Obtains the 1D pixel coordinate form a 2D or 3D array.
;
;
; PROJECT:
;
;       HELIO (HELiophysics Integrated Observatory)
;       Solar Feature Catalog
;
; CALLING SEQUENCE:
;         indices = coord2ind(coord,array)
;
; INPUT
;         coord      set of coordinates for which position want to be
;                    known in the array.
;         array      2D or 3D array in which the position want to be known.
;
; OUTPUTS
;         Output is the position of those coordinates.
;
; AUTHOR:
;
;       David Perez-Suarez
;       ARG
;       Trinity College Dublin (TCD)
;       Ireland
;       E-mail: dps.helio -at- gmail.com
;       This program is free software; you can redistribute it and/or modify it under the terms of the
;       GNU General Public License as published by the Free Software Foundation;
;
; HISTORY:
;         Created by DPS. May 2010
;-
sz=size(array)

if sz[0] eq 1 then indices=sz[1] lt 3 ? (array_coord[1,*]*array[0])+array_coord[0,*]: $
                           array_coord[2,*]*(array[0]*array[1])+(array_coord[1,*]*array[0])+array_coord[0,*]
if sz[0] eq 2 then indices=(array_coord[1,*]*sz[1])+array_coord[0,*]
if sz[0] eq 3 then indices=array_coord[2,*]*(sz[1]*sz[2])+(array_coord[1,*]*sz[1])+array_coord[0,*]



return,reform(indices)
end
