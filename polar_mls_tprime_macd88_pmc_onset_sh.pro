;
; polar plot of MLS temperature anomaly (minus the zonal mean) 
;
@stddat
@kgmt
@ckday
@kdate

loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax
setplot='ps'
read,'setplot=',setplot
nxdim=750
nydim=750
xorig=[0.15]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.02
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
smonth=['J','F','M','A','M','J','J','A','S','O','N','D']
mdir='/atmos/aura6/data/MLS_data/Datfiles_Grid/'
years=[2007,2008,2009,2010,2011,2012,2013,2014,2015]
years=[2014,2015]
nyears=n_elements(years)
for nn=0,nyears-1L do begin

lstmn=12         ; SH
lstdy=1
lstyr=years(nn)
ledmn=12         ; SH
leddy=31
ledyr=years(nn)
lstday=0
ledday=0
;
; loop over years
;
for iyear=lstyr,ledyr do begin
kcount=0

z = stddat(lstmn,lstdy,iyear,lstday)
z = stddat(ledmn,leddy,iyear,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=ledday-lstday+1L
;
; Compute initial Julian date
;
iyr = iyear
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
;
; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,plotit
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
;
; read MLS gridded IDL save files.
; Input data:  IDL> restore,'/Volumes/earth/aura6/data/MLS_data/Datfiles_Grid/MLS_grid5_ALL_v3.3_YYYYMMDD.sav
; Input data:  IDL> restore,'/Volumes/earth/aura6/data/MLS_data/Datfiles_Grid/MLS_grid5_U_V_v3.3_YYYYMMDD.sav
;
; CO_GRID         FLOAT     = Array[144, 96, 37]
; GP_GRID         FLOAT     = Array[144, 96, 55]
; H2O_GRID        FLOAT     = Array[144, 96, 55]
; LAT             DOUBLE    = Array[96]
; LON             DOUBLE    = Array[144]
; N2O_GRID        FLOAT     = Array[144, 96, 37]
; O3_GRID         FLOAT     = Array[144, 96, 55]
; PMLS            FLOAT     = Array[37]
; PMLS2           FLOAT     = Array[55]
; TP_GRID         FLOAT     = Array[144, 96, 55]
; U               FLOAT     = Array[144, 96, 55]
; V               FLOAT     = Array[144, 96, 55]
;
      dum=findfile(mdir+'MLS_grid5_ALL_v3.3_'+sdate+'.sav')
      if dum(0) eq '' then goto,skipmls
      restore,dum(0)
      restore,mdir+'MLS_grid5_U_V_v3.3_'+sdate+'.sav'
      print,sdate
;
; apply mask
;
      index=where(temperature_mask eq -99.)
      if index(0) ne -1L then temperature(index)=-99.
      nlv=n_elements(altitude)
;
; declare time period arrays on first day
;
      if kcount eq 0L then begin
         pressure=pmls2
;        print,pressure
         ralt=0.00464159
;        read,'Enter desired pressure level ',ralt
         index=where(abs(pressure-ralt) eq min(abs(pressure-ralt)))
         ilev=index(0)
         salt=strcompress(ralt,/remove_all)
         nc=n_elements(lon)
         nr=n_elements(lat)
      endif
;
; extract polar temp, GPH, U, V
;
      tp=reform(TP_GRID(*,*,ilev))
      gp=reform(GP_GRID(*,*,ilev))
      uu=reform(U(*,*,ilev))
      vv=reform(V(*,*,ilev))
;
; subtract zonal mean on each day
;
tbar=mean(tp,dim=1,/Nan)
gbar=mean(gp,dim=1,/Nan)
tprime=0.*tp
gprime=0.*tp
for j=0,nr-1L do tprime(*,j)=tp(*,j)-tbar(j)
for j=0,nr-1L do gprime(*,j)=gp(*,j)-gbar(j)
;
if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !p.font=0
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='polar_mls_tprime_'+sdate+'_'+salt+'.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
;
; plot 
;
erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3+2^7	; ticks outward
;
; add wrap around longitude
;
tp2=fltarr(nc+1,nr)
gp2=fltarr(nc+1,nr)
tprime2=fltarr(nc+1,nr)
gprime2=fltarr(nc+1,nr)
tp2(0:nc-1,0:nr-1)=tp
gp2(0:nc-1,0:nr-1)=gp
tprime2(0:nc-1,0:nr-1)=tprime
gprime2(0:nc-1,0:nr-1)=gprime
tp2(nc,0:nr-1)=tp2(0,0:nr-1)
gp2(nc,0:nr-1)=gp2(0,0:nr-1)
tprime2(nc,0:nr-1)=tprime2(0,0:nr-1)
gprime2(nc,0:nr-1)=gprime2(0,0:nr-1)
lon2=fltarr(nc+1)
lon2(0:nc-1)=lon
lon2(nc)=lon2(0)+360.

tlevel=130+5.*findgen(31)
nlvls=n_elements(tlevel)
col1=1+(indgen(nlvls)/float(nlvls))*mcolor
MAP_SET,-90,0,0,/ortho,/noeras,/grid,/contin,/noborder,title=sdate+' '+salt+' km',color=0
contour,tp2,lon2,lat,/noeras,/overplot,charsize=1.5,/cell_fill,c_color=col1,levels=tlevel
contour,tprime2,lon2,lat,levels=-10.+findgen(10),color=mcolor,/follow,/overplot,c_linestyle=5
contour,tprime2,lon2,lat,levels=1.+findgen(10),color=0,/follow,/overplot
imin=min(tlevel)
imax=max(tlevel)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='MLS Temp-Tbar (K)'
ybox=[0,10,10,0,0]
x1=imin
dxx=(imax-imin)/float(nlvls)
for jj=0,nlvls-1 do begin
xbox=[x1,x1,x1+dxx,x1+dxx,x1]
polyfill,xbox,ybox,color=col1(jj)
x1=x1+dxx
endfor

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim polar_mls_tprime_'+sdate+'_'+salt+'.ps -rotate -90 polar_mls_tprime_'+sdate+'_'+salt+'.png'
    endif

skipmls:
      icount=icount+1L
goto,jump

plotit:

endfor  ; loop over years

endfor
end
