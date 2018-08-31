;pro plt_tem, calc = calc, print = print

dir='/Volumes/cloud/data/WACCM_data/Datfiles_SD/'

savfile = dir+'f_1975-2010_2deg_refc1sd_wa4_tsmlt.002.cam.h4tem.2002-2004.sav


;if keyword_set(print) then begin
  set_plot, 'PS'
  device, file='temh4_cora.eps', xsize=7.0, ysize=7.0, $
     encap = 1, /inches, /color, bits=8
;endif

!p.multi = [0,1,2]
!p.charsize=1.2
!x.style=1
!y.style=1
!y.title='Approx. Altitude (km)'
!x.margin=[14,2]
!y.margin=[3,5]
loadct, 0

;if keyword_set(calc) then begin
;  calc_tem, h4file, lat, ilev, vstar, wstar, date
;  save, lat, ilev, vstar, wstar, date, file = savfile
;endif else begin
  restore, savfile
;endelse
;
; subset dates
;
ind0 = where(date eq 20031001)
print, ind0
ind1 = where(date eq 20040331)
print, ind1
;ind0=0
;ind1=n_elements(date)-1
;
date = date(ind0:ind1)
nt = n_elements(date)

vstar = vstar(*,*,ind0:ind1)
wstar = wstar(*,*,ind0:ind1)

nz = n_elements(ilev)
days = indgen(nt)
xran = [1,nt-2]
xtickv = [0,31,62,92,92+31,92+31+29] 
;xtickv = [0,365/4.,365/2.,3.*365./4,365.0]	;	31,62,91] 
xtickn = strmid(strcompress(date(xtickv),/remove_all),0,6)
xticks = 5

wts = cos(!pi*lat/180.)

lat0 = 56.
lat1 = 69.
min0 =  min(abs(lat-lat0), ilat0)
min0 =  min(abs(lat-lat1), ilat1)
ilat0 = ilat0(0)
ilat1 = ilat1(0)

print, ilat0, lat(ilat0), 'to', ilat1, lat(ilat1)
ny = ilat1-ilat0+1

vs = reform(vstar(ilat0:ilat1,*,*),ny,nz*nt)
vs = vs##wts(ilat0:ilat1)
vs = reform(vs,nz,nt)/total(wts(ilat0:ilat1))
vs = transpose(vs)
vs = smooth(vs, [5,1])

vlev = [-100,-2,0,100] 
ccol = [180,230,255,255]

  H  = 7.            ; scale height
  p0=1000.
  zp = H * alog(P0/ilev)        ; TEM quantities are defined on ilev

contour, vs, days, zp, lev=vlev, c_col = ccol, /follow, $
  yrange=[60,120], ystyle=1, /cell, title = 'V* 55-70N (m/s)', $
  xticks = xticks, xtickn = xtickn, xtickv = xtickv, xran = xran

contour, vs, days, zp, lev=[-5,-3,-2,-1,0,1,2,3,4,5], /follow, /over, $
  color=0, c_thick = [2,2,2,2,3,2,2,2,2,2], c_linestyle= [1,1,1,1,0,0,0,0,0,0]

lat0 = 70.
lat1 = 90.
min0 =  min(abs(lat-lat0), ilat0)
min0 =  min(abs(lat-lat1), ilat1)
ilat0 = ilat0(0)
ilat1 = ilat1(0)

print, ilat0, lat(ilat0), 'to', ilat1, lat(ilat1)
ny = ilat1-ilat0+1

ws = reform(wstar(ilat0:ilat1,*,*),ny,nz*nt)
ws = ws##wts(ilat0:ilat1)
ws = reform(ws,nz,nt)/total(wts(ilat0:ilat1))
ws = transpose(ws)
ws = smooth(ws, [5,1])

wlev = (indgen(25)-12)*0.5

wlev = [-100,-1,0,100] 
ccol = [180,230,255,255]

contour, 100*ws, days, zp, lev=wlev, c_col = ccol, /follow, $
  yrange=[60,120], ystyle=1, /cell, title = 'W* 70-90N (cm/s)', $
  xticks = xticks, xtickn = xtickn, xtickv = xtickv, xran = xran

contour, 100*ws, days, zp, lev=[-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,3], /follow, /over, $
  color=0, c_thick = [2,2,2,2,3,2,2,2,2,2], c_linestyle= [1,1,1,1,0,0,0,0,0,0]

;xyouts, /norm, .01, .96, 'a)'
;xyouts, /norm, .01, .46, 'b)'

!p.multi = 0

altitude=zp
pressure=ilev
vstar=vs
wstar=ws*100.
yyyymmdd=date
vstartitle='V* 55-70N (m/s)'
wstartitle='W* 70-90N (cm/s)'
help,altitude,pressure,yyyymmdd,vstar,wstar,vstartitle,wstartitle

;if keyword_set(print) then begin
  device, /close
  set_plot, 'X'
;endif

;return
end
