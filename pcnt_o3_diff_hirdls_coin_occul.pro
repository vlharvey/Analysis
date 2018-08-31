;
; plot difference between physically coincident 
; HIRDLS and HALOE/SAGE II/SAGE III/POAM III
; VLH 11/10/2003
;
@aura2date
@loadauradata
@rd_sage3_o3_soundings
@rd_haloe_o3_soundings
@rd_poam3_o3_soundings
@rd_sage2_o3_soundings
@rd_ukmo_nc3
@stddat
@kgmt
@ckday
@kdate

re=40000./2./!pi
rad=double(180./!pi)
dtr=double(!pi/180.)
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
nlvls=20
col1=1+indgen(nlvls)*mcolor/nlvls
icmm1=icolmax-1
icmm2=icolmax-2
setplot='x'
read,'setplot=',setplot
nxdim=750 & nydim=750
xorig=[0.15,0.55,0.15,0.55]
yorig=[0.55,0.55,0.13,0.13]
xlen=0.3
ylen=0.3
cbaryoff=0.01
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
SpeciesNames = ['Temperature',$
                'H2O', $
                'O3',  $
                'N2O', $
                'HNO3']
GeoLoc = ['Pressure',$
          'Time',$
          'Latitude',$
          'Longitude',$
          'SolarZenithAngle',$
          'LocalSolarTime']
hdir='/aura3/data/HIRDLS_data/Datfiles/'
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
dirh='/aura3/data/HALOE_data/Sound_data/haloe_'
dirs='/aura3/data/SAGE_II_data/Sound_data/sage2_'
dirs3='/aura3/data/SAGE_III_data/Sound_data/sage3_solar_'
dirp='/aura3/data/POAM_data/Sound_data/poam3_'
ifile='                             '
lstmn=10 & lstdy=2 & lstyr=0 & lstday=0
ledmn=10 & leddy=2 & ledyr=0 & ledday=0
;
; Ask interactive questions- get starting/ending date
;
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
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; test for end condition and close windows.
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,plotit
;
; read satellite ozone soundings
;
      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      sfile=mon(imn-1)+sdy+'_'+syr
      rd_sage3_o3_soundings,dirs3+sfile+'_o3.sound',norbits3,tsage3,$
         xsage3,ysage3,tropps3,tropzs3,tropths3,modes3,o3sage3,psage3,$
         thsage3,zsage3,clsage3,qo3sage3,nlevs3
      print,norbits3,' SAGE III'
      rd_sage2_o3_soundings,dirs+sfile+'_o3.sound',norbits2,tsage2,$
         xsage2,ysage2,tropps2,tropzs2,tropths2,modes2,o3sage2,psage2,$
         thsage2,zsage2,clsage2,qo3sage2,nlevs2
      print,norbits2,' SAGE II'
      rd_poam3_o3_soundings,dirp+sfile+'_o3.sound',norbitp3,tpoam3,$
         xpoam3,ypoam3,troppp3,tropzp3,tropthp3,modep3,o3poam3,ppoam3,$
         thpoam3,zpoam3,clpoam3,qo3poam3,nlevp3
      print,norbitp3,' POAM III'
      rd_haloe_o3_soundings,dirh+sfile+'_o3.sound',norbith,thal,$
         xhal,yhal,tropph,tropzh,tropthh,modeh,o3hal,phal,$
         thhal,zhal,clhal,qo3hal,nlevh
      print,norbith,' HALOE'
;
; read HIRDLS and MLS data
;
      sday=strcompress(string(iday),/remove_all)
      Hfile=hdir+'HIRDLS2_'+syr+'d'+sday+'_MZ3_c1.he5'
      print,hfile

;; load HIRDLS data all at once
      hirdls=LoadAuraData(Hfile, [GeoLoc, SpeciesNames])

;; file header and tail for MLS
      Mfileh=hdir+'MLS-Aura_L2GP-'
      Mfilet='_sAura2c--t_'+syr+'d'+sday+'.he5'
      print,mfilet

;; loop over species
      FOR is = 0,N_ELEMENTS(SpeciesNames)-1 DO BEGIN
          SpeciesName = SpeciesNames(is)
          Mfile=Mfileh + SpeciesName + Mfilet
          IF is EQ 0 THEN mls = LoadAuraData(Mfile, GeoLoc)
          mls=LoadAuraData(Mfile, SpeciesName, mls)
      ENDFOR
