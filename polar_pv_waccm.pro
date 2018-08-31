;
; reads in WACCM .sav and plots polar projection
;
@stddat
@kgmt
@ckday
@kdate

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
lstmn=11
lstdy=1
lstyr=2003
ledmn=7
leddy=1
ledyr=2004
lstday=0
ledday=0
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

dir='/aura3/data/WACCM_data/Datfiles/PV_ELAT_S1_'
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
      syr=strcompress(string(iyr),/remove_all)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      date=syr+smn+sdy
      ifile=date+'.sav'
      restore,dir+ifile
      pv2=pv
      elat2=elat
      if icount eq 0 then begin
         rpress=0.
         print,lev
         read,'Enter pressure level ',rpress
         index=where(long(rpress*10000.) eq long(lev*10000.))
         if index(0) eq -1 then stop,'Invalid pressure level '
         ipress=index(0)
         spress=strcompress(string(rpress),/remove_all)
      endif
      elat1=reform(elat2(*,*,ipress))
      pv1=reform(pv2(*,*,ipress))
      nc=n_elements(alon)
      nr=n_elements(alat)
      pv=0.*fltarr(nc+1,nr)
      pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
      pv(nc,*)=pv(0,*)
      elat=0.*fltarr(nc+1,nr)
      elat(0:nc-1,0:nr-1)=elat1(0:nc-1,0:nr-1)
      elat(nc,*)=elat(0,*)
      pv(*,nr-1)=pv(*,nr-2)
      elat(*,nr-1)=elat(*,nr-2)
pv=smooth(pv,3,/edge_truncate)
elat=smooth(elat,3,/edge_truncate)
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
                filename='waccm_'+date+'_'+spress+'.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
      endif
      erase
      !psym=0
      MAP_SET,90,0,0,/stereo,/noeras,/grid,/contin,/noborder,$
              title=date+'  '+spress+' hPa',charsize=2.0
      oplot,findgen(361),0.1+0.*findgen(361)
      if icount eq 0 then begin
         index=where(lat gt 0. and pv ne -1.e12)
         pvmin=min(pv(index))
         pvmax=max(pv(index))
         nlvls=20
         pvint=(pvmax-pvmin)/nlvls
         pvlevel=pvmin+pvint*findgen(nlvls)
         col1=1+indgen(nlvls)*icolmax/float(nlvls)
      endif
      contour,pv,x,alat,/overplot,levels=pvlevel,c_color=col1,$
             /cell_fill,/noeras,min_value=-1.e12
      contour,pv,x,alat,/overplot,levels=pvlevel,/follow,$
              c_labels=0*pvlevel,/noeras,color=0,min_value=-1.e12
      contour,elat,x,alat,/overplot,levels=[65.],thick=10,color=mcolor,max_value=1.e12
      MAP_SET,90,0,0,/stereo,/noeras,/grid,/contin,/noborder,charsize=2.0
;     if setplot ne 'ps' then stop
      if setplot eq 'ps' then device, /close
    icount=icount+1
goto,jump
end
