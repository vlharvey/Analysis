;
; plot daily average vertical profile of dth/dz for GEOS-5 and MLS inside/outside the vortex
; 

@stddat
@kgmt
@ckday
@kdate

sver='v2.2'

a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
loadct,39
mcolor=!p.color
icolmax=byte(!p.color)
icmm1=icolmax-1B
icmm2=icolmax-2B
device,decompose=0
nlvls=19
col1=1+indgen(nlvls)*icolmax/nlvls
!NOERAS=-1
!P.FONT=1
!p.charsize=1
!p.charthick=2
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.25]
yorig=[0.15]
xlen=0.5
ylen=0.7
cbaryoff=0.02
cbarydel=0.01
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'
dir='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS520.MetO.'
dirm='/aura6/data/MLS_data/Datfiles_SOSST/'
lstmn=1
lstdy=5
lstyr=2008
ledmn=1
leddy=15
ledyr=2008
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
kday=ledday-lstday+1L
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
; read MLS CO, TEMP data and GEOS-5 MARK, TEMP and PV.  read temperature and pressure to interpolate to theta surfaces
;
      dum=findfile(dirm+'cat_mls_'+sver+'_'+sdate+'.sav')
      if dum(0) eq '' then goto,jumpday
      restore,dirm+'cat_mls_'+sver+'_'+sdate+'.sav'             ; altitude
      restore,dirm+'tpd_mls_'+sver+'_'+sdate+'.sav'             ; temperature, pressure
      restore,dirm+'co_mls_'+sver+'_'+sdate+'.sav'              ; mix
      restore,dirm+'mark_mls_'+sver+'.geos5.'+sdate+'.sav'	; mark
      restore,dirm+'dmps_mls_'+sver+'.geos5.'+sdate+'.sav'	; GEOS DMPs on theta
      nz=n_elements(altitude)
      nth=n_elements(thlev)
      th=thlev
      mprof=n_elements(longitude)
      mlev=n_elements(altitude)
      muttime=time
      mlat=latitude
      mlon=longitude
      bad=where(mask eq -99.)
      if bad(0) ne -1L then mix(bad)=-99.
      good=where(mix ne -99.)
      if good(0) eq -1L then goto,jump
      mco=mix*1.e6
      mtemp=temperature
      bad=where(temperature eq -99.)
      if bad(0) ne -1L then temperature(bad)=-99.
      mpress=pressure
;
; eliminate bad profiles and profiles below 40 N
;
      index=where(muttime gt 0. and mlat gt 40.,mprof)
      if index(0) eq -1L then goto,jump
      muttime=reform(muttime(index))
      mlat=reform(mlat(index))
      mlon=reform(mlon(index))
      mtemp=reform(mtemp(index,*))
      mpress=reform(mpress(index,*))
      mco=reform(mco(index,*))
      mmark=reform(mark_prof(index,*))
;
; GEOS DMP arrays already on theta
;
      PV_PROF=PV_PROF(index,*)
      galtitude=Z_PROF(index,*)
      gtemp=TP_PROF(index,*)
      gpress=P_PROF(index,*)
      gtheta=THLEV
;
; compute MLS potential temperature
;
      mtheta=mtemp*(1000./mpress)^0.286
      index=where(mtemp eq -99.)
      if index(0) ne -1L then mtheta(index)=-99.
;
; MLS dtheta/dz = (th1-th0) / (z1-z0)
;
      mdthdz=0.*mtheta
      for i=0,mprof-1 do begin
      for k=0,mlev-1 do begin
          lm1=k-1
          lp1=k+1
          if k eq 0 then lm1=0
          if k eq mlev-1 then lp1=mlev-1
          mdthdz(i,k)=(mtheta(i,lp1)-mtheta(i,lm1))/(altitude(lp1)-altitude(lm1))
      endfor
      endfor
      index=where(mtemp eq -99.)
      if index(0) ne -1L then mdthdz(index)=-99.
