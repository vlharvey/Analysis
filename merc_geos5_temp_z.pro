;
; GEOS-5 merc plot of temperature interpolate to z
; use nc3 geos5 data
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto

loadct,39
device,decompose=0
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
icmm1=icolmax-1
icmm2=icolmax-2
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
!noeras=1
nxdim=750
nydim=750
xorig=[0.15]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.07
cbarydel=0.01
setplot='x'
read,'setplot=',setplot
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=icolmax
endif
dir='/aura7/harvey/GEOS5_data/Datfiles/'
stimes=[$
'_0000.V01.',$
'_0600.V01.',$
'_1200.V01.',$
'_1800.V01.']
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
lstmn=1
lstdy=15
lstyr=2008
ledmn=3
leddy=15
ledyr=2008
lstday=0
ledday=0
nlv=201L
altitude=findgen(nlv)
print,altitude
ilev=40L
;read,' Enter altitude ',ilev
salt=strcompress(ilev)
;
; Ask interactive questions- get starting/ending date and p surface
;
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=ledday-lstday+1L
;
; Compute initial Julian date
;
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
      if ndays gt ledday then stop
      if iyr ge 2000L then iyr1=iyr-2000L
      if iyr lt 2000L then iyr1=iyr-1900L
;
;***Read GEOS-5 data
;
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
      print,sdate
      ifile='DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'+sdate+stimes(0)+'nc3'
;
; read GEOS-5 data
;
      rd_geos5_nc3_meto,dir+ifile,nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag
      if iflag eq 1 then goto,jump
      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=alon(0)+360.
      t2=0.*pv2
      for k=0,nth-1 do t2(*,*,k)=th(k)*((p2(*,*,k)/1000.)^(.286))
      z2=(msf2-1004.*t2)/(9.86*1000.)
;
; interpolate GEOS temperature to SABER height surfaces
;
tpolar=fltarr(nc,nr)
upolar=fltarr(nc,nr)
zz=altitude(ilev)
for j=0L,nr-1L do begin
    for i=0L,nc-1L do begin
        zprof=reform(z2(j,i,*))
        for k=1L,nth-1L do begin
            zup=zprof(k-1) & zlw=zprof(k)
            if zup ge zz and zlw le zz then begin
               zscale=(zup-zz)/(zup-zlw)
               tpolar(i,j)=t2(j,i,k-1)+zscale*(t2(j,i,k)-t2(j,i,k-1))
               upolar(i,j)=u2(j,i,k-1)+zscale*(u2(j,i,k)-u2(j,i,k-1))
;print,zlw,zz,zup,zscale
;print,t2(j,i,k),tpolar(i,j),t2(j,i,k-1)
;stop
            endif
        endfor
    endfor
endfor
tpolar2=fltarr(nc+1,nr)
upolar2=fltarr(nc+1,nr)
tpolar2(0:nc-1,*)=tpolar
upolar2(0:nc-1,*)=tpolar
for j=0L,nr-1L do begin
    tpolar2(nc,*)=tpolar2(0,*)
    upolar2(nc,*)=upolar2(0,*)
endfor

if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='merc_geos5_temp_z_'+sdate+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
   !p.thick=2.0                   ;Plotted lines twice as thick
   !p.charsize=1.0
endif
;
; plot zonal mean zonal wind
;
erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
nlvls=19
col1=1+indgen(nlvls)*icolmax/nlvls
level=190.+5.*findgen(nlvls)
;map_set,0,0,0,/noeras,title='GEOS-5 '+sdate,color=0
contour,tpolar2,x,alat,/noeras,/fill,c_color=col1,levels=level,yrange=[0.,90.],color=0,$
        ytitle='Latitude',yticks=6,xtitle='Longitude',title='GEOS-5 '+sdate
contour,tpolar2,x,alat,/noeras,/overplot,/follow,color=0,levels=level
map_set,0,0,0,/noeras,/grid,/contin,color=0,limit=[0.,0.,90.,360.]
imin=min(level)
imax=max(level)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle=salt+' km Temperature (K)'
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for jj=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(jj)
x1=x1+dx
endfor

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim merc_geos5_temp_z_'+sdate+'.ps -rotate -90 merc_geos5_temp_z_'+sdate+'.jpg'
endif

icount=icount+1L
goto,jump

end