;
; extract mls and hirdls variables
; time is elapsed seconds since midnight 1 Jan 1993
;
      mpress=mls.p            ; P               FLOAT     Array[37]
      mlev=n_elements(mpress)
      mtime=mls.time          ; TIME            DOUBLE    Array[3495]
      mlat=mls.lat            ; LAT             FLOAT     Array[3495]
      mlon=mls.lon            ; LON             FLOAT     Array[3495]
      msza=mls.sza            ; SZA             FLOAT     Array[3495]
      mlst=mls.lst            ; LST             FLOAT     Array[3495]
      mprof=n_elements(mlst)
      mtemp=mls.t             ; T               FLOAT     Array[37, 3495]
      mh2o=mls.h2o            ; H2O             FLOAT     Array[37, 3495]
      mo3=mls.o3              ; O3              FLOAT     Array[37, 3495]
      mn2o=mls.n2o            ; N2O             FLOAT     Array[37, 3495]
      mhno3=mls.hno3          ; HNO3            FLOAT     Array[37, 3495]

      hpress=hirdls.p         ;   P               FLOAT     Array[145]
      hlev=n_elements(hpress)
      htime=hirdls.time       ;   TIME            DOUBLE    Array[7848]
      hlat=hirdls.lat         ;   LAT             FLOAT     Array[7848]
      hlon=hirdls.lon         ;   LON             FLOAT     Array[7848]
      hsza=hirdls.sza         ;   SZA             FLOAT     Array[7848]
      hlst=hirdls.lst         ;   LST             FLOAT     Array[7848]
      hprof=n_elements(hlst)
      htemp=hirdls.t          ;   T               FLOAT     Array[145, 7848]
      hh2o=hirdls.h2o         ;   H2O             FLOAT     Array[145, 7848]
      ho3=hirdls.o3           ;   O3              FLOAT     Array[145, 7848]
      hn2o=hirdls.n2o         ;   N2O             FLOAT     Array[145, 7848]
      hno3=hirdls.hno3        ;   HNO3            FLOAT     Array[145, 7848]
;
; convert elapsed seconds to dates (yyyymmddhh)
;
      aura2date,mdate,mtime
      aura2date,hdate,htime
;
; make press,lat,lon 2d
;
      mpress2=0.*mo3
      mlat2=0.*mo3
      mlon2=0.*mo3
      for i=0L,mprof-1L do mpress2(*,i)=mpress
      for i=0L,mlev-1L do begin
          mlat2(i,*)=mlat
          mlon2(i,*)=mlon
      endfor
      hpress2=0.*ho3
      hlat2=0.*ho3
      hlon2=0.*ho3
      for i=0L,hprof-1L do hpress2(*,i)=hpress
      for i=0L,hlev-1L do begin
          hlat2(i,*)=hlat
          hlon2(i,*)=hlon
      endfor
      mtheta=mtemp*(1000./mpress2)^0.286
      htheta=htemp*(1000./hpress2)^0.286
;
; retain coincident soundings
;
      if icount eq 0L then begin
         ncoin=1000L & nlev=300L & dxc=100.
         xcoinhal=-9999.+fltarr(ncoin)
         ycoinhal=-9999.+fltarr(ncoin)
         pcoinhal=-9999.+fltarr(ncoin,nlev)
         thcoinhal=-9999.+fltarr(ncoin,nlev)
         o3coinhal=-9999.+fltarr(ncoin,nlev)
         xcoinhirdlshal=-9999.+fltarr(ncoin)
         ycoinhirdlshal=-9999.+fltarr(ncoin)
         pcoinhirdlshal=-9999.+fltarr(ncoin,nlev)
         thcoinhirdlshal=-9999.+fltarr(ncoin,nlev)
         o3coinhirdlshal=-9999.+fltarr(ncoin,nlev)

         xcoinsage3=-9999.+fltarr(ncoin)
         ycoinsage3=-9999.+fltarr(ncoin)
         pcoinsage3=-9999.+fltarr(ncoin,nlev)
         thcoinsage3=-9999.+fltarr(ncoin,nlev)
         o3coinsage3=-9999.+fltarr(ncoin,nlev)
         xcoinhirdls3=-9999.+fltarr(ncoin)
         ycoinhirdls3=-9999.+fltarr(ncoin)
         pcoinhirdls3=-9999.+fltarr(ncoin,nlev)
         thcoinhirdls3=-9999.+fltarr(ncoin,nlev)
         o3coinhirdls3=-9999.+fltarr(ncoin,nlev)

         xcoinsage2=-9999.+fltarr(ncoin)
         ycoinsage2=-9999.+fltarr(ncoin)
         pcoinsage2=-9999.+fltarr(ncoin,nlev)
         thcoinsage2=-9999.+fltarr(ncoin,nlev)
         o3coinsage2=-9999.+fltarr(ncoin,nlev)
         xcoinhirdls2=-9999.+fltarr(ncoin)
         ycoinhirdls2=-9999.+fltarr(ncoin)
         pcoinhirdls2=-9999.+fltarr(ncoin,nlev)
         thcoinhirdls2=-9999.+fltarr(ncoin,nlev)
         o3coinhirdls2=-9999.+fltarr(ncoin,nlev)

         xcoinpoam3=-9999.+fltarr(ncoin)
         ycoinpoam3=-9999.+fltarr(ncoin)
         pcoinpoam3=-9999.+fltarr(ncoin,nlev)
         thcoinpoam3=-9999.+fltarr(ncoin,nlev)
         o3coinpoam3=-9999.+fltarr(ncoin,nlev)
         xcoinhirdlsp3=-9999.+fltarr(ncoin)
         ycoinhirdlsp3=-9999.+fltarr(ncoin)
         pcoinhirdlsp3=-9999.+fltarr(ncoin,nlev)
         thcoinhirdlsp3=-9999.+fltarr(ncoin,nlev)
         o3coinhirdlsp3=-9999.+fltarr(ncoin,nlev)

         hcoin=0L & scoin2=0L & scoin3=0L & pcoin3=0L
         hhcoin=0L & hscoin2=0L & hscoin3=0L & hpcoin3=0L
      endif
