;****************************************************************************************
; CIPS PMC frequency, OMI Ozone hole area, MERRA zonal wind speed
; SH onset
;****************************************************************************************
@stddat
@kgmt
@ckday
@kdate
@readl3omi
@rd_merra_nc3

restore,'c11.tbl'
tvlct,c1,c2,c3
c1(12)=180 & c2(12)=0 & c3(12)=0
tvlct,c1,c2,c3  ;must execute this again.
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=1000
nydim=1000
xorig=[0.15,0.15,0.15]
yorig=[0.75,0.45,0.15]
cbaryoff=0.08
cbarydel=0.01
xlen=0.7
ylen=0.225
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
;
; read CIPS PMC frequencies at 80S with 2G threshhold for all years
;
restore,'o3hole_area.sav
omidfs=dfs
omifdoy=fdoy
omidates=sdates_all
restore,'/Volumes/Data/CIPS_data/Line_Plots/F_V4.20_r05_80Lat_2G_all_sh_plot_data.sav
; 
; PLOT_DAYS_ASC   INT       = Array[120, 7]
; PLOT_DAYS_DSC   INT       = Array[120, 7]
; PLOT_F_ASC      FLOAT     = Array[120, 7]
; PLOT_F_DSC      FLOAT     = Array[120, 7]
; SEASONS         STRING    = Array[7]
; SLAT            STRING    = '80'
;
; loop over years
;
cols=[6,7,8,9,10,11,12,13]
col1=cols
for iyear=2007,2014 do begin
    slat='-60.0000'
    yearlab=strcompress(iyear,/remove_all)
    restore,'Save_files/omi_mino3_'+yearlab+'_'+slat+'.sav'	;,kday,mino3time,maxo3time,meano3time,minlattime,sdates
    if iyear eq 2007 then begin
       mino3time_all=mino3time
       maxo3time_all=maxo3time
       meano3time_all=meano3time
       minlattime_all=minlattime
       sdates_all=sdates
    endif
    if iyear gt 2007 then begin
       mino3time_all=[mino3time_all,mino3time]
       maxo3time_all=[maxo3time_all,maxo3time]
       meano3time_all=[meano3time_all,meano3time]
       minlattime_all=[minlattime_all,minlattime]
       sdates_all=[sdates_all,sdates]
    endif
endfor

nn=n_elements(sdates_all)
fdoy=fltarr(nn)
for i=0L,nn-1L do begin
    iyr=long(strmid(sdates_all(i),0,4))
    imn=long(strmid(sdates_all(i),4,2))
    idy=long(strmid(sdates_all(i),6,2))
    z = kgmt(imn,idy,iyr,iday)
    fdoy(i)=1.0*iday
endfor
;
; read MERRA and save zonal mean zonal winds and temperatures for every day in sdates_all
;
goto,quick
dirm='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'
for i=0L,nn-1L do begin
    sdate=sdates_all(i)
    ifile=dirm+sdate+'.nc3'
    dum1=findfile(ifile)
    iflag=0L
    if dum1(0) ne '' then begin
       ncid=ncdf_open(ifile)
       print,ifile
       ncdf_diminq,ncid,0,name,nr
       ncdf_diminq,ncid,1,name,nc
       ncdf_diminq,ncid,2,name,nth
       alon=fltarr(nc)
       alat=fltarr(nr)
       th=fltarr(nth)
       p2=fltarr(nr,nc,nth)
       u2=fltarr(nr,nc,nth)
       ncdf_varget,ncid,0,alon
       ncdf_varget,ncid,1,alat
       ncdf_varget,ncid,2,th
       ncdf_varget,ncid,4,p2
       ncdf_varget,ncid,5,u2
       ncdf_close,ncid
    endif
    if dum1(0) eq '' then iflag=1
    if iflag ne 0L then goto,jumpmerra
    tmp2=0.*p2
    for k=0L,nth-1L do tmp2(*,*,k)=th(k)*(p2(*,*,k)/1000.)^0.286

    if i eq 0L then begin
       uzm_all=fltarr(nr,nth,nn)
       tzm_all=fltarr(nr,nth,nn)
    endif
    uzm_all(*,*,i)=mean(u2,dim=2)
    tzm_all(*,*,i)=mean(tmp2,dim=2)
