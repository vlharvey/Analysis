pro rd_ecmwf,ifile,iflg,nc,nr,nl,alon,alat,press,pv,gp,tp,uu,vv,ww,sh,oz
nc=0L & nr=0L & nl=0L & iflg=0L
close,1
openr,1,ifile,/f77,ERROR=err
print,'Opening ',ifile
if err ne 0 then begin
   printf, -2, !ERR_STRING
   iflg = 1
   goto, jump
endif
readu,1,nc,nr,nl
alon=fltarr(nc)
alat=fltarr(nr)
press=fltarr(nl)
pv=fltarr(nc,nr,nl)
gp=fltarr(nc,nr,nl)
tp=fltarr(nc,nr,nl)
uu=fltarr(nc,nr,nl)
vv=fltarr(nc,nr,nl)
ww=fltarr(nc,nr,nl)
sh=fltarr(nc,nr,nl)
oz=fltarr(nc,nr,nl)
readu,1,alon,alat,press
readu,1,pv,gp,tp,uu,vv,ww,sh,oz
close,1
jump:
return
end
