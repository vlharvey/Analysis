;
; altitude-time of ubar60 and dtdy
; user enters desired date range
;
loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax
mon=['Jan','Feb','Mar','Apr','May','Jun',$
     'Jul','Aug','Sep','Oct','Nov','Dec']
!NOERAS=-1
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.175,0.175]
yorig=[0.6,0.15]
xlen=0.7
ylen=0.35
cbaryoff=0.08
cbarydel=0.02
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
;
; restore save file
;
restore,file='MetO_dTdy_Ubar_SSW_Climo.sav'	;,yyyymmdd,th,nh_dtdy,sh_dtdy,nh_ubar60,sh_ubar60,comment
nlv=n_elements(th)
;
; quick bug fix. why is there one date of 200000?
;
index=where(yyyymmdd lt 19000000)
if index(0) ne -1L then yyyymmdd(index)=yyyymmdd(index-1)
;
; enter desired date range
;
print,min(yyyymmdd),max(yyyymmdd)
date0=20090101
date1=20090401
;date0=20080101
;date1=20080401
;read,'Enter beginning date ',date0
;read,'Enter ending date ',date1
index=where(yyyymmdd ge date0 and yyyymmdd le date1,nday)
kday=nday
NH_UBAR60_date=reform(NH_UBAR60(index,*))
NH_dtdy_date=reform(NH_dtdy(index,*))
syyyymmdd=strcompress(yyyymmdd(index),/remove_all)

index=where(NH_UBAR60_date eq 0.)
if index(0) ne -1L then NH_UBAR60_date(index)=0./0.
index=where(NH_dtdy_date eq 0.)
if index(0) ne -1L then NH_dtdy_date(index)=0./0.
;
; date labels
;
syear=strmid(syyyymmdd,0,4)
smon=strmid(syyyymmdd,4,2)
sday=strmid(syyyymmdd,6,2)
daterange=syyyymmdd(0)+'-'+syyyymmdd(nday-1)
minyear=long(min(long(syear)))
maxyear=long(max(long(syear)))
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
xindex=where(sday eq '01',nxticks)
if minyear eq maxyear then xindex=where(sday eq '01' or sday eq '15',nxticks)
xlabs=smon(xindex)+'/'+sday(xindex)
;
; postscript file and plot
;
if setplot eq 'ps' then begin
   xsize=nxdim/100.
   ysize=nydim/100.
   set_plot,'ps'
   !p.font=0
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='plot_dtdy_ubar_ssw_meto_zt_'+daterange+'.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
;
; interpolate small gaps in time
;
for k=0,nlv-1 do begin
    dlev=reform(NH_ubar60_date(*,k))
    for i=1,kday-1 do begin
        if finite(dlev(i)) eq 0. and finite(dlev(i-1)) ne 0. then begin
           for ii=i+1,kday-1 do begin
               naway=float(ii-i)
               if naway le 5.0 and finite(dlev(ii)) ne 0. then begin
                  dlev(i)=(naway*dlev(i-1)+dlev(ii))/(naway+1.0)
                  goto,jump1
               endif
           endfor
jump1:
        endif
    endfor
    NH_ubar60_date(*,k)=dlev

    dlev=reform(NH_dtdy_date(*,k))
    for i=1,kday-1 do begin
        if finite(dlev(i)) eq 0. and finite(dlev(i-1)) ne 0. then begin
           for ii=i+1,kday-1 do begin
               naway=float(ii-i)
               if naway le 5.0 and finite(dlev(ii)) ne 0. then begin
                  dlev(i)=(naway*dlev(i-1)+dlev(ii))/(naway+1.0)
                  goto,jump2
               endif
           endfor
jump2:
        endif
    endfor
    NH_dtdy_date(*,k)=dlev
endfor

erase
!type=2^2+2^3
nlvls=15
col1=1+indgen(nlvls)*mcolor/(nlvls)
umin=-50. & umax=80.
level=umin+10.*findgen(nlvls)
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
contour,NH_ubar60_date,1.+findgen(nday),th,/noeras,/cell_fill,c_color=col1,levels=level,ytitle='Potential Temperature (K)',$
        title='Zonal Mean Zonal Wind at 60!uo!n N',color=0,yrange=[300.,max(th)],$
        xticks=nxticks-1,xtickname=xlabs,xtickv=xindex
