;
; plot the location of HALOE, SAGE II, SAGE III, POAM III, and ILAS
; VLH	4/1/03
;
@rd_ukmo_nc3
@rd_haloe_merged_data
@rd_sage2_merged_data
@rd_sage3_merged_data
@rd_poam_merged_data
@rd_ilas_merged_data

loadct,38
mcolor=byte(!p.color)
device,decompose=0
icmm1=mcolor-1B
icmm2=mcolor-2B
nlev=21
col1=indgen(nlev)*mcolor/nlev
!noeras=1
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
setplot='ps'
;read,'enter setplot',setplot
xorig=.15
yorig=.25
xlen=.7
ylen=.4
cbaryoff=0.03
cbarydel=0.02
nxdim=700
nydim=700
lc=mcolor
if setplot ne 'ps' then $
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
dirh='/aura3/data/HALOE_data/Merged_data/'
dirs='/aura3/data/SAGE_II_data/Merged_data/'
dirs3='/aura3/data/SAGE_III_data/Merged_data/'
dirp='/aura3/data/POAM_data/Merged_data/'
diri='/aura3/data/ILAS_data/Merged_data/'
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'

infile=[$
'ukmo_1991.fil'$
;'ukmo_1992.fil',$
;'ukmo_1993.fil',$
;'ukmo_1994.fil',$
;'ukmo_1995.fil',$
;'ukmo_1996.fil',$
;'ukmo_1997.fil',$
;'ukmo_1998.fil',$
;'ukmo_1999.fil',$
;'ukmo_2000.fil',$
;'ukmo_2001.fil',$
;'ukmo_2002.fil',$
;'ukmo_2003.fil',$
;'ukmo_2004.fil'$
]
nyear=n_elements(infile)
for iyear=0,nyear-1 do begin
filename=''
nday=0L
close,2
openr,2,infile(iyear)
readf,2,nday
for iday=0,nday-1 do begin
    readf,2,filename
    if strmid(filename,7,1) eq '9' then syear='19'+strmid(filename,7,2)
    if strmid(filename,7,1) eq '0' then syear='20'+strmid(filename,7,2)
;
; read UKMO data
;
    rd_ukmo_nc3,dir+filename+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag
    x=fltarr(nc+1)
    x(0:nc-1)=alon
    x(nc)=alon(0)+360.
    x2d=fltarr(nc+1,nr)
    y2d=fltarr(nc+1,nr)
    for i=0,nc do y2d(i,*)=alat
    for j=0,nr-1 do x2d(*,j)=x
    kindex=where(th eq 1000.)
    itheta=kindex(0)
    rtheta=th(kindex(0))
    stheta=strcompress(string(fix(rtheta)),/remove_all)+'K'
    pv1=transpose(pv2(*,*,itheta))
    p1=transpose(p2(*,*,itheta))
    sf1=transpose(sf2(*,*,itheta))
    mark1=transpose(marksf2(*,*,itheta))
    pv=fltarr(nc+1,nr)
    pv(0:nc-1,0:nr-1)=pv1
    pv(nc,*)=pv(0,*)
    p=fltarr(nc+1,nr)
    p(0:nc-1,0:nr-1)=p1
    p(nc,*)=p(0,*)
    sf=fltarr(nc+1,nr)
    sf(0:nc-1,0:nr-1)=sf1
    sf(nc,*)=sf(0,*)
    mark=fltarr(nc+1,nr)
    mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
    mark(nc,*)=mark(0,*)
;
; read HALOE data
;
    ifile='haloe_'+strmid(filename,0,7)+syear+'.merged'
    hdum=findfile(dirh+ifile)
    hcount=0L
    if hdum(0) eq '' then goto,jumphaloe
    close,4
    openr,4,dirh+ifile
    rd_haloe_merged_data,yymmdd,ncount,thal,xhal,yhal,thhal,xsathal,ysathal,$
       phal,zhal,ptrhal,ztrhal,thtrhal,clhal,mhal,ch4hal,hfhal,h2ohal,$
       o3hal,hclhal,no2hal,nohal,aerhal,ech4hal,ehfhal,eh2ohal,eo3hal,$
       ehclhal,eno2hal,enohal,eaerhal,here1,here2,here3,here4,halcomp,$
       haldens,halmedr,haldisw,halconc,halsurf,halvolu,haleffr
    close,4
    if ncount eq 0L then goto,jumphaloe
    index=where(thhal eq 1000. and o3hal gt 0.,hcount)
    xhal=xhal(index)
    yhal=yhal(index)
    ch4hal=ch4hal(index)*1.e6
    hfhal=hfhal(index)*1.e6
    h2ohal=h2ohal(index)*1.e6
    o3hal=o3hal(index)*1.e6
    aerhal=aerhal(index)
    print,'merged file is '+ifile,hcount
    jumphaloe:
