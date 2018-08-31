;
; compare MERRA and MLS winds
;
@stddat
@kgmt
@ckday
@kdate
@rd_merra_nc3

sver='v3.3'

a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
loadct,39
mcolor=!p.color
icolmax=byte(!p.color)
icmm1=icolmax-1B
icmm2=icolmax-2B
device,decompose=0
!NOERAS=-1
!P.FONT=1
!p.charsize=1
!p.charthick=2
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.1,0.55,0.1,0.55]
yorig=[0.55,0.55,0.125,0.125]
xlen=0.325
ylen=0.325
cbaryoff=0.01
cbarydel=0.02
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_press_'
dirm='/Volumes/atmos/aura6/data/MLS_data/Datfiles_SOSST/'
dirm2='/Volumes/earth/aura6/data/MLS_data/Datfiles_Grid/MLS_grid5_ALL_'

lstmn=1
lstdy=1
lstyr=2006
ledmn=2
leddy=28
ledyr=2006
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;print, ' '
;print, '      MERRA Version '
;print, ' '
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
;
; oct through march only
;
      if iday gt 90 and iday lt 274 then goto,jumpday

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' normal termination condition '
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
;
; Read MERRA
;
        ncfile0='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'+sdate+'.nc3'
        rd_merra_nc3,ncfile0,nc,nr,nth,alon,alat,th,pv2,p2,$
           u2,v2,qdf2,mark2,qv2,z2,sf2,q2,iflag
      restore,dir+sdate+'.sav'
;mark1=reform(transpose(mark2(*,*,10)))	; 3000
mark1=reform(transpose(mark2(*,*,5)))	; 4000
;mark1=reform(transpose(mark2(*,*,0)))	; 5000
      alat=LATITUDE_WACCM
      nth=n_elements(pressure)
      nr=n_elements(LATITUDE_WACCM)
      nc=n_elements(LONGITUDE_WACCM)
u2=ugrd
v2=vgrd
      sp2=sqrt(u2^2.+v2^2.)
;
; declare arrays and select surfaces
;
      if icount eq 0 then begin
;        print,th
         plev=0.1
;        read,' Enter desired pressure surface ',plev
         index=where(abs(pressure-plev) eq min(abs(pressure-plev)))
         ilev=index(0)
         slev=strcompress(plev,/remove_all)
alon=LONGITUDE_WACCM
alat=LATITUDE_WACCM
;        print,alon
         rlon1=150.
;        read,' Enter longitude ',rlon1
         index1=where(alon eq rlon1)
         if index1(0) eq -1 then stop,'Bad Longitude'
         ilon1=index1(0)
         rlon2=rlon1+180.
         if rlon2 gt max(alon) then rlon2=rlon2-360.
         index2=where(alon eq rlon2)
         ilon2=index2(0)
         slon1=string(format='(f7.3)',rlon1)+'E'
         slon2=string(format='(f7.3)',rlon2)+'E'
         print,'longitudes ',rlon1,rlon2
         x=fltarr(nc+1)
         x(0:nc-1)=alon(0:nc-1)
         x(nc)=alon(0)+360.
         x2d=fltarr(nc,nr)
         y2d=fltarr(nc,nr)
         for i=0,nc-1 do y2d(i,*)=alat
         for j=0,nr-1 do x2d(*,j)=alon
         xyz=fltarr(nr,nth)
         yyz=fltarr(nr,nth)
         for i=0,nr-1 do yyz(i,*)=pressure
         for j=0,nth-1 do xyz(*,j)=alat 
      endif
      index=where(abs(pressure-plev) eq min(abs(pressure-plev)))
      ilev=index(0)
      sp1=reform(u2(*,*,ilev))
