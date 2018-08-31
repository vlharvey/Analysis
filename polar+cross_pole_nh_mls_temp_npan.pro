;
; add MLS CO and temp
; plot polar projections and yz cross polar sections

@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto
@compvort
@drawvectors

sver='v3.3'

a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill

loadct,39
icolmax=byte(!p.color)
mcolor=icolmax
icmm1=icolmax-1B
icmm2=icolmax-2B
device,decompose=0
!NOERAS=-1
SETPLOT='ps'
read,'setplot',setplot
npp=16
delta='n'
gcm_panels,npp,delta,nxdim,nydim,xorig,yorig,xlen,ylen,cbaryoff,cbarydel
cbarydel=0.01
xlen=0.15
xorig=xorig+0.05
yorig=yorig+0.05
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dirm='/Volumes/earth/aura6/data/MLS_data/Datfiles_SOSST/'

lstmn=1
lstdy=21
lstyr=2012
ledmn=2
leddy=11
ledyr=2012
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; --- Test for end condition and close windows.
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' normal termination condition '
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
      print,sdate
;
; read MLS temperature and CO
;
    dum=findfile(dirm+'cat_mls_'+sver+'_'+sdate+'.sav')
    if dum(0) eq '' then goto,jumpday
    restore,dirm+'cat_mls_'+sver+'_'+sdate+'.sav'             ; altitude
    restore,dirm+'tpd_mls_'+sver+'_'+sdate+'.sav'             ; temperature, pressure
    restore,dirm+'co_mls_'+sver+'_'+sdate+'.sav'              ; mix
    nz=n_elements(altitude)
    nthlev=n_elements(thlev)
    mprof=n_elements(longitude)
    mlev=n_elements(altitude)
    muttime=time
    mlat=latitude
    mlon=longitude
    bad=where(mask eq -99.)
    if bad(0) ne -1L then mix(bad)=-99.
    good=where(mix ne -99.)
    if good(0) eq -1L then goto,jump
    mco=mix*1.e6
    mtemp=temperature
    mpress=pressure
;
; eliminate bad uttimes and SH
;
    index=where(muttime gt 0. and mlat gt 20.,mprof)
    if index(0) eq -1L then goto,jump
    muttime=reform(muttime(index))
    mlat=reform(mlat(index))
    mlon=reform(mlon(index))
    mtemp=reform(mtemp(index,*))
    mpress=reform(mpress(index,*))
    mco=reform(mco(index,*))
    mtheta=mtemp*(1000./mpress)^0.286
    index=where(mtemp lt 0.)
    if index(0) ne -1L then mtheta(index)=-99.
;
; postscript file
;
ilev=80
slev=strcompress(ilev,/remove_all)

    if setplot eq 'ps' then begin
       lc=0
       xsize=nxdim/100.
       ysize=nydim/100.
       set_plot,'ps'
       !p.font=0
       device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
              /bold,/color,bits_per_pixel=8,/helvetica,filename='polar+cross_pole_nh_mlsco+temp_'+sdate+'_'+slev+'km.ps'
       !p.charsize=1.25
       !p.thick=2
       !p.charthick=2
       !p.charthick=2
       !y.thick=2
       !x.thick=2
    endif
;
; determine number of NH swaths and print time of swaths on polar plot
;
    index=where(mlat ge 81.7,npt)
    tswath=muttime(index)
    flag=0.*tswath
    nswath=50L
    tsave=fltarr(nswath)
    mcount=0L
    for i=0L,npt-1L do begin
        index=where(abs(tswath(i)-tswath) lt 1. and flag eq 0.)
        if index(0) ne -1L then begin
           flag(index)=1.0
           kindex=where(abs(muttime-tswath(index(0))) le 0.5 and mlat gt 0.)
;          oplot,mlon(kindex),mlat(kindex),psym=8,symsize=1.25,color=(float(i+1)/float(npt))*mcolor
           stime=string(FORMAT='(I2.2)',long(tswath(index(0))))
           tsave(mcount)=tswath(index(0))
           mcount=mcount+1L
           xtmp=mlon(kindex)
           ytmp=mlat(kindex)
           index=where(ytmp eq min(ytmp))
;          xyouts,xtmp(index(0)),30.,stime,/data,alignment=0.5,color=0
        endif
    endfor
    nswath=mcount
    tsave=tsave(0:mcount-1L)

erase
xyouts,.4,.95,sdate,/normal,color=0,charsize=3,charthick=2
;iswath=n_elements(tsave)-1L
;!p.multi[1]=4
;!p.multi[2]=4
;
; loop over swaths
;
for iswath=0L,nswath-1L do begin

