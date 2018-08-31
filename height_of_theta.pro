;
; plot GEOS-5 SF vs PV
; superimpose all theta levels
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto
@calcelat2d

loadct,39
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
xorig=[0.15]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.01
cbarydel=0.02
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
stimes=[$
'_AVG.V01.']
slabs=['AVG']
ntimes=n_elements(stimes)
!noeras=1
dirm='/aura6/data/MLS_data/Datfiles_SOSST/'
dir='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'
lstmn=1L & lstdy=1L & lstyr=2006L
ledmn=1L & leddy=19L & ledyr=2007L
lstday=0L & ledday=0L
;
; get date range
;
print, ' '
print, '      GEOS-5 Version '
print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 2000 then lstyr=lstyr+2000
if ledyr lt 2000 then ledyr=ledyr+2000
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
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; --- Test for end condition
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
;
; construct date string
;
      syr=strcompress(iyr,/remove_all)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      sdate=syr+smn+sdy
;
; read GEOS-5 data
;
      rd_geos5_nc3_meto,dir+sdate+stimes(0)+'nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag
      if iflag eq 1 then goto,jump

      t2=0.*pv2
      for ilev=0L,nth-1L do t2(*,*,ilev)=th(ilev)*((p2(*,*,ilev)/1000.)^(.286))
      z2=(msf2 - 1004.*t2)/(9.86*1000.)
;
; save postscript version
;
if icount eq 0 then begin
      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !p.charsize=1.25
         !p.thick=2
         !p.charthick=5
         !p.charthick=5
         !y.thick=2
         !x.thick=2
         device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='height_of_theta_'+sdate+'.ps'
      endif
;
; mean PV per SF bin
;
      erase
      !type=2^2+2^3
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
endif

      minz=fltarr(nth)
      maxz=fltarr(nth)
      meanz=fltarr(nth)
      sigz=fltarr(nth)
      dz=fltarr(nth)
      for ilev=0L,nth-1L do begin
          minz(ilev)=min(z2(*,*,ilev))
          maxz(ilev)=max(z2(*,*,ilev))
          meanz(ilev)=mean(z2(*,*,ilev))
          sigz(ilev)=stdev(z2(*,*,ilev))
      endfor
      for ilev=1L,nth-2L do dz(ilev)=(meanz(ilev-1)-meanz(ilev+1))/2.

      if icount eq 0 then plot,minz,th,yrange=[400.,4000.],xrange=[10.,80.],$
         xtitle='Altitude (km)',ytitle='Theta (K)',/noerase,color=0
      oplot,minz,th,color=0
      oplot,maxz,th,color=0
      axis,xrange=[0.,5],yrange=[400.,4000.],/save,xaxis=1,/data,$
           xticklen=-0.02,color=0,xtitle='dz (km)'
      oplot,dz,th,color=mcolor*.9
      oplot,sigz,th,color=mcolor*.3
      axis,xrange=[10.,80.],yrange=[400.,4000.],/save,xaxis=1,/data

icount=icount+1
;     if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device,/close
         spawn,'convert -trim height_of_theta_'+sdate+'.ps -rotate -90 height_of_theta_'+sdate+'.jpg'
      endif

goto,jump
end
