;
; total counts, not % of days
; fco, gco, mee00, mee01
;
@stddat
@kgmt
@ckday
@kdate

loadct,39
mcolor=!p.color
mcolor=byte(!p.color)
device,decompose=0
month=['July','August','September','October','November','December',$
       'January','February','March','April','May','June']
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
smon=['J','F','M','A','M','J','J','A','S','O','N','D']
!noeras=1
nxdim=800
nydim=800
xorig=[0.15,0.15]
yorig=[0.55,0.15]
xlen=0.7
ylen=0.3
cbaryoff=0.055
cbarydel=0.005
set_plot,'x'
setplot='x'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
erase
;restore Met Office SSW stats
restore,'/aura2/harvey/UKMO_means/Pre_process/meto_wmo_ssw_diagnostics.sav
meto_nhdt=NHDT
meto_nhu60=NHU60
meto_shdt=SHDT
meto_shu60=SHU60
meto_th=TH
meto_yyyymmdd=YYYYMMDD
kmday=n_elements(meto_yyyymmdd)
;
; WACCM SSW dT and U are stored in yearly files
; restore each year and concatenate all years
;
; LEV             DOUBLE    = Array[66]
; NHDT            FLOAT     = Array[1014, 66]
; NHU60           FLOAT     = Array[1014, 66]
; SHDT            FLOAT     = Array[1014, 66]
; SHU60           FLOAT     = Array[1014, 66]
; YYYYMMDD        LONG      = Array[1014]
;
spawn,'ls /aura3/data/WACCM_data/Pre_process_Isentropic/Datfiles/waccm_ssw_stats_noaurgco_mills_*sav',ifiles
nyear=n_elements(ifiles)
for iyear=0L,nyear-1L do begin
    restore,ifiles(iyear)
    if iyear eq 0L then begin
       NHDT_all=nhdt
       nhu60_all=NHU60
       shdt_all=SHDT
       shu60_all=SHU60
       yyyymmdd_all=YYYYMMDD
    endif
    if iyear gt 0L then begin
       NHDT_all=[NHDT_all,nhdt]
       nhu60_all=[nhu60_all,NHU60]
       shdt_all=[shdt_all,SHDT]
       shu60_all=[shu60_all,SHU60]
       yyyymmdd_all=[yyyymmdd_all,YYYYMMDD]
    endif
help,NHDT_all
endfor
good=where(yyyymmdd_all ne 0L,gkday)
gNHDT=reform(nhdt_all(good,*))
gnhu60=reform(NHU60_all(good,*))
gshdt=reform(SHDT_all(good,*))
gshu60=reform(SHU60_all(good,*))
gyyyymmdd=reform(YYYYMMDD_all(good))
;
; mee runs
;
spawn,'ls /aura3/data/WACCM_data/Pre_process_Isentropic/Datfiles/waccm_ssw_stats_mee00fco_mills_*sav',ifiles
nyear=n_elements(ifiles)
for iyear=0L,nyear-1L do begin
    restore,ifiles(iyear)
    if iyear eq 0L then begin
       NHDT_all=nhdt
       nhu60_all=NHU60
       shdt_all=SHDT
       shu60_all=SHU60
       yyyymmdd_all=YYYYMMDD
    endif
    if iyear gt 0L then begin
       NHDT_all=[NHDT_all,nhdt]
       nhu60_all=[nhu60_all,NHU60]
       shdt_all=[shdt_all,SHDT]
       shu60_all=[shu60_all,SHU60]
       yyyymmdd_all=[yyyymmdd_all,YYYYMMDD]
    endif
help,NHDT_all
endfor
good=where(yyyymmdd_all ne 0L,m0kday)
m0NHDT=reform(nhdt_all(good,*))
m0nhu60=reform(NHU60_all(good,*))
m0shdt=reform(SHDT_all(good,*))
m0shu60=reform(SHU60_all(good,*))
m0yyyymmdd=reform(YYYYMMDD_all(good))

spawn,'ls /aura3/data/WACCM_data/Pre_process_Isentropic/Datfiles/waccm_ssw_stats_mee01fco_mills_*sav',ifiles
nyear=n_elements(ifiles)
for iyear=0L,nyear-1L do begin
    restore,ifiles(iyear)
    if iyear eq 0L then begin
       NHDT_all=nhdt
       nhu60_all=NHU60
       shdt_all=SHDT
       shu60_all=SHU60
       yyyymmdd_all=YYYYMMDD
    endif
    if iyear gt 0L then begin
       NHDT_all=[NHDT_all,nhdt]
       nhu60_all=[nhu60_all,NHU60]
       shdt_all=[shdt_all,SHDT]
       shu60_all=[shu60_all,SHU60]
       yyyymmdd_all=[yyyymmdd_all,YYYYMMDD]
    endif
