;
; nearby ambient using range_ring
; first look at MLS LOP climatology
;
@stddat
@kgmt
@ckday
@kdate

loadct,38
device,decompose=0
mcolor=byte(!p.color)
icolmax=mcolor
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
!noeras=0
setplot='x'
read,'setplot=',setplot
nxdim=750 & nydim=750
xorig=[0.10]
yorig=[0.10]
cbaryoff=0.015
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=0
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=icolmax
endif
;
; postscript file
;
if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !p.font=0
   !p.thick=2
   device,font_size=9
   device,/landscape,bits=8,filename='mls_lops_yz.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
lstmn=10 & lstdy=1 & lstyr=2004 & lstday=0
ledmn=4 & leddy=1 & ledyr=2006 & ledday=0
;read,' Enter starting year ',lstyr
;read,' Enter ending year ',ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

nday=ledday-lstday+1L
fdoy_save=fltarr(nday)
sdate_save=strarr(nday)
ldate_save=strarr(nday)
nlat=35L
latbin=-85+5.*findgen(nlat)
goto,plotit

iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
lcount=0L
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,plotit

      fdoy_save(icount)=iday
      if iyr eq 2005L then fdoy_save(icount)=fdoy_save(icount)+366.
      if iyr eq 2006L then fdoy_save(icount)=fdoy_save(icount)+366.+365.

      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      smn=string(FORMAT='(i2.2)',imn)
      sdate_save(icount)=syr+smn+sdy
      ldate_save(icount)=long(syr+smn+sdy)
      print,syr+smn+sdy,icount
;
; variables in daily "LOP" files
;
; AO3MEAN_SAVE    FLOAT     = Array[7]		; mean ozone in ambient on ambient mean theta
; AO3SIGMA_SAVE   FLOAT     = Array[7]		; mean sigma "
; AO3_SAVE        FLOAT     = Array[4384]	; all ozone "
; ATHMEAN_SAVE    FLOAT     = Array[7]		; mean theta "
; ATHSIGMA_SAVE   FLOAT     = Array[7]		; sigma theta "
; ATH_SAVE        FLOAT     = Array[4384]	; all theta "
; AT_SAVE         FLOAT     = Array[4384]	; all time "
; AX_SAVE         FLOAT     = Array[4384]	; all longitudes "
; AY_SAVE         FLOAT     = Array[4384]	; all latitudes "
; HO3MEAN_SAVE    FLOAT     = Array[7]		; mean ozone in anticyclones on anticyclone mean theta
; HO3SIGMA_SAVE   FLOAT     = Array[7]		; mean sigma "
; HO3_SAVE        FLOAT     = Array[1328]	; all ozone "
; HTHMEAN_SAVE    FLOAT     = Array[7]		; mean theta "
; HTHSIGMA_SAVE   FLOAT     = Array[7]		; sigma theta "
; HTH_SAVE        FLOAT     = Array[1328]	; all theta "
; HT_SAVE         FLOAT     = Array[1328]	; all time "
; HX_SAVE         FLOAT     = Array[1328]	; all longitudes "
; HY_SAVE         FLOAT     = Array[1328]	; all latitudes "
; O3LOP_SAVE      FLOAT     = Array[9]		; mean LOP profile
; TH              FLOAT     = Array[22]		; MetO theta
; THLOP_SAVE      FLOAT     = Array[9]		; theta of LOP points
; TLOP_SAVE       FLOAT     = Array[9]		; time "
; XLOP_SAVE       FLOAT     = Array[9]		; longitude "
; YLOP_SAVE       FLOAT     = Array[9]		; latitude "
;
; restore NH MLS LOPs
;
      dum=findfile('/aura2/harvey/Analysis/Datfiles_MLS/mls_nhDLlop_'+syr+smn+sdy+'.sav')
      if dum(0) eq '' then goto,jump2sh
      restore,'/aura2/harvey/Analysis/Datfiles_MLS/mls_nhDLlop_'+syr+smn+sdy+'.sav
;
; on first day only, declare arrays to save all LOP points and ozone values
;
      if lcount gt 0L then begin
         o3lop_all=[o3lop_all,o3lop_save]
         thlop_all=[thlop_all,thlop_save]
         ylop_all=[ylop_all,ylop_save]
         xlop_all=[xlop_all,xlop_save]
         o3h_all=[o3h_all,HO3_SAVE]
         thh_all=[thh_all,HTH_SAVE]
         yh_all=[yh_all,HY_SAVE]
         o3a_all=[o3a_all,AO3_SAVE]
         tha_all=[tha_all,ATH_SAVE]
         ya_all=[ya_all,AY_SAVE]
      endif
      if lcount eq 0L then begin
         o3lop_all=o3lop_save
         thlop_all=thlop_save
         ylop_all=ylop_save
         xlop_all=xlop_save
         o3h_all=HO3_SAVE
         thh_all=HTH_SAVE
         yh_all=HY_SAVE
         o3a_all=AO3_SAVE
         tha_all=ATH_SAVE
         ya_all=AY_SAVE
         lcount=1L
      endif
