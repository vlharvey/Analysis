;
; read multi-year monthly means in all fields and plot vortices
;
nxdim=750
nydim=750
xorig=[0.2]
yorig=[0.25]
xlen=0.65
ylen=0.65
cbaryoff=0.11
cbarydel=0.02
loadct,38
mcolor=!p.color
mcolor=byte(!p.color)
device,decompose=0
month=['July','August','September','October','November','December',$
       'January','February','March','April','May','June']
months=['Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar','Apr','May','Jun']
mon=['jul','aug','sep','oct','nov','dec','jan','feb','mar','apr','may','jun']
re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
!noeras=1
set_plot,'x'
setplot='x'
read,'setplot= ',setplot
if setplot ne 'ps' then $
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
dir='/aura7/harvey/GEOS5_data/Datfiles/'
infiles=[$
'DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.jul_avg.sav',$
'DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.aug_avg.sav',$
'DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.sep_avg.sav',$
'DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.oct_avg.sav',$
'DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.nov_avg.sav',$
'DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.dec_avg.sav',$
'DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.jan_avg.sav',$
'DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.feb_avg.sav',$
'DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.mar_avg.sav',$
'DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.apr_avg.sav',$
'DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.may_avg.sav',$
'DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.jun_avg.sav']
infiles=dir+infiles
nmonths=n_elements(month)
for m=0,nmonths-1 do begin
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='geos5_markyz_'+mon(m)+'.ps'
       device,/color
       device,/bold
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif
    ifile=infiles(m)
    print,ifile
    restore,ifile
;
; zonal mean array
;
    markyz=fltarr(nr,nth)
    uyz=fltarr(nr,nth)
    minmarkyz=fltarr(nr,nth)
    for k=0L,nth-1L do begin
        for j=0L,nr-1L do begin
            markyz(j,k)=total(mark_mean(j,*,k))/float(nc)
            uyz(j,k)=total(u_mean(j,*,k))/float(nc)
            minmarkyz(j,k)=min(mark_mean(j,*,k))
        endfor
    endfor
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=-1.0+0.1*findgen(21)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,minmarkyz,alat,th,levels=level,xrange=[-90.,90.],xticks=6,/fill,/cell_fill,$
        c_color=col1,/noeras,title=month(m)+' GEOS-5',charsize=2,xtitle='Latitude',$
        ytitle='Potential Temperature',yrange=[min(th),4000.]
index=where(level lt 0.)
contour,minmarkyz,alat,th,levels=level(index),/follow,/overplot,c_color=0,/noeras,c_labels=0*indgen(nlvls),thick=2
index=where(level gt 0.)
contour,minmarkyz,alat,th,levels=level(index),/follow,/overplot,c_color=mcolor,/noeras,c_labels=0*indgen(nlvls),thick=2
contour,uyz,alat,th,levels=[-100.,-80.,-60.],/follow,/overplot,c_color=mcolor,/noeras,c_labels=0*indgen(nlvls),$
        c_linestyle=1,thick=2
contour,uyz,alat,th,levels=[60.,80.,100.],/follow,/overplot,c_color=0,/noeras,c_labels=0*indgen(nlvls),$
        c_linestyle=0,thick=2

imin=min(level)
imax=max(level)
set_viewport,xorig(0),xorig(0)+xlen,yorig(0)-cbaryoff,yorig(0)-cbaryoff+cbarydel
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],charsize=1.5,xtitle='Vortex/Anticyclone Frequency'
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(j)
    x1=x1+dx
endfor

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim geos5_markyz_'+mon(m)+'.ps -rotate -90 geos5_markyz_'+mon(m)+'.jpg'
;  spawn,'/usr/bin/rm geos5_markyz_'+mon(m)+'.ps'
endif
endfor  ; loop over months

end

