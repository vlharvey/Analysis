;
; find coincidences between MLS and CIPS
; save daily (or seasonal?) files
; VLH 8/4/2009
;
@stddat
@kgmt
@ckday
@kdate
@ks_stats

re=40000./2./!pi
rad=double(180./!pi)
dtr=double(!pi/180.)

loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
setplot='ps'
read,'setplot=',setplot
nxdim=750
nydim=750
xorig=[0.15,0.55,0.15,0.55]
yorig=[0.55,0.55,0.15,0.15]
xlen=0.3
ylen=0.3
cbaryoff=0.06
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
smonth=['J','F','M','A','M','J','J','A','S','O','N','D']
mdir='/aura6/data/MLS_data/Datfiles_SOSST/'
;
; restore CIPS procedures and functions
;
restore,'read_cips_file.sav
pth='/aura7/harvey/CIPS_data/Datfiles/cips_sci_2a_orbit_'

lstmn=7
lstdy=15
lstyr=2009
ledmn=7
leddy=15
ledyr=2009
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;read,' Enter starting date ',lstmn,lstdy,lstyr
;read,' Enter ending date ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=ledday-lstday+1L
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
kcount=0L
;
; USE THE CLOUD PRESENCE MAP ARRAY TO CALCULATE FREQUENCIES. AND USES THE CPM=1 VALUE TO GET THE ALBEDOS.
; LOWER LIMIT FOR ALBEDO -- ANYTHING SMALLER THAN THIS IS ASSUMED NOT TO BE A CLOUD.
; USING LIM=-99 ESSENTIALLY INCLUDES ALL POINTS THAT ARE FOUND WITH CLOUD_PRESENCE_MAP,
; EVEN IF THE ALBEDO IS NEGATIVE (WHICH DOES HAPPEN) -- BUT THEN THE ALB/ALB_ERR TEST MIGHT CATCH IT.
;LIM=1.
;ERRLIM=1.0      ;MAXIMUM ALLOWED RATIO OF ALBEDO_ERR/ALBEDO
;SZALIM=91.      ;DATA WITH SZA > SZALIM ARE BAD (IN NH THIS CAN ONLY HAPPEN ON THE ASCENDING NODE)
;SZALIM=180.    ;DON'T GET RID OF ANY DATA BASED ON SZA.

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
      sday=string(FORMAT='(I3.3)',iday)
      sdate=syr+smn+sdy
;
; postscript file
;
      if setplot eq 'ps' then begin
         lc=0
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !p.font=0
         device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
                /bold,/color,bits_per_pixel=8,/helvetica,filename='find_coin_mls_cips_'+sdate+'.ps'
         !p.charsize=1.25
         !p.thick=2
         !p.charthick=5
         !p.charthick=5
         !y.thick=2
         !x.thick=2
      endif
;
; get nc filenames on this day
;
      spawn,'ls '+pth+'*'+syr+'-'+sday+'*.nc',fnames
      if fnames(0) eq '' then goto,jump
      norbit=n_elements(fnames)
;
; average albedo, IWC, radii in each latitude bin
;
norbit=1L
      npts=300000L
      ALB_all=-99.+0.*fltarr(norbit,npts)
      cips_lat_all=-99.+0.*fltarr(norbit,npts)
      cips_lon_all=-99.+0.*fltarr(norbit,npts)
      cips_ut_time_all=-99.+0.*fltarr(norbit,npts)
;
; loop over orbits
;
      FOR iorbit = 0,norbit-1 DO BEGIN
          FNAME=FNAMES(iorbit)
          print,fname
          data=read_cips_file(fname,/full_path,attributes=attributes)
