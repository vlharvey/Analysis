
; check new nc data

@rd_ukmo_nc
@rd_ukmo_nc3
@stddat
@kgmt
@ckday
@kdate
@date2uars

loadct,38
mcolor=byte(!p.color)
device,decompose=0
icmm1=mcolor-1B
icmm2=mcolor-2B
!noeras=1
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=750
nydim=750
xorig=[0.10,0.10]
yorig=[0.60,0.15]
xlen=0.8
ylen=0.3
cbaryoff=0.06
cbarydel=0.02
!NOERAS=-1
SETPLOT='ps'
read,'setplot',setplot
if setplot ne 'ps' then begin
   lc=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
uday=0L & lstday=0L & ledday=0L
lstmn=10L & lstdy=28L & lstyr=3L 
ledmn=2L & leddy=28L & ledyr=5L
mon=['jan_','feb_','mar_','apr_','may_','jun_','jul_','aug_','sep_','oct_','nov_','dec_']
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
;
; this logic will work through 2090
;
if lstyr ge 91 and lstyr le 99 then lstyr=lstyr+1900
if ledyr ge 91 and ledyr le 99 then ledyr=ledyr+1900
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
      if iyr lt 2000 then iyr1=iyr-1900
      if iyr ge 2000 then iyr1=iyr-2000
      syr=string(FORMAT='(I2.2)',iyr1)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      ifile=mon(imn-1)+sdy+'_'+syr
      rd_ukmo_nc,dir+ifile+'.nc',nc,nr,nth,alon,alat,th,pv1,p1,msf1,u1,v1,q1,qdf1,iflag
      rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth3,alon,alat,th3,pv3,p3,msf3,u3,v3,q3,qdf3,mark3,vp3,sf3,iflag

for ilev=8,8L do begin
    pgrd1=transpose(q1(*,*,ilev))
index=where(abs(th3-th(ilev)) eq min(abs(th3-th(ilev))))
    pgrd3=transpose(q3(*,*,index(0)))

    stheta=strtrim(string(th(ilev)),2)
    stheta3=strtrim(string(th3(index(0))),2)
    nlvls=21
    imin=min(pgrd1) & imax=max(pgrd1)
    level=imin+((imax-imin)/float(nlvls))*findgen(nlvls)
    col1=1+indgen(nlvls)*mcolor/nlvls

    !noeras=1
    erase
    xyouts,.4,.95,syr+smn+sdy,/normal,charsize=3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    contour,pgrd1,alon,alat,levels=level,/fill,/cell_fill,c_color=col1,/noeras,$
        title='Rosenfield Diabatic Heating '+stheta+' K',xtitle='Longitude',ytitle='Latitude',$
        xticks=6,yrange=[-90.,90.],xrange=[0.,360.]
    index=where(level gt 0.)
    if index(0) ne -1L then contour,pgrd1,alon,alat,levels=level(index),/follow,c_color=mcolor,c_linestyle=1,/overplot,/noeras
    index=where(level lt 0.)
    if index(0) ne -1L then contour,pgrd1,alon,alat,levels=level(index),/follow,c_color=0,c_linestyle=0,/overplot,/noeras
    contour,pgrd1,alon,alat,levels=[0],/follow,c_color=0,thick=3,c_linestyle=0,/overplot,/noeras

    map_set,0,180,0,/grid,/contin,/noeras 
imin=min(level)
imax=max(level)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],charsize=1.5
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
endfor

;   imin=min(pgrd3) & imax=max(pgrd3)
;   level=imin+((imax-imin)/float(nlvls))*findgen(nlvls)
    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    contour,pgrd3,alon,alat,levels=level,/fill,/cell_fill,c_color=col1,/noeras,$
        title='Shine Diabatic Heating '+stheta3+' K',xtitle='Longitude',ytitle='Latitude',$
        xticks=6,yrange=[-90.,90.],xrange=[0.,360.]
    index=where(level gt 0.)
    if index(0) ne -1L then contour,pgrd3,alon,alat,levels=level(index),/follow,c_color=mcolor,c_linestyle=1,/overplot,/noeras
    index=where(level lt 0.)
    if index(0) ne -1L then contour,pgrd3,alon,alat,levels=level(index),/follow,c_color=0,c_linestyle=0,/overplot,/noeras
    contour,pgrd3,alon,alat,levels=[0],/follow,c_color=0,thick=3,c_linestyle=0,/overplot,/noeras
    map_set,0,180,0,/grid,/contin,/noeras 
imin=min(level)
imax=max(level)
ymnb=yorig(1) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],charsize=1.5
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
endfor

endfor
wait,.1
goto,jump
end