jumpmerra:
endfor
save,filename='merra_ubar_tbar_cips.sav',alat,th,sdates_all,uzm_all,tzm_all
quick:
restore,'merra_ubar_tbar_cips.sav

if setplot eq 'ps' then begin
   lc=0
   xsize=nxdim/100.
   ysize=nydim/100.
   set_plot,'ps'
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='omi+cips_area_allyears_'+slat+'.ps'
   !p.charsize=1.2
   !p.thick=2
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif

erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
plot,[0,0],[0,0],/nodata,xrange=[-50,50],xtitle='DFS',color=0,yrange=[0,100],ytitle='CIPS PMC Frequency 80S 2G',charsize=1.5,charthick=2
pmconset_date=fltarr(2014-2007+1)
for i=2007,2014 do begin
    isea=i-2007
    ddd=reform(PLOT_DAYS_ASC(*,isea))
    array=reform(PLOT_F_ASC(*,isea))
    index=where(ddd ne 0)
    ddd=ddd(index)
    array=array(index)
    oplot,ddd,array,thick=12,color=cols(isea)

index=where(array ge 10. and ddd gt -60)
print,i,min(ddd(index))
pmconset_date(i-2007)=min(ddd(index))

endfor

xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
xlabs=['07','08','09','10','11','12','01','02','03','04','05','06']
nxticks=n_elements(xlabs)
plot,[0,0],/nodata,xrange=[-50,50],xtitle='DFS',color=0,yrange=[-10,60],/noeras,ytitle='MERRA Zonal Wind (m/s)',charsize=1.5,charthick=2

print,alat
rlat=-59.6842
;read,'Enter Latitude ',rlat
index=where(abs(alat-rlat) eq min(abs(alat-rlat)))
ilat=index(0)
slat=strcompress(alat(ilat),/remove_all)
print,th
rth=500.
read,'Enter Theta ',rth
index=where(abs(rth-th) eq min(abs(rth-th)))
ith=index(0)
sth=strcompress(long(th(ith)),/remove_all)+'K'
udata=reform(uzm_all(ilat,ith,*))
tdata=reform(tzm_all(ilat,ith,*))

DFS=omidfs
fdoy=omifdoy
sdates_all=omidates
windshift_date=fltarr(2014-2007+1)

for iyear=2007,2014 do begin
    iyr=long(strmid(sdates_all,0,4))
    index=where((iyr eq iyear and fdoy ge 182.) or (iyr eq iyear+1L and fdoy lt 182.))
    iyr0=iyr(index)
    fdoy0=fdoy(index)
    udata0=udata(index)
    dfs0=dfs(index)
    oplot,dfs0,udata0,thick=12,color=col1(iyear-2007)

    index=where(udata0 le 15. and dfs0 gt -60)
    print,iyear,min(dfs0(index))
    windshift_date(iyear-2007)=min(dfs0(index))
endfor
xyouts,xmx-0.4,ymx-0.02,slat+'  '+sth,/normal,color=0,charsize=2,charthick=2
set_viewport,0.675,0.825,0.5,0.65
plot,pmconset_date,windshift_date,xrange=[-50,10],xtitle='PMC Onset',color=0,yrange=[-50,10],/noeras,ytitle='U<15',charsize=1.5,psym=8,charthick=2
oplot,-50+findgen(61),-50+findgen(61),color=0
for i=0,n_elements(windshift_date)-1L do begin
    a=findgen(8)*(2*!pi/8.)
    usersym,cos(a),sin(a),/fill
    oplot,[pmconset_date(i),pmconset_date(i)],[windshift_date(i),windshift_date(i)],psym=8,symsize=2,color=col1(i)
    a=findgen(9)*(2*!pi/8.)
    usersym,cos(a),sin(a)
    oplot,[pmconset_date(i),pmconset_date(i)],[windshift_date(i),windshift_date(i)],psym=8,symsize=2,color=0
