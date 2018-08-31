;
; interpolate to create missing days
;
;        8      13    1995 = UARS day     1432
;        8      23    1996 = UARS day     1808
;       11       7    1998 = UARS day     2614
;       10      18    1999 = UARS day     2959
;        9      21    2000 = UARS day     3298
;        9      20    2001 = UARS day     3662

@rd_ukmo_nc3
@write_ukmo_nc3.pro
dir='/aura3/data/UKMO_data/Datfiles/'
ofile=[$
'ukmo_sep_20_01.nc3']
ifile0=[$
'ukmo_sep_19_01.nc3']
ifile1=[$
'ukmo_sep_21_01.nc3']
nfile=n_elements(ifile1)
for n=0,nfile-1 do begin
    iflag=0
    rd_ukmo_nc3,dir+ifile0(n),nc,nr,nth,alon,alat,th,$
                pv0,p0,msf0,u0,v0,q0,qdf0,mark0,vp0,sf0,iflag
    rd_ukmo_nc3,dir+ifile1(n),nc,nr,nth,alon,alat,th,$
                pv1,p1,msf1,u1,v1,q1,qdf1,mark1,vp1,sf1,iflag
    if iflag eq 1 then stop

    pv=(pv0+pv1)/2.0
    p=(p0+p1)/2.0
    msf=(msf0+msf1)/2.0
    u=(u0+u1)/2.0
    v=(v0+v1)/2.0
    q=(q0+q1)/2.0
    qdf=(qdf0+qdf1)/2.0
    mark=(mark0+mark1)/2.0
    vp=(vp0+vp1)/2.0
    sf=(sf0+sf1)/2.0

; Write UKMO isentropic data in netCDF format
    write_ukmo_nc3,dir+ofile(n),nc,nr,nth,alon,alat,th,$
          pv,p,msf,u,v,q,qdf,mark,vp,sf

endfor		; loop over files
end
