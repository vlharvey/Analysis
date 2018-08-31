;
; latitude-time plots of U, Mark, wbarstar - 300 year annual averages
;
loadct,39
mcolor=byte(!p.color)
icmm1=mcolor-1B
icmm2=mcolor-2B
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
!NOERAS=-1
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.15]
yorig=[0.25]
xlen=0.7
ylen=0.5
cbaryoff=0.1
cbarydel=0.01
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/atmos/harvey/WACCM_data/Datfiles/Datfiles_Ethan_600yr/CO2x1SmidEmax_yBWCN/3d_CO2x1SmidEmax_yBWCN_'
smonth=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
nmonth=n_elements(smonth)

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
;
; build MMDD dates
;
spawn,'ls '+dir+'????.sav',ifiles
ndays=n_elements(ifiles)
;
; loop over days of the year
;
mmdd=strarr(ndays)
for iday=0,ndays-1 do begin
;
; restore daily mean of all years
;
    ofile=ifiles(iday)
    result=strsplit(ofile,'_',/extract)
    result2=strsplit(result(-1),'.',/extract)
    mmdd(iday)=result2(0)
    print,'reading '+ofile
    restore,ofile	;,nc,nr,nth,alon,alat,th,ipvavg,pavg,uavg,vavg,qdfavg,coavg,zavg,sfavg,mavg,$
	                   ;	ipvsig,psig,usig,vsig,qdfsig,cosig,zsig,sfsig,msig

    if iday eq 0L then begin
       tyt=fltarr(ndays,nr)
       uyt=fltarr(ndays,nr)
       myt=fltarr(ndays,nr)
       zyt=fltarr(ndays,nr)
       coyt=fltarr(ndays,nr)
       wstaryt=fltarr(ndays,nr)
       vstaryt=fltarr(ndays,nr)

       zprof=mean(zavg,dim=1)
       zprof=mean(zprof,dim=1)
       ralt=40.
       print,zprof
       read,'Enter desired altitude ',ralt
       index=where(abs(zprof-ralt) eq min(abs(zprof-ralt)))
       ialt=index(0)
       salt=strcompress(long(ralt),/r)+'km'
;goto,quick
    endif
;
; calculate temp
;
    tavg=0*pavg
    for k=0,nth-1 do tavg(*,*,k) = th(k)*( (pavg(*,*,k)/1000.)^(.286) )
;
; calculate zonal means
;
    uyz=mean(uavg,dim=2)
    coyz=mean(coavg,dim=2)
    zyz=mean(zavg,dim=2)
    myz=mean(mavg,dim=2)
    tyz=mean(tavg,dim=2)
;
; extract daily means in the polar regions
;
    tyt(iday,*)=reform(tyz(*,ialt))
    uyt(iday,*)=reform(uyz(*,ialt))
    myt(iday,*)=reform(myz(*,ialt))
    zyt(iday,*)=reform(zyz(*,ialt))
    coyt(iday,*)=reform(coyz(*,ialt))
endfor
;
; save file
;
save,file='yt_TUMark_smidemax_'+salt+'.sav',ndays,nr,alat,mmdd,tyt,uyt,myt,zyt,coyt
quick:
restore,'yt_TUMark_smidemax_'+salt+'.sav'
;
; postscript file
;
    if setplot eq 'ps' then begin
       lc=0
       xsize=nxdim/100.
       ysize=nydim/100.
       !p.font=0
       set_plot,'ps'
       device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
              /bold,/color,bits_per_pixel=8,/helvetica,filename='figure_5_yt_TUMark_smidemax.ps'
       !p.charsize=1
       !p.thick=2
       !p.charthick=2
       !y.thick=2
       !x.thick=2
    endif
