;
; MERRA version.  
;
; zonal mean temperature and zonal wind from theta data
; store 2-D arrays (day vs. theta) of dT/dy and Ubar 
; for both hemispheres and entire data record in one IDL save file
;
@stddat
@kgmt
@ckday
@kdate

loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=[0.15,.15]
yorig=[.55,.1]
xlen=0.7
ylen=0.35
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
!noeras=1
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_press_'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
lstmn=1L & lstdy=1L & lstyr=1979L
ledmn=10L & leddy=31L & ledyr=2013L
;
restore,'Save_files/MERRA_dTdy_Ubar_SSW_Climo.sav'
;
; save postscript version
;
sdate0=syyyymmdd(0)
sdate1=syyyymmdd(icount-1)
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='merra_ssw_pdfs.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
   !p.thick=2.
   !p.charthick=2.
   !p.charsize=1.5
endif
syr=strmid(syyyymmdd,2,2)
smn=strmid(syyyymmdd,4,2)
sdy=strmid(syyyymmdd,6,2)
xindex=where(sdy eq '01' and smn eq '01',nxticks)
xlabs=syr(xindex)

erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=-50.+5.*findgen(21)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
!type=2^2+2^3

index=where(pressure eq 10.)
ilev=index(0)
ubar10=reform(NH_UBAR(*,ilev))
index=where(ubar10 lt 0. and (SMN eq '12' or SMN eq '01' or SMN eq '02'),nday)
sswwind=reform(ubar10(index))
sswdate=YYYYMMDD(index)
syr=strmid(SYYYYMMDD,0,4)
jday = JULDAY(long(smn(index)), long(sdy(index)), long(syr(index)))
;
; how many days in each SSW with and without and ES?
;
n0=findgen(nday)
n1=1+findgen(nday)
diff=jday(n1)-jday(n0)
print,ubar10(index)
print,sswdate
print,diff
sswlen=fltarr(100)
sswdd=lonarr(100)
issw=0
for i=0L,nday-2L do begin
    if diff(i) eq 1 then sswlen(issw)=sswlen(issw)+1
    if diff(i) ne 1 then begin
       sswlen(issw)=sswlen(issw)+1
       sswdd(issw)=sswdate(i)
       if diff(i) gt 14L then issw=issw+1
       if diff(i) lt 14L then sswlen(issw)=sswlen(issw)+diff(i)
    endif
endfor
sswlen(issw)=sswlen(issw)+1
sswdd(issw)=sswdate(nday-1)
good=where(sswlen ne 0.)
sswlen=sswlen(good)
sswdd=sswdd(good)
plot,sswdd/10000L,sswlen,psym=8,color=0,yrange=[0,80],xrange=[1979,2013],ytitle='Major SSW Duration (days)',charsize=2,charthick=2,title='MERRA'
index=where(sswdd/10000L eq 2004L or sswdd/10000L eq 2006L or sswdd/1000L eq 20090L or sswdd/10000L eq 2010L or sswdd/1000L eq 20120L or sswdd/10000L eq 2013L)
oplot,sswdd(index)/10000L,sswlen(index),psym=8,color=250
a=findgen(8)*(2*!pi/8.)
usersym,2*cos(a),2*sin(a)
index=where(sswdd/10000L eq 1985L or sswdd/1000L eq 19870L)
oplot,sswdd(index)/10000L,sswlen(index),psym=8,color=250

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
index=where(sswdd/10000L eq 1985L or sswdd/1000L eq 19870L or sswdd/10000L eq 2004L or sswdd/10000L eq 2006L or $
            sswdd/1000L eq 20090L or sswdd/10000L eq 2010L or sswdd/1000L eq 20120L or sswdd/10000L eq 2013L)
esflag=0*sswdd
esflag(index)=1
years=1979+indgen(35)
index=where(esflag eq 0)
nmajornoes=sswlen(index)
print,nmajornoes
index=where(esflag eq 1)
nmajorwes=sswlen(index)
print,nmajorwes

x=5*findgen(17)
y1=histogram(nmajornoes,min=0,max=80,binsize=5)
y2=histogram(nmajorwes,min=0,max=80,binsize=5)
;y1=smooth(y1,3,/edge_truncate)
;y2=smooth(y2,3,/edge_truncate)
plot,x,y1,color=0,thick=10,ytitle='Number of Major SSWs',xtitle='Major SSW duration (days)',charsize=2,charthick=2
oplot,x,y2,color=250,thick=9
xyouts,55,8,'NO ES',color=0,/data,charsize=2,charthick=2
xyouts,55,7,'With ES',color=250,/data,charsize=2,charthick=2

if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim merra_ssw_pdfs.ps -rotate -90 merra_ssw_pdfs.jpg'
endif

end
