;
; GEOS-5 SABER, MLS, and HIRDLS polar projections
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
xorig=[0.1,0.4,0.7,0.1,0.4,0.7,0.1,0.4,0.7]
yorig=[0.7,0.7,0.7,0.45,0.45,0.45,0.2,0.2,0.2]
xlen=0.2
ylen=0.2
cbaryoff=0.02
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/aura7/harvey/GEOS5_data/Datfiles/'
sdir='/aura6/data/SABER_data/Datfiles/'
mdir='/aura6/data/MLS_data/Datfiles_SOSST/'
hdir='/aura6/data/HIRDLS_data/Datfiles_SOSST/'
stimes=[$
'_AVG.V01.']
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
lstmn=7
lstdy=15
lstyr=2009
ledmn=7
leddy=15
ledyr=2009
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
      ifile='DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'+sdate+stimes(0)+'nc3'
;
; read GEOS-5 data
;
      rd_geos5_nc3_meto,dir+ifile,nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag
      if iflag eq 1 then begin
      ifile='DAS.ops.asm.tavg3d_dyn_v.GEOS520.MetO.'+sdate+stimes(0)+'nc3'
;
; read GEOS-5 data
;
      rd_geos5_nc3_meto,dir+ifile,nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag
      if iflag eq 1 then goto,jump
      endif
      index=where(mark2 lt -1.)
      if index(0) ne -1L then mark2(index)=mark2(index)/abs(mark2(index))
      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=alon(0)+360.
      t2=0.*pv2
      for k=0,nth-1 do t2(*,*,k)=th(k)*((p2(*,*,k)/1000.)^(.286))
      z2=(msf2-1004.*t2)/(9.86*1000.)
;
; restore tpd_hirdls_v2.04.19_20080614.sav file
;
; ALTITUDE        FLOAT     = Array[121]
; COMMENT         STRING    = Array[7]
; DENTOT          FLOAT     = Array[3494, 121]
; ID              STRING    = Array[3494]
; PRESSURE        FLOAT     = Array[3494, 121]
; TEMPERATURE     FLOAT     = Array[3494, 121]
; TEMPERATURE_ERROR
; TEMPERATURE_MASK
;
    dum=findfile(hdir+'tpd_hirdls_v2.04.19_'+sdate+'.sav')
    if dum(0) eq '' then goto,jump
    restore,hdir+'tpd_hirdls_v2.04.19_'+sdate+'.sav'
    restore,hdir+'cat_hirdls_v2.04.19_'+sdate+'.sav'    ; latitude
print,'cat_hirdls_v2.04.19_'+sdate+'.sav'
    nlvh=n_elements(altitude)
    if icount eq 0 then begin
      theta0=55.
;      print,altitude
;      read,'Enter altitude ',theta0
       index=where(theta0 eq altitude)
       if index(0) eq -1 then stop,'Invalid theta level '
       thlev0h=index(0)
       icount=1
    endif
;
; bin HIRDLS temperature by lonbin/latbin
;
      hirdls3d=fltarr(nlon,nlat,nlvh)
      nhirdls3d=lonarr(nlon,nlat,nlvh)
      nprof=n_elements(fdoy)
      for iprof=0L,nprof-1L do begin
;     for k=0L,nlvh-1L do begin
      for k=thlev0h,thlev0h do begin        ; increase speed
          if latitude(iprof) lt -90. then goto,skiplev1h
          xlat=latitude(iprof) & xlon=longitude(iprof)
          for j=0L,nlat-1L do begin
              if xlat ge latbin(j)-dy/2. and xlat lt latbin(j)+dy/2. then begin
                 for i=0L,nlon-1L do begin
                     if xlon ge lonbin(i)-dx/2. and xlon lt lonbin(i)+dx/2. then begin
                        hirdls3d(i,j,k)=hirdls3d(i,j,k)+TEMPERATURE(iprof,k)
                        nhirdls3d(i,j,k)=nhirdls3d(i,j,k)+1L
                     endif
                 endfor
              endif
          endfor
          skiplev1h:
      endfor
      endfor
      index=where(nhirdls3d gt 0L)
      if index(0) ne -1L then hirdls3d(index)=hirdls3d(index)/float(nhirdls3d(index))
