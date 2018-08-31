;
; save maximum temperature poleward of 45 degrees latitude in each
; hemisphere, on each theta level, on each day
;
; store maxt flag arrays for both hemispheres and entire data record
; in one IDL save file
;
@rd_ukmo_nc3

diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
ifile='                             '
close,1
openr,1,'ssw_finder.fil'
nfile=0L
readf,1,nfile
yyyymmdd=lonarr(nfile)
for n=0,nfile-1 do begin
    readf,1,ifile
    uyr=strmid(ifile,7,2)
    if strmid(uyr,0,1) eq '9' then iyr='19'+uyr
    if strmid(uyr,0,1) ne '9' then iyr='20'+uyr
    tmp=strmid(ifile,0,4)
    index=where(mon eq tmp)
    imn=index(0)+1L
    idy=strmid(ifile,4,2)
    syr=string(FORMAT='(I4)',iyr)
    smn=string(FORMAT='(I2.2)',imn)
    sdy=string(FORMAT='(I2.2)',idy)
    yyyymmdd(n)=long(syr+smn+sdy)
    print,ifile,long(syr+smn+sdy)
    dum1=findfile(diru+ifile+'.nc3')
    if dum1(0) ne '' then ncid=ncdf_open(diru+ifile+'.nc3')
    if dum1(0) eq '' then goto,jump
    if n eq 0 then begin
       nr=0L
       nc=0L
       nth=0L
       ncdf_diminq,ncid,0,name,nr
       ncdf_diminq,ncid,1,name,nc
       ncdf_diminq,ncid,2,name,nth
       alon=fltarr(nc)
       alat=fltarr(nr)
       th=fltarr(nth)
       ncdf_varget,ncid,0,alon
       ncdf_varget,ncid,1,alat
       ncdf_varget,ncid,2,th
       p2=fltarr(nr,nc,nth)
       ynindex=where(alat ge 45.)
       ysindex=where(alat le -45.)
; 
; set to maximum temperature poleward of 45 degrees at each theta level
;
       nh_maxt_flag=fltarr(nfile,nth)
       sh_maxt_flag=fltarr(nfile,nth)
    endif
    ncdf_varget,ncid,4,p2
    ncdf_close,ncid
;
; Temperature=theta*(p/po)^R/cp and divide by 1000 for km
;
    t2=0.*p2
    for k=0,nth-1 do $
        t2(*,*,k)=th(k)*((p2(*,*,k)/1000.)^(.286))
;
; retain max temperature poleward of 45 degrees
;
    for k=0,nth-1 do begin
        nhtemp=reform(t2(ynindex,*,k))
        shtemp=reform(t2(ysindex,*,k))
        nh_maxt_flag(n,k)=max(nhtemp)
        sh_maxt_flag(n,k)=max(shtemp)
    endfor
    if max(nh_maxt_flag(n,*)) ge 300. then print,'warm stratopause ',max(nh_maxt_flag(n,*))
    jump:
endfor		; loop over days
;
; save file
;
comment='flag set to 1 if minor SSW. set to 2 if major SSW'
save,file='MetO_MaxT_Climo.sav',yyyymmdd,th,nh_maxt_flag,sh_maxt_flag
end
