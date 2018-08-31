;
; plot the location of HALOE, POAM III, SAGE II, and SAGE III, and ILAS occultations 
;
loadct,38
mcolor=byte(!p.color)
device,decompose=0
icmm1=mcolor-1B
icmm2=mcolor-2B
nlev=21
col1=10.+indgen(nlev)*mcolor/nlev
!noeras=1
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
setplot='ps'
npp=16
delta='n'
gcm_panels,npp,delta,nxdim,nydim,xorig,yorig,xlen,ylen,cbaryoff,cbarydel
lc=mcolor
if setplot ne 'ps' then $
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/color,/landscape,bits=8,filename='haloe_sage2+3_poam_ilas_sweeps_1992-2004.ps'
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
           xsize=xsize,ysize=ysize
endif
ufile=[$
'ukmo_1992.fil',$
'ukmo_1993.fil',$
'ukmo_1994.fil',$
'ukmo_1995.fil',$
'ukmo_1996.fil',$
'ukmo_1997.fil',$
'ukmo_1998.fil',$
'ukmo_1999.fil',$
'ukmo_2000.fil',$
'ukmo_2001.fil',$
'ukmo_2002.fil',$
'ukmo_2003.fil',$
'ukmo_2004.fil'$
]
nyear=n_elements(ufile)
sfile=[$
'haloe_sage2+3_poam_ilas_sweeps_1992.dat',$
'haloe_sage2+3_poam_ilas_sweeps_1993.dat',$
'haloe_sage2+3_poam_ilas_sweeps_1994.dat',$
'haloe_sage2+3_poam_ilas_sweeps_1995.dat',$
'haloe_sage2+3_poam_ilas_sweeps_1996.dat',$
'haloe_sage2+3_poam_ilas_sweeps_1997.dat',$
'haloe_sage2+3_poam_ilas_sweeps_1998.dat',$
'haloe_sage2+3_poam_ilas_sweeps_1999.dat',$
'haloe_sage2+3_poam_ilas_sweeps_2000.dat',$
'haloe_sage2+3_poam_ilas_sweeps_2001.dat',$
'haloe_sage2+3_poam_ilas_sweeps_2002.dat',$
'haloe_sage2+3_poam_ilas_sweeps_2003.dat',$
'haloe_sage2+3_poam_ilas_sweeps_2004.dat'$
]
syear=['1992','1993','1994','1995','1996','1997',$
       '1998','1999','2000','2001','2002','2003',$
       '2004']
for iyear=0,nyear-1 do begin
;
; read year of dates
;
    filename=''
    nday=0L
    close,2
    openr,2,ufile(iyear)
    readf,2,nday
    sdate=strarr(nday)
    for iday=0,nday-1 do begin
        readf,2,filename
        sdate(iday)=filename
    endfor
    close,2
;
; read year of sweep locations
;
    close,10
    openr,10,'../Datfiles/'+sfile(iyear)
    print,sfile(iyear)
    hcount=0L
    readf,10,hcount
    if hcount gt 0L then begin
       th=fltarr(hcount)
       yh=fltarr(hcount)
       readf,10,th,yh
    endif
    scount2=0L
    readf,10,scount2
    if scount2 gt 0L then begin
       ts2=fltarr(scount2)
       ys2=fltarr(scount2)
       readf,10,ts2,ys2
    endif
    scount3=0L
    readf,10,scount3
    if scount3 gt 0L then begin
       ts3=fltarr(scount3)
       ys3=fltarr(scount3)
       readf,10,ts3,ys3
    endif
    pcount=0L
    readf,10,pcount
    if pcount gt 0L then begin
       tp=fltarr(pcount)
       yp=fltarr(pcount)
       readf,10,tp,yp
    endif
    icount=0L
    readf,10,icount
    if icount gt 0L then begin
       ti=fltarr(icount)
       yi=fltarr(icount)
       readf,10,ti,yi
    endif
    close,10

    !type=2^2+2^3
    xmn=xorig(iyear)
    xmx=xorig(iyear)+xlen
    ymn=yorig(iyear)
    ymx=yorig(iyear)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    alat=-90.+findgen(181)
    if iyear eq 0 or iyear eq 4 or iyear eq 8 then begin
    plot,1+findgen(nday),alat,yticks=6,xrange=[1,nday],yrange=[-90.,90.],$
         xticks=11,/nodata,charsize=1.5,title=syear(iyear),ytitle='Latitude',$
         xtickname=['J','F','M','A','M','J','J','A','S','O','N','D']
    endif
    if iyear ne 0 or iyear ne 4 or iyear ne 8 then begin
    plot,1+findgen(nday),alat,yticks=6,xrange=[1,nday],yrange=[-90.,90.],$
         xticks=11,/nodata,charsize=1.5,title=syear(iyear),$
         xtickname=['J','F','M','A','M','J','J','A','S','O','N','D'],$
         ytitle=' ',ytickname=[' ',' ',' ',' ',' ',' ',' ']
    endif

    if hcount gt 0L then oplot,th,yh,psym=8,color=mcolor*.9,symsize=0.5
    if scount2 gt 0L then oplot,ts2,ys2,psym=8,color=mcolor*.35,symsize=0.5
    if scount3 gt 0L then oplot,ts3,ys3,psym=8,color=mcolor*.65,symsize=0.5
    if pcount gt 0L then oplot,tp,yp,psym=8,color=mcolor*.31,symsize=0.5
    if icount gt 0L then oplot,ti,yi,psym=8,color=lc,symsize=0.5
endfor
xyouts,.15,.95,'SAGE II,',charsize=2.5,/normal,color=mcolor*.35
xyouts,.28,.95,'HALOE,',charsize=2.5,/normal,color=mcolor*.9
xyouts,.40,.95,'POAM II/III,',charsize=2.5,/normal,color=mcolor*.31
xyouts,.57,.95,'ILAS,',charsize=2.5,/normal,color=lc
xyouts,.66,.95,'SAGE III',charsize=2.5,/normal,color=mcolor*.65

if setplot eq 'ps' then begin
   device,/close
   spawn,'convert haloe_sage2+3_poam_ilas_sweeps_1992-2004.ps -rotate -90 '+$
                 'haloe_sage2+3_poam_ilas_sweeps_1992-2004.jpg'
endif
end
