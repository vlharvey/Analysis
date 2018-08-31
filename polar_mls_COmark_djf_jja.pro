;
; multi-year DJF and JJA YZ of T, U, CO gradient marker
; MLS
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
xorig=[0.15,0.55,0.15,0.55]
yorig=[0.55,0.55,0.15,0.15]
xlen=0.325
ylen=0.325
cbaryoff=0.02
cbarydel=0.01
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/Users/harvey/Harvey_etal_2018/Code/Save_files/daily_mls_coelatedge+merra2_sfelatedge_'
smonth=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
nmonth=n_elements(smonth)
;
; get lon,lat information
;
restore,'smidemax_300-year_TUmark_djf_jja.sav

goto,quick
;
; file listing of MLS CO marker files
;
spawn,'ls '+dir+'*.sav',ifiles
nfile=n_elements(ifiles)
;
; loop over files
;
icount=0L
for ifile=0L,nfile-1L do begin
    result=strsplit(ifiles(ifile),'_',/extract)
    yyyymm=result(-3)
    smon=strmid(yyyymm,4,2)
    imon=long(smon)

    if imon ne 1 and imon ne 2 and imon ne 12 and imon ne 6 and imon ne 7 and imon ne 8 then goto,skipmonth		; DJF and JJA only
;   if imon ne 1 and imon ne 7 then goto,skipmonth		; Jan/Jul only
;
; restore monthly data
;
; DELATLEVS3D     FLOAT     = Array[30, 91, 37]
; HLATPDF_TIME_3D FLOAT     = Array[30, 46, 37]
; LLATPDF_TIME_3D FLOAT     = Array[30, 46, 37]
; LOWLAT_ELATEDGE_2D FLOAT     = Array[30, 37]
; LOWLAT_ELATINNER_2D FLOAT     = Array[30, 37]
; LOWLAT_ELATOUTER_2D FLOAT     = Array[30, 37]
; MARKMLS4D       FLOAT     = Array[144, 96, 37, 30]
; MARKSFELATEDGE_2D FLOAT     = Array[30, 37]
; NASHELATEDGE_2D FLOAT     = Array[30, 37]
; NASHINNER_2D    FLOAT     = Array[30, 37]
; NASHOUTER_2D    FLOAT     = Array[30, 37]
; NOVORTEX_FLAG_2D FLOAT     = Array[30, 37]
; PMLS            FLOAT     = Array[37]
; SDATE_TIME      STRING    = Array[30]
; SFELATEDGE_2D   FLOAT     = Array[30, 37]
; SFMARKEDGE_2D   FLOAT     = Array[30, 37]
; SPBIN3D         FLOAT     = Array[30, 91, 37]
; YEQ             FLOAT     = Array[91]
;
        print,ifiles(ifile)
        restore,ifiles(ifile)
        mavg2=mean(MARKMLS4D,dim=4)	; average over days in the month
; 
; declare DJF and JJA arrays
;
        if icount eq 0L then begin
           djf_markco_mls=0.*mavg2
           jja_markco_mls=0.*mavg2
           ndjf_markco_mls=0.*mavg2
           njja_markco_mls=0.*mavg2
           icount=1L
        endif
;
; DJF
;
    if smon eq '12' or smon eq '01' or smon eq '02' then begin
       djf_markco_mls=djf_markco_mls+mavg2
       ndjf_markco_mls=ndjf_markco_mls+1.
    endif
;
; JJA
;
    if smon eq '06' or smon eq '07' or smon eq '08' then begin
       jja_markco_mls=jja_markco_mls+mavg2
       njja_markco_mls=njja_markco_mls+1.
    endif

skipmonth:
endfor  ; loop over files

djf_markco_mls=djf_markco_mls/ndjf_markco_mls
jja_markco_mls=jja_markco_mls/njja_markco_mls
;
; need height information
;
restore,'mls_djf_jja.sav
zindex=0.*press55
for k = 0,n_elements(PRESS55)-1 do begin
    index = where(press37 eq press55(k))
    if index(0) ne -1 then zindex(k) = 1.0
