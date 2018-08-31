;
; choose altitude to plot latitude-annual cycle plots
;
; average individual monthly averages to get multi-year monthly averages
; plot annual cycle from 30-pole to compare to occultation plot
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
nxdim=700
nydim=700
yorig=[0.5,0.5,0.5,0.125,0.125,0.125]
xorig=[0.1,0.4,0.7,0.1,0.4,0.7]
ylen=0.3
xlen=0.25
cbaryoff=0.06
cbarydel=0.02
xlabels=['J','F','M','A','M','J','J','A','S','O','N','D']
if setplot ne 'ps' then begin
   lc=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
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
           nth=n_elements(th)
           x2d=0.*vortex_o3_avg
           y2d=0.*vortex_o3_avg
           for ii=0,nlat-1 do y2d(ii,*)=th
           for j=0,nth-1 do x2d(*,j)=ybin
;
; annual cycle arrays
;
           if imonth eq 0L then begin
           out_annual_yt=fltarr(nmonth,nlat)
           out_annual_num_yt=fltarr(nmonth,nlat)
           high_annual_yt=fltarr(nmonth,nlat)
           high_annual_num_yt=fltarr(nmonth,nlat)
           vortex_annual_yt=fltarr(nmonth,nlat)
           vortex_annual_num_yt=fltarr(nmonth,nlat)
;
; choose altitude to plot
;
           rlev=0.
           print,th
           read,'Enter theta level ',rlev
           index=where(th eq rlev)
           ilev=index(0)
           slev=strcompress(string(fix(rlev)),/remove_all)
           endif
        endif
        index=where(high_o3_avg gt 0.)
        if index(0) ne -1L then begin
        HIGH_O3_AVG_ALL(index)=HIGH_O3_AVG_ALL(index)+high_o3_avg(index)*float(high_o3_num(index))
        HIGH_O3_NUM_ALL(index)=HIGH_O3_NUM_ALL(index)+high_o3_num(index)
        HIGH_O3_SIG_ALL(index)=HIGH_O3_SIG_ALL(index)+high_o3_sig(index)*float(high_o3_num(index))
        endif
        index=where(out_O3_avg gt 0.)
        if index(0) ne -1L then begin
        OUT_O3_AVG_ALL(index)=OUT_O3_AVG_ALL(index)+out_o3_avg(index)*float(out_o3_num(index))
        OUT_O3_NUM_ALL(index)=OUT_O3_NUM_ALL(index)+out_o3_num(index)
        OUT_O3_SIG_ALL(index)=OUT_O3_SIG_ALL(index)+out_o3_sig*float(out_o3_num(index))
        endif
        index=where(vortex_O3_avg gt 0.)
        if index(0) ne -1L then begin
        VORTEX_O3_AVG_ALL(index)=VORTEX_O3_AVG_ALL(index)+vortex_o3_avg(index)*float(vortex_o3_num(index))
        VORTEX_O3_NUM_ALL(index)=VORTEX_O3_NUM_ALL(index)+vortex_o3_num(index)
        VORTEX_O3_SIG_ALL(index)=VORTEX_O3_SIG_ALL(index)+vortex_o3_sig(index)*float(vortex_o3_num(index))
        endif
    endfor
;
; multi-year monthly averages
;
    index=where(HIGH_O3_AVG_ALL gt 0.)
    HIGH_O3_AVG_ALL(index)=HIGH_O3_AVG_ALL(index)/HIGH_O3_NUM_ALL(index)
    HIGH_O3_SIG_ALL(index)=HIGH_O3_SIG_ALL(index)/HIGH_O3_NUM_ALL(index)
    index=where(OUT_O3_AVG_ALL gt 0.)
    OUT_O3_AVG_ALL(index)=OUT_O3_AVG_ALL(index)/OUT_O3_NUM_ALL(index)
    OUT_O3_SIG_ALL(index)=OUT_O3_SIG_ALL(index)/OUT_O3_NUM_ALL(index)
    index=where(VORTEX_O3_AVG_ALL gt 0.)
    VORTEX_O3_AVG_ALL(index)=VORTEX_O3_AVG_ALL(index)/VORTEX_O3_NUM_ALL(index)
    VORTEX_O3_SIG_ALL(index)=VORTEX_O3_SIG_ALL(index)/VORTEX_O3_NUM_ALL(index)
