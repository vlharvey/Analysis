;
; check marker field
;
nr=0L
nc=0L
nth=0L
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifile='                             '
close,1,2
openr,1,'check_marker.fil'
openw,2,'check_marker.dat'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin
    readf,1,ifile
    dum1=findfile(diru+ifile+'.nc3')
    if dum1(0) ne '' then ncid=ncdf_open(diru+ifile+'.nc3')
    if dum1(0) eq '' then goto,jump
    if n eq 0 then begin
       nr=0L & nc=0L & nth=0L
       ncdf_diminq,ncid,0,name,nr
       ncdf_diminq,ncid,1,name,nc
       ncdf_diminq,ncid,2,name,nth
       alon=fltarr(nc)
       alat=fltarr(nr)
       th=fltarr(nth)
       mark2=fltarr(nr,nc,nth)
    endif
    ncdf_varget,ncid,10,mark2
    ncdf_close,ncid
    printf,2,ifile,min(mark2),max(mark2)
jump:
endfor; loop over days
close,2
end
