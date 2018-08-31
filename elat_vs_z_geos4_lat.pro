;
; contour avg, max-min, GEOS latitude in equivalent latitude vs height
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto
@calcelat2d

sver='v2.2'
;sver='v1.52'

loadct,38
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=[.1,0.575]
yorig=[.2,0.2]
xlen=0.4
ylen=0.7
cbaryoff=0.08
cbarydel=0.01
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
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
mon=['jan','feb','mar','apr','may','jun',$
     'jul','aug','sep','oct','nov','dec']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
nlat=35L
elatbin=-85+5.*findgen(nlat)

!noeras=1
dirm='/aura6/data/MLS_data/Datfiles_SOSST/'
idir='/aura6/data/GEOS4_data/Analysis/'
dir1='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'
dir2='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS501.MetO.'

lstmn=1 & lstdy=1 & lstyr=2004
ledmn=2 & leddy=28 & ledyr=2004
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;print, ' '
;print, '      GEOS Version '
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

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' normal termination condition '
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy

      rd_geos5_nc3_meto,dir1+sdate+'_1200.V01.nc3',nc,nr,nth,alon,alat,th,$
         pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag

;
; save postscript version
;
     if setplot eq 'ps' then begin
        set_plot,'ps'
        xsize=nxdim/100.
        ysize=nydim/100.
        !psym=0
        !p.font=0
        device,font_size=9
        device,/landscape,bits=8,filename='elat_vs_z_geos4_lat_'+sdate+'.ps'
        device,/color
        device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
     endif
;
; zonal mean  and max-min latitude as a function of elat and theta
;
      lat_avg_2d=fltarr(nlat,nth)
      lat_max_min_2d=fltarr(nlat,nth)
      y2d=fltarr(nc,nr)
      x2d=fltarr(nc,nr)
      for ii=0L,nc-1L do y2d(ii,*)=alat
      for jj=0L,nr-1L do x2d(*,jj)=alon
;
; loop over theta
;

      for kk=0L,nth-1L do begin
          pv1=transpose(pv2(*,*,kk))
          elat1=calcelat2d(pv1,alon,alat)
;
; calculate average and max-min latitude as a function of elat
;
          for j=0L,nlat-2L do begin
              e0=elatbin(j) & e1=elatbin(j+1)
              index=where(elat1 ge e0 and elat1 lt e1)
              if index(0) ne -1L then begin
                 lat_avg_2d(j,kk)=mean(y2d(index))
                 lat_max_min_2d(j,kk)=max(y2d(index))-min(y2d(index))
;if lat_max_min_2d(j,kk) gt 50. then begin
;if max(y2d(index)) gt 10. and min(y2d(index)) lt -10. then begin
;print,max(y2d(index))-min(y2d(index)),max(y2d(index)),min(y2d(index))
;erase
;set_viewport,.1,.9,.2,.7
;map_set,0,0,0,/contin,/grid,/noeras,color=0,title=string(th(kk))
;contour,elat1,alon,alat,levels=elatbin,/follow,color=0,/overplot
;oplot,x2d(index),y2d(index),psym=8,color=230
;stop
;endif
              endif

;             index=where(elat1 ge e0 and elat1 lt e1)
;             if index(0) ne -1L then markyt(icount-1,j,kk)=max(mark1(index))
;             index=where(elatdata ge e0 and elatdata lt e1,npt)
;             if index(0) ne -1L then coyt(icount-1,j,kk)=max(codata(index))
          endfor
      endfor
;
; polar plot
;
    erase
    xyouts,.35,.95,'GEOS-4 '+sdate,charsize=3,color=0,/normal,charthick=2
    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    nlvls=nlat
    level=elatbin
    col1=1+indgen(nlvls)*icolmax/nlvls
    contour,lat_avg_2d,elatbin,th,color=0,/noeras,charsize=1.5,title='Mean Latitude',$
            /fill,c_color=col1,levels=level,xrange=[-90.,90.],xticks=6,yrange=[min(th),max(th)],$
            xtitle='Equivalent Latitude',charthick=2,ytitle='Theta (K)'
    contour,lat_avg_2d,elatbin,th,/overplot,levels=level,color=0,/noeras,/follow
    set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    omin=min(level)
    omax=max(level)
    plot,[omin,omax],[0,0],yrange=[0,10],$
          xrange=[omin,omax],xtitle='Degrees Latitude',/noeras,$
          xstyle=1,charsize=1.5,color=0,charthick=2
    ybox=[0,10,10,0,0]
    x1=omin
    dx=(omax-omin)/float(nlvls)
    for j=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(j)
        x1=x1+dx
    endfor

    !type=2^2+2^3
    level=4*findgen(nlvls)
    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    contour,lat_max_min_2d,elatbin,th,color=0,/noeras,charsize=1.5,title='Max-Min Latitude',$
            /fill,c_color=col1,levels=level,xrange=[-90.,90.],xticks=6,yrange=[min(th),max(th)],$
            xtitle='Equivalent Latitude',charthick=2
    contour,lat_max_min_2d,elatbin,th,/overplot,levels=level,color=0,/noeras,/follow
    set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    omin=min(level)
    omax=max(level)
    plot,[omin,omax],[0,0],yrange=[0,10],$
          xrange=[omin,omax],xtitle='Degree Difference',/noeras,$
          xstyle=1,charsize=1.5,color=0,charthick=2
    ybox=[0,10,10,0,0]
    x1=omin
    dx=(omax-omin)/float(nlvls)
    for j=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(j)
        x1=x1+dx
    endfor
    if setplot ne 'ps' then wait,1
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert -trim elat_vs_z_geos4_lat_'+sdate+'.ps -rotate -90 '+$
                           'elat_vs_z_geos4_lat_'+sdate+'.jpg'
    endif

goto,jump
end