;
; assign latitude-time arrays
;
    odum=reform(out_O3_AVG_ALL(*,ilev))
    nodum=reform(out_O3_num_ALL(*,ilev))
    if index(0) ne -1 then out_annual_yt(imonth,*)=out_O3_AVG_ALL(*,ilev)
    if index(0) ne -1 then out_annual_num_yt(imonth,*)=out_O3_num_ALL(*,ilev)
    hdum=reform(high_O3_AVG_ALL(*,ilev))
    nhdum=reform(high_O3_num_ALL(*,ilev))
    if index(0) ne -1 then high_annual_yt(imonth,*)=high_O3_AVG_ALL(*,ilev)
    if index(0) ne -1 then high_annual_num_yt(imonth,*)=high_O3_num_ALL(*,ilev)
    dum=reform(vortex_O3_AVG_ALL(*,ilev))
    ndum=reform(vortex_O3_num_ALL(*,ilev))
    if index(0) ne -1 then vortex_annual_yt(imonth,*)=vortex_O3_AVG_ALL(*,ilev)
    if index(0) ne -1 then vortex_annual_num_yt(imonth,*)=vortex_O3_num_ALL(*,ilev)
endfor		; loop over months
if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/portrait,bits=8,filename='mls_yt_o3_airmass_'+slev+'K.ps'
   device,/color
   device,/inch,xoff=0.05,yoff=.1,xsize=xsize,ysize=ysize
endif
erase
!type=2^2+2^3
xyouts,.4,.9,'UARS MLS '+slev+' K',/normal,charsize=3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=findgen(11)
nlev=n_elements(level)
col1=1+indgen(nlev)*mcolor/nlev
contour,out_annual_yt,findgen(nmonth),ybin,/noeras,title='Ambient',$
     ytitle='Latitude',xrange=[0.,nmonth-1],yrange=[-90.,90.],xtickname=xlabels,$
     max_value=9999.,/cell_fill,c_color=col1,xticks=nmonth-1,levels=level,$
     xticklen=-0.02,yticks=6,charsize=1.25
contour,out_annual_yt,findgen(nmonth),ybin,/noeras,/follow,levels=level,$
        c_labels=1+0*level,max_value=9999.,/overplot,color=0

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
index=where(high_annual_yt eq 0.)
high_annual_yt(index)=-9999.
contour,high_annual_yt,findgen(nmonth),ybin,/noeras,$
     ytitle=' ',xrange=[0.,nmonth-1],yrange=[-90.,90.],xtickname=xlabels,$
     min_value=-9999.,/cell_fill,c_color=col1,xticks=nmonth-1,levels=level,$
     xticklen=-0.02,yticks=6,title='Anticyclones',charsize=1.25
contour,high_annual_yt,findgen(nmonth),ybin,/noeras,/follow,levels=level,$
        c_labels=1+0*level,max_value=9999.,/overplot,color=0

!type=2^2+2^3
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=-2.0+.2*findgen(21)
nlev=n_elements(level)
col1=1+indgen(nlev)*mcolor/nlev
diff=high_annual_yt-out_annual_yt
index=where(high_annual_yt lt 0.)
diff(index)=-9999.
contour,diff,findgen(nmonth),ybin,/noeras,$
     ytitle=' ',xrange=[0.,nmonth-1],yrange=[-90.,90.],xtickname=xlabels,$
     min_value=-9999.,/cell_fill,c_color=col1,xticks=nmonth-1,levels=level,$
     xticklen=-0.02,yticks=6,title='Anticyclones-Ambient',charsize=1.25
index=where(level lt 0.)
contour,diff,findgen(nmonth),ybin,/noeras,/follow,levels=level(index),$
        c_labels=0*level(index),min_value=-9999.,/overplot,color=mcolor,charsize=2
index=where(level gt 0.)
contour,diff,findgen(nmonth),ybin,/noeras,/follow,levels=level(index),$
        c_labels=0*level(index),min_value=-9999.,/overplot,color=0,charsize=2
contour,diff,findgen(nmonth),ybin,/noeras,/follow,levels=[0],c_labels=[0],$
        min_value=-9999.,/overplot,color=0,thick=3

!type=2^2+2^3
xmn=xorig(3)
xmx=xorig(3)+xlen
ymn=yorig(3)
ymx=yorig(3)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=findgen(11)
nlev=n_elements(level)
col1=1+indgen(nlev)*mcolor/nlev
contour,out_annual_yt,findgen(nmonth),ybin,/noeras,title='Ambient',$
     ytitle='Latitude',xrange=[0.,nmonth-1],yrange=[-90.,90.],xtickname=xlabels,$
     max_value=9999.,/cell_fill,c_color=col1,xticks=nmonth-1,levels=level,$
     xticklen=-0.02,yticks=6,charsize=1.25
