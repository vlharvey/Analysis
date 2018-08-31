;****************************************************************************************
; Read OMI he5 data and save column ozone at a specified latitude
; Programed by: V. Lynn Harvey  10/1/14
;               CU/LASP									*
;****************************************************************************************
@stddat
@kgmt
@ckday
@kdate
@readl3omi

restore,'c11.tbl'
tvlct,c1,c2,c3
c1(12)=180 & c2(12)=0 & c3(12)=0
tvlct,c1,c2,c3  ;must execute this again.
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=1000
nydim=1000
xorig=[0.1,0.1]
yorig=[0.6,0.2]
cbaryoff=0.08
cbarydel=0.01
xlen=0.8
ylen=0.3
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
;
; read CIPS PMC frequencies at 80S with 2G threshhold for all years
;
restore,'/Volumes/Data/CIPS_data/Line_Plots/F_V4.20_r05_80Lat_2G_all_sh_plot_data.sav
; 
; PLOT_DAYS_ASC   INT       = Array[120, 7]
; PLOT_DAYS_DSC   INT       = Array[120, 7]
; PLOT_F_ASC      FLOAT     = Array[120, 7]
; PLOT_F_DSC      FLOAT     = Array[120, 7]
; SEASONS         STRING    = Array[7]
; SLAT            STRING    = '80'
;
; loop over years
;
cols=[6,7,8,9,10,11,12]
col1=cols
for iyear=2007,2014 do begin
    slat='-60.0000'
    yearlab=strcompress(iyear,/remove_all)
    restore,'omi_mino3_'+yearlab+'_'+slat+'.sav'	;,kday,mino3time,maxo3time,meano3time,minlattime,sdates
    if iyear eq 2007 then begin
       mino3time_all=mino3time
       maxo3time_all=maxo3time
       meano3time_all=meano3time
       minlattime_all=minlattime
       sdates_all=sdates
    endif
    if iyear gt 2007 then begin
       mino3time_all=[mino3time_all,mino3time]
       maxo3time_all=[maxo3time_all,maxo3time]
       meano3time_all=[meano3time_all,meano3time]
       minlattime_all=[minlattime_all,minlattime]
       sdates_all=[sdates_all,sdates]
    endif
endfor

nn=n_elements(sdates_all)
fdoy=fltarr(nn)
for i=0L,nn-1L do begin
    iyr=long(strmid(sdates_all(i),0,4))
    imn=long(strmid(sdates_all(i),4,2))
    idy=long(strmid(sdates_all(i),6,2))
    z = kgmt(imn,idy,iyr,iday)
    fdoy(i)=1.0*iday
endfor

if setplot eq 'ps' then begin
   lc=0
   xsize=nxdim/100.
   ysize=nydim/100.
   set_plot,'ps'
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='omi+cips_allyears_'+slat+'.ps'
   !p.charsize=1.2
   !p.thick=2
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif

erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
plot,[0,0],[0,0],/nodata,xrange=[-50,50],xtitle='DFS',color=0,yrange=[0,100],ytitle='CIPS PMC Frequency 80S 2G'
for i=2007,2013 do begin
    isea=i-2007
    ddd=reform(PLOT_DAYS_ASC(*,isea))
    array=reform(PLOT_F_ASC(*,isea))
    index=where(ddd ne 0)
    ddd=ddd(index)
    array=array(index)
    oplot,ddd,array,thick=12,color=cols(isea)
endfor

; PLOT_DAYS_ASC   INT       = Array[120, 7]
; PLOT_DAYS_DSC   INT       = Array[120, 7]
; PLOT_F_ASC      FLOAT     = Array[120, 7]
; PLOT_F_DSC      FLOAT     = Array[120, 7]
; SEASONS         STRING    = Array[7]
; SLAT            STRING    = '80'

xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
xlabs=['07','08','09','10','11','12','01','02','03','04','05','06']
nxticks=n_elements(xlabs)
index=where(mino3time eq 0.)
if index(0) ne -1L then mino3time(index)=0./0.
index=where(maxo3time eq 0.)
if index(0) ne -1L then maxo3time(index)=0./0.
index=where(meano3time eq 0.)
if index(0) ne -1L then meano3time(index)=0./0.
index=where(minlattime ge 0.)
if index(0) ne -1L then minlattime(index)=0./0.

plot,[0,0],/nodata,xrange=[-50,50],xtitle='DFS',color=0,yrange=[150,300],/noeras,ytitle='OMI Min Column Ozone at 60S'

hem='SH'
yearlab_all=strarr(2013-2007+1)
for iyear=2007,2013 do begin
iyr=long(strmid(sdates_all,0,4))
index=where((iyr eq iyear and fdoy ge 182.) or (iyr eq iyear+1L and fdoy lt 182.))
iyr0=iyr(index)
fdoy0=fdoy(index)
mino3time0=mino3time_all(index)
meano3time0=meano3time_all(index)

DFS=lonarr(n_elements(iyr0))
sdate=sdates_all(index)
if hem eq 'SH' then jdaysol=JULDAY(12,21,long(strmid(sdate(0),0,4)))
if hem eq 'NH' then jdaysol=JULDAY(6,21,long(strmid(sdate(0),0,4)))
for i=0L,n_elements(iyr0)-1L do begin
    iyr=long(strmid(sdate(i),0,4))
    imn=long(strmid(sdate(i),4,2))
    idy=long(strmid(sdate(i),6,2))
    dfs(i)=JULDAY(imn,idy,iyr)-jdaysol
endfor

yearlab=strmid(strcompress(iyear,/remove_all),2,2)+'/'+strmid(strcompress(iyear+1L,/remove_all),2,2)
yearlab_all(iyear-2007)=yearlab

;oplot,findgen(kday),smooth(meano3time,7,/NaN),thick=5,color=col1(iyear-2007)
oplot,dfs,smooth(mino3time0,9,/NaN,/edge_truncate),thick=12,color=col1(iyear-2007)
;oplot,dfs,smooth(meano3time0,9,/NaN,/edge_truncate),thick=12,color=col1(iyear-2007),linestyle=5
;oplot,findgen(kday),smooth(maxo3time,7,/NaN),thick=3,color=col1(iyear-2007)
endfor

;loadct,0
;axis,yrange=[-90,-30],yaxis=1,/save,ytitle='Minimum Latitude',color=150
;oplot,findgen(kday),smooth(minlattime,7,/NaN),thick=3,color=150
;loadct,39

!type=2^2+2^3+2^6
set_viewport,xmn,max(xorig)+xlen,ymn-cbaryoff,ymn-cbaryoff+cbarydel
imin=2007
imax=2014
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,xstyle=1,charsize=1.2,color=0,charthick=2,xtickname=yearlab_all,xticks=n_elements(yearlab_all)-1L
ybox=[0,10,10,0,0]
x1=imin
nlvls=n_elements(col1)
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
  xbox=[x1,x1,x1+dx,x1+dx,x1]
  polyfill,xbox,ybox,color=col1(j)
  x1=x1+dx
endfor
;
;
; Close PostScript file and return control to X-windows
;
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim omi+cips_allyears_'+slat+'.ps -rotate -90 omi+cips_allyears_'+slat+'.ps'
;  spawn,'rm -f omi+cips_allyears_'+slat+'.ps'
endif

end
