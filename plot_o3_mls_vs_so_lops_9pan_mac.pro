;
; compare MLS and SO ozone profiles in 9 lops btw August 2004 and March 2006
;
@stddat
@kgmt
@ckday
@kdate

loadct,39
device,decompose=0
mcolor=byte(fix(!p.color))
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
   device,/landscape,bits=8,filename='o3_mls_vs_so_lops_9pan.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
dirs2='/Users/harvey/SOSST_data/'	;/aura3/data/SAGE_II_data/Datfiles_SOSST/'
dirs3='/Users/harvey/SOSST_data/'	;/aura3/data/SAGE_III_data/Datfiles_SOSST/'
diri='/Users/harvey/SOSST_data/'	;/aura3/data/ILAS_data/Datfiles_SOSST/'
dirh='/Users/harvey/SOSST_data/'	;/aura3/data/HALOE_data/Datfiles_SOSST/'
dirp='/Users/harvey/SOSST_data/'	;/aura3/data/POAM_data/Datfiles_SOSST/'
dira='/Users/harvey/SOSST_data/'	;/aura3/data/ACE_data/Datfiles_SOSST/v2.2/'
;
; loop over 9 lop start and end dates
;
lop_sdate=[20041106L,20041208L,20050218L,20051021L,20051124L,20041001L,20050714L,20050724L,20050921L]
lop_edate=[20041112L,20050214L,20050327L,20051107L,20060120L,20041022L,20050726L,20050810L,20050930L]
ymin_date=[45.,33.,50.,68.,59.,-81.,-49.,-49.,-66.]
ymax_date=[68.,68.,79.,78.,69.,-50.,-30.,-30.,-50.]
nloptot=n_elements(lop_sdate)

for ilop=0L,nloptot-1L do begin
sdate=strcompress(lop_sdate(ilop),/remove_all)
edate=strcompress(lop_edate(ilop),/remove_all)
lstyr=long(strmid(sdate,0,4))
lstmn=long(strmid(sdate,4,2))
lstdy=long(strmid(sdate,6,2))
ledyr=long(strmid(edate,0,4))
ledmn=long(strmid(edate,4,2))
leddy=long(strmid(edate,6,2))
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
sdate_save=strarr(nday)
ldate_save=strarr(nday)

print,lstyr,lstmn,lstdy
print,ledyr,ledmn,leddy,nday

iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)

syr=strtrim(string(iyr),2)
sdy=string(FORMAT='(i2.2)',idy)
smn=string(FORMAT='(i2.2)',imn)
idate=long(smn+sdy)
; 
; restore SO catalogs and isentropic ozone on initial day
;
; SAGE II
dates2_all=[-99.]
if iyr lt 2006 then begin
   restore,dirs2+'cat_sage2_v6.2.'+syr
   restore,dirs2+'o3_sage2_v6.2_theta.'+syr
   index=where(latitude ge ymin_date(ilop) and latitude le ymax_date(ilop) and $
               longitude ge 90. and longitude le 270.)
   if index(0) ne -1L then begin
      tmp=date
      dates2_all=tmp(index)
      ysage2_all=latitude(index)
      xsage2_all=longitude(index)
      o3sage2_all=mix(index,*)
   endif
endif
;
; SAGE III
dates3_all=[-99.]
if iyr ge 2002 and iyr lt 2006 then begin
   restore,dirs3+'cat_sage3_v3.00.'+syr
   restore,dirs3+'o3mlr_sage3_v3.00_theta.'+syr
   index=where(latitude ge ymin_date(ilop) and latitude le ymax_date(ilop) and $
               longitude ge 90. and longitude le 270.)
   if index(0) ne -1L then begin
      tmp=date
      dates3_all=tmp(index)
      ysage3_all=latitude(index)
      xsage3_all=longitude(index)
      o3sage3_all=mix(index,*)
   endif
endif
;
; HALOE
dateh_all=[-99.]
if iyr lt 2006 then begin
   restore,dirh+'cat_haloe_v19.'+syr
   restore,dirh+'o3_haloe_v19_theta.'+syr
   index=where(latitude ge ymin_date(ilop) and latitude le ymax_date(ilop) and $
               longitude ge 90. and longitude le 270.)
   if index(0) ne -1L then begin
      tmp=date
      dateh_all=tmp(index)
      yhal_all=latitude(index)
      xhal_all=longitude(index)
      o3hal_all=mix(index,*)
   endif