contour,out_annual_yt,findgen(nmonth),ybin,/noeras,/follow,levels=level,$
        c_labels=1+0*level,max_value=9999.,/overplot,color=0
imin=min(level)
imax=max(level)
ymnb=ymn -cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xorig(3),xorig(3)+xlen,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xtitle='Ozone (ppmv)',$
    xrange=[imin,imax],/noeras,charsize=1.25
ybox=[0,10,10,0,0]
x2=imin
dx=(imax-imin)/float(nlev)
for j=0,nlev-1 do begin
    xbox=[x2,x2,x2+dx,x2+dx,x2]
    polyfill,xbox,ybox,color=col1(j)
    x2=x2+dx
endfor

!type=2^2+2^3
xmn=xorig(4)
xmx=xorig(4)+xlen
ymn=yorig(4)
ymx=yorig(4)+ylen
set_viewport,xmn,xmx,ymn,ymx
index=where(vortex_annual_yt eq 0.)
vortex_annual_yt(index)=-9999.
contour,vortex_annual_yt,findgen(nmonth),ybin,/noeras,$
     ytitle=' ',xrange=[0.,nmonth-1],yrange=[-90.,90.],xtickname=xlabels,$
     min_value=-9999.,/cell_fill,c_color=col1,xticks=nmonth-1,levels=level,$
     xticklen=-0.02,yticks=6,title='Vortex',charsize=1.25
contour,vortex_annual_yt,findgen(nmonth),ybin,/noeras,/follow,levels=level,$
        c_labels=1+0*level,max_value=9999.,/overplot,color=0
imin=min(level)
imax=max(level)
ymnb=ymn -cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xorig(4),xorig(4)+xlen,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xtitle='Ozone (ppmv)',$
    xrange=[imin,imax],/noeras,charsize=1.25
ybox=[0,10,10,0,0]
x2=imin
dx=(imax-imin)/float(nlev)
for j=0,nlev-1 do begin
    xbox=[x2,x2,x2+dx,x2+dx,x2]
    polyfill,xbox,ybox,color=col1(j)
    x2=x2+dx
endfor

!type=2^2+2^3
xmn=xorig(5)
xmx=xorig(5)+xlen
ymn=yorig(5)
ymx=yorig(5)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=-2.0+.2*findgen(21)
nlev=n_elements(level)
col1=1+indgen(nlev)*mcolor/nlev
diff=vortex_annual_yt-out_annual_yt
index=where(vortex_annual_yt lt 0.)
diff(index)=-9999.
contour,diff,findgen(nmonth),ybin,/noeras,$
     ytitle=' ',xrange=[0.,nmonth-1],yrange=[-90.,90.],xtickname=xlabels,$
     min_value=-9999.,/cell_fill,c_color=col1,xticks=nmonth-1,levels=level,$
     xticklen=-0.02,yticks=6,title='Vortex-Ambient',charsize=1.25
index=where(level lt 0.)
contour,diff,findgen(nmonth),ybin,/noeras,/follow,levels=level(index),$
        c_labels=0*level(index),min_value=-9999.,/overplot,color=mcolor,charsize=2
index=where(level gt 0.)
contour,diff,findgen(nmonth),ybin,/noeras,/follow,levels=level(index),$
        c_labels=0*level(index),min_value=-9999.,/overplot,color=0,charsize=2
contour,diff,findgen(nmonth),ybin,/noeras,/follow,levels=[0],c_labels=[0],$
        min_value=-9999.,/overplot,color=0,thick=3
imin=min(level)
imax=max(level)
ymnb=ymn -cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xorig(5),xorig(5)+xlen,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xtitle='Ozone Difference (ppmv)',$
    xrange=[imin,imax],/noeras,charsize=1.25
ybox=[0,10,10,0,0]
x2=imin
dx=(imax-imin)/float(nlev)
for j=0,nlev-1 do begin
    xbox=[x2,x2,x2+dx,x2+dx,x2]
    polyfill,xbox,ybox,color=col1(j)
    x2=x2+dx
endfor
if setplot eq 'ps' then device,/close
if setplot ne 'ps' then stop
end
