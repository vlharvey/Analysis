; 
; check dates in ionization files and WACCM output
; VLH 12/23/10
;
; read Xiaohua Xiaohua_Fang_e.nc file that contains all dates in one file
;
ncfile='/Users/harvey/Desktop/CHARM/Xiaohua_Fang_e.nc'
ncid=ncdf_open(ncfile)
result0=ncdf_inquire(ncid)
for idim=0,result0.ndims-1 do begin
    ncdf_diminq,ncid,idim,name,dim
    if name eq 'lon' then ncx=dim
    if name eq 'lat' then nrx=dim
    if name eq 'altitude' then nlx=dim
    if name eq 'time' then ntx=dim
    print,'read Xiaohua ',name,' dimension ',dim
endfor
for ivar=0,result0.nvars-1 do begin
    result=ncdf_varinq(ncid,ivar)
    ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
    if result.name eq 'lat' then xlat=data
    if result.name eq 'lon' then xlon=data
    if result.name eq 'altitude' then xaltitude=data
    if result.name eq 'date' then xdate=data
    if result.name eq 'datesec' then xdatesec=data
    if result.name eq 'e' then xegrd=data
    print,ivar,result.name,min(data),max(data)
endfor
ncdf_close,ncid
;
dir='/Volumes/data/WACCM/no_aur_run1.cam2.h1.'
rtd=double(180./!pi)
dtr=1./rtd
ks=1.931853d-3
ecc=0.081819
gamma45=9.80
;
; loop over WACCM date+datesec files
;
for n=0,ntx-1L do begin
;
; extract date
;
    date0=strcompress(xdate(n),/remove_all)
    datesec0=xdatesec(n)
    while datesec0 gt 84600 do datesec0=datesec0-84600
    datesec0=string(FORMAT='(i5.5)',datesec0)
    syr=strmid(date0,0,4)
    smn=strmid(date0,4,2)
    sdy=strmid(date0,6,2)
    print,date0,' ',datesec0
;
; read WACCM data
;
    ifile=dir+syr+'-'+smn+'-'+sdy+'-'+datesec0+'.nc'
    sdum=findfile(ifile)
    if sdum ne '' then print,ifile
    jumpstep:
endfor		; loop over time steps
end
