; IDL code to view horizontal slices (on pressure surfaces) of UKMO
; Z,T,u,v data.  Plots are displayed in a polar stereographic view.

@stddat
@kgmt
@ckday
@kdate
@rd_ukmo
@date2uars
@drawvectors

device,decompose=0

runtitle='UKMO '
title2=['Geopotential Height ',$
        'Temperature ',$
        'Zonal Wind ',$
        'Meridional Wind ']
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
setplot='x'
read,'setplot ',setplot
nlg=0l
nlat=0l
nlv=0l
lstmn=0
lstdy=0
lstyr=0
ledmn=0
leddy=0
ledyr=0
lsfc=0
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
print, ' '
print, '      UKMO Version '
print, ' '
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
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
xorig=[0.1,0.3]
yorig=[0.55,0.1]
xlen=[0.8,0.4]
ylen=[0.4,0.4]
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

;***Read UKMO data
      file='/aura3/data/UKMO_data/Datfiles/ppassm_y'+$
            string(FORMAT='(i2.2,a2,i2.2,a2,i2.2,a11)',$
            iyr+'_m'+imn+'_d'+idy+'_h12.pp.dat')
      print,file
      rd_ukmo,file,iflg,nlg,nlat,nlv,alon,alat,wlon,wlat,p,$
              zp,tp,up,vp
      if iflg ne 0 then goto, jump

      if icount eq 0L then begin 
         rsfc=0.0
         print,p
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
      dat=fltarr(nlg+1,nlat)
      u2=fltarr(nlg+1,nlat-1)
      v2=fltarr(nlg+1,nlat-1)
      x=fltarr(nlg+1)
      x(0:nlg-1)=alon(0:nlg-1)
      x(nlg)=x(0)+360.
      xw=fltarr(nlg+1)
      xw(0:nlg-1)=wlon(0:nlg-1)
      xw(nlg)=xw(0)+360.

      dat(0:nlg-1,0:nlat-1)=zp(0:nlg-1,0:nlat-1,lsfc)/1000.
      dat(nlg,*)=dat(0,*)

      u2(0:nlg-1,0:nlat-2)=up(0:nlg-1,0:nlat-2,lsfc)
      v2(0:nlg-1,0:nlat-2)=vp(0:nlg-1,0:nlat-2,lsfc)
      u2(nlg,*)=u2(0,*)
      v2(nlg,*)=v2(0,*)

; Find data range for autoscaling contours
      minval=min(dat)
      maxval=max(dat)

; Autoscale if scale values for parameter/level are not defined
      nlvls=30
      level=minval+((maxval-minval)/nlvls)*findgen(nlvls)
      col1=1+indgen(nlvls)*icolmax/nlvls
      mb=strcompress(string(FORMAT='(F7.2,A4)',p(lsfc),' mb '))
      date=strcompress(string(FORMAT='(A3,A1,I2,A2,I4)',$
                              month(imn-1),' ',idy,', ',iyr))
      mtitle=runtitle+mb+title2(0)+date

; Mercator projection
      xmn=xorig(0)
      xmx=xorig(0)+xlen(0)
      ymn=yorig(0)
      ymx=yorig(0)+ylen(0)
      set_viewport,xmn,xmx,ymn,ymx
      !psym=0
      MAP_SET,0,0,0,title=mtitle,/noeras,/noborder
      contour,dat,x,alat,levels=level,/overplot,/cell_fill,$
              xtitle='Longitude',ytitle='Latitude',c_color=col1
      contour,dat,x,alat,levels=level,/overplot,$
              xtitle='Longitude',ytitle='Latitude',$
              xrange=[0,360],yrange=[-90,90],c_color=[0],$
              c_labels=0*level,c_linestyle=level lt 0
      MAP_SET,0,0,0,/GRID,/CONTIN,/noeras,/noborder
      drawvectors,nlg+1,nlat-1,xw,wlat,u2,v2,3,0

; stereographic projection
      xmn=xorig(1)
      xmx=xorig(1)+xlen(1)
      ymn=yorig(1)
      ymx=yorig(1)+ylen(1)
      set_viewport,xmn,xmx,ymn,ymx
      MAP_SET,-90,0,90,/stereo,/noeras,/noborder
      contour,dat,x,alat,levels=level,/overplot,/cell_fill,c_color=col1
      contour,dat,x,alat,levels=level,/overplot,c_color=[0],$
              c_labels=0*level,c_linestyle=level lt 0
      MAP_SET,-90,0,90,/stereo,/GRID,/CONTIN,/noeras,/noborder
      drawvectors,nlg+1,nlat-1,xw,wlat,u2,v2,3,0

; Draw color bar
      imin=min(level)
      imax=max(level)
      ymnb=yorig(1) -cbaryoff
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

; animate
;     if setplot eq 'x' then begin
;        save=assoc(3,bytarr(750,750))
;        img=bytarr(750,750)
;        img(0,0)=TVRD(0,0,750,750)
;        openr,3,'psurf.dat',error=err
;        close,3
;        if (err ne 0) then begin
;           openw,3,'psurf.dat',/fixed,4096L
;           save(0)=img
;           close,3
;        endif else begin
;           openu,3,'psurf.dat',/fixed,4096L
;           i=0
;           while not eof(3) do begin
;                 xx=save(i)
;                 i=i+1
;           endwhile
;           save(i)=img
;          close,3
;        endelse
;     endif
icount=icount+1L
goto, jump

; Close PostScript file and return control to X-windows
      if setplot eq 'ps' then begin
         device, /close
         set_plot, 'x'
         !p.font=0
         !p.thick=1.0
      endif

end
