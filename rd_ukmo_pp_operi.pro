pro rd_ukmo_pp_operi,ifile,iflg,inlg,inlat,inlv,alon,alat,wlon,wlat,p,zp,tp,up,vp

inlg=96L	; 3.75 longitude
inlat=73L	; 2.5  latitude
inlv=22L	; 25   levels
iflg=0

; t,z,q go from 90   N to -90   S by 2.5  (73 lats)
;           and 0      to 360     by 3.75 (96 lons)
; winds go from 88.75N to -88.75S by 2.5  (72 lats)
;           and 1.875  to 358.125 by 3.75 (96 lons)
dx=3.75
alon=0.+dx*findgen(inlg)
alat=90.-2.5*findgen(inlat)
wlon=1.875+dx*findgen(inlg)
wlat=88.75-2.5*findgen(inlat-1)
p=fltarr(inlv)

u=fltarr(inlg,inlat-1)	; winds go from 88.75 to -88.75
v=fltarr(inlg,inlat-1)
t=fltarr(inlg,inlat)	; T and Z go from pole to pole
z=fltarr(inlg,inlat)
up=fltarr(inlg,inlat-1,inlv)
vp=fltarr(inlg,inlat-1,inlv)
tp=fltarr(inlg,inlat,inlv)
zp=fltarr(inlg,inlat,inlv)

close,1
openr,1,ifile,/f77,ERROR=err
;print,'Opening ',ifile

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
;   print,' plevel=',plevel
    readu,1,u,v,t,z
;
; fill 3d arrays
;
    up(0:inlg-1,0:inlat-2,k)=u(0:inlg-1,0:inlat-2)
    vp(0:inlg-1,0:inlat-2,k)=v(0:inlg-1,0:inlat-2)
    tp(0:inlg-1,0:inlat-1,k)=t(0:inlg-1,0:inlat-1)
    zp(0:inlg-1,0:inlat-1,k)=z(0:inlg-1,0:inlat-1)
;print,up(0,0,k),vp(0,0,k),tp(0,0,k),zp(0,0,k)
endfor
close,1
jump:
end
