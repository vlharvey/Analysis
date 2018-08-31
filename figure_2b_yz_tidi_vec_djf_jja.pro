;
; plot zonal mean multi-year seasonal averages DJF/JJA 
;
@read_tidi_vec
@kdate
@rd_merra_nc3

loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax
setplot='ps'
read,'setplot=',setplot
nxdim=750
nydim=750
xorig=[0.15,0.6]
yorig=[0.3,0.3]
xlen=0.35
ylen=0.4
cbaryoff=0.1
cbarydel=0.02
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif

mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'
dir2='/atmos/harvey/MERRA2_data/Datfiles/MERRA2-on-WACCM_theta_'

nlat=19L
latbin=-85+10.*findgen(nlat)
dy=(latbin(1)-latbin(0))/2.

stime=['00','06','12','18']
ntime=n_elements(stime)

goto,quick

ncfiles=file_search('/atmos/aura3/data/TIDI_data/Datfiles/20??/TIDI_PB_20*_P0100_S0450_D011_R01.VEC')
nfile=n_elements(ncfiles)
icount=0L
icount2=0L
for ifile=0L,nfile-1L do begin
    ncfile=ncfiles(ifile)
;
; extract the date
;
    dum0=strsplit(ncfile,'/',/extract)
    dum1=strsplit(dum0(6),'_',/extract)
    datedoy=dum1(2)
    iyr=strmid(datedoy,0,4)
    doy=strmid(datedoy,4,3)
    kdate,float(doy),iyr,imn,idy
    syr=string(FORMAT='(I4)',iyr)
    smn=string(FORMAT='(I2.2)',imn)
    sdy=string(FORMAT='(I2.2)',idy)
    sdate=syr+smn+sdy
;
; skip if not DJF or JJA
;
    if smn ne '01' and smn ne '02' and smn ne '12' and smn ne '06' and smn ne '07' and smn ne '08' then goto,jumpall
;
; DJF
;
    if smn eq '01' or smn eq '02' or smn eq '12' then begin

    read_tidi_vec,ncfile,nvec,nalts,ut_date,lat,lon,sza,alt_retrieved,time,$
         ms_time,ut_time,rec_index,data_ok,lst,lza,mlat,mlon,track,table_id,$
         measure_track,flight_dir,ascending,in_saa,u1,var_u1,v1,var_v1
    if max(u1) eq -9999.00 then goto,jump	; many days with no data
    ut_seconds=ut_time/1000.
    ut_hours=ut_seconds/60./60.
    sut_date=strcompress(string(ut_date),/remove_all)
    sjdate=sut_date(0)
    if sjdate eq '' then goto,jump
print,ncfile,max(u1)
;help,nvec,nalts,ut_date,lat,lon,sza,alt_retrieved,time,$
;         ms_time,ut_time,rec_index,data_ok,lst,lza,mlat,mlon,track,table_id,$
;         measure_track,flight_dir,ascending,in_saa,u1,var_u1,v1,var_v1

    nvec=n_elements(data_ok)
    in_saa=reform(in_saa)
    sin_saa=strarr(nvec) 
    for i=0L,nvec-1L do sin_saa(i)=string(in_saa(i))
    sdata_ok=strarr(nvec)
    for i=0L,nvec-1L do sdata_ok(i)=string(DATA_OK(i))
    warm_or_cold=strarr(nvec)
    for i=0L,nvec-1L do warm_or_cold(i)=string(measure_track(i))
;
; read data on sjdate
;
    syr=strmid(sjdate,0,4)
    iyr=long(syr)
    iday=strmid(sjdate,4,3)
    kdate,float(iday),iyr,imn,idy
    smn=string(format='(i2.2)',imn)
    sdy=string(format='(i2.2)',idy)
    syr=string(format='(i4)',iyr)
    sdate=syr+smn+sdy
;
; 2d lon/lat/alt
;
    lon2d=fltarr(NALTS,NVEC)
    lat2d=fltarr(NALTS,NVEC)
    alt2d=fltarr(NALTS,NVEC)
    for k=0L,NALTS-1 do lon2d(k,*)=lon
    for k=0L,NALTS-1 do lat2d(k,*)=lat
    for i=0L,NVEC-1 do alt2d(*,i)=ALT_RETRIEVED
