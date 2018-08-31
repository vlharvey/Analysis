pro rd_nogaps_dat,ifile,iflg,inlg,inlat,inlv,alon,alat,p,zp,tp,up,vp,pv,o3,h2o

inlg=96L	; 3.75 longitude
inlat=72L	; 2.5  latitude
inlv=60L	; 60   levels
iflg=0
dx=3.75
alon=0.+dx*findgen(inlg)
alat=88.75-2.5*findgen(inlat)
p=fltarr(inlv)

u=fltarr(inlg,inlat)
v=fltarr(inlg,inlat)
t=fltarr(inlg,inlat)
z=fltarr(inlg,inlat)
pv1=fltarr(inlg,inlat)
o31=fltarr(inlg,inlat)
h2o1=fltarr(inlg,inlat)
up=fltarr(inlg,inlat,inlv)
vp=fltarr(inlg,inlat,inlv)
tp=fltarr(inlg,inlat,inlv)
zp=fltarr(inlg,inlat,inlv)
pv=fltarr(inlg,inlat,inlv)
o3=fltarr(inlg,inlat,inlv)
h2o=fltarr(inlg,inlat,inlv)

close,1
openr,1,ifile,/f77,ERROR=err
print,'Opening ',ifile

; --- If data is not available on disk then return
if err ne 0 then begin
   printf, -2, !ERR_STRING
   iflg = 1
   goto, jump
endif
;
;  loop over pressure
;
for k=0,inlv-1 do begin
    readu,1,plevel
    p(k)=plevel
    readu,1,u,v,t,z,pv1,o31,h2o1
;
; fill 3d arrays
;
    up(*,*,k)=u
    vp(*,*,k)=v
    tp(*,*,k)=t
    zp(*,*,k)=z
    pv(*,*,k)=pv1
    o3(*,*,k)=o31
    h2o(*,*,k)=h2o1
print,plevel,up(0,0,k),vp(0,0,k),tp(0,0,k),zp(0,0,k),pv(0,0,k),o3(0,0,k),h2o(0,0,k)
endfor
close,1
jump:
end
