pro rd_winds_nc,file1,nlg,nlat,nlev,alon,alat,press,u,v,w,theta,iflg
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
ncdf_diminq,ncid,0,name,nlg
ncdf_diminq,ncid,1,name,nlat
ncdf_diminq,ncid,2,name,nlev
alon=fltarr(nlg)
alat=fltarr(nlat)
press=fltarr(nlev)
u=fltarr(nlat,nlg,nlev)
v=fltarr(nlat,nlg,nlev)
w=fltarr(nlat,nlg,nlev)
theta=fltarr(nlat,nlg,nlev)
ncdf_varget,ncid,0,alon
ncdf_varget,ncid,1,alat
ncdf_varget,ncid,2,press
ncdf_varget,ncid,3,u
ncdf_varget,ncid,4,v
ncdf_varget,ncid,5,w
ncdf_varget,ncid,6,th
ncdf_close,ncid
end