;
; interpolate MLS CO, temp, dth/dz data to GEOS-5 theta surfaces
;
      mco_th=fltarr(mprof,nth)
      mmark_th=fltarr(mprof,nth)
      mtemp_th=fltarr(mprof,nth)
      mdthdz_th=fltarr(mprof,nth)
      for k=nth-1L,0L,-1L do begin
          zlev=th(k)
          for iprof=0L,mprof-1L do begin
              for kk=2L,nz-2L do begin
                  if mco(iprof,kk) ne -9.90000e+07 and mco(iprof,kk+1) ne -9.90000e+07 then begin
                  if mtheta(iprof,kk) lt zlev and mtheta(iprof,kk+1) ge zlev then begin
                     zscale=(mtheta(iprof,kk+1)-zlev)/(mtheta(iprof,kk+1)-mtheta(iprof,kk))
                     mco_th(iprof,k)= mco(iprof,kk+1)+zscale*(mco(iprof,kk)-mco(iprof,kk+1))
;print,mtheta(iprof,kk),zlev,mtheta(iprof,kk+1),zscale
;print,mco(iprof,kk),mco_th(iprof,k),mco(iprof,kk+1)
;stop
                  endif
                  endif
                  if mtemp(iprof,kk) gt 0. and mtemp(iprof,kk+1) gt 0. then begin
                  if mtheta(iprof,kk) lt zlev and mtheta(iprof,kk+1) ge zlev then begin
                     zscale=(mtheta(iprof,kk+1)-zlev)/(mtheta(iprof,kk+1)-mtheta(iprof,kk))
                     mtemp_th(iprof,k)=mtemp(iprof,kk+1)+zscale*(mtemp(iprof,kk)-mtemp(iprof,kk+1))
                     mdthdz_th(iprof,k)=mdthdz(iprof,kk+1)+zscale*(mdthdz(iprof,kk)-mdthdz(iprof,kk+1))
                  endif
                  endif
                  if mmark(iprof,kk) ne -99. and mmark(iprof,kk+1) ne -99. then begin
                  if mtheta(iprof,kk) lt zlev and mtheta(iprof,kk+1) ge zlev then begin
                     zscale=(mtheta(iprof,kk+1)-zlev)/(mtheta(iprof,kk+1)-mtheta(iprof,kk))
                     mmark_th(iprof,k)=mmark(iprof,kk+1)+zscale*(mmark(iprof,kk)-mmark(iprof,kk+1))
                  endif
                  endif
              endfor
          endfor
      endfor
;
; GEOS dtheta/dz = (th1-th0) / (z1-z0)
;
      gdthdz=0.*gpress
      for i=0,mprof-1 do begin
      for k=0,nth-1 do begin
          lm1=k-1
          lp1=k+1
          if k eq 0 then lm1=0
          if k eq nth-1 then lp1=nth-1
          gdthdz(i,k)=(gtheta(lp1)-gtheta(lm1))/(galtitude(i,lp1)-galtitude(i,lm1))
      endfor
      endfor
      index=where(gtemp eq -99.)
      if index(0) ne -1L then gdthdz(index)=-99.
;
; working arrays:
; MCO_TH          FLOAT     = Array[1328, 42]	; mls co
; MTEMP_TH        FLOAT     = Array[1328, 42]	; mls temp
; MDTHDZ_TH       FLOAT     = Array[1328, 42]	; mls dth/dz
; PV_PROF         FLOAT     = Array[1328, 42]	; geos pv
; MMARK_TH        FLOAT     = Array[1328, 42]	; geos mark
; GTEMP           FLOAT     = Array[1328, 42]	; geos temp
; GDTHDZ          FLOAT     = Array[1328, 42]	; geos dth/dz
print,'MLS CO ',min(MCO_TH),max(MCO_TH)
print,'MLS TP ',min(MTEMP_TH),max(MTEMP_TH)
print,'MLS DTHDZ ',min(MDTHDZ_TH),max(MDTHDZ_TH)
print,'GEOS PV ',min(PV_PROF),max(PV_PROF)
print,'GEOS Mark ',min(MMARK_TH),max(MMARK_TH)
print,'GEOS TP ',min(GTEMP),max(GTEMP)
print,'GEOS DTHDZ ',min(GDTHDZ),max(GDTHDZ)
;help,MCO_TH,MTEMP_TH,MDTHDZ_TH,PV_PROF,MMARK_TH,GTEMP,GDTHDZ
; 
; declare average profiles in and out of vortex
;
    gtp_in=fltarr(nth)
    gtp_out=fltarr(nth)
    gpv_in=fltarr(nth)
    gpv_out=fltarr(nth)
    gdthdz_in=fltarr(nth)
    gdthdz_out=fltarr(nth)
    mtp_in=fltarr(nth)
    mtp_out=fltarr(nth)
    mdthdz_in=fltarr(nth)
    mdthdz_out=fltarr(nth)
    mco_in=fltarr(nth)
    mco_out=fltarr(nth)