;
; extract contents from data structure
;
;IDL> help,/str,data
;** Structure <20db38>, 18 tags, length=176, data length=156, refs=1:
;   AIM_ORBIT_NUMBER INT          12109
;   VERSION         STRING    '03.20'
;   PRODUCT_CREATION_TIME STRING    '2009/202-12:23:19'
;   DEPENDANT1BVERSION STRING    '03.20'
;   DEPENDANT1CVERSION STRING    '03.20'
;   QUALITY_FLAGS   LONG                 0
;   STACK_ID        INT              0
;   UT_DATE         LONG          20090716
;   HEMISPHERE      STRING    'N'
;   STACK_START_TIME DOUBLE       9.3173728e+14
;   UT_TIME         DOUBLE          0.14681250
;   LA_TIME         STRING    '2009/197-00:08:49'
;   ALBEDO          POINTER   <PtrHeapVar28>
;   CENTER_LON      DOUBLE           82.797813
;   KM_PER_PIXEL    FLOAT           5.00000
;   BBOX            INT       Array[4]
;   LATITUDE        POINTER   <PtrHeapVar29>
;   LONGITUDE       POINTER   <PtrHeapVar30>
;
          AIM_ORBIT_NUMBER=data.AIM_ORBIT_NUMBER                ;INT Cumulative mission orbit number
          VERSION=data.VERSION                                  ;STRING    '03.20'
          PRODUCT_CREATION_TIME=data.PRODUCT_CREATION_TIME      ;STRING    '2009/040-13:23:03' Version number of data product
          DEPENDANT1BVERSION=data.DEPENDANT1BVERSION            ;STRING    '03.20'
          UT_DATE=DATA.UT_DATE                                  ;LONG       2009001 UTC date of this orbit
          HEMISPHERE=DATA.HEMISPHERE                            ;STRING    'S'
          STACK_ID=data.STACK_ID                                ;INT        0 uniquely identify the Level 1B data
          QUALITY_FLAGS=data.QUALITY_FLAGS                      ;LONG      TBD
          KM_PER_PIXEL=data.KM_PER_PIXEL                        ;INT              5
          BBOX=data.BBOX                                        ;LONG      Array[4] {x, y} bounding box of map projected image
          CENTER_LON=data.CENTER_LON    ;Center longitude of map proj, NOT data. Used for orienting the data horizontally.
          UT_TIME=(data[0].ut_time)                             ;POINTER  Number of seconds elapsed since orbit_start_time_ut
          LATITUDE=(*DATA[0].LATITUDE)                          ;latitude for every pixel
          LONGITUDE=(*DATA[0].LONGITUDE)                        ;longitude for every pixel
          latitude_orig=latitude                                ;save original lats to determine asc/desc
          longitude_orig=longitude                              ;save original lons to determine asc/desc
          X=WHERE(LATITUDE GT 90,NX)
          IF NX GT 0 THEN LATITUDE(X)=180-LATITUDE(X)           ;correct latitude for crossing over the NP
          X=WHERE(LATITUDE lt -90.,nx)
          if nx gt 0L then latitude(x)=-90.-(latitude(x)+90.)   ;correct latitude for crossing over the SP
          X=WHERE(LONGITUDE LT 0,NX)
          IF NX GT 0 THEN LONGITUDE(X)=LONGITUDE(X)+360
          ALB = (*data[0].albedo)                               ;Cloud albedo in Garys (10^-6 sr^-1) i.e., alb x 1.e6
          result=size(longitude)
          nprof=result(1)
if iorbit eq 0L then begin
   erase
   set_viewport,0.15,0.85,0.15,0.85
   !type=2^2+2^3
   map_set,90,0,0,/ortho,/contin,/grid,title='CIPS and MLS '+sdate,color=0,limit=[40.,0.,90.,360.]
endif
utmin=0. & utmax=24.
for ii=0L,nprof-1L do $
    oplot,LONGITUDE(ii,*),latitude(ii,*),psym=8,color=((ut_time-utmin)/(utmax-utmin))*mcolor,symsize=0.3
;
; free memory
;
          HEAP_GC
