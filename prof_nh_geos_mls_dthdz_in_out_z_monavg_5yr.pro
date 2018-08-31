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
smonth=['10','11','12','01','02','03']
nmonth=n_elements(smonth)
syear=['2004','2005','2006','2007','2008','2009']
nyear=n_elements(lyear)

for imonth=0L,nmonth-1L do begin

dum=findfile('prof_nh_mls_dthdz_in_out_*'+smonth(imonth)+'_z_monavg.sav')
print,dum
nfile=n_elements(dum)
;
; read and average monthly mean profiles over nfile years
;
for ifile=0L,nfile-1L do begin
restore,dum(ifile)
print,'read average '+syrmon,icount

if imonth eq 0L and ifile eq 0L then begin
   nlev=n_elements(altitude)
   MCO_RATIO_avg=fltarr(nmonth,nlev)
   MDTHDZ_RATIO_avg=fltarr(nmonth,nlev)
   MTP_RATIO_avg=fltarr(nmonth,nlev)
   mnum_RATIO_avg=fltarr(nmonth,nlev)
endif
index=where(mco_ratio ne 0.)
if index(0) ne -1L then begin
   MCO_RATIO_avg(imonth,index)=MCO_RATIO_avg(imonth,index)+mco_ratio(index)
   MDTHDZ_RATIO_avg(imonth,index)=MDTHDZ_RATIO_avg(imonth,index)+mdthdz_ratio(index)
   MTP_RATIO_avg(imonth,index)=MTP_RATIO_avg(imonth,index)+mtp_ratio(index)
   mnum_RATIO_avg(imonth,index)=mnum_ratio_avg(imonth,index)+1.
endif

endfor
endfor
index=where(mnum_ratio_avg ne 0.)
if index(0) ne -1L then begin
   MCO_RATIO_avg(index)=MCO_RATIO_avg(index)/mnum_RATIO_avg(index)
   MDTHDZ_RATIO_avg(index)=MDTHDZ_RATIO_avg(index)/mnum_RATIO_avg(index)
   MTP_RATIO_avg(index)=MTP_RATIO_avg(index)/mnum_RATIO_avg(index)
endif
;
; postscript
;
    if setplot eq 'ps' then begin
       lc=0
       xsize=nxdim/100.
       ysize=nydim/100.
       set_plot,'ps'
       device,/color,/landscape,bits=8,filename='prof_nh_mls_dthdz_in_out_z_monavg_5yr.ps'
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
    xyouts,0.4,ymx+0.075,'MLS',charsize=3,color=0,/normal
    set_viewport,xmn,xmx,ymn,ymx
    plot,mtp_ratio_avg(0,*),altitude,color=0,title='Temperature in/out',xrange=[0.75,1.25],yrange=[20.,70.],/nodata,$
         charsize=1.5,ytitle='Altitude (km)'
    plots,1,20.
    plots,1,70.,/continue,color=0
for imonth=0L,nmonth-1L do begin
    mtp_ratio=reform(mtp_ratio_avg(imonth,*))
    index=where(mtp_ratio ne 0.)
    if index(0) ne -1L then oplot,mtp_ratio(index),altitude(index),color=(float(imonth)/float(nmonth))*mcolor,psym=8
endfor

    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    plot,mdthdz_ratio_avg(0,*),altitude,color=0,title='dth/dz in/out',charsize=1.5,xrange=[0.75,2],yrange=[20.,70.],/nodata
    plots,1,20.
    plots,1,70.,/continue,color=0
for imonth=0L,nmonth-1L do begin
    mdthdz_ratio=reform(mdthdz_ratio_avg(imonth,*))
    index=where(mdthdz_ratio ne 0.)
    if index(0) ne -1L then oplot,mdthdz_ratio(index),altitude(index),color=(float(imonth)/float(nmonth))*mcolor,psym=8
endfor

    xmn=xorig(2)
    xmx=xorig(2)+xlen
    ymn=yorig(2)
    ymx=yorig(2)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    plot,mco_ratio,altitude,color=0,title='CO in/out',charsize=1.5,$
         xrange=[0.1,100.],/xlog,yrange=[20.,70.],/nodata
    plots,1,20.
    plots,1,70.,/continue,color=0
for imonth=0L,nmonth-1L do begin
    mco_ratio=reform(mco_ratio_avg(imonth,*))
    index=where(mco_ratio ne 0.)
    if index(0) ne -1L then oplot,mco_ratio(index),altitude(index),color=(float(imonth)/float(nmonth))*mcolor,psym=8
endfor

; Close PostScript file and return control to X-windows
     if setplot ne 'ps' then stop
     if setplot eq 'ps' then begin
        device, /close
        spawn,'convert -trim prof_nh_mls_dthdz_in_out_z_monavg_5yr.ps -rotate -90 '+$
                            'prof_nh_mls_dthdz_in_out_z_monavg_5yr.jpg'
        spawn,'/usr/bin/rm prof_nh_mls_dthdz_in_out_z_monavg_5yr.ps'
     endif
end