;
; find HIRDLS soundings within dxc km of HALOE/SAGE II/SAGE III/POAM III soundings 
;
; HIRDLS/HALOE
;
      if norbith gt 0L then begin
         for i=0,norbith-1L do begin
             xh=xhal(i) & yh=yhal(i)
             dxf=re*abs(xh-hlon)*dtr*cos(yh*dtr)
             dyf=re*abs(yh-hlat)*dtr
             dist=sqrt(dxf*dxf+dyf*dyf)
             hindex=where(dist le dxc,ncoin0)
             if hindex(0) ne -1 then begin
                for icoin=0L,ncoin0-1L do begin
                    ii=hindex(icoin)
                    xcoinhirdlshal(hhcoin)=hlon(ii)
                    ycoinhirdlshal(hhcoin)=hlat(ii)
                    pcoinhirdlshal(hhcoin,0:hlev-1L)=hpress2(*,ii)
                    thcoinhirdlshal(hhcoin,0:hlev-1L)=htheta(*,ii)
                    o3coinhirdlshal(hhcoin,0:hlev-1L)=ho3(*,ii)
                    hhcoin=hhcoin+1L
                    if hhcoin ge ncoin then stop,'increase ncoin'
                endfor
                xcoinhal(hcoin)=xh
                ycoinhal(hcoin)=yh
                pcoinhal(hcoin,0:nlevh-1L)=phal(i,*)
                thcoinhal(hcoin,0:nlevh-1L)=thhal(i,*)
                o3coinhal(hcoin,0:nlevh-1L)=o3hal(i,*)
                hcoin=hcoin+1L
             endif
         endfor
      endif
;
; HIRDLS/SAGE III
;
      if norbits3 gt 0L then begin
         for i=0,norbits3-1L do begin
             xh=xsage3(i) & yh=ysage3(i)
             dxf=re*abs(xh-hlon)*dtr*cos(yh*dtr)
             dyf=re*abs(yh-hlat)*dtr
             dist=sqrt(dxf*dxf+dyf*dyf)
             hindex=where(dist le dxc,ncoin0)
             if hindex(0) ne -1 then begin
                for icoin=0L,ncoin0-1L do begin
                    ii=hindex(icoin)
                    xcoinhirdls3(hscoin3)=hlon(ii)
                    ycoinhirdls3(hscoin3)=hlat(ii)
                    pcoinhirdls3(hscoin3,0:hlev-1L)=hpress2(*,ii)
                    thcoinhirdls3(hscoin3,0:hlev-1L)=htheta(*,ii)
                    o3coinhirdls3(hscoin3,0:hlev-1L)=ho3(*,ii)
                    hscoin3=hscoin3+1L
                    if hscoin3 ge ncoin then stop,'increase ncoin'
                endfor
                xcoinsage3(scoin3)=xh
                ycoinsage3(scoin3)=yh
                pcoinsage3(scoin3,0:nlevs3-1L)=psage3(i,*)
                thcoinsage3(scoin3,0:nlevs3-1L)=thsage3(i,*)
                o3coinsage3(scoin3,0:nlevs3-1L)=o3sage3(i,*)
                scoin3=scoin3+1L
             endif
         endfor
      endif
;
; HIRDLS/SAGE II
;
      if norbits2 gt 0L then begin
         for i=0,norbits2-1L do begin
             xh=xsage2(i) & yh=ysage2(i)
             dxf=re*abs(xh-hlon)*dtr*cos(yh*dtr)
             dyf=re*abs(yh-hlat)*dtr
             dist=sqrt(dxf*dxf+dyf*dyf)
             hindex=where(dist le dxc,ncoin0)
             if hindex(0) ne -1 then begin
                for icoin=0L,ncoin0-1L do begin
                    ii=hindex(icoin)
                    xcoinhirdls2(hscoin2)=hlon(ii)
                    ycoinhirdls2(hscoin2)=hlat(ii)
                    pcoinhirdls2(hscoin2,0:hlev-1L)=hpress2(*,ii)
                    thcoinhirdls2(hscoin2,0:hlev-1L)=htheta(*,ii)
                    o3coinhirdls2(hscoin2,0:hlev-1L)=ho3(*,ii)
                    hscoin2=hscoin2+1L
                    if hscoin2 ge ncoin then stop,'increase ncoin'
                endfor
                xcoinsage2(scoin2)=xh
                ycoinsage2(scoin2)=yh
                pcoinsage2(scoin2,0:nlevs2-1L)=psage2(i,*)
                thcoinsage2(scoin2,0:nlevs2-1L)=thsage2(i,*)
                o3coinsage2(scoin2,0:nlevs2-1L)=o3sage2(i,*)
                scoin2=scoin2+1L
             endif
         endfor
      endif
