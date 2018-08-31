pro rd_sage2_o3_soundings,sfile,norbit,tsage,xsage,ysage,$
           tropp,tropz,tropth,mode,o3sage,psage,thsage,zsage,$
           clsage,qo3sage,nl
month=['jan','feb','mar','apr','may','jun',$
       'jul','aug','sep','oct','nov','dec']
mday=[31,28,31,30,31,30,31,31,30,31,30,31]
norbit=0L
dum=findfile(sfile)
if dum(0) eq '' then return
close,4
openr,4,sfile
readf,4,norbit
print,'reading ',sfile,norbit
if norbit eq 0 then return
tsage=fltarr(norbit)
xsage=fltarr(norbit)
ysage=fltarr(norbit)
tropp=fltarr(norbit)
tropz=fltarr(norbit)
tropth=fltarr(norbit)
mode=lonarr(norbit)
for i=0,norbit-1 do begin
    x=0.
    y=0.
    xs=0.
    ys=0.
    t=0.
    p_trop=0.
    z_trop=0.
    th_trop=0.
    m=0L
    readf,4,t,y,x,xs,ys,p_trop,z_trop,th_trop,m
    tsage(i)=t
    xsage(i)=x
    if xsage(i) lt 0. then xsage(i)=xsage(i)+360.
    ysage(i)=y
    tropp(i)=p_trop
    tropz(i)=z_trop
    tropth(i)=th_trop
    mode(i)=m
    readf,4,nl
    o3_snd=fltarr(nl) 
    p_snd=fltarr(nl) 
    th_snd=fltarr(nl) 
    z_snd=fltarr(nl) 
    cl_snd=fltarr(nl)
    qo3_snd=fltarr(nl) 
    readf,4,o3_snd
    readf,4,p_snd
    readf,4,th_snd
    readf,4,z_snd
    readf,4,cl_snd
    readf,4,qo3_snd
    if i eq 0 then begin
       o3sage=fltarr(norbit,nl)
       psage=fltarr(norbit,nl)
       thsage=fltarr(norbit,nl)
       zsage=fltarr(norbit,nl)
       clsage=fltarr(norbit,nl)
       qo3sage=fltarr(norbit,nl)
    endif
    o3sage(i,0:nl-1)=o3_snd
    psage(i,0:nl-1)=p_snd
    thsage(i,0:nl-1)=th_snd
    zsage(i,0:nl-1)=z_snd
    clsage(i,0:nl-1)=cl_snd
    qo3sage(i,0:nl-1)=qo3_snd
endfor
close,4
return
end
