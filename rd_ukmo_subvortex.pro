pro rd_ukmo_subvortex,file1,nc,nr,nth,alon,alat,th,mark
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
stop
jump:
nr=0L
nc=0L
nth=0L
ncdf_diminq,ncid,0,name,nr
ncdf_diminq,ncid,1,name,nc
ncdf_diminq,ncid,2,name,nth
alon=fltarr(nc)
alat=fltarr(nr)
th=fltarr(nth)
mark=fltarr(nr,nc,nth)
ncdf_varget,ncid,0,alon
ncdf_varget,ncid,1,alat
ncdf_varget,ncid,2,th
ncdf_varget,ncid,3,mark
ncdf_close,ncid
return
end