;
; read MERRA2 data today at 12Z
;
file1=dir2+sdate+stime(2)+'.nc3'
dum1=findfile(file1)
if dum1(0) eq '' then goto,jump
ncid=ncdf_open(file1)
ncdf_diminq,ncid,0,name,nr
ncdf_diminq,ncid,1,name,nc
ncdf_diminq,ncid,2,name,nth
alon=fltarr(nc)
alat=fltarr(nr)
thlev=fltarr(nth)
ugrd=fltarr(nr,nc,nth)
zgrd=fltarr(nr,nc,nth)
ncdf_varget,ncid,0,alon
ncdf_varget,ncid,1,alat
ncdf_varget,ncid,2,thlev
ncdf_varget,ncid,5,ugrd
ncdf_varget,ncid,10,zgrd
ncdf_close,ncid

    if icount eq 0L then begin
        tidi_ubar_djf=fltarr(nfile,nlat,nalts)/0.
        merra2_ubar_djf=fltarr(nfile,nr,nth)/0.
        merra2_zbar_djf=fltarr(nfile,nr,nth)/0.
;       tidi_vbar_djf=fltarr(nfile,nlat,nalts)
;       tidi_uvarbar_djf=fltarr(nlat,nalts)
;       tidi_vvarbar_djf=fltarr(nlat,nalts)
        icount=1
    endif
index=where(zgrd eq 0.)		; top unresolved theta level
if index(0) ne -1L then zgrd(index)=0./0.
if index(0) ne -1L then ugrd(index)=0./0.
    merra2_ubar_djf(ifile,*,*)=mean(ugrd,dim=2,/Nan)
    merra2_zbar_djf(ifile,*,*)=mean(zgrd,dim=2,/Nan)
;
; compute zonal mean uu as a function of latbin
;
     for ilev=0L,nalts-1L do begin
         uu=reform(u1(ilev,*))
         vv=reform(v1(ilev,*))
         uu_var=reform(var_u1(ilev,*))
         vv_var=reform(var_v1(ilev,*))

;        index=where(abs(uu) le 200. and abs(vv) le 200. and uu ne 0. and vv ne 0. and warm_or_cold eq 'C' and sdata_ok eq 'T',nprof)
         index=where(uu ne -9999. and uu le 200. and uu_var le 500. and vv ne -9999. and vv le 200. and vv_var le 500. and $
                     warm_or_cold eq 'C' and sdata_ok eq 'T' and sin_saa eq 'F',nprof)
         if index(0) eq -1L then goto,skiplev
         uu=uu(index)
         vv=vv(index)
         lat0=lat(index)
         for j=0L,nlat-1L do begin
             y0=latbin(j)-dy & y1=latbin(j)+dy
             index=where(lat0 ge y0 and lat0 lt y1,npts)
             if index(0) ne -1L then begin
                tidi_ubar_djf(ifile,j,ilev)=total(uu(index))/float(npts)
             endif
         endfor
         skiplev:
     endfor
;
; check
;
    erase
    set_viewport,0.1,0.9,0.1,0.9
    nlvls=21
    level=-100.+10.*findgen(nlvls)
    col1=1+indgen(nlvls)*icolmax/nlvls
    !type=2^2+2^3
    contour,reform(tidi_ubar_djf(ifile,*,*)),latbin,ALT_RETRIEVED,levels=level,c_color=col1,/cell_fill,charsize=2,/noeras,color=0,charthick=2,$
            xtitle='Latitude',ytitle='Altitude (km)',yrange=[30,120],xrange=[-90,90],title=sdate
    index=where(level gt 0.)
    contour,reform(tidi_ubar_djf(ifile,*,*)),latbin,ALT_RETRIEVED,levels=level(index),/foll,charsize=2,/noeras,color=0,charthick=2,/overplot
    index=where(level lt 0.)
    contour,reform(tidi_ubar_djf(ifile,*,*)),latbin,ALT_RETRIEVED,levels=level(index),/foll,charsize=2,/noeras,color=mcolor,charthick=2,/overplot,c_linestyle=5
    contour,reform(merra2_ubar_djf(ifile,*,*)),alat,reform(merra2_zbar_djf(ifile,*,*)),levels=level,c_color=col1,/cell_fill,/overplot
;stop
    endif	; if DJF
    jump:

