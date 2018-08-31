;
; SH version
; plot an altitude profile of the frequency of the time that
; minimum PV is not inside the vortex
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto

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
set_plot,'x'
!p.background=mcolor
window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
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
lstmn=6L & lstdy=1L & lstyr=2006L
ledmn=6L & leddy=30L & ledyr=2006L
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
      if ndays gt ledday then goto,plotit
;
; construct date string
;
      syr=strcompress(iyr,/remove_all)
      smn=string(FORMAT='(i2.2)',imn)
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
         sf2=fltarr(nr,nc,nth)
         ncdf_varget,ncid,0,alon
         ncdf_varget,ncid,1,alat
         ncdf_varget,ncid,2,th
      endif
      ncdf_varget,ncid,3,pv2
      ncdf_varget,ncid,12,sf2
      ncdf_close,ncid
;
; on first day
;
      if icount eq 0L then begin
         pvfreq=fltarr(nth)
         pvsigma=fltarr(nth)
         pvlat=fltarr(nth)
         pvlatsigma=fltarr(nth)
         sdates=strarr(kday)
         y2d=fltarr(nc,nr)
         for i=0,nc-1 do y2d(i,*)=alat
      endif
      sdates(icount)=sdate
;
; loop over theta surfaces
;
      for ilev=0L,nth-1L do begin
          sf=transpose(sf2(*,*,ilev))
          pv=transpose(pv2(*,*,ilev))
;
; NH SF bins
;
          index=where(y2d lt -20.)
          sfmin=min(sf(index)) & sfmax=max(sf(index))
          nbins=20L
          sfbins=sfmin+((sfmax-sfmin)/(nbins-1.))*findgen(nbins)
          nbins=n_elements(sfbins)
          dsf=sfbins(1)-sfbins(0)
;
; mean PV per SF bin
;
          meanpv=fltarr(nbins)
          sigmapv=fltarr(nbins)
          meanlat=fltarr(nbins)
          sigmalat=fltarr(nbins)
          for ii=0L,nbins-1L do begin
              index=where(y2d lt -20. and sf ge sfbins(ii)-dsf and sf lt sfbins(ii)+dsf)
              if n_elements(index) ge 2L then begin
                 result=moment(pv(index))
                 meanpv(ii)=result(0)
                 sigmapv(ii)=100.*sqrt(result(1))/abs(result(0))	; %
                 result=moment(y2d(index))
                 meanlat(ii)=result(0)
                 sigmalat(ii)=100.*sqrt(result(1))/abs(result(0))        ; %
              endif
          endfor
meanpv=smooth(meanpv,3)
;
; increment this level if max PV is larger outside the vortex
;
index=where(meanpv eq min(meanpv))
;print,th(ilev),index(0)
if index(0) lt nbins-5L then begin
   pvfreq(ilev)=pvfreq(ilev)+1.
   pvsigma(ilev)=pvsigma(ilev)+sigmapv(index(0))
   pvlat(ilev)=pvlat(ilev)+meanlat(index(0))
   pvlatsigma(ilev)=pvlatsigma(ilev)+sigmalat(index(0))
;  plot,sfbins,meanpv,psym=0,thick=5,color=1+(float(ilev)/float(nth))*mcolor
   print,'# SF bins where PV increases ',th(ilev),index(0)
endif
      endfor	; loop over altitude

      icount=icount+1L
goto,jump
plotit:
pvfreq=100.*pvfreq/float(icount)
pvsigma=pvsigma/float(icount)
pvlat=pvlat/float(icount)
pvlatsigma=pvlatsigma/float(icount)
;
; save postscript version
;
sdate0=sdates(0)
sdate1=sdates(kday-1)
save,file='geos5_pv_freq_minout_sh_'+syr+smn+'.sav',pvfreq,pvsigma,pvlat,pvlatsigma,th,sdates,sdate0,sdate1
;
; plot frequency profile
;
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
pvfreq=smooth(pvfreq,3)
pvsigma=smooth(pvsigma,3)
pvlat=smooth(pvlat,3)
pvlatsigma=smooth(pvlatsigma,3)
plot,pvfreq,th,xrange=[0.,100.],yrange=[500.,max(th)],color=0,title=sdate0+'-'+sdate1,$
     xtitle='Frequency of the time mean PV decreases with increasing Elat',ytitle='Theta (K)',thick=5
;oplot,pvsigma,th,psym=0,color=mcolor*.3,thick=5
;oplot,pvlat,th,psym=0,color=mcolor*.9,thick=5
;oplot,pvlatsigma,th,psym=0,color=mcolor*.8,thick=5

end
