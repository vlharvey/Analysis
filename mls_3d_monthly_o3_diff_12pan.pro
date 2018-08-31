;
; average individual monthly averages to get multi-year monthly averages
;
@fillit
@smoothit

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
npp=12L
delta='y'
gcm_panels,npp,delta,nxdim,nydim,xorig,yorig,xlen,ylen,cbaryoff,cbarydel
if setplot ne 'ps' then begin
   lc=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/portrait,bits=8,filename='mls_3d_o3_diff_12pan.ps'
   device,/color
   device,/inch,xoff=0.05,yoff=.1,xsize=xsize,ysize=ysize
endif
dir='/aura6/data/MLS_data/Datfiles/mls_'
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
mday=[31,28,31,30,31,30,31,31,30,31,30,31]
nlat=18
ybin=-85.+10.*findgen(nlat)
nmonth=12L
for imonth=0L,nmonth-1L do begin
    spawn,'ls -1 '+dir+'*airmass*'+mon(imonth)+'*.sav',ifiles
;   for i=0L,0L do begin	;n_elements(ifiles)-1L do begin
    for i=0L,n_elements(ifiles)-1L do begin
        restore,ifiles(i)
print,'restored '+ifiles(i)
        if i eq 0L then begin
           HIGH_O3_AVG_ALL=0.*high_o3_avg
           HIGH_O3_NUM_ALL=0L*high_o3_num
           HIGH_O3_SIG_ALL=0.*high_o3_avg
           OUT_O3_AVG_ALL=0.*out_o3_avg
           OUT_O3_NUM_ALL=0L*out_o3_num
           OUT_O3_SIG_ALL=0.*out_o3_avg
           VORTEX_O3_AVG_ALL=0.*vortex_o3_avg
           VORTEX_O3_NUM_ALL=0L*vortex_o3_num
           VORTEX_O3_SIG_ALL=0.*vortex_o3_avg
x2d=0.*vortex_o3_avg
y2d=0.*vortex_o3_avg
for ii=0,nlat-1 do y2d(ii,*)=th
for j=0,n_elements(th)-1 do x2d(*,j)=ybin
        endif
        index=where(high_o3_avg ne -9999.)
        if index(0) ne -1L then begin
        HIGH_O3_AVG_ALL(index)=HIGH_O3_AVG_ALL(index)+high_o3_avg(index)*float(high_o3_num(index))
        HIGH_O3_NUM_ALL(index)=HIGH_O3_NUM_ALL(index)+high_o3_num(index)
        HIGH_O3_SIG_ALL(index)=HIGH_O3_SIG_ALL(index)+high_o3_sig(index)*float(high_o3_num(index))
        endif
        index=where(out_O3_avg ne 0L)
        if index(0) ne -1L then begin
        OUT_O3_AVG_ALL(index)=OUT_O3_AVG_ALL(index)+out_o3_avg(index)*float(out_o3_num(index))
        OUT_O3_NUM_ALL(index)=OUT_O3_NUM_ALL(index)+out_o3_num(index)
        OUT_O3_SIG_ALL(index)=OUT_O3_SIG_ALL(index)+out_o3_sig*float(out_o3_num(index))
        endif
        index=where(vortex_O3_avg ne 0L)
        if index(0) ne -1L then begin
        VORTEX_O3_AVG_ALL(index)=VORTEX_O3_AVG_ALL(index)+vortex_o3_avg(index)*float(vortex_o3_num(index))
        VORTEX_O3_NUM_ALL(index)=VORTEX_O3_NUM_ALL(index)+vortex_o3_num(index)
        VORTEX_O3_SIG_ALL(index)=VORTEX_O3_SIG_ALL(index)+vortex_o3_sig(index)*float(vortex_o3_num(index))
        endif
    endfor
    index=where(HIGH_O3_AVG_ALL gt 0.)
    HIGH_O3_AVG_ALL(index)=HIGH_O3_AVG_ALL(index)/HIGH_O3_NUM_ALL(index)
    HIGH_O3_SIG_ALL(index)=HIGH_O3_SIG_ALL(index)/HIGH_O3_NUM_ALL(index)
    index=where(OUT_O3_AVG_ALL gt 0.)
    OUT_O3_AVG_ALL(index)=OUT_O3_AVG_ALL(index)/OUT_O3_NUM_ALL(index)
    OUT_O3_SIG_ALL(index)=OUT_O3_SIG_ALL(index)/OUT_O3_NUM_ALL(index)
    index=where(VORTEX_O3_AVG_ALL gt 0.)
    VORTEX_O3_AVG_ALL(index)=VORTEX_O3_AVG_ALL(index)/VORTEX_O3_NUM_ALL(index)
    VORTEX_O3_SIG_ALL(index)=VORTEX_O3_SIG_ALL(index)/VORTEX_O3_NUM_ALL(index)

!type=2^2+2^3
set_viewport,xorig(imonth),xorig(imonth)+xlen,yorig(imonth),yorig(imonth)+ylen
level=0.5*findgen(nlvls)
index=where(out_o3_avg_all eq 0.)
if index(0) ne -1L then out_o3_avg_all(index)=-9999.
yindex=where(th eq 2000. or th eq 1800. or th eq 1600. or th eq 1400. or th eq 1200. or $
            th eq 1000. or th eq 800. or th eq 600. or th eq 400.,nth)
ynames=strcompress(fix(string(th(yindex))),/remove_all)
if imonth ne 0L and imonth ne 4L and imonth ne 8L then ynames=[' ',' ']
xyouts,.25,.95,'MLS Anticyclone Ozone Anomaly',charsize=3,/normal
level=-2.+0.2*findgen(nlvls)
index=where(high_o3_avg_all gt 0. and out_o3_avg_all gt 0.)
dum=0.*out_o3_avg_all
dum(index)=high_o3_avg_all(index)-out_o3_avg_all(index)
index=where(dum eq 0.)
dum(index)=-9999.
contour,dum,ybin,th,xrange=[-90.,90.],yrange=[400.,2000.],/noeras,/cell_fill,$
        c_color=col1,levels=level,min_value=-9999.,title=strupcase(strmid(mon(imonth),0,3)),$
        charsize=1.75,yticks=n_elements(ynames)-1,ytickv=th(yindex),ytickname=ynames
index=where(level lt 0.)
contour,dum,ybin,th,/overplot,/noeras,color=0,levels=level(index),c_linestyle=1,min_value=-9999.
index=where(level gt 0.)
contour,dum,ybin,th,/overplot,/noeras,color=mcolor,levels=level(index),c_linestyle=0,min_value=-9999.
contour,dum,ybin,th,/overplot,/noeras,color=0,levels=0,thick=2,min_value=-9999.
index=where(dum ne -9999.)
index=where(high_o3_num_all le 0.)
oplot,x2d(index),y2d(index),psym=8,symsize=0.2

;print,'high ',min(dum(index)),max(dum)
endfor		; loop over months
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim mls_3d_o3_diff_12pan.ps mls_3d_o3_diff_12pan.jpg'
endif
end
