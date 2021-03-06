;
; compute the standard deviation of latitude within SF and PV bins
;
@stddat
@kgmt
@ckday
@kdate

loadct,38
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=[0.3]
yorig=[0.2]
xlen=0.4
ylen=0.6
cbaryoff=0.06
cbarydel=0.01
;set_plot,'ps'
;setplot='ps'
;read,'setplot= ',setplot
;if setplot ne 'ps' then begin
;   set_plot,'x'
;   !p.background=mcolor
;   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
;endif
re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
nrr=91L
yeq=findgen(nrr)
latcircle=fltarr(nrr)
hem_frac=fltarr(nrr)
for j=0,nrr-2 do begin
    hy=re*dtr
    dx=re*cos(yeq(j)*dtr)*360.*dtr
    latcircle(j)=dx*hy
endfor
for j=0,nrr-1 do begin
    if yeq(j) ge 0. then index=where(yeq ge yeq(j))
    if index(0) ne -1 then hem_frac(j)=100.*total(latcircle(index))/hem_area
    if yeq(j) eq 0. then hem_frac(j)=100.
endfor
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
mon=['jan','feb','mar','apr','may','jun',$
     'jul','aug','sep','oct','nov','dec']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
stimes=[$
'_AVG.V01.']
slabs=['AVG']
ntimes=n_elements(stimes)
!noeras=1
dirm='/aura6/data/MLS_data/Datfiles_SOSST/'
dir='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'
dir2='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS520.MetO.'
lstmn=10L & lstdy=1L & lstyr=2003L
ledmn=9L & leddy=30L & ledyr=2008L
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
kcount=0L
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
      if ndays gt ledday then goto,saveit
;
; construct date string
;
      syr=strcompress(iyr,/remove_all)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      sdate=syr+smn+sdy
      if kcount eq 0L then sdates=strarr(kday)
      sdates(kcount)=sdate
      kcount=kcount+1L
;     if smn eq '04' or smn eq '05' or smn eq '06' or $
;        smn eq '07' or smn eq '08' or smn eq '09' then goto,jump
;
; read GEOS-5 data
;
      file1=dir+sdate+stimes(0)+'nc3'
      dum1=findfile(file1)
      if dum1(0) eq '' then begin
         file1=dir2+sdate+stimes(0)+'nc3'
         dum1=findfile(file1)
         if dum1(0) eq '' then goto,jump
      endif
      ncid=ncdf_open(file1)
      print,'opening ',file1
      if icount eq 0L then begin
         ncdf_diminq,ncid,0,name,nr
         ncdf_diminq,ncid,1,name,nc
         ncdf_diminq,ncid,2,name,nth
         alon=fltarr(nc)
         alat=fltarr(nr)
         th=fltarr(nth)
         pv2=fltarr(nr,nc,nth)
         sf2=fltarr(nr,nc,nth)
         ncdf_varget,ncid,0,alon
         ncdf_varget,ncid,1,alat
         ncdf_varget,ncid,2,th
      endif
      index=where(th ge 450,nth)
      ncdf_varget,ncid,3,pv2
      ncdf_varget,ncid,12,sf2
      ncdf_close,ncid
      th=reform(th(index))
      pv2=reform(pv2(*,*,index))
      sf2=reform(sf2(*,*,index))
;
; on first day
;
      if icount eq 0L then begin
         x2d=fltarr(nc,nr)
         y2d=fltarr(nc,nr)
         for i=0,nr-1 do x2d(*,i)=alon
         for i=0,nc-1 do y2d(i,*)=alat
         lat=y2d
         area=0.*y2d
         deltax=alon(1)-alon(0)
         deltay=alat(1)-alat(0)
         for j=0,nr-1 do begin
             hy=re*deltay*dtr
             dx=re*cos(alat(j)*dtr)*deltax*dtr
             area(*,j)=dx*hy    ; area of each grid point
         endfor
         nbins=20L
         col1=1+(findgen(nbins)/float(nbins))*mcolor
         sfdiff_all=-99.+0.*fltarr(kday,nth)
         pvdiff_all=-99.+0.*fltarr(kday,nth)
      endif
      col2=reverse(1+(findgen(nth)/float(nth))*mcolor)
      meanlat_sf=fltarr(nbins,nth)
      meanlat_pv=fltarr(nbins,nth)
      sigmalat_sf=fltarr(nbins,nth)
      sigmalat_pv=fltarr(nbins,nth)
