;
; first look at WACCM 3 LOP climatology
; Hovmoller plot of WACCM 3 LOPs
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
   device,/landscape,bits=8,filename='wa3_lops_mino3_xt+highs.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
lstmn=1 & lstdy=1 & lstyr=1990 & lstday=0
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
nlon=72L
dx=5.
lonbin=dx*findgen(nlon)

o3maxnh=-9999+0.*fltarr(nday,nlon)
o3minnh=9999+0.*fltarr(nday,nlon)
o3maxsh=-9999+0.*fltarr(nday,nlon)
o3minsh=9999+0.*fltarr(nday,nlon)
nhighnh=lonarr(nday,nlon)
nhighsh=lonarr(nday,nlon)

iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
goto,plotit
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,saveit

      fdoy_save(icount)=icount
      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      smn=string(FORMAT='(i2.2)',imn)
      sdate_save(icount)=syr+smn+sdy
      ldate_save(icount)=long(syr+smn+sdy)
      print,syr+smn+sdy,icount
;
; restore NH WACCM LOPs
;
      dum=findfile('/aura3/data/WACCM_data/Datfiles/wa3_nhDLlop_'+syr+smn+sdy+'.sav')
      if dum(0) eq '' then goto,jump2sh
      restore,'/aura3/data/WACCM_data/Datfiles/wa3_nhDLlop_'+syr+smn+sdy+'.sav
      nlop=n_elements(XLOP_SAVE)
      for ii=0L,nlop-1L do begin         ; loop over LOP points on this day
      o3=O3LOP_SAVE(ii)
      theta=THLOP_SAVE(ii)
if theta le 600. or theta ge 1600. then goto,jumpnhlop
      xpos=XLOP_SAVE(ii)
      for j=0L,nlon-1L do begin
          x0=lonbin(j)-dx/2.
          x1=lonbin(j)+dx/2.
          if x0 le xpos and x1 gt xpos then begin
             if o3 gt o3maxnh(icount,j) then o3maxnh(icount,j)=o3
             if o3 lt o3minnh(icount,j) then o3minnh(icount,j)=o3
          endif
      endfor
jumpnhlop:
      endfor

nlop=n_elements(HO3_SAVE)
for ii=0L,nlop-1L do begin         ; loop over LOP points on this day
    theta=HTH_SAVE(ii)
    xpos=HX_SAVE(ii)
    if HY_SAVE(ii) gt 30. then begin
      for j=0L,nlon-1L do begin
          x0=lonbin(j)-dx/2.
          x1=lonbin(j)+dx/2.
          if x0 le xpos and x1 gt xpos then nhighnh(icount,j)=nhighnh(icount,j)+1L
      endfor
    endif
endfor

      jump2sh:
;
; restore SH WACCM LOPs
;
      dum=findfile('/aura3/data/WACCM_data/Datfiles/wa3_sh135Elop_'+syr+smn+sdy+'.sav')
      if dum(0) eq '' then goto,jump2count
      restore,'/aura3/data/WACCM_data/Datfiles/wa3_sh135Elop_'+syr+smn+sdy+'.sav
      nlop=n_elements(XLOP_SAVE)
      for ii=0L,nlop-1L do begin         ; loop over LOP points on this day
      o3=O3LOP_SAVE(ii)
      theta=THLOP_SAVE(ii)
if theta le 600. or theta ge 1600. then goto,jumpshlop
      xpos=XLOP_SAVE(ii)
      for j=0L,nlon-1L do begin
          x0=lonbin(j)-dx/2.
          x1=lonbin(j)+dx/2.
          if x0 le xpos and x1 gt xpos then begin
             if o3 gt o3maxsh(icount,j) then o3maxsh(icount,j)=o3
             if o3 lt o3minsh(icount,j) then o3minsh(icount,j)=o3
          endif
      endfor
jumpshlop:
      endfor

