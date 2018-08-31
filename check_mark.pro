;
; corrects marker=2 values from merging marker fields
;
@rd_ukmo_nc3
@write_ukmo_nc3
dir='/usr72/users/ukmo/Datfiles/ukmo_'
ifile='                             '
close,1
openr,1,'gsfc.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin
    readf,1,ifile
    rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,xlon,xlat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2
;
; correct marker value and write new file
;
    index=where(mark2 gt 1.,nbad)
    print,ifile,nbad
    if index(0) ne -1 then begin
       mark2(index)=1.0 
       write_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,xlon,xlat,$
             th,pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2
    endif
endfor		; loop over files
end