;     if setplot eq 'ps' then begin
;        set_plot,'ps'
;        xsize=nxdim/100.
;        ysize=nydim/100.
;        !psym=0
;        !p.font=0
;        device,font_size=9
;        device,/landscape,bits=8,filename='PV_vs_SF/geos5_nh_sf_pv_difflat_'+sdate+'.ps'
;        device,/color
;        device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
;     endif
;
; loop over theta surfaces
;
      for ilev=0L,nth-1L do begin
          sf=transpose(sf2(*,*,ilev))
          pv=transpose(pv2(*,*,ilev))
;
; gridpoints within concentric SF and PV contours poleward of 40 N
;
          index=where(lat gt 40.)
          sfmax=max(sf(index))*.9 & sfmin=min(sf(index))*.9
          sfbin=sfmin+((sfmax-sfmin)/float(nbins))*findgen(nbins)
          n=0L
          t=where(lat gt 40. and sf lt sfbin(n))
          if n_elements(t) ge 2L then begin
             result=moment(lat(t))	; mean lat
;
; area-weighted latitude
;
             wlat=total( lat(t)*cos(lat(t)*dtr) )/total( cos(lat(t)*dtr) )
;print,result(0),wlat
;print,30.,(0.*cos(0.)+60.*cos(60.*dtr))/(cos(0.*dtr)+cos(60.*dtr))
if abs(wlat) gt 90. then stop
             meanlat_sf(n,ilev)=wlat
             sigmalat_sf(n,ilev)=sqrt(result(1))
          endif
          for n=0,nbins-2 do begin
              t=where(lat gt 40. and sf gt sfbin(n) and sf le sfbin(n+1))
              if n_elements(t) ge 2L then begin
                 result=moment(lat(t))
                 wlat=total( lat(t)*cos(lat(t)*dtr) )/total( cos(lat(t)*dtr) )
                 meanlat_sf(n,ilev)=wlat
                 sigmalat_sf(n,ilev)=sqrt(result(1))
if abs(wlat) gt 90. then stop
              endif
          endfor
          n=nbins-1
          t=where(lat gt 40. and sf ge sfbin(n))
          if n_elements(t) ge 2L then begin
             result=moment(lat(t))
             wlat=total( lat(t)*cos(lat(t)*dtr) )/total( cos(lat(t)*dtr) )
if abs(wlat) gt 90. then stop
             meanlat_sf(n,ilev)=wlat
             sigmalat_sf(n,ilev)=sqrt(result(1))
          endif

          index=where(lat gt 40.)
          pvmax=max(pv(index))*.9
          pvmin=min(pv(index))*.9
          pvbin=pvmax-((pvmax-pvmin)/float(nbins))*findgen(nbins)
          n=0L
          t=where(lat gt 40. and pv gt pvbin(n))
          if n_elements(t) ge 2L then begin
             result=moment(lat(t))
             wlat=total( lat(t)*cos(lat(t)*dtr) )/total( cos(lat(t)*dtr) )
if abs(wlat) gt 90. then stop
             meanlat_pv(n,ilev)=wlat
             sigmalat_pv(n,ilev)=sqrt(result(1))
          endif
          for n=1,nbins-2L do begin
              t=where(lat gt 40. and pv le pvbin(n) and pv gt pvbin(n+1))
              if n_elements(t) ge 2L then begin
                 result=moment(lat(t))
                 wlat=total( lat(t)*cos(lat(t)*dtr) )/total( cos(lat(t)*dtr) )
