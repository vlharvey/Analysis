pro rd_geos5_1_dat,ifile,iflg,inlg,inlat,inlv,alon,alat,pp,zp,tp,up,vp,qp,pvp

inlg=96L	; 3.75 longitude
inlat=72L	; 2.5  latitude
inlv=72L	; 72   levels
iflg=0

; arrays go from 90   N to -90   S by 2.5  (73 lats)
;           and 0      to 360     by 3.75 (96 lons)
dx=3.75
alon=0.+dx*findgen(inlg)
alat=90.-2.5*findgen(inlat)

p=fltarr(inlg,inlat)
u=fltarr(inlg,inlat)
v=fltarr(inlg,inlat)
t=fltarr(inlg,inlat)
z=fltarr(inlg,inlat)
q=fltarr(inlg,inlat)
pv=fltarr(inlg,inlat)

pp=fltarr(inlg,inlat,inlv)
up=fltarr(inlg,inlat,inlv)
vp=fltarr(inlg,inlat,inlv)
tp=fltarr(inlg,inlat,inlv)
zp=fltarr(inlg,inlat,inlv)
qp=fltarr(inlg,inlat,inlv)
pvp=fltarr(inlg,inlat,inlv)

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
    readu,1,p,u,v,t,z,q,pv
;
; fill 3d arrays
;
    pp(0:inlg-1,0:inlat-1,k)=p(0:inlg-1,0:inlat-1)
    up(0:inlg-1,0:inlat-1,k)=u(0:inlg-1,0:inlat-1)
    vp(0:inlg-1,0:inlat-1,k)=v(0:inlg-1,0:inlat-1)
    tp(0:inlg-1,0:inlat-1,k)=t(0:inlg-1,0:inlat-1)
    zp(0:inlg-1,0:inlat-1,k)=z(0:inlg-1,0:inlat-1)
    qp(0:inlg-1,0:inlat-1,k)=q(0:inlg-1,0:inlat-1)
    pvp(0:inlg-1,0:inlat-1,k)=pv(0:inlg-1,0:inlat-1)
;print,p(10,10),u(10,10),v(10,10),t(10,10),z(10,10),q(10,10),pv(10,10)
endfor
close,1
jump:
end
