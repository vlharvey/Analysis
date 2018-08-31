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
mcolor=byte(!p.color)
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
xorig=[0.1]
yorig=[0.15]
xlen=0.8
ylen=0.8
cbaryoff=0.07
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
lstyr=2014
ledmn=1
leddy=31
ledyr=2014
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
mark1=reform(transpose(mark2(*,*,10)))
      alat=LATITUDE_WACCM
      nth=n_elements(pressure)
      nr=n_elements(LATITUDE_WACCM)
      nc=n_elements(LONGITUDE_WACCM)
      sp2=sqrt(u2^2.+v2^2.)
;
; declare arrays and select surfaces
;
      if icount eq 0 then begin
;        print,th
         plev=500.
;        read,' Enter desired theta surface ',plev
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
         x2d=fltarr(nc+1,nr)
         y2d=fltarr(nc+1,nr)
         for i=0,nc do y2d(i,*)=alat
         for j=0,nr-1 do x2d(*,j)=x
         xyz=fltarr(nr,nth)
         yyz=fltarr(nr,nth)
         for i=0,nr-1 do yyz(i,*)=pressure
         for j=0,nth-1 do xyz(*,j)=alat 
      endif
      index=where(abs(th-plev) eq min(abs(th-plev)))
      ilev=index(0)
      sp1=reform(transpose(sp2(*,*,ilev)))
      pv1=reform(transpose(pv2(*,*,ilev)))
      mark1=reform(transpose(mark2(*,*,ilev)))
      sp=fltarr(nc+1,nr)
      sp(0:nc-1,*)=sp1(0:nc-1,*)
      sp(nc,*)=sp(0,*)
      pv=fltarr(nc+1,nr)
      pv(0:nc-1,*)=pv1(0:nc-1,*)
      pv(nc,*)=pv(0,*)
      mark=fltarr(nc+1,nr)
      mark(0:nc-1,*)=mark1(0:nc-1,*)
      mark(nc,*)=mark(0,*)
;
    if setplot eq 'ps' then begin
       lc=0
       xsize=nxdim/100.
       ysize=nydim/100.
       set_plot,'ps'
       device,/color,/landscape,bits=8,filename='polar_merra_pv_'+sdate+'_'+slev+'.ps'
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif
;
; plot
;
    erase
    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
      if icount eq 0 then begin
         index=where(y2d gt 0. and pv ne -1.e12)
         pvmin=min(pv(index))
         pvmax=max(pv(index))
         nlvls=20
         pvint=(pvmax-pvmin)/nlvls
         level=pvmin+pvint*findgen(nlvls)
         col1=1+indgen(nlvls)*icolmax/float(nlvls)
      endif
    map_set,90,0,-90,/stereo,/contin,/grid,/noerase,color=0,title=sdate,label=1,lonlab=10.,latlab=0,latdel=10.,londel=45.,charsize=1.5
    contour,pv,x,alat,levels=level,c_color=col1,/cell_fill,/overplot,/noeras
    contour,pv,x,alat,levels=level,color=0,/follow,/overplot,/noeras
    index=where(level lt 0)
    contour,pv,x,alat,levels=level(index),color=mcolor,/overplot,/noeras,/follow,c_linestyle=5
    map_set,90,0,-90,/stereo,/contin,/grid,/noerase,color=0,label=1,lonlab=10.,latlab=0,latdel=10.,londel=45.,charsize=1.5
;   contour,mark,x,alat,levels=[0.1],color=0,/follow,/overplot,/noeras,thick=10,c_labels=[0]
;   contour,mark,x,alat,levels=[-0.1],color=mcolor,/follow,/overplot,/noeras,thick=10,c_labels=[0]
;   contour,sp,x,alat,levels=[100],color=mcolor*.9,/follow,/overplot,/noeras,thick=10,c_labels=[0]
;   contour,sp,x,alat,levels=[80],color=mcolor*.8,/follow,/overplot,/noeras,thick=10,c_labels=[0]
;   contour,sp,x,alat,levels=[60],color=mcolor*.75,/follow,/overplot,/noeras,thick=10,c_labels=[0]
    imin=min(level)
    imax=max(level)
    set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],$
          xrange=[imin,imax],xtitle=slev+' K MERRA PV',/noeras,$
          xstyle=1,charsize=1.5,color=0,charthick=5
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
        spawn,'convert -trim polar_merra_pv_'+sdate+'_'+slev+'.ps -rotate -90 '+$
                            'polar_merra_pv_'+sdate+'_'+slev+'.jpg'
;       spawn,'rm -f polar_merra_pv_'+sdate+'_'+slev+'.ps'
     endif
     jumpday:
goto,jump
end