endif
;
; POAM
datep_all=[-99.]
if iyr ge 1998 and iyr lt 2006 then begin
   restore,dirp+'cat_poam3_v4.0.'+syr
   restore,dirp+'o3_poam3_v4.0_theta.'+syr
   index=where(latitude ge ymin_date(ilop) and latitude le ymax_date(ilop) and $
               longitude ge 90. and longitude le 270.)
   if index(0) ne -1L then begin
      tmp=date
      datep_all=tmp(index)
      ypoam_all=latitude(index)
      xpoam_all=longitude(index)
      o3poam_all=mix(index,*)
   endif
endif
;
; ACE
datea_all=[-99.]
if iyr ge 2004 then begin
   restore,dira+'cat_ace_v2.2.'+syr
   restore,dira+'o3_ace_v2.2_theta.'+syr
   index=where(latitude ge ymin_date(ilop) and latitude le ymax_date(ilop) and $
               longitude ge 90. and longitude le 270.)
   if index(0) ne -1L then begin
      tmp=date
      datea_all=tmp(index)
      yace_all=latitude(index)
      xace_all=longitude(index)
      o3ace_all=mix(index,*)
   endif
endif
; ---have full year of SOSST ozone---
;
; initialize MLS variables
;
AO3_all=[-99.]
ATH_all=[-99.]
AT_all=[-99.]
AX_all=[-99.]
AY_all=[-99.]
HO3_all=[-99.]
HTH_all=[-99.]
HT_all=[-99.]
HX_all=[-99.]
HY_all=[-99.]
O3LOP_all=[-99.]
THLOP_all=[-99.]
TLOP_all=[-99.]
XLOP_all=[-99.]
YLOP_all=[-99.]

iday = iday - 1
icount=0L
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,plotit

      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      smn=string(FORMAT='(i2.2)',imn)
      idate=long(smn+sdy)
      sdate_save(icount)=syr+smn+sdy
      ldate_save(icount)=long(syr+smn+sdy)
;
; restore MLS LOP information
;
      if ymin_date(ilop) gt 0. then begin
         dum=findfile('Datfiles_MLS/mls_nhDLlop_'+syr+smn+sdy+'.sav')
         if dum(0) ne '' then begin
            restore,'Datfiles_MLS/mls_nhDLlop_'+syr+smn+sdy+'.sav
            ao3_all=[ao3_all,AO3_SAVE]
            ath_all=[ath_all,ATH_SAVE]
            at_all=[at_all,AT_SAVE]
            ax_all=[ax_all,AX_SAVE]
            ay_all=[ay_all,AY_SAVE]
            ho3_all=[ho3_all,HO3_SAVE]
            hth_all=[hth_all,HTH_SAVE]
            ht_all=[ht_all,HT_SAVE]
            hx_all=[hx_all,HX_SAVE]
            hy_all=[hy_all,HY_SAVE]
            o3lop_all=[o3lop_all,O3LOP_SAVE]
            thlop_all=[thlop_all,THLOP_SAVE]
            tlop_all=[tlop_all,TLOP_SAVE]
            xlop_all=[xlop_all,XLOP_SAVE]
            ylop_all=[ylop_all,YLOP_SAVE]
         endif
      endif
      if ymin_date(ilop) lt 0. then begin
         dum=findfile('Datfiles_MLS/mls_sh135Elop_'+syr+smn+sdy+'.sav')
         if dum(0) ne '' then begin
            restore,'Datfiles_MLS/mls_sh135Elop_'+syr+smn+sdy+'.sav
            ao3_all=[ao3_all,AO3_SAVE]
            ath_all=[ath_all,ATH_SAVE]
            at_all=[at_all,AT_SAVE]
            ax_all=[ax_all,AX_SAVE]
            ay_all=[ay_all,AY_SAVE]
            ho3_all=[ho3_all,HO3_SAVE]
            hth_all=[hth_all,HTH_SAVE]
            ht_all=[ht_all,HT_SAVE]
            hx_all=[hx_all,HX_SAVE]
            hy_all=[hy_all,HY_SAVE]
            o3lop_all=[o3lop_all,O3LOP_SAVE]
            thlop_all=[thlop_all,THLOP_SAVE]
            tlop_all=[tlop_all,TLOP_SAVE]
            xlop_all=[xlop_all,XLOP_SAVE]
            ylop_all=[ylop_all,YLOP_SAVE]
         endif
      endif
