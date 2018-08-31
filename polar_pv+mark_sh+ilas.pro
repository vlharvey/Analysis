;
; plot southern hemisphere polar projection of isentropic potential vorticity
;
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nc3

lstmn=10
lstdy=3
lstyr=1995
ledmn=10
leddy=3
ledyr=1995
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;print, ' '
;print, '      UKMO Version '
;print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
setplot='ps'
read,'setplot=',setplot
nxdim=500
nydim=500
xorig=[0.1]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.03
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
diri='/aura3/data/ILAS_data/Datfiles_SOSST/'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L

; --- Loop here --------
jump: iday = iday + 1
print,iday
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '

      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      smn=string(FORMAT='(i2.2)',imn)
      uyr=strmid(syr,2,2)
      ifile=mon(imn-1)+sdy+'_'+uyr

    iflag=0
    rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump
    if icount eq 0 then begin
;
; ILAS
;
    ex=findfile(diri+'cat_ilas_v06.10.'+syr)
    if ex(0) ne '' then begin
       restore,diri+'cat_ilas_v06.10.'+syr
    endif
    ex=findfile(diri+'cat_ilas2_v1.4.'+syr)
    if ex(0) ne '' then begin
       restore,diri+'cat_ilas2_v1.4.'+syr
    endif

       theta=700.
       print,th
       read,'Enter theta ',theta
       index=where(theta eq th)
       if index(0) eq -1 then stop,'Invalid theta level '
       thlev=index(0)
    endif
;
; pick out ILAS day
;
    index=where(date eq long(syr+smn+sdy),nilas)
    if index(0) ne -1L then begin
    xilas=longitude(index)
    yilas=latitude(index)
    endif

;   for thlev=0,nth-1 do begin
    theta=th(thlev)
    stheta=strcompress(string(fix(theta)),/remove_all)
    qdf1=transpose(qdf2(*,*,thlev))
    sf1=transpose(sf2(*,*,thlev))
    pv1=transpose(pv2(*,*,thlev))
    mark1=transpose(mark2(*,*,thlev))
    qdf=0.*fltarr(nc+1,nr)
    qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
    qdf(nc,*)=qdf(0,*)
    sf=0.*fltarr(nc+1,nr)
    sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
    sf(nc,*)=sf(0,*)
    pv=0.*fltarr(nc+1,nr)
    pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
    pv(nc,*)=pv(0,*)
    mark=0.*fltarr(nc+1,nr)
    mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
    mark(nc,*)=mark(0,*)
    x=fltarr(nc+1)
    x(0:nc-1)=alon
    x(nc)=alon(0)+360.
    lon=0.*sf
    lat=0.*sf
    for i=0,nc   do lat(i,*)=alat
    for j=0,nr-1 do lon(*,j)=x

    if setplot eq 'ps' then begin
       lc=0
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename=ifile+'_'+stheta+'K_pv+mark_sh.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif
    erase
    !psym=0
    MAP_SET,-90,0,0,/stereo,/noeras,/grid,/contin,/noborder,$
            title=ifile+'  '+stheta+' K',charsize=2.0,latdel=10
    oplot,findgen(361),0.1+0.*findgen(361)
;   if icount eq 0 then begin
       index=where(lat lt 0.)
       pvmin=min(pv(index))
       pvmax=max(pv(index))
       nlvls=30
       pvint=(pvmax-pvmin)/nlvls
       pvlevel=pvmin+pvint*findgen(nlvls)
       col1=1+indgen(nlvls)*icolmax/float(nlvls)
;   endif
    contour,pv,x,alat,/overplot,levels=pvlevel,c_color=col1,$
           /cell_fill,/noeras
    contour,pv,x,alat,/overplot,levels=pvlevel,/follow,$
            c_labels=0*pvlevel,/noeras,color=0
    contour,mark,x,alat,/overplot,levels=[0.1],thick=5,color=mcolor
    contour,mark,x,alat,/overplot,levels=[-0.1],thick=5,color=0
    MAP_SET,-90,0,0,/stereo,/noeras,/grid,/contin,/noborder,$
           charsize=2.0,latdel=10
    if nilas gt 0L then oplot,xilas,yilas,psym=8
    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim '+ifile+'_'+stheta+'K_pv+mark_sh.ps -rotate -90 '+$
             ifile+'_'+stheta+'K_pv+mark_sh.jpg'
    endif
;   endfor
    icount=1L
goto,jump
end
