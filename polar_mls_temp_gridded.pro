;
; plot daily polar maps of MLS gridded temperature
;
@stddat
@kgmt
@ckday
@kdate
@rd_merra2_nc3

loadct,39
mcolor=byte(!p.color)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
xorig=[0.1]
yorig=[0.15]
cbaryoff=0.01
cbarydel=0.01
xlen=0.8
ylen=0.8
PI2=6.2831853071796
DTR=PI2/360.
RADEA=6.37E6
!NOERAS=-1
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
;
; get file listing
;
dir='/atmos/aura6/data/MLS_data/Datfiles_Grid/'

lstmn=7
lstdy=20
lstyr=2018
ledmn=7
leddy=30
ledyr=2018
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
kday=ledday-lstday+1L
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
kcount=0L

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal Termination Condition '
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
      print,sdate
;
; read gridded MLS data on pressure
; BRO             FLOAT     = Array[144, 96, 37, 2]
; CLO             FLOAT     = Array[144, 96, 37, 2]
; CO              FLOAT     = Array[144, 96, 37, 2]
; GPH             FLOAT     = Array[144, 96, 55, 2]
; H2O             FLOAT     = Array[144, 96, 55, 2]
; HCL             FLOAT     = Array[144, 96, 37, 2]
; HNO3            FLOAT     = Array[144, 96, 37, 2]
; HO2             FLOAT     = Array[144, 96, 49, 2]
; LAT             DOUBLE    = Array[96]
; LON             DOUBLE    = Array[144]
; N2O             FLOAT     = Array[144, 96, 37, 2]
; NODE            STRING    = Array[2]
; O3              FLOAT     = Array[144, 96, 55, 2]
; OH              FLOAT     = Array[144, 96, 49, 2]
; PMLS            FLOAT     = Array[37]
; PMLS2           FLOAT     = Array[55]
; PMLS3           FLOAT     = Array[49]
; T               FLOAT     = Array[144, 96, 55, 2]
; U               FLOAT     = Array[144, 96, 55, 2]
; V               FLOAT     = Array[144, 96, 55, 2]
;
        ifile=dir+'MLS_grid5_ALL_U_V_v4.2_'+sdate+'.sav'
        dum=findfile(ifile)
        if dum(0) eq '' then goto,jump
        restore,ifile
        print,'read '+ifile
        TP_GRID=mean(T,dim=4,/Nan)
        U_GRID=mean(U,dim=4,/Nan)
        if kcount eq 0L then begin
           ralt=0.00464159
;           print,pmls2
;           read,'Enter desired altitude ',ralt
           index=where(abs(pmls2-ralt) eq min(abs(pmls2-ralt)))
           ialt=index(0)
           salt=strcompress(ralt,/r)+'hPa'
        endif
;
; strip out ialt
;
        tp=reform(TP_GRID(*,*,ialt))
        uu=reform(U_GRID(*,*,ialt))

        if setplot eq 'ps' then begin
           lc=0
           xsize=nxdim/100.
           ysize=nydim/100.
           set_plot,'ps'
           device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
                  /bold,/color,bits_per_pixel=8,/helvetica,filename='polar_mls_temp_gridded_'+sdate+'_'+salt+'.ps'
           !p.charsize=1.25
           !p.thick=2
           !p.charthick=5
           !y.thick=2
           !x.thick=2
        endif
;
; plot
;
       imin=135.
       level=imin+2.5*findgen(31)
       imax=max(level)
       nlvls=n_elements(level)
       col1=1+(indgen(nlvls)/float(nlvls))*mcolor
;
; wrap longitude
;
       nc=n_elements(lon)
       nr=n_elements(lat)
       tp2=fltarr(nc+1,nr)
       tp2(0:nc-1,*)=tp
       tp2(nc,*)=tp2(0,*)
       uu2=fltarr(nc+1,nr)
       uu2(0:nc-1,*)=uu
       uu2(nc,*)=uu2(0,*)
       lon2=fltarr(nc+1)
       lon2(0:nc-1)=lon
       lon2(nc)=lon2(0)+360.
       erase
       xmn=xorig(0)
       xmx=xorig(0)+xlen
       ymn=yorig(0)
       ymx=yorig(0)+ylen
       set_viewport,xmn,xmx,ymn,ymx
       !type=2^2+2^3
       map_set,90,0,0,/ortho,/noeras,/grid,/contin,title=sdate,color=0	;,limit=[-50.,0.,-90.,360.]
       contour,tp2,lon2,lat,levels=level,/noeras,c_color=col1,/cell_fill,/overplot
       map_set,90,0,0,/ortho,/noeras,/grid,/contin	;,limit=[-50.,0.,-90.,360.]
       contour,tp2,lon2,lat,levels=level,/overplot,/noeras,c_color=0,/follow,c_labels=0*level
       contour,tp2,lon2,lat,levels=[130,135,140],/overplot,/noeras,c_color=mcolor,/follow,c_labels=1+0*level,thick=5
;      contour,uu2,lon2,lat,levels=[10.,20,30,40,50,60,70,80,90,100],/overplot,/noeras,c_color=0,/follow
;      contour,uu2,lon2,lat,levels=[-100.,-90,-80,-70,-60,-50,-40,-30,-20,-10],/overplot,/noeras,c_color=mcolor,/follow,c_linestyle=5
       ymnb=ymn -cbaryoff
       ymxb=ymnb+cbarydel
       set_viewport,xorig(0)+0.02,xorig(0)+xlen-0.02,ymnb,ymxb
       !type=2^2+2^3+2^6
       plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,color=0,charsize=1,xtitle='MLS '+salt+' Temperature (K)'
       ybox=[0,10,10,0,0]
       x2=imin
       dx=(imax-imin)/(float(nlvls)-1)
       for j=1,nlvls-1 do begin
           xbox=[x2,x2,x2+dx,x2+dx,x2]
           polyfill,xbox,ybox,color=col1(j)
           x2=x2+dx
       endfor
;
; Close PostScript file and return control to X-windows
       if setplot ne 'ps' then stop	;wait,1
       if setplot eq 'ps' then begin
          device, /close
          spawn,'convert -trim polar_mls_temp_gridded_'+sdate+'_'+salt+'.ps -rotate -90 '+$
                              'polar_mls_temp_gridded_'+sdate+'_'+salt+'.jpg'
          spawn,'rm -f polar_mls_temp_gridded_'+sdate+'_'+salt+'.ps'
       endif

skip:
goto,jump

end
