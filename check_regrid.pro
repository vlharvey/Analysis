@stddat
@kgmt
@ckday
@kdate
@date2uars
@rd_ukmo
@store_ukmo

month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
setplot='x'
colbw='col'
lstmn=0
lstdy=0
lstyr=0
ledmn=0
leddy=0
ledyr=0
lstday=0
ledday=0
uday=0

; Ask interactive questions- get starting/ending date and p surface
print, ' '
print, '      UKMO Version '
print, ' '
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr

if lstyr ge 91 and lstyr le 99 then lstyr=lstyr+1900
if ledyr ge 91 and ledyr le 99 then ledyr=ledyr+1900
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1991 or lstyr gt 2002 then stop,'Year out of range '
if ledyr lt 1991 or ledyr gt 2002 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

; define viewport location 
nxdim=750
nydim=750
xorig=[0.1,0.5]
yorig=[0.15,0.15]
xlen=0.3
ylen=0.3
cbaryoff=0.03
cbarydel=0.01
!NOERAS=-1

;if setplot ne 'ps' then $
;   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162

;if setplot eq 'ps' then begin
;  set_plot,'ps'
;  xsize=nxdim/100.
;  ysize=nydim/100.
;  !psym=0
;  !p.font=0
;  device,font_size=9
;  device,/landscape,bits=8,filename='ukmo_press.ps'
;  if colbw ne 'bw' and colbw ne 'gs' then device,/color
;  device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
;         xsize=xsize,ysize=ysize
;  !p.thick=2.0                   ;Plotted lines twice as thick
;  !p.charsize=1.0
;endif

; set color table
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
icmm1=icolmax-1
icmm2=icolmax-2
nlvls=30
col1=indgen(nlvls)*icmm1/nlvls
!noeras=1
device,decompose=0

; Compute initial Julian date
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '

; --- Calculate UARS day from (imn,idy,iyr) information.
      z = date2uars(imn,idy,iyr,uday)
      print,imn,idy,iyr,' = UARS day ',fix(uday)

;***Read UKMO data
      if iyr ge 2000 then iyr1=iyr-2000
      if iyr le 1999 then iyr1=iyr-1900
      file='/aura3/data/UKMO_data/Datfiles/ppassm_y'+$
            string(FORMAT='(i2.2,a2,i2.2,a2,i2.2,a11)',$
            iyr1,'_m',imn,'_d',idy,'_h12.pp.dat')
      rd_ukmo,file,iflg,nlg,nlat,nlv,alon,alat,wlon,wlat,p,$
              g3d,t3d,u3d,v3d
      if iflg ne 0 then goto, jump

; map temperature, heights, psfc, and q to wind grid
; ------------------------------------------------
; t,z,q go from 90   N to -90   S by 2.5  (73 lats)
;           and 0      to 360     by 3.75 (96 lons)
; winds go from 88.75N to -88.75S by 2.5  (72 lats)
;           and 1.875  to 358.125 by 3.75 (96 lons)

      erase
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      MAP_SET,90,0,0,/ortho,/GRID,/CONTIN,/noeras
      tl=reform(t3d(*,*,3))
      level=180.+5.*findgen(nlvls)
      contour,tl,alon,alat,levels=level,/overplot,/cell_fill,c_color=col1
      contour,tl,alon,alat,levels=level,/overplot,/follow,c_color=icolmax

      tl=fltarr(nlg,nlat-1)
      for i=0,nlg-1 do begin
          im1=i
          ip1=i+1
;         if i eq 0 then im1=nlg-1
          if i eq nlg-1 then ip1=0
          for j=1,nlat-1 do begin
              tim1=.5*(t3d(im1,j-1,3)+t3d(im1,j,3))
              tip1=.5*(t3d(ip1,j-1,3)+t3d(ip1,j,3))
              tl(i,j-1)=.5*(tim1+tip1)
           endfor
      endfor

      xmn=xorig(1)
      xmx=xorig(1)+xlen
      ymn=yorig(1)
      ymx=yorig(1)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      MAP_SET,90,0,0,/ortho,/GRID,/CONTIN,/noeras
      contour,tl,wlon,wlat,levels=level,/overplot,/cell_fill,c_color=col1
      contour,tl,wlon,wlat,levels=level,/overplot,/follow,c_color=icolmax
stop

goto,jump
end
