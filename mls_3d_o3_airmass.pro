;
; calculate monthly means from all Januaries, Februaries, etc
; requires retention of all data and calculations at the end
; includes "out" catagory modification
;
setplot='x'
read,'setplot?',setplot
loadct,38
device,decompose=0
mcolor=byte(!p.color)
mcolor=fix(mcolor)
if mcolor eq 0 then mcolor=255
nlvls=20
col1=1+mcolor*findgen(20)/nlvls
icmm1=mcolor-1
icmm2=mcolor-2
!noeras=1
a=findgen(6)*(2*!pi/6.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
xorig=[0.15,0.15]
yorig=[0.60,0.15]
xlen=0.7
ylen=0.3
cbaryoff=0.02
cbarydel=0.02
if setplot ne 'ps' then begin
   lc=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/aura6/data/MLS_data/Datfiles/mls_'
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
mday=[31,28,31,30,31,30,31,31,30,31,30,31]
nlat=18
ybin=-85.+10.*findgen(nlat)
ifile='               '
close,1
openr,1,'mls_3d_o3_airmass.fil'
nmonth=0L
readf,1,nmonth
for imonth=0,nmonth-1 do begin
kday=5.e4
nday=0L
readf,1,nday
istart=0L
for iday=0,nday-1 do begin
    readf,1,ifile
    index=where(mon eq strmid(ifile,0,4))
    kmonth=index(0)
    dum=findfile(diru+ifile+'.nc3')
    if dum(0) eq '' then begin
       print,'missing ukmo data on ',ifile
       goto,missingday
    endif
    ncid=ncdf_open(diru+ifile+'.nc3')
    print,'opening '+diru+ifile+'.nc3'
    if istart eq 0L then begin
       nr=0L
       nc=0L
       nth=0L
       ncdf_diminq,ncid,0,name,nr
       ncdf_diminq,ncid,1,name,nc
       ncdf_diminq,ncid,2,name,nth
       alon=fltarr(nc)
       alat=fltarr(nr)
       th=fltarr(nth)
       mark2=fltarr(nr,nc,nth)
       ncdf_varget,ncid,0,alon
       ncdf_varget,ncid,1,alat
       ncdf_varget,ncid,2,th
;
; all measurements in one month
;
       out_o3=-9999+fltarr(kday,nlat,nth)
       vortex_o3=-9999+fltarr(kday,nlat,nth)
       high_o3=-9999+fltarr(kday,nlat,nth)
       out_o3_num=lonarr(nlat,nth)
       vortex_o3_num=lonarr(nlat,nth)
       high_o3_num=lonarr(nlat,nth)

       if imonth eq 0L then begin
;         out_o3_month=-9999+fltarr(kday,12,nlat,nth)
;         vortex_o3_month=-9999+fltarr(kday,12,nlat,nth)
;         high_o3_month=-9999+fltarr(kday,12,nlat,nth)
          out_o3_month_num=lonarr(12,nlat,nth)
          vortex_o3_month_num=lonarr(12,nlat,nth)
          high_o3_month_num=lonarr(12,nlat,nth)
          out_o3_month_avg=-9999+fltarr(12,nlat,nth)
          vortex_o3_month_avg=-9999+fltarr(12,nlat,nth)
          high_o3_month_avg=-9999+fltarr(12,nlat,nth)
          out_o3_month_sig=-9999+fltarr(12,nlat,nth)
          vortex_o3_month_sig=-9999+fltarr(12,nlat,nth)
          high_o3_month_sig=-9999+fltarr(12,nlat,nth)

          out_o3_num_save=lonarr(nmonth,nlat,nth)
          out_o3_avg_save=fltarr(nmonth,nlat,nth)
          out_o3_sig_save=fltarr(nmonth,nlat,nth)
          vortex_o3_num_save=lonarr(nmonth,nlat,nth)
          vortex_o3_avg_save=fltarr(nmonth,nlat,nth)
          vortex_o3_sig_save=fltarr(nmonth,nlat,nth)
          high_o3_num_save=lonarr(nmonth,nlat,nth)
          high_o3_avg_save=fltarr(nmonth,nlat,nth)
          high_o3_sig_save=fltarr(nmonth,nlat,nth)
       endif
       istart=1L
       dy=alat(1)-alat(0)
       dx=alon(1)-alon(0)
    endif
;
; read marker field and normalize
;
    mark2=fltarr(nr,nc,nth)
    ncdf_varget,ncid,10,mark2
    ncdf_close,ncid
    index=where(mark2 ne 0.)
    if index(0) ne -1 then mark2(index)=mark2(index)/abs(mark2(index))
;
; restore IDL save file variables mtime,mlon,mlat,mo3,mo3err,o3press,mtp,tppress
;
    if fix(strmid(ifile,7,2)) gt 90 then $
       yy='19'+string(FORMAT='(I2.2)',fix(strmid(ifile,7,2)))
    if fix(strmid(ifile,7,2)) lt 90 then $
       yy='20'+string(FORMAT='(I2.2)',fix(strmid(ifile,7,2)))
    dum=findfile(dir+strmid(ifile,0,7)+yy+'.sav')
    if dum(0) eq '' then begin
       print,'missing mls data on ',ifile
       goto,missingday
    endif
    restore,dir+strmid(ifile,0,7)+yy+'.sav'
    print,'restored '+dir+strmid(ifile,0,7)+yy+'.sav'
    tppress=tppress(2:38)
    MTP=MTP(2:38,*)
    mth=0.*mtp
    for k=0L,n_elements(O3PRESS)-1L do mth(k,*)=MTP(k,*)*(1000./o3press(k))^0.286
;
; interpolate MLS ozone to MetO theta surfaces
;
    nmls=n_elements(mlat)
    o3mls=fltarr(nmls,nth)
    eo3mls=fltarr(nmls,nth)
    ymls=fltarr(nmls,nth)
    xmls=fltarr(nmls,nth)
    thmls=fltarr(nmls,nth)
    for i=0L,nmls-1L do begin
        thmls(i,*)=th
        for k=0L,nth-1L do begin
            if i eq 0L then ymls(*,k)=mlat
            if i eq 0L then xmls(*,k)=mlon
            if th(k) lt min(mth(*,i)) then goto,skiplev
               for kk=0L,n_elements(o3press)-2L do begin
                   if mth(kk,i) le th(k) and mth(kk+1L,i) ge th(k) and $
                      mo3(kk,i) gt 0. and mo3(kk+1L,i) gt 0. then begin
                      zscale=(mth(kk+1L,i)-th(k))/(mth(kk+1L,i)-mth(kk,i))
                      o3mls(i,k)=mo3(kk+1L,i)+zscale*(mo3(kk,i)-mo3(kk+1L,i))
                      eo3mls(i,k)=mo3err(kk+1L,i)+zscale*(mo3err(kk,i)-mo3err(kk+1L,i))
                   endif
               endfor
            skiplev:
        endfor
    endfor
;
; initialize counter to 0.  if there is data it these will change
;
    nmls=0L
    mindex=where(th lt 0.)
;
; loop over MetO potential temperature surfaces
;
    for ith=0,nth-1 do begin
        mark1=transpose(mark2(*,*,ith))
        for ilat=0,nlat-1 do begin
;
; extract th(ith) surface from MLS data
;
        mindex=where(abs(ymls-ybin(ilat)) le 5. and thmls eq th(ith),nmls)
        if mindex(0) eq -1L then goto,jumplat
;
; arrays to hold MLS data on this level
; 
        lon=fltarr(nmls)
        lat=fltarr(nmls)
        o3=fltarr(nmls)
        eo3=fltarr(nmls)
        airtype=9999.+fltarr(nmls)
        if mindex(0) ne -1 then begin
           lon=xmls(mindex)
           lat=ymls(mindex)
           o3=o3mls(mindex)
           eo3=eo3mls(mindex)
        endif
;
; eliminate bad data
;
        index=where(eo3/o3 le 0.5,nmls)
        if index(0) ne -1 then begin
           lon=lon(index)
           lat=lat(index)
           o3=o3(index)
           eo3=eo3(index)
           airtype=airtype(index)
        endif
;
; initialize airtype array
;
        for i=0,nmls-1 do begin
            xs=lon(i)
            if xs lt 0. then xs=xs+360.
            ys=lat(i)
            yindex=where(abs(alat-ys) le dy)
            ym1=yindex(0)
            yp1=yindex(1)
            if xs ge alon(0) and xs le alon(nc-1) then begin
               xindex=where(abs(alon-xs) le dx)
               xm1=xindex(0)
               xp1=xindex(1)
            endif
            if xs lt alon(0) or xs gt alon(nc-1) then begin
               xm1=nc-1
               xp1=0
            endif
            CASE 1 OF
                 mark1(xm1,ym1)+mark1(xm1,yp1)+$
                 mark1(xp1,ym1)+mark1(xp1,yp1)+$	; not in a vortex
                 mark1(xm1,ym1)+mark1(xm1,yp1)+$
                 mark1(xp1,ym1)+mark1(xp1,yp1) eq 0.0 : airtype(i)=0.

                 mark1(xm1,ym1)+mark1(xm1,yp1)+$	; in polar vortex
                 mark1(xp1,ym1)+mark1(xp1,yp1) gt 0.0 : airtype(i)=1.

                 mark1(xm1,ym1)+mark1(xm1,yp1)+$	; in anticyclone
                 mark1(xp1,ym1)+mark1(xp1,yp1) lt 0.0 : airtype(i)=-1.
            ENDCASE
        endfor	; loop over orbits
;
; polar vortex
;
        index=where(airtype eq 1.)
        if index(0) ne -1 then begin
           for ii=0,n_elements(index)-1 do begin
               num=vortex_o3_num(ilat,ith)
               vortex_o3(num,ilat,ith)=o3(index(ii))
               vortex_o3_num(ilat,ith)=vortex_o3_num(ilat,ith)+1L
           endfor
        endif
;
; anticyclones
;
        index=where(airtype eq -1.)
        if index(0) ne -1 then begin
           for ii=0,n_elements(index)-1 do begin                        ; loop over data in anticyclones
               num=high_o3_num(ilat,ith)
               high_o3(num,ilat,ith)=o3(index(ii))
               high_o3_num(ilat,ith)=high_o3_num(ilat,ith)+1L
           endfor
        endif
;
; ambient
;
        index=where(airtype eq 0.)
        if index(0) ne -1 then begin
           for ii=0,n_elements(index)-1 do begin
               num=out_o3_num(ilat,ith)
               out_o3(num,ilat,ith)=o3(index(ii))
               out_o3_num(ilat,ith)=out_o3_num(ilat,ith)+1L
           endfor
        endif

;print,th(ith),out_o3_num(ilat,ith),vortex_o3_num(ilat,ith),high_o3_num(ilat,ith)
        jumplat:
        endfor		; loop over latitude bins
    endfor		; loop over theta
print,ifile,max(out_o3_num),max(vortex_o3_num),max(high_o3_num)
    missingday:
endfor			; loop over days
;
; calculate profile of monthly means and standard deviations in each airmass
;
out_o3_avg=fltarr(nlat,nth)
out_o3_sig=fltarr(nlat,nth)
vortex_o3_avg=fltarr(nlat,nth)
vortex_o3_sig=fltarr(nlat,nth)
high_o3_avg=fltarr(nlat,nth)
high_o3_sig=fltarr(nlat,nth)
for k=0,nth-1 do begin
for j=0,nlat-1 do begin
    num=out_o3_num(j,k)
    if num ge 1L then begin
       num2=out_o3_month_num(kmonth,j,k)
;      out_o3_month(num2:num2+num-1L,kmonth,j,k)=out_o3(0:num-1,j,k)
       out_o3_month_num(kmonth,j,k)=out_o3_month_num(kmonth,j,k)+num
    endif
    if num ge 3L then begin
       out_o3_avg(j,k)=total(out_o3(0:num-1,j,k))/float(num)
       result=moment(out_o3(0:num-1,j,k))
       out_o3_sig(j,k)=sqrt(result(1))
    endif

    num=vortex_o3_num(j,k)
    if num ge 1L then begin
       num2=vortex_o3_month_num(kmonth,j,k)
;      vortex_o3_month(num2:num2+num-1L,kmonth,j,k)=vortex_o3(0:num-1,j,k)
       vortex_o3_month_num(kmonth,j,k)=vortex_o3_month_num(kmonth,j,k)+num
    endif
    if num ge 3L then begin
       vortex_o3_avg(j,k)=total(vortex_o3(0:num-1,j,k))/float(num)
       result=moment(vortex_o3(0:num-1,j,k))
       vortex_o3_sig(j,k)=sqrt(result(1))
    endif

    num=high_o3_num(j,k)
    if num ge 1L then begin
       num2=high_o3_month_num(kmonth,j,k)
;      high_o3_month(num2:num2+num-1L,kmonth,j,k)=high_o3(0:num-1,j,k)
       high_o3_month_num(kmonth,j,k)=high_o3_month_num(kmonth,j,k)+num
    endif
    if num ge 3L then begin
       high_o3_avg(j,k)=total(high_o3(0:num-1,j,k))/float(num)
       result=moment(high_o3(0:num-1,j,k))
       high_o3_sig(j,k)=sqrt(result(1))
    endif
endfor
endfor
print,ifile,max(out_o3_month_num),max(vortex_o3_month_num),max(high_o3_month_num)
print,' '

if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/portrait,bits=8,filename='mls_3d_o3_airmass_'+ifile+'.ps'
   device,/color
   device,/inch,xoff=0.05,yoff=.1,xsize=xsize,ysize=ysize
endif
erase
!type=2^2+2^3
set_viewport,.3,.8,.75,.95
level=0.5*findgen(nlvls)
index=where(out_o3_avg eq 0.)
if index(0) ne -1L then out_o3_avg(index)=-9999.
contour,out_o3_avg,ybin,th,xrange=[-90.,90.],yrange=[240.,2000.],/noeras,/cell_fill,$
        c_color=col1,levels=level,min_value=-9999.,title='Ambient '+ifile
contour,out_o3_avg,ybin,th,/overplot,levels=level,/follow,color=0,min_value=-9999.

set_viewport,.2,.5,.45,.65
index=where(high_o3_avg eq 0.)
if index(0) ne -1L then high_o3_avg(index)=-9999.
contour,high_o3_avg,ybin,th,xrange=[-90.,90.],yrange=[240.,2000.],/noeras,/cell_fill,$
        c_color=col1,levels=level,min_value=-9999.,title='Anticyclone'
contour,high_o3_avg,ybin,th,/overplot,levels=level,/follow,color=0,min_value=-9999.

set_viewport,.2,.5,.15,.35
index=where(vortex_o3_avg eq 0.)
if index(0) ne -1L then vortex_o3_avg(index)=-9999.
contour,vortex_o3_avg,ybin,th,xrange=[-90.,90.],yrange=[240.,2000.],/noeras,/cell_fill,$
        c_color=col1,levels=level,min_value=-9999.,title='Vortex'
contour,vortex_o3_avg,ybin,th,/overplot,levels=level,/follow,color=0,min_value=-9999.

set_viewport,.6,.9,.45,.65
level=-2.+0.2*findgen(nlvls)
index=where(high_o3_avg gt 0. and out_o3_avg gt 0.)
dum=0.*out_o3_avg
if index(0) ne -1L then dum(index)=high_o3_avg(index)-out_o3_avg(index)
index=where(dum eq 0.)
dum(index)=-9999.
contour,dum,ybin,th,xrange=[-90.,90.],yrange=[240.,2000.],/noeras,/cell_fill,$
        c_color=col1,levels=level,min_value=-9999.,title='Anticyclone-Ambient'
index=where(level lt 0.)
contour,dum,ybin,th,/overplot,/noeras,color=0,levels=level(index),c_linestyle=1,min_value=-9999.
index=where(level gt 0.)
contour,dum,ybin,th,/overplot,/noeras,color=mcolor,levels=level(index),c_linestyle=0,min_value=-9999.
contour,dum,ybin,th,/overplot,/noeras,color=0,levels=0,thick=2,min_value=-9999.

set_viewport,.6,.9,.15,.35
index=where(vortex_o3_avg gt 0. and out_o3_avg gt 0.)
dum=0.*out_o3_avg
if index(0) ne -1L then dum(index)=vortex_o3_avg(index)-out_o3_avg(index)
index=where(dum eq 0.)
dum(index)=-9999.
contour,dum,ybin,th,xrange=[-90.,90.],yrange=[240.,2000.],/noeras,/cell_fill,$
        c_color=col1,levels=level,min_value=-9999.,title='Vortex-Ambient'
index=where(level lt 0.)
contour,dum,ybin,th,/overplot,/noeras,color=0,levels=level(index),c_linestyle=1,min_value=-9999.
index=where(level gt 0.)
contour,dum,ybin,th,/overplot,/noeras,color=mcolor,levels=level(index),c_linestyle=0,min_value=-9999.
contour,dum,ybin,th,/overplot,/noeras,color=0,levels=0,thick=2,min_value=-9999.
if setplot eq 'ps' then device,/close
;
; retain monthly profiles for total time period output at the end
;
out_o3_num_save(imonth,*,*)=out_o3_num
out_o3_avg_save(imonth,*,*)=out_o3_avg
out_o3_sig_save(imonth,*,*)=out_o3_sig
vortex_o3_num_save(imonth,*,*)=vortex_o3_num
vortex_o3_avg_save(imonth,*,*)=vortex_o3_avg
vortex_o3_sig_save(imonth,*,*)=vortex_o3_sig
high_o3_num_save(imonth,*,*)=high_o3_num
high_o3_avg_save(imonth,*,*)=high_o3_avg
high_o3_sig_save(imonth,*,*)=high_o3_sig
;
; store individual monthly profiles
;
save,file=dir+'_3d_o3_airmass_'+strmid(ifile,0,4)+strmid(ifile,7,2)+'.sav',ybin,th,$
     out_o3_num,vortex_o3_num,high_o3_num,out_o3_avg,out_o3_sig,vortex_o3_avg,$
     vortex_o3_sig,high_o3_avg,high_o3_sig
jumpwrite:
endfor		; loop over months
;
; store statistics for all januaries, februaries, ...
;
;for i=0,11 do begin
;for k=0,nth-1 do begin
;for j=0,nlat-1 do begin
;    num=out_o3_month_num(i,j,k)
;    if num ge 5L then begin
;       tmp=reform(out_o3_month(0:num-1,i,j,k))
;       result=moment(tmp)
;       out_o3_month_avg(i,j,k)=result(0)
;       out_o3_month_sig(i,j,k)=sqrt(result(1))
;    endif
;    num=vortex_o3_month_num(i,j,k)
;    if num ge 5L then begin
;       tmp=reform(vortex_o3_month(0:num-1,i,j,k))
;       result=moment(tmp)
;       vortex_o3_month_avg(i,j,k)=result(0)
;       vortex_o3_month_sig(i,j,k)=sqrt(result(1))
;    endif
;    num=high_o3_month_num(i,j,k)
;    if num ge 5L then begin
;       tmp=reform(high_o3_month(0:num-1,i,j,k))
;       result=moment(tmp)
;       high_o3_month_avg(i,j,k)=result(0)
;       high_o3_month_sig(i,j,k)=sqrt(result(1))
;    endif
;print,mon(i),th(k),ybin(j),out_o3_month_num(i,j,k),vortex_o3_month_num(i,j,k),high_o3_month_num(i,j,k)
;endfor
;endfor
;endfor

save,file=dir+'_3d_o3_airmass_uars.sav',ybin,th,out_o3_num_save,vortex_o3_num_save,$
     high_o3_num_save,out_o3_avg_save,out_o3_sig_save,vortex_o3_avg_save,vortex_o3_sig_save,$
     high_o3_avg_save,high_o3_sig_save
;,out_o3_month_num,vortex_o3_month_num,high_o3_month_num,$
;    out_o3_month_avg,vortex_o3_month_avg,high_o3_month_avg,out_o3_month_sig,vortex_o3_month_sig,$
;    high_o3_month_sig
end