;
; HIRDLS/POAM III
;
      if norbitp3 gt 0L then begin
         for i=0,norbitp3-1L do begin
             xh=xpoam3(i) & yh=ypoam3(i)
             dxf=re*abs(xh-hlon)*dtr*cos(yh*dtr)
             dyf=re*abs(yh-hlat)*dtr
             dist=sqrt(dxf*dxf+dyf*dyf)
             hindex=where(dist le dxc,ncoin0)
             if hindex(0) ne -1 then begin
                for icoin=0L,ncoin0-1L do begin
                    ii=hindex(icoin)
                    xcoinhirdlsp3(hpcoin3)=hlon(ii)
                    ycoinhirdlsp3(hpcoin3)=hlat(ii)
                    pcoinhirdlsp3(hpcoin3,0:hlev-1L)=hpress2(*,ii)
                    thcoinhirdlsp3(hpcoin3,0:hlev-1L)=htheta(*,ii)
                    o3coinhirdlsp3(hpcoin3,0:hlev-1L)=ho3(*,ii)
                    hpcoin3=hpcoin3+1L
                    if hpcoin3 ge ncoin then stop,'increase ncoin'
                endfor
                xcoinpoam3(pcoin3)=xh
                ycoinpoam3(pcoin3)=yh
                pcoinpoam3(pcoin3,0:nlevp3-1L)=ppoam3(i,*)
                thcoinpoam3(pcoin3,0:nlevp3-1L)=thpoam3(i,*)
                o3coinpoam3(pcoin3,0:nlevp3-1L)=o3poam3(i,*)
                pcoin3=pcoin3+1L
             endif
         endfor
      endif

      icount=icount+1L
goto,jump
           
plotit:
;
; bin in theta then average
;
nbin=97L
thbins=200.+20.*findgen(nbin)

if hhcoin gt 0L then begin
   xcoinhirdlshal=xcoinhirdlshal(0:hhcoin-1L)
   ycoinhirdlshal=ycoinhirdlshal(0:hhcoin-1L)
   pcoinhirdlshal=pcoinhirdlshal(0:hhcoin-1L,0:hlev-1L)
   thcoinhirdlshal=thcoinhirdlshal(0:hhcoin-1L,0:hlev-1L)
   o3coinhirdlshal=o3coinhirdlshal(0:hhcoin-1L,0:hlev-1L)
   pavehirdlshal=fltarr(nbin)
   thavehirdlshal=fltarr(nbin)
   o3avehirdlshal=fltarr(nbin)
   nbins=0L*lonarr(nbin)
   for i=0,hhcoin-1 do begin
       yh=ycoinhirdlshal(i)
       ph=reform(pcoinhirdlshal(i,*))
       thh=reform(thcoinhirdlshal(i,*))
       o3h=reform(o3coinhirdlshal(i,*))
       for k=0L,hlev-1L do begin
           for ibin=0L,nbin-2L do begin
               if thbins(ibin) le thh(k) and thbins(ibin+1L) gt thh(k) and $
                  o3h(k) gt 0. and o3h(k) ne 1.e24 then begin
                  pavehirdlshal(ibin)=pavehirdlshal(ibin)+ph(k)
                  thavehirdlshal(ibin)=thavehirdlshal(ibin)+thh(k)
                  o3avehirdlshal(ibin)=o3avehirdlshal(ibin)+o3h(k)
                  nbins(ibin)=nbins(ibin)+1L
                  goto,jumpout1
               endif
           endfor
           jumpout1:
       endfor
   endfor
   index=where(nbins gt 0L)
   pavehirdlshal(index)=pavehirdlshal(index)/float(nbins(index))
   thavehirdlshal(index)=thavehirdlshal(index)/float(nbins(index))
   o3avehirdlshal(index)=o3avehirdlshal(index)/float(nbins(index))

   xcoinhal=xcoinhal(0:hcoin-1L)
   ycoinhal=ycoinhal(0:hcoin-1L)
   pcoinhal=pcoinhal(0:hcoin-1L,0:nlevh-1L)
   thcoinhal=thcoinhal(0:hcoin-1L,0:nlevh-1L)
   o3coinhal=o3coinhal(0:hcoin-1L,0:nlevh-1L)
   pavehal=fltarr(nbin)
   thavehal=fltarr(nbin)
   o3avehal=fltarr(nbin)
   nbins=0L*lonarr(nbin)
   for i=0,hcoin-1 do begin
       yh=ycoinhal(i)
       ph=reform(pcoinhal(i,*))
       thh=reform(thcoinhal(i,*))
       o3h=reform(o3coinhal(i,*))
       for k=0L,nlevh-1L do begin
           for ibin=0L,nbin-2L do begin
               if thbins(ibin) le thh(k) and thbins(ibin+1L) gt thh(k) and $
                  o3h(k) gt 0. and o3h(k) ne 1.e24 then begin
                  pavehal(ibin)=pavehal(ibin)+ph(k)
                  thavehal(ibin)=thavehal(ibin)+thh(k)
                  o3avehal(ibin)=o3avehal(ibin)+o3h(k)
                  nbins(ibin)=nbins(ibin)+1L
                  goto,jumpout2
               endif
           endfor
           jumpout2:
       endfor
   endfor
   index=where(nbins gt 0L)
   pavehal(index)=pavehal(index)/float(nbins(index))
   thavehal(index)=thavehal(index)/float(nbins(index))
   o3avehal(index)=o3avehal(index)/float(nbins(index))
