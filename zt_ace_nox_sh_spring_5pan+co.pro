;
; SH version
; spring time period only
; plot time-altitude section of vortex NOx
;
@fillit
@smoothit

loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,0.3*cos(a),0.3*sin(a),/fill
setplot='x'
read,'setplot=',setplot
mcolor=icolmax
icmm1=icolmax-1
icmm2=icolmax-2
nxdim=800 & nydim=800
xorig=[0.25,0.25,0.25,0.25,0.25]
yorig=[0.7,0.55,0.4,0.25,0.1]+0.1
xlen=0.5
ylen=0.1
cbaryoff=0.08
cbarydel=0.04
!NOERAS=-1
!p.font=1
!x.ticklen=-0.05
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   device,font_size=9
   device,/landscape,bits=8,filename='zt_ace_nox_sh_spring_5pan+co.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
endif
erase
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
dira='/aura3/data/ACE_data/Datfiles_SOSST/v2.2/'
syear=['2004','2005','2006','2007','2008']
nyear=n_elements(syear)
nlvls=21L
col1=1L+indgen(nlvls)*mcolor/float(nlvls)
;
; loop over years
;
for iyear=0L,nyear-1L do begin
;
; restore ACE SOSST data
;
    ex=findfile(dira+'cat_ace_v2.2.'+syear(iyear))
    if ex(0) eq '' then goto,jumpyear
    restore,dira+'dmps_ace_v2.2.meto.'+syear(iyear)
    dmpdate=date
    restore,dira+'cat_ace_v2.2.'+syear(iyear)
    restore,dira+'no_ace_v2.2.'+syear(iyear)
    nomix=mix & nomask=mask
    restore,dira+'no2_ace_v2.2.'+syear(iyear)
    no2mix=mix & no2mask=mask
    help,no2mix,dmpdate
altitude_save=altitude
;
; NOx is NO + NO2 and take only good values
;
    noxmix=0.*nomix
    index=where(nomask ne -99. and no2mask ne -99.)	; both good
    noxmix(index)=nomix(index)+no2mix(index)
    index=where(nomask ne -99. and no2mask eq -99.)	; only NO good
    noxmix(index)=nomix(index)
    index=where(nomask eq -99. and no2mask ne -99.)	; only NO2 good
    noxmix(index)=no2mix(index)
;
; daily average NOx in the vortex
;
    nday=long(max(fdoy))-long(min(fdoy))+1L
    nday=365.
    nz=n_elements(altitude)
    onox=fltarr(nday,nz)
    olat=fltarr(nday,nz)
    num=lonarr(nday,nz)
    for iday=1L,nday do begin
        today=where(long(fdoy) eq iday and latitude lt 0.,nprof)	; Antarctic
        if nprof le 1L then goto,skipday
        noxday=reform(noxmix(today,*))
        for iprof=0L,nprof-1L do begin
            noxs=reform(noxday(iprof,*))
            if latitude(today(iprof)) le -50. then begin
            for k=nz-1L,0L,-1L do begin	; loop from the bottom up
                if noxs(k) ne 0. then begin
                   onox(iday-1L,k)=onox(iday-1L,k)+noxs(k)
                   olat(iday-1L,k)=olat(iday-1L,k)+latitude(today(iprof))
                   num(iday-1L,k)=num(iday-1L,k)+1L
                endif
            endfor
            endif
            jumpprof:
        endfor
        skipday:
    endfor
;
; daily average
;
    index=where(num gt 0L)
    if index(0) eq -1L then goto,jumpyear
    onox(index)=1.e6*onox(index)/float(num(index))
    olat(index)=olat(index)/float(num(index))
    oday=0.*olat
    for k=0L,nz-1L do oday(*,k)=1.+findgen(nday)
;
; fill
;
    onox_fill=onox
    for j=0,nz-1 do begin
        dummy=reform(onox(*,j))
        index1=where(dummy gt 0.,ngood)
        index2=where(dummy le 0.,nbad)
        if ngood gt 1L and nbad gt 1L then begin
           filled=interpol(dummy(index1),index1,index2)
;          onox_fill(index2,j)=filled
        endif
    endfor
;   if syear(iyear) eq '2004' then begin
;      onox_fill(0:35,*)=0.      ; do not extrapolate data voids 
;      index=where(fdoy lt 30.)
;      latitude(index)=0.
;   endif
    onox=onox_fill
;
; smooth
;
    smoothit,onox,onoxsmooth
    onox=onoxsmooth