;!p.multi[0]=nswath-1L-iswath
;!p.multi[0]=iswath+1

    tplot=tsave(iswath)
    kindex=where(abs(muttime-tplot) le 0.5 and mlat gt 0.,mprofs)
    stime=strcompress(string(FORMAT='(F4.1)',muttime(kindex(0))),/remove_all)
    ylabels=string(format='(f4.1)',mlat(kindex))
    xlabels=string(format='(f5.1)',mlon(kindex))
    lonswath=reform(mlon(kindex))
    latswath=reform(mlat(kindex))
    coswath=mco(kindex,*)
    tempswath=mtemp(kindex,*)
    slon1=string(format='(i3)',lonswath(0))+'E'
    slon2=string(format='(i3)',lonswath(mprofs-1L))+'E'
    slat1=string(format='(i2)',latswath(0))+'N'
    slat2=string(format='(i2)',latswath(mprofs-1L))+'N'
if iswath eq 0L then begin
   colevs=fltarr(93,nswath)
   tplevs=fltarr(93,nswath)
   latlevs=fltarr(93,nswath)
endif
tplevs(0:mprofs-1,iswath)=tempswath(*,ilev)
colevs(0:mprofs-1,iswath)=coswath(*,ilev)
latlevs(0:mprofs-1,iswath)=latswath

; plot
;
    !type=2^2+2^3
    xmn=xorig(iswath)
    xmx=xorig(iswath)+xlen
    ymn=yorig(iswath)
    ymx=yorig(iswath)+ylen
    set_viewport,xmn,xmx,ymn,ymx
ylab=' '
if iswath mod 4 eq 0 then ylab='Altitude (km)'
imin=160.
imax=330.
int=10.
nlvls=15
    level=imin+int*findgen(nlvls)
    slevel=string(format='(i3)',level)
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*icolmax/nlvls
index=where(tempswath lt 0.)
if index(0) ne -1L then tempswath(index)=0./0.

    contour,tempswath,findgen(mprofs),altitude,levels=level,/cell_fill,c_color=col1,color=0,title='t='+stime,$
            ytitle=ylab,xticks=1,xtickname=[' ',' '],yrange=[20.,100.],/noeras
    xyouts,xmn-0.02,ymn-0.02,'('+slat1+','+slon1+')      ('+slat2+','+slon2+')',/normal,$
           color=0,charsize=1,charthick=1.5
    contour,tempswath,findgen(mprofs),altitude,levels=level,/overplot,/follow,color=0
;   contour,coswath,findgen(mprofs),altitude,levels=level,/overplot,/follow,color=0
endfor  ; loop over panels

    xmn=xorig(nswath)
    xmx=xorig(nswath)+xlen
    ymn=yorig(nswath)
    ymx=yorig(nswath)+ylen
    set_viewport,xmn,xmx,ymn,ymx
plot,latlevs(*,0),tplevs(*,0),color=0,title='Temperature at '+slev+' km',yrange=[imin,imax-50.],$
     xtitle='Latitude',xrange=[20,90],psym=1,charsize=1
for iswath=1L,nswath-1L do begin
    oplot,latlevs(*,iswath),tplevs(*,iswath),color=(float(iswath)/float(nswath))*mcolor,psym=1
endfor


    imin=min(level)
    imax=max(level)
    ymnb=min(yorig) -cbaryoff-0.05
    ymxb=ymnb+cbarydel
    set_viewport,min(xorig)+0.01,max(xorig)+xlen-0.01,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,color=0,charsize=1.5,charthick=2,$
         xtitle='MLS Temperature',xtickname=slevel,xticks=n_elements(level)-1
    ybox=[0,10,10,0,0]
    x2=imin
    dx=(imax-imin)/(float(nlvls)-1)
    for j=1,nlvls-1 do begin
        xbox=[x2,x2,x2+dx,x2+dx,x2]
        polyfill,xbox,ybox,color=col1(j)
        x2=x2+dx
    endfor

    icount=icount+1

; Close PostScript file and return control to X-windows
     if setplot ne 'ps' then stop
     if setplot eq 'ps' then begin
        device, /close
        spawn,'convert -trim polar+cross_pole_nh_mlsco+temp_'+sdate+'_'+slev+'km.ps -rotate -90 '+$
                            'polar+cross_pole_nh_mlsco+temp_'+sdate+'_'+slev+'km.jpg'
        spawn,'/usr/bin/rm polar+cross_pole_nh_mlsco+temp_'+sdate+'_'+slev+'km.ps'
     endif
     jumpday:
goto,jump
end
