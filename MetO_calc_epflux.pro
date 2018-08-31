;MetO_calc_epflux.pro

;Katelynn Greer
;14 July 2011

;Purpose: Calculate the EP-flux and divergence for a MetO file

;Required sub-functions: epflux.pro 

!PATH = Expand_Path('+/home/greerk/idl/coyote')+':'+!PATH
!PATH = Expand_Path('+/home/greerk/idl/dandelion')+':'+!PATH

year=2002
month=2
day=13

;title='3 Jan 2004'
;psfilename='/home/greerk/Documents/AnalysisCodes/EPflux/ps/y02m02d13.ps'
title='13 Feb 2002'
psfilename='/home/greerk/Documents/AnalysisCodes/EPflux/ps/y02m02d13_new.ps'

;==================Retrieve .netcdf data================================================
yearfolder = string(format='(i4)',year)
if year lt 2000 then year_str = string(format='(i2)', year-1900)
if (year ge 2000) and (year lt 2010) then year_str = '0'+string(format='(i1)',year-2000)
if (year ge 2010) then year_str = string(format='(i2)',year-2000)
month_id=month
if month_id lt 10 then month_str = '0'+string(format='(i1)',month)
if month_id ge 10 then month_str = string(format='(i2)',month)
day_id = day
if day_id lt 10 then day_str = '0'+string(format='(i1)',day)
if day_id ge 10 then day_str = string(format='(i2)',day)

if year lt 2006 then nc_file = '/y'+year_str+'_m'+month_str+'_d'+day_str+'_h12.nc'
if year ge 2006 then nc_file = '/ukmo-nwp-strat_gbl-std_20'+year_str+month_str+day_str+'12_u-v-gph-t-w_uars.nc'
filepathget = '/media/tulip/UKMOdata/netcdf/';
filenameget = filepathget + yearfolder +nc_file;zonal mean density

cdfid = ncdf_open(filenameget)

;~~~Retrieve latitude_1 (for temperature and geopotential heigh25 Mayt)
varid = ncdf_varid(cdfid, 'latitude_1')
ncdf_varget,cdfid,varid,data8
lat1length = n_elements(data8)
latitude1 = make_array(1,lat1length)
;if data8(0) lt data8(70) then lat_1 =reverse(data8) else lat_1=data8
lat_1=data8

;~~~Retrieve longitude_1 (for temperature and geopotential height)
varid = ncdf_varid(cdfid, 'longitude_1')
ncdf_varget,cdfid,varid,data9
lon1length = n_elements(data9)
longitude1 = make_array(1,lon1length)
longitude1 = data9
long0index = where (longitude1 gt 180.0)
lon_0 = make_array(1,lon1length)
for b = 0, lon1length-1, 1 do begin
  if longitude1[b] ge 180.0 then begin
    lon_0[b] = longitude1[b]-360.0
  endif else begin
    lon_0[b] = longitude1[b]
  endelse
end
lon_1 = lon_0[sort(lon_0)]

;~~~Retrieve latitude (for u,v,w)
varid = ncdf_varid(cdfid, 'latitude')
ncdf_varget,cdfid,varid,datax
latlength = n_elements(datax)
latitude = make_array(1,latlength)
;if datax(0) lt datax(70) then lat =reverse(datax) else lat=datax
lat=reform(datax)
ny=latlength

;~~~Retrieve longitude (for u,v,w)
varid = ncdf_varid(cdfid, 'longitude')
ncdf_varget,cdfid,varid,data9x
lonlength = n_elements(data9x)
longitude = make_array(1,lonlength)
longitude = data9x
long0indexx = where (longitude gt 180.0)
lon_0x = make_array(1,lonlength)
for b = 0, lonlength-1, 1 do begin
  if longitude[b] ge 180.0 then begin
    lon_0x[b] = longitude[b]-360.0
  endif else begin
    lon_0x[b] = longitude[b]
  endelse
end
lon = lon_0x[sort(lon_0x)]
nx=lonlength

