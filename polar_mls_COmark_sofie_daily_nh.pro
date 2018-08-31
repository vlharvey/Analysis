;
; save daily zonal mean CO gradient marker for each day (to hopefully match the mls_daily_zonal_means_from_gridded TUV file).
; NH version. Also save daily altitude profile of marker area (% of the hemisphere).
;
@drawvectors

loadct,39
mcolor=byte(!p.color)
icolmax=mcolor
icmm1=mcolor-1B
icmm2=mcolor-2B
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
!NOERAS=-1
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.15]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.03
cbarydel=0.02
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/Users/harvey/Harvey_etal_2018/Code/Save_files/daily_mls_coelatedge+merra2_sfelatedge_'
dirm='/atmos/harvey/MERRA2_data/Datfiles/MERRA2-on-WACCM_theta_'
dirmls='/atmos/aura6/data/MLS_data/Datfiles_Grid/MLS_grid5_ALL_U_V_v4.2_'

re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
nrr=91L
yeq=findgen(nrr)
index=where(yeq mod 2 eq 0,nrr2)
yeq2=yeq(index)                         ; 2 degree bins

latcircle=fltarr(nrr)
hem_frac=fltarr(nrr)
for j=0,nrr-2 do begin
    hy=re*dtr
    dx=re*cos(yeq(j)*dtr)*360.*dtr
    latcircle(j)=dx*hy
endfor
for j=0,nrr-1 do begin
    if yeq(j) ge 0. then index=where(yeq ge yeq(j))
    if index(0) ne -1 then hem_frac(j)=100.*total(latcircle(index))/hem_area
    if yeq(j) eq 0. then hem_frac(j)=100.
endfor
;
; SOFIE locations
; DATE            LONG      = Array[10551]
; DOY             LONG      = Array[10551]
; LAT             FLOAT     = Array[10551]
; LON             FLOAT     = Array[10551]
; LST             FLOAT     = Array[10551]
; MODE            INT       = Array[10551]
; TIME            FLOAT     = Array[10551]
; YRD             FLOAT     = Array[10551]
;
restore,'sofie_daily_predicts.sav
index=where(yrd gt 2017.5 and yrd lt 2018.5,nsofie)
sofie_DATE=date(index)
sofie_DOY=doy(index)
sofie_LAT=lat(index)
sofie_LON=lon(index)
sofie_LST=lst(index)
sofie_MODE=mode(index)
sofie_TIME=time(index)
sofie_YRD=yrd(index)
;
; make corresponding YYYYMMDD array
;
sofie_yyyymmdd=strarr(nsofie)
for i=0L,nsofie-1L do begin
    iyr=long(sofie_yrd(i))
    kdate,float(sofie_doy(i)),iyr,imn,idy
    syear=string(FORMAT='(I4)',iyr)
    smn=string(FORMAT='(I2.2)',imn)
    sdy=string(FORMAT='(I2.2)',idy)
    sofie_yyyymmdd(i)=syear+smn+sdy
;   print,sofie_doy(i),sofie_yrd(i),' ',sofie_yyyymmdd(i)
endfor
;
; get lon,lat information
;
restore,'smidemax_300-year_TUmark_djf_jja.sav
;
; MLS daily zonal means
; KDAY            FLOAT     =       4664.00
; NLV             LONG      =           55
; NLV2            LONG      =           37
; NR              LONG      =           96
; LAT             DOUBLE    = Array[96]
; PRESS37         FLOAT     = Array[37]
; PRESS55         FLOAT     = Array[55]
; SDATE_ALL       STRING    = Array[4664]
; TBAR            FLOAT     = Array[96, 55, 4664]
; UBAR            FLOAT     = Array[96, 55, 4664]
; VBAR            FLOAT     = Array[96, 55, 4664]
; ZBAR            FLOAT     = Array[96, 55, 4664]
; H2OBAR          FLOAT     = Array[96, 55, 4664]
; O3BAR           FLOAT     = Array[96, 55, 4664]
; N2OBAR          FLOAT     = Array[96, 37, 4664]
; COBAR           FLOAT     = Array[96, 37, 4664]
;
restore,'/atmos/aura6/data/MLS_data/Pre_process/mls_daily_zonal_means_from_gridded_20040808-20170515.sav
restore,'mls_djf_jja.sav
zindex=0.*press55
for k = 0,n_elements(PRESS55)-1 do begin
    index = where(press37 eq press55(k))
    if index(0) ne -1 then zindex(k) = 1.0