;
; JJA
;
    if smn eq '06' or smn eq '07' or smn eq '08' then begin

    read_tidi_vec,ncfile,nvec,nalts,ut_date,lat,lon,sza,alt_retrieved,time,$
         ms_time,ut_time,rec_index,data_ok,lst,lza,mlat,mlon,track,table_id,$
         measure_track,flight_dir,ascending,in_saa,u1,var_u1,v1,var_v1
    if max(u1) eq -9999.00 then goto,jumpall       ; many days with no data
    ut_seconds=ut_time/1000.
    ut_hours=ut_seconds/60./60.
    sut_date=strcompress(string(ut_date),/remove_all)
    sjdate=sut_date(0)
    if sjdate eq '' then goto,jumpall
print,ncfile,max(u1)
;help,nvec,nalts,ut_date,lat,lon,sza,alt_retrieved,time,$
;         ms_time,ut_time,rec_index,data_ok,lst,lza,mlat,mlon,track,table_id,$
;         measure_track,flight_dir,ascending,in_saa,u1,var_u1,v1,var_v1

    nvec=n_elements(data_ok)
    in_saa=reform(in_saa)
    sin_saa=strarr(nvec)
    for i=0L,nvec-1L do sin_saa(i)=string(in_saa(i))
    sdata_ok=strarr(nvec)
    for i=0L,nvec-1L do sdata_ok(i)=string(DATA_OK(i))
    warm_or_cold=strarr(nvec)
    for i=0L,nvec-1L do warm_or_cold(i)=string(measure_track(i))
;
; read data on sjdate
;
    syr=strmid(sjdate,0,4)
    iyr=long(syr)
    iday=strmid(sjdate,4,3)
    kdate,float(iday),iyr,imn,idy
    smn=string(format='(i2.2)',imn)
    sdy=string(format='(i2.2)',idy)
    syr=string(format='(i4)',iyr)
    sdate=syr+smn+sdy
;
; 2d lon/lat/alt
;
    lon2d=fltarr(NALTS,NVEC)
    lat2d=fltarr(NALTS,NVEC)
    alt2d=fltarr(NALTS,NVEC)
    for k=0L,NALTS-1 do lon2d(k,*)=lon
    for k=0L,NALTS-1 do lat2d(k,*)=lat
    for i=0L,NVEC-1 do alt2d(*,i)=ALT_RETRIEVED
;
; read MERRA2 data today at 12Z
;
file1=dir2+sdate+stime(2)+'.nc3'
dum1=findfile(file1)
if dum1(0) eq '' then goto,jumpall
ncid=ncdf_open(file1)
ncdf_diminq,ncid,0,name,nr
ncdf_diminq,ncid,1,name,nc
ncdf_diminq,ncid,2,name,nth
alon=fltarr(nc)
alat=fltarr(nr)
thlev=fltarr(nth)
ugrd=fltarr(nr,nc,nth)
zgrd=fltarr(nr,nc,nth)
ncdf_varget,ncid,0,alon
ncdf_varget,ncid,1,alat
ncdf_varget,ncid,2,thlev
ncdf_varget,ncid,5,ugrd
ncdf_varget,ncid,10,zgrd
ncdf_close,ncid

    if icount2 eq 0L then begin
        tidi_ubar_jja=fltarr(nfile,nlat,nalts)/0.
        merra2_ubar_jja=fltarr(nfile,nr,nth)/0.
        merra2_zbar_jja=fltarr(nfile,nr,nth)/0.
;       tidi_vbar_jja=fltarr(nfile,nlat,nalts)
;       tidi_uvarbar_jja=fltarr(nlat,nalts)
;       tidi_vvarbar_jja=fltarr(nlat,nalts)
        icount2=1
    endif
index=where(zgrd eq 0.)         ; top unresolved theta level
if index(0) ne -1L then zgrd(index)=0./0.
if index(0) ne -1L then ugrd(index)=0./0.
    merra2_ubar_jja(ifile,*,*)=mean(ugrd,dim=2,/Nan)
    merra2_zbar_jja(ifile,*,*)=mean(zgrd,dim=2,/Nan)
;
; compute zonal mean uu as a function of latbin
;
     for ilev=0L,nalts-1L do begin
         uu=reform(u1(ilev,*))
         vv=reform(v1(ilev,*))
         uu_var=reform(var_u1(ilev,*))
         vv_var=reform(var_v1(ilev,*))

