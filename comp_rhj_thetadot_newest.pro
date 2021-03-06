
; Plot markers.  cyclones = 1;  anticyclones = -1

@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_th_newest
@compdiv
@compadv
@specfilt
num=0L
nlvls=20
loadct,38
mcolor=!p.color
icolmax=byte(!p.color)
icmm1=icolmax-1B
icmm2=icolmax-2B
col1=1+indgen(nlvls)*icolmax/nlvls
!P.FONT=0
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.10,0.10]
yorig=[0.60,0.20]
xlen=0.8
ylen=0.3
cbaryoff=0.03
cbarydel=0.01
mon=strarr(12)*4
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
lstmn=0l
lstdy=0l
lstyr=0l
ledmn=0l
leddy=0l
ledyr=0l
thlev=0l
lstday=0l
ledday=0l
date=''
print, ' '
print, '      UKMO Version '
print, ' '
read,'Enter date (month, day, year) ',lstmn,lstdy,lstyr
read,'Enter ending date (month, day, year) ',ledmn,leddy,ledyr
print, ' '
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 or lstyr gt 1999 then stop,'Year out of range '
if ledyr lt 1991 or ledyr gt 1999 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
if setplot eq 'ps' then begin
   lc=0
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   wdelete,1
   set_plot,'ps'
   device,/color,/landscape,bits=8,filename='ukmo_marks.ps'
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
   xsize=xsize,ysize=ysize
endif

; Compute initial Julian date
iyr = lstyr
idy = lstdy
imn = lstmn
z=kgmt(imn,idy,iyr,iday)
iday = iday - 1

; loop over days
jump: iday = iday + 1

kdate,float(iday),iyr,imn,idy
ckday,iday,iyr
iyr1=iyr-1900
print,imn,idy,iyr1

; Test for end condition and close windows.
z=stddat(imn,idy,iyr,ndays)
if ndays lt lstday then stop,' starting day outside range '
if ndays gt ledday then stop,' Normal termination condition '

date=strcompress(string(FORMAT='(A3,A1,I2,A2,I4)',$
     month(imn-1),' ',idy,', ',iyr))
if idy ge 10 then datelab=strcompress(string(FORMAT='(A4,I2,A1,I4)',$
     mon(imn-1),idy,'_',iyr))
if idy lt 10 then datelab=strcompress(string(FORMAT='(A4,A1,I1,A1,I4)',$
     mon(imn-1),'0',idy,'_',iyr))
; Read UKMO isentropic data
rd_ukmo_th_newest,imn,idy,iyr1,inc,inr,inth,xlon,xlat,th,$
           pv2,p2,msf2,u2,v2,q2,qdf2,mark2,ur2,vr2,div2
nc=inc
nr=inr
nth=inth
x=fltarr(nc+1)
x(0:nc-1)=xlon(0:nc-1)
x(nc)=xlon(0)+360.
;
; introduce theta-dot from integrated divergencs
; introduce 3d isentropic Jacobian
;
rhj2=0*pv2
div3=0*pv2
dp2=0*pv2
; loop over theta from top down
FOR thlev=1,nth-1 DO BEGIN

; extract theta level
theta=th(thlev)
print,'theta level=',theta
div1=.5*(transpose(div2(*,*,thlev))+transpose(div2(*,*,thlev-1)))
u1=.5*(transpose(u2(*,*,thlev))+transpose(u2(*,*,thlev-1)))
v1=.5*(transpose(v2(*,*,thlev))+transpose(v2(*,*,thlev-1)))
div1=reform(div1,nc,nr)
u1=reform(u1,nc,nr)
v1=reform(v1,nc,nr)
; introduce isentropic Jacobian 
rhj=div1*0.0
;
; compute isentropic Jacobian (convert from mb to pa)
;
for j=0,nr-1 do begin
for i=0,nc-1 do begin
dth=th(thlev)-th(thlev-1)
dp=p2(j,i,thlev)-p2(j,i,thlev-1)
dp2(j,i,thlev)=dp
rhj(i,j)=-dp/(9.8*dth*100.)
endfor
endfor
;
; compute advection of jacobian
;
compadv,u1,v1,rhj,adv,xlon,xlat,nc,nr
;
; compute mass divergence
;
div1=rhj*div1+adv
;
; fourier filter mass divergence
;
specfilt,div1,xlon,xlat,nr,nc
div3(*,*,thlev)=transpose(div1) 
rhj2(*,*,thlev)=transpose(rhj)
ENDFOR  ; loop over theta
div2=div3
;
; smooth in latitude
; 1,2,1 
;
for l=0,nth-1 do begin
 for i=0,nc-1 do begin
  dummy1=reform(div2(*,i,l),nr)
  dummy2=dummy1
  for j=1,nr-2 do begin
   dummy2(j)=(dummy1(j-1)+2.*dummy1(j)+dummy1(j+1))/4.
  endfor
  div2(*,i,l)=dummy2
 endfor
;
; smooth in longitude
;
 for j=0,nr-1 do begin
  dummy1=reform(div2(j,*,l),nc)
  dummy1=reform([dummy1(nc-2:nc-1),dummy1,dummy1(0:1)],nc+4)
  dummy2=dummy1
  for i=1,nc+2 do begin
   dummy2(i)=(dummy1(i-1)+2.*dummy1(i)+dummy1(i+1))/4.
  endfor
  div2(j,*,l)=dummy2(2:nc+1)
 endfor
