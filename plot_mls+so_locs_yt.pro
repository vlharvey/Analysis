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
   device,/landscape,bits=8,filename='mls+so_locs_yt.ps'
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
thmaxnh=-9999+0.*fltarr(nday,nlat)
thminnh=9999+0.*fltarr(nday,nlat)
thmaxsh=-9999+0.*fltarr(nday,nlat)
thminsh=9999+0.*fltarr(nday,nlat)
nhighnh=lonarr(nday,nlat)
nhighsh=lonarr(nday,nlat)
goto,plotit

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
      if ndays gt ledday then goto,saveit

      fdoy_save(icount)=iday
      if iyr eq 2005L then fdoy_save(icount)=fdoy_save(icount)+366.
      if iyr eq 2006L then fdoy_save(icount)=fdoy_save(icount)+366.+365.

      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      smn=string(FORMAT='(i2.2)',imn)
; 
; restore catalogs on initial day
;
if icount eq 0L then begin
   if iyr eq 2004L or iyr eq 2005L then begin
      restore,'/aura3/data/SAGE_II_data/Datfiles_SOSST/cat_sage2_v6.2.'+syr
      sage2lat=latitude
      if iyr eq 2004L then sage2fdoy=fdoy
      if iyr eq 2005L then sage2fdoy=fdoy+366.

      restore,'/aura3/data/SAGE_III_data/Datfiles_SOSST/cat_sage3_v3.00.'+syr
      sage3lat=latitude
      if iyr eq 2004L then sage3fdoy=fdoy
      if iyr eq 2005L then sage3fdoy=fdoy+366.
      if iyr eq 2006L then sage3fdoy=fdoy+366.+365.

      restore,'/aura3/data/POAM_data/Datfiles_SOSST/cat_poam3_v4.0.'+syr
      poam3lat=latitude
      if iyr eq 2004L then poam3fdoy=fdoy
      if iyr eq 2005L then poam3fdoy=fdoy+366.

      restore,'/aura3/data/HALOE_data/Datfiles_SOSST/cat_haloe_v19.'+syr
      hallat=latitude
      if iyr eq 2004L then halfdoy=fdoy
      if iyr eq 2005L then halfdoy=fdoy+366.
   endif
   restore,'/aura3/data/ACE_data/Datfiles_SOSST/v2.2/cat_ace_v2.2.'+syr
   acelat=latitude
   if iyr eq 2004L then acefdoy=fdoy
   if iyr eq 2005L then acefdoy=fdoy+366.
   if iyr eq 2006L then acefdoy=fdoy+366.+365.
endif
;
; restore catalogs on 1 January
;
if iday eq 1L then begin
   if iyr eq 2004L or iyr eq 2005L then begin
      restore,'/aura3/data/SAGE_II_data/Datfiles_SOSST/cat_sage2_v6.2.'+syr
      sage2lat=[sage2lat,latitude]
      if iyr eq 2005L then sage2fdoy=[sage2fdoy,fdoy+366.]

      restore,'/aura3/data/SAGE_III_data/Datfiles_SOSST/cat_sage3_v3.00.'+syr
      sage3lat=[sage3lat,latitude]
      if iyr eq 2004L then sage3fdoy=[sage3fdoy,fdoy]
      if iyr eq 2005L then sage3fdoy=[sage3fdoy,fdoy+366.]
      if iyr eq 2006L then sage3fdoy=[sage3fdoy,fdoy+366.+365.]

      restore,'/aura3/data/POAM_data/Datfiles_SOSST/cat_poam3_v4.0.'+syr
      poam3lat=[poam3lat,latitude]
      if iyr eq 2004L then poam3fdoy=[poam3fdoy,fdoy]
      if iyr eq 2005L then poam3fdoy=[poam3fdoy,fdoy+366.]

      restore,'/aura3/data/HALOE_data/Datfiles_SOSST/cat_haloe_v19.'+syr
      hallat=[hallat,latitude]
      if iyr eq 2004L then halfdoy=[halfdoy,fdoy]
      if iyr eq 2005L then halfdoy=[halfdoy,fdoy+366.]
   endif
   restore,'/aura3/data/ACE_data/Datfiles_SOSST/v2.2/cat_ace_v2.2.'+syr
   acelat=[acelat,latitude]
   if iyr eq 2004L then acefdoy=[acefdoy,fdoy]
   if iyr eq 2005L then acefdoy=[acefdoy,(fdoy+366.)]
   if iyr eq 2006L then acefdoy=[acefdoy,(fdoy+366.+365.)]
endif

      sdate_save(icount)=syr+smn+sdy
      ldate_save(icount)=long(syr+smn+sdy)
      print,syr+smn+sdy,icount
;
; restore NH MLS LOPs
;
dy=latbin(1)-latbin(0)
      dum=findfile('/aura2/harvey/Analysis/Datfiles_MLS/mls_nhDLlop_'+syr+smn+sdy+'.sav')
      if dum(0) eq '' then goto,jump2sh
      restore,'/aura2/harvey/Analysis/Datfiles_MLS/mls_nhDLlop_'+syr+smn+sdy+'.sav
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

      jump2sh:
