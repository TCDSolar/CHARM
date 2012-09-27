function copy_order,localfile=localfile,remotefile=remotefile,to=to,from=from,grid=grid
 if keyword_set(to) then begin
      cp_grid='lcg-cr --vo vo.helio-vo.eu file:'+localfile+' -l lfn:'+remotefile
      cp_local='cp '+localfile+' '+remotefile
 endif
 if keyword_set(from) then begin
      cp_grid='lcg-cp --vo vo.helio-vo.eu lfn:'+remotefile+ ' file:'+localfile
      cp_local='cp '+remotefile+' '+localfile
 endif
 cp_command=(keyword_set(grid))?cp_grid:cp_local
 return,cp_command
end
