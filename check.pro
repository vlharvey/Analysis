
; debug write
;
openr,109,'fort.109',/f77
nc=0l
nr=0l
nl=0l
readu,109,nc,nr,nl
alat=fltarr(nr)
alon=fltarr(nc)
p=fltarr(nl)
thl=fltarr(nc,nr,nl) 
readu,109,alon,alat,p
readu,109,thl
stop

openr,99,'fort.99',/f77
nlat=0l
nlg=0l
nth=0l
readu,99,nlat,nlg,nth
alat=fltarr(nlat)
alon=fltarr(nlg)
thlev=fltarr(nth)
ipvgrd=fltarr(nlat,nlg,nth) 
pgrd=fltarr(nlat,nlg,nth) 
msfgrd=fltarr(nlat,nlg,nth) 
ugrd=fltarr(nlat,nlg,nth) 
vgrd=fltarr(nlat,nlg,nth) 
qgrd=fltarr(nlat,nlg,nth) 
qdfgrd=fltarr(nlat,nlg,nth) 
readu,99,alat,alon,thlev
readu,99,IPVGRD,PGRD,MSFGRD,UGRD,VGRD,QGRD,QDFGRD 
stop
end 