;        index=where(abs(uu) le 200. and abs(vv) le 200. and uu ne 0. and vv ne 0. and warm_or_cold eq 'C' and sdata_ok eq 'T',nprof)
         index=where(uu ne -9999. and uu le 200. and uu_var le 500. and vv ne -9999. and vv le 200. and vv_var le 500. and $
                     warm_or_cold eq 'C' and sdata_ok eq 'T' and sin_saa eq 'F',nprof)
         if index(0) eq -1L then goto,skiplev2
         uu=uu(index)
         vv=vv(index)
         lat0=lat(index)
         for j=0L,nlat-1L do begin
             y0=latbin(j)-dy & y1=latbin(j)+dy
             index=where(lat0 ge y0 and lat0 lt y1,npts)
             if index(0) ne -1L then begin
                tidi_ubar_jja(ifile,j,ilev)=total(uu(index))/float(npts)
             endif
         endfor
         skiplev2:
     endfor
;
; check
;
    erase
    set_viewport,0.1,0.9,0.1,0.9
    nlvls=21
    level=-100.+10.*findgen(nlvls)
    col1=1+indgen(nlvls)*icolmax/nlvls
    !type=2^2+2^3
    contour,reform(tidi_ubar_jja(ifile,*,*)),latbin,ALT_RETRIEVED,levels=level,c_color=col1,/cell_fill,charsize=2,/noeras,color=0,charthick=2,$
            xtitle='Latitude',ytitle='Altitude (km)',yrange=[30,120],xrange=[-90,90],title=sdate
    index=where(level gt 0.)
    contour,reform(tidi_ubar_jja(ifile,*,*)),latbin,ALT_RETRIEVED,levels=level(index),/foll,charsize=2,/noeras,color=0,charthick=2,/overplot
    index=where(level lt 0.)
    contour,reform(tidi_ubar_jja(ifile,*,*)),latbin,ALT_RETRIEVED,levels=level(index),/foll,charsize=2,/noeras,color=mcolor,charthick=2,/overplot,c_linestyle=5
    contour,reform(merra2_ubar_jja(ifile,*,*)),alat,reform(merra2_zbar_jja(ifile,*,*)),levels=level,c_color=col1,/cell_fill,/overplot
;stop

    endif       ; if JJA

    jumpall:
endfor          ; loop over days
;
; average non Nan points
;
djf_ubar=fltarr(nlat,nalts)/0.
ndjf_ubar=fltarr(nlat,nalts)/0.
jja_ubar=fltarr(nlat,nalts)/0.
njja_ubar=fltarr(nlat,nalts)/0.
for ilev=0L,nalts-1L do begin
    for j=0L,nlat-1L do begin
        ubar=reform( tidi_ubar_djf(*,j,ilev) )
        good=where(finite(ubar) eq 1)
        if good(0) ne -1L then djf_ubar(j,ilev)=mean(ubar(good))
        if good(0) ne -1L then ndjf_ubar(j,ilev)=n_elements(good)

        ubar=reform( tidi_ubar_jja(*,j,ilev) )
        good=where(finite(ubar) eq 1)
        if good(0) ne -1L then jja_ubar(j,ilev)=mean(ubar(good))
        if good(0) ne -1L then njja_ubar(j,ilev)=n_elements(good)
    endfor
endfor

djf_ubar_merra2=fltarr(nr,nth)/0.
jja_ubar_merra2=fltarr(nr,nth)/0.
djf_zbar_merra2=fltarr(nr,nth)/0.
jja_zbar_merra2=fltarr(nr,nth)/0.
for ilev=0L,nth-1L do begin
    for j=0L,nr-1L do begin
        ubar=reform( merra2_ubar_djf(*,j,ilev) )
        good=where(finite(ubar) eq 1)
        if good(0) ne -1L then djf_ubar_merra2(j,ilev)=mean(ubar(good))
        zbar=reform( merra2_zbar_djf(*,j,ilev) )
        good=where(finite(zbar) eq 1)
        if good(0) ne -1L then djf_zbar_merra2(j,ilev)=mean(zbar(good))

        ubar=reform( merra2_ubar_jja(*,j,ilev) )
        good=where(finite(ubar) eq 1)
        if good(0) ne -1L then jja_ubar_merra2(j,ilev)=mean(ubar(good))
        zbar=reform( merra2_zbar_jja(*,j,ilev) )
        good=where(finite(zbar) eq 1)
        if good(0) ne -1L then jja_zbar_merra2(j,ilev)=mean(zbar(good))
    endfor
endfor
;
; omit points with less than 100 obs
;
index=where(ndjf_ubar lt 100.)
if index(0) ne -1L then djf_ubar(index)=0./0.
index=where(njja_ubar lt 100.)
if index(0) ne -1L then jja_ubar(index)=0./0.

