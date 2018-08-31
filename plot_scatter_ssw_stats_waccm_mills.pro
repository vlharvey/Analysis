;
; scatter plot
; mee01fco run
; plot number of minor ssw days per DJF.  use standard WMO definition
;
@stddat
@kgmt
@ckday
@kdate

a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
icmm1=icolmax-1
icmm2=icolmax-2
device,decompose=0
!noeras=1
nxdim=600
nydim=600
xorig=[0.175]
yorig=[0.25]
xlen=0.7
ylen=0.5
cbaryoff=0.08
cbarydel=0.02
set_plot,'x'
setplot='x'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=icolmax
endif
ilev=36         ; 36=10.7 hPa
for ilev=20,50 do begin
spawn,'ls /aura3/data/WACCM_data/Pre_process_Isentropic/Datfiles/waccm_ssw_stats_mee01fco_mills_*sav',ifiles
nyear=n_elements(ifiles)
for iyear=0L,nyear-1L do begin
    restore,ifiles(iyear)
    if iyear eq 0L then begin
       NHDT_all=nhdt
       nhu60_all=NHU60
       shdt_all=SHDT
       shu60_all=SHU60
       yyyymmdd_all=YYYYMMDD
    endif
    if iyear gt 0L then begin
       NHDT_all=[NHDT_all,nhdt]
       nhu60_all=[nhu60_all,NHU60]
       shdt_all=[shdt_all,SHDT]
       shu60_all=[shu60_all,SHU60]
       yyyymmdd_all=[yyyymmdd_all,YYYYMMDD]
    endif
;help,NHDT_all
endfor
good=where(yyyymmdd_all ne 0L,kday)
NHDT=reform(nhdt_all(good,*))
nhu60=reform(NHU60_all(good,*))
shdt=reform(SHDT_all(good,*))
shu60=reform(SHU60_all(good,*))
yyyymmdd=reform(YYYYMMDD_all(good))
print,'mee01 ',min(yyyymmdd),max(yyyymmdd)

syyyymmdd=strcompress(yyyymmdd,/remove_all)
syear=strmid(syyyymmdd,0,4)
smon=strmid(syyyymmdd,4,2)
iyear0=min(long(syear))
iyear1=max(long(syear))
nyear=iyear1-iyear0+1L
nhfreq=fltarr(nyear)
shfreq=fltarr(nyear)
slev=strcompress(lev(ilev),/remove_all)
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='plot_scatter_ssw_stats_waccm_mills_'+slev+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
   !p.thick=2.0                   ;Plotted lines twice as thick
   !p.charsize=2.0
endif
for iyear=iyear0,iyear1 do begin
    syear0=strcompress(iyear-1,/remove_all)
    syear1=strcompress(iyear,/remove_all)
;   index=where((syear eq syear0 and smon eq '12') or (syear eq syear1 and smon eq '01') or $
;               (syear eq syear1 and smon eq '02'),nday)
;   if index(0) ne -1L then begin
;      nhdt0=reform(nhdt(index,ilev))
       nhdt0=reform(nhdt(*,ilev))
       index=where(nhdt0 gt 0.,nn)
       nhfreq(iyear-iyear0)=nn
;   endif
    index=where(syear eq syear1 and (smon eq '08' or smon eq '09' or smon eq '10'),nday)
    if index(0) ne -1L then begin
       shdt0=reform(shdt(index,ilev))
       index=where(shdt0 gt 0.,nn)
       shfreq(iyear-iyear0)=nn
    endif
endfor
erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
plot,findgen(50),findgen(50),/noeras,ytitle='mee01fco',xtitle='mee00fco',$
     color=0,yrange=[0.,50.],xrange=[0.,50.],title=slev+' hPa'
m1pts_nh=reform(100.*(nhfreq/90.))
m1pts_sh=reform(100.*(shfreq/91.))
;
; mee00
;
spawn,'ls /aura3/data/WACCM_data/Pre_process_Isentropic/Datfiles/waccm_ssw_stats_mee00fco_mills_*sav',ifiles
nyear=n_elements(ifiles)
for iyear=0L,nyear-1L do begin
    restore,ifiles(iyear)
    if iyear eq 0L then begin
       NHDT_all=nhdt
       nhu60_all=NHU60
       shdt_all=SHDT
       shu60_all=SHU60
       yyyymmdd_all=YYYYMMDD
    endif
    if iyear gt 0L then begin
       NHDT_all=[NHDT_all,nhdt]
       nhu60_all=[nhu60_all,NHU60]
       shdt_all=[shdt_all,SHDT]
       shu60_all=[shu60_all,SHU60]
       yyyymmdd_all=[yyyymmdd_all,YYYYMMDD]
    endif
;help,NHDT_all
endfor
good=where(yyyymmdd_all ne 0L,kday)
NHDT=reform(nhdt_all(good,*))
nhu60=reform(NHU60_all(good,*))
shdt=reform(SHDT_all(good,*))
shu60=reform(SHU60_all(good,*))
yyyymmdd=reform(YYYYMMDD_all(good))
print,'mee00 ',min(yyyymmdd),max(yyyymmdd)

syyyymmdd=strcompress(yyyymmdd,/remove_all)
syear=strmid(syyyymmdd,0,4)
smon=strmid(syyyymmdd,4,2)
iyear0=min(long(syear))
iyear1=max(long(syear))
nyear=iyear1-iyear0+1L
nhfreq=fltarr(nyear)
shfreq=fltarr(nyear)
for iyear=iyear0,iyear1 do begin
    syear0=strcompress(iyear-1,/remove_all)
    syear1=strcompress(iyear,/remove_all)
;   index=where((syear eq syear0 and smon eq '12') or (syear eq syear1 and smon eq '01') or $
;               (syear eq syear1 and smon eq '02'),nday)
;   if index(0) ne -1L then begin
;      nhdt0=reform(nhdt(index,ilev))
       nhdt0=reform(nhdt(*,ilev))
       index=where(nhdt0 gt 0.,nn)
       nhfreq(iyear-iyear0)=nn
;   endif
    index=where(syear eq syear1 and (smon eq '08' or smon eq '09' or smon eq '10'),nday)
    if index(0) ne -1L then begin
       shdt0=reform(shdt(index,ilev))
       index=where(shdt0 gt 0.,nn)
       shfreq(iyear-iyear0)=nn
    endif
endfor
m0pts_nh=reform(100.*(nhfreq/90.))
m0pts_sh=reform(100.*(shfreq/91.))

good=where(m0pts_nh ne 0. and m1pts_nh ne 0.)
if good(0) ne -1L then oplot,m0pts_nh(good),m1pts_nh(good),psym=8,color=0

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim plot_scatter_ssw_stats_waccm_mills_'+slev+'.ps '+$
         '-rotate -90 plot_scatter_ssw_stats_waccm_mills_'+slev+'.jpg'
endif
endfor
end
