;---------------------------------------------------------------------------------------------------
; xcentroid and ycentroid from Greer moment diagnostics
; based on MERRA data 
; save over specified dates
;
;	 -------------------------------
;       |         Lynn Harvey           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 4/24/2014      |
;	 -------------------------------
;
@stddat			; Determines the number of days since Jan 1, 1956
@kgmt			; This function computes the Julian day number (GMT) from the
@ckday			; This routine changes the Julian day from 365(6 if leap yr)
@kdate			; gives back kmn,kdy information from the Julian day #.
@rd_merra_nc3
@vortexshape

;-----------------------------------------------------

SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.1,0.4,0.7]
yorig=[0.1,0.1,0.1]
xlen=0.2
ylen=0.25
cbaryoff=0.12
cbarydel=0.01
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
loadct,39
mcolor=!p.color
icolmax=255
mcolor=icolmax
icmm1=icolmax-1B
icmm2=icolmax-2B
device,decompose=0
!NOERAS=-1
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
days = 0
months = ['Apr','May','Jun','Jul','Aug','Sep','Oct','Nov']
MONTH = ['04','05','06','07','08','09','10','11']
lstmn=12
lstdy=1
lstyr=2013
ledmn=2
leddy=1
ledyr=2014
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;read,' Enter starting date ',lstmn,lstdy,lstyr
;read,' Enter ending date ',ledmn,leddy,ledyr
if lstyr lt 79 then lstyr=lstyr+2000
if ledyr lt 79 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
minyear=strcompress(lstyr,/remove_all)+string(FORMAT='(I2.2)',lstmn)+string(FORMAT='(I2.2)',lstdy)
maxyear=strcompress(ledyr,/remove_all)+string(FORMAT='(I2.2)',ledmn)+string(FORMAT='(I2.2)',leddy)
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'
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
kcount=0L

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal Termination Condition'
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
      print,sdate
;
; read daily file
;
      dum=findfile(dir+sdate+'.nc3')
      if dum ne '' then ncfile0=dir+sdate+'.nc3'
      rd_merra_nc3,ncfile0,nc,nr,nth,alon,alat,th,pv2,p2,$
         u2,v2,qdf2,mark2,qv2,gph2,sf2,q2,iflag
      if iflag ne 0L then goto,jump
      tmp2=0.*p2
      for k=0L,nth-1L do tmp2(*,*,k)=th(k)*(p2(*,*,k)/1000.)^0.286
;
; find vortex centroids, ellipticity_profile
;
      marker_USLM = make_array(nc,nr,nth)
      for k=0,nth-1 do marker_USLM(*,*,k) = transpose(mark2(*,*,k))
      shape = vortexshape(marker_USLM, alat, alon)
      centroid=shape.nhcentroid
      centroidx=reform(centroid(0,*))
      centroidy=reform(centroid(1,*))
      axis=shape.axis
      majoraxis=reform(axis(0,*))
      minoraxis=reform(axis(1,*))
      ellipticity_profile=minoraxis/majoraxis
      index=where(centroidx lt 0.)
      if index(0) ne -1L then centroidx(index)=centroidx(index)+360.
;
; save postscript version
;
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/times,filename='polar_merra_vortex_edge+shape_diagnostics_'+sdate+'.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
;
; loop over altitude
;
erase
!type=2^2+2^3
set_viewport,.25,.75,.4,.9
map_set,90,0,-90,/ortho,/contin,/grid,/noerase,color=0,title='MERRA Vortex '+sdate,label=1,lonlab=10.,latlab=0,latdel=10.,londel=45.,charsize=1.5
contour, transpose(reform(mark2[*,*,0])),alon,alat,levels=[0.1],color=0,thick=5,/nodata,/overplot
      nr2=nr/2
      altitude=fltarr(nth)
      number_vortex_lobes=fltarr(nth)
      for ii = 0L, nth - 1L do begin
          x2d=fltarr(nr2,nc)
          y2d=fltarr(nr2,nc)
          for i=0L,nc-1 do y2d(*,i)=alat(nr2:nr-1)
          for j=0L,nr2-1 do x2d(j,*)=alon

          dailymark = transpose(reform(mark2[nr2:nr-1,*,nth-1L-ii]))
          marker=fltarr(nc+1L,nr2)
          marker[0L:nc-1L,*] = dailymark
          marker[nc,*] = marker(0,*)
          sf=fltarr(nc+1L,nr2)
          sf[0L:nc-1L,*] = transpose(reform(sf2[nr2:nr-1,*,nth-1L-ii]))
          sf[nc,*] = sf(0,*)
          z=fltarr(nc+1L,nr2)
          z[0L:nc-1L,*] = transpose(reform(gph2[nr2:nr-1,*,nth-1L-ii]))
          z[nc,*] = z(0,*)
          index=where(marker gt 0.)
          if index(0) eq -1L then index=where(y2d ge 60.)	; if no vortex then take polar cap average altitude
          if index(0) ne -1L then begin
             altitude(nth-1-ii)=mean(z(index))
