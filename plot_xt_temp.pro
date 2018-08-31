;
; plot longitude-time sections of MetO Temperature, Anticyclones, Polar vortices, and a trajectory
; loop over latitudes and altitudes
;
loadct,38
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
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
pi2 = 6.2831853071796
dtr=pi2/360.
re=6.37E3
dir='/aura2/harvey/Hovmoller/Datfiles/ukmo_'
spawn,'ls '+dir+'*nc3_xt.sav',ifiles
nyear=n_elements(ifiles)
for n=0,nyear-1L do begin 
    restore,ifiles(n)
    nfile=n_elements(sfile)
    nth=n_elements(th2)
    nr=n_elements(YMIDS)
    nc=n_elements(alon)
    x2d=fltarr(nc,nfile)
    y2d=fltarr(nc,nfile)
    for i=0,nc-1 do y2d(i,*)=findgen(nfile)
    for j=0,nfile-1 do x2d(*,j)=alon
;
; plot Hovs at different latitudes and altitudes
;
    for k=0,nth-1 do begin
        sth=strcompress(string(fix(th2(k))),/remove_all)
        for j=0,nr-1 do begin
            if ymids(j) eq 0. then slat='Eq'
            if ymids(j) gt 0. then slat=strcompress(string(ymids(j)),/remove_all)+'N'
            if ymids(j) lt 0. then slat=strcompress(string(ymids(j)),/remove_all)+'S'
            if setplot eq 'ps' then begin
               lc=0
               set_plot,'ps'
               xsize=nxdim/100.
               ysize=nydim/100.
               !p.font=0
               device,font_size=9
               device,/landscape,bits=8,filename='hov_Tmark_'+sth+'K_'+slat+'_'+sfile(0)+'.ps'
               device,/color
               device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                      xsize=xsize,ysize=ysize
            endif
            erase
            xmn=xorig(0)
            xmx=xorig(0)+xlen
            ymn=yorig(0)
            ymx=yorig(0)+ylen
            !type=2^2+2^3
            set_viewport,xmn,xmx,ymn,ymx
            mtitle='UKMO Temperature '+sth+' K '+slat
            plt=reform(tmpxt(*,*,j,k),nc,nfile)
            plt1=smooth(reform(markxt(*,*,j,k),nc,nfile),3)
            uplt=reform(uxt(*,*,j,k),nc,nfile)
            imin=min(plt)
            imax=max(plt)
imin=230.
imax=290.
            if abs(imin) eq 0. and abs(imax) eq 0. then goto,jump2
            nlev=10
            col1=1.0+(findgen(nlev)/nlev)*mcolor
            cint=(imax-imin)/(nlev-1)
            level=imin+cint*findgen(nlev)
            index=where(strmid(sfile,4,2) eq '01',nytick)
            contour,plt,alon,findgen(nfile),xrange=[0.,360.],/fill,$
                    /cell_fill,yrange=[0,nfile-1L],xstyle=1,ystyle=1,xticks=6,$
                    yticks=nytick-1,ytickv=index,ytickname=sfile(index),$
                    xtitle='!6Longitude',ytitle='!6Time',c_color=col1,$
                    title=mtitle,/noeras,levels=level,charsize=2
;           contour,plt,alon,findgen(nfile),/overplot,/follow,levels=level,$
;                   c_color=0,c_labels=0*level,/noeras
            contour,plt1,alon,findgen(nfile),/overplot,/follow,levels=[-0.01],$
                    c_color=0,c_labels=0,thick=2,/noeras
            contour,plt1,alon,findgen(nfile),/overplot,/follow,levels=[0.01],$
                    c_color=mcolor,c_labels=0,thick=2,/noeras
            index=where(plt1 lt 0.)
            if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=0,symsize=0.1
            index=where(plt1 gt 0.)
            if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=mcolor,symsize=0.1
;
; start parcel at the GM and loop over days
;
            xold=0.
            oplot,[xold,xold],[0,0],psym=8,symsize=0.75
            for nn=0L,nfile-1L do begin
;
; daily zonal wind at parcel location
;
                xindex=where(abs(xold-alon) eq min(abs(xold-alon)))
                uu=uplt(xindex(0),nn)
                dkm=uu*86400./1000.
                dx=re*cos(ymids(j)*dtr)*360.*dtr               ; km around latitude circle
                xnew=xold+ (dkm/dx)*360.
                if xnew gt 360. then xnew=xnew-360.
                if xnew lt 0. then xnew=xnew+360.
                if uu gt 0. then oplot,[xnew,xnew],[nn,nn],psym=8,color=mcolor,symsize=0.75
                if uu lt 0. then oplot,[xnew,xnew],[nn,nn],psym=8,color=0,symsize=0.75
                xold=xnew
            endfor
            xyouts,xmn,ymn-0.08,'Anticyclone (black)',charsize=2,/normal,color=lc
            xyouts,xmn+0.45,ymn-0.08,'Polar Vortex (white)',charsize=2,/normal,color=lc
            ymnb=yorig-cbaryoff
            ymxb=ymnb +cbarydel
            set_viewport,xmn,xmx,ymnb,ymxb
            !type=2^2+2^3+2^6
            plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,charsize=1.5
            ybox=[0,10,10,0,0]
            x1=imin
            dx=(imax-imin)/float(nlev)
            for jj=0,nlev-1 do begin
                xbox=[x1,x1,x1+dx,x1+dx,x1]
                polyfill,xbox,ybox,color=col1(jj)
                x1=x1+dx
            endfor
            if setplot eq 'ps' then begin
               device, /close
               spawn,'convert -trim hov_Tmark_'+sth+'K_'+slat+'_'+sfile(0)+'.ps '+$
                     '-rotate -90 hov_Tmark_'+sth+'K_'+slat+'_'+sfile(0)+'.jpg'
            endif
            if setplot ne 'ps' then stop
            jump2:
        endfor
     endfor
;endfor
endfor
end