if abs(wlat) gt 90. then stop
                 meanlat_pv(n,ilev)=wlat
                 sigmalat_pv(n,ilev)=sqrt(result(1))
              endif
          endfor    
          n=nbins-1
          t=where(lat gt 40. and pv le pvbin(n))
          if n_elements(t) ge 2L then begin
             result=moment(lat(t))
             wlat=total( lat(t)*cos(lat(t)*dtr) )/total( cos(lat(t)*dtr) )
if abs(wlat) gt 90. then stop
             meanlat_pv(n,ilev)=wlat
             sigmalat_pv(n,ilev)=sqrt(result(1))
          endif
endfor  ; loop over altitude
;
; plot
;
;erase
;!type=2^2+2^3
;xyouts,.4,.975,sdate,color=0,/normal,charsize=2,charthick=2
;set_viewport,.075,.475,.6,.95
ilev=nth-1
sf=transpose(sf2(*,*,ilev))
index=where(lat gt 40.)
sfmax=max(sf(index))*0.9 & sfmin=min(sf(index))*0.9
sfbin=sfmin+((sfmax-sfmin)/float(nbins))*findgen(nbins)
index=where(meanlat_sf(*,ilev) ne 0.)
xmin=-1.e-5
xmax=5.e-6
;plot,sfbin(index),meanlat_sf(index,ilev),color=0,thick=7,/noeras,xtitle='SF Bins',$
;     yrange=[30.,90.],/nodata,ytitle='Mean Latitude',xrange=[xmax,xmin],xticks=4
sfdiff=-99.+0.*fltarr(nth)
for ilev=nth-1L,0L,-1L do begin
    sf=transpose(sf2(*,*,ilev))
    index=where(lat gt 40.)
    sfmax=max(sf(index))*0.9 & sfmin=min(sf(index))*0.9
    sfbin=sfmin+((sfmax-sfmin)/float(nbins))*findgen(nbins)
    index=where(meanlat_sf(*,ilev) ne 0.)
;    oplot,sfbin(index),meanlat_sf(index,ilev),color=col2(ilev),psym=0,thick=7
    if meanlat_sf(0,ilev) ne 0. then sfdiff(ilev)=abs(meanlat_sf(0,ilev)-max(meanlat_sf(index,ilev)))
endfor    ; loop over altitude
sfdiff_all(kcount-1,*)=sfdiff
for ilev=nth-1L,0L,-1L do begin
    sf=transpose(sf2(*,*,ilev))
    index=where(lat gt 40.)
    sfmax=max(sf(index))*0.9 & sfmin=min(sf(index))*0.9
    sfbin=sfmin+((sfmax-sfmin)/float(nbins))*findgen(nbins)
    index=where(meanlat_sf(*,ilev) ne 0.)
;    if sfbin(index(0)) gt xmin and sfbin(index(0)) lt xmax then $
;       xyouts,sfbin(index(0)),meanlat_sf(index(0),ilev),'V',/data,color=0,charthick=5,charsize=2,alignment=0.5
endfor    ; loop over altitude
;
;!type=2^2+2^3
;set_viewport,.55,.95,.6,.95
ilev=nth-1
pv=transpose(pv2(*,*,ilev))
index=where(lat gt 40.)
pvmax=max(pv(index))*0.9 & pvmin=min(pv(index))*0.9
pvbin=pvmax-((pvmax-pvmin)/float(nbins))*findgen(nbins)
index=where(meanlat_pv(*,ilev) ne 0.)
xmin=1.e-6
xmax=5.
;plot,pvbin(index),meanlat_pv(index,ilev),color=0,thick=7,/noeras,xtitle='PV Bins',$
;     yrange=[30.,90.],/nodata,/xlog,xrange=[xmin,xmax]
pvdiff=-99.+0.*fltarr(nth)
for ilev=nth-1L,0,-1L do begin
    pv=transpose(pv2(*,*,ilev))
    index=where(lat gt 40.)
    pvmax=max(pv(index))*0.9 & pvmin=min(pv(index))*0.9
    pvbin=pvmax-((pvmax-pvmin)/float(nbins))*findgen(nbins)
    index=where(meanlat_pv(*,ilev) ne 0.)
