pro residCirc
;==============================================================================
; calc_tem_vectors
;==============================================================================
;@arrows

; Calculate residual circulation for waccm runs ... rrg 11/07/2006
; uses zonal-mean files extracted from h0 (monthly) output with extract_tem0.pro
;
;--------------------------------------------------------------------------
; set file paths
;--------------------------------------------------------------------------

;  nruns = 4
;nruns=1

 ; root = ['/home/aksmith/waccm/circulation/idl/files_refb1.1/',$
 ;        '/home/aksmith/waccm/circulation/idl/files_refb1.2/',$
 ;         '/home/aksmith/waccm/circulation/idl/files_refb1.3/',$
 ;         '/home/aksmith/waccm/circulation/idl/files_refb1.4/']
 ;root=['/Volumes/Data/WACCM/TEM.cam2.h0.0001-02.nc']
mrunname = 'noaurfpl_FW_smin'
 ;root=['/Volumes/External_Ethan/WACCM3/'+mrunname+'/']
 root=['/export/home/pecked/temp/'+mrunname+'/']
 root=['/nobackupp2/epeck/temp/'+mrunname+'/']
 oroot = root+'savs/'
  ;inpath  = '/data/bigusb1/WACCM4/'+mrunname+'/'       ; path for input files
  inpath  = root+'vars/'        ; path for input files

  print, 'input directory: ',  inpath

;--------------------------------------------------------------------------
; choose month
;--------------------------------------------------------------------------

  ;mplot = 11   ; january

  lab_mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', $
             'Oct', 'Nov', 'Dec']

  allVstar = list()
  allWstar = list()
;--------------------------------------------------------------------------
; set plotting stuff
;--------------------------------------------------------------------------

;    loadct, 39
;    !p.background = 255 & !p.color = 0
;icolmax=byte(!p.color)
;icolmax=fix(icolmax)
;if icolmax eq 0 then icolmax=255
;mcolor=icolmax
;!NOERAS=-1
;device,decompose=0
;;nxdim=700
;;nydim=700
;
;    !p.charsize = 1.5
;
;    set_plot, 'PS'
;setplot='x'
;read,'setplot= ',setplot
;if setplot ne 'ps' then begin
;   set_plot,'x'
;   !p.background=mcolor
;;  window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
;endif
;    if setplot eq 'ps' then begin
;       set_plot,'ps'
;;      xsize=nxdim/100.
;;      ysize=nydim/100.
;       !psym=0
;       !p.font=0
;       device,font_size=9
;       device, xsize=5., xoffset=0.25, $
;             ysize=5., /inches, yoffset=0.25,bits=8,filename=oroot+'vectors_'+ lab_mon[mplot] + '.ps'
;             ;ysize=5., /inches, yoffset=0.25,bits=8,filename='vectors_'+ lab_mon[mplot] + '.ps'
;       device,/color
;    endif

;--------------------------------------------------------------------------
; set some constants
;--------------------------------------------------------------------------
  H  = 7.0e3            ; scale height
  ae = 6.37e6           ; Earth's radius
  g  = 9.8              ; gravity
  omega_e = 7.292e-5 ; Earth's angular rotation rate



;--------------------------------------------------------------------------
; read the data
;--------------------------------------------------------------------------
; the following file contains zonal-means of fields needed to calculate v*,w*
;  extracted with extract_tem0.pro

;nn=5 ;year 2030
files = file_search(inpath+'*.cam2.h3.dyns*')
for nn=0,N_ELEMENTS(files)-1 do begin  ;this is for years
     fname = files[nn]
     ;fname = inpath[nn]        ; + 'concat_zm_U,V,OMEGA,TH,UV3d,UW3d,VTH3d,UTGWORO,UTGWSPEC,BUTGWSPEC,EKGWSPEC,Z3.nc'

     print, 'processing ' + fname
     ncid = ncdf_open(fname)

     ncdf_varget, ncid, 'P0',       P0      ;original files were in form of (lon,lat,lev) for this file
     ncdf_varget, ncid, 'hyam',     hyam    ;I need to adapt for annual averages.
     ncdf_varget, ncid, 'hybm',     hybm
     ncdf_varget, ncid, 'hyai',     hyai
     ncdf_varget, ncid, 'hybi',     hybi
     ncdf_varget, ncid, 'lat',      lat
     ncdf_varget, ncid, 'lev',      lev
     ncdf_varget, ncid, 'ilev',     ilev
     ncdf_varget, ncid, 'time',     time
     ncdf_varget, ncid, 'date',     date
     ncdf_varget, ncid, 'U',        Ugrd
     ncdf_varget, ncid, 'V',        Vgrd
     ncdf_varget, ncid, 'OMEGA',    Wgrd
     ncdf_varget, ncid, 'TH',       THgrd
     ncdf_varget, ncid, 'VTH3d',    VTHgrd
     ncdf_varget, ncid, 'UV3d',     UVgrd
     ncdf_varget, ncid, 'UW3d',     UWgrd
     ncdf_varget, ncid, 'Z3',       Z3grd