help,NHDT_all
endfor
good=where(yyyymmdd_all ne 0L,m1kday)
m1NHDT=reform(nhdt_all(good,*))
m1nhu60=reform(NHU60_all(good,*))
m1shdt=reform(SHDT_all(good,*))
m1shu60=reform(SHU60_all(good,*))
m1yyyymmdd=reform(YYYYMMDD_all(good))

spawn,'ls /aura3/data/WACCM_data/Pre_process_Isentropic/Datfiles/waccm_ssw_stats_noaurfco_mills_*sav',ifiles
nyear=n_elements(ifiles)
for iyear=0L,nyear-1L do begin
    restore,ifiles(iyear)
    if iyear eq 0L then begin
       NHDT_all=nhdt
       nhu60_all=NHU60
       shdt_all=SHDT
       shu60_all=SHU60
       yyyymmdd_all=YYYYMMDD
    endif
    if iyear gt 0L then begin
       NHDT_all=[NHDT_all,nhdt]
       nhu60_all=[nhu60_all,NHU60]
       shdt_all=[shdt_all,SHDT]
       shu60_all=[shu60_all,SHU60]
       yyyymmdd_all=[yyyymmdd_all,YYYYMMDD]
    endif
help,NHDT_all
endfor
good=where(yyyymmdd_all ne 0L,kday)
NHDT=reform(nhdt_all(good,*))
nhu60=reform(NHU60_all(good,*))
shdt=reform(SHDT_all(good,*))
shu60=reform(SHU60_all(good,*))
yyyymmdd=reform(YYYYMMDD_all(good))
;print,lev
rth=10.707050
;read,'Enter desired pressure surface ',rth
sth=strcompress(rth,/remove_all)
index=where(abs(lev-rth) eq min(abs(lev-rth)))
if index(0) eq -1L then stop,'Invalid pressure level'
ith=index(0)
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !p.font=0
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='waccm_mills+meto_ssw_totcount_'+sth+'hPa.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
;
; choose Met Office level
;
;print,th
rth=1000.0
;read,'Enter closest theta surface to '+sth+' hPa ',rth
index=where(th eq rth)
mth=index(0)
meto_nhdtlev=reform(meto_nhdt(*,mth))
meto_nhu60lev=reform(meto_nhu60(*,mth))
meto_shdtlev=reform(meto_shdt(*,mth))
meto_shu60lev=reform(meto_shu60(*,mth))
meto_syear=strarr(kmday)
meto_smon=lonarr(kmday)
meto_jday=lonarr(kmday)
for i=0L,kmday-1L do begin
    meto_syear(i)=strmid(strcompress(meto_yyyymmdd(i),/remove_all),0,4)
    imn=long(strmid(strcompress(meto_yyyymmdd(i),/remove_all),4,2))
    meto_smon(i)=imn
    idy=long(strmid(strcompress(meto_yyyymmdd(i),/remove_all),6,2))
    iyr=long(strmid(strcompress(meto_yyyymmdd(i),/remove_all),0,4))
    z = kgmt(imn,idy,iyr,iday)
    meto_jday(i)=iday
endfor
miyr0=strcompress(min(meto_syear),/remove_all)
miyr1=strcompress(max(meto_syear),/remove_all)
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,1.+findgen(12),findgen(10),/nodata,xrange=[1,12],ytitle='Number of Days',yrange=[0.,1000],$
     title='Minor Warmings',xticks=11,xtickname=smon,color=0
meto_nh_minor=fltarr(12)
meto_nh_major=fltarr(12)
meto_sh_minor=fltarr(12)
meto_sh_major=fltarr(12)
for imon=1L,12L do begin
    index=where(meto_smon eq imon,totdays)
    index=where(meto_smon eq imon and meto_nhdtlev gt 0.,npts)
    if imon lt 5L or imon gt 9L then meto_nh_minor(imon-1L)=float(npts)
    index=where(meto_smon eq imon and meto_shdtlev gt 0.,npts)
    if imon ge 4L and imon le 8L then meto_sh_minor(imon-1L)=float(npts)
