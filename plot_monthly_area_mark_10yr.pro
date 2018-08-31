;
; read multi-year monthly mean vortex frequency and plot altitude-time
; section of area enclosed in Highs and Lows
;
@gcm_panels

loadct,38
mcolor=!p.color
mcolor=byte(!p.color)
device,decompose=0
month=['July','August','September','October','November','December',$
       'January','February','March','April','May','June']
smon=['J','A','S','O','N','D','J','F','M','A','M','J']
re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
!noeras=1
nxdim=800
nydim=800
xorig=[0.1,0.55,0.1,0.55]
yorig=[0.55,0.55,0.12,0.12]
xlen=0.4
ylen=0.35
cbaryoff=0.055
cbarydel=0.005
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
   device,/landscape,bits=8,filename='wa3_areazt_4pan_30-pole.ps'
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
; altitude-time arrays
;
    if m eq 0L then begin
       nhharea=fltarr(nmonths,nth)
       nhlarea=fltarr(nmonths,nth)
       shharea=fltarr(nmonths,nth)
       shlarea=fltarr(nmonths,nth)
       dum=transpose(mark_mean(*,*,0))
       lon=0.*dum
       lat=0.*dum
       for i=0,nc-1 do lat(i,*)=alat
       for j=0,nr-1 do lon(*,j)=alon
       area=0.*lat
       nrr=91
       yeq=findgen(nrr)
       latcircle=fltarr(nrr)
       latsum=fltarr(nrr)
       hem_frac=fltarr(nrr)
       for j=0,nrr-2 do begin
           hy=re*dtr
           dx=re*cos(yeq(j)*dtr)*360.*dtr
           latcircle(j)=dx*hy ; area in each latitude circle
       endfor
       for j=0L,nrr-1 do latsum(j)=total(latcircle(j:nrr-1))
       for j=0,nrr-1 do begin
           index=where(yeq ge yeq(j))

; fraction of the hemisphere of each latitude circle
           if index(0) ne -1 then $
              hem_frac(j)=100.*total(latcircle(index))/hem_area
           if yeq(j) eq 0. then hem_frac(j)=100.
       endfor
       deltax=alon(1)-alon(0)
       deltay=alat(1)-alat(0)
       for j=0,nr-1 do begin
           hy=re*deltay*dtr
           dx=re*cos(alat(j)*dtr)*deltax*dtr
           area(*,j)=dx*hy    ; area of each grid point
       endfor
    endif

    for thlev=0,nth-1 do begin
        mark=transpose(mark_mean(*,*,thlev))
        index=where(lat gt 0. and mark gt 0.0)
        if index(0) ne -1 then begin
           a0=total(area(index))
           nhlarea(m,thlev)=a0/1.e6     ; millions of sqare km
        endif
        index=where(lat gt 30. and mark lt 0.0)
        if index(0) ne -1 then begin
           a0=total(area(index))
           nhharea(m,thlev)=a0/1.e6
        endif
        index=where(lat lt 0. and mark gt 0.0)
        if index(0) ne -1 then begin
           a0=total(area(index))
           shlarea(m,thlev)=a0/1.e6
        endif
        index=where(lat lt -30. and mark lt 0.0)
        if index(0) ne -1 then begin
           a0=total(area(index))
           shharea(m,thlev)=a0/1.e6
        endif
    endfor

endfor	; loop over months

!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=5*findgen(26)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,nhlarea,1.+findgen(nmonths),th,levels=level,xrange=[1,nmonths],/fill,/cell_fill,$
        c_color=col1,/noeras,title='Arctic Vortex Area',charsize=1.2,yrange=[500,2000.],$
        min_value=0.,xticks=nmonths-1,xtickname=smon
contour,nhlarea,1.+findgen(nmonths),th,levels=level,/follow,/overplot,c_color=0,/noeras,$
        min_value=0.,c_labels=0*indgen(nlvls)
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
contour,shlarea,1.+findgen(nmonths),th,levels=level,xrange=[1,nmonths],/fill,/cell_fill,$
        c_color=col1,/noeras,title='Antarctic Vortex Area',charsize=1.2,yrange=[500,2000.],$
        min_value=0.,xticks=nmonths-1,xtickname=smon
contour,shlarea,1.+findgen(nmonths),th,levels=level,/follow,/overplot,c_color=0,/noeras,$
        min_value=0.,c_labels=0*indgen(nlvls)
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
contour,nhharea,1.+findgen(nmonths),th,levels=level,xrange=[1,nmonths],/fill,/cell_fill,$
        c_color=col1,/noeras,title='NH Anticyclone Area',charsize=1.2,yrange=[500,2000.],$
        min_value=0.,xticks=nmonths-1,xtickname=smon
contour,nhharea,1.+findgen(nmonths),th,levels=level,/follow,/overplot,c_color=0,/noeras,c_labels=0*indgen(nlvls),$
        min_value=0.
xmn=xorig(3)
xmx=xorig(3)+xlen
ymn=yorig(3)
ymx=yorig(3)+ylen
set_viewport,xmn,xmx,ymn,ymx
contour,shharea,1.+findgen(nmonths),th,levels=level,xrange=[1,nmonths],/fill,/cell_fill,$
        c_color=col1,/noeras,title='SH Anticyclone Area',charsize=1.2,yrange=[500,2000.],$
        min_value=0.,xticks=nmonths-1,xtickname=smon
contour,shharea,1.+findgen(nmonths),th,levels=level,/follow,/overplot,c_color=0,/noeras,c_labels=0*indgen(nlvls),$
        min_value=0.
imin=min(level)
imax=max(level)
set_viewport,0.3,0.7,0.05,0.06
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],charsize=1.5,title='millions of sqare kilometers'
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(j)
    x1=x1+dx
endfor
xyouts,.3,.95,'WACCM3 Output (30 degrees to the pole)',/normal,charsize=2
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim wa3_areazt_4pan_30-pole.ps -rotate -90 wa3_areazt_4pan_30-pole.jpg'
endif

end