;
; restore NH MLS LOPs
;
      dum=findfile('/aura2/harvey/Analysis/Datfiles_MLS/mls_sh135Elop_'+syr+smn+sdy+'.sav')
      if dum(0) eq '' then goto,jump2count
      restore,'/aura2/harvey/Analysis/Datfiles_MLS/mls_sh135Elop_'+syr+smn+sdy+'.sav
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
; uncomment to re-save
;
saveit:
thdepthnh=0.*thmaxnh
index=where(thmaxnh ne -9999. and thminnh ne 9999.)
if index(0) ne -1L then thdepthnh(index)=thmaxnh(index)-thminnh(index)
thdepthnh=smooth(thdepthnh,5,/edge_truncate)
thdepthsh=0.*thmaxsh
index=where(thmaxsh ne -9999. and thminsh ne 9999.)
if index(0) ne -1L then thdepthsh(index)=thmaxsh(index)-thminsh(index)
thdepthsh=smooth(thdepthsh,5,/edge_truncate)
save,file='MLS_LOP_YT.sav',thdepthnh,thdepthsh,fdoy_save,sdate_save,ldate_save,latbin,sage2fdoy,sage2lat,$
     halfdoy,hallat,sage3fdoy,sage3lat,poam3fdoy,poam3lat,acefdoy,acelat,nhighnh,nhighsh,nday

plotit:
restore,'MLS_LOP_YT.sav'

sdays=strcompress(sdate_save,/remove_all)
xindex=where(strmid(sdays,6,2) eq '15',nxtick)
xlabs=sdays(xindex)
erase
level=[50.,100.,200.,300.,500.,800.,1200.]
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
!type=2^2+2^3
set_viewport,.2,.8,.3,.7
contour,thdepthnh,fdoy_save-min(fdoy_save),latbin,levels=level,min_value=-9999.,yrange=[-90.,90.],$
        /noeras,/cell_fill,c_color=col1,color=0,xticks=nxtick-1L,/nodata,yticks=6,$
        xtickv=xindex,xtickname=' '+strarr(n_elements(xindex)+1),ytitle='Latitude',charsize=1.5
oplot,sage2fdoy-min(fdoy_save),sage2lat,psym=8,color=mcolor*.2,symsize=0.8
xyouts,.225,.71,'SAGE II',color=mcolor*.2,charthick=2,charsize=1.7,/normal

oplot,halfdoy-min(fdoy_save),hallat,psym=8,color=mcolor*.35,symsize=0.8
xyouts,.35,.71,'HALOE',color=mcolor*.35,charthick=2,charsize=1.7,/normal

oplot,sage3fdoy-min(fdoy_save),sage3lat,psym=8,color=mcolor*.65,symsize=0.8
xyouts,.475,.71,'SAGE III',color=mcolor*.65,charthick=2,charsize=1.7,/normal

oplot,poam3fdoy-min(fdoy_save),poam3lat,psym=8,color=mcolor*.8,symsize=0.8
xyouts,.6,.71,'POAM III',color=mcolor*.8,charthick=2,charsize=1.7,/normal

oplot,acefdoy-min(fdoy_save),acelat,psym=8,color=mcolor*.9,symsize=0.8
xyouts,.725,.71,'ACE',color=mcolor*.9,charthick=2,charsize=1.7,/normal

for ii=0L,n_elements(xindex)-1L do begin
    xyouts,xindex(ii),-110.,strmid(sdays(xindex(ii)),4,2)+'/'+strmid(sdays(xindex(ii)),2,2),orientation=90,$
           charsize=1.25,alignment=0.5,color=0,/data
endfor
;
; box SOSST LOPs
;
loadct,0
if min(ldate_save) le 20041106L then begin
index0=where(ldate_save eq 20041106L)
index1=where(ldate_save eq 20041112L)
ymin=45. & ymax=68.
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index0(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index1(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymin,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymax
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
endif

if min(ldate_save) le 20041208L then begin
index0=where(ldate_save eq 20041208L)
index1=where(ldate_save eq 20050214L)
ymin=33. & ymax=68.
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index0(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index1(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymin,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymax
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
endif

if min(ldate_save) le 20050218L then begin
index0=where(ldate_save eq 20050218L)
index1=where(ldate_save eq 20050327L)
ymin=50. & ymax=79.
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index0(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index1(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymin,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymax
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
endif

if min(ldate_save) le 20051021L then begin
index0=where(ldate_save eq 20051021L)
index1=where(ldate_save eq 20051107L)
ymin=68. & ymax=78.
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index0(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index1(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymin,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymax
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
endif

if min(ldate_save) le 20051124L then begin
index0=where(ldate_save eq 20051124L)
index1=where(ldate_save eq 20060120L)
ymin=59. & ymax=69.
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index0(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index1(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymin,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymax
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
endif

if min(ldate_save) le 20041022L then begin
index0=where(ldate_save eq min(ldate_save))
index1=where(ldate_save eq 20041022L)
ymin=-81. & ymax=-50.
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index0(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index1(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymin,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymax
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
endif

if min(ldate_save) le 20050714L then begin
index0=where(ldate_save eq 20050714L)
index1=where(ldate_save eq 20050726L)
ymin=-49. & ymax=-30.
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index0(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index1(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymin,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymax
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
endif

if min(ldate_save) le 20050724L then begin
index0=where(ldate_save eq 20050724L)
index1=where(ldate_save eq 20050810L)
ymin=-49. & ymax=-30.
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index0(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index1(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymin,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymax
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
endif

if min(ldate_save) le 20050921L then begin
index0=where(ldate_save eq 20050921L)
index1=where(ldate_save eq 20050930L)
ymin=-66. & ymax=-50.
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index0(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index1(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymin
plots,fdoy_save(index1(0))-min(fdoy_save),ymin,/continue,/data,thick=10,color=mcolor*.1
plots,fdoy_save(index0(0))-min(fdoy_save),ymax
plots,fdoy_save(index1(0))-min(fdoy_save),ymax,/continue,/data,thick=10,color=mcolor*.1
endif

if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim mls+so_locs_yt.ps -rotate -90 mls+so_locs_yt.jpg'
endif

end