Pref = P0

     ny = n_elements(lat)
     nzi = n_elements(ilev)
     nz = n_elements(lev)
     nt = n_elements(date)

  nmon = N_ELEMENTS(date)
  avg_vstar = fltarr(ny,nz,nmon)
  avg_wstar = fltarr(ny,nz,nmon)
  navg = fltarr(ny,nz,nmon)
  avg_z = fltarr(nz)
  navg_z = fltarr(nz)
for mplot = 0,nmon-1 do begin ;this is for months
;--------------------------------------------------------------------------
; arrays for averaging
;--------------------------------------------------------------------------
  ;ny = 96
  ;nz = 66

;
; compute zonal means
;
u=fltarr(n_elements(lat),n_elements(lev))
v=fltarr(n_elements(lat),n_elements(lev))
w=fltarr(n_elements(lat),n_elements(lev))
z3=fltarr(n_elements(lat),n_elements(lev))
th=fltarr(n_elements(lat),n_elements(ilev))
vth=fltarr(n_elements(lat),n_elements(ilev))
uv=fltarr(n_elements(lat),n_elements(ilev))
uw=fltarr(n_elements(lat),n_elements(ilev))
for j=0L,n_elements(lat)-1L do begin
    for k=0L,n_elements(lev)-1L do begin        ; lev=66
        u(j,k)=mean(ugrd(*,j,k,mplot))
        v(j,k)=mean(vgrd(*,j,k,mplot))
        w(j,k)=mean(wgrd(*,j,k,mplot))
        z3(j,k)=mean(z3grd(*,j,k,mplot))
    endfor
    for k=0L,n_elements(ilev)-1L do begin       ; ilev=67
        th(j,k)=mean(thgrd(*,j,k,mplot))
        vth(j,k)=mean(vthgrd(*,j,k,mplot))
        uv(j,k)=mean(uvgrd(*,j,k,mplot))
        uw(j,k)=mean(uwgrd(*,j,k,mplot))
    endfor
endfor

; check and fix points 'below ground'
     zero = where(UV gt 1.e15)
     UV(zero) = 0.0
     VTH(zero) = 0.0
     UW(zero) = 0.0
     TH(zero) = 250.0
     TH = TH > 250.0

; get month, year
     year = date/10000
;  month = (date/100 mod 1e2)
     month = (date/100 mod 1e2) - 1 ; arrange months: 1 to 12
     month(where(month eq 0)) = 12  ; adjust month
     year(where(month eq 12)) = year(where(month eq 12)) - 1 ; adjust year

; definitions
     ny = n_elements(lat)
     nzi = n_elements(ilev)
     nz = n_elements(lev)
     nt = n_elements(date)

     latr = lat * !dtor
     coslat = cos(latr)
     sinlat = sin(latr)

     fc = 2.*omega_e*sinlat
     P0 = Pref/100.
     zp = H * alog(P0/lev)
     zpi = H * alog(P0/ilev)
     rho = 100.*lev/(g*H)
     for k = 0, nz-1 do W(*,k,*) = -H/(lev(k)*100.) * W(*,k,*)

     ;pmin = 10.
     ;changed lowest altitude pressure to 300 at the behest of Cora so that we could see the lower branch in greater detail.
     pmin = 300.
     pmax = 0.00005
     ymin = -7.e3*alog(pmin/1000.)
     ymax = -7.e3*alog(pmax/1000.)

     res = min(abs(zp - ymin), k2)
     res = min(abs(zp - ymax), k1)

     k1 = k1+1
;--------------------------------------------------------------------------
;    for n = 0, nt-1 do begin   ; main loop (over all times)
;       if year[n] ge 1960 then begin
;--------------------------------------------------------------------------
n=0