nlop=n_elements(HO3_SAVE)
for ii=0L,nlop-1L do begin         ; loop over LOP points on this day
    theta=HTH_SAVE(ii)
    xpos=HX_SAVE(ii)
    if HY_SAVE(ii) lt -30. then begin
      for j=0L,nlon-1L do begin
          x0=lonbin(j)-dx/2.
          x1=lonbin(j)+dx/2.
          if x0 le xpos and x1 gt xpos then nhighsh(icount,j)=nhighsh(icount,j)+1L
      endfor
    endif
endfor

      jump2count:
      icount=icount+1L
goto,jump
;
; save
;
saveit:
save,file='WA3_LOP_XT_mino3.sav',o3minnh,o3maxnh,o3minsh,o3maxsh,$
     fdoy_save,sdate_save,lonbin,nhighnh,nhighsh
;
; plot Hovmoller
;
plotit:
restore,'WA3_LOP_XT_mino3.sav'
o3minnh=transpose(o3minnh)
o3minsh=transpose(o3minsh)
ldate_save=long(sdate_save)

sdays=strcompress(sdate_save,/remove_all)
xindex=where(strmid(sdays,4,4) eq '0101',nxtick)
xlabs=strmid(sdays(xindex),0,4)
erase
o3level=2.5+0.5*findgen(9)
nlvls=n_elements(o3level)
col1=1+indgen(nlvls)*mcolor/nlvls
!type=2^2+2^3
set_viewport,.15,.45,.2,.8
index=where(o3minnh eq 9999.)
if index(0) ne -1L then o3minnh(index)=0
;o3minnh=smooth(o3minnh,3,/edge_truncate)
contour,o3minnh,lonbin,fdoy_save-min(fdoy_save),levels=o3level,min_value=0.,/nodata,xrange=[0.,360.],$
        title='WACCM Arctic',/noeras,/cell_fill,c_color=col1,color=0,yticks=nxtick-1L,xticks=6,$
        ytickv=xindex,ytickname=' '+strarr(n_elements(xindex)+1),xtitle='Longitude',charsize=1.5,$
        charthick=1.5
