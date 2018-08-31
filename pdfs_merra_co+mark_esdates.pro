;
; when and where are CO distributions bimodal during the ES composite?
; contour CO and the vortex edge as a function of latitude and time
; +/- 30 days around all ES events
;
@stddat
@kgmt
@ckday
@kdate

sver='v3.3'
loadct,39
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=1000
nydim=700
xorig=[.1,0.1,0.55,0.55]
yorig=[.25,.1,.55,.1]
xlen=0.8
ylen=0.6
cbaryoff=0.1
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
!noeras=1
dirm='/Volumes/earth/aura6/data/MLS_data/Datfiles_SOSST/'
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'
mlsesdates=['20060130','20090205','20120130','20130123']
;sabesdates=['20060128','20090205','20120128','20130123']

nevent=n_elements(mlsesdates)
for ievent=0,nevent-1L do begin
    esdate0=mlsesdates(ievent)
    iyr=long(strmid(esdate0,0,4))
    imn=long(strmid(esdate0,4,2))
    idy=long(strmid(esdate0,6,2))
    jday = JULDAY(imn,idy,iyr)
    jday0=jday-30
    jday1=jday+30
    CALDAT, jday0, lstmn ,lstdy , lstyr
    CALDAT, jday1, ledmn ,leddy , ledyr
    lstday=0L & ledday=0L
    if lstyr eq ledyr then yearlab=strcompress(lstyr,/remove_all)
    if lstyr ne ledyr then yearlab=strcompress(lstyr,/remove_all)+'-'+strcompress(ledyr,/remove_all)
;goto,quick
;
    z = stddat(lstmn,lstdy,lstyr,lstday)
    z = stddat(ledmn,leddy,ledyr,ledday)
    if ledday lt lstday then stop,' Wrong dates! '
    kday=long(ledday-lstday+1L)
;
; Compute initial Julian date
;
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
; --- Test for end condition
;
          z = stddat(imn,idy,iyr,ndays)
          if ndays lt lstday then stop,' starting day outside range '
          if ndays gt ledday then goto,plotit
;
; construct date string
;
          syr=strcompress(iyr,/remove_all)
          smn=string(FORMAT='(i2.2)',imn)
          sdy=string(FORMAT='(i2.2)',idy)
          sdate=syr+smn+sdy
;
; read MLS data
;
          dum=findfile(dirm+'cat_mls_'+sver+'_'+sdate+'.sav')
          if dum(0) eq '' then goto,skipit
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
          if good(0) eq -1L then goto,skipit
          mco=mix
          restore,dirm+'h2o_mls_'+sver+'_'+sdate+'.sav'              ; water vapor mix
          bad=where(mask eq -99.)
          if bad(0) ne -1L then mix(bad)=-99.
          good=where(mix ne -99.)
          if good(0) eq -1L then goto,skipit
          mh2o=mix
          mtemp=temperature
          mpress=pressure
;
; eliminate bad uttimes and SH
;
          index=where(muttime gt 0.)
          if index(0) eq -1L then goto,skipit
          muttime=reform(muttime(index))
          mlat=reform(mlat(index))
          mlon=reform(mlon(index))
          mtemp=reform(mtemp(index,*))
          mpress=reform(mpress(index,*))
          mco=reform(mco(index,*))
          mh2o=reform(mh2o(index,*))
          mtheta=mtemp*(1000./mpress)^0.286
          index=where(mtemp lt 0.)
          if index(0) ne -1L then mtheta(index)=-99.
;
; construct 2d MLS latitude
;
          mlat2=0.*mco
          for i=0L,mlev-1L do mlat2(*,i)=mlat
;
; declare arrays on first day of event
;
          if icount eq 0 then begin
             sdate_all=strarr(kday)
             co2d_pdf=fltarr(kday,14)
             h2o2d_pdf=fltarr(kday,14)
          endif
          sdate_all(icount)=sdate
