;
; bin SABER temperature on lon/lat grid and look for geographical 
; pattern to T differences with G5
; G5 temperature and vortex edge
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto

ipan=0
npp=1
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,39
device,decompose=0
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
setplot='ps'
read,'setplot=',setplot
nxdim=750
nydim=750
xorig=[0.1,0.4,0.7]
yorig=[0.4,0.4,0.4]
xlen=0.25
ylen=0.25
cbaryoff=0.05
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/aura7/harvey/GEOS5_data/Datfiles/'
sdir='/aura6/data/SABER_data/Datfiles/'
stimes=[$
'_AVG.V01.']
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
nlat=35L
latbin=-85+5.*findgen(nlat)
dy=latbin(1)-latbin(0)
nlon=12L
lonbin=15.+30.*findgen(nlon)
dx=lonbin(1)-lonbin(0)
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
; read SABER data
;
      dum=findfile(sdir+'SABER_TPZ_'+sdate+'.sav')
      if dum(0) eq '' then goto,jump
      restore,sdir+'SABER_TPZ_'+sdate+'.sav'
      if icount eq 0 then begin
         theta=30.
         print,altitude
         read,'Enter altitude ',theta
         index=where(theta eq altitude)
         if index(0) eq -1 then stop,'Invalid theta level '
         thlev=index(0)
         icount=1
      endif
      nlv=n_elements(altitude)
      nprof=n_elements(mode)
;
; bin SABER temperature by lonbin/latbin
;
      saber3d=fltarr(nlon,nlat,nlv)
      nsaber3d=lonarr(nlon,nlat,nlv)
      for iprof=0L,nprof-1L do begin
;     for k=0L,nlv-1L do begin
      for k=thlev,thlev do begin	; increase speed
          if latitude(iprof,k) lt -90. then goto,skiplev
          xlat=latitude(iprof,k) & xlon=longitude(iprof,k)
          for j=0L,nlat-1L do begin
              if xlat ge latbin(j)-dy/2. and xlat lt latbin(j)+dy/2. then begin
                 for i=0L,nlon-1L do begin
                     if xlon ge lonbin(i)-dx/2. and xlon lt lonbin(i)+dx/2. then begin
                        saber3d(i,j,k)=saber3d(i,j,k)+TEMPERATURE(iprof,k)
                        nsaber3d(i,j,k)=nsaber3d(i,j,k)+1L
                     endif
                 endfor
              endif
          endfor
          skiplev:
      endfor
      endfor
      index=where(nsaber3d gt 0L)
      if index(0) ne -1L then saber3d(index)=saber3d(index)/float(nsaber3d(index))
print,'binned saber'
;
;
; interpolate GEOS temperature to altitude surfaces
;
      nlv=n_elements(altitude)
      t2z=fltarr(nr,nc,nlv)
;     for kk=0L,nlv-1L do begin
      for kk=thlev,thlev do begin  ; increase speed
      zz=altitude(kk)
      if max(z2) lt zz then goto,jumplev
      for j=0L,nr-1L do begin
      for i=0L,nc-1L do begin
          for k=1L,nth-1L do begin
              zup=z2(j,i,k-1) & zlw=z2(j,i,k)
              if zup ne 0. and zlw ne 0. then begin
              if zup ge zz and zlw le zz then begin
                 zscale=(zup-zz)/(zup-zlw)
                 t2z(j,i,kk)=t2(j,i,k-1)+zscale*(t2(j,i,k)-t2(j,i,k-1))
;print,zlw,zz,zup,zscale
;print,t2(j,i,k),t2z(j,i,kk),t2(j,i,k-1)
;stop
              endif
              endif
          endfor
      endfor
      endfor
      jumplev:
      endfor
print,'interpolated geos to z'
;
; bin GEOS temperature by lonbin/latbin
;
      geos3d=fltarr(nlon,nlat,nlv)
      ngeos3d=lonarr(nlon,nlat,nlv)
;     for k=0L,nlv-1L do begin
      for k=thlev,thlev do begin  ; increase speed
          for j=0L,nlat-1L do begin
          for i=0L,nlon-1L do begin
              for jj=0L,nr-1L do begin
                  if alat(jj) ge latbin(j)-dy/2. and alat(jj) lt latbin(j)+dy/2. then begin
                  for ii=0L,nc-1L do begin
                     if alon(ii) ge lonbin(i)-dx/2. and alon(ii) lt lonbin(i)+dx/2. then begin
                        geos3d(i,j,k)=geos3d(i,j,k)+t2z(jj,ii,k)
                        ngeos3d(i,j,k)=ngeos3d(i,j,k)+1L
                     endif
                  endfor
                  endif
              endfor
          endfor
          endfor
      endfor
      index=where(ngeos3d gt 0L)
      if index(0) ne -1L then geos3d(index)=geos3d(index)/float(ngeos3d(index))