help,MCO_TH,MTEMP_TH,MDTHDZ_TH,PV_PROF,MMARK_TH,GTEMP,GDTHDZ
;
; average in and out of vortex
;
    for k=0L,nth-1L do begin
        invort=where(mmark_th(*,k) gt 0.5 and MTEMP_TH ne 0.,nin)
        if invort(0) ne -1L then begin
            gtp_in(k)=total(GTEMP(invort,k))/float(nin)
            gpv_in(k)=total(PV_PROF(invort,k))/float(nin)
            gdthdz_in(k)=total(GDTHDZ(invort,k))/float(nin)
            mtp_in(k)=total(MTEMP_TH(invort,k))/float(nin)
            mdthdz_in(k)=total(MDTHDZ_TH(invort,k))/float(nin)
            mco_in(k)=total(MCO_TH(invort,k))/float(nin)
        endif
        outvort=where(mmark_th(*,k) le 0. and MTEMP_TH ne 0.,nout)
        if outvort(0) ne -1L then begin
            gtp_out(k)=total(GTEMP(outvort,k))/float(nout)
            gpv_out(k)=total(PV_PROF(outvort,k))/float(nout)
            gdthdz_out(k)=total(GDTHDZ(outvort,k))/float(nout)
            mtp_out(k)=total(MTEMP_TH(outvort,k))/float(nout)
            mdthdz_out(k)=total(MDTHDZ_TH(outvort,k))/float(nout)
            mco_out(k)=total(MCO_TH(outvort,k))/float(nout)
        endif
    endfor
;
; compute ratios
;
gtp_ratio=0.*gtp_out
gpv_ratio=0.*gtp_out
gdthdz_ratio=0.*gtp_out
mtp_ratio=0.*gtp_out
mdthdz_ratio=0.*gtp_out
mco_ratio=0.*gtp_out
index=where(gtp_out ne 0.)
if index(0) ne -1L then begin
   gtp_ratio(index)=gtp_in(index)/gtp_out(index)
   gpv_ratio(index)=gpv_in(index)/gpv_out(index)
   gdthdz_ratio(index)=gdthdz_in(index)/gdthdz_out(index)
   mtp_ratio(index)=mtp_in(index)/mtp_out(index)
   mdthdz_ratio(index)=mdthdz_in(index)/mdthdz_out(index)
   mco_ratio(index)=mco_in(index)/mco_out(index)
endif
;
; postscript
;
    if setplot eq 'ps' then begin
       lc=0
       xsize=nxdim/100.
       ysize=nydim/100.
       set_plot,'ps'
       device,/color,/landscape,bits=8,filename='prof_nh_geos_mls_dthdz_in_out_'+sdate+'.ps'
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
    plot,gdthdz_ratio,th,color=0,title='GEOS-5 '+sdate,charsize=1.5,$
         xtitle='dth/dz in/out',xrange=[0.5,1.5],yrange=[500.,3000.],thick=4
    index=where(mdthdz_ratio ne 0.)
    if index(0) ne -1L then oplot,mdthdz_ratio(index),th(index),color=0,psym=8
    plots,1,500.
    plots,1,3000.,/continue,color=0

    index=where(gtp_ratio ne 0.)
    if index(0) ne -1L then oplot,gtp_ratio(index),th(index),color=mcolor*.2,thick=4
    index=where(mtp_ratio ne 0.)
    if index(0) ne -1L then oplot,mtp_ratio(index),th(index),color=mcolor*.2,psym=8
;   oplot,gpv_ratio,th,color=mcolor*.9,thick=4
;   oplot,mco_ratio,th,color=mcolor*.8,psym=8

    icount=icount+1

; Close PostScript file and return control to X-windows
     if setplot ne 'ps' then stop
     if setplot eq 'ps' then begin
        device, /close
        spawn,'convert -trim prof_nh_geos_mls_dthdz_in_out_'+sdate+'.ps -rotate -90 '+$
                            'prof_nh_geos_mls_dthdz_in_out_'+sdate+'.jpg'
        spawn,'/usr/bin/rm prof_nh_geos_mls_dthdz_in_out_'+sdate+'.ps'
     endif
     jumpday:
goto,jump
end
