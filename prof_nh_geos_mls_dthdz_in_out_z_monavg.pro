;
; MLS only T and dth/dz in/out up to top of mmark
; 
@stddat
@kgmt
@ckday
@kdate

sver='v2.2'
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
loadct,39
mcolor=fix(byte(!p.color))
if mcolor ne 255 then mcolor=255
icmm1=mcolor-1B
icmm2=mcolor-2B
device,decompose=0
nlvls=19
col1=1+indgen(nlvls)*mcolor/nlvls
!NOERAS=-1
!P.FONT=1
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.1,0.4,0.7]
yorig=[0.25,0.25,0.25]
xlen=0.25
ylen=0.5
cbaryoff=0.02
cbarydel=0.01
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dirm='/aura6/data/MLS_data/Datfiles_SOSST/'
lmonth=1+indgen(12)
mday=[31,28,31,30,31,30,31,31,30,31,30,31]
nmonth=n_elements(lmonth)
lyear=[2004,2005,2006,2007,2008,2009]
nyear=n_elements(lyear)

for iyear=0L,nyear-1L do begin
for imonth=0L,nmonth-1L do begin

lstmn=imonth+1L
lstdy=1
lstyr=lyear(iyear)
ledmn=lstmn
leddy=mday(imonth)
ledyr=lyear(iyear)
if ledyr mod 4 eq 0L and lstmn eq 2L then leddy=mday(imonth)+1	; leap day
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
      if ndays gt ledday then goto,plotit
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
      syrmon=syr+smn
dum=findfile('prof_nh_mls_dthdz_in_out_'+syrmon+'_z_monavg.sav')
if dum(0) ne '' then goto,quick
print,sdate
;
; read MLS CO, TEMP data and GEOS-5 MARK, TEMP and PV.  read temperature and pressure to interpolate to theta surfaces
;
      dum=findfile(dirm+'mark_mls_'+sver+'.geos5.'+sdate+'.sav')
      if dum(0) eq '' then goto,jumpday
      restore,dirm+'cat_mls_'+sver+'_'+sdate+'.sav'             ; altitude
      restore,dirm+'tpd_mls_'+sver+'_'+sdate+'.sav'             ; temperature, pressure
      restore,dirm+'co_mls_'+sver+'_'+sdate+'.sav'              ; mix
      restore,dirm+'mark_mls_'+sver+'.geos5.'+sdate+'.sav'	; mark
      nz=n_elements(altitude)
      mprof=n_elements(longitude)
      mlev=n_elements(altitude)
      muttime=time
      mlat=latitude
      mlon=longitude
      bad=where(mask eq -99.)
      if bad(0) ne -1L then mix(bad)=-99.
      good=where(mix ne -99.)
      if good(0) eq -1L then goto,jump
      mix(good)=mix(good)*1.e6
      mco=mix
      mtemp=temperature
      bad=where(temperature eq -99.)
      if bad(0) ne -1L then temperature(bad)=-99.
      mpress=pressure
;
; eliminate bad profiles and profiles below 40 N
;
      index=where(muttime gt 0. and mlat gt 20.,mprof)
      if index(0) eq -1L then goto,jump
      muttime=reform(muttime(index))
      mlat=reform(mlat(index))
      mlon=reform(mlon(index))
      mtemp=reform(mtemp(index,*))
      mpress=reform(mpress(index,*))
      mco=reform(mco(index,*))
      mmark=reform(mark_prof(index,*))
;     mmark=smooth(mmark,5)
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
; declare average profiles in and out of vortex
;
      mtp_in=fltarr(mlev)
      mtp_out=fltarr(mlev)
      mdthdz_in=fltarr(mlev)
      mdthdz_out=fltarr(mlev)
      mco_in=fltarr(mlev)
      mco_out=fltarr(mlev)
;
; average in and out of vortex
;
;set_viewport,.1,.9,.1,.9
;map_set,90,0,0,/ortho,/contin,/grid,color=0
      for k=0L,mlev-1L do begin
;oplot,mlon,mlat,psym=8,color=0
          mmark_lev=reform(mmark(*,k))
          mtp_lev=reform(mtemp(*,k))
          mdthdz_lev=reform(mdthdz(*,k))
          mco_lev=reform(mco(*,k))
;index=where(mmark_lev eq 1.)
;if index(0) ne -1L then oplot,mlon(index),mlat(index),psym=8,color=mcolor*.3

          invort=where(mmark_lev eq 1. and mtp_lev ne -99. and mco_lev ne -99.,nin)
          outvort=where(mmark_lev le 0.25 and mmark_lev ne -99. and mtp_lev ne -99. and mco_lev ne -99.,nout)

          if nin ge 100L and nout ge 100L then begin
;oplot,mlon(invort),mlat(invort),psym=8,color=mcolor*.2
             mtp_in(k)=total(mtp_lev(invort))/float(nin)
             mdthdz_in(k)=total(mdthdz_lev(invort))/float(nin)
             mco_in(k)=total(mco_lev(invort))/float(nin)

