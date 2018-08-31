;
; read multi-year monthly means in all fields and plot vortices
;
@gcm_panels

loadct,38
mcolor=!p.color
mcolor=byte(!p.color)
device,decompose=0
month=['July','August','September','October','November','December',$
       'January','February','March','April','May','June']
re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
!noeras=1
nxdim=800
nydim=800
xorig=[0.2]
yorig=[0.25]
xlen=0.65
ylen=0.65
cbaryoff=0.1
cbarydel=0.01
set_plot,'x'
setplot='x'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/aura7/harvey/WACCM_data/Datfiles/'
infiles=dir+[$
'wa3_tnv3_jul_avg.sav',$
'wa3_tnv3_aug_avg.sav',$
'wa3_tnv3_sep_avg.sav',$
'wa3_tnv3_oct_avg.sav',$
'wa3_tnv3_nov_avg.sav',$
'wa3_tnv3_dec_avg.sav',$
'wa3_tnv3_jan_avg.sav',$
'wa3_tnv3_feb_avg.sav',$
'wa3_tnv3_mar_avg.sav',$
'wa3_tnv3_apr_avg.sav',$
'wa3_tnv3_may_avg.sav',$
'wa3_tnv3_jun_avg.sav']
nmonths=n_elements(month)
for m=0,nmonths-1 do begin
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='wa3_u+markyz_1pan_5000K_'+month(m)+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif

    ifile=infiles(m)
    print,ifile
    restore,ifile
;
; zonal mean array
;
    uyz=fltarr(nr,nth)
    markyz=fltarr(nr,nth)
    minmarkyz=fltarr(nr,nth)
    for k=0L,nth-1L do begin
        for j=0L,nr-1L do begin
            uyz(j,k)=total(u_mean(j,*,k))/float(nc)
            markyz(j,k)=max(mark_mean(j,*,k))
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
level=-100.+10.*findgen(21)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,uyz,alat,th,levels=level,xrange=[-90.,90.],xticks=6,/fill,/cell_fill,color=0,$
        c_color=col1,/noeras,title=month(m),charsize=2,yrange=[min(th),5000.],charthick=2,$
        ytitle='Potential Temperature (K)',xtitle='Latitude'
index=where(level gt 0.)
contour,uyz,alat,th,levels=level(index),/overplot,/follow,color=0,thick=2
index=where(level lt 0.)
contour,uyz,alat,th,levels=level(index),/overplot,/follow,color=mcolor,c_linestyle=5,thick=2
contour,markyz,alat,th,levels=0.1+0.1*findgen(9),/follow,/overplot,c_color=0,/noeras,thick=10
imin=min(level)
imax=max(level)
set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],charsize=1.5,charthick=2,color=0,xtitle='m/s'
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
   spawn,'convert -trim wa3_u+markyz_1pan_5000K_'+month(m)+'.ps -rotate -90 wa3_u+markyz_1pan_5000K_'+month(m)+'.jpg'
endif
endfor
end

