;
; nearby ambient using range_ring
; first look at WACCM 3 LOP climatology
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
   device,/landscape,bits=8,filename='wa3_lops_depth_yt.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
lstmn=1 & lstdy=1 & lstyr=1992 & lstday=0
ledmn=1 & leddy=1 & ledyr=2004 & ledday=0
;read,' Enter starting year ',lstyr
;read,' Enter ending year ',ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1990 then stop,'Year out of range '
if ledyr lt 1990 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

nday=ledday-lstday+1L
fdoy_save=fltarr(nday)
sdate_save=strarr(nday)
ldate_save=strarr(nday)
nlat=35L
latbin=-85+5.*findgen(nlat)
thmaxnh=-9999+0.*fltarr(nday,nlat)
thminnh=9999+0.*fltarr(nday,nlat)
thmaxsh=-9999+0.*fltarr(nday,nlat)
thminsh=9999+0.*fltarr(nday,nlat)
nhighnh=lonarr(nday,nlat)
nhighsh=lonarr(nday,nlat)
;goto,plotit

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
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,plotit

      fdoy_save(icount)=icount

      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      smn=string(FORMAT='(i2.2)',imn)
      sdate_save(icount)=syr+smn+sdy
      ldate_save(icount)=long(syr+smn+sdy)
      print,syr+smn+sdy,icount
;
; restore NH WACCM 3 LOPs
;
      dy=latbin(1)-latbin(0)
      dum=findfile('/aura3/data/WACCM_data/Datfiles/wa3_nhDLlop_'+syr+smn+sdy+'.sav')
      if dum(0) eq '' then goto,jump2sh
      restore,'/aura3/data/WACCM_data/Datfiles/wa3_nhDLlop_'+syr+smn+sdy+'.sav'
      nlop=n_elements(YLOP_SAVE)
      for ii=0L,nlop-1L do begin         ; loop over LOP points on this day
      theta=THLOP_SAVE(ii)
      ypos=YLOP_SAVE(ii)
      for j=0L,nlat-1L do begin
          y0=latbin(j)-dy/2.
          y1=latbin(j)+dy/2.
          if y0 le ypos and y1 gt ypos then begin
             if theta gt thmaxnh(icount,j) then thmaxnh(icount,j)=theta
             if theta lt thminnh(icount,j) then thminnh(icount,j)=theta
          endif
      endfor
      endfor

      nlop=n_elements(HO3_SAVE)
      for ii=0L,nlop-1L do begin         ; loop over LOP points on this day
          ypos=HY_SAVE(ii)
          for j=0L,nlat-1L do begin
              y0=latbin(j)-dy/2.
              y1=latbin(j)+dy/2.
              if ypos gt 0. and y0 le ypos and y1 gt ypos then nhighnh(icount,j)=nhighnh(icount,j)+1L
          endfor
      endfor
;
; check lop
;
erase
set_viewport,0.1,0.5,0.3,0.7
!type=2^2+2^3
MAP_SET,90,-90,0,/stereo,/noeras,/grid,/contin,title=syr+smn+sdy+' WA3 LOP',charsize=1.5,color=0,/noborder
oplot,findgen(361),0.2+0.*findgen(361),color=0
oplot,xlop_save,ylop_save,psym=8,color=0,symsize=1
set_viewport,0.6,0.9,0.3,0.7
thmin=500. & thmax=2000.
index=where(ho3mean_save gt 0.)
if index(0) ne -1L then begin
   plot,ho3mean_save(index),th(index),color=0,/nodata,thick=5,psym=0,$
        xrange=[2.,8.],yrange=[thmin,thmax],charsize=1.5,ytitle='Theta'
   oplot,ho3mean_save(index),th(index),color=mcolor*.9,thick=5,psym=0
   oplot,ho3mean_save(index)-ho3sigma_save(index),th(index),color=mcolor*.9,thick=5,psym=0,linestyle=5
   oplot,ho3mean_save(index)+ho3sigma_save(index),th(index),color=mcolor*.9,thick=5,psym=0,linestyle=5
   index=where(ao3mean_save gt 0.)
   if index(0) ne -1L then begin
      oplot,ao3mean_save(index),th(index),color=0,thick=5,psym=0
      oplot,ao3mean_save(index)-ao3sigma_save(index),th(index),color=0,thick=5,psym=0,linestyle=5
      oplot,ao3mean_save(index)+ao3sigma_save(index),th(index),color=0,thick=5,psym=0,linestyle=5
   endif