;
; restore SH MLS LOPs
;
      jump2sh:
      dum=findfile('/aura2/harvey/Analysis/Datfiles_MLS/mls_sh135Elop_'+syr+smn+sdy+'.sav')
      if dum(0) eq '' then goto,jump2count
      restore,'/aura2/harvey/Analysis/Datfiles_MLS/mls_sh135Elop_'+syr+smn+sdy+'.sav
      if lcount gt 0L then begin
         o3lop_all=[o3lop_all,o3lop_save]
         thlop_all=[thlop_all,thlop_save]
         ylop_all=[ylop_all,ylop_save]
         xlop_all=[xlop_all,xlop_save]
         o3h_all=[o3h_all,HO3_SAVE]
         thh_all=[thh_all,HTH_SAVE]
         yh_all=[yh_all,HY_SAVE]
         o3a_all=[o3a_all,AO3_SAVE]
         tha_all=[tha_all,ATH_SAVE]
         ya_all=[ya_all,AY_SAVE]
      endif
      if lcount eq 0L then begin
         o3lop_all=o3lop_save
         thlop_all=thlop_save
         ylop_all=ylop_save
         xlop_all=xlop_save
         o3h_all=HO3_SAVE
         thh_all=HTH_SAVE
         yh_all=HY_SAVE
         o3a_all=AO3_SAVE
         tha_all=ATH_SAVE
         ya_all=AY_SAVE
         lcount=1L
      endif

      jump2count:
      icount=icount+1L
goto,jump
;
; plot latitude-time section
;
plotit:
restore,file='MLS_LOP_all.sav'
;
; bin ambient and anticyclone and LOP ozone points in latitude and theta
;
dum=findfile('MLS_2d_ozone.sav')
if dum(0) ne '' then begin
   restore,dum(0)
   goto,jumpbin
endif
nth=n_elements(th)
o3a2d=fltarr(nlat,nth)
no3a2d=lonarr(nlat,nth)
;nlop=n_elements(o3a_all)
;for ii=0L,nlop-1L do begin         ; loop over LOP points on this day
;    theta=tha_all(ii)
;    ypos=ya_all(ii)
;    for j=0L,nlat-2L do begin
;        if latbin(j) le ypos and latbin(j+1L) gt ypos then begin
;        for k=0L,nth-2L do begin
;            dth=100.
;            if k gt 0L then dth=(th(k-1)-th(k+1L))/2.0
;            if th(k)+dth ge theta and th(k)-dth lt theta then begin
;               o3a2d(j,k)=o3a2d(j,k)+o3a_all(ii)
;               no3a2d(j,k)=no3a2d(j,k)+1L
;            endif
;        endfor
;        endif
;    endfor
;endfor
;index=where(no3a2d ge 1L)
;if index(0) ne -1L then o3a2d(index)=o3a2d(index)/float(no3a2d(index))
;index=where(no3a2d eq 0L)
;if index(0) ne -1L then o3a2d(index)=-99.

;o3h2d=fltarr(nlat,nth)
;no3h2d=lonarr(nlat,nth)
;nlop=n_elements(o3h_all)
;for ii=0L,nlop-1L do begin         ; loop over LOP points on this day
;    theta=thh_all(ii)
;    ypos=yh_all(ii)
;    for j=0L,nlat-2L do begin
;        if latbin(j) le ypos and latbin(j+1L) gt ypos then begin
;        for k=0L,nth-2L do begin
;            dth=100.
;            if k gt 0L then dth=(th(k-1)-th(k+1L))/2.0
;            if th(k)+dth ge theta and th(k)-dth lt theta then begin
;               o3h2d(j,k)=o3h2d(j,k)+o3h_all(ii)
;               no3h2d(j,k)=no3h2d(j,k)+1L
;            endif
;        endfor
;        endif
;    endfor
;endfor
;index=where(no3h2d ge 1L)
;if index(0) ne -1L then o3h2d(index)=o3h2d(index)/float(no3h2d(index))
;index=where(no3h2d eq 0L)
;if index(0) ne -1L then o3h2d(index)=-99.
;
o3lop2d=fltarr(nlat,nth)
no3lop2d=lonarr(nlat,nth)
nlop=n_elements(o3lop_all)
for ii=0L,nlop-1L do begin         ; loop over LOP points on this day
    theta=thlop_all(ii)
    ypos=ylop_all(ii)
    for j=0L,nlat-2L do begin
        if latbin(j) le ypos and latbin(j+1L) gt ypos then begin
        for k=0L,nth-2L do begin
            dth=100.
            if k gt 0L then dth=(th(k-1)-th(k+1L))/2.0
            if th(k)+dth ge theta and th(k)-dth lt theta then begin
               o3lop2d(j,k)=o3lop2d(j,k)+o3lop_all(ii)
               no3lop2d(j,k)=no3lop2d(j,k)+1L
            endif
        endfor
        endif
    endfor