;
; shift NH to put winter in the middle
;
;tnhshift=0.*tnh
;znhshift=0.*znh
;unhshift=0.*unh
;mnhshift=0.*mnh
;tnhshift(0:183,*)=reform(tnh(181:364,*))	; July-Dec
;tnhshift(184:364,*)=reform(tnh(0:180,*))	; Jan-July
;znhshift(0:183,*)=reform(znh(181:364,*))        ; July-Dec
;znhshift(184:364,*)=reform(znh(0:180,*))        ; Jan-July
;unhshift(0:183,*)=reform(unh(181:364,*))        ; July-Dec
;unhshift(184:364,*)=reform(unh(0:180,*))        ; Jan-July
;mnhshift(0:183,*)=reform(mnh(181:364,*))        ; July-Dec
;mnhshift(184:364,*)=reform(mnh(0:180,*))        ; Jan-July
;
; plot
;
    x2d=0.*tyt
    for k=0L,nth-1L do x2d(*,k)=findgen(ndays)
    smon=strmid(mmdd,0,2)
    sday=strmid(mmdd,2,2)
    xindex=where(sday eq '15',nxticks)
    xlabs=smon(xindex)
    erase
    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    nlvls=25
    tlevel=-120+10*findgen(nlvls)	;[130+5*findgen(nlvls),280,300,320,350,400,450,500]
    nlvls=n_elements(tlevel)
    col1=(findgen(nlvls)/float(nlvls))*mcolor
    contour,uyt,findgen(ndays),alat,/noera,/fill,color=0,c_color=col1,levels=tlevel,xrange=[0,ndays-1],yrange=[-90,90],ytitle='Latitude',charsize=1,charthick=2,$
            xticks=nxticks-1,xtickname=xlabs,xtickv=xindex
index=where(tlevel gt 0.)
    contour,uyt,findgen(ndays),alat,/noera,/follow,color=0,levels=tlevel(index),/overplot
index=where(tlevel lt 0.)
    contour,uyt,findgen(ndays),alat,/noera,/follow,color=mcolor,levels=tlevel(index),/overplot,c_linestyle=5
myt=smooth(myt,3,/edge_truncate)
    contour,myt,findgen(ndays),alat,/noera,/foll,color=0,thick=15,levels=[0.1,0.3,0.5,0.7,0.9],/overplot
    contour,myt,findgen(ndays),alat,/noera,/foll,color=mcolor,thick=15,levels=[-0.9,-0.7,-0.5,-0.3,-0.1],/overplot
;
; horizontal color bar
;
!type=2^2+2^3+2^6
x0=xmn
x1=xmx
y0=ymn-0.1
y1=ymn-0.05
level=tlevel
nlvls  = n_elements(level)

col1 = (1 + indgen(nlvls)) * 255. / nlvls    ; define colors
slab=' '+strarr(nlvls)
plot,[0,0],[0,0],yrange=[0,10],xrange=[0,1],/noeras,xticks=nlvls-1L,$
        position = [x0,y0,x1,y1],xstyle=1,xtickname=slab,/nodata,color=0
xyouts,(x0+x1)/3.,y0-0.03,salt+' Zonal Wind (m/s)',color=0,charsize=1.25,charthick=2,/normal
slab=strcompress(string(format='(i4)',long(level)),/remove_all)
slabcolor = fltarr(nlvls)*0.
slabcolor[0:10] = 255        ; set first few labels to white so they are visible
ybox=[0,10,10,0,0]
x2=0
dx= 1./(nlvls-1.)
x1=dx/2 ; center of first color level
for j=0,nlvls-2 do begin
    xbox=[x2,x2,x2+dx,x2+dx,x2]
    polyfill,xbox,ybox,color=col1[j]
    x2=x2+dx
    i=j
;   if j mod 2 eq 0 then xyouts,x1-dx/2.,5,slab(i),charsize=1.1,charthick=2,/data,color=slabcolor[i], orientation= -90.,align = .5
    x1=x1+dx
endfor
dx= 1./(nlvls-1.)
x1=dx/2 ; center of first color level
for j=0,nlvls-2 do begin
    i=j
    if j mod 2 eq 0 then xyouts,x1-dx/2.,5,slab(i),charsize=1.1,charthick=2,/data,color=slabcolor[i], orientation= -90.,align = .5
    x1=x1+dx
endfor
;
; Close PostScript file and return control to X-windows
;
    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim figure_5_yt_TUMark_smidemax.ps -rotate -90 figure_5_yt_TUMark_smidemax.jpg
;      spawn,'rm -f figure_5_yt_TUMark_smidemax.ps'
    endif

end
