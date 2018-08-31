@stddat
@kgmt
@ckday
@kdate
@rd_waccm_nc3

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
!NOERAS=-1
device,decompose=0
nxdim=700
nydim=700
xorig=[0.1]
yorig=[0.35]
xlen=0.8
ylen=0.8
cbaryoff=0.08
cbarydel=0.02
!NOERAS=-1
lstmn=1
lstdy=1
lstyr=1990
ledmn=1
leddy=4
ledyr=2004
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
print, ' '
print, '      ECMWF Version '
print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 57 then lstyr=lstyr+2000
if ledyr lt 57 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1957 then stop,'Year out of range '
if ledyr lt 1957 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

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
mon=['jan','feb','mar','apr','may','jun',$
     'jul','aug','sep','oct','nov','dec']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
!noeras=1
dir='/aura7/harvey/WACCM_data/Datfiles/TNV3_files/wa3_tnv3_'

; Compute initial Julian date
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
      if iyr ge 2000L then iyr1=iyr-2000L
      if iyr lt 2000L then iyr1=iyr-1900L
      date=strcompress(string(FORMAT='(A3,A1,I2,A2,I4)',$
                              month(imn-1),' ',idy,', ',iyr))
      ifile=string(FORMAT='(i4.4,i2.2,i2.2,a4)',iyr,imn,idy,'.nc3')
      rd_waccm_nc3,dir+ifile,nc,nr,nth,alon,alat,th,pv2,p2,$
         u2,v2,qdf2,mark2,vp2,sf2,o32,ch42,noy2,iflag
      if iflag eq 1 then goto,jump

; select theta level
    if icount eq 0L then begin
       rlev=1000.
;      print,th
;      read,'Enter theta surface ',rlev
       zindex=where(th eq rlev)
       ilev=zindex(0)
       slev=strcompress(string(fix(th(ilev))),/remove_all)+'K'
       icount=1L
    endif

; save postscript version
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='Figures/'+ifile+'_sh_ho3_'+slev+'.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif

    mark1=transpose(mark2(*,*,ilev))
    sf1=transpose(sf2(*,*,ilev))
print,min(sf1(*,0:nr/2))
sfmin=min(sf1(*,0:nr/2))+0.1*abs(min(sf1(*,0:nr/2)))
    o31=transpose(o32(*,*,ilev))*1.e6
    sf=0.*fltarr(nc+1,nr)
    sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
    sf(nc,*)=sf(0,*)
    mark=0.*fltarr(nc+1,nr)
    mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
    mark(nc,*)=mark(0,*)
    o3=0.*fltarr(nc+1,nr)
    o3(0:nc-1,0:nr-1)=o31(0:nc-1,0:nr-1)
    o3(nc,*)=o3(0,*)
    x=fltarr(nc+1)
    x(0:nc-1)=alon
    x(nc)=alon(0)+360.
    erase
    xyouts,.15,.9,strmid(ifile,0,8),charsize=2,/normal,color=0
    xmn=0.0
    xmx=0.5
    ymn=0.35
    ymx=0.8
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    MAP_SET,-90,0,180,/stereo,/noeras,/grid,/contin,title=slev,charsize=1.5,color=0,/noborder
    oplot,findgen(361),0.1+0.*findgen(361)
    nlvls=19
    level=1.0+0.5*findgen(nlvls)
    col1=1+indgen(nlvls)*icolmax/nlvls
    contour,o3,x,alat,/overplot,levels=level,c_color=col1,$
           /cell_fill,/noeras
