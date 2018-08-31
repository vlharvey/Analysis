;
; 2d PDFs (choose altitude, then contour PDF in time vs ppmv)
; v1.5 MLS
; enter altitude and plot MLS CO and GEOS-5 Arctic vortex
; plot PV and isotachs.  4 panel
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto

sver='v1.52'
;sver='v2.2'

loadct,38
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=0.025+[.1,.4,.7]
yorig=[.15,.15,.15]
xlen=0.25
ylen=0.75
cbaryoff=0.075
cbarydel=0.01
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
mon=['jan','feb','mar','apr','may','jun',$
     'jul','aug','sep','oct','nov','dec']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
stimes=[$
;'_0000.V01.',$
;'_0600.V01.',$
;'_1200.V01.',$
'_AVG.V01.']
slabs=['00Z','06Z','12Z','18Z']
slabs=['AVG']
ntimes=n_elements(stimes)
!noeras=1
dirm='/aura6/data/MLS_data/Datfiles_SOSST/'
dir='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'
lstmn=10L & lstdy=20L & lstyr=2004L
ledmn=11L & leddy=20L & ledyr=2004L
;ledmn=4L & leddy=1L & ledyr=2005L
lstday=0L & ledday=0L
;
; get date range
;
print, ' '
print, '      GEOS-5 Version '
print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 2000 then lstyr=lstyr+2000
if ledyr lt 2000 then ledyr=ledyr+2000
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=(ledday-lstday+1L)*4L
kday=ledday-lstday+1L
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
kcount=-1L
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; construct date string
;
      syr=strcompress(iyr,/remove_all)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      sdate=syr+smn+sdy
      print,sdate
;
; --- Test for end condition
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,plotit
;
; read MLS data
;
      dum=findfile(dirm+'cat_mls_'+sver+'_'+sdate+'.sav')
      kcount=kcount+1L
      if dum(0) eq '' then goto,jump
      restore,dirm+'cat_mls_'+sver+'_'+sdate+'.sav'             ; altitude
      restore,dirm+'tpd_mls_'+sver+'_'+sdate+'.sav'             ; temperature, pressure
      restore,dirm+'co_mls_'+sver+'_'+sdate+'.sav'              ; mix
      nz=n_elements(altitude)
      nthlev=n_elements(thlev)
      mprof=n_elements(longitude)
      mlev=n_elements(altitude)
      muttime=time
      mlat=latitude
      mlon=longitude
      bad=where(mask eq -99.)
      if bad(0) ne -1L then mix(bad)=-99.
      good=where(mix ne -99.)
      if good(0) eq -1L then goto,jump
      mco=mix
      restore,dirm+'h2o_mls_'+sver+'_'+sdate+'.sav'              ; water vapor mix
      bad=where(mask eq -99.)
      if bad(0) ne -1L then mix(bad)=-99.
      good=where(mix ne -99.)
      if good(0) eq -1L then goto,jump
      mh2o=mix
      restore,dirm+'n2o_mls_'+sver+'_'+sdate+'.sav'              ; N2O mix
      bad=where(mask eq -99.)
      if bad(0) ne -1L then mix(bad)=-99.
      good=where(mix ne -99.)
      if good(0) eq -1L then goto,jump
      mn2o=mix
      mtemp=temperature
      mpress=pressure
;
; eliminate bad uttimes and SH
;
      index=where(muttime gt 0. and mlat gt 30.)
      if index(0) eq -1L then goto,jump
      muttime=reform(muttime(index))
      mlat=reform(mlat(index))
      mlon=reform(mlon(index))
      mtemp=reform(mtemp(index,*))
      mpress=reform(mpress(index,*))
      mco=reform(mco(index,*))
      mh2o=reform(mh2o(index,*))
      mn2o=reform(mn2o(index,*))
      mtheta=mtemp*(1000./mpress)^0.286
      index=where(mtemp lt 0.)
      if index(0) ne -1L then mtheta(index)=-99.
;
; construct 2d MLS arrays to match CO
;
      mpress2=mpress
      mtime2=0.*mco
      mlat2=0.*mco
      mlon2=0.*mco
      for i=0L,mlev-1L do begin
          mtime2(*,i)=muttime
          mlat2(*,i)=mlat
          mlon2(*,i)=mlon
      endfor
;
; read GEOS-5 data once to get theta levels
;
      if icount eq 0L then begin
         rd_geos5_nc3_meto,dir+sdate+stimes(0)+'nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag
         if iflag eq 1 then goto,jump
;
; time vs mix vs altitude PDF arrays
;
         xbins=-1.+.25*findgen(37)
         nbins=n_elements(xbins)
         copdf3d=fltarr(nbins,kday,nth)
         h2opdf3d=fltarr(nbins,kday,nth)
         n2opdf3d=fltarr(nbins,kday,nth)
         date_all=strarr(kday)
         syr0=syr
      endif
      date_all(icount)=sdate
;
; 2d daily PDFs
;
      copdf2d=fltarr(nbins,nth)
      h2opdf2d=fltarr(nbins,nth)
      n2opdf2d=fltarr(nbins,nth)
      for k=0L,nth-1L do begin
          rlev=th(k)
          kindex=where(abs(mtheta-rlev) le 50. and mco ne -99.)
          if kindex(0) ne -1L then begin
             codata2d=mco(kindex)*1.e6
             y2=histogram(codata2d,min=-1,max=8.,binsize=.25)/float(n_elements(codata2d))
             copdf2d(*,k)=y2
          endif
          kindex=where(abs(mtheta-rlev) le 50. and mh2o ne -99.)
          if kindex(0) ne -1L then begin
             h2odata2d=mh2o(kindex)*1.e6
             y2=histogram(h2odata2d,min=-1,max=8.,binsize=.25)/float(n_elements(h2odata2d))
             h2opdf2d(*,k)=y2
          endif
          kindex=where(abs(mtheta-rlev) le 50. and mn2o ne -99.)
          if kindex(0) ne -1L then begin
             n2odata2d=mn2o(kindex)*1.e7
             y2=histogram(n2odata2d,min=-1,max=8.,binsize=.25)/float(n_elements(n2odata2d))
             n2opdf2d(*,k)=y2
          endif
