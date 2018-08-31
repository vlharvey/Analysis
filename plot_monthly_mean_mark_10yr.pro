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
npp=12
delta='n'
gcm_panels,npp,delta,nxdim,nydim,xorig,yorig,xlen,ylen,cbaryoff,cbarydel
xlen=.15
set_plot,'x'
setplot='x'
read,'setplot= ',setplot
if setplot ne 'ps' then $
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
infiles=[$
'../Datfiles/wa3_tnv3_jul_avg.sav',$
'../Datfiles/wa3_tnv3_aug_avg.sav',$
'../Datfiles/wa3_tnv3_sep_avg.sav',$
'../Datfiles/wa3_tnv3_oct_avg.sav',$
'../Datfiles/wa3_tnv3_nov_avg.sav',$
'../Datfiles/wa3_tnv3_dec_avg.sav',$
'../Datfiles/wa3_tnv3_jan_avg.sav',$
'../Datfiles/wa3_tnv3_feb_avg.sav',$
'../Datfiles/wa3_tnv3_mar_avg.sav',$
'../Datfiles/wa3_tnv3_apr_avg.sav',$
'../Datfiles/wa3_tnv3_may_avg.sav',$
'../Datfiles/wa3_tnv3_jun_avg.sav']
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='wa3_markyz_12pan_5000.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
erase
nmonths=n_elements(month)
for m=0,nmonths-1 do begin
    ifile=infiles(m)
    print,ifile
    restore,ifile
;
; zonal mean array
;
    markyz=fltarr(nr,nth)
    minmarkyz=fltarr(nr,nth)
    for k=0L,nth-1L do begin
        for j=0L,nr-1L do begin
            markyz(j,k)=total(mark_mean(j,*,k))/float(nc)
            minmarkyz(j,k)=min(mark_mean(j,*,k))
        endfor
    endfor

!type=2^2+2^3
xmn=xorig(m)
xmx=xorig(m)+xlen
ymn=yorig(m)
ymx=yorig(m)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=-1.0+0.1*findgen(21)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,minmarkyz,alat,th,levels=level,xrange=[-90.,90.],xticks=6,/fill,/cell_fill,$
        c_color=col1,/noeras,title=month(m),charsize=1.2,yrange=[min(th),5000.]
index=where(level lt 0.)
contour,minmarkyz,alat,th,levels=level(index),/follow,/overplot,c_color=0,/noeras,c_labels=0*indgen(nlvls)
index=where(level gt 0.)
contour,minmarkyz,alat,th,levels=level(index),/follow,/overplot,c_color=mcolor,/noeras,c_labels=0*indgen(nlvls)
endfor	; loop over months
imin=min(level)
imax=max(level)
set_viewport,0.3,0.7,0.05,0.06
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],charsize=1.5
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(j)
    x1=x1+dx
endfor
xyouts,.2,.95,'WACCM3 15-Year Monthly Mean Zonal Mean Vortex Frequency',/normal,charsize=1.5

if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim wa3_markyz_12pan_5000.ps -rotate -90 wa3_markyz_12pan_5000.jpg'
endif

end