;
; read SAGE II data
;
    ifile='sage2_'+strmid(filename,0,7)+syear+'.merged'
    sdum=findfile(dirs+ifile)
    scount=0L
    if sdum(0) eq '' then goto,jumpsage
    close,4
    openr,4,dirs+ifile
    rd_sage2_merged_data,yymmdd,ncount,tsage,xsage,ysage,thsage,$
        xsatsage,ysatsage,psage,zsage,ptrsage,ztrsage,thtrsage,clsage,msage,h2osage,$
        o3sage,no2sage,extasage,sadsage,eh2osage,eo3sage,eno2sage,eextasage,esadsage
    close,4
    if ncount eq 0L then goto,jumpsage
    index=where(thsage eq 1000. and o3sage gt 0.,scount)
    xsage=xsage(index)
    ysage=ysage(index)
    h2osage=h2osage(index)*1.e6
    o3sage=o3sage(index)*1.e6
    sadsage=sadsage(index)
    print,'merged file is '+ifile,scount
    jumpsage:
;
; read SAGE III data
;
    ifile='sage3_'+strmid(filename,0,7)+syear+'.merged'
    sdum=findfile(dirs3+ifile)
    scount3=0L
    if sdum(0) eq '' then goto,jumpsage3
    close,4
    openr,4,dirs3+ifile
    rd_sage3_merged_data,yymmdd,ncount,tsage3,xsage3,ysage3,thsage3,$
        dsatsage3,psage3,zsage3,ptrsage3,ztrsage3,thtrsage3,$
        clsage3,msage3,h2osage3,o3sage3,no2sage3,extasage3,sadsage3,$
        eh2osage3,eo3sage3,eno2sage3,eextasage3,esadsage3
    close,4
    if ncount eq 0L then goto,jumpsage3
    index=where(thsage3 eq 1000. and o3sage3 gt 0.,scount3)
    xsage3=xsage3(index)
    ysage3=ysage3(index)
    h2osage3=h2osage3(index)*1.e6
    o3sage3=o3sage3(index)*1.e6
    sadsage3=sadsage3(index)
    print,'merged file is '+ifile,scount3
    jumpsage3:
;
; read POAM data
;
    ifile='poam3_'+strmid(filename,0,7)+syear+'.merged'
    ifile2='poam2_'+strmid(filename,0,7)+syear+'.merged'
    sdum=findfile(dirp+ifile)
    sdum2=findfile(dirp+ifile2)
    pcount=0L
    if sdum(0) eq '' and sdum2(0) eq '' then goto,jumppoam
    close,4
    if sdum(0) ne '' then openr,4,dirp+ifile
    if sdum2(0) ne '' then openr,4,dirp+ifile2
    rd_poam_merged_data,yymmdd,ncount,tpoam,xpoam,ypoam,thpoam,$
        xsatpoam,ysatpoam,ppoam,zpoam,ptrpoam,ztrpoam,thtrpoam,$
        clpoam,mpoam,h2opoam,pvpoam,o3poam,no2poam,aerpoam,eh2opoam,$
        eo3poam,eno2poam,eaerpoam
    close,4
    if ncount eq 0L then goto,jumppoam
    index=where(thpoam eq 1000. and o3poam gt 0.,pcount)
    if index(0) eq -1 then goto,jumppoam
    xpoam=xpoam(index)
    ypoam=ypoam(index)
    h2opoam=h2opoam(index)*1.e6
    o3poam=o3poam(index)*1.e6
    aerpoam=aerpoam(index)
    if sdum(0) ne '' then print,'merged file is '+ifile,pcount
    if sdum2(0) ne '' then print,'merged file is '+ifile2,pcount
    jumppoam:
;
; read ILAS data
;
    ifile='ilas_'+strmid(filename,0,7)+syear+'.merged'
    sdum=findfile(diri+ifile)
    icount=0L
    if sdum(0) eq '' then goto,jumpilas
    close,4
    openr,4,diri+ifile
    rd_ilas_merged_data,yymmdd,ncount,tilas,xilas,yilas,thilas,$
       satilas,pilas,zilas,ptrilas,ztrilas,thtrilas,clilas,milas,$
       h2oilas,o3ilas,no2ilas,eh2oilas,eo3ilas,eno2ilas
    close,4
    if ncount eq 0L then goto,jumpilas
    index=where(thilas eq 1000. and o3ilas gt 0.,icount)
    xilas=xilas(index)
    yilas=yilas(index)
    h2oilas=h2oilas(index)*1.e6
    o3ilas=o3ilas(index)*1.e6
    if sdum(0) ne '' then print,'merged file is '+ifile,icount
    jumpilas:
    syymmdd=strcompress(string(yymmdd),/remove_all)