;
; save in 3d arrays
;
          copdf3d(*,icount,k)=copdf2d(*,k)
          h2opdf3d(*,icount,k)=h2opdf2d(*,k)
          n2opdf3d(*,icount,k)=n2opdf2d(*,k)
      endfor    ; loop over theta levels
      icount=icount+1L
goto,jump

plotit:
syr1=syr
yrlab=syr0+'-'+syr1
save,file='mls_co+h2o+n2o_3dpdfs_'+yrlab+'.sav,copdf3d,h2opdf3d,n2opdf3d,th,kday,date_all,xbins
;
; loop over theta levels
;
for k=0L,nth-1L do begin
    copdf2d_time=reform(copdf3d(*,*,k))
    h2opdf2d_time=reform(h2opdf3d(*,*,k))
    n2opdf2d_time=reform(n2opdf3d(*,*,k))
    rlev=th(k)
    slev=strcompress(long(rlev),/remove_all)+'K'
;
; save postscript version
;
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='mls_co+h2o+n2o_pdfs_mix_vs_time_'+slev+'_'+yrlab+'_'+sver+'.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif
    !p.thick=2.0                   ;Plotted lines twice as thick
;
; date labels
;
    sdays=strcompress(strmid(date_all,6,2),/remove_all)
    smons=strcompress(strmid(date_all,4,2),/remove_all)
    syrs=strcompress(strmid(date_all,0,4),/remove_all)
    xindex=where(sdays eq '01' or sdays eq '10' or sdays eq '20',nxtick)
    xlabs1=sdays(xindex)
    xlabs0=smons(xindex)
    xlabs=xlabs0+'/'+xlabs1
;   xlabs=date_all(xindex)
;
; CO PDF time vs mix
;
    erase
    !type=2^2+2^3
    xyouts,.45,.95,yrlab+'  '+slev,/normal,color=0,charsize=2,charthick=2
    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    level=[0.001,0.005,0.01,0.015,0.02,0.025,0.03,0.035,0.04,0.045,0.05,0.06,0.075,0.1,0.25,.5,.75,1.0]
    slevel=['0.001','0.005','0.01','0.015','0.02','0.025','0.03','0.035','0.04','0.045','0.05','0.06',$
            '0.075','0.1','0.25','.5','.75','1.0']
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*mcolor/nlvls
    contour,copdf2d_time,xbins,findgen(kday),levels=level,title='CO PDF',/noerase,/fill,c_color=col1,$
            xtitle='CO (ppmv)',color=0,ytickv=xindex,yticks=nxtick,ytickname=' '+strarr(nxtick+1),xrange=[min(xbins),max(xbins)]
;   contour,copdf2d_time,xbins,findgen(kday),levels=level,/overplot,/follow,color=0,c_labels=0*level
    for ii=0L,n_elements(xindex)-1L do xyouts,-3.,xindex(ii),xlabs(ii),alignment=0.0,color=0,/data
;
; H2O PDF time vs mix
;
    !type=2^2+2^3
    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    contour,h2opdf2d_time,xbins,findgen(kday),levels=level,title='H2O PDF',/noerase,/fill,c_color=col1,$
            xtitle='H2O (ppmv)',color=0,ytickv=xindex,yticks=nxtick,ytickname=' '+strarr(nxtick+1),xrange=[min(xbins),max(xbins)]
;   contour,h2opdf2d_time,xbins,findgen(kday),levels=level,/overplot,/follow,color=0,c_labels=0*level
;
; N2O PDF time vs mix
;
    !type=2^2+2^3
    xmn=xorig(2)
    xmx=xorig(2)+xlen
    ymn=yorig(2)
    ymx=yorig(2)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    contour,n2opdf2d_time,xbins,findgen(kday),levels=level,title='N2O PDF',/noerase,/fill,c_color=col1,$
            xtitle='N2O x 10 (ppmv)',color=0,ytickv=xindex,yticks=nxtick,ytickname=' '+strarr(nxtick+1),xrange=[min(xbins),max(xbins)]
;   contour,n2opdf2d_time,xbins,findgen(kday),levels=level,/overplot,/follow,color=0,c_labels=0*level

    set_viewport,min(xorig),max(xorig)+xlen,ymn-cbaryoff,ymn-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    omin=min(level)
    omax=max(level)
    plot,[omin,omax],[0,0],yrange=[0,10],xrange=[omin,omax],xtitle='Frequency',$
          xticks=nlvls-1,xtickname=slevel,/noeras,xstyle=1,color=0
    ybox=[0,10,10,0,0]
    x1=omin
    dx=(omax-omin)/nlvls
    for j=0,nlvls-1 do begin
      xbox=[x1,x1,x1+dx,x1+dx,x1]
      polyfill,xbox,ybox,color=col1(j)
      x1=x1+dx
    endfor

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert -trim mls_co+h2o+n2o_pdfs_mix_vs_time_'+slev+'_'+yrlab+'_'+sver+'.ps -rotate -90 '+$
             'mls_co+h2o+n2o_pdfs_mix_vs_time_'+slev+'_'+yrlab+'_'+sver+'.jpg'
    endif
endfor
end