save,file='tidi_merra2_djf_jja.sav',nalts,nlat,nr,nth,latbin,ALT_RETRIEVED,alat,thlev,djf_zbar_merra2,djf_ubar_merra2,jja_ubar_merra2,jja_zbar_merra2,jja_ubar,djf_ubar,njja_ubar,ndjf_ubar,$
     tidi_ubar_djf,tidi_ubar_jja,merra2_ubar_djf,merra2_zbar_djf,merra2_ubar_jja,merra2_zbar_jja

quick:
restore,'tidi_merra2_djf_jja.sav'

if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='figure_2b_yz_tidi_vec_djf_jja.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif

erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
nlvls=21
level=-100+10.*findgen(nlvls)
col1=1+indgen(nlvls)*icolmax/nlvls
!type=2^2+2^3
contour,jja_ubar,latbin,ALT_RETRIEVED,levels=level,c_color=col1,/cell_fill,charsize=2,/noeras,color=0,charthick=2,$
        xtitle='Latitude',ytitle='Altitude (km)',yrange=[30,120],xrange=[-90,90],title='JJA',xticks=6
index=where(level gt 0.)
contour,jja_ubar,latbin,ALT_RETRIEVED,levels=level(index),/foll,charsize=2,/noeras,color=0,charthick=2,/overplot
index=where(level lt 0.)
contour,jja_ubar,latbin,ALT_RETRIEVED,levels=level(index),/foll,charsize=2,/noeras,color=mcolor,charthick=2,/overplot,c_linestyle=5
;contour,njja_ubar,latbin,ALT_RETRIEVED,levels=100.+100.*findgen(20),/foll,charsize=2,/noeras,color=0,charthick=2,/overplot,thick=3

contour,jja_ubar_merra2,alat,jja_zbar_merra2,levels=level,c_color=col1,/cell_fill,charsize=2,/noeras,color=0,/overplot
index=where(level gt 0.)
contour,jja_ubar_merra2,alat,jja_zbar_merra2,levels=level(index),/foll,charsize=2,/noeras,color=0,charthick=2,/overplot
index=where(level lt 0.)
contour,jja_ubar_merra2,alat,jja_zbar_merra2,levels=level(index),/foll,charsize=2,/noeras,color=mcolor,charthick=2,/overplot,c_linestyle=5

xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
nlvls=21
level=-100+10.*findgen(nlvls)
col1=1+indgen(nlvls)*icolmax/nlvls
!type=2^2+2^3
contour,djf_ubar,latbin,ALT_RETRIEVED,levels=level,c_color=col1,/cell_fill,charsize=2,/noeras,color=0,charthick=2,$
        xtitle='Latitude',yrange=[30,120],xrange=[-90,90],title='DJF',xticks=6
index=where(level gt 0.)
contour,djf_ubar,latbin,ALT_RETRIEVED,levels=level(index),/foll,charsize=2,/noeras,color=0,charthick=2,/overplot
index=where(level lt 0.)
contour,djf_ubar,latbin,ALT_RETRIEVED,levels=level(index),/foll,charsize=2,/noeras,color=mcolor,charthick=2,/overplot,c_linestyle=5
;contour,ndjf_ubar,latbin,ALT_RETRIEVED,levels=100.+100.*findgen(20),/foll,charsize=2,/noeras,color=0,charthick=2,/overplot,thick=3

contour,djf_ubar_merra2,alat,djf_zbar_merra2,levels=level,c_color=col1,/cell_fill,charsize=2,/noeras,color=0,/overplot
index=where(level gt 0.)
contour,djf_ubar_merra2,alat,djf_zbar_merra2,levels=level(index),/foll,charsize=2,/noeras,color=0,charthick=2,/overplot
index=where(level lt 0.)
contour,djf_ubar_merra2,alat,djf_zbar_merra2,levels=level(index),/foll,charsize=2,/noeras,color=mcolor,charthick=2,/overplot,c_linestyle=5

imin=min(level)
imax=max(level)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb(0)  +cbarydel
set_viewport,min(xorig),max(xorig)+xlen,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,charsize=1.5,$
      xtitle='Zonal Wind (m/s)',charthick=2
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(j)
    x1=x1+dx
endfor

if setplot ne 'ps' then stop	;wait,1.
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim figure_2b_yz_tidi_vec_djf_jja.ps -rotate -90 figure_2b_yz_tidi_vec_djf_jja.jpg'
;  spawn,'rm -f figure_2b_yz_tidi_vec_djf_jja.ps'
endif
end
