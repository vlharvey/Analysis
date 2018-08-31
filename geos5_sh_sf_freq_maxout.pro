;
; plot an altitude profile of the frequency of the time that 
; max SF is outside the vortex (SH)
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
lstmn=3L & lstdy=1L & lstyr=2004L
ledmn=4L & leddy=30L & ledyr=2008L
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
      if smn eq '12' or smn eq '01' or smn eq '02' then goto,jump
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
      endif
      sdates(icount)=sdate
;
; loop over theta surfaces
;
      for ilev=0L,nth-1L do begin
          sf=transpose(sf2(*,*,ilev))
          pv=transpose(pv2(*,*,ilev))
          mark=transpose(mark2(*,*,ilev))
;
; max SF out of vortex and in vortex
;
          aindex=where(y2d lt -30. and mark eq 0.)
          if aindex(0) eq -1L then goto,jumplev
          amax=max(sf(aindex))
          vindex=where(y2d lt -30. and mark eq 1.)
          if vindex(0) eq -1L then goto,jumplev
          vmax=max(sf(vindex))
;
; increment this level if amax lt vmax
;
          if amax gt vmax then begin
             sffreq(ilev)=sffreq(ilev)+1.
             nfreq(ilev)=nfreq(ilev)+1L
erase
set_viewport,.1,.9,.1,.9
map_set,90,0,-90,/ortho,/noeras,color=0,/contin,/grid,title=sdate+string(th(ilev))
contour,sf,alon,alat,/overplot,nlevels=40,color=0
contour,mark,alon,alat,/overplot,levels=[0.1],thick=3,color=0
index=where(y2d gt 0. and sf eq amax)
oplot,x2d(index),y2d(index),psym=8,symsize=2,color=mcolor*.9
index=where(y2d gt 0. and sf eq vmax)
oplot,x2d(index),y2d(index),psym=8,symsize=2,color=mcolor*.3
stop
          endif
jumplev:
      endfor	; loop over altitude
      icount=icount+1L
goto,jump
plotit:
index=where(nfreq ne 0L)
if index(0) eq -1 then stop,'No data'
sffreq(index)=100.*sffreq(index)/float(nfreq(index))
;
; save postscript version
;
kday=icount
sdates=sdates(0:icount-1L)
sdate0=sdates(0)
sdate1=sdates(kday-1)
save,file='geos5_sf_freq_maxout_sh_'+syr+smn+'.sav',sffreq,sdates,sdate0,sdate1,th

if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='geos5_sh_sf_'+sdate0+'-'+sdate1+'_'+slabs(0)+'_freq_maxout.ps'
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
;sffreq=smooth(sffreq,3)
plot,sffreq,th,xrange=[0.,100.],yrange=[500.,max(th)],color=0,title=sdate0+'-'+sdate1,$
     xtitle='Frequency of the time SF max is out of vortex',ytitle='Theta (K)',thick=5

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim geos5_sh_sf_'+sdate0+'-'+sdate1+'_'+slabs(0)+'_freq_maxout.ps -rotate -90 '+$
         'geos5_sh_sf__'+sdate0+'-'+sdate1+'_'+slabs(0)+'_freq_maxout.jpg'
   spawn,'/usr/bin/rm geos5_sh_sf_'+sdate0+'-'+sdate1+'_'+slabs(0)+'_freq_maxout.ps'
endif
end