;
; restore MLS dmp_mls_v2.2.geos5.20080614.sav file
;
; ALTITUDE        FLOAT     = Array[121]
; COMMENT         STRING    = Array[7]
; DENTOT          FLOAT     = Array[3494, 121]
; ID              STRING    = Array[3494]
; PRESSURE        FLOAT     = Array[3494, 121]
; TEMPERATURE     FLOAT     = Array[3494, 121]
; TEMPERATURE_ERROR
; TEMPERATURE_MASK
;
    dum=findfile(mdir+'tpd_mls_v2.2_'+sdate+'.sav')
    if dum(0) eq '' then goto,jump
    restore,mdir+'tpd_mls_v2.2_'+sdate+'.sav'
    restore,mdir+'cat_mls_v2.2_'+sdate+'.sav'   ; latitude
    print,'cat_mls_v2.2_'+sdate+'.sav'
    index=where(theta0 eq altitude)
    if index(0) eq -1 then stop,'Invalid theta level '
    thlev0m=index(0)
    nlvm=n_elements(altitude)
;
; bin MLS temperature by lonbin/latbin
;
      mls3d=fltarr(nlon,nlat,nlvm)
      nmls3d=lonarr(nlon,nlat,nlvm)
      nprof=n_elements(fdoy)
      for iprof=0L,nprof-1L do begin
;     for k=0L,nlvm-1L do begin
      for k=thlev0m,thlev0m do begin        ; increase speed
          if latitude(iprof) lt -90. then goto,skiplev1
          xlat=latitude(iprof) & xlon=longitude(iprof)
          for j=0L,nlat-1L do begin
              if xlat ge latbin(j)-dy/2. and xlat lt latbin(j)+dy/2. then begin
                 for i=0L,nlon-1L do begin
                     if xlon ge lonbin(i)-dx/2. and xlon lt lonbin(i)+dx/2. then begin
                        mls3d(i,j,k)=mls3d(i,j,k)+TEMPERATURE(iprof,k)
                        nmls3d(i,j,k)=nmls3d(i,j,k)+1L
                     endif
                 endfor
              endif
          endfor
          skiplev1:
      endfor
      endfor
      index=where(nmls3d gt 0L)
      if index(0) ne -1L then mls3d(index)=mls3d(index)/float(nmls3d(index))
;
; read SABER data
;
      dum=findfile(sdir+'SABER_TPZ_'+sdate+'.sav')
      if dum(0) eq '' then goto,jump
      restore,sdir+'SABER_TPZ_'+sdate+'.sav'
print,'SABER_TPZ_'+sdate+'.sav'
      index=where(theta0 eq altitude)
      if index(0) eq -1 then stop,'Invalid theta level '
      thlev=index(0)
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
;
;
; interpolate GEOS temperature to altitude surfaces
;
      nlv=n_elements(altitude)
      t2z=fltarr(nr,nc,nlv)
      mark2z=fltarr(nr,nc,nlv)
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
                 mark2z(j,i,kk)=mark2(j,i,k-1)+zscale*(mark2(j,i,k)-mark2(j,i,k-1))
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
;
; bin GEOS temperature by lonbin/latbin
;
      geos3d=fltarr(nlon,nlat,nlv)
      markgeos3d=fltarr(nlon,nlat,nlv)
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
                        markgeos3d(i,j,k)=markgeos3d(i,j,k)+mark2z(jj,ii,k)
                        ngeos3d(i,j,k)=ngeos3d(i,j,k)+1L
                     endif
                  endfor
                  endif
              endfor
          endfor
          endfor
      endfor
      index=where(ngeos3d gt 0L)
      if index(0) ne -1L then begin
         geos3d(index)=geos3d(index)/float(ngeos3d(index))
         markgeos3d(index)=markgeos3d(index)/float(ngeos3d(index))
      endif

      stheta=strcompress(string(fix(theta0)),/remove_all)
      sabert1=saber3d(*,*,thlev)
      mlst1=mls3d(*,*,thlev0m)
      hirdlst1=hirdls3d(*,*,thlev0h)
      geost1=geos3d(*,*,thlev)
      geosmark1=markgeos3d(*,*,thlev)
      sabert=0.*fltarr(nlon+1,nlat)
      sabert(0:nlon-1,0:nlat-1)=sabert1(0:nlon-1,0:nlat-1)
      sabert(nlon,*)=sabert(0,*)
      mlst=0.*fltarr(nlon+1,nlat)
      mlst(0:nlon-1,0:nlat-1)=mlst1(0:nlon-1,0:nlat-1)
      mlst(nlon,*)=mlst(0,*)
      hirdlst=0.*fltarr(nlon+1,nlat)
      hirdlst(0:nlon-1,0:nlat-1)=hirdlst1(0:nlon-1,0:nlat-1)
      hirdlst(nlon,*)=hirdlst(0,*)
      geost=0.*fltarr(nlon+1,nlat)
      geost(0:nlon-1,0:nlat-1)=geost1(0:nlon-1,0:nlat-1)
      geost(nlon,*)=geost(0,*)
      geosmark=0.*fltarr(nlon+1,nlat)
      geosmark(0:nlon-1,0:nlat-1)=geosmark1(0:nlon-1,0:nlat-1)
      geosmark(nlon,*)=geosmark(0,*)

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
                 filename='polar_temp+mark_geos5-saber_mls_hirdls_'+sdate+'_'+stheta+'km.ps'
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
xyouts,0.45,0.95,sdate,charsize=1.5,charthick=2,/normal
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='GEOS-5',charsize=1.5
nlvls=19
col1=1+indgen(nlvls)*icolmax/nlvls
level=180.+5.*findgen(nlvls)
contour,geost,x,latbin,/overplot,levels=level,c_color=col1,thick=1,/cell_fill,/noeras
contour,geost,x,latbin,/overplot,levels=level,/follow,color=0,c_labels=0*level
contour,geosmark,x,latbin,/overplot,levels=[0.5],/follow,color=0,thick=5
contour,geosmark,x,latbin,/overplot,levels=[-0.75],/follow,color=mcolor,thick=5
MAP_SET,90,0,-90,/ortho,/noeras,/contin

xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
!psym=0
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='SABER',charsize=1.5
contour,sabert,x,latbin,/overplot,levels=level,c_color=col1,thick=1,/cell_fill,/noeras
contour,sabert,x,latbin,/overplot,levels=level,/follow,color=0,c_labels=0*level
contour,geosmark,x,latbin,/overplot,levels=[0.5],/follow,color=0,thick=5
contour,geosmark,x,latbin,/overplot,levels=[-0.75],/follow,color=mcolor,thick=5
MAP_SET,90,0,-90,/ortho,/noeras,/contin

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
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='GEOS-SABER',charsize=1.5
contour,pdiff,x,latbin,/overplot,charsize=1.5,levels=level,/cell_fill,c_color=col2,color=0,min_value=-99.
contour,pdiff,x,latbin,/overplot,levels=level,color=0,/follow,min_value=-99.,$
        c_labels=0*level
contour,pdiff,x,latbin,/overplot,levels=[0],color=0,thick=1,min_value=-99.
contour,geosmark,x,latbin,/overplot,levels=[0.5],/follow,color=0,thick=5
contour,geosmark,x,latbin,/overplot,levels=[-0.75],/follow,color=mcolor,thick=5
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin
;
; MLS
;
loadct,39
xmn=xorig(3)
xmx=xorig(3)+xlen
ymn=yorig(3)
ymx=yorig(3)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
!psym=0
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='GEOS-5',charsize=1.5
nlvls=19
col1=1+indgen(nlvls)*icolmax/nlvls
level=180.+5.*findgen(nlvls)
contour,geost,x,latbin,/overplot,levels=level,c_color=col1,thick=1,/cell_fill,/noeras
contour,geost,x,latbin,/overplot,levels=level,/follow,color=0,c_labels=0*level
contour,geosmark,x,latbin,/overplot,levels=[0.5],/follow,color=0,thick=5
contour,geosmark,x,latbin,/overplot,levels=[-0.75],/follow,color=mcolor,thick=5
MAP_SET,90,0,-90,/ortho,/noeras,/contin

xmn=xorig(4)
xmx=xorig(4)+xlen
ymn=yorig(4)
ymx=yorig(4)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
!psym=0
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='MLS',charsize=1.5
contour,mlst,x,latbin,/overplot,levels=level,c_color=col1,thick=1,/cell_fill,/noeras
contour,mlst,x,latbin,/overplot,levels=level,/follow,color=0,c_labels=0*level
contour,geosmark,x,latbin,/overplot,levels=[0.5],/follow,color=0,thick=5
contour,geosmark,x,latbin,/overplot,levels=[-0.75],/follow,color=mcolor,thick=5
MAP_SET,90,0,-90,/ortho,/noeras,/contin
;
; superimpose pdiff
;
restore,'c11_rb.tbl'
tvlct,c1,c2,c3
col2=1+indgen(11)
pdiff=-99.+0.*mlst
index=where(mlst gt 0. and geost gt 0.)
if index(0) eq -1L then goto,jump
pdiff(index)=geost(index)-mlst(index)
level=-20.+4.*findgen(11)
!type=2^2+2^3
xmn=xorig(5)
xmx=xorig(5)+xlen
ymn=yorig(5)
ymx=yorig(5)+ylen
set_viewport,xmn,xmx,ymn,ymx
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='GEOS-MLS',charsize=1.5
contour,pdiff,x,latbin,/overplot,charsize=1.5,levels=level,/cell_fill,c_color=col2,color=0,min_value=-99.
contour,pdiff,x,latbin,/overplot,levels=level,color=0,/follow,min_value=-99.,$
        c_labels=0*level