endfor
index=where(no3lop2d ge 1L)
if index(0) ne -1L then o3lop2d(index)=o3lop2d(index)/float(no3lop2d(index))
index=where(no3lop2d eq 0L)
if index(0) ne -1L then o3lop2d(index)=-99.

jumpbin:
;save,file='MLS_LOP_all.sav',sdate_save,ldate_save,latbin,th,o3lop_all,thlop_all,ylop_all,xlop_all,sdate_save
sdays=strcompress(sdate_save,/remove_all)
xindex=where(strmid(sdays,6,2) eq '15',nxtick)
xlabs=sdays(xindex)
erase
level=[100.,500.,1000.,1500.,2000.,2500.,3000.,3500.,4000.,4500.,5000.]
nlvls=n_elements(level)
col1=reverse(1+indgen(nlvls)*mcolor/nlvls)

!type=2^2+2^3
set_viewport,.2,.8,.3,.7
loadct,0
no3lop2d=smooth(no3lop2d,3,/edge_truncate)
contour,no3lop2d,latbin,th,xrange=[-90.,90.],yrange=[500.,2000.],/noeras,color=0,xticks=6,$
     xtitle='Latitude',charsize=1.5,ytitle='Theta (K)',charthick=2,levels=level,c_color=col1,/fill
contour,no3lop2d,latbin,th,/overplot,/noeras,color=0,charsize=1.5,charthick=2,levels=level,/follow,$
     c_labels=1+0*level
;
; sort ozone from high to low
;
;x=reverse(sort(o3lop_all))
;o3lop_all=o3lop_all(x)
;thlop_all=thlop_all(x)
;ylop_all=ylop_all(x)
;xlop_all=xlop_all(x)
;omin=2. & omax=8.
;nn=n_elements(o3lop_all)
;for ii=0L,nn-1L do begin
;    oplot,[ylop_all(ii),ylop_all(ii)],[thlop_all(ii),thlop_all(ii)],$
;           color=((o3lop_all(ii)-omin)/(omax-omin))*mcolor,psym=8
;endfor
;xyouts,-88.,410.,'Boxes = SOSST LOPs',/data,charsize=1.5,charthick=2,color=0
;
; box SOSST LOPs
;
loadct,0
ymin=45. & ymax=68.
zmin=1000. & zmax=1400.
plots,ymin,zmin
plots,ymin,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmin
plots,ymax,zmin,/continue,/data,thick=10,color=mcolor*.1
plots,ymax,zmin
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmax
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
ymin=33. & ymax=68.
zmin=700. & zmax=1400.
plots,ymin,zmin
plots,ymin,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmin
plots,ymax,zmin,/continue,/data,thick=10,color=mcolor*.1
plots,ymax,zmin
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmax
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
ymin=50. & ymax=79.
zmin=800. & zmax=1600.
plots,ymin,zmin
plots,ymin,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmin
plots,ymax,zmin,/continue,/data,thick=10,color=mcolor*.1
plots,ymax,zmin
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmax
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
ymin=68. & ymax=78.
zmin=800. & zmax=1200.
plots,ymin,zmin
plots,ymin,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmin
plots,ymax,zmin,/continue,/data,thick=10,color=mcolor*.1
plots,ymax,zmin
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmax
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
ymin=59. & ymax=69.
zmin=800. & zmax=1600.
plots,ymin,zmin
plots,ymin,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmin
plots,ymax,zmin,/continue,/data,thick=10,color=mcolor*.1
plots,ymax,zmin
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmax
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
;
; SH
;
ymin=-81. & ymax=-50.
zmin=800. & zmax=1300.
plots,ymin,zmin
plots,ymin,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmin
plots,ymax,zmin,/continue,/data,thick=10,color=mcolor*.1
plots,ymax,zmin
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmax
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
ymin=-49. & ymax=-30.
zmin=800. & zmax=1200.
plots,ymin,zmin
plots,ymin,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmin
plots,ymax,zmin,/continue,/data,thick=10,color=mcolor*.1
plots,ymax,zmin
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmax
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
ymin=-49. & ymax=-30.
zmin=1100. & zmax=1400.
plots,ymin,zmin
plots,ymin,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmin
plots,ymax,zmin,/continue,/data,thick=10,color=mcolor*.1
plots,ymax,zmin
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmax
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
ymin=-66. & ymax=-50.
zmin=900. & zmax=1300.
plots,ymin,zmin
plots,ymin,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmin
plots,ymax,zmin,/continue,/data,thick=10,color=mcolor*.1
plots,ymax,zmin
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1
plots,ymin,zmax
plots,ymax,zmax,/continue,/data,thick=10,color=mcolor*.1