; load fields for the current month, interpolating those defined
;  on the ilev grid onto the lev grid
           ubar     = U
           vbar     = V
           wbar     = W
;    utgworo  = UTORO(*,*,n)
;    utgwspec = UTSPEC(*,*,n) + BUTSPEC(*,*,n)

           thbar = fltarr(ny,nz)
           u1v1  = fltarr(ny,nz)
           u1w1  = fltarr(ny,nz)
           v1th1 = fltarr(ny,nz)
           for j = 0, ny-1 do begin
              thbar(j,*) = interpol(TH(j,*),  zpi, zp)
              u1v1(j,*)  = interpol(UV(j,*),  zpi, zp)
              u1w1(j,*)  = interpol(UW(j,*),  zpi, zp)
              v1th1(j,*) = interpol(VTH(j,*), zpi, zp)
           endfor

; compute d(thbar)/dz
           thbar_z = fltarr(ny,nz)
           for j = 0, ny-1 do thbar_z(j,*) = deriv(zp(*), thbar(j,*))
           for k = 0, nz-1 do begin
              if(zp(k) lt 2000.) then thbar_z(*,k) = thbar_z(*,k) > 0.1
           endfor

; compute d(ubar)/dz
           ubar_z = fltarr(ny,nz)
           for j = 0, ny-1 do ubar_z(j,*) = deriv(zp(*), ubar(j,*))

; compute d(ubar)/dy
           ubar_y = fltarr(ny,nz)
           for k = 0, nz-1 do ubar_y(*,k) = deriv(latr(*), ubar(*,k)*coslat(*))$
                                          / (ae*coslat(*))
           ubar_y(0,*)    = 0.0
           ubar_y(ny-1,*) = 0.0

; compute TEM velocities
           vstar = fltarr(ny,nz)
           d1z = fltarr(nz)

           for j = 0, ny-1 do begin
              d1z(*) = deriv(zp(*), rho(*)*v1th1(j,*)/thbar_z(j,*))
              for k = k1, k2 do vstar(j,k) = vbar(j,k) - d1z(k)/rho(k)
           endfor

           wstar = fltarr(ny,nz)
           d1y = fltarr(ny)
           d2y = fltarr(ny)

           for k = k1, k2 do begin
              d1y(*) = deriv(latr(*), coslat(*) * v1th1(*,k)/thbar_z(*,k))
              d2y(*) = deriv(latr(*), d1y(*))

              wstar(*,k) = wbar(*,k) + d1y(*)/(ae*coslat(*))
              wstar(0,k) = wbar(0,k) - 1./(ae*sinlat(0)) * d2y(0)
              wstar(ny-1,k) = wbar(ny-1,k) - 1./(ae*sinlat(ny-1)) * d2y(ny-1)
           endfor


;          avg_vstar[*,*,month[n]-1] = avg_vstar[*,*,month[n]-1] + vstar[*,*]
;          avg_wstar[*,*,month[n]-1] = avg_wstar[*,*,month[n]-1] + wstar[*,*]
;          navg[*,*,month[n]-1] = navg[*,*,month[n]-1] + 1

           for k = 0, nz-1 do begin
              for iy = 0, ny-1 do avg_z[k] = avg_z[k] + z3[iy,k]        ;,month[n]-1]
              navg_z[k] = navg_z[k] + ny
           endfor

;--------------------------------------------------------------------------
;       endif
;     endfor            ; end loop over years
;  endfor               ; end loop over runs
;--------------------------------------------------------------------------


; avg_vstar = avg_vstar/navg
; avg_wstar = avg_wstar/navg
avg_vstar[*,*,mplot]=vstar  ;this is what I care about
avg_wstar[*,*,mplot]=wstar
;print, mplot
;print, nmon
endfor ;this will be over months in a given year
        if (nn eq 58) and (mrunname eq 'noaurfco')  then begin ;see print statement below
                print, 'Doing surgury on year 2083 to restore October for noaurfco, which is otherwise missing.'
                print, date
                tavg_vstar= avg_vstar
                avg_vstar = fltarr(N_ELEMENTS(avg_vstar[*,0,0]),N_ELEMENTS(avg_vstar[0,*,0]),(N_ELEMENTS(avg_vstar[0,0,*])+1))
                avg_vstar[*,*,0:7] = tavg_vstar[*,*,0:7]
                avg_vstar[*,*,8] = (tavg_vstar[*,*,7]+tavg_vstar[*,*,8])/2.
                avg_vstar[*,*,9:11] = tavg_vstar[*,*,8:10]
                tavg_wstar= avg_wstar
                avg_wstar = fltarr(N_ELEMENTS(avg_wstar[*,0,0]),N_ELEMENTS(avg_wstar[0,*,0]),(N_ELEMENTS(avg_wstar[0,0,*])+1))
                avg_wstar[*,*,0:7] = tavg_wstar[*,*,0:7]
                avg_wstar[*,*,8] = (tavg_wstar[*,*,7]+tavg_wstar[*,*,8])/2.
                avg_wstar[*,*,9:11] = tavg_wstar[*,*,8:10]
        endif