;         RESULT=MEMORY(/CURRENT)
;         PRINT,'MEMORY IS: ',RESULT
;         PRINT,' '
;
;GET RID OF ANY INFINITE DATA AND ANY negative DATA
;
          good=WHERE(FINITE(ALB) EQ 1 and ALB gt 0,ngood)
          IF NGOOD GT 0 THEN BEGIN
             ALB=alb(good)
             cips_latitude=latitude(good)
             cips_longitude=longitude(good)
             cips_ut_date=ut_date(good)
             cips_ut_time=ut_time(good)
             if ngood gt npts then stop,'increase npts'
;    
; save petals into daisy
;
             ALB_all(iorbit,0:ngood-1L)=alb
             cips_lat_all(iorbit,0:ngood-1L)=cips_latitude
             cips_lon_all(iorbit,0:ngood-1L)=cips_longitude
             cips_ut_time_all(iorbit,0:ngood-1L)=cips_ut_time
print,'UT time ',min(cips_ut_time),max(cips_ut_time),ngood,' points'
          ENDIF
      endfor  ; loop over orbits
;
; make arrays 1-d of good values
;
good=where(alb_all gt 0.,ngood)
alb=alb_all(good)
clat=cips_lat_all(good)
clon=cips_lon_all(good)
cuttime=cips_ut_time_all(good)
;
; Compute LOCAL TIME
;




;
; restore MLS CO on this day
; ALTITUDE        FLOAT     = Array[121]
; COMMENT         STRING    = Array[4]
; DATE            LONG      =     20070101
; ERR             FLOAT     = Array[3491, 121]
; FDOY            FLOAT     = Array[3491]
; ID              STRING    = Array[3491]
; LATITUDE        FLOAT     = Array[3491]
; LONGITUDE       FLOAT     = Array[3491]
; MASK            FLOAT     = Array[3491, 121]
; MIX             FLOAT     = Array[3491, 121]
; TIME            FLOAT     = Array[3491]
;
      dum=findfile(mdir+'cat_mls_v2.2_'+sdate+'.sav')
      if dum(0) eq '' then goto,skipmls
      restore,mdir+'cat_mls_v2.2_'+sdate+'.sav'
      restore,mdir+'h2o_mls_v2.2_'+sdate+'.sav'
      restore,mdir+'tpd_mls_v2.2_'+sdate+'.sav'
      print,sdate
;
; apply mask
;
      good=where(mix ne -99.)
      if good(0) eq -1L then goto,jump
      bad=where(mask eq -99.)
      if bad(0) ne -1L then mix(bad)=-99.
      bad=where(temperature_mask eq -99.)
      if bad(0) ne -1L then temperature(bad)=-99.
      mh2o=mix
      good=where(mh2o ne -99.)
      mh2o(good)=mh2o(good)*1.e6
      mtemp=temperature
      mpress=pressure
      mprof=n_elements(longitude)
      mlev=n_elements(altitude)
      muttime=time
      mlat=latitude
      mlon=longitude
;
; eliminate bad UT times and SH
;
      index=where(muttime gt 0. and mlat ge 40.,mprof)
      if index(0) eq -1L then goto,jump
      muttime=reform(muttime(index))
      mlat=reform(mlat(index))
      mlon=reform(mlon(index))
      mtemp=reform(mtemp(index,*))
      mpress=reform(mpress(index,*))
      mh2o=reform(mh2o(index,*))
      mtheta=mtemp*(1000./mpress)^0.286
      index=where(mtemp lt 0.)
      if index(0) ne -1L then mtheta(index)=-99.

for ii=0L,mprof-1L do $
    oplot,[mlon(ii),mlon(ii)],[mlat(ii),mlat(ii)],psym=8,color=((muttime(ii)-utmin)/(utmax-utmin))*mcolor
