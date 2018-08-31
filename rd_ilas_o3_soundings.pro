pro rd_ilas_o3_soundings,sfile,norbit,tilas,xilas,yilas,$
       tropp,tropz,tropth,mode,o3ilas,pilas,thilas,zilas,$
       clilas,qo3ilas,nl
norbit=0L
dum=findfile(sfile)
if dum(0) eq '' then return
close,4
openr,4,sfile
readf,4,norbit
;print,'reading ',sfile,norbit
if norbit eq 0 then return
tilas=fltarr(norbit)
xilas=fltarr(norbit)
yilas=fltarr(norbit)
tropp=fltarr(norbit)
tropz=fltarr(norbit)
tropth=fltarr(norbit)
mode=lonarr(norbit)
for i=0,norbit-1 do begin
    x=0.
    y=0.
    dsat=0.
    t=0.
    p_trop=0.
    z_trop=0.
    th_trop=0.
    m=0L
    readf,4,t,y,x,dsat,p_trop,z_trop,th_trop,m
    tilas(i)=t
    xilas(i)=x
    if xilas(i) lt 0. then xilas(i)=xilas(i)+360.
    yilas(i)=y
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
       o3ilas=fltarr(norbit,nl)
       pilas=fltarr(norbit,nl)
       thilas=fltarr(norbit,nl)
       zilas=fltarr(norbit,nl)
       clilas=fltarr(norbit,nl)
       qo3ilas=fltarr(norbit,nl)
    endif
    o3ilas(i,0:nl-1)=o3_snd
    pilas(i,0:nl-1)=p_snd
    thilas(i,0:nl-1)=th_snd
    zilas(i,0:nl-1)=z_snd
    clilas(i,0:nl-1)=cl_snd
    qo3ilas(i,0:nl-1)=qo3_snd
endfor
close,4
return
end
