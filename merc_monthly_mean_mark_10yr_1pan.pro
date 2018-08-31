;
; read multi-year monthly means in all fields and plot vortices
;
nxdim=750
nydim=750
xorig=[0.15]
yorig=[0.25]
xlen=0.8
ylen=0.6
cbaryoff=0.11
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
infiles=[$
'/aura7/harvey/WACCM_data/Datfiles/TNV3_files/wa3_tnv3_jul_avg.sav',$
'/aura7/harvey/WACCM_data/Datfiles/TNV3_files/wa3_tnv3_aug_avg.sav',$
'/aura7/harvey/WACCM_data/Datfiles/TNV3_files/wa3_tnv3_sep_avg.sav',$
'/aura7/harvey/WACCM_data/Datfiles/TNV3_files/wa3_tnv3_oct_avg.sav',$
'/aura7/harvey/WACCM_data/Datfiles/TNV3_files/wa3_tnv3_nov_avg.sav',$
'/aura7/harvey/WACCM_data/Datfiles/TNV3_files/wa3_tnv3_dec_avg.sav',$
'/aura7/harvey/WACCM_data/Datfiles/TNV3_files/wa3_tnv3_jan_avg.sav',$
'/aura7/harvey/WACCM_data/Datfiles/TNV3_files/wa3_tnv3_feb_avg.sav',$
'/aura7/harvey/WACCM_data/Datfiles/TNV3_files/wa3_tnv3_mar_avg.sav',$
'/aura7/harvey/WACCM_data/Datfiles/TNV3_files/wa3_tnv3_apr_avg.sav',$
'/aura7/harvey/WACCM_data/Datfiles/TNV3_files/wa3_tnv3_may_avg.sav',$
'/aura7/harvey/WACCM_data/Datfiles/TNV3_files/wa3_tnv3_jun_avg.sav']
nmonths=n_elements(month)
for m=0,nmonths-1 do begin
    ifile=infiles(m)
    print,ifile
    restore,ifile
    if m eq 0L then begin
       rth=0.
       print,th
       read,'Enter desired theta surface ',rth
       index=where(rth eq th)
       ith=index(0)
       sth=strcompress(long(rth),/remove_all)
    endif
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='merc_wa3_mark_'+mon(m)+'_'+sth+'K.ps'
       device,/color
       device,/bold
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
       lc=0
    endif
;
; zonal mean array
;
    mark=fltarr(nc,nr)
    for j=0L,nr-1L do begin
        for i=0L,nc-1L do begin
            mark(i,j)=mark_mean(j,i,ith)
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
map_set,0,0,0,/contin,/grid,/noeras,title=month(m)+' WACCM3 '+sth+' K',charsize=2
contour,mark,alon,alat,levels=0.1+0.1*findgen(9),/follow,color=lc,/noeras,thick=3
map_set,0,0,0,/contin,/grid,/noeras
imin=min(level)
imax=max(level)
set_viewport,xorig(0),xorig(0)+xlen,yorig(0)-cbaryoff,yorig(0)-cbaryoff+cbarydel
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],charsize=1.5,xtitle='Vortex Frequency'
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
   spawn,'convert -trim merc_wa3_mark_'+mon(m)+'_'+sth+'K.ps -rotate -90 merc_wa3_mark_'+mon(m)+'_'+sth+'K.jpg'
   spawn,'/usr/bin/rm merc_wa3_mark_'+mon(m)+'_'+sth+'K.ps'
endif
endfor  ; loop over months

end