;
; plot
;
    if setplot eq 'ps' then begin
       lc=0
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/color,/landscape,bits=8,$
              filename='merc_ukmo+occul_'+syymmdd+'_'+stheta+'.ps'
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
               xsize=xsize,ysize=ysize
    endif
    erase
    !type=2^2+2^3
    set_viewport,xorig,xorig+xlen,yorig,yorig+ylen
    MAP_SET,0,180,0,/contin,/grid,/noeras,color=lc,charsize=2,$
            title=filename+'               '+stheta
    contour,sf,x,alat,nlevels=30,c_color=lc,/overplot,/follow,$
            c_labels=0,/noeras
    contour,mark,x,alat,levels=[0.,1.],c_color=lc,/overplot,/follow,$
            c_labels=0,/noeras,thick=3
    index=where(mark gt 0.)
    if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=2,color=lc
    index=where(mark lt 0.)
    if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=4,color=lc
    o3min=2.0
    o3max=11.
    if hcount gt 0L then begin
       a=findgen(9)*(2*!pi/8.)
       usersym,2.*cos(a),2.*sin(a),/fill
       for i=0,hcount-1 do $
           oplot,[xhal(i),xhal(i)],[yhal(i),yhal(i)],$
                 psym=8,color=mcolor*(o3hal(i)-o3min)/(o3max-o3min)
       a=findgen(9)*(2*!pi/8.)
       usersym,2.*cos(a),2.*sin(a)
       oplot,xhal,yhal,psym=8,color=mcolor
    endif
    if scount gt 0L then begin
       a=findgen(5)*(2*!pi/4.)
       usersym,2.*cos(a),2.*sin(a),/fill
       for i=0,scount-1 do $
           oplot,[xsage(i),xsage(i)],[ysage(i),ysage(i)],$
                 psym=8,color=mcolor*(o3sage(i)-o3min)/(o3max-o3min)
       a=findgen(5)*(2*!pi/4.)
       usersym,2.*cos(a),2.*sin(a)
       oplot,xsage,ysage,psym=8,color=mcolor
    endif
    if scount3 gt 0L then begin
       a=findgen(6)*(2*!pi/5.)
       usersym,2.*cos(a),2.*sin(a),/fill
       for i=0,scount3-1 do $
           oplot,[xsage3(i),xsage3(i)],[ysage3(i),ysage3(i)],symsize=1.5,$
                 psym=8,color=mcolor*(o3sage3(i)-o3min)/(o3max-o3min)
       a=findgen(6)*(2*!pi/5.)
       usersym,2.*cos(a),2.*sin(a)
       oplot,xsage3,ysage3,psym=8,color=mcolor,symsize=1.5
    endif
    if pcount gt 0L then begin
       a=findgen(4)*(2*!pi/3.)
       usersym,2.*cos(a),2.*sin(a),/fill
       for i=0,pcount-1 do $
           oplot,[xpoam(i),xpoam(i)],[ypoam(i),ypoam(i)],symsize=1.5,$
                 psym=8,color=mcolor*(o3poam(i)-o3min)/(o3max-o3min)
       a=findgen(4)*(2*!pi/3.)
       usersym,2.*cos(a),2.*sin(a)
       oplot,xpoam,ypoam,psym=8,color=mcolor,symsize=1.5
    endif
    if icount gt 0L then begin
       a=findgen(4)*(2*!pi/3.)
       usersym,2.*cos(a),2.*sin(a),/fill
       for i=0,icount-1 do $
           oplot,[xilas(i),xilas(i)],[yilas(i),yilas(i)],symsize=1.5,$
                 psym=8,color=mcolor*(o3ilas(i)-o3min)/(o3max-o3min)
       a=findgen(4)*(2*!pi/3.)
       usersym,2.*cos(a),2.*sin(a)
       oplot,xilas,yilas,psym=8,color=mcolor,symsize=1.5
    endif
    set_viewport,xorig,xorig+xlen,yorig-cbaryoff,yorig-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    imin=o3min
    imax=o3max
    plot,[imin,imax],[0,0],yrange=[0,10],$
         xrange=[imin,imax],/noeras,ystyle=1,$
         xstyle=1,yticks=1,xtitle='Ozone (ppmv)',$
         ytickname=[' ',' '],charsize=2
    ybox=[0,10,10,0,0]
    x2=imin
    dx=(imax-imin)/float(nlev-1)
    for j=1,nlev-1 do begin
        xbox=[x2,x2,x2+dx,x2+dx,x2]
        polyfill,xbox,ybox,color=col1(j)
        x2=x2+dx
    endfor

    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert merc_ukmo+occul_'+syymmdd+'_'+stheta+'.ps -rotate -90 '+$
                     'Mark+occul/merc_ukmo+occul_'+syymmdd+'_'+stheta+'.jpg'
       spawn,'/usr/bin/rm merc_ukmo+occul_'+syymmdd+'_'+stheta+'.ps'
    endif
endfor
endfor
end