endfor
result=correlate(pmconset_date,windshift_date)
xyouts,0.75,0.66,'r='+string(result,format='(f4.2)'),/normal,color=0,charsize=1.5,charthick=2

xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
xlabs=['07','08','09','10','11','12','01','02','03','04','05','06']
nxticks=n_elements(xlabs)
plot,[0,0],/nodata,xrange=[-50,50],xtitle='DFS',color=0,yrange=[0,30],/noeras,ytitle='OMI O3 Hole Area (Million km!U2!N)',charsize=1.5,charthick=2
hem='SH'
yearlab_all=strarr(2014-2007+1)
o3hole_death=fltarr(2014-2007+1)
for iyear=2007,2014 do begin
    iyr=long(strmid(sdates_all,0,4))
    index=where((iyr eq iyear and fdoy ge 182.) or (iyr eq iyear+1L and fdoy lt 182.))
    iyr0=iyr(index)
    fdoy0=fdoy(index)
    area0=O3AREA_ALL(index)
    dfs0=dfs(index)
    yearlab=strmid(strcompress(iyear,/remove_all),2,2)+'/'+strmid(strcompress(iyear+1L,/remove_all),2,2)
    yearlab_all(iyear-2007)=yearlab
    oplot,dfs0,area0,thick=12,color=col1(iyear-2007)

    index=where(area0 le 2. and dfs0 gt -60)
    print,iyr0(0),min(dfs0(index))
    o3hole_death(iyear-2007)=min(dfs0(index))
endfor
set_viewport,0.675,0.825,0.2,0.35
plot,pmconset_date,o3hole_death,xrange=[-50,10],xtitle='PMC Onset',color=0,yrange=[-50,10],/noeras,ytitle='Area<2',charsize=1.25,psym=8,charthick=2
oplot,-50+findgen(61),-50+findgen(61),color=0
for i=0,n_elements(o3hole_death)-1L do begin
    a=findgen(8)*(2*!pi/8.)
    usersym,cos(a),sin(a),/fill
    oplot,[pmconset_date(i),pmconset_date(i)],[o3hole_death(i),o3hole_death(i)],psym=8,symsize=2,color=col1(i)
    a=findgen(9)*(2*!pi/8.)
    usersym,cos(a),sin(a)
    oplot,[pmconset_date(i),pmconset_date(i)],[o3hole_death(i),o3hole_death(i)],psym=8,symsize=2,color=0
endfor
result=correlate(pmconset_date,o3hole_death)
xyouts,0.75,0.36,'r='+string(result,format='(f4.2)'),/normal,color=0,charsize=1.5,charthick=2

!type=2^2+2^3+2^6
set_viewport,xmn,max(xorig)+xlen,ymn-cbaryoff,ymn-cbaryoff+cbarydel
imin=2007
imax=2014
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,xstyle=1,color=0,charthick=2,xtickname=yearlab_all,xticks=n_elements(yearlab_all)-1L,charsize=1.5
ybox=[0,10,10,0,0]
x1=imin
nlvls=n_elements(col1)
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
  xbox=[x1,x1,x1+dx,x1+dx,x1]
  polyfill,xbox,ybox,color=col1(j)
  x1=x1+dx
endfor
;
;
; Close PostScript file and return control to X-windows
;
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim omi+cips_area_allyears_'+slat+'.ps -rotate -90 omi+cips_area_allyears_'+slat+'.ps'
;  spawn,'rm -f omi+cips_area_allyears_'+slat+'.ps'
endif

end