;
; 4000 K where the vortex is difficult to identify due to multiple jets and uncertain data
;
          for kk=0,0 do begin	;nth2-1L do begin
              rlev=4000.
              slev=strcompress(long(rlev),/remove_all)+'K'
              print,slev,' ',sdate,icount-30
              kindex=where(mlat2 ge 0. and abs(mtheta-rlev) le 50. and mco ne -99. and mh2o ne -99.,mprof)
              if kindex(0) eq -1L then goto,skipit
              codata=mco(kindex)*1.e6
              h2odata=mh2o(kindex)*1.e6
              ydata=mlat2(kindex)
;
;             if icount eq 0L then begin
;                erase
;                index=where(ydata ge 60.)
;                y60=histogram(codata(index),min=-1,max=12.,binsize=1)
;                y60=float(y60)/max(float(y60))
;                plot,y60,color=(float(icount)/61.)*mcolor,thick=5,title=sdate+' Day '+strcompress(icount-30)+'  Theta='+slev,yrange=[0,1.]
;             endif

              y2=histogram(codata,min=-1,max=12.,binsize=1)
              index=where(ydata ge 60.)
              y60=histogram(codata(index),min=-1,max=12.,binsize=1)
              y60=float(y60)/max(float(y60))
              co2d_pdf(icount,*)=y60

              y60=histogram(h2odata(index),min=-1,max=12.,binsize=1)
              y60=float(y60)/max(float(y60))
              h2o2d_pdf(icount,*)=y60
;             if icount mod 5 eq 0L then oplot,y60,color=(float(icount)/61.)*mcolor,thick=5
          endfor		; loop over altitude
     skipit:
     icount=icount+1L
     goto,jump

     plotit:
     syear=strmid(sdate_all,0,4)
     smon=strmid(sdate_all,4,2)
     sday=strmid(sdate_all,6,2)
     xindex=where(sday eq '01' or sday eq '15',nxticks)
     xlabs=smon(xindex)+'/'+sday(xindex)
     good=where(long(syear) ne 0L)
     minyear=long(min(long(syear(good))))
     maxyear=long(max(long(syear)))
     yearlab=strcompress(maxyear,/remove_all)
     if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
     x=-1+findgen(14)
     save,file='pdfs_merra_co+mark_'+yearlab+'.sav',kday,sdate_all,co2d_pdf,h2o2d_pdf,x,rlev

     quick:
     restore,'pdfs_merra_co+mark_'+yearlab+'.sav'
     syear=strmid(sdate_all,0,4)
     smon=strmid(sdate_all,4,2)
     sday=strmid(sdate_all,6,2)
     xindex=where(sday eq '01' or sday eq '15',nxticks)
     xlabs=smon(xindex)+'/'+sday(xindex)
     good=where(long(syear) ne 0L)
     minyear=long(min(long(syear(good))))
     maxyear=long(max(long(syear)))
     yearlab=strcompress(maxyear,/remove_all)
     if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
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
         device,/landscape,bits=8,filename='pdfs_merra_co+mark_'+yearlab+'_'+slev+'.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
         !p.thick=2.0                   ;Plotted lines twice as thick
         !p.charsize=2.0
      endif

      erase
      !type=2^2+2^3
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      cbartitle=slev+' MLS CO PDF'
      nlvls=20
      col1=1+indgen(nlvls)*mcolor/nlvls
      x=-1+findgen(14)
      level=.05+0.05*findgen(20)
      contour,co2d_pdf,-30.+findgen(kday),x,levels=.05+0.05*findgen(20),/fill,c_color=col1,xtitle='Days From ES Onset',ytitle='Frequency',color=0,/noeras,charsize=2,charthick=2
;     contour,h2o2d_pdf,-30.+findgen(kday),x,levels=.05+0.05*findgen(20),/follow,/overplot,color=0

      omin=min(level)
      omax=max(level)
      set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
      !type=2^2+2^3+2^6
      plot,[omin,omax],[0,0],yrange=[0,10],charsize=2,charthick=2,$
            xrange=[omin,omax],xtitle=cbartitle,/noeras,xstyle=1,color=0
      ybox=[0,10,10,0,0]
      x1=omin
      dx=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor
      if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device,/close
         spawn,'convert -trim pdfs_merra_co+mark_'+yearlab+'_'+slev+'.ps -rotate -90 '+$
               'pdfs_merra_co+mark_'+yearlab+'_'+slev+'.jpg'
      endif
endfor	; loop over ES event
end
