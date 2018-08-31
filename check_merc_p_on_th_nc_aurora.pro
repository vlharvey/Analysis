
; check new nc data

@rd_ukmo_nc
@stddat
@kgmt
@ckday
@kdate

loadct,38
mcolor=byte(!p.color)
device,decompose=0
icmm1=mcolor-1B
icmm2=mcolor-2B
!noeras=1
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=750
nydim=750
xorig=[0.10]
yorig=[0.15]
xlen=0.8
ylen=0.7
cbaryoff=0.06
cbarydel=0.02
!NOERAS=-1
SETPLOT='ps'
read,'setplot',setplot
if setplot ne 'ps' then begin
   lc=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/aura7/harvey/WACCM_data/Datfiles/Aurora/waccm3_'
uday=0L & lstday=0L & ledday=0L
lstmn=1L & lstdy=1L & lstyr=95L 
ledmn=1L & leddy=1L & ledyr=95L
mon=['jan_','feb_','mar_','apr_','may_','jun_','jul_','aug_','sep_','oct_','nov_','dec_']
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
;
; this logic will work through 2090
;
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

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
      ifile=dir+sdate+'.nc1'
      dum=findfile(ifile)
      if dum(0) eq '' then goto,jump
      ncid=ncdf_open(ifile)
      print,'opening ',ifile
      ncdf_diminq,ncid,0,name,nr
      ncdf_diminq,ncid,1,name,nc
      ncdf_diminq,ncid,2,name,nth
      alon=fltarr(nc)
      alat=fltarr(nr)
      thlev=fltarr(nth)
      ipv=fltarr(nr,nc,nth)
      prs=fltarr(nr,nc,nth)
      msf=fltarr(nr,nc,nth)
      u=fltarr(nr,nc,nth)
      v=fltarr(nr,nc,nth)
      qdf=fltarr(nr,nc,nth)
      ncdf_varget,ncid,0,alon
      print,alon
      ncdf_varget,ncid,1,alat
      print,alat
      ncdf_varget,ncid,2,thlev
      print,thlev
      ncdf_varget,ncid,3,ipv
      print,reform(ipv(10,10,*))
      ncdf_varget,ncid,4,prs
      print,reform(prs(10,10,*))
      ncdf_varget,ncid,5,msf
      ncdf_varget,ncid,6,u
      ncdf_varget,ncid,7,v
      ncdf_varget,ncid,8,qdf
      ncdf_close,ncid

for ilev=nth-1L,0L,-1L do begin
    pgrd1=transpose(p1(*,*,ilev))
    stheta=strtrim(string(th(ilev)),2)
    nlvls=21
    imin=min(pgrd1) & imax=max(pgrd1)
    level=imin+((imax-imin)/float(nlvls))*findgen(nlvls)
    col1=1+indgen(nlvls)*mcolor/nlvls

    !noeras=1
    erase
    xyouts,.4,.95,syr+smn+sdy,/normal,charsize=3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    contour,pgrd1,alon,alat,levels=level,/fill,/cell_fill,c_color=col1,/noeras,$
        title='Pressure '+stheta+' K',xtitle='Longitude',ytitle='Latitude',$
        xticks=6,yrange=[-90.,90.],xrange=[0.,360.]
    contour,pgrd1,alon,alat,levels=level,/follow,c_color=0,/overplot,/noeras
    map_set,0,180,0,/grid,/contin,/noeras 
imin=min(level)
imax=max(level)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],charsize=1.5
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
endfor

stop
endfor
goto,jump
end
