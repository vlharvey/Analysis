pro rd_ukmo_nc,file1,nlg,nlat,nth,alon,alat,thlev,ipv,prs,msf,u,v,q,qdf,iflg
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
ipv=fltarr(nlat,nlg,nth)
prs=fltarr(nlat,nlg,nth)
msf=fltarr(nlat,nlg,nth)
u=fltarr(nlat,nlg,nth)
v=fltarr(nlat,nlg,nth)
q=fltarr(nlat,nlg,nth)
qdf=fltarr(nlat,nlg,nth)
ncdf_varget,ncid,0,alon
print,alon
ncdf_varget,ncid,1,alat
print,alat
ncdf_varget,ncid,2,thlev
print,thlev
ncdf_varget,ncid,3,ipv
print,reform(ipv(10,10,*))
ncdf_varget,ncid,4,prs
print,reform(prs(10,10,*))
ncdf_varget,ncid,5,msf
ncdf_varget,ncid,6,u
ncdf_varget,ncid,7,v
ncdf_varget,ncid,8,qdf
ncdf_close,ncid
end
