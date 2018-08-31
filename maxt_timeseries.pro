;
; plot maximum temperature timeseries in each hemisphere at given theta surfaces
;
loadct,38
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icmm1=icolmax-1B
icmm2=icolmax-2B
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,.5*cos(a),.5*sin(a),/fill
!NOERAS=-1
!P.FONT=1
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.20]
yorig=[0.25]
xlen=0.6
ylen=0.6
cbaryoff=0.07
cbarydel=0.01
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
;
; restore max temperature from MetO
;
restore,'MetO_MaxT_Climo.sav'	;,yyyymmdd,th,nh_maxt_flag,sh_maxt_flag,comment
print,th
rth=1800.
read,'Enter desired theta surface ',rth
index=where(th eq rth)
ilev=index(0)
slev=strcompress(long(rth),/remove_all)
if setplot eq 'ps' then begin
   lc=0
   xsize=nxdim/100.
   ysize=nydim/100.
   set_plot,'ps'
   device,/color,/landscape,bits=8,filename='maxt_timeseries_'+slev+'K.ps'
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
endif
nhmaxt=reform(nh_maxt_flag(*,ilev))
shmaxt=reform(sh_maxt_flag(*,ilev))
nday=n_elements(yyyymmdd)
syyyymmdd=strcompress(yyyymmdd,/remove_all)
syr=strmid(syyyymmdd,2,2)
smn=strmid(syyyymmdd,4,2)
sdy=strmid(syyyymmdd,6,2)
xindex=where(smn eq '01' and sdy eq '01',nxticks)
xlabs=syr(xindex)
n0=findgen(nxticks)
n1=1.+findgen(nxticks)
diff=abs(xindex(n0)-xindex(n1))
index=where(diff eq 0. or (diff ge 360. and diff le 367.),nxticks)
xindex=xindex(index)
;
; plot
;
erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
xyouts,.225,.9,'MetO Maximum Daily Polar Temperature at '+slev+' K',/normal,charsize=1.5,color=0
!type=2^2+2^3
imin=230.
imax=330.
plot,findgen(nday),nhmaxt,psym=8,ytitle='Temperature',yrange=[imin,imax],/nodata,$
     xtickname=syr(xindex),xtickv=xindex,xticks=nxticks-1,charsize=1.5,color=0
;
; color by month of the year
;
nlvls=12
col1=1+indgen(nlvls)*icolmax/nlvls
for ii=0L,11 do begin
    sii=string(format='(i2.2)',ii+1)
    index=where(smn eq sii)
    oplot,index,nhmaxt(index),psym=8,symsize=1.5,color=col1(ii)
    oplot,index,shmaxt(index),psym=1,symsize=0.5,color=col1(ii)
endfor
xyouts,.2,.86,'Northern Hemisphere',color=0,/normal,charsize=1.5
xyouts,.55,.86,'Southern Hemisphere',color=0,/normal,charsize=1.5
;oplot,findgen(nday),nhmaxt,psym=8,color=0,symsize=0.8
imin=1.
imax=12.
ymnb=ymn -cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,$
      charsize=1.5,xtitle='Month of Year',color=0,xticks=11
ybox=[0,10,10,0,0]
x2=imin
dx=(imax-imin)/(float(nlvls)-1)
for j=1,nlvls-1 do begin
    xbox=[x2,x2,x2+dx,x2+dx,x2]
    polyfill,xbox,ybox,color=col1(j)
    x2=x2+dx
endfor

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim maxt_timeseries_'+slev+'K.ps -rotate -90 maxt_timeseries_'+slev+'K.jpg'
endif
end