endif

if hscoin3 gt 0L then begin
   xcoinhirdls3=xcoinhirdls3(0:hscoin3-1L)
   ycoinhirdls3=ycoinhirdls3(0:hscoin3-1L)
   pcoinhirdls3=pcoinhirdls3(0:hscoin3-1L,0:hlev-1L)
   thcoinhirdls3=thcoinhirdls3(0:hscoin3-1L,0:hlev-1L)
   o3coinhirdls3=o3coinhirdls3(0:hscoin3-1L,0:hlev-1L)
   pavehirdls3=fltarr(nbin)
   thavehirdls3=fltarr(nbin)
   o3avehirdls3=fltarr(nbin)
   nbins=0L*lonarr(nbin)
   for i=0,hscoin3-1 do begin
       yh=ycoinhirdls3(i)
       ph=reform(pcoinhirdls3(i,*))
       thh=reform(thcoinhirdls3(i,*))
       o3h=reform(o3coinhirdls3(i,*))
       for k=0L,hlev-1L do begin
           for ibin=0L,nbin-2L do begin
               if thbins(ibin) le thh(k) and thbins(ibin+1L) gt thh(k) and $
                  o3h(k) gt 0. and o3h(k) ne 1.e24 then begin
                  pavehirdls3(ibin)=pavehirdls3(ibin)+ph(k)
                  thavehirdls3(ibin)=thavehirdls3(ibin)+thh(k)
                  o3avehirdls3(ibin)=o3avehirdls3(ibin)+o3h(k)
                  nbins(ibin)=nbins(ibin)+1L
                  goto,jumpout3
               endif
           endfor
           jumpout3:
       endfor
   endfor
   index=where(nbins gt 0L)
   pavehirdls3(index)=pavehirdls3(index)/float(nbins(index))
   thavehirdls3(index)=thavehirdls3(index)/float(nbins(index))
   o3avehirdls3(index)=o3avehirdls3(index)/float(nbins(index))

   xcoinsage3=xcoinsage3(0:scoin3-1L)
   ycoinsage3=ycoinsage3(0:scoin3-1L)
   pcoinsage3=pcoinsage3(0:scoin3-1L,0:nlevs3-1L)
   thcoinsage3=thcoinsage3(0:scoin3-1L,0:nlevs3-1L)
   o3coinsage3=o3coinsage3(0:scoin3-1L,0:nlevs3-1L)
   paves3=fltarr(nbin)
   thaves3=fltarr(nbin)
   o3aves3=fltarr(nbin)
   nbins=0L*lonarr(nbin)
   for i=0,scoin3-1 do begin
       yh=ycoinsage3(i)
       ph=reform(pcoinsage3(i,*))
       thh=reform(thcoinsage3(i,*))
       o3h=reform(o3coinsage3(i,*))
       for k=0L,nlevs3-1L do begin
           for ibin=0L,nbin-2L do begin
               if thbins(ibin) le thh(k) and thbins(ibin+1L) gt thh(k) and $
                  o3h(k) gt 0. and o3h(k) ne 1.e24 then begin
                  paves3(ibin)=paves3(ibin)+ph(k)
                  thaves3(ibin)=thaves3(ibin)+thh(k)
                  o3aves3(ibin)=o3aves3(ibin)+o3h(k)
                  nbins(ibin)=nbins(ibin)+1L
                  goto,jumpout4
               endif
           endfor
           jumpout4:
       endfor
   endfor
   index=where(nbins gt 0L)
   paves3(index)=paves3(index)/float(nbins(index))
   thaves3(index)=thaves3(index)/float(nbins(index))
   o3aves3(index)=o3aves3(index)/float(nbins(index))
endif

