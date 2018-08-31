;
; load color table
;
loadct,38
icolmax=byte(!p.color)
icmm1=icolmax-1
icmm2=icolmax-2
nlvls=20
col1=1+indgen(nlvls)*icolmax/nlvls
;
; define viewport location 
;
nxdim=750
nydim=750
xorig=[0.1]
yorig=[0.15]
xlen=0.8
ylen=0.8
cbaryoff=0.08
cbarydel=0.01
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
plot,findgen(10),findgen(10),/nodata,/noeras
;
; draw color bar
;
level=findgen(100)
imin=min(level)
imax=max(level)
ymnb=yorig(0)-cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(j)
    x1=x1+dx
endfor

end