;index=where(olat gt -50. and (oday lt 51. or oday gt 81.))
;onox(index)=-9999.
;
; store save file
;
    save,file='vortex_nox_sh_'+syear(iyear)+'.sav',nday,fdoy,altitude,latitude,onox
    restore,'vortex_co_'+syear(iyear)+'_sh.sav'    ;,nday,fdoy,altitude,latitude,oco
    smoothit,oco,ocosmooth
    oco=ocosmooth
;
; postscript file
;
    !type=2^2+2^3
    xmn=xorig(iyear)
    xmx=xorig(iyear)+xlen
    ymn=yorig(iyear)
    ymx=yorig(iyear)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    level=[1.,2.,5.,10.,15.,20.,30.,50.,75.,100.,150.,200.,$
           500.,1000.,2000.,5000.,10000.,20000.,50000.,100000.,200000.]/1000.
    print,min(fdoy),max(fdoy)
    kday=365.
    leapdy=(long(syear(iyear)) mod 4)
    kday=kday+leapdy
;kday=long(max(fdoy))	; uncomment to "zoom" in on partial year
kday0=121
kday1=274
    xlab=[' ',' ',' ',' ',' ',' ']
    contour,onox,1.+findgen(nday),altitude_save,/noeras,c_color=col1,/cell_fill,levels=level,$
         yrange=[30.,90.],xrange=[kday0,kday1],xticks=n_elements(xlab)-1L,xtickname=xlab,$
         charsize=2,ytitle='Altitude (km)',color=0,min_value=0.
    contour,onox,1.+findgen(nday),altitude_save,/noeras,color=0,/follow,levels=level,/overplot,$
            c_labels=0*level,min_value=0.

    colevel=[0.5,5.]
    contour,oco,1.+findgen(nday),altitude,/noeras,color=mcolor,/follow,levels=colevel,/overplot,$
            c_labels=1L+0*colevel,min_value=0.,thick=6,c_charthick=4,c_charsize=2

    xyouts,kday0+5.,35.,syear(iyear),/data,color=0,charsize=3
    set_viewport,xorig(iyear),xorig(iyear)+xlen,ymn-0.05,ymn-0.005
    index=where(fdoy ge kday0 and fdoy le kday1)
    plot,fdoy(index),latitude(index),psym=1,color=0,yrange=[-90.,-30.],xrange=[kday0,kday1],xticks=n_elements(xlab)-1L,$
         xtickname=xlab,charsize=2,ytitle='Lat',yticks=2,$
         ytickv=[-30.,-60.,-90.],symsize=0.5
    if iyear eq nyear-1L then begin
    xyouts,135.,-110.,'May',/data,color=0,charsize=2,alignment=0.5
    xyouts,166.,-110.,'Jun',/data,color=0,charsize=2,alignment=0.5
    xyouts,196.,-110.,'Jul',/data,color=0,charsize=2,alignment=0.5
    xyouts,227.,-110.,'Aug',/data,color=0,charsize=2,alignment=0.5
    xyouts,258.,-110.,'Sep',/data,color=0,charsize=2,alignment=0.5
    endif
    jumpyear:
endfor  ; loop over years
!type=2^2+2^3+2^5
xmnb=xorig(3)+xlen+cbaryoff
xmxb=xmnb+cbarydel
ymnb=min(yorig)
ymxb=max(yorig)
set_viewport,xmnb,xmxb,ymnb,ymxb
slab=' '+strarr(n_elements(level))
plot,[0,0],[min(level),max(level)],xrange=[0,10],color=0,$
     yticks=n_elements(level)-1L,ytickname=slab,$
     yrange=[min(level),max(level)],charsize=1.5,title='NO!lx!n (ppmv)',charthick=2
xbox=[0,10,10,0,0]
y1=min(level)
dy=(max(level)-min(level))/float(nlvls)
for j=0,nlvls-1 do begin
    ybox=[y1,y1,y1+dy,y1+dy,y1]
    polyfill,xbox,ybox,color=col1(j)
    y1=y1+dy
endfor
slab=strcompress(string(format='(f7.3)',level),/remove_all)
y1=min(level)+dy/2
for i=0L,n_elements(slab)-1L do begin
    slab0=slab(i)
    flab0=float(slab(i))
    if flab0 lt 0.01 then slab0=strcompress(string(format='(f5.3)',flab0),/remove_all)
    if flab0 lt 1. and flab0 ge 0.01 then slab0=strcompress(string(format='(f4.2)',flab0),/remove_all)
    if flab0 ge 1. then slab0=strcompress(long(slab0),/remove_all)
    xyouts,xorig(3)+xlen+0.02,y1,slab0,charsize=1.1,/data,color=0,charthick=2
    y1=y1+dy
endfor

if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim zt_ace_nox_sh_spring_5pan+co.ps -rotate -90 zt_ace_nox_sh_spring_5pan+co.jpg'
endif
end
