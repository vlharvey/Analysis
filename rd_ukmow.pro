pro rd_ukmow,ifile,iflg,inlg,inlat,inlv,alon,alat,wlon,wlat,p,zp,tp,up,vp,wp

inlg=96L	; 3.75 longitude
inlat=73L	; 2.5  latitude
inlv=22L	; 22   levels (25 after October 2003)
iflg=0

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
w=fltarr(inlg,inlat)
up=fltarr(inlg,inlat-1,inlv)
vp=fltarr(inlg,inlat-1,inlv)
tp=fltarr(inlg,inlat,inlv)
zp=fltarr(inlg,inlat,inlv)
wp=fltarr(inlg,inlat,inlv)

close,1
openr,1,ifile,/f77,ERROR=err

; --- If data is not available on disk then return
if err ne 0 then begin
   printf, -2, !ERR_STRING
   iflg = 1
   goto, jump
endif
;
;  loop over pressure
;
for k=0L,inlv-1L do begin
    readu,1,plevel
    p(k)=plevel
    readu,1,u,v,t,z,w
;
; fill 3d arrays
;
    up(0:inlg-1,0:inlat-2,k)=u(0:inlg-1,0:inlat-2)
    vp(0:inlg-1,0:inlat-2,k)=v(0:inlg-1,0:inlat-2)
    tp(0:inlg-1,0:inlat-1,k)=t(0:inlg-1,0:inlat-1)
    zp(0:inlg-1,0:inlat-1,k)=z(0:inlg-1,0:inlat-1)
    wp(0:inlg-1,0:inlat-1,k)=w(0:inlg-1,0:inlat-1)
endfor
close,1
jump:
return
end
