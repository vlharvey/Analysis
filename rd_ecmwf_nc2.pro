pro rd_ecmwf_nc2,file1,nc,nr,nth,alon,alat,thlev,$
    ipv,prs,msf,u,v,q,qdf,vp,sf,sh,o3,iflg
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
nr=0L & nc=0L & nth=0L
ncdf_diminq,ncid,0,name,nr
ncdf_diminq,ncid,1,name,nc
ncdf_diminq,ncid,2,name,nth
alon=fltarr(nc)
alat=fltarr(nr)
thlev=fltarr(nth)
ipv=fltarr(nr,nc,nth)
prs=fltarr(nr,nc,nth)
msf=fltarr(nr,nc,nth)
u=fltarr(nr,nc,nth)
v=fltarr(nr,nc,nth)
q=fltarr(nr,nc,nth)
qdf=fltarr(nr,nc,nth)
vp=fltarr(nr,nc,nth)
sf=fltarr(nr,nc,nth)
sh=fltarr(nr,nc,nth)
o3=fltarr(nr,nc,nth)
ncdf_varget,ncid,0,alon
ncdf_varget,ncid,1,alat
ncdf_varget,ncid,2,thlev
print,alon,alat,thlev
ncdf_varget,ncid,3,ipv
ncdf_varget,ncid,4,prs
ncdf_varget,ncid,5,msf
ncdf_varget,ncid,6,u
ncdf_varget,ncid,7,v
ncdf_varget,ncid,8,q
ncdf_varget,ncid,9,qdf
ncdf_varget,ncid,10,vp
ncdf_varget,ncid,11,sf
ncdf_varget,ncid,12,sh
ncdf_varget,ncid,13,o3
ncdf_close,ncid
end
