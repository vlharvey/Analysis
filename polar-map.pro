;
; polar map

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill

loadct,39
mcolor=!p.color
icolmax=byte(!p.color)
mcolor=icolmax
icmm1=icolmax-1B
icmm2=icolmax-2B
device,decompose=0
nlvls=19
col1=1+indgen(nlvls)*icolmax/nlvls
!NOERAS=-1
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.15]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.02
cbarydel=0.02
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
    erase
    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,90,0,-90,/stereo,/contin,/grid,title=sdate,color=0,/usa,limit=[0.,0.,90.,360.],latdel=30,londel=30,label=1,lonlab=1
    map_continents,/fill_continents,color=150
    map_continents,/countries,color=0,/usa
end