print,th(nth-1L-ii),mean(z(index))
          endif
contour, transpose(reform(mark2[*,*,nth-1L-ii])),alon,alat,levels=[0.1],color=(float(ii)/(float(nth)))*mcolor,thick=10,/overplot
oplot,[centroidx(nth-1L-ii),centroidx(nth-1L-ii)],[centroidy(nth-1L-ii),centroidy(nth-1L-ii)],psym=8,color=(float(ii)/(float(nth)))*mcolor,symsize=2
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a)
oplot,[centroidx(nth-1L-ii),centroidx(nth-1L-ii)],[centroidy(nth-1L-ii),centroidy(nth-1L-ii)],psym=8,color=0,symsize=2
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
;
; histograms of vortex latitude and longitude
;
          py1=fltarr(nc)
          px1=fltarr(nr)
          for i=0L,nc-1L do begin
              index=where(marker(i,*) gt 0.,nn)
              py1(i)=float(nn)
          endfor
          for j=0L,nr-1L do begin
              index=where(mark2(j,*,nth-1L-ii) gt 0.,nn)
              px1(j)=float(nn)
          endfor
;
; are there two cyclonic vortices?
;
          n0=findgen(nc)
          n1=1.+findgen(nc)
          vortlon=0.*alon
          index=where(py1 ne 0.)
          if index(0) ne -1L then vortlon(index)=1.
          index=where(abs(vortlon(n0)-vortlon(n1)) gt 0.,nv)
          nextra=1
          if nv eq 0L then nv=2                   ; circumpolar has no zeros. set to 2 to get 1 vortex
          index=where(vortlon eq 1.)
          if min(alon(index)) eq min(alon) and max(alon(index)) ne max(alon) then nextra=0        ; GM edge
          if min(alon(index)) ne min(alon) and max(alon(index)) eq max(alon) then nextra=0        ; GM edge
          if nv gt 2L then begin
             nextra=0.5*nv                ; each vortex results in 2 edge points - unless it lies exactly along the GM
          endif
          nv=round(nv-nextra)
          number_vortex_lobes(nth-1L-ii)=nv

print,altitude(nth-1-ii),th(nth-1L-ii),number_vortex_lobes(nth-1L-ii),ellipticity_profile(nth-1L-ii),centroidx(nth-1L-ii),centroidy(nth-1L-ii)
      endfor          ; loop over altitude
nlvls=nth
col1=1+indgen(nlvls)*icolmax/nlvls
imin=min(altitude)
imax=max(altitude)
xmnb=0.75+cbaryoff
xmxb=xmnb  +cbarydel
set_viewport,xmnb,xmxb,0.4,0.9
!type=2^2+2^3+2^5
plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],color=0,$
      ytitle='Altitude (km)',charthick=2,charsize=1.5
xbox=[0,10,10,0,0]
y1=imin
dy=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
ybox=[y1,y1,y1+dy,y1+dy,y1]
polyfill,xbox,ybox,color=col1(j)
y1=y1+dy
endfor
;
; longitude phase
;
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,centroidx,altitude,color=0,psym=8,ytitle='Altitude (km)',symsize=2,$
     xrange=[0.,360.],yrange=[15.,80.],xtitle='Centroid Longitude',charsize=1.5,charthick=2
index=where(number_vortex_lobes gt 1)
if index(0) ne -1L then oplot,centroidx(index),altitude(index),psym=8,color=mcolor*.9
;
; latitude phase
;
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
plot,centroidy,altitude,color=0,psym=8,ytitle='Altitude (km)',symsize=2,$
        xrange=[40.,90],yrange=[15.,80.],xtitle='Centroid Latitude',charsize=1.5,charthick=2
index=where(number_vortex_lobes gt 1)
if index(0) ne -1L then oplot,centroidy(index),altitude(index),psym=8,color=mcolor*.9
;
; ellipticity_profile
;
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
plot,ellipticity_profile,altitude,psym=8,ytitle='Altitude (km)',symsize=2,$
        xrange=[0.,1.],color=0,yrange=[15.,80.],xtitle='Ellipticity',charsize=1.5,charthick=2
index=where(number_vortex_lobes gt 1)
if index(0) ne -1L then oplot,ellipticity_profile(index),altitude(index),psym=8,color=mcolor*.9

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert polar_merra_vortex_edge+shape_diagnostics_'+sdate+'.ps -rotate -90 polar_merra_vortex_edge+shape_diagnostics_'+sdate+'.png'
   spawn,'rm -f polar_merra_vortex_edge+shape_diagnostics_'+sdate+'.ps'
endif
goto,jump
end