if hscoin2 gt 0L then begin
   xcoinhirdls2=xcoinhirdls2(0:hscoin2-1L)
   ycoinhirdls2=ycoinhirdls2(0:hscoin2-1L)
   pcoinhirdls2=pcoinhirdls2(0:hscoin2-1L,0:hlev-1L)
   thcoinhirdls2=thcoinhirdls2(0:hscoin2-1L,0:hlev-1L)
   o3coinhirdls2=o3coinhirdls2(0:hscoin2-1L,0:hlev-1L)
   pavehirdls2=fltarr(nbin)
   thavehirdls2=fltarr(nbin)
   o3avehirdls2=fltarr(nbin)
   nbins=0L*lonarr(nbin)
   for i=0,hscoin2-1 do begin
       yh=ycoinhirdls2(i)
       ph=reform(pcoinhirdls2(i,*))
       thh=reform(thcoinhirdls2(i,*))
       o3h=reform(o3coinhirdls2(i,*))
       for k=0L,hlev-1L do begin
           for ibin=0L,nbin-2L do begin
               if thbins(ibin) le thh(k) and thbins(ibin+1L) gt thh(k) and $
                  o3h(k) gt 0. and o3h(k) ne 1.e24 then begin
                  pavehirdls2(ibin)=pavehirdls2(ibin)+ph(k)
                  zavehirdls2(ibin)=zavehirdls2(ibin)+zh(k)
                  thavehirdls2(ibin)=thavehirdls2(ibin)+thh(k)
                  o3avehirdls2(ibin)=o3avehirdls2(ibin)+o3h(k)
                  nbins(ibin)=nbins(ibin)+1L
                  goto,jumpout5
               endif
           endfor
           jumpout5:
       endfor
   endfor
   index=where(nbins gt 0L)
   pavehirdls2(index)=pavehirdls2(index)/float(nbins(index))
   thavehirdls2(index)=thavehirdls2(index)/float(nbins(index))
   o3avehirdls2(index)=o3avehirdls2(index)/float(nbins(index))

   xcoinsage2=xcoinsage2(0:scoin2-1L)
   ycoinsage2=ycoinsage2(0:scoin2-1L)
   pcoinsage2=pcoinsage2(0:scoin2-1L,0:nlevs2-1L)
   thcoinsage2=thcoinsage2(0:scoin2-1L,0:nlevs2-1L)
   o3coinsage2=o3coinsage2(0:scoin2-1L,0:nlevs2-1L)
   paves2=fltarr(nbin)
   thaves2=fltarr(nbin)
   o3aves2=fltarr(nbin)
   nbins=0L*lonarr(nbin)
   for i=0,scoin2-1 do begin
       yh=ycoinsage2(i)
       thh=reform(thcoinsage2(i,*))
       o3h=reform(o3coinsage2(i,*))
       for k=0L,nlevs2-1L do begin
           for ibin=0L,nbin-2L do begin
               if thbins(ibin) le thh(k) and thbins(ibin+1L) gt thh(k) and $
                  o3h(k) gt 0. and o3h(k) ne 1.e24 then begin
                  paves2(ibin)=paves2(ibin)+ph(k)
                  thaves2(ibin)=thaves2(ibin)+thh(k)
                  o3aves2(ibin)=o3aves2(ibin)+o3h(k)
                  nbins(ibin)=nbins(ibin)+1L
                  goto,jumpout6
               endif
           endfor
           jumpout6:
       endfor
   endfor
   index=where(nbins gt 0L)
   paves2(index)=paves2(index)/float(nbins(index))
   thaves2(index)=thaves2(index)/float(nbins(index))
   o3aves2(index)=o3aves2(index)/float(nbins(index))
endif

if hpcoin3 gt 0L then begin
   xcoinhirdlsp3=xcoinhirdlsp3(0:hpcoin3-1L)
   ycoinhirdlsp3=ycoinhirdlsp3(0:hpcoin3-1L)
   pcoinhirdlsp3=pcoinhirdlsp3(0:hpcoin3-1L,0:hlev-1L)
   thcoinhirdlsp3=thcoinhirdlsp3(0:hpcoin3-1L,0:hlev-1L)
   o3coinhirdlsp3=o3coinhirdlsp3(0:hpcoin3-1L,0:hlev-1L)
   pavehirdlsp3=fltarr(nbin)
   thavehirdlsp3=fltarr(nbin)
   o3avehirdlsp3=fltarr(nbin)
   nbins=0L*lonarr(nbin)
   for i=0,hpcoin3-1 do begin
       yh=ycoinhirdlsp3(i)
       ph=reform(pcoinhirdlsp3(i,*))
       thh=reform(thcoinhirdlsp3(i,*))
       o3h=reform(o3coinhirdlsp3(i,*))
       for k=0L,hlev-1L do begin
           for ibin=0L,nbin-2L do begin
               if thbins(ibin) le thh(k) and thbins(ibin+1L) gt thh(k) and $
                  o3h(k) gt 0. and o3h(k) ne 1.e24 then begin
                  pavehirdlsp3(ibin)=pavehirdlsp3(ibin)+ph(k)
                  thavehirdlsp3(ibin)=thavehirdlsp3(ibin)+thh(k)
                  o3avehirdlsp3(ibin)=o3avehirdlsp3(ibin)+o3h(k)
                  nbins(ibin)=nbins(ibin)+1L
                  goto,jumpout7
               endif
           endfor
           jumpout7:
       endfor
   endfor
   index=where(nbins gt 0L)
   pavehirdlsp3(index)=pavehirdlsp3(index)/float(nbins(index))
   thavehirdlsp3(index)=thavehirdlsp3(index)/float(nbins(index))
   o3avehirdlsp3(index)=o3avehirdlsp3(index)/float(nbins(index))

   xcoinpoam3=xcoinpoam3(0:pcoin3-1L)
   ycoinpoam3=ycoinpoam3(0:pcoin3-1L)
   pcoinpoam3=pcoinpoam3(0:pcoin3-1L,0:nlevp3-1L)
   thcoinpoam3=thcoinpoam3(0:pcoin3-1L,0:nlevp3-1L)
   o3coinpoam3=o3coinpoam3(0:pcoin3-1L,0:nlevp3-1L)
   pavep3=fltarr(nbin)
   thavep3=fltarr(nbin)
   o3avep3=fltarr(nbin)
   nbins=0L*lonarr(nbin)
   for i=0,pcoin3-1 do begin
       yh=ycoinpoam3(i)
       ph=reform(pcoinpoam3(i,*))
       thh=reform(thcoinpoam3(i,*))
       o3h=reform(o3coinpoam3(i,*))
       for k=0L,nlevp3-1L do begin
           for ibin=0L,nbin-2L do begin
               if thbins(ibin) le thh(k) and thbins(ibin+1L) gt thh(k) and $
                  o3h(k) gt 0. and o3h(k) ne 1.e24 then begin
                  pavep3(ibin)=pavep3(ibin)+ph(k)
                  thavep3(ibin)=thavep3(ibin)+thh(k)
                  o3avep3(ibin)=o3avep3(ibin)+o3h(k)
                  nbins(ibin)=nbins(ibin)+1L
                  goto,jumpout8
               endif
           endfor
           jumpout8:
       endfor
   endfor
   index=where(nbins gt 0L)
   pavep3(index)=pavep3(index)/float(nbins(index))
   thavep3(index)=thavep3(index)/float(nbins(index))
   o3avep3(index)=o3avep3(index)/float(nbins(index))
