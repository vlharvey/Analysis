;
; read multi-year monthly means in all fields and plot vortices
;
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=750
nydim=750
xorig=[0.15,0.15]
yorig=[0.55,0.15]
xlen=0.75
ylen=0.3
cbaryoff=0.05
cbarydel=0.02
loadct,38
mcolor=!p.color
mcolor=byte(!p.color)
lc=mcolor
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
sdir='/aura6/data/SNOE_data/Datfiles/'
wdir='/aura3/data/WACCM_data/Datfiles/'
syear=['1998','1999','2000','2001','2002']
lyear=long(syear)
nyear=n_elements(syear)
restore,wdir+'wa3_tnv3_jun_avg.sav'
rth=5000.
;print,th
;read,'Enter desired theta surface ',rth
index=where(rth eq th)
ith=index(0)
sth=strcompress(long(rth),/remove_all)
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='merc_wa3_mark_2pan_'+sth+'K+snoe.ps'
       device,/color
       device,/bold
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
       lc=0
    endif

restore,wdir+'wa3_tnv3_jun_avg.sav'
jjamark=transpose(mark_mean(*,*,ith))
restore,wdir+'wa3_tnv3_jul_avg.sav'
jjamark=jjamark+transpose(mark_mean(*,*,ith))
restore,wdir+'wa3_tnv3_aug_avg.sav'
jjamark=jjamark+transpose(mark_mean(*,*,ith))
jjamark=jjamark/3.0

restore,wdir+'wa3_tnv3_nov_avg.sav'
ndjmark=transpose(mark_mean(*,*,ith))
restore,wdir+'wa3_tnv3_dec_avg.sav'
ndjmark=ndjmark+transpose(mark_mean(*,*,ith))
restore,wdir+'wa3_tnv3_jan_avg.sav'
ndjmark=ndjmark+transpose(mark_mean(*,*,ith))
ndjmark=ndjmark/3.0

erase
!type=2^2+2^3
xyouts,.3,.925,'WACCM3 + SNOE '+sth+' K',/normal,charsize=3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=-1.0+0.1*findgen(21)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
map_set,0,0,0,/contin,/grid,/noeras,title='NH Summer (JJA)',charsize=2
contour,jjamark,alon,alat,levels=0.1+0.1*findgen(9),/follow,color=lc,/noeras,thick=3,/overplot
imax=0.
for iyear=0L,nyear-1L do begin
    year = syear(iyear)
    restore,sdir+'snoe_pmc_params'+year+'.sav'
    index=where(lsr1 gt 0. and lat gt 0. and abs(lat) lt 50.,npmc)
    if max(lsr1(index)) gt imax then imax=max(lsr1(index))
    for i=0L,npmc-1L do begin
        oplot,[lon(index(i)),lon(index(i))],[lat(index(i)),lat(index(i))],psym=8,symsize=2,$
              color=(lsr1(index(i))/6.7)*mcolor
    endfor
;   print,date(index)
endfor

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=-1.0+0.1*findgen(21)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
map_set,0,0,0,/contin,/grid,/noeras,title='SH Summer (NDJ)',charsize=2
contour,ndjmark,alon,alat,levels=0.1+0.1*findgen(9),/follow,color=lc,/noeras,thick=3,/overplot
for iyear=0L,nyear-1L do begin
    year = syear(iyear)
    restore,sdir+'snoe_pmc_params'+year+'.sav'
    index=where(lsr1 gt 0. and lat lt 0. and abs(lat) lt 50.,npmc)
    for i=0L,npmc-1L do begin
        oplot,[lon(index(i)),lon(index(i))],[lat(index(i)),lat(index(i))],psym=8,symsize=2,$
              color=(lsr1(index(i))/6.7)*mcolor
    endfor
;   print,date(index)
endfor

imin=0.
set_viewport,xorig(1),xorig(1)+xlen,yorig(1)-cbaryoff,yorig(1)-cbaryoff+cbarydel
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],charsize=1.5,xtitle='PMC Brightness'
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
   spawn,'convert -trim merc_wa3_mark_'+sth+'K+snoe.ps -rotate -90 merc_wa3_mark_'+sth+'K+snoe.jpg'
   spawn,'/usr/bin/rm merc_wa3_mark_'+sth+'K+snoe.ps'
endif

end