;~~~Retrieve Pressure levels [hPa]
if year eq 1991 then varid = ncdf_varid(cdfid, 'pseudo')
if year eq 1992 and month le 12 then varid = ncdf_varid(cdfid, 'pseudo')
if year eq 1992 and month eq 11 and day ge 11 then varid = ncdf_varid(cdfid,'p')
if year eq 1992 and month eq 12 then varid = ncdf_varid(cdfid,'p')
if year ge 1993 then varid = ncdf_varid(cdfid, 'p')
ncdf_varget,cdfid,varid,data3
plength = n_elements(data3)
p = make_array(1,plength)
p = data3
size_p = size(p)
nz = plength

;~~~Retrieve Temperatures [K]
varid = ncdf_varid(cdfid, 'temp')
ncdf_varget,cdfid,varid,data4;zonal mean density
templength = n_elements(data4)
temps = make_array(96,73,22)
temps = data4
temperatures_0 = shift(temps,long0index[0],0,0)
;if data8(0) lt data8(70) then temperatures_1 =reverse(temperatures_0,2) else temperatures_1=temperatures_0
temperatures_1=temperatures_0
size_t = size(temperatures_1)

;~~~Retrieve Geopotential heights [m]
varid = ncdf_varid(cdfid, 'ht')
ncdf_varget,cdfid,varid,data5
htlength = n_elements(data5)
geo = make_array(1,htlength)
geo = data5
geopotentials_0 = shift(geo, long0index[0],0,0)
;if data8(0) lt data8(70) then geopotentials_1 =reverse(geopotentials_0,2) else geopotentials_1=geopotentials_0
geopotentials_1=geopotentials_0

;~~~Retrieve zonal wind [m/s]
varid=ncdf_varid(cdfid,'u')
ncdf_varget,cdfid,varid,data6
uwind = data6
u_0 = shift(uwind, long0indexx[0],0,0)
;if data6(0) lt data6(70) then u =reverse(u_0,2) else u=u_0
u=u_0
size_u = size(u)

;~~~Retrieve meridional wind [m/s]
varid=ncdf_varid(cdfid,'v')
ncdf_varget,cdfid,varid,data7
vwind = data7
v_0 = shift(vwind, long0indexx[0],0,0)
;if data7(0) lt data7(70) then v =reverse(v_0,2) else v=v_0;zonal mean density
v=v_0

;~~~Retrieve vertical wind [m/s]lev
if year lt 2004 then begin
varid=ncdf_varid(cdfid,'omega')
ncdf_varget,cdfid,varid,data2
omegawind = data2
omega_0 = shift(omegawind, long0indexx[0],0,0)
;if data2(0) lt data2(70) then omega =reverse(omega_0,2) else omega=omega_0
omega=omega_0
endif
if year ge 2004 then begin
varid=ncdf_varid(cdfid,'dz_dt')
ncdf_varget,cdfid,varid,data2
omegawind = data2
omega_0 = shift(omegawind, long0indexx[0],0,0)
;if data2(0) lt data2(70) then omega =reverse(omega_0,2) else omega=omega_0
omega=omega_0
endif

ncdf_close, cdfid;zonal mean density;zonal mean density

;==================Interpolate winds,T, gp onto same grid================================================

x=Interpol(Findgen(N_Elements(lon_1)),lon_1,lon)
y=Interpol(Findgen(N_Elements(lat_1)),lat_1,lat)
xx=Rebin(x,nx,ny,/sample)
yy=Rebin(Reform(y,1,ny),nx,ny,/sample)
temperatures=make_array(nx,ny,nz)
geopotentials=make_array(nx,ny,nz)
omega_2=make_array(nx,ny,nz)
for k=0,nz-1 do begin
  temperatures(*,*,k)=Interpolate(temperatures_1(*,*,k),xx,yy)
  geopotentials(*,*,k)=Interpolate(geopotentials_1(*,*,k),xx,yy)
  omega_2(*,*,k)=Interpolate(omega(*,*,k),xx,yy)
