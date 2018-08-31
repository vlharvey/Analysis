@stddat
@kgmt
@ckday
@kdate

loadct,38
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
lc=0L
if setplot ne 'ps' then begin
   lc=mcolor
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

;restore the following WACCM3 arrays
; LEV             DOUBLE    = Array[66]
; NHDT            FLOAT     = Array[1014, 66]
; NHU60           FLOAT     = Array[1014, 66]
; SHDT            FLOAT     = Array[1014, 66]
; SHU60           FLOAT     = Array[1014, 66]
; YYYYMMDD        LONG      = Array[1014]
;
restore,'wa3_wmo_ssw_diagnostics.sav
kday=n_elements(yyyymmdd)
;print,lev
rth=10.707050
for kk=50L,n_elements(lev)-1L do begin
rth=lev(kk)
;read,'Enter desired pressure surface ',rth
sth=strcompress(rth,/remove_all)
index=where(abs(lev-rth) eq min(abs(lev-rth)))
if index(0) eq -1L then stop,'Invalid pressure level'
ith=index(0)
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='wa3+meto_ssw_freq_'+sth+'hPa.ps'
   device,/color
   device,/bold
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
;
; choose Met Office level
;
;print,th
;rth=1000.0
read,'Enter closest theta surface to '+sth+' hPa ',rth
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
miyr0=long(meto_syear(0))
miyr1=long(meto_syear(kmday-1))
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,1.+findgen(12),findgen(10),/nodata,xrange=[1,12],yrange=[0.,100],title='Percent of Days with Minor Warmings',$
     xticks=11,xtickname=smon,charsize=2,color=0
xyouts,1.5,90.,'WACCM3',/data,color=mcolor*.9,charsize=1.5
meto_nh_minor=fltarr(12)
meto_nh_major=fltarr(12)
meto_sh_minor=fltarr(12)
meto_sh_major=fltarr(12)
for imon=1L,12L do begin
    index=where(meto_smon eq imon,totdays)
    index=where(meto_smon eq imon and meto_nhdtlev gt 0.,npts)
    if imon lt 5L or imon gt 9L then meto_nh_minor(imon-1L)=100.*float(npts)/float(totdays)
    index=where(meto_smon eq imon and meto_shdtlev gt 0.,npts)
    if imon ge 4L and imon le 8L then meto_sh_minor(imon-1L)=100.*float(npts)/float(totdays)
endfor
oplot,1.+findgen(12),meto_nh_minor,psym=0,color=0,thick=5
oplot,1.+findgen(12),meto_sh_minor,psym=0,color=0,thick=5,linestyle=2
xyouts,1.5,80.,'MetO',/data,color=0,charsize=1.5

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
wa3_nh_minor=fltarr(12)
wa3_nh_major=fltarr(12)
wa3_sh_minor=fltarr(12)
wa3_sh_major=fltarr(12)
for imon=1L,12L do begin
    index=where(wa3_smon eq imon,totdays)
    index=where(wa3_smon eq imon and nhdtlev gt 0.,npts)
    if imon lt 5L or imon gt 9L then wa3_nh_minor(imon-1L)=100.*float(npts)/float(totdays)
    index=where(wa3_smon eq imon and shdtlev gt 0.,npts)
    if imon ge 4L and imon le 8L then wa3_sh_minor(imon-1L)=100.*float(npts)/float(totdays)
endfor
oplot,1.+findgen(12),wa3_nh_minor,psym=0,color=mcolor*.9,thick=5
oplot,1.+findgen(12),wa3_sh_minor,psym=0,color=mcolor*.9,thick=5,linestyle=2

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,1.+findgen(12),findgen(10),/nodata,xrange=[1,12],yrange=[0.,20],title='Percent of Days with Major Warmings',$
     xticks=11,xtickname=smon,charsize=2,color=0
xyouts,1.5,90.,'WACCM3',/data,color=mcolor*.9,charsize=1.5
for imon=1L,12L do begin
    index=where(meto_smon eq imon,totdays)
    index=where(meto_smon eq imon and meto_nhdtlev gt 0. and meto_nhu60lev lt 0.,npts)
    if imon lt 4L or imon gt 9L then meto_nh_major(imon-1L)=100.*float(npts)/float(totdays)
    index=where(meto_smon eq imon and meto_shdtlev gt 0. and meto_shu60lev lt 0.,npts)
    if imon ge 4L and imon le 8L then meto_sh_major(imon-1L)=100.*float(npts)/float(totdays)
endfor
oplot,1.+findgen(12),meto_nh_major,psym=0,color=0,thick=5
oplot,1.+findgen(12),meto_sh_major,psym=0,color=0,thick=5,linestyle=2
xyouts,1.5,80.,'MetO',/data,color=0,charsize=1.5
for imon=1L,12L do begin
    index=where(wa3_smon eq imon,totdays)
    index=where(wa3_smon eq imon and nhdtlev gt 0. and nhu60lev lt 0.,npts)
    if imon lt 4L or imon gt 9L then wa3_nh_major(imon-1L)=100.*float(npts)/float(totdays)
    index=where(wa3_smon eq imon and shdtlev gt 0. and shu60lev lt 0.,npts)
    if imon ge 4L and imon le 8L then wa3_sh_major(imon-1L)=100.*float(npts)/float(totdays)
endfor
oplot,1.+findgen(12),wa3_nh_major,psym=0,color=mcolor*.9,thick=5
oplot,1.+findgen(12),wa3_sh_major,psym=0,color=mcolor*.9,thick=5,linestyle=2

;xyouts,.15,.85,sth+' hPa',/normal,charsize=2

if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim wa3+meto_ssw_freq_'+sth+'hPa.ps -rotate -90 wa3+meto_ssw_freq_'+sth+'hPa.jpg'
endif
endfor	; loop over WACCM pressure levels
end
