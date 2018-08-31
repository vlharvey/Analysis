; 
; WACCM files from Hanli
; polar cap average vertical profiles of NO in density and e (electrons)
;
@stddat
@kgmt
@ckday
@kdate

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
!NOERAS=-1
device,decompose=0
nxdim=700
nydim=700
xorig=[0.15,0.6,0.15,0.6]
yorig=[0.6,0.6,0.15,0.15]
xlen=0.3
ylen=0.3
cbaryoff=0.03
cbarydel=0.02
!NOERAS=-1
lstmn=1
lstdy=1
lstyr=2002
ledmn=1
leddy=31
ledyr=2002
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

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
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
dir='/Volumes/earth/harvey/WACCM_data/Datfiles/Datfiles_Liu/WA3548T08CO_2x.cam2.h2.'
!p.thick=5
!p.charsize=1.25

; Compute initial Julian date
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L

; --- Loop over days --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
      syr=string(FORMAT='(i4)',iyr)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
;
; read WACCM data
;
      spawn,'ls '+dir+syr+'-'+smn+'-'+sdy+'-00000.nc',ncfiles
          sdate=syr+'-'+smn+'-'+sdy
          ncfile=ncfiles(0)
          ncid=ncdf_open(ncfile)
          result0=ncdf_inquire(ncid)
          for idim=0,result0.ndims-1 do begin
              ncdf_diminq,ncid,idim,name,dim
              if name eq 'lon' then nc=dim
              if name eq 'lat' then nr=dim
              if name eq 'lev' then nl=dim
              if name eq 'time' then nt=dim
;             print,'read ',name,' dimension ',dim
          endfor
;
; loop over variables
;
          for ivar=0,result0.nvars-1 do begin
              result=ncdf_varinq(ncid,ivar)
;             if result.name ne 'T' and result.name ne 'U' and result.name ne 'V' then $

              ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
              if result.name eq 'P0' then p0=data
              if result.name eq 'lat' then alat=data
              if result.name eq 'lon' then alon=data
              if result.name eq 'lev' then lev=data
              if result.name eq 'ilev' then ilev=data
              if result.name eq 'time' then time=data
              if result.name eq 'datesec' then time=data/86400.
              if result.name eq 'hyai' then hyai=data
              if result.name eq 'hybi' then hybi=data
              if result.name eq 'hyam' then hyam=data
              if result.name eq 'hybm' then hybm=data
              if result.name eq 'date' then date=data
              if result.name eq 'PS' then psfc=data	;/100.
              if result.name eq 'T' then tgrd=data
              if result.name eq 'U' then ugrd=data
              if result.name eq 'V' then vgrd=data
;             if result.name eq 'CH4' then ch4grd=data
              if result.name eq 'e' then egrd=data
              if result.name eq 'NOY' then noygrd=data
              if result.name eq 'NO' then nogrd=data
              if result.name eq 'QRL_TOT' then qrtgrd=data
              if result.name eq 'QRS_TOT' then qrsgrd=data
;             if result.name eq 'O3' then  o3grd=data
              if result.name eq 'Z3' then  zgrd=data/1000.

;             print,ivar,result.name,min(data),max(data)
          endfor
          ncdf_close,ncid
;
;============================================================
; Calculate Pressure : pgrd(i,j,k) = A(k)*PO + B(k)*PS(i,j)
;============================================================
          pgrd        = fltarr(nc,nr,nl)
          Pzero       = P0      ;/100.
          FOR ilon = 0, nc-1 DO $
              FOR ilat = 0, nr-1 DO $
                  FOR ialt = 0, nl-1 DO $
                      pgrd(ilon,ilat,ialt) = hyam(ialt)*Pzero + hybm(ialt)*PSFC(ilon,ilat)
;
; horizontal wind speed
;
    speedgrd=sqrt(ugrd^2+vgrd^2)
