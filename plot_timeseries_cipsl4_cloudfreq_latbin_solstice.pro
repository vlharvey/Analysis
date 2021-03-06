;
; plot relative to days from solstice
;
; read one CIPS IDL save file of all days of cloud frequency binned every 5 degrees latitude
; timeseries of frequency in 4 seasons at latitudes 50-85 by 5 degrees in each hem
;
; color table and symbol, set path
;
loadct,39
device,decompose=0
mcolor=byte(!p.color)
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=750
nydim=750
xorig=[0.15]
yorig=[0.25]
xlen=0.7
ylen=0.5
!noeras=1
setplot='x'
read,'setplot=',setplot
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
!p.background=mcolor
pth='/aura7/harvey/CIPS_data/Datfiles/cips_sci_4_orbit_'
smonth=['J','F','M','A','M','J','J','A','S','O','N','D']
;
; latbins
;
nlat=35
latbin=-85.+5.*findgen(nlat)    ; -85 to 85
goto,quick
;
; set date range
;
lstmn=5
lstdy=25
lstyr=2007
ledmn=4
leddy=1
ledyr=2009

lstday=0
ledday=0
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
icount = 0
kcount = 0
;
; loop over days
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,plotit
      syear=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sday=string(FORMAT='(I3.3)',iday)
      sdate=syear+smn+sdy
      if icount eq 0 then begin
         sdate_all=strarr(kday)
         fdoy_all=fltarr(kday)
         cloud_freq_max_all=fltarr(kday,nlat)
         cloud_freq_avg_all=fltarr(kday,nlat)
         cloud_freq_sigma_all=fltarr(kday,nlat)
         icount=1
      endif
      sdate_all(kcount)=sdate
      fdoy_all(kcount)=float(iday)
;
; skip if save file does not exist
;
      dum=findfile(pth+sdate+'_v03.20.sav')
      if dum(0) eq '' then begin
         print,sdate+' missing'
         kcount=kcount+1
         goto,jump
      endif
;
; restore daily file
;
      ofile=pth+sdate+'_v03.20.sav'
      print,ofile
      restore,ofile	;contents: latbin,cloud_points,total_points,norbit
;
; why are some of the total_points values large negative???
;
      bad=where(total_points lt 0.)
      if bad(0) ne -1L then total_points(bad)=0.
;
; convert number of cloud points to percent clouds
;
      good=where(total_points gt 0.)
      cloud_freq=0.*cloud_points
      if good(0) ne -1L then begin
         cloud_freq(good)=100.*cloud_points(good)/total_points(good)
         index=where(cloud_points gt total_points)
         if index(0) ne -1L then stop,'cld points > total'
      endif
;
; cloud array is (kday,nlat). daily avg, max, sig cloud arrays are (nlat,norbit)
; compute daily average and sigma at each lat
;
      for j=0,nlat-1 do begin
          cloud_freq_orbits=reform(cloud_freq(j,*))
          result=moment(cloud_freq_orbits)
          cloud_freq_max_all(kcount,j)=max(cloud_freq_orbits)	; max of all orbits in this lat
          cloud_freq_avg_all(kcount,j)=result(0)	; avg over orbits in this lat
          cloud_freq_sigma_all(kcount,j)=sqrt(result(1))
print,latbin(j),cloud_freq_max_all(kcount,j),cloud_freq_avg_all(kcount,j),cloud_freq_sigma_all(kcount,j)
      endfor

erase
!type=2^2+2^3
plot,latbin,cloud_freq(*,0),psym=2,/nodata,title=sdate,yrange=[0.,100.],$
     ytitle='Cloud Frequency (%)',xtitle='Latitude',xrange=[-90.,90.],color=0
for iorbit=0,norbit-1 do begin
    oplot,latbin,cloud_freq(*,iorbit),psym=0,color=(float(iorbit)/float(norbit))*mcolor,thick=3
endfor
;stop

      kcount=kcount+1

goto,jump
;
; plot timeseries in each latitude bin
;
plotit:
save,file='cloud_freq_latbin_all.sav',cloud_freq_avg_all,cloud_freq_max_all,cloud_freq_sigma_all,$
     latbin,fdoy_all,sdate_all
quick:
restore,'cloud_freq_latbin_all.sav'
;
; loop over lat bins
;
for ilat=0L,nlat/2-1L do begin
    index=where(latbin eq abs(latbin(ilat)))
    ilat2=index(0)
    if max(cloud_freq_max_all(*,ilat)) lt 2. and max(cloud_freq_max_all(*,ilat2)) lt 2. then goto,skiplat
    slat=string(format='(i2)',abs(latbin(ilat)))
;
; ps file for this lat bin
;
    if setplot eq 'ps' then begin
       lc=0
       xsize=nxdim/100.
       ysize=nydim/100.
       set_plot,'ps'
       device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
              /bold,/color,bits_per_pixel=8,/helvetica,filename='timeseries_cipsl4_cloudfreq_'+slat+'.ps'
       !p.charsize=1.25
       !p.thick=2
       !p.charthick=5
       !p.charthick=5
       !y.thick=2
       !x.thick=2
    endif
    erase
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
;
; avg frequency and sigma at this latitude
;
    cloud_freq_avg_lat=reform(cloud_freq_avg_all(*,ilat))	; fltarr(kday) at ilat
    cloud_freq_max_lat=reform(cloud_freq_max_all(*,ilat))	; fltarr(kday) at ilat
    cloud_freq_sigma_lat=reform(cloud_freq_sigma_all(*,ilat)) 
