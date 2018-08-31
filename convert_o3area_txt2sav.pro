@stddat
@kgmt
@ckday
@kdate

close,1
openr,1,'o3hole_area.txt'
dum=' '
readf,1,dum
print,dum
readf,1,dum
print,dum  
readf,1,dum
print,dum  
readf,1,dum
print,dum  
readf,1,dum
print,dum  
readf,1,dum
print,dum  
syear=0L
smon=0L
sday=0L
o3area=0.
o3min=0.
icount=0L
while not eof(1) do begin
    readf,1,syear,smon,sday,o3area,o3min
    print,syear,smon,sday,o3area,o3min

    if icount ne 0L then begin
       syear_all=[syear_all,syear]
       smon_all=[smon_all,smon]
       sday_all=[sday_all,sday]
       o3area_all=[o3area_all,o3area]
       o3min_all=[o3min_all,o3min]
       icount=1L
    endif
    if icount eq 0L then begin
       syear_all=syear
       smon_all=smon
       sday_all=sday
       o3area_all=o3area
       o3min_all=o3min
       icount=1L
    endif
endwhile
close,1
;
; calculate dfs for PMC plot
;
sdates_all=string(FORMAT='(I4)',syear_all)+string(FORMAT='(I2.2)',smon_all)+string(FORMAT='(I2.2)',sday_all)
nn=n_elements(sdates_all)
fdoy=fltarr(nn)
dfs=fltarr(nn)
for i=0L,nn-1L do begin
    iyr=long(strmid(sdates_all(i),0,4))
    imn=long(strmid(sdates_all(i),4,2))
    idy=long(strmid(sdates_all(i),6,2))
    z = kgmt(imn,idy,iyr,iday)
    fdoy(i)=1.0*iday
    kyr=iyr
    if fdoy(i) lt 182. then kyr=iyr-1
    jdaysol=JULDAY(12,21,kyr)
    dfs(i)=JULDAY(imn,idy,iyr)-jdaysol
endfor
save,filename='o3hole_area.sav',dfs,fdoy,sdates_all,o3area_all
end