;
; restore catalogs on 1 January
;
      if iday eq 1L then begin
;
; SAGE II
         if iyr lt 2006 then begin
            restore,dirs2+'cat_sage2_v6.2.'+syr
            restore,dirs2+'o3_sage2_v6.2_theta.'+syr
            index=where(latitude ge ymin_date(ilop) and latitude le ymax_date(ilop)  and $
               longitude ge 90. and longitude le 270.)
            if index(0) ne -1L then begin
               if dates2_all(0) eq -99. then begin
                  tmp=date
                  dates2_all=tmp(index)
                  ysage2_all=latitude(index)
                  xsage2_all=longitude(index)
                  o3sage2_all=mix(index,*)
               endif
               if dates2_all(0) ne -99. then begin
                  tmp=date
                  dates2_all=[dates2_all,tmp(index)]
                  ysage2_all=[ysage2_all,latitude(index)]
                  xsage2_all=[xsage2_all,longitude(index)]
                  o3sage2_all=[o3sage2_all,mix(index,*)]
               endif
            endif
         endif
;
; SAGE III
         if iyr ge 2002 and iyr lt 2006 then begin
            restore,dirs3+'cat_sage3_v3.00.'+syr
            restore,dirs3+'o3mlr_sage3_v3.00_theta.'+syr
            index=where(latitude ge ymin_date(ilop) and latitude le ymax_date(ilop)  and $
               longitude ge 90. and longitude le 270.)
            if index(0) ne -1L then begin
               if dates3_all(0) eq -99. then begin
                  tmp=date
                  dates3_all=tmp(index)
                  ysage3_all=latitude(index)
                  xsage3_all=longitude(index)
                  o3sage3_all=mix(index,*)
               endif
               if dates3_all(0) ne -99. then begin
                  tmp=date
                  dates3_all=[dates3_all,tmp(index)]
                  ysage3_all=[ysage3_all,latitude(index)]
                  xsage3_all=[xsage3_all,longitude(index)]
                  o3sage3_all=[o3sage3_all,mix(index,*)]
               endif
            endif
         endif
;
; HALOE
         if iyr lt 2006 then begin
            restore,dirh+'cat_haloe_v19.'+syr
            restore,dirh+'o3_haloe_v19_theta.'+syr
            index=where(latitude ge ymin_date(ilop) and latitude le ymax_date(ilop)  and $
               longitude ge 90. and longitude le 270.)
            if index(0) ne -1L then begin
               if dateh_all(0) eq -99. then begin
                  tmp=date
                  dateh_all=tmp(index)
                  yhal_all=latitude(index)
                  xhal_all=longitude(index)
                  o3hal_all=mix(index,*)
               endif
               if dateh_all(0) ne -99. then begin
                  tmp=date
                  dateh_all=[dateh_all,tmp(index)]
                  yhal_all=[yhal_all,latitude(index)]
                  xhal_all=[xhal_all,longitude(index)]
                  o3hal_all=[o3hal_all,mix(index,*)]
               endif
            endif
         endif
;
; POAM
         if iyr ge 1998 and iyr lt 2006 then begin
            restore,dirp+'cat_poam3_v4.0.'+syr
            restore,dirp+'o3_poam3_v4.0_theta.'+syr
            index=where(latitude ge ymin_date(ilop) and latitude le ymax_date(ilop)  and $
               longitude ge 90. and longitude le 270.)
            if index(0) ne -1L then begin
               if datep_all(0) eq -99. then begin
                  tmp=date
                  datep_all=tmp(index)
                  ypoam_all=latitude(index)
                  xpoam_all=longitude(index)
                  o3poam_all=mix(index,*)
               endif
               if datep_all(0) ne -99. then begin
                  tmp=date
                  datep_all=[datep_all,tmp(index)]
                  ypoam_all=[ypoam_all,latitude(index)]
                  xpoam_all=[xpoam_all,longitude(index)]
                  o3poam_all=[o3poam_all,mix(index,*)]
               endif
            endif
         endif
