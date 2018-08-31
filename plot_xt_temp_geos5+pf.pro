;
; plot longitude-time sections of GEOS-5 Temperature, Anticyclones, Polar vortices, and a trajectory
; loop over latitudes and altitudes
;
loadct,39
device,decompose=0
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
a=findgen(8)*(2*!pi/8.)
usersym,2*cos(a),2*sin(a),/fill
nxdim=800
nydim=800
xorig=[0.2]
yorig=[0.2]
xlen=0.7
ylen=0.7
cbaryoff=0.12
cbarydel=0.02
set_plot,'x'
setplot='x'
read,'setplot=',setplot
!p.background=mcolor
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
pi2 = 6.2831853071796
dtr=pi2/360.
re=6.37E3
dir='/aura2/harvey/Hovmoller/Datfiles/geos5_'
spawn,'ls '+dir+'*01_nc3_xt.sav',ifiles
nyear=n_elements(ifiles)
for n=0,nyear-1L do begin 
    restore,ifiles(n)
    nfile=n_elements(sfile)
    nth2=n_elements(th2)
    nr=n_elements(alat)
    nc=n_elements(alon)
    x2d=fltarr(nc,nfile)
    y2d=fltarr(nc,nfile)
    for i=0,nc-1 do y2d(i,*)=findgen(nfile)
    for j=0,nfile-1 do x2d(*,j)=alon
;
; plot Hovs at different latitudes and altitudes
;
    for k=0,nth2-1 do begin
        sth=strcompress(long(th2(k)),/remove_all)
;       for j=0,nr-1 do begin
        for j=62,62 do begin
            if alat(j) eq 0. then slat='Eq'
            if alat(j) gt 0. then slat=strcompress(string(format='(f5.2)',alat(j)))+'N'
            if alat(j) lt 0. then slat=strcompress(string(format='(f6.2)',alat(j)))+'S'
            if alat(j) gt 0. then slatlab='N'
            if alat(j) lt 0. then slatlab='S'
            if setplot eq 'ps' then begin
               set_plot,'ps'
               xsize=nxdim/100.
               ysize=nydim/100.
               !p.font=0
               device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
                      /bold,/color,bits_per_pixel=8,/helvetica,$
                      filename='hov_Tmark_'+sth+'K_'+slat+'_'+sfile(0)+'_geos5.ps'
               !p.charsize=1.25
               !p.thick=2
               !p.charthick=5
               !p.charthick=5
               !y.thick=2
               !x.thick=2
            endif
            erase
            xmn=xorig(0)
            xmx=xorig(0)+xlen
            ymn=yorig(0)
            ymx=yorig(0)+ylen
            !type=2^2+2^3
            set_viewport,xmn,xmx,ymn,ymx
            mtitle='GEOS-5 '+strcompress(string(format='(f6.2)',alat(j)))+'!uo!n '+slatlab
            plt=reform(tmpxt(*,*,j,k),nc,nfile)
            plt1=smooth(reform(markxt(*,*,j,k),nc,nfile),3)
            uplt=reform(uxt(*,*,j,k),nc,nfile)
            imin=min(plt)
            imax=max(plt)
            if abs(imin) eq 0. and abs(imax) eq 0. then goto,jump2
            nlvls=19
            col1=1+indgen(nlvls)*icolmax/nlvls
            level=180.+5.*findgen(nlvls)
            index=where(strmid(sfile,6,2) eq '01' or strmid(sfile,6,2) eq '15',nytick)
            contour,plt,alon,findgen(nfile),xrange=[0.,360.],/fill,color=0,$
                    /cell_fill,yrange=[nfile-1,0L],xstyle=1,ystyle=1,xticks=6,$
                    yticks=nytick-1,ytickv=index,ytickname=sfile(index),$
                    xtitle='Longitude',c_color=col1,$
                    title=mtitle,/noeras,levels=level,charsize=1.5,charthick=2
            contour,plt,alon,findgen(nfile),/overplot,/follow,levels=level,$
                    c_color=0,c_labels=0*level,/noeras
            contour,smooth(plt1,3,/edge_truncate),alon,findgen(nfile),/overplot,/follow,levels=[0.4],$
                    c_color=0,c_labels=0,thick=15,/noeras
            contour,smooth(plt1,3,/edge_truncate),alon,findgen(nfile),/overplot,/follow,levels=[-0.1],$
                    c_color=mcolor,c_labels=0,thick=15,/noeras
loadct,0
plots,213.,0
plots,213.,nfile-1,color=mcolor*.6,/continue,thick=15
xyouts,213,nfile+2,'PF',color=mcolor*.6,/data,alignment=0.5,charthick=2,charsize=1.5
loadct,39
;
; start parcel at the GM and loop over days
;
;             xold=180.
;             oplot,[xold,xold],[0,0],psym=8,symsize=0.75
;             for nn=0L,nfile-1L do begin
;;
;; daily zonal wind at parcel location
;;
;                 xindex=where(abs(xold-alon) eq min(abs(xold-alon)))
;                 uu=uplt(xindex(0),nn)
;                 dkm=uu*86400./1000.
;                 dx=re*cos(alat(j)*dtr)*360.*dtr               ; km around latitude circle
;                 xnew=xold+ (dkm/dx)*360.
;                 if xnew gt 360. then xnew=xnew-360.
;                 if xnew lt 0. then xnew=xnew+360.
;                 if uu gt 0. then oplot,[xnew,xnew],[nn,nn],psym=8,color=mcolor,symsize=0.75
;                 if uu lt 0. then oplot,[xnew,xnew],[nn,nn],psym=8,color=0,symsize=0.75
;                 if nn gt 0 then if uu gt 0. then oplot,[xold,xnew],[nn-1,nn],psym=0,color=mcolor,thick=2
;                 if nn gt 0 then if uu lt 0. then oplot,[xold,xnew],[nn-1,nn],psym=0,color=0,thick=2
;
;                 xold=xnew
;             endfor
            xyouts,xmn-0.035,ymn-0.08,'Anticyclones (white)',charsize=1.25,/normal,color=0,charthick=2
            xyouts,xmn+0.475,ymn-0.08,'Polar Vortex (black)',charsize=1.25,/normal,color=0,charthick=2
            ymnb=yorig-cbaryoff
            ymxb=ymnb +cbarydel
            set_viewport,xmn,xmx,ymnb,ymxb
            !type=2^2+2^3+2^6
            plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,charsize=1.5,$
                 xtitle=sth+' K Temperature (K)',color=0,charthick=2
            ybox=[0,10,10,0,0]
            x1=imin
            dx=(imax-imin)/float(nlvls)
            for jj=0,nlvls-1 do begin
                xbox=[x1,x1,x1+dx,x1+dx,x1]
                polyfill,xbox,ybox,color=col1(jj)
                x1=x1+dx
            endfor
            if setplot eq 'ps' then begin
               device, /close
               spawn,'convert -trim hov_Tmark_'+sth+'K_'+slat+'_'+sfile(0)+'_geos5.ps '+$
                     '-rotate -90 hov_Tmark_'+sth+'K_'+slat+'_'+sfile(0)+'_geos5.jpg'
            endif
            if setplot ne 'ps' then stop
            jump2:
        endfor
     endfor
;endfor
endfor
end
