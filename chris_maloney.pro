pro fillit,cn,cnfill
result=size(cn)
nc=result(1)
nr=result(2)
nz=result(3)
cnfill2=cn
for i=0,nc-1 do begin
for j=0,nr-1 do begin
    dummy=reform(cnfill2(i,j,*),nz)
    good=where(dummy ne -9999.)
    bad=where(dummy eq -9999.)
    if good(0) ne -1 and bad(0) ne -1 then begin
       filled=interpol(dummy(good),good,bad)
       cnfill2(i,j,bad)=filled
    endif
endfor
endfor
cnfill=cnfill2

return
end
