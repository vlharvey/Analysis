pro rd_rigby_dat,ifile,iflg,inlg,inlat,inlv,alon,alat,wlon,wlat,p,zp,tp,up,vp

inlg=96L	; 3.75 longitude
inlat=72L	; 2.5  latitude
inlv=23L	; 23   levels
iflg=0

; t,z,q go from 90   N to -90   S by 2.5  (73 lats)
;           and 0      to 360     by 3.75 (96 lons)
; winds go from 88.75N to -88.75S by 2.5  (72 lats)
;           and 1.875  to 358.125 by 3.75 (96 lons)
dx=3.75
alon=1.875+dx*findgen(inlg)
alat=88.75-2.5*findgen(inlat)
wlon=1.875+dx*findgen(inlg)
wlat=88.75-2.5*findgen(inlat)
p=fltarr(inlv)

u=fltarr(inlg,inlat)	; winds go from 88.75 to -88.75
v=fltarr(inlg,inlat)
t=fltarr(inlg,inlat)    ; T and Z have been interpolated to wind grid
z=fltarr(inlg,inlat)
up=fltarr(inlg,inlat,inlv)
vp=fltarr(inlg,inlat,inlv)
tp=fltarr(inlg,inlat,inlv)
zp=fltarr(inlg,inlat,inlv)

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
    readu,1,u,v,t,z
;
; fill 3d arrays
;
    up(0:inlg-1,0:inlat-1,k)=u(0:inlg-1,0:inlat-1)
    vp(0:inlg-1,0:inlat-1,k)=v(0:inlg-1,0:inlat-1)
    tp(0:inlg-1,0:inlat-1,k)=t(0:inlg-1,0:inlat-1)
    zp(0:inlg-1,0:inlat-1,k)=z(0:inlg-1,0:inlat-1)
;print,plevel,up(10,10,k),vp(10,10,k),tp(10,10,k),zp(10,10,k)
endfor
close,1
jump:
end