;    oplot,pvbin(index),meanlat_pv(index,ilev),color=col2(ilev),psym=0,thick=7
    if meanlat_pv(0,ilev) ne 0. then pvdiff(ilev)=abs(meanlat_pv(0,ilev)-max(meanlat_pv(index,ilev)))
endfor	; loop over altitude
pvdiff_all(kcount-1,*)=pvdiff
for ilev=nth-1L,0,-1L do begin
    pv=transpose(pv2(*,*,ilev))
    index=where(lat gt 40.)
    pvmax=max(pv(index))*0.9 & pvmin=min(pv(index))*0.9
    pvbin=pvmax-((pvmax-pvmin)/float(nbins))*findgen(nbins)
    index=where(meanlat_pv(*,ilev) ne 0.)
;    if pvbin(index(0)) gt xmin and pvbin(index(0)) lt xmax then $
;       xyouts,pvbin(index(0)),meanlat_pv(index(0),ilev),'V',/data,color=0,charthick=5,charsize=2,alignment=0.5
endfor  ; loop over altitude
;col2=1+(findgen(nth)/float(nth))*mcolor
;imin=min(th)
;imax=max(th)
;ymnb=0.6 -cbaryoff
;ymxb=ymnb  +cbarydel
;set_viewport,.075,.95,ymnb,ymxb
;!type=2^2+2^3+2^6
;plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='Theta (K)',charsize=1.5
;ybox=[0,10,10,0,0]
;x1=imin
;dx=(imax-imin)/float(nth)
;for j=0,nth-1 do begin
;xbox=[x1,x1,x1+dx,x1+dx,x1]
;polyfill,xbox,ybox,color=col2(j)
;x1=x1+dx
;endfor
;!type=2^2+2^3
;set_viewport,.075,.475,.05,.45
;index=where(sfdiff ne -99.)
;;plot,sfdiff(index),th(index),color=0,thick=7,/noeras,xtitle='Mean Lat at Min SF - Max Lat',$
;plot,sfdiff(index),th(index),color=0,psym=2,/noeras,xtitle='Mean Lat at Min SF - Max Lat',$
;     ytitle='Theta (K)',xrange=[0.,90.]
;set_viewport,.55,.95,.05,.45
;index=where(pvdiff ne -99.)
;;plot,pvdiff(index),th(index),color=0,thick=7,/noeras,xtitle='Mean Lat at Max PV - Max Lat',$
;plot,pvdiff(index),th(index),color=0,psym=2,/noeras,xtitle='Mean Lat at Max PV - Max Lat',$
;     ytitle='Theta (K)',xrange=[0.,90.]
;
;if setplot ne 'ps' then stop
;if setplot eq 'ps' then begin
;   device,/close
;   spawn,'convert -trim PV_vs_SF/geos5_nh_sf_pv_difflat_'+sdate+'.ps -rotate -90 '+$
;         'PV_vs_SF/geos5_nh_sf_pv_difflat_'+sdate+'.jpg'
;   spawn,'/usr/bin/rm PV_vs_SF/geos5_nh_sf_pv_difflat_'+sdate+'.ps'
;endif

icount=icount+1L
goto,jump
;
; save mean lat in SF and PV bins for all days and altitudes
;
saveit:
index=where(sdates ne '',kday)
sdates=sdates(index)
sfdiff_all=reform(sfdiff_all(index,*))
pvdiff_all=reform(pvdiff_all(index,*))
save,file='geos5_nh_sf_pv_diffwlat_save_daily.sav',sfdiff_all,pvdiff_all,sdates,th
end