;
; ACE
         if iyr ge 2004 then begin
            restore,dira+'cat_ace_v2.2.'+syr
            restore,dira+'o3_ace_v2.2_theta.'+syr
            index=where(latitude ge ymin_date(ilop) and latitude le ymax_date(ilop)  and $
               longitude ge 90. and longitude le 270.)
            if index(0) ne -1L then begin
               if datea_all(0) eq -99. then begin
                  tmp=date
                  datea_all=tmp(index)
                  yace_all=latitude(index)
                  xace_all=longitude(index)
                  o3ace_all=mix(index,*)
               endif
               if datea_all(0) ne -99. then begin
                  tmp=date
                  datea_all=[datea_all,tmp(index)]
                  yace_all=[yace_all,latitude(index)]
                  xace_all=[xace_all,longitude(index)]
                  o3ace_all=[o3ace_all,mix(index,*)]
               endif
            endif
         endif
      endif
      icount=icount+1L
goto,jump
plotit:
;
; remove -99 from MLS
;
index=where(ao3_all ne -99.)
ao3_all=ao3_all(index)
ath_all=ath_all(index)
at_all=at_all(index)
ax_all=ax_all(index)
ay_all=ay_all(index)
index=where(ho3_all ne -99.)
ho3_all=ho3_all(index)
hth_all=hth_all(index)
ht_all=ht_all(index)
hx_all=hx_all(index)
hy_all=hy_all(index)
index=where(o3lop_all ne -99.)
o3lop_all=o3lop_all(index)
thlop_all=thlop_all(index)
tlop_all=tlop_all(index)
xlop_all=xlop_all(index)
ylop_all=ylop_all(index)
;
; extract daily SOSST data over LOP date and longitude range
;
      norbits3=0L & norbits2=0L & norbitp=0L & norbith=0L & norbiti=0L & norbita=0L

      sage2day=where(dates2_all ge long(sdate) and dates2_all le long(edate) and $
                     xsage2_all ge min(ax_all) and xsage2_all le max(ax_all),norbits2)
      if norbits2 le 1L then goto,jumpsage2
      o3sage2=reform(o3sage2_all(sage2day,*))
      thsage2=0.*o3sage2
      nth=n_elements(theta)
      for k=0L,nth-1L do thsage2(*,k)=theta(k)
      ysage2=reform(ysage2_all(sage2day))
      xsage2=reform(xsage2_all(sage2day))
jumpsage2:
      sage3day=where(dates3_all ge long(sdate) and dates3_all le long(edate) and $
                     xsage3_all ge min(ax_all) and xsage3_all le max(ax_all),norbits3)
      if norbits3 le 1L then goto,jumpsage3
      o3sage3=reform(o3sage3_all(sage3day,*))
      thsage3=0.*o3sage3
      for k=0L,nth-1L do thsage3(*,k)=theta(k)
      ysage3=reform(ysage3_all(sage3day))
      xsage3=reform(xsage3_all(sage3day))
jumpsage3:
      halday=where(dateh_all ge long(sdate) and dateh_all le long(edate) and $
                   xhal_all ge min(ax_all) and xhal_all le max(ax_all),norbith)
      if norbith le 1L then goto,jumphal
      o3hal=reform(o3hal_all(halday,*))
      thhal=0.*o3hal
      for k=0L,nth-1L do thhal(*,k)=theta(k)
      yhal=reform(yhal_all(halday))
      xhal=reform(xhal_all(halday))
jumphal:
      poamday=where(datep_all ge long(sdate) and datep_all le long(edate) and $
                    xpoam_all ge min(ax_all) and xpoam_all le max(ax_all),norbitp)
      if norbitp le 1L then goto,jumppoam
      o3poam=reform(o3poam_all(poamday,*))
      thpoam=0.*o3poam
      for k=0L,nth-1L do thpoam(*,k)=theta(k)
      ypoam=reform(ypoam_all(poamday))
      xpoam=reform(xpoam_all(poamday))
