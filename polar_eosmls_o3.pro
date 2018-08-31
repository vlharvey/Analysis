;****************************************************************************************
; Programed by: V. Lynn Harvey  7/7/05							*
;               CU/LASP									*
;
; plot EOS-MLS o3 in a mercator projection
;
; EOS-MLS "o3" structure variables:
; SWATHNAME		STRING    'O3'
; NTIMES		LONG              3494
; NLEVELS		LONG                37
; NFREQS		LONG                 0
; PRESSURE		FLOAT     Array[37]
; FREQUENCY		DOUBLE    Array[1]
; LATITUDE		FLOAT     Array[3494]
; LONGITUDE		FLOAT     Array[3494]
; TIME			DOUBLE    Array[3494]
; LOCALSOLARTIME	FLOAT     Array[3494]
; SOLARZENITHANGLE	FLOAT     Array[3494]
; LINEOFSIGHTANGLE	FLOAT     Array[3494]
; ORBITGEODETICANGLE	FLOAT     Array[3494]
; CHUNKNUMBER		LONG      Array[3494]
; L2GPVALUE		FLOAT     Array[37, 3494]
; L2GPPRECISION		FLOAT     Array[37, 3494]
; STATUS		LONG      Array[3494]
; QUALITY		FLOAT     Array[3494]
; ATTRIBUTES      STRUCT    -> <Anonymous> Array[1]
;
; IDL> help,/struct,o3.attributes
; _FILLVALUE      FLOAT     Array[1]
; TITLE           STRING    'O3'
; UNITS           STRING    'vmr'
; MISSINGVALUE    FLOAT     Array[1]
; UNIQUEFIELDDEFINITION STRING    'HIRDLS-MLS-TES-Shared'
;
;****************************************************************************************
@stddat
@kgmt
@ckday
@kdate
@readl2gp
setplot='x'
read,'setplot?',setplot
loadct,38
device,decompose=0
mcolor=byte(!p.color)
mcolor=fix(mcolor)
if mcolor eq 0 then mcolor=255
nlvls=21
col1=1+mcolor*findgen(nlvls)/nlvls
icmm1=mcolor-1
icmm2=mcolor-2
!noeras=1
a=findgen(6)*(2*!pi/6.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
xorig=[0.1]
yorig=[0.15]
xlen=0.8
ylen=0.8
cbaryoff=0.03
cbarydel=0.02
if setplot ne 'ps' then begin
   lc=mcolor
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/aura6/data/MLS_data/Datfiles/'
;lstmn=12L & lstdy=31L & lstyr=2006L
;ledmn=12L & leddy=31L & ledyr=2006L
lstday=0L & ledday=0L 
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 or lstyr gt 2011 then stop,'Year out of range '
if ledyr lt 1991 or ledyr gt 2011 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      z = stddat(imn,idy,iyr,ndays)
      if ndays gt ledday then stop,' Normal termination condition '
;
; read EOS-MLS data: i.e. MLS-Aura_L2GP-O3_v01-51-c20_2004d243.he5
;
      spawn,'ls '+dir+'MLS-Aura_L2GP-O3_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',o3files
      spawn,'ls '+dir+'MLS-Aura_L2GP-GPH_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',gpfiles
      spawn,'ls '+dir+'MLS-Aura_L2GP-CO_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',cofiles
      spawn,'ls '+dir+'MLS-Aura_L2GP-HCl_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',hclfiles
      spawn,'ls '+dir+'MLS-Aura_L2GP-ClO_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',clofiles
      spawn,'ls '+dir+'MLS-Aura_L2GP-H2O_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',h2ofiles
      spawn,'ls '+dir+'MLS-Aura_L2GP-HNO3_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',hno3files
      spawn,'ls '+dir+'MLS-Aura_L2GP-N2O_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',n2ofiles
      spawn,'ls '+dir+'MLS-Aura_L2GP-Temperature*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',tpfiles
      result=size(o3files)
      if result(0) eq 0L then goto,jump
      o3=readl2gp(o3files(0),swathName='O3',variableName=variableName,precisionName=precisionName)
      gp=readl2gp(gpfiles(0),swathName='GPH',variableName=variableName,precisionName=precisionName)
      co=readl2gp(cofiles(0),swathName='CO',variableName=variableName,precisionName=precisionName)
      hcl=readl2gp(hclfiles(0),swathName='HCl',variableName=variableName,precisionName=precisionName)
      clo=readl2gp(clofiles(0),swathName='ClO',variableName=variableName,precisionName=precisionName)
      h2o=readl2gp(h2ofiles(0),swathName='H2O',variableName=variableName,precisionName=precisionName)
      hno3=readl2gp(hno3files(0),swathName='HNO3',variableName=variableName,precisionName=precisionName)
      n2o=readl2gp(n2ofiles(0),swathName='N2O',variableName=variableName,precisionName=precisionName)
      tp=readl2gp(tpfiles(0),swathName='Temperature',variableName=variableName,precisionName=precisionName)
;
; extract variables from structures
;
      pmls=o3.pressure
      xmls=o3.longitude
      ymls=o3.latitude
      tmls=o3.time
      o3mls=o3.L2GPVALUE
      o3precision=o3.L2GPPRECISION
      o3status=o3.STATUS
      o3quality=o3.QUALITY
      o3mask=0.*o3mls
      gpmls=gp.L2GPVALUE
      gpprecision=gp.L2GPPRECISION
      gpstatus=gp.STATUS
      gpquality=gp.QUALITY
      gpmask=0.*gpmls
      comls=co.L2GPVALUE
      coprecision=co.L2GPPRECISION
      costatus=co.STATUS
      coquality=co.QUALITY
      comask=0.*comls
      hclmls=hcl.L2GPVALUE
      hclprecision=hcl.L2GPPRECISION
      hclstatus=hcl.STATUS
      hclquality=hcl.QUALITY
      hclmask=0.*hclmls
      clomls=clo.L2GPVALUE
      cloprecision=clo.L2GPPRECISION
      clostatus=clo.STATUS
      cloquality=clo.QUALITY
      clomask=0.*clomls
      h2omls=h2o.L2GPVALUE
      h2oprecision=h2o.L2GPPRECISION
      h2ostatus=h2o.STATUS
      h2oquality=h2o.QUALITY
      h2omask=0.*h2omls
      hno3mls=hno3.L2GPVALUE
      hno3precision=hno3.L2GPPRECISION
      hno3status=hno3.STATUS
      hno3quality=hno3.QUALITY
      hno3mask=0.*hno3mls
      n2omls=n2o.L2GPVALUE
      n2oprecision=n2o.L2GPPRECISION
      n2ostatus=n2o.STATUS
      n2oquality=n2o.QUALITY
      n2omask=0.*n2omls
      tpmls=tp.L2GPVALUE
      tpprecision=tp.L2GPPRECISION
      tpstatus=tp.STATUS
      tpquality=tp.QUALITY
      tpmask=0.*tpmls
;
; use quality, status, and precision flags to mask suspect data
;
      o3bad=where(o3precision lt 0.)
      if o3bad(0) ne -1L then o3mask(o3bad)=-99.
      gpbad=where(gpprecision lt 0.)
      if gpbad(0) ne -1L then gpmask(gpbad)=-99.
      cobad=where(coprecision lt 0.)
      if cobad(0) ne -1L then comask(cobad)=-99.
      hclbad=where(hclprecision lt 0.)
      if hclbad(0) ne -1L then hclmask(hclbad)=-99.
      clobad=where(cloprecision lt 0.)
      if clobad(0) ne -1L then clomask(clobad)=-99.
      h2obad=where(h2oprecision lt 0.)
      if h2obad(0) ne -1L then h2omask(h2obad)=-99.
      hno3bad=where(hno3precision lt 0.)
      if hno3bad(0) ne -1L then hno3mask(hno3bad)=-99.
      n2obad=where(n2oprecision lt 0.)
      if n2obad(0) ne -1L then n2omask(n2obad)=-99.
      tpbad=where(tpprecision lt 0.)
      if tpbad(0) ne -1L then tpmask(tpbad)=-99.

      o3bad=where(o3status mod 2 ne 0L)		; o3status=0 is good, all odd values are bad
      if o3bad(0) ne -1L then o3mask(*,o3bad)=-99.
      gpbad=where(gpstatus mod 2 ne 0L)         ; gpstatus=0 is good, all odd values are bad
      if gpbad(0) ne -1L then gpmask(*,gpbad)=-99.
      cobad=where(costatus mod 2 ne 0L)         ; costatus=0 is good, all odd values are bad
      if cobad(0) ne -1L then comask(*,cobad)=-99.
      hclbad=where(hclstatus mod 2 ne 0L)         ; hclstatus=0 is good, all odd values are bad
      if hclbad(0) ne -1L then hclmask(*,hclbad)=-99.
      clobad=where(clostatus mod 2 ne 0L)         ; clostatus=0 is good, all odd values are bad
      if clobad(0) ne -1L then clomask(*,clobad)=-99.
      h2obad=where(h2ostatus mod 2 ne 0L)          ; h2ostatus=0 is good, all odd values are bad
      if h2obad(0) ne -1L then h2omask(*,h2obad)=-99.
      hno3bad=where(hno3status mod 2 ne 0L)         ; hno3status=0 is good, all odd values are bad
      if hno3bad(0) ne -1L then hno3mask(*,hno3bad)=-99.
      n2obad=where(n2ostatus mod 2 ne 0L)         ; n2ostatus=0 is good, all odd values are bad
      if n2obad(0) ne -1L then n2omask(*,n2obad)=-99.
      tpbad=where(tpstatus mod 2 ne 0L)          ; tpstatus=0 is good, all odd values are bad
      if tpbad(0) ne -1L then tpmask(*,tpbad)=-99.

      o3bad=where(o3quality lt 0.1)         ; do not use if quality < 0.1
      if o3bad(0) ne -1L then o3mask(*,o3bad)=-99.
      gpbad=where(tpquality lt 1.0)         ; do not use if quality < 1.0
      if gpbad(0) ne -1L then gpmask(*,gpbad)=-99.
      cobad=where(coquality lt 0.05)         ; do not use if quality < 0.05
      if cobad(0) ne -1L then comask(*,cobad)=-99.
      hclbad=where(hclquality lt 1.5)         ; do not use if quality < 1.5
      if hclbad(0) ne -1L then hclmask(*,hclbad)=-99.
      clobad=where(cloquality lt 2.7)         ; do not use if quality < 2.7
      if clobad(0) ne -1L then clomask(*,clobad)=-99.
      h2obad=where(h2oquality lt 0.02)          ; do not use if h2oquality 0.02
      if h2obad(0) ne -1L then h2omask(*,h2obad)=-99.
      hno3bad=where(hno3quality lt 0.17)         ; do not use if quality < 0.17
      if hno3bad(0) ne -1L then hno3mask(*,hno3bad)=-99.
      n2obad=where(n2oquality lt 1.5)         ; do not use if quality < 1.5
      if n2obad(0) ne -1L then n2omask(*,n2obad)=-99.
      tpbad=where(tpquality lt 1.0)          ; do not use if tpquality < 1.0
      if tpbad(0) ne -1L then tpmask(*,tpbad)=-99.

      if iyr ge 2000 then iyr1=iyr-2000
      if iyr lt 2000 then iyr1=iyr-1900
      uyr=string(FORMAT='(I2.2)',iyr1)
      syr=string(FORMAT='(I4.4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
      yymmdd=long(sdate)

      print,pmls
      rpress=10.
      read,'Enter pressure level ',rpress
      index=where(long(pmls*1000./1000.) eq long(rpress*1000./1000.))
      ilev=index(0)
      spress=strtrim(string(pmls(ilev)),2)

      if setplot eq 'ps' then begin
         lc=0
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !psym=0
         !p.font=0
         device,font_size=9
         device,/portrait,bits=8,filename='polar_mls_o3_'+sdate+'_'+spress+'.ps'
         device,/color
         device,/inch,xoff=0.05,yoff=.1,xsize=xsize,ysize=ysize
      endif
;
; NH polar plot of MLS ozone
;
      erase
      !type=2^2+2^3
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      MAP_SET,90,0,0,/stereo,/noeras,/grid,/contin,charsize=2,color=0,$
              title='EOS-MLS Ozone on '+sdate+' and '+spress+' hPa'
      index=where(o3mask lt 0.)
      if index(0) ne -1L then o3mls(index)=-99.
      o3m=reform(o3mls(ilev,*))*1.e6
      imax=12.
      imin=2.
      for i=0,n_elements(xmls)-1 do $
          if ymls(i) gt 0. and o3m(i) gt 0. then $
             oplot,[xmls(i),xmls(i)],[ymls(i),ymls(i)],psym=8,$
                   color=((o3m(i)-imin)/(imax-imin))*mcolor,symsize=1.5
;
; color bar
;
      ymnb=ymn-cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,xmn+0.05,xmx-0.05,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle='(ppmv)',charsize=1.5,color=0
      ybox=[0,10,10,0,0]
      x1=imin
      dx=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor

      if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device,/close
         spawn,'convert -trim polar_mls_o3_'+sdate+'_'+spress+'.ps polar_mls_o3_'+sdate+'_'+spress+'.jpg'
      endif
goto,jump
end