endif
oplot,o3lop_save,thlop_save,symsize=2.5,psym=8,color=50
max1=reform(thmaxnh(icount,*))
min1=reform(thminnh(icount,*))
index=where(max1 ne -9999. and min1 ne 9999.,npt)
if index(0) ne -1L then begin
   for i=0L,npt-1L do $
       print,'Theta Min/Max ',latbin(index(i)),min1(index(i)),max1(index(i)),max1(index(i))-min1(index(i))
stop
endif
      jump2sh:
;
; restore SH WACCM 3 LOPs
;
      dum=findfile('/aura3/data/WACCM_data/Datfiles/wa3_sh135Elop_'+syr+smn+sdy+'.sav')
      if dum(0) eq '' then goto,jump2count
      restore,'/aura3/data/WACCM_data/Datfiles/wa3_sh135Elop_'+syr+smn+sdy+'.sav
      nlop=n_elements(YLOP_SAVE)
      for ii=0L,nlop-1L do begin         ; loop over LOP points on this day
      theta=THLOP_SAVE(ii)
      ypos=YLOP_SAVE(ii)
      for j=0L,nlat-2L do begin
          if latbin(j) le ypos and latbin(j+1L) gt ypos then begin
             if theta gt thmaxsh(icount,j) then thmaxsh(icount,j)=theta
             if theta lt thminsh(icount,j) then thminsh(icount,j)=theta
          endif
      endfor
      endfor

      nlop=n_elements(HO3_SAVE)
      for ii=0L,nlop-1L do begin         ; loop over LOP points on this day
          ypos=HY_SAVE(ii)
          for j=0L,nlat-1L do begin
              y0=latbin(j)-dy/2.
              y1=latbin(j)+dy/2.
              if ypos lt 0. and y0 le ypos and y1 gt ypos then nhighsh(icount,j)=nhighsh(icount,j)+1L
          endfor
      endfor

      jump2count:
      icount=icount+1L
goto,jump
;
; plot latitude-time section
;
plotit:
;
; uncomment to re-save
;
;thdepthnh=0.*thmaxnh
;index=where(thmaxnh ne -9999. and thminnh ne 9999.)
;if index(0) ne -1L then thdepthnh(index)=thmaxnh(index)-thminnh(index)
;thdepthnh=smooth(thdepthnh,5,/edge_truncate)
;thdepthsh=0.*thmaxsh
;index=where(thmaxsh ne -9999. and thminsh ne 9999.)
;if index(0) ne -1L then thdepthsh(index)=thmaxsh(index)-thminsh(index)
;thdepthsh=smooth(thdepthsh,5,/edge_truncate)
;save,file='WA3_LOP_YT.sav',thmaxnh,thminnh,thmaxsh,thminsh,thdepthnh,thdepthsh,$
;     fdoy_save,sdate_save,ldate_save,latbin,nhighnh,nhighsh,nday
restore,'WA3_LOP_YT.sav'
index=where(thmaxnh ne -9999. and thminnh ne 9999.)
if index(0) ne -1L then thdepthnh(index)=thmaxnh(index)-thminnh(index)
index=where(thmaxsh ne -9999. and thminsh ne 9999.)
if index(0) ne -1L then thdepthsh(index)=thmaxsh(index)-thminsh(index)
;
; set date bounds
;
idate=19911001L & edate=19930401L
;read,' Enter starting date ',idate
;read,' Enter ending date ',edate
index=where(LDATE_SAVE ge idate and LDATE_SAVE le edate)
LDATE_SAVE=reform(ldate_save(index))
fdoy_save=reform(fdoy_save(index))
sdate_save=reform(sdate_save(index))
thdepthnh=reform(thdepthnh(index,*))
thdepthsh=reform(thdepthsh(index,*))
NHIGHNH=reform(NHIGHNH(index,*))
NHIGHSH=reform(NHIGHSH(index,*))
thdepthnhsm=smooth(thdepthnh,5,/edge_truncate)
thdepthshsm=smooth(thdepthsh,5,/edge_truncate)
NHIGHNHsm=smooth(NHIGHNH,5,/edge_truncate)
NHIGHSHsm=smooth(NHIGHSH,5,/edge_truncate)

sdays=strcompress(sdate_save,/remove_all)
xindex=where(strmid(sdays,6,2) eq '15',nxtick)
xlabs=strmid(sdays(xindex),4,2)
erase
level=[50.,100.,200.,300.,500.,800.,1200.]
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
!type=2^2+2^3
set_viewport,.2,.8,.6,.9
contour,thdepthnh,fdoy_save-min(fdoy_save),latbin,levels=level,min_value=-9999.,yrange=[20.,85.],$
        title='WACCM 3 Arctic',/noeras,/cell_fill,c_color=col1,color=0,xticks=nxtick-1L,/nodata,$
