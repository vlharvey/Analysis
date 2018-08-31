;
; IDL code to view horizontal slices (on theta surfaces) of ECMWF
; pv,Z,T,u,v,ww,sh,ozone data.  Plots are displayed in a polar stereographic view.

@stddat
@kgmt
@ckday
@kdate
@rd_ecmwf_nc

device,decompose=0
dir='/aura3/data/ECMWF_data/Datfiles/ecmwf_'
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
setplot='x'
read,'setplot ',setplot
lstmn=11
lstdy=1
lstyr=91
ledmn=11
leddy=1
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
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
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
xorig=[0.1,0.4,0.7,0.15,0.55]
yorig=[0.6,0.6,0.6,0.15,0.15]
xlen=0.25
ylen=0.2
cbaryoff=0.03
cbarydel=0.02
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
      print,imn,idy,iyr

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
;
;***Read ECMWF data
      file=dir+smn+'_'+sdy+'_'+syr+'_12Z.nc'
      rd_ecmwf_nc,file,nc,nr,nl,alon,alat,th,pv2,p2,msf2,u2,v2,q2,qdf2,sh2,o3,iflg

      if iflg ne 0 then goto, jump
      if icount eq 0L then begin 
         rsfc=0.0
         print,th
         read,' Enter desired theta surface ',rsfc
         index=where(rsfc eq th)
         lsfc=index(0)
         ssfc=strcompress(string(fix(rsfc)),/remove_all)
      endif
      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !psym=0
         !p.font=0
         device,font_size=9
         device,/landscape,bits=8,filename=$
             string(FORMAT='(a5,i2.2,a1,i2.2,a1,i4)',$
             'ecmwf_',imn,'_',idy,'_',iyr)+'_'+ssfc+'K.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
         !p.charsize=1.0
      endif

; Declare plotting arrays
      edat=transpose(pv2(*,*,lsfc))
      water=transpose(sh2(*,*,lsfc))*1.e6
      ozone=transpose(o3(*,*,lsfc))*1.e6

; Find data range for autoscaling contours
      erase
      minval=min(edat)
      maxval=max(edat)
      nlvs=30
      cint=(maxval-minval)/float(nlvs)

; Autoscale if scale values for parameter/level are not defined
      level=minval+cint*findgen(nlvs)
      col1=1+indgen(nlvs)*icolmax/nlvs
      mb=ssfc+' K '
      date=strcompress(string(FORMAT='(A3,A1,I2,A2,I4)',$
                              month(imn-1),' ',idy,', ',iyr))

; Mercator projection
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      !type=2^2+2^3
      xyouts,.3,.9,'ECMWF '+mb+' PV '+date,/normal,charsize=2
      MAP_SET,0,0,0,/noeras,/noborder,title='PV',charsize=2
      contour,edat,alon,alat,levels=level,/overplot,/cell_fill,c_color=col1,/noeras
      contour,edat,alon,alat,levels=level,/overplot,c_color=[0],$
              c_labels=0*level,c_linestyle=level lt 0,/noeras
      MAP_SET,0,0,0,/GRID,/CONTIN,/noeras,/noborder
      imin=min(level)
      imax=max(level)
      ymnb=yorig(0) -cbaryoff
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

      xmn=xorig(1)
      xmx=xorig(1)+xlen
      ymn=yorig(1)
      ymx=yorig(1)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      !type=2^2+2^3
      level=0.5*findgen(30)
      MAP_SET,0,0,0,/noeras,/noborder,title='Ozone',charsize=2
      contour,ozone,alon,alat,levels=level,/overplot,/cell_fill,c_color=col1,/noeras
      contour,ozone,alon,alat,levels=level,/overplot,c_color=[0],$
              c_labels=0*level,c_linestyle=level lt 0,/noeras
      MAP_SET,0,0,0,/GRID,/CONTIN,/noeras,/noborder
      imin=min(level)
      imax=max(level)
      ymnb=yorig(1) -cbaryoff
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

      xmn=xorig(2)
      xmx=xorig(2)+xlen
      ymn=yorig(2)
      ymx=yorig(2)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      !type=2^2+2^3
      level=1.+0.1*findgen(30)
      MAP_SET,0,0,0,/noeras,/noborder,title='Sp. Humidity',charsize=2
      contour,water,alon,alat,levels=level,/overplot,/cell_fill,c_color=col1,/noeras
      contour,water,alon,alat,levels=level,/overplot,c_color=[0],$
              c_labels=0*level,c_linestyle=level lt 0,/noeras
      MAP_SET,0,0,0,/GRID,/CONTIN,/noeras,/noborder
      imin=min(level)
      imax=max(level)
      ymnb=yorig(2) -cbaryoff
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

      !type=2^2+2^3
      xmn=xorig(3)
      xmx=xorig(3)+0.3
      ymn=yorig(3)
      ymx=yorig(3)+0.3
      set_viewport,xmn,xmx,ymn,ymx
      omin=min(ozone)
      omax=max(ozone)
      plot,edat,ozone,psym=3,xrange=[minval,maxval],yrange=[omin,omax],$
           xtitle='Potential Vorticity',ytitle=mb+' Ozone',title='PV/O3 Scatterplot'

      xmn=xorig(4)
      xmx=xorig(4)+0.3
      ymn=yorig(4)
      ymx=yorig(4)+0.3
      set_viewport,xmn,xmx,ymn,ymx
      omin=min(water)
      omax=max(water)
      plot,edat,water,psym=3,xrange=[minval,maxval],yrange=[omin,omax],$
           xtitle='Potential Vorticity',ytitle=mb+' Specific Humidity',title='PV/H2O Scatterplot'


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