endfor
;
if ndays eq lstday then begin
rhjnm1=rhj2
divnm1=div2
qnm1=q2
pnm1=p2
datelabnm1=datelab
goto, jump
endif
if ndays eq lstday+1 then begin
divn=div2
rhjn=rhj2
qn=q2
pn=p2
datelabn=datelab
goto, jump
endif
if ndays ge lstday+2 then begin
rhjnp1=rhj2
divnp1=div2
qnp1=q2
pnp1=p2
datelabnp1=datelab
endif
print,'n-1=',datelabnm1,' n=',datelabn,' n+1=',datelabnp1
thd2=rhjn*qn/(24.*60.*60.)
dt=2.*24.*60.*60.
drhjdt=(rhjnp1-rhjnm1)/dt
for i=0,nc-1 do begin
for j=0,nr-1 do begin
pres=reform(pn(j,i,*),nth)
index=where(pres ge 70.)
bth=index(0)-1
;
; loop over theta from top down
FOR thlev=bth,nth-1 DO BEGIN
dth=th(thlev)-th(thlev-1)
thd2(j,i,thlev)=thd2(j,i,thlev-1)-dth*(divn(j,i,thlev)+drhjdt(j,i,thlev))
ENDFOR  ; loop over theta
endfor
endfor
;
; loop over theta from top down
FOR thlev=0,nth-1 DO BEGIN
dummy1=reform(thd2(*,*,thlev),nr,nc)
dummy2=reform(rhjn(*,*,thlev),nr,nc)
index=where(dummy2 gt 0.)
if index(0) ne -1 then dummy1(index)=dummy1(index)/dummy2(index)
index=where(dummy2 eq 0.)
if index(0) ne -1 then dummy1(index)=0. 
thd2(*,*,thlev)=24.*60.*60.*dummy1 
ENDFOR  ; loop over theta
thd2(*,*,0)=qn(*,*,0)
;
; linear blend of shine and divergent thetadot between
; 70 and 100mb
;
for i=0,nc-1 do begin
for j=0,nr-1 do begin
snd=thd2(j,i,*)
pres=pn(j,i,*)
index=where(pres ge 70. and pres le 100.)
npnt=n_elements(index)
nbeg=index(0)
nend=index(npnt-1)
for l=nbeg,nend do begin
scale=(pres(l)-70.)/(100.-70.)
snd(l)=scale*thd2(j,i,l)+(1.-scale)*qn(j,i,l)
endfor
thd2(j,i,*)=snd
endfor
endfor
;
; smooth in latitude
; 1,2,1 
;
for l=0,nth-1 do begin
 for i=0,nc-1 do begin
  dummy1=reform(thd2(*,i,l),nr)
  dummy2=dummy1
  for j=1,nr-2 do begin
   dummy2(j)=(dummy1(j-1)+2.*dummy1(j)+dummy1(j+1))/4.
  endfor
  thd2(*,i,l)=dummy2
 endfor
;
; smooth in longitude
;
 for j=0,nr-1 do begin
  dummy1=reform(thd2(j,*,l),nc)
  dummy1=reform([dummy1(nc-2:nc-1),dummy1,dummy1(0:1)],nc+4)
  dummy2=dummy1
  for i=1,nc+2 do begin
   dummy2(i)=(dummy1(i-1)+2.*dummy1(i)+dummy1(i+1))/4.
  endfor
  thd2(j,*,l)=dummy2(2:nc+1)
 endfor
endfor
;
thdbar=fltarr(nr,nth)
qbar=fltarr(nr,nth)
pbar=fltarr(nr,nth)
ybar=fltarr(nr,nth)
for j=0,nr-1 do begin
for l=0,nth-1 do begin
thdbar(j,l)=total(thd2(j,*,l))/nc
qbar(j,l)=total(qn(j,*,l))/nc
pbar(j,l)=total(pn(j,*,l))/nc
ybar(j,l)=xlat(j)
endfor
endfor
level=-3.0+.2*findgen(31)
!p.multi=[0,3,1]
plot_io,ybar,pbar,xrange=[-90,90],yrange=[1000.,10.],/nodata,$
xtitle='Latitude',ytitle='Pressure'
contour,qbar,ybar,pbar,level=level,$
c_linestyle = level lt 0.,/overplot
plot_io,ybar,pbar,xrange=[-90,90],yrange=[1000.,10.],/nodata,$
xtitle='Latitude',ytitle='Pressure'
contour,thdbar,ybar,pbar,level=level,$ 
c_linestyle = level lt 0.,/overplot
plot_io,ybar,pbar,xrange=[-90,90],yrange=[1000.,10.],/nodata,$
xtitle='Latitude',ytitle='Pressure'
contour,qbar-thdbar,ybar,pbar,level=level,$ 
c_linestyle = level lt 0.,/overplot
;
; write output
;
close,10
openw,10,datelabn+'_theta_dot_newest.dat'
writeu,10,nr,nc,nth
writeu,10,xlat,xlon,th
writeu,10,thd2,rhjn,pn
;
rhjnm1=rhjn
divnm1=divn
qnm1=qn
datelabnm1=datelabn
;
rhjn=rhjnp1
divn=divnp1
qn=qnp1
datelabn=datelabnp1
goto, jump	; loop over days
end