jumppoam:
      aceday=where(datea_all ge long(sdate) and datea_all le long(edate) and $
                   xace_all ge min(ax_all) and xace_all le max(ax_all),norbita)
      if norbita le 1L then goto,jumpace
      o3ace=reform(o3ace_all(aceday,*))
      thace=0.*o3ace
      for k=0L,nth-1L do thace(*,k)=theta(k)
      yace=reform(yace_all(aceday))
      xace=reform(xace_all(aceday))
jumpace:
print,norbits2,norbits3,norbitp,norbith,norbita
;
; check
;
erase
!type=12
set_viewport,.3,.7,.525,.925
ihem=1.
if ymin_date(ilop) lt 0. then ihem=-1.
map_set,ihem*90,-180,0,/stereo,/contin,/grid,/noeras,color=0,title=sdate+' - '+edate,charsize=2
loadct,0
oplot,ax_all,ay_all,psym=8,color=150
oplot,hx_all,hy_all,psym=8,symsize=2,color=150
oplot,xlop_all,ylop_all,psym=8,symsize=2,color=0
loadct,39
if norbits2 gt 1L then oplot,xsage2,ysage2,psym=8,color=.15*mcolor,symsize=2
if norbits3 gt 1L then begin
   flag=fltarr(norbits3)
   for i=0L,norbits3-1L do if max(o3sage3(i,*)) eq -99. then flag(i)=-99.
   index=where(flag eq 0.,norbits3)
   if index(0) ne -1L then oplot,xsage3(index),ysage3(index),psym=8,color=.3*mcolor,symsize=2
endif
if norbitp gt 1L then oplot,xpoam,ypoam,psym=8,color=.4*mcolor,symsize=2
if norbith gt 1L then oplot,xhal,yhal,psym=8,color=.75*mcolor,symsize=1
if norbita gt 1L then oplot,xace,yace,psym=8,color=.9*mcolor,symsize=1

set_viewport,.3,.7,.1,.5
plot,findgen(10),findgen(10),/nodata,xrange=[1.,9.],yrange=[500.,1600.],/noeras,color=0,$
     xtitle='Ozone',ytitle='Theta',charsize=1.5
xyouts,1.2,1200,'SAGE II',color=mcolor*.15,/data,charsize=1.5,charthick=2
if norbits2 gt 1L then xyouts,2.8,1200,'('+strcompress(norbits2,/remove_all)+')',color=.15*mcolor,charsize=1.5,charthick=2,/data
xyouts,1.2,1125,'SAGE III',color=mcolor*.3,/data,charsize=1.5,charthick=2
if norbits3 gt 1L then xyouts,2.8,1125,'('+strcompress(norbits3,/remove_all)+')',color=.3*mcolor,charsize=1.5,charthick=2,/data
xyouts,1.2,1050,'POAM III',color=mcolor*.4,/data,charsize=1.5,charthick=2
if norbitp gt 1L then xyouts,2.8,1050,'('+strcompress(norbitp,/remove_all)+')',color=.4*mcolor,charsize=1.5,charthick=2,/data
xyouts,1.2,975,'HALOE',color=mcolor*.75,/data,charsize=1.5,charthick=2
if norbith gt 1L then xyouts,2.8,975,'('+strcompress(norbith,/remove_all)+')',color=.75*mcolor,charsize=1.5,charthick=2,/data
xyouts,1.2,900,'ACE',color=mcolor*.9,/data,charsize=1.5,charthick=2
if norbita gt 1L then xyouts,2.8,900,'('+strcompress(norbita,/remove_all)+')',color=.9*mcolor,charsize=1.5,charthick=2,/data


if norbits2 gt 1L then begin
   for ii=0L,norbits2-1L do begin
       o3prof=reform(o3sage2(ii,*)) & thprof=reform(thsage2(ii,*))
       index=where(o3prof ne -99.)
