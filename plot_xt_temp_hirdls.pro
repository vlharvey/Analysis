;
; plot longitude-time sections of HIRDLS Temperature
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
dir='/aura2/harvey/Hovmoller/Datfiles/hirdls_'
spawn,'ls '+dir+'*alt_xt.sav',ifiles
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
        for j=29,29 do begin
            if alat(j) eq 0. then slat='Eq'
            if alat(j) gt 0. then slat=strcompress(alat(j),/remove_all)+'N'
            if alat(j) lt 0. then slat=strcompress(alat(j),/remove_all)+'S'
            if setplot eq 'ps' then begin
               lc=0
               set_plot,'ps'
               xsize=nxdim/100.
               ysize=nydim/100.
               !p.font=0
               device,font_size=9
               device,/landscape,bits=8,filename='hov_Tmark_'+sth+'km_'+slat+'_'+sfile(0)+'_hirdls.ps'
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
            mtitle='HIRDLS Temperature '+sth+' km '+slat
            plt=reform(tmpxt(*,*,j,k),nc,nfile)
            imin=min(plt)
            imax=max(plt)
            if abs(imin) eq 0. and abs(imax) eq 0. then goto,jump2
            nlvls=19
            col1=1+indgen(nlvls)*icolmax/nlvls
            level=180.+5.*findgen(nlvls)
            index=where(strmid(sfile,6,2) eq '15',nytick)
            contour,plt,alon,findgen(nfile),xrange=[0.,360.],/fill,$
                    /cell_fill,yrange=[nfile-1,0L],xstyle=1,ystyle=1,xticks=6,$
                    yticks=nytick-1,ytickv=index,ytickname=sfile(index),$
                    xtitle='Longitude',c_color=col1,$
                    title=mtitle,/noeras,levels=level,charsize=2
            contour,plt,alon,findgen(nfile),/overplot,/follow,levels=level,$
                    c_color=0,c_labels=0*level,/noeras
            ymnb=yorig-cbaryoff
            ymxb=ymnb +cbarydel
            set_viewport,xmn,xmx,ymnb,ymxb
            !type=2^2+2^3+2^6
imin=min(level)
imax=max(level)
            plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,charsize=1.5,xtitle='(K)'
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
               spawn,'convert -trim hov_Tmark_'+sth+'km_'+slat+'_'+sfile(0)+'_hirdls.ps '+$
                     '-rotate -90 hov_Tmark_'+sth+'km_'+slat+'_'+sfile(0)+'_hirdls.jpg'
            endif
            if setplot ne 'ps' then stop
            jump2:
        endfor
     endfor
;endfor
endfor
end
