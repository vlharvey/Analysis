; IDL code to view horizontal slices (on pressure surfaces) of ECMWF
; pv,Z,T,u,v,ww,sh,ozone data.  Plots are displayed in a polar stereographic view.

@stddat
@kgmt
@ckday
@kdate
@rd_ecmwf

device,decompose=0
dir='/aura5/harvey/ECMWF_data/Datfiles/ecmwf_'
runtitle='ECMWF '
title2=['Potential Vorticity (PVU) ',$
        'Geopotential Height (km) ',$
;       'Temperature (K) ',$
;       'Zonal Wind ',$
;       'Meridional Wind ',$
;       'Vertical Wind ',$
        'Specific Humidity (g/kg) ',$
        'Ozone Mixing Ratio (g/kg) ']
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
setplot='x'
read,'setplot ',setplot
lstmn=11
lstdy=1
lstyr=91
ledmn=11
leddy=30
ledyr=91
lsfc=0
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
print, ' '
print, '      ECMWF Version '
print, ' '
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

; define viewport location 
nxdim=750
nydim=750
xorig=[0.05,0.55,0.05,0.55]
yorig=[0.55,0.55,0.13,0.13]
npan=n_elements(xorig)
xlen=0.4
ylen=0.3
cbaryoff=0.02
cbarydel=0.01
!p.thick=1
!p.charsize=1.0
if setplot ne 'ps' then $
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
icmm1=icolmax-1
icmm2=icolmax-2
!noeras=1

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

      print,imn,idy,iyr
      if iyr ge 2000 then iyr1=iyr-2000
      if iyr lt 2000 then iyr1=iyr-1900
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)

;***Read ECMWF data
      file=dir+smn+'_'+sdy+'_'+syr+'_12Z.dat'
      print,file
      rd_ecmwf,file,iflg,nc,nr,nl,alon,alat,press,pv,gp,tp,uu,vv,ww,sh,oz
      if iflg ne 0 then goto, jump

      if icount eq 0L then begin 
         rsfc=0.0
         print,double(press)
         read,' Enter desired pressure surface ',rsfc
         index=where(rsfc eq press)
         lsfc=index(0)
         ssfc=strcompress(string(fix(rsfc)),/remove_all)
         ssfc=strmid(ssfc,0,7)
      endif

      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !psym=0
         !p.font=0
         device,font_size=9
         device,/landscape,bits=8,filename=$
             string(FORMAT='(a6,i2.2,a1,i2.2,a1,i4)',$
             'ecmwf_',imn,'_',idy,'_',iyr)+'_'+ssfc+'mb.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
         !p.charsize=1.0
      endif

; Declare plotting arrays
      dat=fltarr(nc+1,nr)
      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=x(0)+360.
      x2d=fltarr(nc+1,nr)
      y2d=fltarr(nc+1,nr)
      for i=0,nc do y2d(i,*)=alat
      for j=0,nr-1 do x2d(*,j)=x
      erase
      mb='    '+ssfc+' mb'
      date='   '+strcompress(string(FORMAT='(A3,A1,I2,A2,I4)',$
                              month(imn-1),' ',idy,', ',iyr))
      xyouts,.2,.92,runtitle+date+mb,/normal,charsize=2.5
      for ipan=0,npan-1 do begin

      if ipan eq 0 then dat(0:nc-1,0:nr-1)=pv(0:nc-1,0:nr-1,lsfc)
      if ipan eq 1 then dat(0:nc-1,0:nr-1)=gp(0:nc-1,0:nr-1,lsfc)/1000./9.8601
      if ipan eq 2 then dat(0:nc-1,0:nr-1)=sh(0:nc-1,0:nr-1,lsfc)*1.e6
      if ipan eq 3 then dat(0:nc-1,0:nr-1)=oz(0:nc-1,0:nr-1,lsfc)*1.e6
      dat(nc,*)=dat(0,*)

; Find data range for autoscaling contours
      minval=min(dat)-0.05*min(dat)
      maxval=max(dat)+0.05*max(dat)
      nlvls=20
      cint=(maxval-minval)/float(nlvls)
      level=minval+cint*findgen(nlvls)

; Mercator projection
      xmn=xorig(ipan)
      xmx=xorig(ipan)+xlen
      ymn=yorig(ipan)
      ymx=yorig(ipan)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      !psym=0
      MAP_SET,0,0,0,/noeras,/noborder,title=title2(ipan),charsize=1.5
      contour,dat,x,alat,levels=level,/overplot,/cell_fill,c_color=col1,/noeras
      contour,dat,x,alat,levels=level,/overplot,c_color=[0],$
              c_labels=0*level,c_linestyle=level lt 0,/noeras
      MAP_SET,0,0,0,/GRID,/CONTIN,/noeras,/noborder
      imin=min(level)
      imax=max(level)
      ymnb=yorig(ipan)-cbaryoff
      ymxb=ymnb  +cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax]
      ybox=[0,10,10,0,0]
      x1=imin
      dx=(imax-imin)/float(icmm1)
      for j=1,icmm1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=j
          x1=x1+dx
      endfor
      print,imin,imax
      endfor

; Close PostScript file and return control to X-windows
      if setplot eq 'ps' then begin
         device, /close
         set_plot, 'x'
         !p.font=0
         !p.thick=1.0
      endif

      icount=icount+1L
stop
goto, jump

end