contour,pdiff,x,latbin,/overplot,levels=[0],color=0,thick=1,min_value=-99.
contour,geosmark,x,latbin,/overplot,levels=[0.5],/follow,color=0,thick=5
contour,geosmark,x,latbin,/overplot,levels=[-0.75],/follow,color=mcolor,thick=5
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin
loadct,39
;
; HIRDLS
;
xmn=xorig(6)
xmx=xorig(6)+xlen
ymn=yorig(6)
ymx=yorig(6)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
!psym=0
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='GEOS-5',charsize=1.5
nlvls=19
col1=1+indgen(nlvls)*icolmax/nlvls
level=180.+5.*findgen(nlvls)
contour,geost,x,latbin,/overplot,levels=level,c_color=col1,thick=1,/cell_fill,/noeras
contour,geost,x,latbin,/overplot,levels=level,/follow,color=0,c_labels=0*level
contour,geosmark,x,latbin,/overplot,levels=[0.5],/follow,color=0,thick=5
contour,geosmark,x,latbin,/overplot,levels=[-0.75],/follow,color=mcolor,thick=5
MAP_SET,90,0,-90,/ortho,/noeras,/contin
imin=min(level)
imax=max(level)
xmn=xorig(6)
xmx=xorig(6)+xlen
ymnb=yorig(6) -cbaryoff
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
;
xmn=xorig(7)
xmx=xorig(7)+xlen
ymn=yorig(7)
ymx=yorig(7)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
!psym=0
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='HIRDLS',charsize=1.5
contour,hirdlst,x,latbin,/overplot,levels=level,c_color=col1,thick=1,/cell_fill,/noeras
contour,hirdlst,x,latbin,/overplot,levels=level,/follow,color=0,c_labels=0*level
contour,geosmark,x,latbin,/overplot,levels=[0.5],/follow,color=0,thick=5
contour,geosmark,x,latbin,/overplot,levels=[-0.75],/follow,color=mcolor,thick=5
MAP_SET,90,0,-90,/ortho,/noeras,/contin
imin=min(level)
imax=max(level)
xmn=xorig(7)
xmx=xorig(7)+xlen
ymnb=yorig(7) -cbaryoff
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
;; superimpose pdiff
restore,'c11_rb.tbl'
tvlct,c1,c2,c3
col2=1+indgen(11)
pdiff=-99.+0.*hirdlst
index=where(hirdlst gt 0. and geost gt 0.)
if index(0) eq -1L then goto,jump
pdiff(index)=geost(index)-hirdlst(index)
level=-20.+4.*findgen(11)
!type=2^2+2^3
xmn=xorig(8)
xmx=xorig(8)+xlen
ymn=yorig(8)
ymx=yorig(8)+ylen
set_viewport,xmn,xmx,ymn,ymx
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='GEOS-HIRDLS',charsize=1.5
contour,pdiff,x,latbin,/overplot,charsize=1.5,levels=level,/cell_fill,c_color=col2,color=0,min_value=-99.
contour,pdiff,x,latbin,/overplot,levels=level,color=0,/follow,min_value=-99.,$
        c_labels=0*level
contour,pdiff,x,latbin,/overplot,levels=[0],color=0,thick=1,min_value=-99.
contour,geosmark,x,latbin,/overplot,levels=[0.5],/follow,color=0,thick=5
contour,geosmark,x,latbin,/overplot,levels=[-0.75],/follow,color=mcolor,thick=5
MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin
xmn=xorig(8)
xmx=xorig(8)+xlen
imin=min(level)
imax=max(level)
ymnb=ymn -cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,$
      xtitle=stheta+' km Differences (K)',xticks=n_elements(level)/2
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
       spawn,'convert -trim polar_temp+mark_geos5-saber_mls_hirdls_'+sdate+'_'+stheta+'km.ps -rotate -90 polar_temp+mark_geos5-saber_mls_hirdls_'+sdate+'_'+stheta+'km.jpg'
    endif
goto,jump
end