endfor
good=where(zindex eq 1.0)
ZBAR_colev_DJF=ZBAR_DJF(*,good)/1000.
ZBAR_colev_JJA=ZBAR_JJA(*,good)/1000.
;
; save 3d DJF and JJA CO-Mark
;
save,file='mls_COmark_djf_jja.sav',nc,nr,nth,alon,alat,th,djf_markco_mls,jja_markco_mls,ZBAR_colev_DJF,ZBAR_colev_JJA
quick:
restore,'mls_COmark_djf_jja.sav'
;
; calculate zonal means
;
djf_markcoyz=mean(djf_markco_mls,dim=1)
jja_markcoyz=mean(jja_markco_mls,dim=1)
;
; strip out level from 3d arrays
;
zprof=reform(ZBAR_colev_DJF(-1,*))
zindex=where(finite(zprof))
zprof=reform(zprof(zindex))
djf_markco_mls=reform(djf_markco_mls(*,*,zindex))	; truncate arrays where altitude is finite
jja_markco_mls=reform(jja_markco_mls(*,*,zindex))
print,zprof
ralt=90.
read,'Enter desired altitude level ',ralt
index=where(abs(zprof-ralt) eq min(abs(zprof-ralt)))
ialt=index(0)
salt=strcompress(zprof(ialt),/r)+'km'
markdjf2d=reform(djf_markco_mls(*,*,ialt))
markjja2d=reform(jja_markco_mls(*,*,ialt))
;
; plot
;
if setplot eq 'ps' then begin
   lc=0
   !p.font=0
   xsize=nxdim/100.
   ysize=nydim/100.
   set_plot,'ps'
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
           /bold,/color,bits_per_pixel=8,/helvetica,filename='polar_multi-year_djf_jja_COMark_mls_'+salt+'.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
;
; DJF
;
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
nlvls=10
tlevel=0.1+0.1*findgen(nlvls)
nlvls=n_elements(tlevel)
col1=(findgen(nlvls)/float(nlvls-1))*mcolor
col1(-1)=col1(-1)-1
myz=jja_markcoyz
zyz=ZBAR_colev_JJA
contour,myz,alat,zyz,/noera,/cell_fill,color=0,c_color=col1,levels=tlevel,xrange=[-90,0],yrange=[20,80],ytitle='Altitude (km)',charsize=1.5,charthick=2,title='JJA',xticks=6
contour,myz,alat,zyz,/noera,/foll,color=0,levels=tlevel,/overplot

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
myz_swap=myz	; jja
for k=0,n_elements(PRESS37)-1L do myz_swap(*,k)=reverse(myz(*,k))
myz=djf_markcoyz	;-myz_swap
;tlevel=-.5+0.1*findgen(nlvls)
zyz=ZBAR_colev_DJF
contour,myz,alat,zyz,/noera,/cell_fill,color=0,c_color=col1,levels=tlevel,xrange=[0,90],yrange=[20,80],charsize=1.5,charthick=2,title='DJF',xticks=6
contour,myz,alat,zyz,/noera,/foll,color=0,levels=tlevel,/overplot

!type=2^2+2^3
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
map_set,-90,0,-90,/ortho,/contin,/grid,/noeras,color=0,title=strcompress(long(ralt),/r)+'km'
contour,markjja2d,alon,alat,/noera,/cell_fill,color=0,c_color=col1,levels=tlevel,/overplot
contour,markjja2d,alon,alat,/noera,/foll,color=0,levels=tlevel,/overplot
map_set,-90,0,-90,/ortho,/contin,/grid,/noeras,color=0

!type=2^2+2^3
xmn=xorig(3)
xmx=xorig(3)+xlen
ymn=yorig(3)
ymx=yorig(3)+ylen
set_viewport,xmn,xmx,ymn,ymx
map_set,90,0,-90,/ortho,/contin,/grid,/noeras,color=0,title=strcompress(long(ralt),/r)+'km'
contour,markdjf2d,alon,alat,/noera,/cell_fill,color=0,c_color=col1,levels=tlevel,/overplot
contour,markdjf2d,alon,alat,/noera,/foll,color=0,levels=tlevel,/overplot
map_set,90,0,-90,/ortho,/contin,/grid,/noeras,color=0

imin=min(tlevel)
imax=max(tlevel)
set_viewport,min(xorig),xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],$
      xrange=[imin,imax],xtitle='MLS CO Gradient Vortex',/noeras,$
      xstyle=1,charsize=1.5,color=0
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(j)
    x1=x1+dx
endfor
;
; Close PostScript file and return control to X-windows
;
if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim polar_multi-year_djf_jja_COMark_mls_'+salt+'.ps -rotate -90 polar_multi-year_djf_jja_COMark_mls_'+salt+'.jpg'
;  spawn,'rm -f polar_multi-year_djf_jja_COMark_mls_'+salt+'.ps'
endif

end