;
; NH
;
    cloud_freq_avg_lat2=reform(cloud_freq_avg_all(*,ilat2))       ; fltarr(kday) at ilat2
    cloud_freq_max_lat2=reform(cloud_freq_max_all(*,ilat2))       ; fltarr(kday) at ilat2
    cloud_freq_sigma_lat2=reform(cloud_freq_sigma_all(*,ilat2))

;sdate_all=strarr(kday)
;fdoy_all=fltarr(kday)

    imin=-40.
    imax=80.
    ndoy=imax-imin
    xlab=['-40','-20','0','20','40','60','80']
    nxticks=n_elements(xtickname)
    plot,findgen(ndoy),cloud_freq_max_lat,ytitle='Cloud Frequency (%)',xrange=[imin,imax],$
         xticks=nxticks,xtickname=xlab,xtickv=float(xlab),charsize=1.5,color=0,/nodata,$
         title='CIPS Level 4 V3.20 Latitude='+slat,yrange=[0.,100.],xtitle='Days from Solstice'
;
; oplot each year
;
    syear=strmid(strcompress(sdate_all,/remove_all),0,4)
;
; NH easy
;
    nhsol=172.
    index=where(syear eq '2007' and cloud_freq_avg_lat2 ge 0.1 and fdoy_all ge nhsol-40 and fdoy_all lt nhsol+80.)
    if index(0) ne -1L then oplot,fdoy_all(index)-nhsol,cloud_freq_avg_lat2(index),color=mcolor*.1,psym=8
    if index(0) ne -1L then oplot,fdoy_all(index)-nhsol,cloud_freq_avg_lat2(index),color=mcolor*.1,psym=0,thick=3
;   if index(0) ne -1L then begin
;      for i=0L,n_elements(index)-1 do begin
;      plots,fdoy_all(index(i))-nhsol,cloud_freq_avg_lat2(index(i))+cloud_freq_sigma_lat2(index(i)),color=mcolor*.1
;      plots,fdoy_all(index(i))-nhsol,cloud_freq_avg_lat2(index(i))-cloud_freq_sigma_lat2(index(i)),color=mcolor*.1,$
;            thick=2,/continue
;      endfor
;   endif
    index=where(syear eq '2008' and cloud_freq_avg_lat2 ge 0.1 and fdoy_all ge nhsol-40 and fdoy_all lt nhsol+80.)
    if index(0) ne -1L then oplot,fdoy_all(index)-nhsol,cloud_freq_avg_lat2(index),color=mcolor*.3,psym=8
    if index(0) ne -1L then oplot,fdoy_all(index)-nhsol,cloud_freq_avg_lat2(index),color=mcolor*.3,psym=0,thick=3
;   if index(0) ne -1L then begin
;      for i=0L,n_elements(index)-1 do begin
;      plots,fdoy_all(index(i))-nhsol,cloud_freq_avg_lat2(index(i))+cloud_freq_sigma_lat2(index(i)),color=mcolor*.3
;      plots,fdoy_all(index(i))-nhsol,cloud_freq_avg_lat2(index(i))-cloud_freq_sigma_lat2(index(i)),color=mcolor*.3,$
;            thick=2,/continue
;      endfor
;   endif
;
; SH
;
    shsol=355.
    index1=where(syear eq '2007' and fdoy_all ge shsol-40. and cloud_freq_avg_lat ge 0.1)
    index2=where(syear eq '2008' and fdoy_all lt nhsol+80 and cloud_freq_avg_lat ge 0.1)
    if index1(0) ne -1L then oplot,fdoy_all(index1)-365.,cloud_freq_avg_lat(index1),color=mcolor*.8,psym=8
    if index1(0) ne -1L then oplot,fdoy_all(index1)-365.,cloud_freq_avg_lat(index1),color=mcolor*.8,psym=0,thick=3
    if index2(0) ne -1L then oplot,fdoy_all(index2),cloud_freq_avg_lat(index2),color=mcolor*.8,psym=8
    if index2(0) ne -1L then oplot,fdoy_all(index2),cloud_freq_avg_lat(index2),color=mcolor*.8,psym=0,thick=3

    index1=where(syear eq '2008' and fdoy_all ge shsol-40. and cloud_freq_avg_lat ge 0.1)
    index2=where(syear eq '2009' and fdoy_all lt nhsol+80 and cloud_freq_avg_lat ge 0.1)
    if index1(0) ne -1L then oplot,fdoy_all(index1)-365.,cloud_freq_avg_lat(index1),color=mcolor*.9,psym=8
    if index1(0) ne -1L then oplot,fdoy_all(index1)-365.,cloud_freq_avg_lat(index1),color=mcolor*.9,psym=0,thick=3
    if index2(0) ne -1L then oplot,fdoy_all(index2),cloud_freq_avg_lat(index2),color=mcolor*.9,psym=8
    if index2(0) ne -1L then oplot,fdoy_all(index2),cloud_freq_avg_lat(index2),color=mcolor*.9,psym=0,thick=3
 print,cloud_freq_avg_lat(index1)
 print,cloud_freq_avg_lat(index2)
if ilat eq 0 then stop
    xyouts,-35.,95.,'NH 2007',color=mcolor*.1,/data,charsize=1.5,charthick=5
    xyouts,-35.,90,'NH 2008',color=mcolor*.3,/data,charsize=1.5,charthick=5
    xyouts,40.,95.,'SH 2007-2008',color=mcolor*.8,/data,charsize=1.5,charthick=5
    xyouts,40.,90,'SH 2008-2009',color=mcolor*.9,/data,charsize=1.5,charthick=5
;
; convert ps to jpg
;
    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim timeseries_cipsl4_cloudfreq_'+slat+'.ps -rotate -90 timeseries_cipsl4_cloudfreq_'+slat+'.jpg'
    endif

skiplat:
endfor
end