allVstar -> add,avg_vstar
allWstar -> add,avg_wstar
endfor ;this will be over years
;At this point I will make arrays of all times Vstar = [46,66,*] and Wstar = [46,66,*]
Vstar = allVstar[0]
Wstar = allWstar[0]
for i = 1,N_ELEMENTS(allVstar)-1 do begin
        tVstar = Vstar
        tWstar = Wstar
        nVstar = allVstar[i]
        nWstar = allWstar[i]
        Vstar = fltarr(N_ELEMENTS(Vstar[*,0,0]),N_ELEMENTS(Vstar[0,*,0]),(N_ELEMENTS(Vstar[0,0,*])+N_ELEMENTS(nVstar[0,0,*])))
        Wstar = fltarr(N_ELEMENTS(Wstar[*,0,0]),N_ELEMENTS(Wstar[0,*,0]),(N_ELEMENTS(Wstar[0,0,*])+N_ELEMENTS(nWstar[0,0,*])))
        Vstar[*,*,0:(N_ELEMENTS(tVstar[0,0,*])-1)] = tVstar
        Vstar[*,*,N_ELEMENTS(tVstar[0,0,*]):(N_ELEMENTS(Vstar[0,0,*])-1)] = nVstar
        Wstar[*,*,0:(N_ELEMENTS(tWstar[0,0,*])-1)] = tWstar
        Wstar[*,*,N_ELEMENTS(tWstar[0,0,*]):(N_ELEMENTS(Wstar[0,0,*])-1)] = nWstar
endfor
ofilename = oroot+'resid_'+mrunname+'_vE.sav'
save, Vstar,Wstar,filename=ofilename

end
;  avg_z = avg_z/navg_z/1000.
;; plots
;  kkp = k2-k1+1
;  llp = ny/4
;
;  yyp = fltarr(llp)
;  yyp[0:llp-1] = lat[2:*:4]
;;  print,yyp
;
;  v_pl = fltarr(llp,kkp)
;  w_pl = fltarr(llp,kkp)
;
;  c_pl = fltarr(ny,nz)
;  c_z = fltarr(nz)
;
;  zkm = fltarr(kkp)
;  p_lev = fltarr(kkp)
;
;;  for n=0,nmon-1 do begin
;  n = mplot
;;    !p.multi = [0, 0, 0]
;     label = lab_mon[n]
;
;     k1p = k1
;     k2p = k2
;
;     zkm[0:kkp-1] = avg_z[k1:k2]
;     p_lev[0:kkp-1] = lev[k1:k2]
;     z_lev = -7.*alog(p_lev/1000.)
;     scale = 6.37e3*!pi/(zkm[0]-zkm[kkp-1])
;     scale_y = (zkm[0]-zkm[kkp-1])/(6.37e3*!pi)
;
;;    !p.multi = [0, 0, 0]
;set_viewport,.1,.9,.1,.9
;
;     v_pl[0:llp-1,0:kkp-1] = avg_vstar[2:*:4,k1:k2]
;     w_pl[0:llp-1,0:kkp-1] = avg_wstar[2:*:4,k1:k2]
;     arrows, v_pl, w_pl, yyp, z_lev, zkm, thick=3, scale_y, $
;              [-90.,90.], [ymin/1000., ymax/1000.], p_lev, label+' '+'TEM'
;
;;  endfor
;    ;conversion from .ps to .jpg
;    if setplot ne 'ps' then stop
;    if setplot eq 'ps' then begin
;       device,/close
;       spawn,'convert -trim vectors_'+lab_mon[mplot]+'.ps vectors_'+lab_mon[mplot]+'.jpg'
;;      spawn,'rm -f vectors_'+lab_mon[mplot]+'.ps'
;    endif
;
;end