endfor
good=where(zindex eq 1.0)
zprof=mean(ZBAR_DJF(*,good)/1000.,dim=1)
index=where(finite(zprof) ne 1)
if index(0) ne -1L then zprof(index)=0.
;
; file listing of MLS CO marker files
;
spawn,'ls '+dir+'*12_2d_nh.sav',ifiles1
spawn,'ls '+dir+'*01_2d_nh.sav',ifiles2
ifiles=[ifiles1,ifiles2]
nfile=n_elements(ifiles)
for ifile=0L,nfile-1L do begin
    restore,ifiles(ifile)
;    print,ifiles(ifile)
    if ifile eq 0L then sdate_all=SDATE_TIME
    if ifile gt 0L then sdate_all=[sdate_all,SDATE_TIME]
endfor
nday=n_elements(sdate_all)
;
; loop over files
;
icount=0L
kcount=0L
for ifile=0L,nfile-1L do begin
    result=strsplit(ifiles(ifile),'_',/extract)
    yyyymm=result(-3)
    smon=strmid(yyyymm,4,2)
    imon=long(smon)
;
; restore monthly data
;
; DELATLEVS3D     FLOAT     = Array[30, 91, 37]
; HLATPDF_TIME_3D FLOAT     = Array[30, 46, 37]
; LLATPDF_TIME_3D FLOAT     = Array[30, 46, 37]
; LOWLAT_ELATEDGE_2D FLOAT     = Array[30, 37]
; LOWLAT_ELATINNER_2D FLOAT     = Array[30, 37]
; LOWLAT_ELATOUTER_2D FLOAT     = Array[30, 37]
; MARKMLS4D       FLOAT     = Array[144, 96, 37, 30]
; MARKSFELATEDGE_2D FLOAT     = Array[30, 37]
; NASHELATEDGE_2D FLOAT     = Array[30, 37]
; NASHINNER_2D    FLOAT     = Array[30, 37]
; NASHOUTER_2D    FLOAT     = Array[30, 37]
; NOVORTEX_FLAG_2D FLOAT     = Array[30, 37]
; PMLS            FLOAT     = Array[37]
; SDATE_TIME      STRING    = Array[30]
; SFELATEDGE_2D   FLOAT     = Array[30, 37]
; SFMARKEDGE_2D   FLOAT     = Array[30, 37]
; SPBIN3D         FLOAT     = Array[30, 91, 37]
; YEQ             FLOAT     = Array[91]
;
    print,ifiles(ifile)
    restore,ifiles(ifile)
;
; loop over days
;
    for ii=0L,n_elements(SDATE_TIME)-1L do begin
        comark3d=reform(MARKMLS4D(*,*,*,ii))
        sdate=SDATE_TIME(ii)
        print,sdate
;
; read MERRA2 at 12Z
;
        dum=findfile(dirm+sdate+'12.nc3')
        rd_merra2_nc3,dum,nc,nr,nth,alon,alat,th,pv2,p2,$
           u2,v2,qdf2,mark2,qv2,z2,sf2,q2,o32,iflag
        if iflag ne 0L then goto,jumpday
        tmp2=0.*p2
        for k=0L,nth-1L do tmp2(*,*,k)=th(k)*(p2(*,*,k)/1000.)^0.286
;
; read MLS gridded data to get CO
;
        mfile=dirmls+sdate+'.sav'
        dum=findfile(mfile)
        if dum(0) eq '' then goto,jumpday
        restore,mfile
        co3d=mean(co,dim=4,/Nan)                     ; make 4.2 data backward compatible. average both nodes

        if icount eq 0 then begin
           bad=where(z2 eq 0.)
           if bad(0) ne -1L then z2(bad)=0./0.
           zdum=mean(z2,dim=1,/Nan)
           zprofile=mean(zdum,dim=1,/Nan)
           zlev=70.
;          print,zprofile
;          read,'Enter altitude ',zlev
           index=where(abs(zprofile-zlev) eq min(abs(zprofile-zlev)))
           if index(0) eq -1 then stop,'Invalid altitude level '
           ilev=index(0)
           salt=strcompress(string(fix(zprofile(ilev))),/remove_all)
;
; find closest altitude in CO gradient vortex
;
           index=where(abs(zprof-zlev) eq min(abs(zprof-zlev)))
           ilevco=index(0)
print,'levels = ',zprofile(ilev),zprof(ilevco)
        endif
;
; strip out level
;
        mark1=transpose(mark2(*,*,ilev))
        u1=transpose(u2(*,*,ilev))
        v1=transpose(v2(*,*,ilev))
        sp1=sqrt(u1^2.+v1^2.)
        sf1=transpose(sf2(*,*,ilev))
        pv1=transpose(pv2(*,*,ilev))
        comark2d=reform(comark3d(*,*,ilevco))
        co2d=reform(co3d(*,*,ilevco))