;
; restore MLS gridded data
;
    restore,dirm2+sver+'_'+sdate+'.sav'
    restore,'/Volumes/earth/aura6/data/MLS_data/Datfiles_Grid/MLS_grid5_U_V_'+sver+'_'+sdate+'.sav'
    index=where(finite(u) eq 1 and finite(v) eq 1)
    mlsspeed=0.*u
    if index(0) ne -1L then mlsspeed(index)=sqrt(u(index)^2.+v(index)^2.)
    index=where(abs(pmls2-plev) eq min(abs(pmls2-plev)))
    ilev=index(0)
;   mlsspeed1=reform(mlsspeed(*,*,ilev))
    mlsspeed1=reform(u(*,*,ilev))
    h2o=reform(h2o_grid(*,*,ilev))*1.e6
    index=where(abs(pmls-plev) eq min(abs(pmls-plev)))
    ilev=index(0)
    co=reform(co_grid(*,*,ilev))*1.e6

;
    if setplot eq 'ps' then begin
       lc=0
       xsize=nxdim/100.
       ysize=nydim/100.
       set_plot,'ps'
       device,/color,/landscape,bits=8,filename='polar_merra_mls_wind_'+sdate+'_'+slev+'.ps'
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif
;
; plot
;
    erase
    xyouts,.4,.95,sdate+' '+slev+' hPa',/normal,color=0,charsize=3
    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    imin=-100.
    imax=100.
    int=10
    nlvls=21
    col1=1+indgen(nlvls)*icolmax/nlvls
    level=imin+int*findgen(nlvls)
    map_set,90,0,-90,/ortho,/contin,/grid,/noerase,color=0,title='MERRA',label=1,lonlab=10.,latlab=0,latdel=10.,londel=45.,charsize=1.5
    contour,sp1,alon,alat,levels=level,c_color=col1,/cell_fill,/overplot,/noeras
    contour,sp1,alon,alat,levels=level,color=0,/follow,/overplot,/noeras
    index=where(level lt 0)
    contour,sp1,alon,alat,levels=level(index),color=mcolor,/overplot,/noeras,/follow,c_linestyle=5
    map_set,90,0,-90,/ortho,/contin,/grid,/noerase,color=0,label=1,lonlab=10.,latlab=0,latdel=10.,londel=45.,charsize=1.5
    contour,mark1,alon,alat,levels=[0.1],color=0,/follow,/overplot,/noeras,thick=10,c_labels=[0]
    imin=min(level)
    imax=max(level)
    set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],$
          xrange=[imin,imax],xtitle='m/s',/noeras,$
          xstyle=1,charsize=1.25,color=0,charthick=5
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(nlvls)
    for j=0,nlvls-1 do begin
      xbox=[x1,x1,x1+dx,x1+dx,x1]
      polyfill,xbox,ybox,color=col1(j)
      x1=x1+dx
    endfor

    !type=2^2+2^3
    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,90,0,-90,/ortho,/contin,/grid,/noerase,color=0,title='MLS',label=1,lonlab=10.,latlab=0,latdel=10.,londel=45.,charsize=1.5
    contour,mlsspeed1,alon,alat,levels=level,c_color=col1,/cell_fill,/overplot,/noeras
    contour,mlsspeed1,alon,alat,levels=level,color=0,/follow,/overplot,/noeras
    index=where(level lt 0)
    contour,mlsspeed1,alon,alat,levels=level(index),color=mcolor,/overplot,/noeras,/follow,c_linestyle=5
    map_set,90,0,-90,/ortho,/contin,/grid,/noerase,color=0,label=1,lonlab=10.,latlab=0,latdel=10.,londel=45.,charsize=1.5
    imin=min(level)
    imax=max(level)
    set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],$
          xrange=[imin,imax],xtitle='m/s',/noeras,$
          xstyle=1,charsize=1.25,color=0,charthick=5
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(nlvls)
    for j=0,nlvls-1 do begin
      xbox=[x1,x1,x1+dx,x1+dx,x1]
      polyfill,xbox,ybox,color=col1(j)
      x1=x1+dx
    endfor

    !type=2^2+2^3
    xmn=xorig(2)
    xmx=xorig(2)+xlen
    ymn=yorig(2)
    ymx=yorig(2)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    level=[0.01,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,1.25,1.5,2,2.5,3,4,5,6,7]		; good at 0.1
