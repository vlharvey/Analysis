;
; plot an altitude profile of the frequency of the time that
; max PV is not in my vortex
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto
@calcelat2d

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
dir2='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS520.MetO.'
lstmn=11L & lstdy=1L & lstyr=2004L
ledmn=11L & leddy=30L & ledyr=2004L
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
;     if smn eq '06' or smn eq '07' or smn eq '08' then goto,jump
      sdy=string(FORMAT='(i2.2)',idy)
      sdate=syr+smn+sdy
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
         mark2=fltarr(nr,nc,nth)
         sf2=fltarr(nr,nc,nth)
         ncdf_varget,ncid,0,alon
         ncdf_varget,ncid,1,alat
         ncdf_varget,ncid,2,th
      endif
      ncdf_varget,ncid,3,pv2
      ncdf_varget,ncid,10,mark2
;     ncdf_varget,ncid,12,sf2
;
; read in MSF instead
;
      ncdf_varget,ncid,5,sf2
      ncdf_close,ncid
;
; on first day
;
      if icount eq 0L then begin
         pvfreq=fltarr(nth)
         nfreq=lonarr(nth)
         sdates=strarr(kday)
         x2d=fltarr(nc,nr)
         y2d=fltarr(nc,nr)
         for i=0,nr-1 do x2d(*,i)=alon
         for i=0,nc-1 do y2d(i,*)=alat
      endif
      sdates(icount)=sdate
;
; loop over theta surfaces
;
      for ilev=0L,nth-1L do begin
          sf1=transpose(sf2(*,*,ilev))
          pv1=transpose(pv2(*,*,ilev))
          mark1=transpose(mark2(*,*,ilev))
index=where(y2d gt 40.)
sfmin=min(sf1(index))
sfmax=max(sf1(index))
sfthresh=(sfmin+sfmax)/2.
;
; min MSF out of vortex and in vortex
;
;         aindex=where(y2d gt 40. and mark1 eq 0.)
          aindex=where(y2d gt 40. and sf1 gt sfthresh)
          if aindex(0) eq -1L then goto,jumplev
          amax=max(pv1(aindex))
;         vindex=where(y2d gt 40. and mark1 eq 1.)
          vindex=where(y2d gt 40. and sf1 le sfthresh)
          if vindex(0) eq -1L then goto,jumplev
          vmax=max(pv1(vindex))
;
; increment this level if amax gt vmax
;
          if amax gt vmax then begin
             pvfreq(ilev)=pvfreq(ilev)+1.
             nfreq(ilev)=nfreq(ilev)+1L
;erase
;set_viewport,.1,.9,.1,.9
;nlvls=30
;col1=1+(findgen(nlvls)/float(nlvls))*mcolor
;map_set,90,0,-90,/ortho,/noeras,color=0,/contin,/grid,title=sdate+string(th(ilev))
;contour,pv1,alon,alat,/overplot,nlevels=30,c_color=col1,thick=3
;contour,sf1,alon,alat,/overplot,levels=[sfthresh],color=mcolor*.3,thick=4
;contour,mark1,alon,alat,/overplot,levels=[0.1],thick=4,color=0
;index=where(y2d gt 0. and pv1 eq amax)
;oplot,x2d(index),y2d(index),psym=8,symsize=2,color=mcolor*.9
;index=where(y2d gt 0. and pv1 eq vmax)
;oplot,x2d(index),y2d(index),psym=8,symsize=2,color=mcolor*.3
;stop
          endif
jumplev:
      endfor
icount=icount+1
goto,jump
plotit:
index=where(nfreq ne 0L)
if index(0) eq -1 then stop,'No data'
pvfreq(index)=100.*pvfreq(index)/float(icount)	;float(nfreq(index))
;
; save postscript version
;
kday=icount
sdates=sdates(0:icount-1)
sdate0=sdates(0)
sdate1=sdates(kday-1)
save,file='geos5_pv_freq_maxout_nh_'+syr+smn+'_msf.sav',pvfreq,sdates,sdate0,sdate1,th

if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='geos5_nh_pv_'+sdate0+'-'+sdate1+'_'+slabs(0)+'_freq_maxout_msf.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
   !p.thick=2
endif
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
;pvfreq=smooth(pvfreq,3)
plot,pvfreq,th,xrange=[0.,100.],yrange=[min(th),max(th)],color=0,title=sdate0+'-'+sdate1,$
     xtitle='Percent of the time max PV in high MSF bins',ytitle='Theta (K)',thick=5

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim geos5_nh_pv_'+sdate0+'-'+sdate1+'_'+slabs(0)+'_freq_maxout_msf.ps -rotate -90 '+$
         'geos5_nh_pv_'+sdate0+'-'+sdate1+'_'+slabs(0)+'_freq_maxout_msf.jpg'
   spawn,'/usr/bin/rm geos5_nh_pv_'+sdate0+'-'+sdate1+'_'+slabs(0)+'_freq_maxout_msf.ps'
endif
end