endfor
oplot,1.+findgen(12),meto_nh_minor,psym=0,color=0,thick=10
oplot,1.+findgen(12),meto_sh_minor,psym=0,color=0,thick=10,linestyle=2
;
; WACCM fco
;
nhdtlev=reform(nhdt(*,ith))
shdtlev=reform(shdt(*,ith))
nhu60lev=reform(nhu60(*,ith))
shu60lev=reform(shu60(*,ith))
syear=strarr(kday)
wa3_smon=lonarr(kday)
jday=lonarr(kday)
for i=0L,kday-1L do begin
    syear(i)=strmid(strcompress(yyyymmdd(i),/remove_all),0,4)
    imn=long(strmid(strcompress(yyyymmdd(i),/remove_all),4,2))
    wa3_smon(i)=imn
    idy=long(strmid(strcompress(yyyymmdd(i),/remove_all),6,2))
    iyr=long(strmid(strcompress(yyyymmdd(i),/remove_all),0,4))
    z = kgmt(imn,idy,iyr,iday)
    jday(i)=iday
endfor
wmiyr0=strcompress(min(syear),/remove_all)
wmiyr1=strcompress(max(syear),/remove_all)
wa3_nh_minor=fltarr(12)
wa3_nh_major=fltarr(12)
wa3_sh_minor=fltarr(12)
wa3_sh_major=fltarr(12)
for imon=1L,12L do begin
    index=where(wa3_smon eq imon,totdays)
    index=where(wa3_smon eq imon and nhdtlev gt 0.,npts)
    if imon lt 5L or imon gt 9L then wa3_nh_minor(imon-1L)=float(npts)
    index=where(wa3_smon eq imon and shdtlev gt 0.,npts)
    if imon ge 4L and imon le 8L then wa3_sh_minor(imon-1L)=float(npts)
endfor
oplot,1.+findgen(12),wa3_nh_minor,psym=0,color=mcolor*.95,thick=10
oplot,1.+findgen(12),wa3_sh_minor,psym=0,color=mcolor*.95,thick=10,linestyle=2
;
; gco
;
gnhdtlev=reform(gnhdt(*,ith))
gshdtlev=reform(gshdt(*,ith))
gnhu60lev=reform(gnhu60(*,ith))
gshu60lev=reform(gshu60(*,ith))
gsyear=strarr(gkday)
gwa3_smon=lonarr(gkday)
gjday=lonarr(gkday)
for i=0L,gkday-1L do begin
    gsyear(i)=strmid(strcompress(gyyyymmdd(i),/remove_all),0,4)
    imn=long(strmid(strcompress(gyyyymmdd(i),/remove_all),4,2))
    gwa3_smon(i)=imn
    idy=long(strmid(strcompress(gyyyymmdd(i),/remove_all),6,2))
    iyr=long(strmid(strcompress(gyyyymmdd(i),/remove_all),0,4))
    z = kgmt(imn,idy,iyr,iday)
    gjday(i)=iday
endfor
gwmiyr0=strcompress(min(gsyear),/remove_all)
gwmiyr1=strcompress(max(gsyear),/remove_all)
gwa3_nh_minor=fltarr(12)
gwa3_nh_major=fltarr(12)
gwa3_sh_minor=fltarr(12)
gwa3_sh_major=fltarr(12)
for imon=1L,12L do begin
    index=where(gwa3_smon eq imon,gtotdays)
    index=where(gwa3_smon eq imon and gnhdtlev gt 0.,npts)
    if imon lt 5L or imon gt 9L then gwa3_nh_minor(imon-1L)=float(npts)
    index=where(gwa3_smon eq imon and gshdtlev gt 0.,npts)
    if imon ge 4L and imon le 8L then gwa3_sh_minor(imon-1L)=float(npts)
endfor
oplot,1.+findgen(12),gwa3_nh_minor,psym=0,color=mcolor*.8,thick=10
oplot,1.+findgen(12),gwa3_sh_minor,psym=0,color=mcolor*.8,thick=10,linestyle=2
;
; mee00
;
m0nhdtlev=reform(m0nhdt(*,ith))
m0shdtlev=reform(m0shdt(*,ith))
m0nhu60lev=reform(m0nhu60(*,ith))
m0shu60lev=reform(m0shu60(*,ith))
m0syear=strarr(m0kday)
m0wa3_smon=lonarr(m0kday)
m0jday=lonarr(m0kday)
for i=0L,m0kday-1L do begin
    m0syear(i)=strmid(strcompress(m0yyyymmdd(i),/remove_all),0,4)
    imn=long(strmid(strcompress(m0yyyymmdd(i),/remove_all),4,2))
    m0wa3_smon(i)=imn
    idy=long(strmid(strcompress(m0yyyymmdd(i),/remove_all),6,2))
    iyr=long(strmid(strcompress(m0yyyymmdd(i),/remove_all),0,4))
    z = kgmt(imn,idy,iyr,iday)
    m0jday(i)=iday