;
; declare coincident arrays on first day
;
      if kcount eq 0L then begin
         ncoin=1000L & dxc=20.
         xcoincips=-9999.+fltarr(ncoin)
         ycoincips=-9999.+fltarr(ncoin)
         tcoincips=-9999.+fltarr(ncoin)
         albcoincips=-9999.+fltarr(ncoin)
         xcoinmls=-9999.+fltarr(ncoin)
         ycoinmls=-9999.+fltarr(ncoin)
         tcoinmls=-9999.+fltarr(ncoin)
         tempcoinmls=-9999.+fltarr(ncoin,mlev)
         h2ocoinmls=-9999.+fltarr(ncoin,mlev)
         sdate_all=strarr(kday)
         kcount=1
      endif
      sdate_all(icount)=sdate
;
; find coincidences
; loop over MLS profiles
; 
loadct,0
      scoin=0L
      for i=0,mprof-1L do begin
          xh=mlon(i) & yh=mlat(i)
          dxf=re*abs(xh-clon)*dtr*cos(yh*dtr)
          dyf=re*abs(yh-clat)*dtr
          dist=sqrt(dxf*dxf+dyf*dyf)
          hindex=where(dist le dxc,ncoin0)
          if hindex(0) ne -1 then begin
oplot,[xh,xh],[yh,yh],color=mcolor*.3,psym=8,symsize=2
oplot,clon(hindex),clat(hindex),color=mcolor*.7,psym=1
stop
             for icoin=0L,ncoin0-1L do begin
                 ii=hindex(icoin)
                 xcoincips(scoin)=clon(ii)
                 ycoincips(scoin)=clat(ii)
                 tcoincips(scoin)=cuttime(ii)

                 xcoinmls(scoin)=mlon(i)
                 ycoinmls(scoin)=mlat(i)
                 tempcoinmls(scoin,*)=mtemp(i,*)
                 h2ocoinmls(scoin,*)=mh2o(i,*)
print,icoin,xcoinmls(scoin),xcoincips(scoin),ycoinmls(scoin),ycoincips(scoin),dist(ii)
                 scoin=scoin+1L
                 if scoin ge ncoin then stop,'increase ncoin'
             endfor
stop
          endif
      endfor
;
; overplot coincidences
;
if scoin gt 0L then begin
   index=where(xcoincips ne -9999.,ncoin)
   oplot,xcoincips(index),ycoincips(index),color=0,psym=1
   oplot,xcoinmls(index),ycoinmls(index),color=0,psym=4
endif
;
; plot color bar
;
set_viewport,0.15,0.85,0.12,0.14
imin=utmin
imax=utmax
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,color=0,charsize=1,xtitle='UT Time (hours)'
ybox=[0,10,10,0,0]
x2=imin
nlvls=11
col1=1+indgen(nlvls)*mcolor/nlvls
dx=(imax-imin)/(float(nlvls)-1)
for j=1,nlvls-1 do begin
    xbox=[x2,x2,x2+dx,x2+dx,x2]
    polyfill,xbox,ybox,color=col1(j)
    x2=x2+dx
endfor
    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim find_coin_mls_cips_'+sdate+'.ps -rotate -90 find_coin_mls_cips_'+sdate+'.jpg'
    endif
      skipmls:
      icount=icount+1L
goto,jump

plotit:
;
; plot scatter plots and PDFs
;
erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
plot,findgen(13),findgen(13),xrange=[0.,12.],yrange=[0.,12.],charsize=1.2,$
     ytitle='HALOE',xtitle='HIRDLS',title='Scatter Plot'
if hcoin gt 0. then begin
result=correlate(o3coinhirdlshal,o3coinhal)
r=result(0)
xyouts,8.,3.,'N ='+strcompress(string(hcoin)),/data,charsize=1.2
xyouts,8.,1.,'r = '+strcompress(string(format='(f6.3)',r)),/data,charsize=1.2
thmax=3000. & thmin=200.
for icoin=0L,hcoin-1L do begin
   xx=o3coinhirdlshal(icoin)
   yy=o3coinhal(icoin)
   oplot,[xx,xx],[yy,yy],psym=8,color=((thcoinhirdlshal(icoin)-thmin)/(thmax-thmin))*icolmax,symsize=.5
   a=findgen(9)*(2*!pi/8.)
   usersym,cos(a),sin(a)