print,'binned geos'

      stheta=strcompress(string(fix(theta)),/remove_all)
      sabert1=saber3d(*,*,thlev)
      geost1=geos3d(*,*,thlev)
      sabert=0.*fltarr(nlon+1,nlat)
      sabert(0:nlon-1,0:nlat-1)=sabert1(0:nlon-1,0:nlat-1)
      sabert(nlon,*)=sabert(0,*)
      geost=0.*fltarr(nlon+1,nlat)
      geost(0:nlon-1,0:nlat-1)=geost1(0:nlon-1,0:nlat-1)
      geost(nlon,*)=geost(0,*)
      x=fltarr(nlon+1)
      x(0:nlon-1)=lonbin
      x(nlon)=lonbin(0)+360.

      if ipan eq 0 and setplot eq 'ps' then begin
         lc=0
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
;        !p.font=0
         device,font_size=9
         device,/landscape,bits=8,$
                 filename='polar_temp+mark_geos5-saber_'+sdate+'_'+stheta+'km.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
      endif

erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
!psym=0
xyouts,.45,.72,sdate,charsize=2,/normal
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='GEOS-5',charsize=2.0
nlvls=19
col1=1+indgen(nlvls)*icolmax/nlvls
level=180.+5.*findgen(nlvls)
contour,geost,x,latbin,/overplot,levels=level,c_color=col1,thick=1,/cell_fill,/noeras
contour,geost,x,latbin,/overplot,levels=level,/follow,color=0,c_labels=0*level
MAP_SET,90,0,-90,/ortho,/noeras,/contin
imin=min(level)
imax=max(level)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle=stheta+' km Temperature (K)'
ybox=[0,10,10,0,0]
x1=imin
dxx=(imax-imin)/float(nlvls)
for jj=0,nlvls-1 do begin
xbox=[x1,x1,x1+dxx,x1+dxx,x1]
polyfill,xbox,ybox,color=col1(jj)
x1=x1+dxx
endfor

xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
!psym=0
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='SABER',charsize=2.0
contour,sabert,x,latbin,/overplot,levels=level,c_color=col1,thick=1,/cell_fill,/noeras
contour,sabert,x,latbin,/overplot,levels=level,/follow,color=0,c_labels=0*level
MAP_SET,90,0,-90,/ortho,/noeras,/contin
imin=min(level)
imax=max(level)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle=stheta+' km Temperature (K)'
ybox=[0,10,10,0,0]
x1=imin
dxx=(imax-imin)/float(nlvls)
for jj=0,nlvls-1 do begin
xbox=[x1,x1,x1+dxx,x1+dxx,x1]
polyfill,xbox,ybox,color=col1(jj)
x1=x1+dxx
endfor

; superimpose pdiff
;
restore,'c11_rb.tbl'
tvlct,c1,c2,c3
col2=1+indgen(11)
pdiff=-99.+0.*sabert
index=where(sabert gt 0. and geost gt 0.)
if index(0) eq -1L then goto,jump
pdiff(index)=geost(index)-sabert(index)
level=-20.+4.*findgen(11)
!type=2^2+2^3
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='GEOS-SABER',charsize=2.0
contour,pdiff,x,latbin,/overplot,charsize=1.5,levels=level,/cell_fill,c_color=col2,color=0,min_value=-99.
contour,pdiff,x,latbin,/overplot,levels=level,color=0,/follow,min_value=-99.,$
        c_labels=0*level
contour,pdiff,x,latbin,/overplot,levels=[0],color=0,thick=1,min_value=-99.
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin
imin=min(level)
imax=max(level)
ymnb=ymn -cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,$
      xtitle='(K)',xticks=n_elements(level)/2
ybox=[0,10,10,0,0]
x2=imin
dxx=(imax-imin)/(float(n_elements(col2)))
for jj=0L,n_elements(col2)-1 do begin
    xbox=[x2,x2,x2+dxx,x2+dxx,x2]
    polyfill,xbox,ybox,color=col2(jj)
    x2=x2+dxx
endfor
loadct,39

   if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim polar_temp+mark_geos5-saber_'+sdate+'_'+stheta+'km.ps -rotate -90 polar_temp+mark_geos5-saber_'+sdate+'_'+stheta+'km.jpg'
    endif
goto,jump
end