;       xtickv=xindex,xtickname=strmid(sdays(xindex),4,2)+'/'+strmid(sdays(xindex),2,2),ytitle='Latitude',charsize=1.5
        xtickv=xindex,xtickname=' '+strarr(n_elements(xindex)+1),ytitle='Latitude',charsize=1.5
loadct,0
;
; contour anticyclone frequency
;
level=200.+200.*findgen(13)
loadct,0
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
col1=reverse(col1)
col1=col1-40
index=where(nhighnh le 0.)
nhighnh(index)=-9999.
contour,nhighnh,fdoy_save-min(fdoy_save),latbin,/overplot,level=level,/cell_fill,c_labels=0*level,$
        c_color=col1,min_value=-9999.
;contour,nhighnh,fdoy_save-min(fdoy_save),latbin,/overplot,level=level,/follow,c_labels=0*level,thick=2,color=0
loadct,38
level=[50.,100.,200.,300.,500.,800.,1200.]
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,thdepthnhsm,fdoy_save-min(fdoy_save),latbin,levels=level,min_value=-9999.,/overplot,$
        /noeras,/cell_fill,c_color=col1,color=0,charsize=1.5
contour,thdepthnh,fdoy_save-min(fdoy_save),latbin,levels=level,min_value=-9999.,/overplot,$
        /noeras,/cell_fill,c_color=col1,color=0,charsize=1.5
;contour,thdepthnh,fdoy_save-min(fdoy_save),latbin,levels=level,min_value=-9999.,/overplot,$
;        /follow,color=0L,c_labels=0*level,thick=1
for ii=0L,n_elements(xindex)-1L do $
    xyouts,xindex(ii),12.,xlabs(ii),charsize=1.5,alignment=0.5,color=0,/data

set_viewport,.2,.8,.2,.5
contour,thdepthsh,fdoy_save-min(fdoy_save),latbin,levels=level,min_value=-9999.,yrange=[-85.,-20.],$
        title='WACCM 3 Antarctic',/noeras,/cell_fill,c_color=col1,color=0,xticks=nxtick-1L,/nodata,$
;       xtickv=xindex,xtickname=strmid(sdays(xindex),4,2)+'/'+strmid(sdays(xindex),2,2),ytitle='Latitude',charsize=1.5
        xtickv=xindex,xtickname=' '+strarr(n_elements(xindex)+1),ytitle='Latitude',charsize=1.5
loadct,0
;
; contour anticyclone frequency
;
level=200.+200.*findgen(13)
loadct,0
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
col1=reverse(col1)
col1=col1-40
index=where(nhighsh le 0.)
nhighsh(index)=-9999.
contour,nhighsh,fdoy_save-min(fdoy_save),latbin,/overplot,level=level,/cell_fill,c_labels=0*level,$
        c_color=col1,min_value=-9999.
;contour,nhighsh,fdoy_save-min(fdoy_save),latbin,/overplot,level=level,/follow,c_labels=0*level,thick=2,color=0
loadct,38
level=[50.,100.,200.,300.,500.,800.,1200.]
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,thdepthshsm,fdoy_save-min(fdoy_save),latbin,levels=level,min_value=-9999.,/overplot,$
        /noeras,/cell_fill,c_color=col1,color=0,charsize=1.5
contour,thdepthsh,fdoy_save-min(fdoy_save),latbin,levels=level,min_value=-9999.,/overplot,$
        /noeras,/cell_fill,c_color=col1,color=0,charsize=1.5
;contour,thdepthsh,fdoy_save-min(fdoy_save),latbin,levels=level,min_value=-9999.,/overplot,$
;        /follow,color=0L,c_labels=0*level,thick=1
for ii=0L,n_elements(xindex)-1L do $
    xyouts,xindex(ii),-93.,xlabs(ii),charsize=1.5,alignment=0.5,color=0,/data

loadct,38
xmnb=0.2
xmxb=0.8
imin=min(level)
imax=max(level)
set_viewport,xmnb,xmxb,.1,.12
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],$
      xticks=n_elements(level)-1L,xtickname=strcompress(long(level)),$
      xtitle='(K)',charsize=1.5,color=0
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(j)
    x1=x1+dx
endfor

if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim wa3_lops_depth_yt.ps -rotate -90 wa3_lops_depth_yt.jpg'
endif

end
