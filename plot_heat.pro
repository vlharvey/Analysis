
; plot polar projection and yz cross polar section

@rd_heat_nc
@rd_ukmo_nc3
@stddat
@kgmt
@ckday
@kdate
@date2uars

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
xorig=[0.10,0.60]
yorig=[0.25,0.25]
xlen=0.3
ylen=0.3
cbaryoff=0.08
cbarydel=0.02
!NOERAS=-1
SETPLOT='ps'
read,'setplot',setplot
if setplot ne 'ps' then begin
   lc=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
uday=0L & lstmn=10L & lstdy=27L & lstyr=91L & ledmn=3L & leddy=2L & ledyr=4L & lstday=0L & ledday=0L
mon=['jan_','feb_','mar_','apr_','may_','jun_','jul_','aug_','sep_','oct_','nov_','dec_']
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
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
day = iday - 1

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
      if iyr lt 2000 then iyr1=iyr-1900
      if iyr ge 2000 then iyr1=iyr-2000
      syr=string(FORMAT='(I2.2)',iyr1)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      ifile=mon(imn-1)+sdy+'_'+syr
      rd_heat_nc,dir+ifile+'_heat.nc',nc,nr,nth,alon,alat,th,qnew
      rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag

qzm=fltarr(nr,nth)
qnewzm=fltarr(nr,nth)
for k=0,nth-1 do begin
    for j=0,nr-1 do begin
        qzm(j,k)=total(q2(j,*,k))/float(nc)
        qnewzm(j,k)=total(qnew(j,*,k))/float(nc)
    endfor
endfor
print,'OLD    ',min(qzm),max(qzm)
print,'NEW    ',min(qnewzm),max(qnewzm)

level=-60.+2.5*findgen(31)
nlvls=n_elements(level)
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
    contour,qzm,alat,th,levels=level,/fill,/cell_fill,c_color=col1,/noeras,$
        title='OLD Net Diabatic Heating (K/day)',ytitle='Theta (K)',xtitle='Latitude',$
        xticks=6,xrange=[-90.,90.]
    index=where(level lt 0.)
    contour,qzm,alat,th,levels=level(index),/follow,c_color=0,/overplot,/noeras
    index=where(level gt 0.)
    contour,qzm,alat,th,levels=level(index),/follow,c_color=mcolor,/overplot,/noeras
    contour,qzm,alat,th,levels=[0],/follow,c_color=0,/overplot,thick=2,/noeras

    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    contour,qnewzm,alat,th,levels=level,/fill,/cell_fill,c_color=col1,/noeras,$
        title='NEW Net Diabatic Heating (K/day)',ytitle='Theta (K)',xtitle='Latitude',$
        xticks=6,xrange=[-90.,90.]
    index=where(level lt 0.)
    contour,qnewzm,alat,th,levels=level(index),/follow,c_color=0,/overplot,/noeras
    index=where(level gt 0.)
    contour,qnewzm,alat,th,levels=level(index),/follow,c_color=mcolor,/overplot,/noeras
    contour,qnewzm,alat,th,levels=[0],/follow,c_color=0,/overplot,thick=2,/noeras
;stop

goto,jump
end
