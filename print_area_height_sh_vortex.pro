;
; print Antarctic vortex area and average height at each theta
;
@stddat
@kgmt
@ckday
@kdate
@rd_waccm3_nc3_bardeen_hervig

lstmn=1
lstdy=1
lstyr=2034
ledmn=1
leddy=1
ledyr=2034
lstday=0
ledday=0
re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
mon=['jan','feb','mar','apr','may','jun',$
     'jul','aug','sep','oct','nov','dec']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
!noeras=1
xlab='2x'
ifile='/aura3/data/WACCM_data/Datfiles/h0.hervig_'+xlab+'.nc3'

; Compute initial Julian date
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
      if iyr ge 2000L then iyr1=iyr-2000L
      if iyr lt 2000L then iyr1=iyr-1900L
      sday=string(FORMAT='(I3.3)',iday-1)
      rd_waccm3_nc3_bardeen_hervig,ifile,nc,nr,nth,alon,alat,th,pv2,p2,$
         u2,v2,qdf2,mark2,vp,sf2
      temp2=0.*p2
      for k=0,nth-1L do temp2(*,*,k)=th(k)*(p2(*,*,k)/1000.)^.286
      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=alon(0)+360.

    if icount eq 0L then begin
         dum=transpose(mark2(*,*,0))
         lon=0.*dum
         lat=0.*dum
         for i=0,nc-1 do lat(i,*)=alat
         for j=0,nr-1 do lon(*,j)=alon
         area=0.*lat
         deltax=alon(1)-alon(0)
         deltay=alat(1)-alat(0)
         for j=0,nr-1 do begin
             hy=re*deltay*dtr
             dx=re*cos(alat(j)*dtr)*deltax*dtr
             area(*,j)=dx*hy    ; area of each grid point
         endfor
       icount=1L
    endif
;
; loop over theta
;
      for thlev=0,nth-1 do begin
          mark1=transpose(mark2(*,*,thlev))
          p1=transpose(p2(*,*,thlev))
          index=where(lat lt 0. and mark1 gt 0.,nn)
          if index(0) ne -1 then print,th(thlev),100.*total(area(index))/hem_area,total(p1(index))/float(nn)
      endfor
goto,jump
end
