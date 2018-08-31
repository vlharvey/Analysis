pro rd_geos5_dat_origp,ifile,iflg,inlg,inlat,inlv,alon,alat,height,pp,zp,tp,up,vp,qp,pvp

inlg=96L	; 3.75 longitude
inlat=72L	; 2.5  latitude
inlv=72L	; 72   levels
iflg=0
;
; arrays have been interpolate to wind grid by 
; "step1_convert_geos5.1_hdf2dat_meto_origp.pro"
;
dx=3.75
alon=1.875+dx*findgen(inlg)
alat=88.75-2.5*findgen(inlat)
height=float(inlv)-findgen(inlv)

u=fltarr(inlg,inlat)
v=fltarr(inlg,inlat)
t=fltarr(inlg,inlat)
z=fltarr(inlg,inlat)
q=fltarr(inlg,inlat)
p=fltarr(inlg,inlat)
pv=fltarr(inlg,inlat)

up=fltarr(inlg,inlat,inlv)
vp=fltarr(inlg,inlat,inlv)
tp=fltarr(inlg,inlat,inlv)
zp=fltarr(inlg,inlat,inlv)
qp=fltarr(inlg,inlat,inlv)
pp=fltarr(inlg,inlat,inlv)
pvp=fltarr(inlg,inlat,inlv)

close,1
openr,1,ifile,/f77,ERROR=err
print,'Opening '+ifile

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
    readu,1,p,u,v,t,z,q,pv	;u,v,t,z,q
;
; fill 3d arrays
;
    up(*,*,k)=u
    vp(*,*,k)=v
    tp(*,*,k)=t
    zp(*,*,k)=z
    qp(*,*,k)=q
    pp(*,*,k)=p
    pvp(*,*,k)=pv
print,height(k),pp(0,0,k),up(0,0,k),vp(0,0,k),tp(0,0,k),zp(0,0,k),qp(0,0,k),pvp(0,0,k)
endfor
close,1
jump:
end
