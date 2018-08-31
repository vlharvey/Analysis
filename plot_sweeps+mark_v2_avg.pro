;
; version 2 incorporates information about the number of anticyclones
; present along a given latitude circle
; plot the location of occultations over zonal mean marker values
; AVERAGE marker
; VLH	4/1/03
;
@rd_ukmo_nc3

loadct,38
mcolor=byte(!p.color)
icmm1=mcolor-1B
icmm2=mcolor-2B
device,decompose=0
!noeras=1
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
setplot='ps'
;read,'enter setplot',setplot
nxdim=700
nydim=700
xorig=[0.15]
yorig=[0.3]
xlen=0.7
ylen=0.4
cbaryoff=0.06
cbarydel=0.02
lc=mcolor
lc2=mcolor
if setplot ne 'ps' then $
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
ufile='ukmo_1994.fil'
sfile='haloe_sage2+3_poam_ilas_sweeps_1994.dat'		; example year over mark avg
;
; read year of sweep locations
;
close,10
openr,10,'../Datfiles/'+sfile
hcount=0L
readf,10,hcount
if hcount gt 0L then begin
   th=fltarr(hcount)
   yh=fltarr(hcount)
   readf,10,th,yh
endif
scount=0L
readf,10,scount
if scount gt 0L then begin
   ts=fltarr(scount)
   ys=fltarr(scount)
   readf,10,ts,ys
endif
scount3=0L
readf,10,scount3
if scount3 gt 0L then begin
   ts3=fltarr(scount3)
   ys3=fltarr(scount3)
   readf,10,ts3,ys3
endif
pcount=0L
readf,10,pcount
if pcount gt 0L then begin
   tp=fltarr(pcount)
   yp=fltarr(pcount)
   readf,10,tp,yp
endif
icount=0L
readf,10,icount
if icount gt 0L then begin
   ti=fltarr(icount)
   yi=fltarr(icount)
   readf,10,ti,yi
endif
close,10
filename=''
nday=0L
close,2
openr,2,ufile
readf,2,nday
for iday=0,nday-1 do begin
    readf,2,filename
    if strmid(filename,7,1) eq '9' then syear='19'+strmid(filename,7,2)
    if strmid(filename,7,1) eq '0' then syear='20'+strmid(filename,7,2)
endfor
close,10
openr,10,'../Datfiles/markbar_1992-2003_v2.dat'
nday=0L & nr=0L & nth=0L
readu,10,nday,nr,nth
days=fltarr(nday)
alat=fltarr(nr)
thlev=fltarr(nth)
readu,10,days,alat,thlev
markbar=fltarr(nday,nr,nth)
marklow=fltarr(nday,nr,nth)
markhigh=fltarr(nday,nr,nth)
readu,10,markbar,marklow,markhigh
x2d=fltarr(nday,nr)
y2d=fltarr(nday,nr)
for i=0,nday-1L do y2d(i,*)=alat
for j=0,nr-1L do x2d(*,j)=days

for k=0,nth-1 do begin
stheta=strcompress(string(fix(thlev(k)))+'K',/remove_all)
;
; plot
;
if setplot eq 'ps' then begin
   lc2=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/color,/landscape,bits=8,$
          filename='sweeps+mark_'+stheta+'_v2_avg.ps'
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
           xsize=xsize,ysize=ysize
endif
erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
;markbar=markbar_avg
;marklow=marklow_avg
;markhigh=markhigh_avg
marklev=reform(markhigh(*,*,k))
contour,marklev,1.+findgen(nday),alat,levels=[0.],yticks=6,$
     xrange=[1.,nday],yrange=[-90.,90.],xticks=12,c_color=col1,$
     /cell_fill,title='1992-2003                     '+stheta,$
     /nodata,charsize=2,ytitle='Latitude',xtickname=[' ',' ',$
     ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ']
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
index=where(marklev ne 0.,nm)
if index(0) ne -1 then begin
   xtmp=x2d(index)
   ytmp=y2d(index)
   mtmp=marklev(index)
   ymin=fix(min(markhigh)-1.)
;
; plot -1's first then on down
;
   level=[0.0,-0.1,-0.5,-1.0,-1.5,-2.0,-2.5,-3.0]
   nlev=n_elements(level)-1
   col1=[0.50,0.55,0.65,0.70,0.75,0.80,0.85,0.95]*mcolor
   for i=0,nlev-1 do begin
       index=where(mtmp lt level(i) and mtmp ge level(i+1))
       if index(0) ne -1 then $
          oplot,xtmp(index),ytmp(index),psym=8,color=col1(i)
   endfor
endif
level=abs(level)
a=findgen(8)*(2*!pi/8.)
usersym,0.5*cos(a),0.5*sin(a),/fill
marklev=reform(markhigh(*,*,k))
contour,marklev,1.+findgen(nday),alat,levels=[-4.,-3.,-2.,-1.],/overplot,color=0
marklev=reform(marklow(*,*,k))
contour,marklev,1.+findgen(nday),alat,levels=[0.1,1.0],/overplot,color=mcolor*.2,thick=5
xyouts,7.,-105.,'Jan',charsize=1.5,/data
xyouts,38.,-105.,'Feb',charsize=1.5,/data
xyouts,66.,-105.,'Mar',charsize=1.5,/data
xyouts,98.,-105.,'Apr',charsize=1.5,/data
xyouts,128.,-105.,'May',charsize=1.5,/data
xyouts,159.,-105.,'Jun',charsize=1.5,/data
xyouts,189.,-105.,'Jul',charsize=1.5,/data
xyouts,219.,-105.,'Aug',charsize=1.5,/data
xyouts,250.,-105.,'Sep',charsize=1.5,/data
xyouts,280.,-105.,'Oct',charsize=1.5,/data
xyouts,311.,-105.,'Nov',charsize=1.5,/data
xyouts,341.,-105.,'Dec',charsize=1.5,/data
if hcount gt 0L then oplot,th,yh,psym=4,color=mcolor*lc2,symsize=2
if scount gt 0L then oplot,ts,ys,psym=8,color=mcolor*lc2,symsize=2
if pcount gt 0L then oplot,tp,yp,psym=8,color=lc2,symsize=2
if icount gt 0L then oplot,ti,yi,psym=3,color=lc2,symsize=2
!psym=0
imin=min(level)
imax=max(level)
ymnb=ymn -cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xorig(0),xorig(0)+xlen,ymnb,ymxb
!type=2^2+2^3+2^6
xlabels=strcompress(string(FORMAT='(F3.1)',level),/remove_all)
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],$
      charsize=1.5,xticks=n_elements(xlabels)-1,xtickname=xlabels,$
      xtitle='Number of Anticyclones'
ybox=[0,10,10,0,0]
x2=imin
dx=(imax-imin)/float(nlev)
for j=0,nlev-1 do begin
    xbox=[x2,x2,x2+dx,x2+dx,x2]
    polyfill,xbox,ybox,color=col1(j)
    x2=x2+dx
endfor
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert sweeps+mark_'+stheta+'_v2_avg.ps -rotate -90 '+$
                 'sweeps+mark_'+stheta+'_v2_avg.jpg'
endif
endfor	; loop over levels
end