;      if index(0) ne -1L then oplot,1.e6*o3prof(index),thprof(index),psym=0,color=mcolor*.15,thick=1
   endfor
   o3sage2_mean=fltarr(nth)
   o3sage2_sigma=fltarr(nth)
   for k=0L,nth-1L do begin
       index=where(o3sage2(*,k) ne -99.,ngood)
       if ngood gt 2L then begin
          result=moment(o3sage2(index,k))
          o3sage2_mean(k)=result(0)
          o3sage2_sigma(k)=sqrt(result(1))
       endif
   endfor
   index=where(o3sage2_mean gt 0.)
   oplot,1.e6*o3sage2_mean(index),theta(index),psym=0,color=mcolor*.15,thick=5
   oplot,1.e6*o3sage2_mean(index)+1.e6*o3sage2_sigma(index),theta(index),psym=0,color=mcolor*.15,thick=3,linestyle=5
   oplot,1.e6*o3sage2_mean(index)-1.e6*o3sage2_sigma(index),theta(index),psym=0,color=mcolor*.15,thick=3,linestyle=5
endif
if norbits3 gt 1L then begin
   for ii=0L,norbits3-1L do begin
       o3prof=reform(o3sage3(ii,*)) & thprof=reform(thsage3(ii,*))
       index=where(o3prof ne -99.)
;      if index(0) ne -1L then oplot,1.e6*o3prof(index),thprof(index),psym=0,color=mcolor*.3,thick=1
   endfor
   o3sage3_mean=fltarr(nth)
   o3sage3_sigma=fltarr(nth)
   for k=0L,nth-1L do begin
       index=where(o3sage3(*,k) ne -99.,ngood)
       if ngood gt 2L then begin
          result=moment(o3sage3(index,k))
          o3sage3_mean(k)=result(0)
          o3sage3_sigma(k)=sqrt(result(1))
       endif
   endfor 
   index=where(o3sage3_mean gt 0.)
   if index(0) ne -1L then begin
   oplot,1.e6*o3sage3_mean(index),theta(index),psym=0,color=mcolor*.3,thick=5
   oplot,1.e6*o3sage3_mean(index)+1.e6*o3sage3_sigma(index),theta(index),psym=0,color=mcolor*.3,thick=3,linestyle=5
   oplot,1.e6*o3sage3_mean(index)-1.e6*o3sage3_sigma(index),theta(index),psym=0,color=mcolor*.3,thick=3,linestyle=5
   endif
endif
if norbitp gt 1L then begin
   for ii=0L,norbitp-1L do begin
       o3prof=reform(o3poam(ii,*)) & thprof=reform(thpoam(ii,*))
       index=where(o3prof ne -99.)
;      if index(0) ne -1L then oplot,1.e6*o3prof(index),thprof(index),psym=0,color=mcolor*.4,thick=1
   endfor
   o3poam_mean=fltarr(nth)
   o3poam_sigma=fltarr(nth)
   for k=0L,nth-1L do begin
       index=where(o3poam(*,k) ne -99.,ngood)
       if ngood gt 2L then begin
          result=moment(o3poam(index,k))
          o3poam_mean(k)=result(0)
          o3poam_sigma(k)=sqrt(result(1))
       endif
   endfor
   index=where(o3poam_mean gt 0.)
   oplot,1.e6*o3poam_mean(index),theta(index),psym=0,color=mcolor*.4,thick=5
   oplot,1.e6*o3poam_mean(index)+1.e6*o3poam_sigma(index),theta(index),psym=0,color=mcolor*.4,thick=3,linestyle=5
   oplot,1.e6*o3poam_mean(index)-1.e6*o3poam_sigma(index),theta(index),psym=0,color=mcolor*.4,thick=3,linestyle=5
endif
if norbith gt 1L then begin
   for ii=0L,norbith-1L do begin
       o3prof=reform(o3hal(ii,*)) & thprof=reform(thhal(ii,*))
       index=where(o3prof ne -99.)
;      if index(0) ne -1L then oplot,1.e6*o3prof(index),thprof(index),psym=0,color=mcolor*.75,thick=1
   endfor
   o3hal_mean=fltarr(nth)
   o3hal_sigma=fltarr(nth)
   for k=0L,nth-1L do begin
       index=where(o3hal(*,k) ne -99.,ngood)
       if ngood gt 2L then begin
          result=moment(o3hal(index,k))
          o3hal_mean(k)=result(0)
          o3hal_sigma(k)=sqrt(result(1))
       endif
   endfor
   index=where(o3hal_mean gt 0.)
   oplot,1.e6*o3hal_mean(index),theta(index),psym=0,color=mcolor*.75,thick=5
   oplot,1.e6*o3hal_mean(index)+1.e6*o3hal_sigma(index),theta(index),psym=0,color=mcolor*.75,thick=3,linestyle=5
   oplot,1.e6*o3hal_mean(index)-1.e6*o3hal_sigma(index),theta(index),psym=0,color=mcolor*.75,thick=3,linestyle=5