endfor
omega=omega_2
stop
;==================Calculate EPflux Input Parameters================================================

d2y = 1./360.*2.*!pi*6370000.  ; latitude degee to meridional distance
dlat = (lat(1)-lat(0))*!dtor
dlon = (lon(1)-lon(0))*!dtor
R = 287.15                       ;gas constant
cp = 1004.0                   ;specific heat at constant pressure [J*kg^-1*K^-1]
g0 = 9.81                     ;acceleration of gravity [m/s^2]
p0 = 1013.0                     ;mean sea level pressure [hPa]

rho = make_array(nx,ny,nz) 
for k=0,nz-1 do begin
  rho(*,*,k)=(100.0*p(k))/(R*temperatures(*,*,k))
endfor
rbar = mean(rho, dimension=1) ;zonal mean density

ubar=mean(u,dimension=1)      ;zonal mean of zonal wind
vbar=mean(v,dimension=1)      ;zonal mean of meridional wind
wbar=mean(omega,dimension=1)  ;zonal mean of vertical wind
tbar=mean(temperatures,dimension=1)     ;zonal mean temperatures
zbar=mean(geopotentials,dimension=1)   ;zonal mean geopotential heights

up = make_array(nx,ny,nz)
vp = up
wp = up
tp = up
zp_x = up
for i=0,nx-1 do begin
  up(i,*,*) = u(i,*,*)-ubar
  vp(i,*,*) = v(i,*,*)-vbar
  wp(i,*,*) = omega(i,*,*)-wbar
  tp(i,*,*) = temperatures(i,*,*)-tbar
  zp_x(i,*,*) = geopotentials(i,*,*)-zbar   ;perturbation in gp height.. how is this diff from zp?
endfor

;p is a pressure level/surface in hPa or mb
;H=7000m, scale height
zp = fltarr(ny,nz)            ;geopotential height (perturbation?)
for j=0,ny-1 do begin
  zp(j,*) = (21.416-alog(p/5.e-7))*7000.
endfor

ptbar = make_array(ny,nz)
for l=0,nz-1 do begin
  ptbar(*,l) = tbar(*,l)*(p0/p(l))^(rbar/cp)
endfor

dudz = fltarr(ny,nz)  ;change in u with altitude
dptdz = fltarr(ny,nz) ;change in potential temperature with altitude
stab = fltarr(ny,nz)  ;static stability
for j=0,ny-1 do begin
  dudz(j,*) = deriv(zp(j,*),reform(ubar(j,*)))
  dptdz(j,*) = deriv(zp(j,*),reform(ptbar(j,*)))
  stab(j,*) = deriv(zp(j,*),reform(tbar(j,*)))+g0/cp
endfor
bvf2 = g0*dptdz/ptbar      ;Brunt-Vaisala frequency squared
dudy = fltarr(ny,nz)        ;meridional change in u
for k = 0,nz-1 do begin
  dudy(*,k) = deriv(lat,ubar(*,k)*cos(lat*!DTOR))/d2y $
    /cos(lat*!DTOR)
endfor

;==================Call EPflux Calculator================================================

epy = fltarr(ny,nz)         ;y component of EP-flux
epy1 = epy                  ;term 1 of y component of EP-flux
epy2 = epy                  ;term 2 of y component of EP-flux
epz = epy                   ;z component of EP-flux
epz1 = epy                  ;term 1 of z component of EP-flux
epz2 = epy                  ;term 2 of z component of EP-flux
epfy = epy
epfz = epy
epf = epy
vt = epy                    ;meriodional heat flux

epflux,up,vp,wp,tp,zp,rbar,lat,dudy,dudz,stab,nx,ny,nz,epy1,epy2,epz1,epz2,eptndy,eptndz,eptnd

epy = epy1+epy2
epz = epz1+epz2

