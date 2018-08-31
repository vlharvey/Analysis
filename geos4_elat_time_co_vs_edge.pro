;
; enter altitude and plot MLS CO and GEOS-4 Arctic vortex in time-latitude
; read GEOS-4 based MLS DMPs
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto

sver='v2.2'
;sver='v1.52'

loadct,38
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=[.15]
yorig=[.25]
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
nlat=35L
elatbin=-85+5.*findgen(nlat)

!noeras=1
dirm='/aura6/data/MLS_data/Datfiles_SOSST/'
idir='/aura6/data/GEOS4_data/Analysis/'
dir='/aura7/harvey/GEOS4_data/Datfiles/DAS.flk.asm.tavg3d_mis_e.GEOS403.MetO.'
lstmn=1L & lstdy=1L & lstyr=2006L
ledmn=10L & leddy=28L & ledyr=2006L
lstday=0L & ledday=0L
;
; get date range
;
print, ' '
print, '      GEOS-4 Version '
print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 2000 then lstyr=lstyr+2000
if ledyr lt 2000 then ledyr=ledyr+2000
if lstyr lt 2004 then stop,'Year out of range '
if ledyr lt 2004 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
nday=ledday-lstday+1L

sdateyt=strarr(nday)
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
      icount=icount+1L
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
      sdateyt(icount-1)=sdate
      rd_geos5_nc3_meto,dir+sdate+'_1200.V01.nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag
      if iflag eq 1 then goto,jump
      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=alon(0)+360.
;
; select theta level to plot
;
      if icount eq 1 then begin
         rlev=2000.
;        print,th
;        read,' Enter desired theta surface ',rlev
         zindex=where(th eq rlev)
         ilev=zindex(0)
         slev=strcompress(th(ilev),/remove_all)+'K'
         sdate0=sdate
         coyt=fltarr(nday,nlat,nth)
         markyt=fltarr(nday,nlat,nth)
      endif
;
; read MLS data
;
      dum=findfile(dirm+'cat_mls_'+sver+'_'+sdate+'.sav')
      if dum(0) eq '' then goto,jump
      restore,dirm+'cat_mls_'+sver+'_'+sdate+'.sav'             ; altitude
      restore,dirm+'tpd_mls_'+sver+'_'+sdate+'.sav'             ; temperature, pressure
      restore,dirm+'co_mls_'+sver+'_'+sdate+'.sav'              ; mix
      restore,dirm+'dmps_mls_'+sver+'.geos4.'+sdate+'.sav'       ; elat_prof

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
      melat=elat_prof
      mtemp=temperature
      mpress=pressure
;
; eliminate bad uttimes and SH
;
      index=where(muttime gt 0. and mlat gt 0.)
      if index(0) eq -1L then goto,jump
      muttime=reform(muttime(index))
      mlat=reform(mlat(index))
      mlon=reform(mlon(index))
      mtemp=reform(mtemp(index,*))
      mpress=reform(mpress(index,*))
      mco=reform(mco(index,*))
      melat=reform(melat(index,*))
      mtheta=mtemp*(1000./mpress)^0.286
      index=where(mtemp lt 0.)
      if index(0) ne -1L then mtheta(index)=-99.
;
; loop over theta
;
      for kk=0L,nth-1L do begin
          rlev=th(kk)
          zindex=where(th eq rlev)
          ilev=zindex(0)

          mark1=transpose(mark2(*,*,ilev))
          pv1=transpose(pv2(*,*,ilev))
          elat1=calcelat2d(pv1,alon,alat)
          u1=transpose(u2(*,*,ilev))

          index=where(rlev eq thlev)
          if index(0) eq -1L then goto,jumplev		; for levels above 2000 K
          klev=index(0)
          elatdata=reform(melat(*,klev))    		; melat is already on theta
          elatdata2d=0.*mco				; build 2d elat to match 2d mco
          for k=0L,nz-1L do elatdata2d(*,k)=elatdata
;
; extract MLS CO near rlev
;
          kindex=where(abs(mtheta-rlev) le 50. and mco ne -99.,mprof)
          if kindex(0) eq -1L then goto,jump
          codata=mco(kindex)*1.e6
          elatdata=elatdata2d(kindex)
;
; bin max marker and CO in elat
;
          for j=0L,nlat-2L do begin
              e0=elatbin(j) & e1=elatbin(j+1)
              index=where(elat1 ge e0 and elat1 lt e1)
              if index(0) ne -1L then markyt(icount-1,j,kk)=max(mark1(index))
              index=where(elatdata ge e0 and elatdata lt e1,npt)
              if index(0) ne -1L then coyt(icount-1,j,kk)=max(codata(index))
          endfor
jumplev:
      endfor	; loop over theta

goto,jump
plotit:
sdate1=sdate
save,file='geos4_elat_time_co_vs_edge_'+sdate0+'-'+sdate1+'_nh.sav',markyt,coyt,sdateyt,elatbin,th
markyt3d=markyt
coyt3d=coyt
;
; loop over theta
;
for kk=0L,nth-1L do begin
    rlev=th(kk)
    zindex=where(th eq rlev)
    ilev=zindex(0)
    slev=strcompress(th(ilev),/remove_all)+'K'
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
       device,/landscape,bits=8,filename='elat_time_co_vs_edge_'+sdate0+'-'+sdate1+'_'+slev+'.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
    endif
;
; polar plot
;
    erase
    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    level=0.2*findgen(21)
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*icolmax/nlvls
    xindex=where(strmid(sdateyt,6,2) eq '15')
    xlabs=strmid(sdateyt(xindex),4,2)
    syr1=strmid(sdateyt(0),0,4)
    syr2=strmid(sdateyt(nday-1),0,4)
    coyt=reform(coyt3d(*,*,kk))
    markyt=reform(markyt3d(*,*,kk))
    contour,coyt,findgen(nday),elatbin,color=0,/noeras,charsize=1.5,title='MLS CO + GEOS-4 Vortex '+slev,$
              /fill,c_color=col1,levels=level,yrange=[0.,90.],ytitle='Equivalent Latitude',xtickname=xlabs,$
              xtickv=xindex,xticks=n_elements(xindex)-1,charthick=2
    markyt=smooth(markyt,3)
    contour,markyt,findgen(nday),elatbin,/overplot,levels=[0.5],color=0,thick=4,/noeras,/follow,c_labels=[0]
    xyouts,xmn,ymn-0.07,syr1,charsize=2,charthick=2,color=0,/normal
    xyouts,xmx-0.1,ymn-0.07,syr2,charsize=2,charthick=2,color=0,/normal
    set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    omin=min(level)
    omax=max(level)
    plot,[omin,omax],[0,0],yrange=[0,10],$
          xrange=[omin,omax],xtitle='Carbon Monoxide (ppmv)',/noeras,$
          xtickname=strcompress(string(format='(f4.1)',level),/remove_all),$
          xstyle=1,charsize=1.5,color=0,charthick=2,xticks=nlvls-1
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
       spawn,'convert -trim elat_time_co_vs_edge_'+sdate0+'-'+sdate1+'_'+slev+'.ps -rotate -90 '+$
                           'elat_time_co_vs_edge_'+sdate0+'-'+sdate1+'_'+slev+'.jpg'
    endif
endfor
end