;
; contour anticyclone frequency
;
level=1.+10.*findgen(13)
loadct,0
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
col1=reverse(col1)
col1=col1-30
nhighnh=transpose(nhighnh)
nhighnh=smooth(nhighnh,3)
nhighnh=smooth(nhighnh,3)
contour,nhighnh,lonbin,fdoy_save-min(fdoy_save),/overplot,level=level,/cell_fill,c_labels=0*level,thick=2,c_color=col1
;contour,nhighnh,lonbin,fdoy_save-min(fdoy_save),/overplot,level=level,/follow,c_labels=0*level,thick=2,color=0
loadct,38
nlvls=n_elements(o3level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,o3minnh,lonbin,fdoy_save-min(fdoy_save),levels=o3level,min_value=0.,/overplot,$
        /noeras,/cell_fill,c_color=col1,color=0,charsize=1.5
y2d=0.*o3minnh
x2d=0.*o3minnh
for i=0L,nlon-1L do y2d(i,*)=fdoy_save-min(fdoy_save)
for j=0L,nday-1L do x2d(*,j)=lonbin
index=where(o3minnh ne 0.,npts)
for ii=0L,npts-1L do begin
    xpt=x2d(index(ii))
    ypt=y2d(index(ii))
    xm1=xpt-2.5
    xp1=xpt+2.5
    ym1=ypt-1.
    yp1=ypt+1.
    xbox=[xm1,xp1,xp1,xm1,xm1]
    ybox=[ym1,ym1,yp1,yp1,ym1]
    polyfill,xbox,ybox,color=((o3minnh(index(ii))-min(o3level))/(max(o3level)-min(o3level)))*mcolor
endfor
;
; daily average timeseries for quantitative hemispheric comparison
;
o3minnh_davg=fltarr(nday)
o3minsh_davg=fltarr(nday)
for i=0L,nday-1L do begin
    index=where(o3minnh(*,i) gt 0. and o3minnh(*,i) ne 9999.,npts)
    if npts gt 2L then begin
       result=moment(o3minnh(index,i))
       o3minnh_davg(i)=result(0)
    endif
    index=where(o3minsh(*,i) gt 0. and o3minsh(*,i) ne 9999.,npts)
    if npts gt 2L then begin
       result=moment(o3minsh(index,i))
       o3minsh_davg(i)=result(0)
    endif
endfor
;
; SH
;
!type=2^2+2^3
set_viewport,.525,.825,.2,.8
index=where(o3minsh eq 9999.)
if index(0) ne -1L then o3minsh(index)=0.
;o3minsh=smooth(o3minsh,3,/edge_truncate)
contour,o3minsh,lonbin,fdoy_save-min(fdoy_save),levels=o3level,min_value=0.,xrange=[0.,360.],$
        title='WACCM Antarctic',/noeras,/cell_fill,c_color=col1,color=0,yticks=nxtick-1L,/nodata,xticks=6,$
        ytickv=xindex,ytickname=' '+strarr(n_elements(xindex)+1),xtitle='Longitude',charsize=1.5,$
        charthick=1.5
;for ii=0L,n_elements(xindex)-1L do begin
;    xyouts,-40.,xindex(ii),strmid(sdays(xindex(ii)),4,2)+'/'+strmid(sdays(xindex(ii)),2,2),$
;           charsize=1.25,alignment=0.5,color=0,/data
;endfor
;
; contour anticyclone frequency
;
level=1.+10.*findgen(13)
loadct,0
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
col1=reverse(col1)
col1=col1-30
nhighsh=transpose(nhighsh)
nhighsh=smooth(nhighsh,3)
nhighsh=smooth(nhighsh,3)
contour,nhighsh,lonbin,fdoy_save-min(fdoy_save),/overplot,level=level,/cell_fill,c_labels=0*level,thick=2,c_color=col1
;contour,nhighsh,lonbin,fdoy_save-min(fdoy_save),/overplot,level=level,/follow,c_labels=0*level,thick=2,color=0
loadct,38
nlvls=n_elements(o3level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,o3minsh,lonbin,fdoy_save-min(fdoy_save),levels=o3level,min_value=0.,/overplot,$
        /noeras,/cell_fill,c_color=col1,color=0,charsize=1.5
index=where(o3minsh ne 0.,npts)
for ii=0L,npts-1L do begin
    xpt=x2d(index(ii))
    ypt=y2d(index(ii))
    xm1=xpt-2.5
    xp1=xpt+2.5
    ym1=ypt-1.
    yp1=ypt+1.
    xbox=[xm1,xp1,xp1,xm1,xm1]
    ybox=[ym1,ym1,yp1,yp1,ym1]
    polyfill,xbox,ybox,color=((o3minsh(index(ii))-min(o3level))/(max(o3level)-min(o3level)))*mcolor
endfor
for ii=0L,n_elements(xindex)-1L do begin
    xyouts,-40.,xindex(ii),strmid(sdays(xindex(ii)),4,2)+'/'+strmid(sdays(xindex(ii)),2,2),$
           charsize=1.25,alignment=0.5,color=0,/data
endfor
;
; daily means
;
;!type=2^2+2^3+2^4
;set_viewport,.15,.825,.85,.995
;plot,fdoy_save-min(fdoy_save),o3minnh_davg,psym=8,color=0,yrange=[2.,7.]
;oplot,fdoy_save-min(fdoy_save),o3minsh_davg,psym=8,color=.9*mcolor
;
; color bar
;
xmnb=0.2
xmxb=0.775
imin=min(o3level)
imax=max(o3level)
set_viewport,xmnb,xmxb,.1,.12
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],$
      xticks=n_elements(o3level)-1L,xtickname=string(format='(f4.2)',o3level),$
      xtitle='(ppmv)',charsize=1.5,charthick=1.5,color=0
ybox=[0,10,10,0,0]
x11=imin
dxx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    xbox=[x11,x11,x11+dxx,x11+dxx,x11]
    polyfill,xbox,ybox,color=col1(j)
    x11=x11+dxx
endfor

if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim wa3_lops_mino3_xt+highs.ps -rotate -90 wa3_lops_mino3_xt+highs.jpg'
endif

end