;Scale vectors by magnitude of F
magF_all = make_array(ny,nz)
norm_epy = make_array(ny,nz)
norm_epz = make_array(ny,nz)
for j=0,ny-1 do begin
  for k=0,nz-1 do begin
    magF_all(j,k) = sqrt(epy(j,k)^2+epz(j,k)^2)
    norm_epy(j,k) = epy(j,k)/rbar(j,k)
    norm_epz(j,k) = epz(j,k)/rbar(j,k)
  endfor
endfor



;==================Plot the results================================================
ps_start,filename=psfilename, nomatch=1
!p.multi=[0,1,2,0,0]

;loadct, 40
;gp_levels = indgen(10)*750+39000
;T_levels = indgen(13)*10+180
;T_colors = indgen(13)*18+15
;l_labels = make_array(10, value=1)
;plot, [90,100],[50,60],/nodata,$
;  xrange=[-180,180],yrange=[40,90],xstyle=1,ystyle=1,$
;  title=title+'  2.154 hPa',xtitle='Longitude',ytitle='Latitude'
;contour,temperatures(*,*,16),lon,lat,$
;  levels=T_levels,c_colors=T_colors,/cell_fill, /overplot
;contour,temperatures(*,*,16),lon,lat,$
;  levels=T_levels,c_linestyle=2,$
;  c_thick=1.0,font=1,$
;  /overplot
;contour,geopotentials(*,*,16)/10.0,lon,lat,$
;  levels=gp_levels/10.0,c_labels=l_labels,$
;  c_thick=1.0,font=1,$
;  /overplot
;cgDCBar, T_colors, LABELS=T_levels, ROTATE=45,$
;  position=[0.68, 0.7, 0.98, 0.73], charsize=0.75,$
;  title='Temperature [K]'
  
loadct, 0
ubar_levels = indgen(15)*10.0-70.0
ubar_labels = make_array(1,15,value=1.0)
zero_levels = [-500.0, 0.0, 500.0]
;omega_levels(5)=-0.00001
;omega_colors = [150,150,150,150,150,255,255,255,255,255]
;posx=rebin(lon,nx,nz,/sample)
;posy=transpose(rebin(p,nz,nx,/sample))
;nana = make_array(96,22,/float,value=0.0)
plot, [90,100],[50,60],/nodata,/ylog,$
  xrange=[90,40],yrange=[1000,0.5],xstyle=1,ystyle=1,$
  title=title+'  Zonal Mean Wind',xtitle='Latitude',ytitle='Pressure Height [hPa]
contour,ubar,lat,p,$
  levels=ubar_levels,c_labels=ubar_labels,/overplot
contour,ubar,lat,p,$
  levels=zero_levels,/overplot,c_thick=5, c_labels=[0,1,0]
;contour,ubar,lat,p,$
;  levels=omega_levels,/overplot
loadct,40
;partvelvec,nana(*,0:19),reform(omega(*,8,0:19)),posx(*,0:19),posy(*,0:19),/over, color=50

loadct,0
;ep_levels=indgen(10)*40-180
ep_levels = [-200,-160,-120,-80,-40,-0.01,40,80,120,160,200]
ep_colors = reverse([255,255,255,255,255,255,150,150,150,150,150])
posx=rebin(lat,ny,nz,/sample)
posy=transpose(rebin(p,nz,ny,/sample))

plot,[90,-90],[50,75],/nodata,/ylog,$
  xrange=[90,40],yrange=[1000,0.5],ystyle=1,xstyle=1,$
  xtitle='Latitude',ytitle='Pressure Height [hPa]',title=title + 'EP-Flux'
contour,eptnd(1:71,*),lat(1:71),p,$
  levels=ep_levels,c_colors=ep_colors,/cell_fill,/overplot
contour,eptnd(1:71,*),lat(1:71),p,$
  levels=ep_levels,/overplot
;loadct, 13
;partvelvec,norm_epy(0:48,0:19),norm_epz(0:48,0:19),posx(0:48,0:19),posy(0:48,0:19),/over,length=0.001, color=250

ps_end

;==================================================================================
END