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
if setplot ne 'ps' then $
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
erase
restore,'wa3_wmo_ssw_diagnostics.sav
kday=n_elements(yyyymmdd)
print,lev
rth=10.
;read,'Enter desired theta surface ',rth
for kk=0L,n_elements(lev)-1L do begin
rth=lev(kk)
sth=strcompress(rth,/remove_all)
index=where(abs(lev-rth) eq min(abs(lev-rth)))
if index(0) eq -1L then stop,'Invalid theta level'
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='wa3_ssw_'+sth+'hPa.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
ith=index(0)
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
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,1.+findgen(365),findgen(10),/nodata,xrange=[1,365],yrange=[-40.,40],title='NH T85-T60',xtitle='Day of Year'
plots,1,0
plots,365,0,/continue
for iyear=iyr0,iyr1 do begin
    index=where(long(syear) eq iyear,npts)
    oplot,jday(index),nhdtlev(index),psym=8,symsize=0.5,color=((1.*iyear-(1.*iyr0-1.))/((1.*iyr1+1.)-(1.*iyr0-1.)))*mcolor
tmpyyyymmdd=yyyymmdd(index)
tmpdt=nhdtlev(index)
tmpu=nhu60lev(index)
tmpjday=jday(index)
minorindex=where((tmpjday lt 121 or tmpjday gt 274.) and tmpdt gt 0. and tmpu gt 0.)
majorindex=where((tmpjday lt 121 or tmpjday gt 274.) and tmpdt gt 0. and tmpu lt 0.)
if minorindex(0) ne -1L then begin
;  print,'MINOR ',tmpyyyymmdd(minorindex)
;  oplot,tmpjday(minorindex),tmpdt(minorindex),psym=8,symsize=0.5
endif
if majorindex(0) ne -1L then begin
;  print,'MAJOR ',tmpyyyymmdd(majorindex)
   oplot,tmpjday(majorindex),tmpdt(majorindex),symsize=0.8,psym=8,color=((1.*iyear-(1.*iyr0-1.))/((1.*iyr1+1.)-(1.*iyr0-1.)))*mcolor
endif
;if minorindex(0) ne -1L or majorindex(0) ne -1L then stop
endfor

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,1.+findgen(365),findgen(10),/nodata,xrange=[1,365],yrange=[-40.,40],title='SH T85-T60',xtitle='Day of Year'
plots,1,0
plots,365,0,/continue
for iyear=iyr0,iyr1 do begin
    index=where(long(syear) eq iyear,npts)
    oplot,jday(index),shdtlev(index),psym=8,symsize=0.5,color=((1.*iyear-(1.*iyr0-1.))/((1.*iyr1+1.)-(1.*iyr0-1.)))*mcolor
tmpyyyymmdd=yyyymmdd(index)
tmpdt=shdtlev(index)
tmpu=shu60lev(index)
tmpjday=jday(index)
minorindex=where(tmpjday gt 60 and tmpjday lt 300. and tmpdt gt 0. and tmpu gt 0.)
majorindex=where(tmpjday gt 60 and tmpjday lt 300. and tmpdt gt 0. and tmpu lt 0.)
if minorindex(0) ne -1L then begin
;  print,'MINOR ',tmpyyyymmdd(minorindex)
;  oplot,tmpjday(minorindex),tmpdt(minorindex),psym=8,symsize=0.5
endif
if majorindex(0) ne -1L then begin
;  print,'MAJOR ',tmpyyyymmdd(majorindex)
   oplot,tmpjday(majorindex),tmpdt(majorindex),symsize=0.8,psym=8,color=((1.*iyear-(1.*iyr0-1.))/((1.*iyr1+1.)-(1.*iyr0-1.)))*mcolor
endif
;if minorindex(0) ne -1L or majorindex(0) ne -1L then stop
endfor

!type=2^2+2^3
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,1.+findgen(365),findgen(10),/nodata,xrange=[1,365],yrange=[-50.,110],title='Zonal Mean Wind at 65N',xtitle='Day of Year'
plots,1,0
plots,365,0,/continue
for iyear=iyr0,iyr1 do begin
    index=where(long(syear) eq iyear,npts)
    oplot,jday(index),nhu60lev(index),psym=8,symsize=0.5,color=((1.*iyear-(1.*iyr0-1.))/((1.*iyr1+1.)-(1.*iyr0-1.)))*mcolor
tmpyyyymmdd=yyyymmdd(index)
tmpdt=nhdtlev(index)
tmpu=nhu60lev(index)
tmpjday=jday(index)
minorindex=where((tmpjday lt 121 or tmpjday gt 274.) and tmpdt gt 0. and tmpu gt 0.)
majorindex=where((tmpjday lt 121 or tmpjday gt 274.) and tmpdt gt 0. and tmpu lt 0.)
if minorindex(0) ne -1L then begin
;  oplot,tmpjday(minorindex),tmpu(minorindex),psym=8,symsize=0.5,color=mcolor
endif
if majorindex(0) ne -1L then begin
   oplot,tmpjday(majorindex),tmpu(majorindex),symsize=0.8,psym=8,color=((1.*iyear-(1.*iyr0-1.))/((1.*iyr1+1.)-(1.*iyr0-1.)))*mcolor
endif
endfor

!type=2^2+2^3
xmn=xorig(3)
xmx=xorig(3)+xlen
ymn=yorig(3)
ymx=yorig(3)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,1.+findgen(365),findgen(10),/nodata,xrange=[1,365],yrange=[-50.,110],title='Zonal Mean Zonal Wind at 65S',xtitle='Day of Year'
plots,1,0
plots,365,0,/continue
nyr=iyr1-iyr0+1L
dx=.9/float(nyr)
xx=0.075
for iyear=iyr0,iyr1 do begin
    index=where(long(syear) eq iyear,npts)
    oplot,jday(index),shu60lev(index),psym=8,symsize=0.5,color=((1.*iyear-(1.*iyr0-1.))/((1.*iyr1+1.)-(1.*iyr0-1.)))*mcolor
    xyouts,xx,0.475,strcompress(iyear),color=((1.*iyear-(1.*iyr0-1.))/((1.*iyr1+1.)-(1.*iyr0-1.)))*mcolor,charsize=1.5,/normal
    xx=xx+dx

tmpyyyymmdd=yyyymmdd(index)
tmpdt=shdtlev(index)
tmpu=shu60lev(index)
tmpjday=jday(index)
minorindex=where(tmpjday gt 60 and tmpjday lt 300. and tmpdt gt 0. and tmpu gt 0.)
majorindex=where(tmpjday gt 60 and tmpjday lt 300. and tmpdt gt 0. and tmpu lt 0.)
if minorindex(0) ne -1L then begin
;  print,'MINOR ',tmpyyyymmdd(minorindex)
;  oplot,tmpjday(minorindex),tmpu(minorindex),psym=8,symsize=0.5
endif
if majorindex(0) ne -1L then begin
;  print,'MAJOR ',tmpyyyymmdd(majorindex)
   oplot,tmpjday(majorindex),tmpu(majorindex),symsize=0.8,psym=8,color=((1.*iyear-(1.*iyr0-1.))/((1.*iyr1+1.)-(1.*iyr0-1.)))*mcolor
endif
;if minorindex(0) ne -1L or majorindex(0) ne -1L then stop

endfor
xyouts,.2,.92,sth+' hPa WACCM3 SSW Diagnostics',/normal,charsize=2

if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim wa3_ssw_'+sth+'hPa.ps -rotate -90 wa3_ssw_'+sth+'hPa.jpg'
endif
stop
endfor
end