index=where(level gt 0.)
contour,NH_ubar60_date,1.+findgen(nday),th,/noeras,/follow,c_color=0,levels=level(index),/overplot
index=where(level lt 0.)
contour,NH_ubar60_date,1.+findgen(nday),th,/noeras,/follow,c_color=icolmax,c_linestyle=5,levels=level(index),/overplot
contour,NH_ubar60_date,1.+findgen(nday),th,/noeras,/follow,c_color=0,levels=[0],/overplot,thick=4
xyouts,xmn+0.02,ymn+0.02,yearlab,/normal,color=0,charsize=3,charthick=3
omin=min(level)
omax=max(level)
xmnb=max(xorig)+xlen+0.05
xmxb=xmnb+cbarydel
set_viewport,xmnb,xmxb,yorig(0),yorig(0)+ylen
!type=2^2+2^3+2^5+2^6
plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],color=mcolor
xbox=[0,10,10,0,0]
y1=omin
dy=(omax-omin)/float(nlvls)
for j=0,nlvls-1 do begin
    ybox=[y1,y1,y1+dy,y1+dy,y1]
    polyfill,xbox,ybox,color=col1(j)
    y1=y1+dy
endfor
!type=2^2+2^3+2^5
xyouts,xmxb+0.035,yorig(0)+ylen/3.0,'m/s',/normal,charsize=1.5,orientation=90.,color=0
plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],color=0	;,yticks=nlvls-1,ytickname=strcompress(long(level))

nlvls=11
col1=1+indgen(nlvls)*mcolor/(nlvls)
tmin=-60.
level=tmin+10.*findgen(nlvls)
!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
contour,NH_dtdy_date,1.+findgen(nday),th,/noeras,/cell_fill,c_color=col1,levels=level,ytitle='Potential Temperature (K)',$
        title='Temperature at NP - 60!uo!n N',color=0,yrange=[300.,max(th)],$
        xticks=nxticks-1,xtickname=xlabs,xtickv=xindex
index=where(level gt 0.)
contour,NH_dtdy_date,1.+findgen(nday),th,/noeras,/follow,c_color=0,levels=level(index),/overplot
index=where(level lt 0.)
contour,NH_dtdy_date,1.+findgen(nday),th,/noeras,/follow,c_color=icolmax,c_linestyle=5,levels=level(index),/overplot
contour,NH_dtdy_date,1.+findgen(nday),th,/noeras,/follow,c_color=0,levels=[0],/overplot,thick=4
xyouts,xmn+0.02,ymn+0.02,yearlab,/normal,color=0,charsize=3,charthick=3
omin=min(level)
omax=max(level)
xmnb=max(xorig)+xlen+0.05
xmxb=xmnb+cbarydel
set_viewport,xmnb,xmxb,yorig(1),yorig(1)+ylen
!type=2^2+2^3+2^5+2^6
plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],color=mcolor
xbox=[0,10,10,0,0]
y1=omin
dy=(omax-omin)/float(nlvls)
for j=0,nlvls-1 do begin
    ybox=[y1,y1,y1+dy,y1+dy,y1]
    polyfill,xbox,ybox,color=col1(j)
    y1=y1+dy
endfor
!type=2^2+2^3+2^5
xyouts,xmxb+0.035,yorig(1)+ylen/3.0,'K',/normal,charsize=1.5,orientation=90.,color=0
plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],color=0 ;,yticks=nlvls-1,ytickname=strcompress(long(level))
;
; Close PostScript file and return control to X-windows

     if setplot ne 'ps' then stop
     if setplot eq 'ps' then begin
        device, /close
        spawn,'convert -trim plot_dtdy_ubar_ssw_meto_zt_'+daterange+'.ps -rotate -90 '+$
                            'plot_dtdy_ubar_ssw_meto_zt_'+daterange+'.jpg'
;       spawn,'/usr/bin/rm plot_dtdy_ubar_ssw_meto_zt_'+daterange+'.ps'
     endif
end
