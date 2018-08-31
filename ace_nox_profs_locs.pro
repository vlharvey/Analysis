;
; plot locations of individual profile locations
; of the two mean NOx profiles for Erin Wood
; VLH 3/28/09
;
@rd_ukmo_nc3
@stddat
@kgmt
@ckday
@kdate

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
setplot='x'
read,'setplot=',setplot
nxdim=750 & nydim=750
xorig=[0.15]
yorig=[0.25]
xlen=0.7
ylen=0.5
cbaryoff=0.015
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=0
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=icolmax
endif
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
nmon=['01','02','03','04','05','06','07','08','09','10','11','12']
dira='/aura3/data/ACE_data/Datfiles_SOSST/v2.2/'
ifile='                             '
lstmn=1 & lstdy=15 & lstyr=2009 & lstday=0
ledmn=1 & leddy=15 & ledyr=2009 & ledday=0
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
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; test for end condition and close windows.
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
;
; read UKMO data
;
      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      smn=string(FORMAT='(i2.2)',imn)
      sdate=syr+smn+sdy
      idate=long(smn+sdy)
;
; restore ACE yearly files on first day or Jan 1
;
      if iday eq 1L or icount eq 0L then begin
         dateace_all=[-99.]
         if iyr ge 2004 then begin
            restore,dira+'cat_ace_v2.2.'+syr
            restore,dira+'no2_ace_v2.2.'+syr
            dateace_all=date
            yace_all=latitude
            xace_all=longitude
            no2ace_all=mix
            restore,dira+'no_ace_v2.2.'+syr
            noace_all=mix
            noxace_all=-99.+0.*noace_all
            index=where(no2ace_all ne -99. and noace_all ne -99.)
            if index(0) ne -1L then noxace_all(index)=(no2ace_all(index)+noace_all(index))*1.e6
         endif
      endif
;
; extract daily SOSST data
;
      norbita=0L
      aceday=where(dateace_all eq iyr*10000L+idate,norbita)
      if norbita le 1L then goto,jump
      noxace=reform(noxace_all(aceday,*))
      nleva=n_elements(altitude)
      yace=reform(yace_all(aceday))
      xace=reform(xace_all(aceday))
      tace=reform(time(aceday))
;
; postscript file
;
      if setplot eq 'ps' then begin
         lc=0
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !psym=0
         !p.font=0
         device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
                /bold,/color,bits_per_pixel=8,/helvetica,filename='ace_nox_profs_locs_'+sdate+'.ps'
         !p.charsize=1.25
         !p.thick=2
         !p.charthick=5
         !p.charthick=5
         !y.thick=2
         !x.thick=2
      endif
      erase
      !type=2^2+2^3
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
;
; daily mean NOx profiles
;
      nhnox_prof=fltarr(nleva)
      shnox_prof=fltarr(nleva)
      nhindex=where(yace gt 0.)
      nhymean=mean(yace(nhindex))
      nhxmean=mean(xace(nhindex))
      nhtmean=mean(tace(nhindex))
      nhnox=reform(noxace(nhindex,*))

print,n_elements(nhindex),' NH profiles'
print,'NH Lats ',yace(nhindex)
print,'NH Lons ',xace(nhindex)
print,'NH Times ',tace(nhindex)
print,'NH Average Lat, Lon, Time',nhymean,nhxmean,nhtmean

      shindex=where(yace lt 0.)
      shymean=mean(yace(shindex))
      shxmean=mean(xace(shindex))
      shtmean=mean(tace(shindex))
      shnox=reform(noxace(shindex,*))

print,n_elements(shindex),' SH profiles'
print,'SH Lats ',yace(shindex)
print,'SH Lons ',xace(shindex)
print,'SH Times ',tace(shindex)
print,'SH Average Lat, Lon, Time',shymean,shxmean,shtmean

map_set,0,0,0,/contin,/grid,color=0,title=sdate+' ACE profiles'
oplot,xace(nhindex),yace(nhindex),symsize=2,psym=8,color=mcolor*.3
oplot,xace(shindex),yace(shindex),symsize=2,psym=8,color=mcolor*.9

      for k=0L,nleva-1L do begin
          index=where(nhnox(*,k) ne -99.)
          if index(0) ne -1L then nhnox_prof(k)=mean(nhnox(index,k))
          index=where(shnox(*,k) ne -99.)
          if index(0) ne -1L then shnox_prof(k)=mean(shnox(index,k))
      endfor

      if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device, /close
         spawn,'convert -trim ace_nox_profs_locs_'+sdate+'.ps -rotate -90 ace_nox_profs_locs_'+sdate+'.jpg'
         spawn,'/usr/bin/rm ace_nox_profs_locs_'+sdate+'.ps'
      endif
      icount=icount+1L
goto,jump
end
