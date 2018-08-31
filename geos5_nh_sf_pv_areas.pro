;
; compute the area within SF and PV bins
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
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
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
lstmn=11L & lstdy=3L & lstyr=2006L
ledmn=11L & leddy=30L & ledyr=2006L
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
      if ndays gt ledday then stop,' Normal termination condition '
;
; construct date string
;
      syr=strcompress(iyr,/remove_all)
      smn=string(FORMAT='(i2.2)',imn)
      if smn eq '06' or smn eq '07' or smn eq '08' then goto,jump
      sdy=string(FORMAT='(i2.2)',idy)
      sdate=syr+smn+sdy
;
; read GEOS-5 data
;
      file1=dir+sdate+stimes(0)+'nc3'
      dum1=findfile(file1)
      if dum1(0) ne '' then begin
         ncid=ncdf_open(file1)
         print,'opening ',file1
      endif
      if dum1(0) eq '' then goto,jump
      if icount eq 0L then begin
         ncdf_diminq,ncid,0,name,nr
         ncdf_diminq,ncid,1,name,nc
         ncdf_diminq,ncid,2,name,nth
         alon=fltarr(nc)
         alat=fltarr(nr)
         th=fltarr(nth)
         pv2=fltarr(nr,nc,nth)
         mark2=fltarr(nr,nc,nth)
         sf2=fltarr(nr,nc,nth)
         ncdf_varget,ncid,0,alon
         ncdf_varget,ncid,1,alat
         ncdf_varget,ncid,2,th
      endif
      ncdf_varget,ncid,3,pv2
      ncdf_varget,ncid,10,mark2
      ncdf_varget,ncid,12,sf2
      ncdf_close,ncid
;
; on first day
;
      if icount eq 0L then begin
         sffreq=fltarr(nth)
         nfreq=lonarr(nth)
         sdates=strarr(kday)
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
         icount=1
      endif
      area_sf=fltarr(nbins,nth)
      area_pv=fltarr(nbins,nth)
;
; loop over theta surfaces
;
      for ilev=0L,nth-1L do begin
          sf=transpose(sf2(*,*,ilev))
          pv=transpose(pv2(*,*,ilev))
          mark=transpose(mark2(*,*,ilev))
;
; area within concentric SF and PV contours
;
          index=where(lat gt 40.)
          sfmax=max(sf(index))*.9 & sfmin=min(sf(index))*.9
          sfbin=sfmin+((sfmax-sfmin)/float(nbins))*findgen(nbins)
          n=0L
          t=where(lat gt 40. and sf lt sfbin(n))
          if t(0) ne -1L then area_sf(n,ilev)=total(area(t))
          for n=1,nbins-2 do begin
              t=where(lat gt 40. and sf gt sfbin(n) and sf le sfbin(n+1))
              if t(0) ne -1L then area_sf(n,ilev)=total(area(t))
          endfor
          n=nbins-1
          t=where(lat gt 40. and sf ge sfbin(n))
          if t(0) ne -1L then area_sf(n,ilev)=total(area(t))

          index=where(lat gt 40.)
          pvmax=max(pv(index))*.9
          pvmin=min(pv(index))*.9
          pvbin=pvmax-((pvmax-pvmin)/float(nbins))*findgen(nbins)
          n=0L
          t=where(lat gt 40. and pv gt pvbin(n))
          if t(0) ne -1L then area_pv(n,ilev)=total(area(t))
          for n=1,nbins-2L do begin
              t=where(lat gt 40. and pv le pvbin(n) and pv gt pvbin(n+1))
              if t(0) ne -1L then area_pv(n,ilev)=total(area(t))
          endfor    
          n=nbins-1
          t=where(lat gt 40. and pv le pvbin(n))
          if t(0) ne -1L then area_pv(n,ilev)=total(area(t))

erase
!type=2^2+2^3
xyouts,.3,.9,sdate+' '+string(th(ilev)),color=0,/normal
set_viewport,.1,.8,.5,.8
plot,pvbin,area_pv(*,ilev),color=0,psym=1,/noeras,xtitle='PV bins'
oplot,pvbin,area_pv(*,ilev),color=0,psym=0
axis,xrange=[min(sfbin),max(sfbin)],/save,xaxis=1,/data,color=mcolor*.9,xtitle='SF bins'
oplot,sfbin,area_sf(*,ilev),color=mcolor*.9,psym=1
oplot,sfbin,area_sf(*,ilev),color=mcolor*.9,psym=0
set_viewport,.1,.4,.1,.4
map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras
contour,sf,alon,alat,levels=sfbin,c_color=col1,/cell_fill,/noeras,/overplot
contour,sf,alon,alat,levels=sfbin,color=0,/follow,/noeras,/overplot
set_viewport,.5,.8,.1,.4
map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras
contour,pv,alon,alat,levels=reverse(pvbin),c_color=col1,/cell_fill,/noeras,/overplot
contour,pv,alon,alat,levels=reverse(pvbin),color=0,/follow,/noeras,/overplot
stop
;
; convert square km to elat
;
;         index=where(lat gt 40. and mark1 gt 0.0,nn)
;         if index(0) ne -1 then begin
;            phem=100.*total(area(index))/hem_area      ; % of hemisphere
;            for jj=1L,nrr-1L do begin
;                if hem_frac(jj) le phem and hem_frac(jj-1) gt phem then begin
;                   scale=(hem_frac(jj)-phem)/(hem_frac(jj)-hem_frac(jj-1))
;                   area_sf(jj,ilev)=yeq(jj)-scale*(yeq(jj)-yeq(jj-1)) ; Equivalent latitude
;print,hem_frac(jj-1),phem,hem_frac(jj),scale
;print,yeq(jj-1),area_zt_nc4(icount,thlev),yeq(jj)
;stop
;                endif
;            endfor
;         endif
jumplev:
      endfor	; loop over altitude

if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='geos5_nh_sf_pv_areas_'+sdate+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
   !p.thick=2
endif
;
; plot areas within SF and PV contours
;
;erase
;!type=2^2+2^3
;xmn=xorig(0)
;xmx=xorig(0)+xlen
;ymn=yorig(0)
;ymx=yorig(0)+ylen
;set_viewport,xmn,xmx,ymn,ymx
;;sffreq=smooth(sffreq,3)
;plot,sffreq,th,xrange=[0.,100.],yrange=[min(th),max(th)],color=0,title=sdate0+'-'+sdate1,$
;     xtitle='Percent of the time SF min is out of vortex',ytitle='Theta (K)',thick=5

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim geos5_nh_sf_pv_areas_'+sdate+'.ps -rotate -90 '+$
         'geos5_nh_sf_pv_areas_'+sdate+'.jpg'
   spawn,'/usr/bin/rm geos5_nh_sf_pv_areas_'+sdate+'.ps'
endif

goto,jump
end
