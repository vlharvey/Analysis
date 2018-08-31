;
; polar plot of PV
;
@stddat
@kgmt
@ckday
@kdate
@rd_waccm3_nc3

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
!NOERAS=-1
device,decompose=0
nxdim=700
nydim=700
xorig=[0.1]
yorig=[0.15]
xlen=0.8
ylen=0.8
cbaryoff=0.04
cbarydel=0.02
!NOERAS=-1
lstmn=1
lstdy=1
lstyr=1990
ledmn=1
leddy=1
ledyr=2004
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;print, ' '
;print, '     WACCM Version '
;print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 57 then lstyr=lstyr+2000
if ledyr lt 57 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1957 then stop,'Year out of range '
if ledyr lt 1957 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
mon=['jan','feb','mar','apr','may','jun',$
     'jul','aug','sep','oct','nov','dec']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
!noeras=1
dir='/aura7/harvey/WACCM_data/Datfiles/Datfiles_TNV3/wa3_tnv3_'

; Compute initial Julian date
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
      if iyr ge 2000L then iyr1=iyr-2000L
      if iyr lt 2000L then iyr1=iyr-1900L
      date=strcompress(string(FORMAT='(A3,A1,I2,A2,I4)',$
                              month(imn-1),' ',idy,', ',iyr))
      sdate=string(FORMAT='(i4.4,i2.2,i2.2,a4)',iyr,imn,idy)
      ifile=string(FORMAT='(i4.4,i2.2,i2.2,a4)',iyr,imn,idy,'.nc3')
      rd_waccm3_nc3,dir+ifile,nc,nr,nth,alon,alat,th,pv2,p2,$
         u2,v2,qdf2,mark2,sf2,o32,ch42,no22,h2o2,iflag
      if iflag eq 1 then goto,jump

; select theta level
;    if icount eq 0L then begin
;       rlev=4000.
;;      print,th
;;      read,'Enter theta surface ',rlev
;       zindex=where(th eq rlev)
;       ilev=zindex(0)
;       slev=strcompress(string(fix(th(ilev))),/remove_all)+'K'
;       icount=1L
;    endif
;for kk=0L,20 do begin
for kk=10L,10 do begin
rlev=th(kk)
zindex=where(th eq rlev)
ilev=zindex(0)
slev=strcompress(string(fix(th(ilev))),/remove_all)+'K'

; save postscript version
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='polar_wa3_pv_'+sdate+'_'+slev+'.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif

    speed2=sqrt(u2^2.+v2^2.)
    mark1=transpose(mark2(*,*,ilev))
    pv1=transpose(pv2(*,*,ilev))
    speed1=transpose(speed2(*,*,ilev))
    sf1=transpose(sf2(*,*,ilev))
    qdf1=transpose(qdf2(*,*,ilev))
    o31=transpose(o32(*,*,ilev))
    sf=0.*fltarr(nc+1,nr)
    sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
    sf(nc,*)=sf(0,*)
    speed=0.*fltarr(nc+1,nr)
    speed(0:nc-1,0:nr-1)=speed1(0:nc-1,0:nr-1)
    speed(nc,*)=speed(0,*)
    pv=0.*fltarr(nc+1,nr)
    pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
    pv(nc,*)=pv(0,*)
    mark=0.*fltarr(nc+1,nr)
    mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
    mark(nc,*)=mark(0,*)
    o3=0.*fltarr(nc+1,nr)
    o3(0:nc-1,0:nr-1)=o31(0:nc-1,0:nr-1)
    o3(nc,*)=o3(0,*)
    qdf=0.*fltarr(nc+1,nr)
    qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
    qdf(nc,*)=qdf(0,*)
    x=fltarr(nc+1)
    x(0:nc-1)=alon
    x(nc)=alon(0)+360.
x2d=0.*qdf
y2d=0.*qdf
for i=0L,nc do y2d(i,*)=alat
for j=0L,nr-1 do x2d(*,j)=x
    erase
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    MAP_SET,90,-90,0,/stereo,/noeras,/grid,/contin,title=date+' WACCM '+slev,charsize=1.5,color=0
    nlvls=19
    imin=0 & imax=max(pv)
    level=imin+((imax-imin)/float(nlvls))*findgen(nlvls)
    col1=1+indgen(nlvls)*icolmax/nlvls
    contour,pv,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
    contour,pv,x,alat,/overplot,levels=[7],/follow,c_labels=0*level,/noeras,color=0,thick=4
    contour,speed,x,alat,/overplot,levels=[50,75,100,125],color=mcolor,thick=2
;   contour,sf,x,alat,/overplot,nlevels=30,color=0
;loadct,0
;    contour,mark,x,alat,/overplot,levels=[0.1],thick=10,color=150
;    contour,mark,x,alat,/overplot,levels=[-0.1],thick=10,color=0
;loadct,38
;    index=where(qlevel lt 0.)
;    contour,qdf,x,alat,levels=qlevel(index),/follow,/overplot,color=mcolor
;    index=where(qlevel gt 0.)
;    contour,qdf,x,alat,levels=qlevel(index),/follow,/overplot,color=0
    MAP_SET,90,-90,0,/stereo,/noeras,/grid,/contin,charsize=1.5,color=0
    ymnb=yorig(0)-0.02
    ymxb=ymnb+cbarydel
    set_viewport,xorig(0),xorig(0)+xlen,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='PV (Km!u-2!nkg!u-1!ns!u-1!n)'
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(nlvls)
    for j=0,nlvls-1 do begin
      xbox=[x1,x1,x1+dx,x1+dx,x1]
      polyfill,xbox,ybox,color=col1(j)
      x1=x1+dx
    endfor

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert -trim polar_wa3_pv_'+sdate+'_'+slev+'.ps -rotate -90 polar_wa3_pv_'+sdate+'_'+slev+'.jpg'
       spawn,'/usr/bin/rm polar_wa3_pv_'+sdate+'_'+slev+'.ps'
    endif
endfor	; loop over altitude
goto, jump
end
