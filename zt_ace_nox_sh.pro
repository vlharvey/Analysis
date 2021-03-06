;
; Southern hemisphere
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
nxdim=600 & nydim=600
xorig=[0.15]
yorig=[0.25]
xlen=0.7
ylen=0.5
cbaryoff=0.08
cbarydel=0.02
!NOERAS=-1
!p.font=1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
dira='/aura3/data/ACE_data/Datfiles_SOSST/v2.2/'
syear=['2004','2005','2006']
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
    restore,dira+'dmps_meto_ace_v2.2.'+syear(iyear)
    restore,dira+'cat_ace_v2.2.'+syear(iyear)
    restore,dira+'no_ace_v2.2.'+syear(iyear)
    nomix=mix & nomask=mask
    restore,dira+'no2_ace_v2.2.'+syear(iyear)
    no2mix=mix & no2mask=mask
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
    ovelat_prof=reform(velat_prof(*,*,0))
    nday=long(max(fdoy))-long(min(fdoy))+1L
    nz=n_elements(altitude)
    onox=fltarr(nday,nz)
    num=lonarr(nday,nz)
    zz=where(altitude ge 40.)
    for iday=1L,nday do begin
        today=where(long(fdoy) eq iday and latitude lt 0.,nprof)	; Antarctic
        if nprof le 1L then goto,skipday
        noxday=reform(noxmix(today,*))
        elatday=reform(elat_prof(today,*))
        velatday=reform(ovelat_prof(today,*))
;print,'Today ',fdoy(today)
;print,'Lat ',latitude(today)

        for iprof=0L,nprof-1L do begin
            noxs=reform(noxday(iprof,*))
            elats=reform(elatday(iprof,*))
            velats=reform(velatday(iprof,*))
            index=where(elats ne -99. and velats ne -99.,npts)
;print,'Prof ',iprof,' ngood ',npts
;           if index(0) eq -1L then goto,jumpprof

            if latitude(today(iprof)) le -50. then begin

            for k=nz-1L,0L,-1L do begin	; loop from the bottom up
;               if elats(k) ne -99. and velats(k) ne -99. and $
;                  elats(k) ge velats(k) and noxs(k) ne 0. then begin
                if noxs(k) ne 0. then begin

;print,'profile alt ',altitude(k),noxs(k)
                   onox(iday-1L,k)=onox(iday-1L,k)+noxs(k)
                   num(iday-1L,k)=num(iday-1L,k)+1L
                endif
            endfor
            endif
;
; deal with mesosphere where there is no elat information
; assume the mesospheric profile is inside the vortex if it is inside above 40 km
;
;           noxs=reform(noxday(iprof,zz))
;           elats=reform(elatday(iprof,zz))
;           velats=reform(velatday(iprof,zz))
;           index=where(elats ne -99. and velats ne -99.,npts)
;           if index(0) eq -1L then goto,jumpprof
;           elat0=total(elats(index))/float(npts)
;           velat0=total(velats(index))/float(npts)
;           if elat0 ge velat0 then begin 	; in the upper stratospheric vortex 
;           if latitude(today(iprof)) le -50. then begin
;              index=where(elats eq -99. or velats ne -99.,npts)   ; loop over unresolved points

;              for kk=0L,npts-1L do begin
;                  k=index(kk)
;                  if altitude(k) ge 40. and velats(k) eq -99. and noxs(k) ne 0. then begin
;print,'top part ',altitude(k),noxs(k)
;                     onox(iday-1L,k)=onox(iday-1L,k)+noxs(k)
;                     num(iday-1L,k)=num(iday-1L,k)+1L
;                  endif
;              endfor
;           endif
            jumpprof:
        endfor
        skipday:
print,iday
    endfor
;
; daily average
;
    index=where(num gt 0L)
    if index(0) eq -1L then goto,jumpyear
    onox(index)=1.e9*onox(index)/float(num(index))
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
       onox_fill(index2,j)=filled
    endif
endfor
;onox=onox_fill
;
; smooth
;
smoothit,onox,onoxsmooth
onox=onoxsmooth

    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       device,font_size=9
       device,/landscape,bits=8,filename='zt_ace_nox_'+syear(iyear)+'_sh.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
    endif
    erase
    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    level=[1.,2.,5.,10.,15.,20.,30.,50.,75.,100.,150.,200.,$
           500.,1000.,2000.,5000.,10000.,20000.,50000.,100000.,200000.]
    print,min(fdoy),max(fdoy)
    kday=365.
    leapdy=(long(syear(iyear)) mod 4)
    kday=kday+leapdy
    contour,onox,1.+findgen(nday),altitude,/noeras,c_color=col1,/cell_fill,levels=level,$
         yrange=[30.,90.],xrange=[1.,kday],xticks=11,$
         xtickname=month,charsize=1.75,ytitle='Alitude (km)',color=0,$
         title=syear(iyear)+' ACE Antarctic NOx',min_value=0.
    contour,onox,1.+findgen(nday),altitude,/noeras,color=0,/follow,levels=level,/overplot,$
            c_labels=0*level,min_value=0.
    !type=2^2+2^3+2^5
    xmnb=xorig(0)+xlen+cbaryoff
    xmxb=xmnb+cbarydel
    set_viewport,xmnb,xmxb,ymn,ymx
    slab=strcompress(long(level),/remove_all)
    plot,[0,0],[min(level),max(level)],xrange=[0,10],color=0,$
         yticks=n_elements(level)-1L,ytickname=slab,$
         yrange=[min(level),max(level)],charsize=1.5,title='ppbv'
    xbox=[0,10,10,0,0]
    y1=min(level)
    dy=(max(level)-min(level))/float(nlvls)
    for j=0,nlvls-1 do begin
        ybox=[y1,y1,y1+dy,y1+dy,y1]
        polyfill,xbox,ybox,color=col1(j)
        y1=y1+dy
    endfor
    !type=2^2+2^3
    set_viewport,xorig(0),xorig(0)+xlen,0.1,0.2
    plot,fdoy,latitude,psym=1,color=0,yrange=[-90.,-30.],xrange=[1.,365.],xticks=11,$
         xtickname=' '+strarr(12),charsize=1.75,ytitle='Latitude',yticks=2,$
         ytickv=[-30.,-60.,-90.],symsize=0.5

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim zt_ace_nox_'+syear(iyear)+'_sh.ps -rotate -90 zt_ace_nox_'+syear(iyear)+'_sh.jpg'
    endif
    jumpyear:
endfor	; loop over years
end