;   contour,o3,x,alat,/overplot,levels=level,/follow,c_labels=0*level,/noeras,color=0
    contour,sf,x,alat,/overplot,nlevels=30,color=0
    contour,sf,x,alat,/overplot,levels=[sfmin],color=0,thick=7
    contour,mark,x,alat,/overplot,levels=[0.1],thick=7,color=mcolor
    MAP_SET,-90,0,180,/stereo,/noeras,/grid,/contin,charsize=1.5,color=0,/noborder

    rlat=-31.25
    oplot,findgen(361),rlat+0.*findgen(361),color=mcolor,psym=8,symsize=0.2
    rlat=-41.25
    oplot,findgen(361),rlat+0.*findgen(361),color=mcolor,psym=8,symsize=0.2
    rlat=-51.25
    oplot,findgen(361),rlat+0.*findgen(361),color=mcolor,psym=8,symsize=0.2

    rlat=-51.25
    zindex=where(rlat eq alat)
    ilat=zindex(0)
    slat=strcompress(string(fix(alat(ilat))),/remove_all)
    markxz=0.*fltarr(nc+1,nth)
    markxz(0:nc-1,0:nth-1)=reform(mark2(ilat,0:nc-1,0:nth-1))
    markxz(nc,*)=markxz(0,*)
    o3xz=0.*fltarr(nc+1,nth)
    o3xz(0:nc-1,0:nth-1)=reform(o32(ilat,0:nc-1,0:nth-1))*1.e6
    o3xz(nc,*)=o3xz(0,*)
    xmn=0.6
    xmx=0.9
    ymn=0.75
    ymx=0.95
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    contour,o3xz,x,th,levels=level,/cell_fill,title='WACCM '+slat+' S',c_color=col1,$
            min_value=0.,xticks=4,xrange=[0.,360.],yrange=[500.,1800.],$
            ytitle='Theta',xtitle='Longitude',color=0
    contour,o3xz,x,th,levels=findgen(nlvls),/follow,/overplot,color=0,min_value=0.
    contour,smooth(markxz,3),x,th,levels=[ 0.1],/follow,/overplot,color=mcolor,thick=3
;   contour,markxz,x,th,levels=[-0.1],/follow,/overplot,color=mcolor,thick=3
    rlat=-41.25
    zindex=where(rlat eq alat)
    ilat=zindex(0)
    slat=strcompress(string(fix(alat(ilat))),/remove_all)
    markxz=0.*fltarr(nc+1,nth)
    markxz(0:nc-1,0:nth-1)=reform(mark2(ilat,0:nc-1,0:nth-1))
    markxz(nc,*)=markxz(0,*)
    o3xz=0.*fltarr(nc+1,nth)
    o3xz(0:nc-1,0:nth-1)=reform(o32(ilat,0:nc-1,0:nth-1))*1.e6
    o3xz(nc,*)=o3xz(0,*)
    xmn=0.6
    xmx=0.9
    ymn=0.45
    ymx=0.65
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    contour,o3xz,x,th,levels=level,/cell_fill,title='WACCM '+slat+' S',c_color=col1,$
            min_value=0.,xticks=4,xrange=[0.,360.],yrange=[500.,1800.],$
            ytitle='Theta',xtitle='Longitude',color=0
    contour,o3xz,x,th,levels=findgen(nlvls),/follow,/overplot,color=0,min_value=0.
    contour,smooth(markxz,3),x,th,levels=[ 0.1],/follow,/overplot,color=mcolor,thick=3
    rlat=-31.25
    zindex=where(rlat eq alat)
    ilat=zindex(0)
    slat=strcompress(string(fix(alat(ilat))),/remove_all)
    markxz=0.*fltarr(nc+1,nth)
    markxz(0:nc-1,0:nth-1)=reform(mark2(ilat,0:nc-1,0:nth-1))
    markxz(nc,*)=markxz(0,*)
    o3xz=0.*fltarr(nc+1,nth)
    o3xz(0:nc-1,0:nth-1)=reform(o32(ilat,0:nc-1,0:nth-1))*1.e6
    o3xz(nc,*)=o3xz(0,*)
    xmn=0.6
    xmx=0.9
    ymn=0.15
    ymx=0.35
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    contour,o3xz,x,th,levels=level,/cell_fill,title='WACCM '+slat+' S',c_color=col1,$
            min_value=0.,xticks=4,xrange=[0.,360.],yrange=[500.,1800.],$
            ytitle='Theta',xtitle='Longitude',color=0
    contour,o3xz,x,th,levels=findgen(nlvls),/follow,/overplot,color=0,min_value=0.
    contour,smooth(markxz,3),x,th,levels=[ 0.1],/follow,/overplot,color=mcolor,thick=3
    imin=min(level)
    imax=max(level)
    ymnb=ymn-cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,xmn,xmx,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle='Ozone (ppmv)',charsize=1.5,color=0
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(nlvls)
    for j=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(j)
        x1=x1+dx
    endfor

    if setplot ne 'ps' then wait,.5
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert -trim Figures/'+ifile+'_sh_ho3_'+slev+'.ps -rotate -90 Figures/'+ifile+'_sh_ho3_'+slev+'.jpg'
    endif
wait,.5
goto, jump

end