endfor
m0wmiyr0=strcompress(min(m0syear),/remove_all)
m0wmiyr1=strcompress(max(m0syear),/remove_all)
m0wa3_nh_minor=fltarr(12)
m0wa3_nh_major=fltarr(12)
m0wa3_sh_minor=fltarr(12)
m0wa3_sh_major=fltarr(12)
for imon=1L,12L do begin
    index=where(m0wa3_smon eq imon,m0totdays)
    index=where(m0wa3_smon eq imon and m0nhdtlev gt 0.,npts)
    if imon lt 5L or imon gt 9L then m0wa3_nh_minor(imon-1L)=float(npts)
    index=where(m0wa3_smon eq imon and m0shdtlev gt 0.,npts)
    if imon ge 4L and imon le 8L then m0wa3_sh_minor(imon-1L)=float(npts)
endfor
oplot,1.+findgen(12),m0wa3_nh_minor,psym=0,color=mcolor*.3,thick=10
oplot,1.+findgen(12),m0wa3_sh_minor,psym=0,color=mcolor*.3,thick=10,linestyle=2
;
; mee01
;
m1nhdtlev=reform(m1nhdt(*,ith))
m1shdtlev=reform(m1shdt(*,ith))
m1nhu60lev=reform(m1nhu60(*,ith))
m1shu60lev=reform(m1shu60(*,ith))
m1syear=strarr(m1kday)
m1wa3_smon=lonarr(m1kday)
m1jday=lonarr(m1kday)
for i=0L,m1kday-1L do begin
    m1syear(i)=strmid(strcompress(m1yyyymmdd(i),/remove_all),0,4)
    imn=long(strmid(strcompress(m1yyyymmdd(i),/remove_all),4,2))
    m1wa3_smon(i)=imn
    idy=long(strmid(strcompress(m1yyyymmdd(i),/remove_all),6,2))
    iyr=long(strmid(strcompress(m1yyyymmdd(i),/remove_all),0,4))
    z = kgmt(imn,idy,iyr,iday)
    m1jday(i)=iday
endfor
m1wmiyr0=strcompress(min(m1syear),/remove_all)
m1wmiyr1=strcompress(max(m1syear),/remove_all)
m1wa3_nh_minor=fltarr(12)
m1wa3_nh_major=fltarr(12)
m1wa3_sh_minor=fltarr(12)
m1wa3_sh_major=fltarr(12)
for imon=1L,12L do begin
    index=where(m1wa3_smon eq imon,m1totdays)
    index=where(m1wa3_smon eq imon and m1nhdtlev gt 0.,npts)
    if imon lt 5L or imon gt 9L then m1wa3_nh_minor(imon-1L)=float(npts)
    index=where(m1wa3_smon eq imon and m1shdtlev gt 0.,npts)
    if imon ge 4L and imon le 8L then m1wa3_sh_minor(imon-1L)=float(npts)
endfor
oplot,1.+findgen(12),m1wa3_nh_minor,psym=0,color=mcolor*.5,thick=10
oplot,1.+findgen(12),m1wa3_sh_minor,psym=0,color=mcolor*.5,thick=10,linestyle=2
xyouts,xmn+0.02,ymx-0.04,sth+' hPa',/normal,color=0
xyouts,xmx-0.2,ymx-0.04,'NH (solid)',/normal,color=0
xyouts,xmx-0.2,ymx-0.07,'SH (dashed)',/normal,color=0

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,1.+findgen(12),findgen(10),/nodata,xrange=[1,12],ytitle='Number of Days',yrange=[0.,50.],$
     title='Major Warmings',xticks=11,xtickname=smon,color=0
for imon=1L,12L do begin
    index=where(meto_smon eq imon,totdays)
    index=where(meto_smon eq imon and meto_nhdtlev gt 0. and meto_nhu60lev lt 0.,npts)
    if imon lt 4L or imon gt 9L then meto_nh_major(imon-1L)=float(npts)
    index=where(meto_smon eq imon and meto_shdtlev gt 0. and meto_shu60lev lt 0.,npts)
    if imon ge 4L and imon le 8L then meto_sh_major(imon-1L)=float(npts)
