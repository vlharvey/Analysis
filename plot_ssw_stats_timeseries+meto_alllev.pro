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
smon=['J','A','S','O','N','D','J','F','M','A','M','J']
!noeras=1
nxdim=800
nydim=800
xorig=[0.1,0.55,0.1,0.55]
yorig=[0.55,0.55,0.12,0.12]
xlen=0.4
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
print,lev
rth=10.707050
;read,'Enter desired pressure surface ',rth
for kk=27L,n_elements(lev)-1L do begin
rth=lev(kk)
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
   device,/landscape,bits=8,filename='wa3+meto_ssw_'+sth+'hPa.ps'
   device,/color
   device,/bold
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
;
; choose Met Office level
;
print,'WACCM ',rth
print,th
rth=1000.0
read,'Enter closest theta surface to '+sth+' hPa ',rth
index=where(th eq rth)
mth=index(0)
meto_nhdtlev=reform(meto_nhdt(*,mth))
meto_nhu60lev=reform(meto_nhu60(*,mth))
meto_shdtlev=reform(meto_shdt(*,mth))
meto_shu60lev=reform(meto_shu60(*,mth))
meto_syear=strarr(kmday)
meto_jday=lonarr(kmday)
for i=0L,kmday-1L do begin
    meto_syear(i)=strmid(strcompress(meto_yyyymmdd(i),/remove_all),0,4)
    imn=long(strmid(strcompress(meto_yyyymmdd(i),/remove_all),4,2))
    idy=long(strmid(strcompress(meto_yyyymmdd(i),/remove_all),6,2))
    iyr=long(strmid(strcompress(meto_yyyymmdd(i),/remove_all),0,4))
    z = kgmt(imn,idy,iyr,iday)
    meto_jday(i)=iday
endfor
miyr0=long(meto_syear(0))
miyr1=long(meto_syear(kmday-1))
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,1.+findgen(366),findgen(10),/nodata,xrange=[1,366],yrange=[-40.,40],title='NH T85-T60',xtitle='Day of Year',charsize=1.5
xyouts,10.,35.,'WACCM3',/data,color=mcolor*.9
plots,1,0
plots,366,0,/continue
tmp2d=fltarr(366,15)
loadct,0
for iyear=miyr0,miyr1 do begin
    index=where(long(meto_syear) eq iyear,npts)
;    tmp2d(0:n_elements(index)-1L,iyear-miyr0)=meto_nhdtlev(index)
;endfor
;for iday=0,365 do begin
;    imin=min(tmp2d(iday,*))
;    imax=max(tmp2d(iday,*))
;    plots,iday,imin
;    plots,iday,imax,/continue
    oplot,meto_jday(index),meto_nhdtlev(index),symsize=0.8,psym=8,color=mcolor*.6
endfor
xyouts,10.,30.,'MetO',/data,color=mcolor*.6
loadct,38

nhdtlev=reform(nhdt(*,ith))
shdtlev=reform(shdt(*,ith))
nhu60lev=reform(nhu60(*,ith))
shu60lev=reform(shu60(*,ith))
syear=strarr(kday)
jday=lonarr(kday)
for i=0L,kday-1L do begin
    syear(i)=strmid(strcompress(yyyymmdd(i),/remove_all),0,4)
    imn=long(strmid(strcompress(yyyymmdd(i),/remove_all),4,2))
    idy=long(strmid(strcompress(yyyymmdd(i),/remove_all),6,2))
    iyr=long(strmid(strcompress(yyyymmdd(i),/remove_all),0,4))
    z = kgmt(imn,idy,iyr,iday)
    jday(i)=iday
endfor
iyr0=long(syear(0))
iyr1=long(syear(kday-1))
for iyear=iyr0,iyr1 do begin
    index=where(long(syear) eq iyear,npts)
    oplot,jday(index),nhdtlev(index),psym=8,color=((1.*iyear-(1.*iyr0-0.1))/((1.*iyr1+0.1)-(1.*iyr0-0.1)))*mcolor
endfor

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,1.+findgen(366),findgen(10),/nodata,xrange=[1,366],yrange=[-40.,40],title='SH T85-T60',xtitle='Day of Year',charsize=1.5
xyouts,10.,35.,'WACCM3',/data,color=mcolor*.9
plots,1,0
plots,366,0,/continue
loadct,0
for iyear=miyr0,miyr1 do begin
    index=where(long(meto_syear) eq iyear,npts)
    oplot,meto_jday(index),meto_shdtlev(index),symsize=0.8,psym=8,color=mcolor*.6
endfor
xyouts,10.,30.,'MetO',/data,color=mcolor*.6
loadct,38
for iyear=iyr0,iyr1 do begin
    index=where(long(syear) eq iyear,npts)
    oplot,jday(index),shdtlev(index),psym=8,color=((1.*iyear-(1.*iyr0-0.1))/((1.*iyr1+0.1)-(1.*iyr0-0.1)))*mcolor
endfor

!type=2^2+2^3
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,1.+findgen(366),findgen(10),/nodata,xrange=[1,366],yrange=[-50.,110],title='Zonal Mean Wind at 65N',xtitle='Day of Year',charsize=1.5
xyouts,10.,100.,'WACCM3',/data,color=mcolor*.9
plots,1,0
plots,366,0,/continue
loadct,0
for iyear=miyr0,miyr1 do begin
    index=where(long(meto_syear) eq iyear,npts)
    oplot,meto_jday(index),meto_nhu60lev(index),symsize=0.8,psym=8,color=mcolor*.6
endfor
xyouts,10.,90.,'MetO',/data,color=mcolor*.6
loadct,38
for iyear=iyr0,iyr1 do begin
    index=where(long(syear) eq iyear,npts)
    oplot,jday(index),nhu60lev(index),psym=8,color=((1.*iyear-(1.*iyr0-0.1))/((1.*iyr1+0.1)-(1.*iyr0-0.1)))*mcolor
endfor

!type=2^2+2^3
xmn=xorig(3)
xmx=xorig(3)+xlen
ymn=yorig(3)
ymx=yorig(3)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,1.+findgen(366),findgen(10),/nodata,xrange=[1,366],yrange=[-50.,110],title='Zonal Mean Zonal Wind at 65S',xtitle='Day of Year',charsize=1.5
xyouts,10.,100.,'WACCM3',/data,color=mcolor*.9
plots,1,0
plots,366,0,/continue
loadct,0
for iyear=miyr0,miyr1 do begin
    index=where(long(meto_syear) eq iyear,npts)
    oplot,meto_jday(index),meto_shu60lev(index),symsize=0.8,psym=8,color=mcolor*.6
endfor
xyouts,10.,90.,'MetO',/data,color=mcolor*.6
loadct,38
nyr=iyr1-iyr0+1L
dx=.9/float(nyr)
xx=0.075
for iyear=iyr0,iyr1 do begin
    index=where(long(syear) eq iyear,npts)
    oplot,jday(index),shu60lev(index),psym=8,color=((1.*iyear-(1.*iyr0-0.1))/((1.*iyr1+0.1)-(1.*iyr0-0.1)))*mcolor
    xyouts,xx,0.47,strcompress(iyear),color=((1.*iyear-(1.*iyr0-0.1))/((1.*iyr1+0.1)-(1.*iyr0-0.1)))*mcolor,charsize=1.5,/normal
    xx=xx+dx
endfor
xyouts,.45,.86,sth+' hPa',/normal,charsize=1.5

if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim wa3+meto_ssw_'+sth+'hPa.ps -rotate -90 wa3+meto_ssw_'+sth+'hPa.jpg'
endif
endfor
end
