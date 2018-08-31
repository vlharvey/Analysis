
; Plot markers.  cyclones = 1;  anticyclones = -1

@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_th_v2
@compdiv

num=0L
nlvls=20
loadct,38
mcolor=!p.color
icolmax=byte(!p.color)
icmm1=icolmax-1B
icmm2=icolmax-2B
col1=1+indgen(nlvls)*icolmax/nlvls
!NOERAS=-1
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
rd_ukmo_th_v2,imn,idy,iyr1,inc,inr,inth,xlon,xlat,th,$
           pv2,p2,msf2,u2,v2,q2,qdf2,mark2,iflg
if iflg ne 0 then goto,jump
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
div2=0*pv2
; loop over theta from top down
FOR thlev=1,nth-1 DO BEGIN

; extract theta level
theta=th(thlev)
print,'theta level=',theta
u1=.5*(transpose(u2(*,*,thlev))+transpose(u2(*,*,thlev-1)))
v1=.5*(transpose(v2(*,*,thlev))+transpose(v2(*,*,thlev-1)))
u1=reform(u1,nc,nr)
v1=reform(v1,nc,nr)
; introduce divergence, isentropic Jacobian 
div1=u1*0.0
rhj=u1*0.0
;
; compute isentropic Jacobian
;
for j=0,nr-1 do begin
for i=0,nc-1 do begin
dth=th(thlev)-th(thlev-1)
dp=p2(j,i,thlev)-p2(j,i,thlev-1)
rhj(i,j)=-dp/(9.8*dth)
endfor
endfor
rhj=reform(rhj,nc,nr)
; compute divergence, div
compdiv,u1,v1,rhj,div1,xlon,xlat,inc,inr
div2(*,*,thlev)=transpose(div1)
rhj2(*,*,thlev)=transpose(rhj)
ENDFOR  ; loop over theta
;
; write output
;
close,10
openw,10,datelab+'_rhj_div.dat'
writeu,10,nr,nc,nth
writeu,10,xlat,xlon,th
writeu,10,div2,rhj2,q2,p2
goto, jump	; loop over days
end
