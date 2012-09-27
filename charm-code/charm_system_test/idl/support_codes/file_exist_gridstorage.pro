function file_exist_gridstorage,paths,verbose=verbose
 input_paths=paths
 n=n_elements(input_paths)
 out=bytarr(n)

 for i=0,n-1 do begin
    if keyword_set(verbose) then print,'%% FILE_EXIST_GRIDSTORAGE: checking '+paths[i]
    spawn,'lfc-ls '+paths[i],lsout,/stderr
    out[i]=((strpos(lsout,'No such file or directory'))[0] eq -1)?1:0
    if keyword_set(verbose) then print,'%% FILE_EXIST_GRIDSTORAGE: File/directory ',paths[i],(out[i] eq 1b)?' Exists':' Do not exist'
 endfor

 return,out
end