;
; wrap around longitude
;
        sf=0.*fltarr(nc+1,nr)
        sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
        sf(nc,*)=sf(0,*)
        sp=0.*fltarr(nc+1,nr)
        sp(0:nc-1,0:nr-1)=sp1(0:nc-1,0:nr-1)
        sp(nc,*)=sp(0,*)
        mark=0.*fltarr(nc+1,nr)
        mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
        mark(nc,*)=mark(0,*)
        markco=0.*fltarr(nc+1,nr)
        markco(0:nc-1,0:nr-1)=comark2d(0:nc-1,0:nr-1)
        markco(nc,*)=markco(0,*)
        co=0.*fltarr(nc+1,nr)
        co(0:nc-1,0:nr-1)=co2d(0:nc-1,0:nr-1)*1.e6
        co(nc,*)=co(0,*)

        x=fltarr(nc+1)
        x(0:nc-1)=alon
        x(nc)=alon(0)+360.
;
; plot
;
        if setplot eq 'ps' then begin
           set_plot,'ps'
           xsize=nxdim/100.
           ysize=nydim/100.
;          !p.font=0
           device,font_size=9
           device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
                  /bold,/color,bits_per_pixel=8,/times,filename='Polar+SOFIE/polar_mls_COmark_sofie_daily_nh_'+sdate+'_'+salt+'km.ps'
           !p.charsize=1.25
           !p.thick=2
           !p.charthick=5
           !p.charthick=5
           !y.thick=2
           !x.thick=2
        endif
        erase
        !psym=0
        !type=2^2+2^3
        !p.charthick=2
        xmn=xorig(0)
        xmx=xorig(0)+xlen
        ymn=yorig(0)
        ymx=yorig(0)+ylen
        set_viewport,xmn,xmx,ymn,ymx
        MAP_SET,90,0,-90,/stereo,/noeras,/grid,/contin,/noborder,title=strmid(sdate,4,4),charsize=2.0,latdel=10,color=0
loadct,0
        map_continents,/fill_contin,/countries,/usa,color=100
loadct,39
        oplot,findgen(361),0.1+0.*findgen(361),color=0
        imin=0.
        imax=7.
        nlvls=20
        pvint=(imax-imin)/float(nlvls)
        level=imin+pvint*findgen(nlvls)
cmin=70.	; don't overlap SOFIE sunset navy blue with CO level
crange=mcolor-cmin
cinc=crange/float(nlvls)
        col1=cmin+cinc*indgen(nlvls)
;
; only plot inside the vortex
;
markco=smooth(markco,3,/edge_truncate)
index=where(markco le 0.)
if index(0) ne -1L then co(index)=0./0.
        contour,co,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
;       contour,co,x,alat,/overplot,levels=level,/follow,c_labels=0*level,/noeras,color=0
        contour,markco,x,alat,/overplot,levels=[0.5],/follow,thick=15,/noeras,color=0,c_labels=[0]
;        contour,sf,x,alat,/overplot,nlevels=20,/follow,thick=5,/noeras,color=0,c_labels=[0]
        MAP_SET,90,0,-90,/stereo,/noeras,/grid,/contin,/noborder,charsize=2.0,latdel=10,color=0

;       drawvectors,nc,nr,alon,alat,u1,v1,3
;
; oplot SOFIE this day in 2017/2018
;
monday=strmid(sdate,4,4)
smonday=strmid(sofie_yyyymmdd,4,4)
print,'MONDAY ',monday
today=where(monday eq smonday)
if today(0) ne -1L then begin
   print,'today in SOFIE ',smonday(today)
   lontoday=sofie_lon(today)
   lattoday=sofie_lat(today)
   modetoday=sofie_mode(today)
   index=where(modetoday eq 0)
   oplot,findgen(361),lattoday(index(0))+0.*findgen(361),psym=0,thick=15,color=250
   index=where(modetoday eq 1)
   oplot,findgen(361),lattoday(index(0))+0.*findgen(361),psym=0,thick=15,color=50
endif

        ymnb=ymn -cbaryoff
        ymxb=ymnb+cbarydel
        set_viewport,xmn+0.02,xmx-0.02,ymnb,ymxb
        !type=2^2+2^3+2^6
        plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle='MLS '+salt+' km CO (ppmv)',/noeras,$
              charsize=1.5,color=0,charthick=2
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
           spawn,'convert -trim Polar+SOFIE/polar_mls_COmark_sofie_daily_nh_'+sdate+'_'+salt+'km.ps -rotate -90 Polar+SOFIE/polar_mls_COmark_sofie_daily_nh_'+sdate+'_'+salt+'km.png'
;          spawn,'rm -f Polar+SOFIE/polar_mls_COmark_sofie_daily_nh_'+sdate+'_'+salt+'km.ps'
        endif

        icount=icount+1L
        jumpday:
    endfor	; loop over days

skipmonth:
endfor  ; loop over monthly files
end
