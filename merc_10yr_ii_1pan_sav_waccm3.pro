;
; plot mercator projection of 10 year monthly mean ii frequency
; 12 panel at each theta level
;
nxdim=750
nydim=750
xorig=[0.1]
yorig=[0.2]
xlen=0.8
ylen=0.6
cbaryoff=0.02
cbarydel=0.02
loadct,38
mcolor=!p.color
mcolor=byte(!p.color)
device,decompose=0
icmm1=mcolor-1B
icmm2=mcolor-2B
!NOERAS=-1
nxdim=800
nydim=800
a=findgen(8)*(2*!pi/8.)
usersym,.5*cos(a),.5*sin(a),/fill
!psym=0
setplot='x'
read,'setplot ',setplot
if setplot ne 'ps' then begin
   lc=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
months=['Dec','Jan','Feb','Mar','Apr','May',$
        'Jun','Jul','Aug','Sep','Oct','Nov']
mon=['dec','jan','feb','mar','apr','may',$
     'jun','jul','aug','sep','oct','nov']
ifiles=[$
'wa3_tnv3_ii_dec_avg.sav',$
'wa3_tnv3_ii_jan_avg.sav',$
'wa3_tnv3_ii_feb_avg.sav',$
'wa3_tnv3_ii_mar_avg.sav',$
'wa3_tnv3_ii_apr_avg.sav',$
'wa3_tnv3_ii_may_avg.sav',$
'wa3_tnv3_ii_jun_avg.sav',$
'wa3_tnv3_ii_jul_avg.sav',$
'wa3_tnv3_ii_aug_avg.sav',$
'wa3_tnv3_ii_sep_avg.sav',$
'wa3_tnv3_ii_oct_avg.sav',$
'wa3_tnv3_ii_nov_avg.sav']
nmonth=n_elements(mon)
dir='/aura7/harvey/WACCM_data/Datfiles/Datfiles_TNV3/'
;for m=0,nmonth-1 do begin
for m=0,0 do begin
    ifile=ifiles(m)
    print,ifile
    restore,dir+ifile
for thlev=0,nth-1 do begin
    stheta=strcompress(string(fix(th(thlev))),/remove_all)
    if setplot eq 'ps' then begin
       lc=0
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       set_plot,'ps'
       device,/color,/landscape,bits=8,filename='wa3_10yr_ii_1pan_'+mon(m)+'_'+stheta+'K.ps'
       device,/bold
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
       xsize=xsize,ysize=ysize
    endif

; mercator plots of monthly mean zonal mean frequency
; of inertial instability
    plt1=100.*transpose(reform(ii_mean(*,*,thlev),nr,nc))
    plt=fltarr(nc+1,nr)
    plt(0:nc-1,0:nr-1)=plt1
    plt(nc,*)=plt(0,*)
    x=fltarr(nc+1)
    x(0:nc-1)=alon
    x(nc)=x(0)
    x2d=0.0*fltarr(nc+1,nr)
    y2d=0.0*fltarr(nc+1,nr)
    for j=0,nc do y2d(j,*)=alat
    for k=0,nr-1 do x2d(*,k)=x
    !type=2^2+2^3
    erase
    set_viewport,xorig(0),xorig(0)+xlen,yorig(0),yorig(0)+ylen
    !psym=0
    MAP_SET,0,0,0,/contin,/grid,/noeras,charsize=2,$
            title=months(m)+' WACCM3 at '+stheta+' K',limit=[-60,0,60,360]
    level=[0.1,0.5,1.0,1.5,2.,2.5,3.,3.5,4.,4.5,5.,6.,7.,8.,9.,10.,$
           11.,12.,13.,14.,15.,$
           16.,17.,18.,19.,20.,25.,30.,40.,50.,60.,70.,80.,90.,100.]
    nlvls=n_elements(level)
    col1=3+indgen(nlvls)*mcolor/nlvls
;   col1(0:4)=3
    contour,plt,x,alat,levels=level,/fill,/cell_fill,/overplot,c_color=col1,/noeras
    contour,plt,x,alat,levels=[5],c_labels=[0],/follow,/overplot,color=0,thick=3
    MAP_SET,0,0,0,/contin,/noeras,limit=[-60,0,60,360],mlinethick=1
    xyouts,-180.,-60.,'60S',/data,alignment=1.,charsize=2
    xyouts,-180.,-30.,'30S',/data,alignment=1.,charsize=2
    xyouts,-180.,0.,'EQ',/data,alignment=1.,charsize=2
    xyouts,-180.,30.,'30N',/data,alignment=1.,charsize=2
    xyouts,-180.,60.,'60N',/data,alignment=1.,charsize=2
plots,xorig(0),yorig(0)+ylen/2.0,/normal
plots,xorig(0)+xlen,yorig(0)+ylen/2.0,/continue,/normal,color=mcolor
!psym=0
imin=min(level)
imax=max(level)
set_viewport,xorig(0),xorig(0)+xlen,yorig(0)-cbaryoff,yorig(0)-cbaryoff+cbarydel
!type=2^2+2^3+2^6
xlabels=['.1','.5','1','2','3','4','5','6','7','8','9',$
         '10','12','14','16','18','20','30','50','75','100']
xpos=float(xlabels)
nxticks=n_elements(xpos)-1
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,$
       xstyle=1,xticks=nxticks,xtickname=xlabels,charsize=1.5,$
;xtickv=xpos,$
        xtitle='Percent of the Time Regions are Inertially Unstable'
ybox=[0,10,10,0,0]
x2=imin
dx=(imax-imin)/float(nlvls-1)
for j=1,nlvls-1 do begin
    xbox=[x2,x2,x2+dx,x2+dx,x2]
    polyfill,xbox,ybox,color=col1(j)
    x2=x2+dx
endfor
if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim wa3_10yr_ii_1pan_'+mon(m)+'_'+stheta+'K.ps'+$
         ' -rotate -90 wa3_10yr_ii_1pan_'+mon(m)+'_'+stheta+'K.jpg'
   spawn,'/usr/bin/rm wa3_10yr_ii_1pan_'+mon(m)+'_'+stheta+'K.ps'
endif
ENDFOR          ; loop over months
endfor	; loop over theta
end