;   level=[0.01,0.1,0.25,0.5,1,1.5,2,2.5,3,4,5,6,7,10,15,20,30,50]		; good at 0.01
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*icolmax/nlvls
    map_set,90,0,-90,/ortho,/contin,/grid,/noerase,color=0,title='MLS CO',label=1,lonlab=10.,latlab=0,latdel=10.,londel=45.,charsize=1.5
co=smooth(co,5,/edge_truncate)
    contour,co,alon,alat,levels=level,c_color=col1,/cell_fill,/overplot,/noeras
    contour,co,alon,alat,levels=level,color=0,/follow,/overplot,/noeras
index=where(y2d gt 20.)
index2=where(mlsspeed1(index) eq max(mlsspeed1(index)))
coval=co(index(index2(0)))
print,mlsspeed1(index(index2(0))),coval
    contour,co,alon,alat,levels=[coval],color=0,/follow,/overplot,/noeras,thick=10,c_labels=[0]
    map_set,90,0,-90,/ortho,/contin,/grid,/noerase,color=0,label=1,lonlab=10.,latlab=0,latdel=10.,londel=45.,charsize=1.5
    imin=min(level)
    imax=max(level)
    set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],$
          xrange=[imin,imax],xtitle='ppmv',/noeras,$
          xstyle=1,charsize=1.25,color=0,charthick=5
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(nlvls)
    for j=0,nlvls-1 do begin
      xbox=[x1,x1,x1+dx,x1+dx,x1]
      polyfill,xbox,ybox,color=col1(j)
      x1=x1+dx
    endfor

    !type=2^2+2^3
    xmn=xorig(3)
    xmx=xorig(3)+xlen
    ymn=yorig(3)
    ymx=yorig(3)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    level=1+0.5*findgen(21)		; good at 0.1
;   level=0.1+0.2*findgen(21)		; good at 0.01
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*icolmax/nlvls
    map_set,90,0,-90,/ortho,/contin,/grid,/noerase,color=0,title='MLS H2O',label=1,lonlab=10.,latlab=0,latdel=10.,londel=45.,charsize=1.5
h2o=smooth(h2o,5,/edge_truncate)
    contour,h2o,alon,alat,levels=level,c_color=col1,/cell_fill,/overplot,/noeras
    contour,h2o,alon,alat,levels=level,color=0,/follow,/overplot,/noeras
index=where(y2d gt 20.)
index2=where(mlsspeed1(index) eq max(mlsspeed1(index)))
h2oval=h2o(index(index2(0)))
print,mlsspeed1(index(index2(0))),h2oval
    contour,h2o,alon,alat,levels=h2oval,color=0,/follow,/overplot,/noeras,thick=10,c_labels=[0]
    map_set,90,0,-90,/ortho,/contin,/grid,/noerase,color=0,label=1,lonlab=10.,latlab=0,latdel=10.,londel=45.,charsize=1.5
    imin=min(level)
    imax=max(level)
    set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],$
          xrange=[imin,imax],xtitle='ppmv',/noeras,$
          xstyle=1,charsize=1.25,color=0,charthick=5
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(nlvls)
    for j=0,nlvls-1 do begin
      xbox=[x1,x1,x1+dx,x1+dx,x1]
      polyfill,xbox,ybox,color=col1(j)
      x1=x1+dx
    endfor

    icount=icount+1

; Close PostScript file and return control to X-windows
     if setplot ne 'ps' then stop
     if setplot eq 'ps' then begin
        device, /close
        spawn,'convert -trim polar_merra_mls_wind_'+sdate+'_'+slev+'.ps -rotate -90 '+$
                            'polar_merra_mls_wind_'+sdate+'_'+slev+'.jpg'
;       spawn,'rm -f polar_merra_mls_wind_'+sdate+'_'+slev+'.ps'
     endif
     jumpday:
goto,jump
end