endfor
oplot,1.+findgen(12),meto_nh_major,psym=0,color=0,thick=10
oplot,1.+findgen(12),meto_sh_major,psym=0,color=0,thick=10,linestyle=2
for imon=1L,12L do begin
    index=where(wa3_smon eq imon,totdays)
    index=where(wa3_smon eq imon and nhdtlev gt 0. and nhu60lev lt 0.,npts)
    if imon lt 4L or imon gt 9L then wa3_nh_major(imon-1L)=float(npts)
    index=where(wa3_smon eq imon and shdtlev gt 0. and shu60lev lt 0.,npts)
    if imon ge 4L and imon le 8L then wa3_sh_major(imon-1L)=float(npts)
endfor
oplot,1.+findgen(12),wa3_nh_major,psym=0,color=mcolor*.95,thick=10
oplot,1.+findgen(12),wa3_sh_major,psym=0,color=mcolor*.95,thick=10,linestyle=2
;
; gco
;
for imon=1L,12L do begin
    index=where(gwa3_smon eq imon,totdays)
    index=where(gwa3_smon eq imon and gnhdtlev gt 0. and gnhu60lev lt 0.,npts)
    if imon lt 4L or imon gt 9L then gwa3_nh_major(imon-1L)=float(npts)
    index=where(gwa3_smon eq imon and gshdtlev gt 0. and gshu60lev lt 0.,npts)
    if imon ge 4L and imon le 8L then gwa3_sh_major(imon-1L)=float(npts)
endfor
oplot,1.+findgen(12),gwa3_nh_major,psym=0,color=mcolor*.8,thick=10
oplot,1.+findgen(12),gwa3_sh_major,psym=0,color=mcolor*.8,thick=10,linestyle=2
;
; mee00
;
for imon=1L,12L do begin
    index=where(m0wa3_smon eq imon,totdays)
    index=where(m0wa3_smon eq imon and m0nhdtlev gt 0. and m0nhu60lev lt 0.,npts)
    if imon lt 4L or imon gt 9L then m0wa3_nh_major(imon-1L)=float(npts)
    index=where(m0wa3_smon eq imon and m0shdtlev gt 0. and m0shu60lev lt 0.,npts)
    if imon ge 4L and imon le 8L then m0wa3_sh_major(imon-1L)=float(npts)
endfor
oplot,1.+findgen(12),m0wa3_nh_major,psym=0,color=mcolor*.3,thick=10
oplot,1.+findgen(12),m0wa3_sh_major,psym=0,color=mcolor*.3,thick=10,linestyle=2
;
; mee01
;
for imon=1L,12L do begin
    index=where(m1wa3_smon eq imon,totdays)
    index=where(m1wa3_smon eq imon and m1nhdtlev gt 0. and m1nhu60lev lt 0.,npts)
    if imon lt 4L or imon gt 9L then m1wa3_nh_major(imon-1L)=float(npts)
    index=where(m1wa3_smon eq imon and m1shdtlev gt 0. and m1shu60lev lt 0.,npts)
    if imon ge 4L and imon le 8L then m1wa3_sh_major(imon-1L)=float(npts)
endfor
oplot,1.+findgen(12),m1wa3_nh_major,psym=0,color=mcolor*.5,thick=10
oplot,1.+findgen(12),m1wa3_sh_major,psym=0,color=mcolor*.5,thick=10,linestyle=2

xyouts,6,40.,'WACCM noaurfco '+wmiyr0+'-'+wmiyr1,/data,color=mcolor*.95
xyouts,6,35.,'WACCM noaurgco '+gwmiyr0+'-'+gwmiyr1,/data,color=mcolor*.8
xyouts,6,30.,'WACCM mee00fco '+m0wmiyr0+'-'+m0wmiyr1,/data,color=mcolor*.3
xyouts,6,25.,'WACCM mee01fco '+m1wmiyr0+'-'+m1wmiyr1,/data,color=mcolor*.5
xyouts,6,20.,'MetO '+miyr0+'-'+miyr1,/data,color=0

if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim waccm_mills+meto_ssw_totcount_'+sth+'hPa.ps -rotate -90'+$
         ' waccm_mills+meto_ssw_totcount_'+sth+'hPa.jpg'
endif
end
