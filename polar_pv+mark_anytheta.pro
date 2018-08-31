;
; plot IPV at any theta i.e. vertically interpolate if necessary
;
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nc3

lstmn=4
lstdy=12
lstyr=2001
ledmn=4
leddy=12
ledyr=2001
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;print, ' '
;print, '      UKMO Version '
;print, ' '
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
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
      uyr=strmid(syr,2,2)
      ifile=mon(imn-1)+sdy+'_'+uyr
      rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
              pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
      if iflag eq 1 then goto,jump
      if icount eq 0L then begin
         theta=0.
         read,'Enter theta between ',min(th),max(th),' ',theta
         stheta=strcompress(string(fix(theta)),/remove_all)
      endif

      for kk=1L,nth-1L do begin
          kp1=kk-1             ; UKMO theta profile is top down
          uth=th(kk)
          uthp1=th(kp1)
          if theta ge uth and theta le uthp1 then begin
             zscale=(theta-uth)/(uthp1-uth)
             p1=reform(pv2(*,*,kk))
             p2=reform(pv2(*,*,kp1))
             pv1=p1+zscale*(p2-p1)

             p1=reform(mark2(*,*,kk))
             p2=reform(mark2(*,*,kp1))
             mark1=p1+zscale*(p2-p1)

             goto,jumpz
          endif
      endfor
jumpz:
    pv1=transpose(pv1)
    mark1=transpose(mark1)

    pv=0.*fltarr(nc+1,nr)
    pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
    pv(nc,*)=pv(0,*)
    mark=0.*fltarr(nc+1,nr)
    mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
    mark(nc,*)=mark(0,*)
    x=fltarr(nc+1)
    x(0:nc-1)=alon
    x(nc)=alon(0)+360.
    lon=0.*pv
    lat=0.*pv
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
       device,/landscape,bits=8,$
              filename='Figures/'+ifile+'_'+stheta+'K_pv+mark.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif
    erase
    !psym=0
    MAP_SET,90,0,0,/ortho,/noeras,/grid,/contin,/noborder,$
            title=ifile+'  '+stheta+' K',charsize=2.0,latdel=10,$
            limit=[30.,0.,90.,360.]
    oplot,findgen(361),0.1+0.*findgen(361)
    if icount eq 0 then begin
       index=where(lat gt 0.)
       pvmin=0.
       pvmax=max(pv(index))+0.1*max(pv(index))
       nlvls=20
       pvint=(pvmax-pvmin)/nlvls
       pvlevel=pvmin+pvint*findgen(nlvls)
       col1=1+indgen(nlvls)*icolmax/float(nlvls)
    endif
    contour,pv,x,alat,/overplot,levels=pvlevel,c_color=col1,$
           /cell_fill,/noeras
    contour,pv,x,alat,/overplot,levels=pvlevel,/follow,$
            c_labels=0*pvlevel,/noeras,color=0
    contour,mark,x,alat,/overplot,levels=[0.1],thick=10,color=mcolor
    MAP_SET,90,0,0,/ortho,/noeras,/grid,/contin,/noborder,$
           charsize=2.0,latdel=10,limit=[30.,0.,90.,360.]

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then device, /close
    icount=1L
goto,jump
end
