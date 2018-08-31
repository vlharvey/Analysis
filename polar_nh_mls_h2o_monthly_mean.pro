;
; MLS monthly mean water vapor polar projections 
;
sver='v3.3'
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill

nlon=24L
lonbin=15.*findgen(nlon)
dx=lonbin(1)-lonbin(0)
nlat=35L
latbin=-85+5.*findgen(nlat)
dy=latbin(1)-latbin(0)

loadct,39
mcolor=!p.color
icolmax=byte(!p.color)
mcolor=icolmax
icmm1=icolmax-1B
icmm2=icolmax-2B
device,decompose=0
!NOERAS=-1
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.1,0.55]
yorig=[0.3,0.3]
xlen=0.4
ylen=0.4
cbaryoff=0.05
cbarydel=0.02
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dirm='/atmos/aura6/data/MLS_data/Datfiles_SOSST/'
syear=['2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015']
mday=[31,28,31,30,31,30,31,31,30,31,30,31]
nyear=n_elements(syear)
for iyear=0,nyear-1L do begin

for imon=1,12 do begin
smon=string(format='(i2.2)',imon)

syyyymm=syear(iyear)+smon
print,syyyymm

h2omean=fltarr(nlon,nlat)
nh2omean=fltarr(nlon,nlat)

spawn,'ls '+dirm+'cat_mls_'+sver+'_'+syyyymm+'??.sav',cfiles
spawn,'ls '+dirm+'h2o_mls_'+sver+'_'+syyyymm+'??.sav',hfiles
spawn,'ls '+dirm+'tpd_mls_'+sver+'_'+syyyymm+'??.sav',tfiles
for iday=0,n_elements(cfiles)-1L do begin

    restore,cfiles(iday)
    restore,tfiles(iday)
    restore,hfiles(iday)
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
    if good(0) eq -1L then goto,skipmls
    mh2o=mix*1.e6
    mtemp=temperature
    mpress=pressure
;
; eliminate bad uttimes
;
    index=where(muttime gt 0.,mprof)
    if index(0) eq -1L then goto,skipmls
    muttime=reform(muttime(index))
    mlat=reform(mlat(index))
    mlon=reform(mlon(index))
    mtemp=reform(mtemp(index,*))
    mpress=reform(mpress(index,*))
    mh2o=reform(mh2o(index,*))
    mtheta=mtemp*(1000./mpress)^0.286
    index=where(mtemp lt 0.)
    if index(0) ne -1L then mtheta(index)=-99.
;
; extract data at PMC altitude 83 km
;
ilev=83.
mtemplev=reform(mtemp(*,ilev))
mh2olev=reform(mh2o(*,ilev))
;
; bin in lat/lon
;
for iprof=0L,mprof-1L do begin
    if mh2olev(iprof) ne -9.90000e+07 then begin
       for j=0L,nlat-1L do begin
           if mlat(iprof) ge latbin(j)-dy/2. and mlat(iprof) lt latbin(j)+dy/2. then begin
;
; GM
              if mlon(iprof) ge lonbin(0)-dx/2.+360. or mlon(iprof) lt lonbin(0)+dx/2. then begin
              h2omean(0,j)=h2omean(0,j)+mh2olev(iprof)
              nh2omean(0,j)=nh2omean(0,j)+1L
              endif

              for i=1L,nlon-1L do begin
                  if mlon(iprof) ge lonbin(i)-dx/2. and mlon(iprof) lt lonbin(i)+dx/2. then begin
                     h2omean(i,j)=h2omean(i,j)+mh2olev(iprof)
                     nh2omean(i,j)=nh2omean(i,j)+1L
                  endif
              endfor
           endif		; latitude bin
       endfor		; loop over latitudes
    endif		; if not fill value
endfor		; loop over profiles
;
skipmls:
endfor		; loop over days

    if setplot eq 'ps' then begin
       lc=0
       xsize=nxdim/100.
       ysize=nydim/100.
       set_plot,'ps'
       !p.font=0
       device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
              /bold,/color,bits_per_pixel=8,/helvetica,filename='polar_nh_mls_h2o_'+syyyymm+'.ps'
       !p.charsize=1.25
       !p.thick=2
       !p.charthick=5
       !p.charthick=5
       !y.thick=2
       !x.thick=2
    endif

erase
index=where(nh2omean gt 0.)
if index(0) ne -1L then h2omean(index)=h2omean(index)/nh2omean(index)
h2omean1=fltarr(nlon+1,nlat)
h2omean1(0:nlon-1,*)=h2omean
h2omean1(-1,*)=h2omean1(0,*)
lonbin1=[lonbin,lonbin(0)+360.]
h2omean1(*,-1)=0./0.
h2omean1(*,0)=0./0.

    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,90,0,-90,/stereo,/contin,/grid,title=syyyymm,color=0
    imin=0.
    imax=6.5
    level=0.25*findgen(27)
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*icolmax/nlvls
    contour,h2omean1,lonbin1,latbin,levels=level,/cell_fill,/noeras,/overplot,c_color=col1
    contour,h2omean1,lonbin1,latbin,levels=level,/foll,/noeras,/overplot,color=0
    map_set,90,0,-90,/stereo,/contin,/grid,/usa,/noeras,color=0

    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,-90,0,-90,/stereo,/contin,/grid,title=syyyymm,color=0,/noeras
    imin=0.
    imax=6.5
    level=0.25*findgen(27)
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*icolmax/nlvls
    contour,h2omean1,lonbin1,latbin,levels=level,/cell_fill,/noeras,/overplot,c_color=col1
    contour,h2omean1,lonbin1,latbin,levels=level,/foll,/noeras,/overplot,color=0
    map_set,-90,0,-90,/stereo,/contin,/grid,/noeras,color=0

    imin=min(level)
    imax=max(level)
    ymnb=ymn -cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,min(xorig)+0.01,max(xorig)+xlen-0.01,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,color=0,charsize=1,xtitle='83 km Water Vapor (ppmv)'
    ybox=[0,10,10,0,0]
    x2=imin
    dxx=(imax-imin)/(float(nlvls)-1)
    for j=1,nlvls-1 do begin
        xbox=[x2,x2,x2+dxx,x2+dxx,x2]
        polyfill,xbox,ybox,color=col1(j)
        x2=x2+dxx
    endfor

; Close PostScript file and return control to X-windows
     if setplot ne 'ps' then stop
     if setplot eq 'ps' then begin
        device, /close
        spawn,'convert -trim polar_nh_mls_h2o_'+syyyymm+'.ps -rotate -90 '+$
                            'polar_nh_mls_h2o_'+syyyymm+'.jpg'
;       spawn,'rm -f polar_nh_mls_h2o_'+syyyymm+'.ps'
     endif
endfor	; loop over months
endfor	; loop over years
end