;oplot,mlon(outvort),mlat(outvort),psym=2,color=mcolor*.9
             mtp_out(k)=total(mtp_lev(outvort))/float(nout)
             mdthdz_out(k)=total(mdthdz_lev(outvort))/float(nout)
             mco_out(k)=total(mco_lev(outvort))/float(nout)
;print,altitude(k),min(mmark(*,k)),max(mmark(*,k)),nin,nout
          endif
      endfor
;
; compute ratios
;
      mtp_ratio=0.*mtp_out
      mdthdz_ratio=0.*mtp_out
      mco_ratio=0.*mtp_out
      index=where(mtp_out ne 0.)
      if index(0) ne -1L then begin
         mtp_ratio(index)=mtp_in(index)/mtp_out(index)
         mdthdz_ratio(index)=mdthdz_in(index)/mdthdz_out(index)
         mco_ratio(index)=mco_in(index)/mco_out(index)
      endif

      if icount eq 0L then begin
         mtp_ratio_avg=fltarr(mlev)
         mdthdz_ratio_avg=fltarr(mlev)
         mco_ratio_avg=fltarr(mlev)
         mnum_ratio_avg=fltarr(mlev)
      endif 
      if index(0) ne -1L then begin
      mtp_ratio_avg(index)=mtp_ratio_avg(index)+mtp_ratio(index)
      mdthdz_ratio_avg(index)=mdthdz_ratio_avg(index)+mdthdz_ratio(index)
      mco_ratio_avg(index)=mco_ratio_avg(index)+mco_ratio(index)
      mnum_ratio_avg(index)=mnum_ratio_avg(index)+1.
      endif
;print,max(mtp_ratio_avg(index)),max(mtp_ratio(index))

      icount=icount+1

      jumpday:
goto,jump
;
plotit:
if icount lt 5 then goto,jumpmon

index=where(mnum_ratio_avg gt 1.)
if index(0) ne -1L then begin
   mtp_ratio(index)=mtp_ratio_avg(index)/mnum_ratio_avg(index)
   mdthdz_ratio(index)=mdthdz_ratio_avg(index)/mnum_ratio_avg(index)
   mco_ratio(index)=mco_ratio_avg(index)/mnum_ratio_avg(index)
endif
;
; save file
;
save,file='prof_nh_mls_dthdz_in_out_'+syrmon+'_z_monavg.sav',$
     mtp_ratio,mdthdz_ratio,mco_ratio,altitude,icount,syrmon
;
; for quick plotting
;
quick:
restore,'prof_nh_mls_dthdz_in_out_'+syrmon+'_z_monavg.sav'
print,'saved/read average '+syrmon,icount
;
; postscript
;
    if setplot eq 'ps' then begin
       lc=0
       xsize=nxdim/100.
       ysize=nydim/100.
       set_plot,'ps'
       device,/color,/landscape,bits=8,filename='prof_nh_mls_dthdz_in_out_'+syrmon+'_z_monavg.ps'
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
    scount=strcompress(icount,/remove_all)
    xyouts,0.4,ymx+0.075,'MLS '+syrmon+' ('+scount+' days)',charsize=3,color=0,/normal
    set_viewport,xmn,xmx,ymn,ymx
    plot,mtp_ratio,altitude,color=0,title='Temperature in/out',xrange=[0.75,1.25],yrange=[20.,70.],/nodata,$
         charsize=1.5,ytitle='Altitude (km)'
    plots,1,20.
    plots,1,70.,/continue,color=0
    index=where(mtp_ratio ne 0.)
    if index(0) ne -1L then oplot,mtp_ratio(index),altitude(index),color=0,psym=8

    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    plot,mdthdz_ratio,altitude,color=0,title='dth/dz in/out',charsize=1.5,xrange=[0.75,2],yrange=[20.,70.],/nodata
    plots,1,20.
    plots,1,70.,/continue,color=0
    index=where(mdthdz_ratio ne 0.)
    if index(0) ne -1L then oplot,mdthdz_ratio(index),altitude(index),color=0,psym=8  ;,thick=4

    xmn=xorig(2)
    xmx=xorig(2)+xlen
    ymn=yorig(2)
    ymx=yorig(2)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    plot,mco_ratio,altitude,color=0,title='CO in/out',charsize=1.5,$
         xrange=[0.1,100.],/xlog,yrange=[20.,70.],/nodata
    plots,1,20.
    plots,1,70.,/continue,color=0
    index=where(mco_ratio ne 0.)
    if index(0) ne -1L then oplot,mco_ratio(index),altitude(index),color=0,psym=8  ;,thick=4

; Close PostScript file and return control to X-windows
     if setplot ne 'ps' then stop
     if setplot eq 'ps' then begin
        device, /close
        spawn,'convert -trim prof_nh_mls_dthdz_in_out_'+syrmon+'_z_monavg.ps -rotate -90 '+$
                            'prof_nh_mls_dthdz_in_out_'+syrmon+'_z_monavg.jpg'
        spawn,'/usr/bin/rm prof_nh_mls_dthdz_in_out_'+syrmon+'_z_monavg.ps'
     endif

jumpmon:
endfor	; loop over months
endfor	; loop over years
end
