pro rd_heat_nc,file1,nlg,nlat,nth,alon,alat,thlev,q,iflg
iflg=0
dum1=findfile(file1)
if dum1(0) ne '' then begin
   ncid=ncdf_open(file1)
   print,'opening ',file1
   goto,jump
endif
if dum1(0) eq '' then begin
   iflg=1
   return
endif
jump:
ncdf_diminq,ncid,0,name,nlat
ncdf_diminq,ncid,1,name,nlg
ncdf_diminq,ncid,2,name,nth
alon=fltarr(nlg)
alat=fltarr(nlat)
thlev=fltarr(nth)
q=fltarr(nlat,nlg,nth)
ncdf_varget,ncid,0,alon
ncdf_varget,ncid,1,alat
ncdf_varget,ncid,2,thlev
ncdf_varget,ncid,3,q
ncdf_close,ncid
end
