;
; enter altitude and plot MLS CO and GEOS-4 Arctic vortex in time-latitude
; read GEOS-4 based MLS DMPs
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto

sver='v2.2'
;sver='v1.52'

loadct,38
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=[.15]
yorig=[.25]
xlen=0.8
ylen=0.6
cbaryoff=0.08
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
nlat=35L
elatbin=-85+5.*findgen(nlat)

!noeras=1
dirm='/aura6/data/MLS_data/Datfiles_SOSST/'
idir='/aura6/data/GEOS4_data/Analysis/'
dir='/aura7/harvey/GEOS4_data/Datfiles/DAS.flk.asm.tavg3d_mis_e.GEOS403.MetO.'
rd_geos5_nc3_meto,dir+'20060101_1200.V01.nc3',nc,nr,nth,alon,alat,th,$
   pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag	; get th

restore,file='geos4_elat_time_co_vs_edge_20060101-20061028_nh.sav'
nday=n_elements(sdateyt)
nday=120
sdate0=sdateyt(0)
sdate1=sdateyt(nday-1)
sdateyt=sdateyt(0:nday-1)
markyt3d=reform(markyt(0:nday-1,*,*))
coyt3d=reform(coyt(0:nday-1,*,*))
;
; loop over theta
;
for kk=0L,nth-1L do begin
    rlev=th(kk)
    zindex=where(th eq rlev)
    ilev=zindex(0)
    slev=strcompress(th(ilev),/remove_all)+'K'
;
; save postscript version
;
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='elat_time_co_vs_edge_'+sdate0+'-'+sdate1+'_'+slev+'.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
    endif
;
; polar plot
;
    erase
    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    xindex=where(strmid(sdateyt,6,2) eq '15')
    xlabs=strmid(sdateyt(xindex),4,2)
    syr1=strmid(sdateyt(0),0,4)
    syr2=strmid(sdateyt(nday-1),0,4)
    coyt=reform(coyt3d(*,*,kk))
imin=min(coyt)
imax=max(coyt)
if imax eq 0. then goto,jumplev
nlvls=21
    level=imin+((imax-imin)/float(nlvls))*findgen(nlvls)
    col1=1+indgen(nlvls)*icolmax/nlvls
    markyt=reform(markyt3d(*,*,kk))
    contour,coyt,findgen(nday),elatbin,color=0,/noeras,charsize=1.5,title='MLS CO + GEOS-4 Vortex '+slev,$
              /fill,c_color=col1,levels=level,yrange=[0.,90.],ytitle='Equivalent Latitude',xtickname=xlabs,$
              xtickv=xindex,xticks=n_elements(xindex)-1,charthick=2,xtitle='Time'
    markyt=smooth(markyt,3)
    contour,markyt,findgen(nday),elatbin,/overplot,levels=[0.5],color=0,thick=8,/noeras,/follow,c_labels=[0]
    xyouts,nday-20,2.,syr1,charsize=3,charthick=3,color=0,/data
    set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    omin=min(level)
    omax=max(level)
    plot,[omin,omax],[0,0],yrange=[0,10],$
          xrange=[omin,omax],xtitle='Carbon Monoxide (ppmv)',/noeras,$
          xstyle=1,charsize=1.5,color=0,charthick=2
    ybox=[0,10,10,0,0]
    x1=omin
    dx=(omax-omin)/float(nlvls)
    for j=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(j)
        x1=x1+dx
    endfor
    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert -trim elat_time_co_vs_edge_'+sdate0+'-'+sdate1+'_'+slev+'.ps -rotate -90 '+$
                           'elat_time_co_vs_edge_'+sdate0+'-'+sdate1+'_'+slev+'.jpg'
    endif
jumplev:
endfor
end
