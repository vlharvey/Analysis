; IDL code to view horizontal slices (on pressure surfaces) of UKMO
; Z,T,u,v data.  Plots are displayed in a polar stereographic view.

@stddat
@kgmt
@ckday
@kdate
@rd_ukmow
@date2uars
@drawvectors

device,decompose=0
dir='/aura3/data/UKMO_data/Datfiles/'
runtitle='UKMO '
title2=['Geopotential Height ',$
        'Temperature ',$
        'Zonal Wind ',$
        'Meridional Wind ',$
        'Omega ']
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
setplot='x'
read,'setplot ',setplot
nlg=0l
nlat=0l
nlv=0l
lstmn=1
lstdy=1
lstyr=3
ledmn=1
leddy=1
ledyr=3
lsfc=0
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
print, ' '
print, '      UKMO Version '
print, ' '
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

; define viewport location 
nxdim=750
nydim=750
xorig=0.1
yorig=0.1
xlen=0.8
ylen=0.8
cbaryoff=0.03
cbarydel=0.01

!p.thick=1
!p.charsize=1.0

if setplot ne 'ps' then $
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162

; set color table
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

; --- Calculate UARS day from (imn,idy,iyr) information.
      z = date2uars(imn,idy,iyr,uday)
      print,imn,idy,iyr,' = UARS day ',fix(uday)
      if iyr ge 2000 then iyr1=iyr-2000
      if iyr lt 2000 then iyr1=iyr-1900
      syr=string(FORMAT='(I2.2)',iyr1)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)

;***Read UKMO data
      file=dir+'ppassm_y'+syr+'_m'+smn+'_d'+sdy+'_h12.pp.wdat'
      print,file
      rd_ukmow,file,iflg,nlg,nlat,nlv,alon,alat,wlon,wlat,p,$
              zp,tp,up,vp,wp
      if iflg ne 0 then goto, jump

      if icount eq 0L then begin 
         rsfc=0.0
         print,double(p)
         read,' Enter desired pressure surface ',rsfc
         index=where(rsfc eq p)
         lsfc=index(0)
         ssfc=strcompress(string(rsfc),/remove_all)
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
             (string(FORMAT='(a5,i2.2,a1,i2.2,a1,i4,a1,a7,a5)',$
             'ukmo_',imn,'_',idy,'_',iyr,'_',ssfc,'mb.ps'))
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
         !p.charsize=1.0
      endif

; Declare plotting arrays
      u2=fltarr(nlg+1,nlat-1)
      v2=fltarr(nlg+1,nlat-1)
      x=fltarr(nlg+1)
      x(0:nlg-1)=alon(0:nlg-1)
      x(nlg)=x(0)+360.
      x2d=fltarr(nlg+1,nlat)
      y2d=fltarr(nlg+1,nlat)
      for i=0,nlg do y2d(i,*)=alat
      for j=0,nlat-1 do x2d(*,j)=x

      xw=fltarr(nlg+1)
      xw(0:nlg-1)=wlon(0:nlg-1)
      xw(nlg)=xw(0)+360.

      zdat=zp(*,*,lsfc)/1000.
      tdat=tp(*,*,lsfc)
      wdat=wp(*,*,lsfc)
;
; calculate vertical velocity from omega
; H=RT/g and w=-omega*H/p
;
      ww=0.*wdat
;     H=287.*tdat/9.8
      H=7000.
      plev=p(lsfc)*100.
      ww=-1.0*(wdat*H)/plev
print,'ww ',min(ww),max(ww)

      dat=fltarr(nlg+1,nlat)
      dat(0:nlg-1,0:nlat-1)=ww(0:nlg-1,0:nlat-1)
      u2(0:nlg-1,0:nlat-2)=up(0:nlg-1,0:nlat-2,lsfc)
      v2(0:nlg-1,0:nlat-2)=vp(0:nlg-1,0:nlat-2,lsfc)
      u2(nlg,*)=u2(0,*)
      v2(nlg,*)=v2(0,*)

; Find data range for autoscaling contours
      index=where(y2d gt 0.)
      minval=min(dat(index))
      maxval=max(dat(index))
      nlvls=20
      cint=(maxval-minval)/float(nlvls)

; Autoscale if scale values for parameter/level are not defined
      level=minval+cint*findgen(nlvls)
      col1=1+indgen(nlvls)*icolmax/nlvls
      mb=strcompress(string(FORMAT='(F7.2,A4)',p(lsfc),' mb '))
      date=strcompress(string(FORMAT='(A3,A1,I2,A2,I4)',$
                              month(imn-1),' ',idy,', ',iyr))
      mtitle=runtitle+title2(4)+'at'+mb+'on '+date

; Mercator projection
      xmn=xorig
      xmx=xorig+xlen
      ymn=yorig
      ymx=yorig+ylen
      set_viewport,xmn,xmx,ymn,ymx
      !psym=0
      erase
      MAP_SET,90,-90,0,/stereo,/noeras,/noborder
      contour,dat,x,alat,levels=level,/overplot,/cell_fill,$
              c_color=col1
      contour,dat,x,alat,levels=level,/overplot,c_color=[0],$
              c_labels=0*level,c_linestyle=level lt 0
      xyouts,.15,.95,mtitle,/normal,charsize=2.0
      MAP_SET,90,-90,0,/stereo,/GRID,/CONTIN,/noeras,/noborder
      drawvectors,nlg+1,nlat-1,xw,wlat,u2,v2,5,0

; Draw color bar
      imin=min(level)
      imax=max(level)
      ymnb=yorig -cbaryoff
      ymxb=ymnb  +cbarydel
      set_viewport,0.1,0.9,ymnb,ymxb
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
stop

; Close PostScript file and return control to X-windows
      if setplot eq 'ps' then begin
         device, /close
         set_plot, 'x'
         !p.font=0
         !p.thick=1.0
      endif

      icount=icount+1L
goto, jump

end