;  oplot,[xx,xx],[yy,yy],psym=8,color=lc,symsize=.5
endfor
endif
omin=thmin & omax=thmax
xmnb=xmn+xlen+0.01
xmxb=xmnb+cbarydel
set_viewport,xmnb,xmxb,ymn,ymx
!type=2^2+2^3+2^5+2^6
plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax]
xbox=[0,10,10,0,0]
y1=omin
dy=(omax-omin)/float(nlvls)
for j=0,nlvls-1 do begin
    ybox=[y1,y1,y1+dy,y1+dy,y1]
    polyfill,xbox,ybox,color=col1(j)
    y1=y1+dy
endfor
!type=2^2+2^3+2^5
axis,10,omin,0,YAX=1,/DATA,charsize=1.2,/ynozero
xyouts,xmxb,ymx+0.01,'Theta',/normal,charsize=1.2
;
; PDFs
;
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
x=.5*findgen(nlvls)
if hcoin gt 0L then begin
y1=histogram(o3coinhirdlshal,min=0,max=12.,binsize=.5)/(1.*hcoin)
y1=smooth(y1,3)     ; mapped PDF
y2=histogram(o3coinhal,min=0,max=12.,binsize=.5)/(1.*hcoin)
y2=smooth(y2,3)     ; flight PDF
ymax=max(y1,y2)+0.2*max(y1,y2)
!linetype=0
plot,x,y1,xtitle='Ozone (ppmv)',ytitle='Frequency',charsize=1.2,$
     title='PDFs',xrange=[0.,12.],yrange=[0.,ymax]
y2=histogram(o3coinhal,min=0,max=12.,binsize=.5)/(1.*hcoin)
y2=smooth(y2,3)     ; flight PDF
!linetype=1
oplot,x,y2
plots,[7.5,.3*ymax],/data
plots,[8.5,.3*ymax],/continue,/data
!linetype=0
xyouts,8.75,.3*ymax,'HALOE',/data,charsize=1.2
y2=histogram(o3coinhirdlshal,min=0,max=12.,binsize=.5)/(1.*hcoin)
y2=smooth(y2,3)
plots,[7.5,.1*ymax],/data
plots,[8.5,.1*ymax],/continue,/data
xyouts,8.75,.1*ymax,'HIRDLS',/data,charsize=1.2
ks_stats,o3coinhal,o3coinhirdlshal,kstest,cprob
xyouts,7.5,.9*ymax,'KS='+strmid(string(kstest),5,4),/data
xyouts,7.5,.8*ymax,'KS sig='+$
       strcompress(string(format='(f5.3)',100.*cprob),/remove_all)+'%',/data
print,'KS=',kstest
print,'KS significance=',100.*cprob,' %'
so3bar=total(o3coinhirdlshal)/n_elements(o3coinhirdlshal)
ho3bar=total(o3coinhal)/n_elements(o3coinhal)
o3coinhirdlshal2=o3coinhirdlshal-so3bar+ho3bar
ks_stats,o3coinhal,o3coinhirdlshal2,kstest,cprob
xyouts,7.5,.7*ymax,'w/o Mean Bias:',/data
xyouts,7.5,.6*ymax,'KS='+strmid(string(kstest),5,4),/data
xyouts,7.5,.5*ymax,'KS sig='+strcompress(string(format='(f5.3)',$
        100.*cprob),/remove_all)+'%',/data
endif

;   if setplot ne 'ps' then stop
;   if setplot eq 'ps' then begin
;      device, /close
;      spawn,'convert -trim find_coin_mls_cips_'+sdate+'.ps -rotate -90 find_coin_mls_cips_'+sdate+'.jpg'
;   endif
end
