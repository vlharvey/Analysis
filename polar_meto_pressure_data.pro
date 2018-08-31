;
; save daily UKMO Ubar in IDL save format
;
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nwp
@drawvectors
;
; Ask interactive questions- get starting/ending dates
;
nxdim=700
nydim=700
xorig=[0.1]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.03
cbarydel=0.02

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
!NOERAS=-1
device,decompose=0
!type=2^2+2^3
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
lstmn=9 & lstdy=28 & lstyr=1991
ledmn=10 & leddy=6 & ledyr=2013
lstday=0 & ledday=0
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=ledday-lstday+1L
sdate=strarr(kday)
icount=0L
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
;
; loop over days
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,saveit
      syr=string(FORMAT='(i4)',iyr)
      syr1=strmid(syr,2,2)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      date=syr+smn+sdy
      sdate(icount)=date
;
; have Met Office pressure data from Sep 28th 1991 to Nov 10th 2007 in IDL save format with filenames like this - ppassm_y07_m04_d25_h12.pp.sav
; NOTE - latitude goes from North to South
;
; ALAT            FLOAT     = Array[73]
; ALON            FLOAT     = Array[96]
; P               FLOAT     = Array[22]
; T3D             FLOAT     = Array[96, 73, 22]
; U3D             FLOAT     = Array[96, 72, 22]
; V3D             FLOAT     = Array[96, 72, 22]
; WLAT            FLOAT     = Array[72]
; WLON            FLOAT     = Array[96]
; Z3D             FLOAT     = Array[96, 73, 22]
;
; have Met Office pressure data from Jan 1st 2007 to the present in netCDF format with filenames like this - ukmo-nwp-strat_gbl-std_2007010112_u-v-gph-t-w_uars.nc
;
; read save data prior to 2007
; read netcdf data beginning in 2007
;
      if iyr le 2006 then begin
         restore,'/atmos/harvey/UKMO_data/Datfiles/ppassm_y'+syr1+'_m'+smn+'_d'+sdy+'_h12.pp.sav'
         nc=n_elements(wlon)
         nr=n_elements(wlat)
         nr1=n_elements(alat)
         nlv=n_elements(p)
;
; reverse latitude
;
         u3d_sorted=0.*u3d
         t3d_sorted=0.*t3d
         index=sort(wlat)
         index2=sort(alat)
         for i=0L,nc-1L do begin
             for k=0L,nlv-1L do begin
                 u3d_sorted(i,*,k)=u3d(i,index,k)
                 t3d_sorted(i,*,k)=t3d(i,index2,k)
             endfor
         endfor
         u3d=u3d_sorted
         t3d=t3d_sorted
         wlat=wlat(index)
         alat=alat(index2)
      endif
      if iyr gt 2006 then begin
         ifile='/atmos/harvey/UKMO_data/Datfiles/ukmo-nwp-strat_gbl-std_'+date+'12_u-v-gph-t-w_uars.nc'
         iflg=0L
         rd_ukmo_nwp,ifile,nc,nr,nc1,nr1,nlv,wlon,alon,wlat,alat,p,z3d,t3d,u3d,v3d,iflg
         if iflg gt 0L then goto,jumpday
      endif
;
; remove data above 1 hPa
;
      good=where(p ge 1.,nlv)
      u3d=reform(u3d(*,*,good))
      t3d=reform(t3d(*,*,good))
      p=reform(p(good))
      if min(p) ne 1.0 then goto,jumpday
      print,'read Met Office data on '+date,nr,nlv
      if icount eq 0L then begin
         rpress=10.
;        read,'Enter desired pressure level ',rpress
         index=where(abs(p-rpress) eq min(abs(p-rpress)))
         ilev=index(0)
      endif
;
; polar mean U and T
;
       tdata=reform(t3d(*,*,ilev))
       udata=reform(u3d(*,*,ilev))
       vdata=reform(v3d(*,*,ilev))

erase
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    nlvls=25
    colevel=180.+2.*findgen(nlvls)
    col1=1+indgen(nlvls)*icolmax/nlvls
    map_set,0,0,0,/contin,/grid,/noeras
    contour,tdata,alon,alat,title='MetO Temperature '+date,charsize=2,charthick=2,color=0,/noeras,/overplot,c_color=col1,/fill,levels=colevel
    nc1=n_elements(wlon)
    nr1=n_elements(wlat)
    drawvectors,nc1,nr1,wlon,wlat,udata,vdata,20,1
stop
      jumpday:
      icount=icount+1L
goto,jump
;
; save file
;
saveit:
end