endif
if norbita gt 1L then begin
   for ii=0L,norbita-1L do begin
       o3prof=reform(o3ace(ii,*)) & thprof=reform(thace(ii,*))
       index=where(o3prof ne -99.)
;      if index(0) ne -1L then oplot,1.e6*o3prof(index),thprof(index),psym=0,color=mcolor*.9,thick=1
   endfor
   o3ace_mean=fltarr(nth)
   o3ace_sigma=fltarr(nth)
   for k=0L,nth-1L do begin
       index=where(o3ace(*,k) ne -99.,ngood)
       if ngood gt 2L then begin
          result=moment(o3ace(index,k))
          o3ace_mean(k)=result(0)
          o3ace_sigma(k)=sqrt(result(1))
       endif
   endfor
   index=where(o3ace_mean gt 0.)
   oplot,1.e6*o3ace_mean(index),theta(index),psym=0,color=mcolor*.9,thick=5
   oplot,1.e6*o3ace_mean(index)+1.e6*o3ace_sigma(index),theta(index),psym=0,color=mcolor*.9,thick=3,linestyle=5
   oplot,1.e6*o3ace_mean(index)-1.e6*o3ace_sigma(index),theta(index),psym=0,color=mcolor*.9,thick=3,linestyle=5
endif

loadct,0
ao3_mean=fltarr(nth)
ao3_sigma=fltarr(nth)
ho3_mean=fltarr(nth)
ho3_sigma=fltarr(nth)
lopo3_mean=fltarr(nth)
lopo3_sigma=fltarr(nth)
for k=0L,nth-1L do begin
    index=where(ath_all eq theta(k),ngood)
    if ngood gt 2L then begin
       result=moment(ao3_all(index))
       ao3_mean(k)=result(0)
       ao3_sigma(k)=sqrt(result(1))
    endif
    index=where(hth_all eq theta(k),ngood)
    if ngood gt 2L then begin
       result=moment(ho3_all(index))
       ho3_mean(k)=result(0)
       ho3_sigma(k)=sqrt(result(1))
    endif
    index=where(thlop_all eq theta(k),ngood)
    if ngood gt 2L then begin
       result=moment(o3lop_all(index))
       lopo3_mean(k)=result(0)
       lopo3_sigma(k)=sqrt(result(1))
    endif
endfor
index=where(ao3_mean gt 0.)
oplot,ao3_mean(index),theta(index),psym=0,color=150,thick=7
;oplot,ao3_mean(index)+ao3_sigma(index),theta(index),psym=0,color=50,thick=5,linestyle=5
;oplot,ao3_mean(index)-ao3_sigma(index),theta(index),psym=0,color=50,thick=5,linestyle=5

index=where(ho3_mean gt 0.)
;oplot,ho3_mean(index),theta(index),psym=0,color=150,thick=5
;oplot,ho3_mean(index)+ho3_sigma(index),theta(index),psym=0,color=100,thick=5,linestyle=5
;oplot,ho3_mean(index)-ho3_sigma(index),theta(index),psym=0,color=100,thick=5,linestyle=5

index=where(lopo3_mean gt 0.)
oplot,lopo3_mean(index),theta(index),psym=0,color=0,thick=7
;oplot,lopo3_mean(index)+lopo3_sigma(index),theta(index),psym=0,color=0,thick=5,linestyle=5
;oplot,lopo3_mean(index)-lopo3_sigma(index),theta(index),psym=0,color=0,thick=5,linestyle=5

loadct,39
stop

endfor	; loop over 9 pockets

if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim o3_mls_vs_so_lops_9pan.ps -rotate -90 o3_mls_vs_so_lops_9pan.jpg'
endif
end