endif
;
; check individual profiles
;
print,hcoin,scoin2,scoin3,pcoin3
print,hhcoin,hscoin2,hscoin3,hpcoin3
;set_viewport,.1,.45,.1,.9
;plot,findgen(10),findgen(10),/nodata,xrange=[0.,12.],$
;     yrange=[270.,2000.],title='NH',/noeras
;for i=0L,hcoin-1L do begin
;    if ycoinhal(i) gt 0. then begin
;    index=where(o3coinhal(i,*) gt 0. and o3coinhal(i,*) lt 1.)
;    o3prof=reform(o3coinhal(i,index))*1.e6
;    thprof=reform(thcoinhal(i,index))
;    oplot,o3prof,thprof,color=mcolor*.9
;    endif
;endfor
;for i=0L,scoin2-1L do begin
;    if ycoinsage3(i) gt 0. then begin
;    index=where(o3coinsage3(i,*) gt 0. and o3coinsage3(i,*) lt 1.)
;    o3prof=reform(o3coinsage3(i,index))*1.e6
;    thprof=reform(thcoinsage3(i,index))
;    oplot,o3prof,thprof
;    endif
;endfor
;set_viewport,.55,.9,.1,.9
;plot,findgen(10),findgen(10),/nodata,xrange=[0.,12.],$
;     yrange=[270.,2000.],title='SH',/noeras
;for i=0L,hcoin-1L do begin
;    if ycoinhal(i) lt 0. then begin
;    index=where(o3coinhal(i,*) gt 0. and o3coinhal(i,*) lt 1.)
;    o3prof=reform(o3coinhal(i,index))*1.e6
;    thprof=reform(thcoinhal(i,index))
;    oplot,o3prof,thprof,color=mcolor*.9
;    endif
;endfor
;for i=0L,scoin3-1L do begin
;    if ycoinsage3(i) lt 0. then begin
;    index=where(o3coinsage3(i,*) gt 0. and o3coinsage3(i,*) lt 1.)
;    o3prof=reform(o3coinsage3(i,index))*1.e6
;    thprof=reform(thcoinsage3(i,index))
;    oplot,o3prof,thprof
;    endif
;endfor
;stop
;
; percent differences in ozone
;
if hhcoin gt 0L then begin
index=where(o3avehal gt 0. and o3avehirdlshal gt 0.)
pavehal=pavehal(index)
thavehal=thavehal(index)
o3avehal=o3avehal(index)
pavehirdlshal=pavehirdlshal(index)
thavehirdlshal=thavehirdlshal(index)
o3avehirdlshal=o3avehirdlshal(index)
o3diffhal=100.*(o3avehal-o3avehirdlshal)/o3avehirdlshal
thhal=(thavehal+thavehirdlshal)/2.0
print,'HALOE ',min(o3diffhal),max(o3diffhal)
endif

if hscoin3 gt 0L then begin
index=where(o3aves3 gt 0. and o3avehirdls3 gt 0.)
paves3=paves3(index)
thaves3=thaves3(index)
o3aves3=o3aves3(index)
pavehirdls3=pavehirdls3(index)
thavehirdls3=thavehirdls3(index)
o3avehirdls3=o3avehirdls3(index)
o3diffs3=100.*(o3aves3-o3avehirdls3)/o3avehirdls3
thsage3=(thaves3+thavehirdls3)/2.0
print,'SAGE III ',min(o3diffs3),max(o3diffs3)
endif

if hscoin2 gt 0L then begin
index=where(o3aves2 gt 0. and o3avehirdls2 gt 0.)
paves2=paves2(index)
thaves2=thaves2(index)
o3aves2=o3aves2(index)
pavehirdls2=pavehirdls2(index)
thavehirdls2=thavehirdls2(index)
o3avehirdls2=o3avehirdls2(index)
o3diffs2=100.*(o3aves2-o3avehirdls2)/o3avehirdls2
thsage2=(thaves2+thavehirdls2)/2.0
print,'SAGE II ',min(o3diffs2),max(o3diffs2)
endif