set_viewport,.88,.9,.3,.7
!type=2^2+2^3+2^5
plot,[0,0],[min(level),max(level)],xrange=[0,10],yrange=[min(level),max(level)],$
      charsize=1.5,charthick=2,color=0,title='# LOP Points         '
xbox=[0,10,10,0,0]
y1=min(level)
dy=(max(level)-min(level))/float(nlvls)
for j=0,nlvls-1 do begin
    ybox=[y1,y1,y1+dy,y1+dy,y1]
    polyfill,xbox,ybox,color=col1(j)
    y1=y1+dy
endfor
;
; plot zonal mean ambient
;
;!type=2^2+2^3
;level=0.5*findgen(nlvls)
;set_viewport,.15,.35,.4,.6
;contour,o3a2d,latbin,th,xrange=[-90.,90.],yrange=[400.,2000.],title='Ambient',/noeras,color=0,xticks=6,$
;     xtitle='Latitude',charsize=1.5,ytitle='Theta (K)',c_color=col1,/cell_fill,level=level,min_value=-99
;contour,o3a2d,latbin,th,/overplot,level=level,color=0,/follow,min_value=-99
;
;set_viewport,.4,.6,.4,.6
;contour,o3h2d,latbin,th,xrange=[-90.,90.],yrange=[400.,2000.],title='Anticyclone',/noeras,color=0,xticks=6,$
;     xtitle='Latitude',charsize=1.5,c_color=col1,/cell_fill,level=level,min_value=-99
;contour,o3h2d,latbin,th,/overplot,level=level,color=0,/follow,min_value=-99
;
;set_viewport,.65,.85,.4,.6
;contour,o3lop2d,latbin,th,xrange=[-90.,90.],yrange=[400.,2000.],title='LOPs',/noeras,color=0,xticks=6,$
;     xtitle='Latitude',charsize=1.5,c_color=col1,/cell_fill,level=level,min_value=-99
;contour,o3lop2d,latbin,th,/overplot,level=level,color=0,/follow,min_value=-99
;
;!type=2^2+2^3
;level=-2.5+0.25*findgen(nlvls)
;set_viewport,.25,.45,.1,.3
;index=where(o3a2d ne -99. and o3h2d ne -99.)
;diff=0.*o3a2d
;diff(index)=o3h2d(index)-o3a2d(index)
;index=where(o3a2d eq -99. or o3h2d eq -99.)
;if index(0) ne -1L then diff(index)=-99.
;contour,diff,latbin,th,xrange=[-90.,90.],yrange=[400.,2000.],title='Ant-Ambient',/noeras,color=0,xticks=6,$
;     xtitle='Latitude',charsize=1.5,ytitle='Theta (K)',c_color=col1,/cell_fill,level=level,min_value=-99
;index=where(level gt 0.)
;contour,diff,latbin,th,/overplot,level=level(index),color=0,/follow,min_value=-99
;index=where(level lt 0.)
;contour,diff,latbin,th,/overplot,level=level(index),color=mcolor,/follow,min_value=-99
;
;set_viewport,.55,.75,.1,.3
;index=where(o3a2d ne -99. and o3lop2d ne -99.)
;diff=0.*o3a2d
;diff(index)=o3lop2d(index)-o3a2d(index)
;index=where(o3a2d eq -99. or o3lop2d eq -99.)
;if index(0) ne -1L then diff(index)=-99.
;contour,diff,latbin,th,xrange=[-90.,90.],yrange=[400.,2000.],title='LOP-Ambient',/noeras,color=0,xticks=6,$
;     xtitle='Latitude',charsize=1.5,ytitle='Theta (K)',c_color=col1,/cell_fill,level=level,min_value=-99
;index=where(level gt 0.)
;contour,diff,latbin,th,/overplot,level=level(index),color=0,/follow,min_value=-99
;index=where(level lt 0.)
;contour,diff,latbin,th,/overplot,level=level(index),color=mcolor,/follow,min_value=-99
;
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim mls_lops_yz.ps -rotate -90 mls_lops_yz.jpg'
endif

end
