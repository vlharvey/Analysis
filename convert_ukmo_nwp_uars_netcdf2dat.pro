;
; read new Met Office "nwp" netCDF pressure files
;
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nwp
;
; Ask interactive questions- get starting/ending dates
;
spawn,'date'
lstmn=6 & lstdy=4 & lstyr=2008
ledmn=6 & leddy=4 & ledyr=2008
lstday=0 & ledday=0
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr ge 91 and lstyr le 99 then lstyr=lstyr+1900
if ledyr ge 91 and ledyr le 99 then ledyr=ledyr+1900
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
;
; old Met Office longitudes and latitudes
;
ncold=96L
alonold=3.75*findgen(ncold)
wlonold=1.875+3.75*findgen(ncold)
nrold=72L
nr1old=73L
alatold=90.-2.5*findgen(nr1old)
wlatold=88.75-2.5*findgen(nrold)
;
; loop over days
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then spawn,'date'
      if ndays gt ledday then stop,' Normal Termination Condition '
      syr=strtrim(iyr,2)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      date=syr+smn+sdy
;
; build Met Office filename and read netCDF data
;
;     ifile='/aura3/data/UKMO_data/ftp/ukmo-nwp-strat_gbl-std_'+date+'12_u-v-w-t-gph.nc'
      ifile='/aura3/data/UKMO_data/ftp/ukmo-nwp-strat_gbl-std_'+date+'12_u-v-gph-t-w_uars.nc'
      iflg=0L
      rd_ukmo_nwp,ifile,nc,nr,nc1,nr1,nlv,wlon,alon,wlat,alat,p,z3d,t3d,u3d,v3d,iflg
      if iflg gt 0L then goto,jump
      print,'read Met Office data on '+date
;
; interpolate new grid to old resolution (alat->alatold, wlat->wlatold)
;
      znew=fltarr(ncold,nr1old,nlv)
      tnew=fltarr(ncold,nr1old,nlv)
      unew=fltarr(ncold,nrold,nlv)
      vnew=fltarr(ncold,nrold,nlv)
;     for k=0L,nlv-1L do begin
          for ii=0L,ncold-1L do begin
          xp=alonold(ii)
          for jj=0L,nr1old-1L do begin
          yp=alatold(jj)
          for i=0L,nc-1L do begin
              ip1=i+1
              if i eq nc-1L then ip1=0
              xlon=alon(i)
              xlonp1=alon(ip1)
              if i eq nc-1L then xlonp1=360.+alon(ip1)

              if xp ge xlon and xp le xlonp1 then begin
                 xscale=(xp-xlon)/(xlonp1-xlon)
                 for j=0L,nr1-2L do begin
                     jp1=j+1
                     xlat=alat(j)
                     xlatp1=alat(jp1)
                     if yp ge xlat and yp le xlatp1 then begin
                        yscale=(yp-xlat)/(xlatp1-xlat)
                        tj1=t3d(i,j,*)+xscale*(t3d(ip1,j,*)-t3d(i,j,*))
                        tjp1=t3d(i,jp1,*)+xscale*(t3d(ip1,jp1,*)-t3d(i,jp1,*))
                        tnew(ii,jj,*)=tj1+yscale*(tjp1-tj1)
                        zj1=z3d(i,j,*)+xscale*(z3d(ip1,j,*)-z3d(i,j,*))
                        zjp1=z3d(i,jp1,*)+xscale*(z3d(ip1,jp1,*)-z3d(i,jp1,*))
                        znew(ii,jj,*)=zj1+yscale*(zjp1-zj1)
                     endif
                 endfor
              endif
          endfor
          endfor
;
; winds on staggered grid
;
          xp=wlonold(ii)
          for jj=0L,nrold-1L do begin
          yp=wlatold(jj)
          for i=0L,nc-1L do begin
              ip1=i+1
              if i eq nc-1L then ip1=0
              xlon=wlon(i)
              xlonp1=wlon(ip1)
              if i eq nc-1L then xlonp1=360.+wlon(ip1)
      
              if xp ge xlon and xp le xlonp1 then begin
                 xscale=(xp-xlon)/(xlonp1-xlon)
                 for j=0L,nr-2L do begin
                     jp1=j+1
                     xlat=wlat(j)
                     xlatp1=wlat(jp1)
                     if yp ge xlat and yp le xlatp1 then begin
                        yscale=(yp-xlat)/(xlatp1-xlat)
                        uj1=u3d(i,j,*)+xscale*(u3d(ip1,j,*)-u3d(i,j,*))
                        ujp1=u3d(i,jp1,*)+xscale*(u3d(ip1,jp1,*)-u3d(i,jp1,*))
                        unew(ii,jj,*)=uj1+yscale*(ujp1-uj1)
                        vj1=v3d(i,j,*)+xscale*(v3d(ip1,j,*)-v3d(i,j,*))
                        vjp1=v3d(i,jp1,*)+xscale*(v3d(ip1,jp1,*)-v3d(i,jp1,*))
                        vnew(ii,jj,*)=vj1+yscale*(vjp1-vj1)
                     endif
                 endfor
              endif
          endfor
          endfor
;      print,alonold(ii)
          endfor	; loop over longitude
;     endfor		; loop over altitude
      z3d=znew
      t3d=tnew
      u3d=unew
      v3d=vnew
;
; loop over pressure levels and output /f77 binary to match previous format
;
      if iyr lt 2000 then iyr1=iyr-1900
      if iyr ge 2000 then iyr1=iyr-2000
      syr1=string(FORMAT='(i2.2)',iyr1)
      ofile='/aura7/harvey/UKMO_data/Datfiles/ppassm_y'+syr1+'_m'+smn+'_d'+sdy+'_h12.pp.dat'
      close,1
      openw,1,ofile,/f77
      for kk=0L,nlv-1L do begin
          plevel=p(kk)
          writeu,1,plevel
          z=reform(z3d(*,*,kk))
          t=reform(t3d(*,*,kk))
          u=reform(u3d(*,*,kk))
          v=reform(v3d(*,*,kk))
          writeu,1,u,v,t,z
          print,plevel,u(0,0),v(0,0),t(0,0),z(0,0)
      endfor
goto,jump
end