if hpcoin3 gt 0L then begin
index=where(o3avep3 gt 0. and o3avehirdlsp3 gt 0.)
pavep3=pavep3(index)
thavep3=thavep3(index)
o3avep3=o3avep3(index)
pavehirdlsp3=pavehirdlsp3(index)
thavehirdlsp3=thavehirdlsp3(index)
o3avehirdlsp3=o3avehirdlsp3(index)
o3diffp3=100.*(o3avep3-o3avehirdlsp3)/o3avehirdlsp3
thpoam3=(thavep3+thavehirdlsp3)/2.0
print,'POAM III ',min(o3diffp3),max(o3diffp3)
endif

daterange=strcompress(string(FORMAT='(A3,A1,I2,A2,I4,A3,A3,A1,I2,A2,I4,A3)',$
 month(lstmn-1),' ',lstdy,', ',lstyr,' - ',month(ledmn-1),' ',leddy,', ',ledyr))
datelab=strcompress(string(FORMAT='(I4,I2.2,I2.2,A1,I4,I2.2,I2.2)',$
 lstyr,lstmn,lstdy,'-',ledyr,ledmn,leddy))

if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,$
           filename='hirdls_haloe_sage_coin_'+datelab+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
           xsize=xsize,ysize=ysize
endif

; Set plot boundaries
erase
!type=2^2+2^3
xyouts,.2,.92,daterange,/normal,charsize=3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
thmin=min(thbins)
thmax=max(thbins)
plot,[-100.,100.],[thmin,thmax],yrange=[thmin,thmax],/nodata,$
      xrange=[-100.,100.],charsize=1.2,ytitle='Theta (K)',$
      xtitle='Ozone Percent Difference',title='100*(HALOE-HIRDLS)/HIRDLS'
plots,0,thmin
plots,0,thmax,/continue,linestyle=5
plots,10,thmin
plots,10,thmax,/continue,linestyle=3
plots,-10,thmin
plots,-10,thmax,/continue,linestyle=3
if hhcoin gt 0L then oplot,o3diffhal,thhal,thick=3
snhal=strtrim(hcoin,2)
snhir=strtrim(hhcoin,2)
xyouts,30.,2000.,'HIRDLS ('+snhir+')',/data,charsize=1.2
xyouts,30.,1800.,'HALOE ('+snhal+')',/data,charsize=1.2

xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,[-100.,100.],[thmin,thmax],yrange=[thmin,thmax],/nodata,$
      xrange=[-100.,100.],charsize=1.2,ytitle='Theta (K)',$
      xtitle='Ozone Percent Difference',title='100*(SAGE III-HIRDLS)/HIRDLS'
plots,0,thmin
plots,0,thmax,/continue,linestyle=5
plots,10,thmin
plots,10,thmax,/continue,linestyle=3
plots,-10,thmin
plots,-10,thmax,/continue,linestyle=3
if hscoin3 gt 0L then oplot,o3diffs3,thsage3,thick=3
snsage3=strtrim(scoin3,2)
snhir=strtrim(hscoin3,2)
xyouts,30.,2000.,'HIRDLS ('+snhir+')',/data,charsize=1.2
xyouts,30.,1800.,'SAGE III ('+snsage3+')',/data,charsize=1.2

xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,[-100.,100.],[thmin,thmax],yrange=[thmin,thmax],/nodata,$
      xrange=[-100.,100.],charsize=1.2,ytitle='Theta (K)',$
      xtitle='Ozone Percent Difference',title='100*(SAGE II-HIRDLS)/HIRDLS'
plots,0,thmin
plots,0,thmax,/continue,linestyle=5
plots,10,thmin
plots,10,thmax,/continue,linestyle=3
plots,-10,thmin
plots,-10,thmax,/continue,linestyle=3
if hscoin2 gt 0L then oplot,o3diffs2,thsage2,thick=3
snsage2=strtrim(scoin2,2)
snhir=strtrim(hscoin2,2)
xyouts,30.,2000.,'HIRDLS ('+snhir+')',/data,charsize=1.2
xyouts,30.,1800.,'SAGE III ('+snsage2+')',/data,charsize=1.2

xmn=xorig(3)
xmx=xorig(3)+xlen
ymn=yorig(3)
ymx=yorig(3)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,[-100.,100.],[thmin,thmax],yrange=[thmin,thmax],/nodata,$
      xrange=[-100.,100.],charsize=1.2,ytitle='Theta (K)',$
      xtitle='Ozone Percent Difference',title='100*(POAM III-HIRDLS)/HIRDLS'
plots,0,thmin
plots,0,thmax,/continue,linestyle=5
plots,10,thmin
plots,10,thmax,/continue,linestyle=3
plots,-10,thmin
plots,-10,thmax,/continue,linestyle=3
if hpcoin3 gt 0L then oplot,o3diffp3,thpoam3,thick=3
snpoam3=strtrim(pcoin3,2)
snhir=strtrim(hpcoin3,2)
xyouts,30.,2000.,'HIRDLS ('+snhir+')',/data,charsize=1.2
xyouts,30.,1800.,'POAM III ('+snpoam3+')',/data,charsize=1.2

if setplot eq 'ps' then begin
   device, /close
   spawn,'convert hirdls_haloe_sage_coin_'+datelab+$
         '.ps -rotate -90 hirdls_haloe_sage_coin_'+datelab+'.jpg'
endif
end