;
; compute atmospheric density
;
; p=rho R T -> rho=P/RT where R=287 J/K kg. Pressure in Pascals.
;
rho=pgrd/(tgrd*287.)
;
; to convert species from (NO molecules/air molecules) to NO molecules/cm3
; assume the molecular weight of one molecule of air is 29 grams (weight of O is 16, weight of N is 14, atm is 80% N2 and 20% O2)
; (mol NO/mol air) * (1 molecule air/29 grams) * (1000 g air/1 kg air) * (AIR DENSITY/m^3 air) * (Avagadros #/1 mole NO) = (molecules NO/m^3 air)
; Avagadros # = 6.022e23
;
no_conc=nogrd * (1./29.) * (1000./1.) * rho * 6.022e23
no_conc=no_conc/1.e6                                 ; divide by 1.e6 for m-3 to cm-3
;
dthdtgrd=(qrtgrd+qrsgrd)*86400.
stime=strcompress(long(time),/remove_all)

; save postscript version
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='polar_cap_avg_no_dens_WA3548T08CO_'+sdate+'.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
    endif

noavg_nh=fltarr(nl)
noavg_sh=fltarr(nl)
nosig_nh=fltarr(nl)
nosig_sh=fltarr(nl)

eavg_nh=fltarr(nl)
eavg_sh=fltarr(nl)
esig_nh=fltarr(nl)
esig_sh=fltarr(nl)

zavg=fltarr(nl)
speedavg_nh=fltarr(nl)
speedavg_sh=fltarr(nl)
speedsig_nh=fltarr(nl)
speedsig_sh=fltarr(nl)

dthdtavg_nh=fltarr(nl)
dthdtavg_sh=fltarr(nl)
dthdtsig_nh=fltarr(nl)
dthdtsig_sh=fltarr(nl)

nhindex=where(alat ge 60.)
shindex=where(alat le -60.)
for ilev=0L,nl-1L do begin
    zavg(ilev)=mean(zgrd(*,*,ilev))
    noavg_nh(ilev)=mean(no_conc(*,nhindex,ilev))
    noavg_sh(ilev)=mean(no_conc(*,shindex,ilev))
    nosig_nh(ilev)=stdev(no_conc(*,nhindex,ilev))
    nosig_sh(ilev)=stdev(no_conc(*,shindex,ilev))

    eavg_nh(ilev)=mean(egrd(*,nhindex,ilev))
    eavg_sh(ilev)=mean(egrd(*,shindex,ilev))
    esig_nh(ilev)=stdev(egrd(*,nhindex,ilev))
    esig_sh(ilev)=stdev(egrd(*,shindex,ilev))

    speedavg_nh(ilev)=mean(speedgrd(*,nhindex,ilev))
    speedavg_sh(ilev)=mean(speedgrd(*,shindex,ilev))
    speedsig_nh(ilev)=stdev(speedgrd(*,nhindex,ilev))
    speedsig_sh(ilev)=stdev(speedgrd(*,shindex,ilev))

    dthdtavg_nh(ilev)=mean(dthdtgrd(*,nhindex,ilev))
    dthdtavg_sh(ilev)=mean(dthdtgrd(*,shindex,ilev))
    dthdtsig_nh(ilev)=stdev(dthdtgrd(*,nhindex,ilev))
    dthdtsig_sh(ilev)=stdev(dthdtgrd(*,shindex,ilev))
endfor	; loop over pressure
szavg=string(FORMAT='(i3)',zavg)+'km'

    erase
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    xyouts,.15,.95,'WA3548T08CO      '+sdate,/normal,color=0,charsize=3,charthick=3
    plot,noavg_nh,zavg,/noeras,color=0,title='NO',xtitle='molecules/cm!u3!n',ytitle='Altitude (km)',xrange=[0.,5.e8],yrange=[80.,140.]
    oplot,noavg_nh,zavg,color=0,thick=10
    oplot,noavg_nh+nosig_nh,zavg,color=0,thick=1
    oplot,noavg_nh-nosig_nh,zavg,color=0,thick=1
    oplot,noavg_sh,zavg,color=250,linestyle=5,thick=10
    oplot,noavg_sh+nosig_sh,zavg,color=250,linestyle=5,thick=1
    oplot,noavg_sh-nosig_sh,zavg,color=250,linestyle=5,thick=1

    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    plot,eavg_nh,zavg,/noeras,color=0,title='Electron Concentration',xrange=[0.,5.e-6],yrange=[80.,140.],xtitle='mol/mol'
    oplot,eavg_nh,zavg,color=0,thick=10
    oplot,eavg_nh+esig_nh,zavg,color=0,thick=1
    oplot,eavg_nh-esig_nh,zavg,color=0,thick=1
    oplot,eavg_sh,zavg,color=250,linestyle=5,thick=10
    oplot,eavg_sh+esig_sh,zavg,color=250,linestyle=5,thick=1
    oplot,eavg_sh-esig_sh,zavg,color=250,linestyle=5,thick=1

    xyouts,.45,.525,'NH > 60N',/normal,color=0,charsize=2,charthick=3
    xyouts,.45,.49,'SH < 60S',/normal,color=250,charsize=2,charthick=3

    xmn=xorig(2)
    xmx=xorig(2)+xlen
    ymn=yorig(2)
    ymx=yorig(2)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    plot,speedavg_nh,zavg,/noeras,color=0,title='Horizontal Wind Speed',xrange=[0.,200.],yrange=[80.,140.],xtitle='m/s',ytitle='Altitude (km)'
    oplot,speedavg_nh,zavg,color=0,thick=10
    oplot,speedavg_nh+speedsig_nh,zavg,color=0,thick=1
    oplot,speedavg_nh-speedsig_nh,zavg,color=0,thick=1
    oplot,speedavg_sh,zavg,color=250,linestyle=5,thick=10
    oplot,speedavg_sh+speedsig_sh,zavg,color=250,linestyle=5,thick=1
    oplot,speedavg_sh-speedsig_sh,zavg,color=250,linestyle=5,thick=1

    xmn=xorig(3)
    xmx=xorig(3)+xlen
    ymn=yorig(3)
    ymx=yorig(3)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    plot,dthdtavg_nh,zavg,/noeras,color=0,title='d(Theta)/dt',xrange=[-300.,300.],yrange=[80.,140.],xtitle='K/day'
    oplot,dthdtavg_nh,zavg,color=0,thick=10
    plots,0,80.
    plots,0,140.,/continue,color=0,thick=1
    oplot,dthdtavg_nh+dthdtsig_nh,zavg,color=0,thick=1
    oplot,dthdtavg_nh-dthdtsig_nh,zavg,color=0,thick=1
    oplot,dthdtavg_sh,zavg,color=250,linestyle=5,thick=10
    oplot,dthdtavg_sh+dthdtsig_sh,zavg,color=250,linestyle=5,thick=1
    oplot,dthdtavg_sh-dthdtsig_sh,zavg,color=250,linestyle=5,thick=1

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert -trim polar_cap_avg_no_dens_WA3548T08CO_'+sdate+'.ps -rotate -90 polar_cap_avg_no_dens_WA3548T08CO_'+sdate+'.jpg'
       spawn,'rm -f polar_cap_avg_no_dens_WA3548T08CO_'+sdate+'.ps'
    endif

icount=1
goto, jump

end
