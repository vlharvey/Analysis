;
; copy ES days -30 to +30 to common directory
;
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nc3
;
; Read ES day zeros
;
restore,'/Users/harvey/Harvey_etal_2014/Post_process/elevated_strat.sav'
restore,'/Users/harvey/Harvey_etal_2014/Post_process/WACCM_ES_daily_max_T_Z.sav'
dir='/Volumes/earth/harvey/WACCM_data/Datfiles/Datfiles_WACCM4/mee00fpl_FW2.cam2.h3.dyns.'
odir='/Users/harvey/Harvey_etal_2014/Datfiles/mee00fpl_FW2.cam2.h3.dyns.'
kcount=0L
for iES = 0L, n_elements(dayzerodates) - 1L do begin
    ydate = dayzerodates[iES]
    print,'Day Zero = ',ydate
    iyr=long(strmid(ydate,0,4))
    imn=long(strmid(ydate,4,2))
    idy=long(strmid(ydate,6,2))
    z = kgmt(imn,idy,iyr,kday)
    kday=kday-30
    if kday lt 0L then begin
       kday=kday+365
       iyr=iyr-1
    endif
    icount=0
    for iday=kday,kday+60L do begin
        iday0=iday
        if iday0 gt 366L then iday0=iday0-365L
        kdate,float(iday0),iyr,imn,idy
        ckday,iday0,iyr
        sdy=string(FORMAT='(i2.2)',idy)
        smn=string(FORMAT='(i2.2)',imn)
        syr=strtrim(string(iyr),2)

        ifile = syr+smn+sdy
        ifiles=file_search(dir+ifile+'_3D_dyn.nc3',count=nfile)
        if ifiles[0] eq '' then continue
        result=strsplit(ifiles(0),'.',/extract)
        result2=strsplit(result(4),'_',/extract)
        sdate=result2(0)
print,icount,' ',sdate
;
; read daily file
;
        ncfile0=ifiles(0)
        ncid=ncdf_open(ncfile0)
        result0=ncdf_inquire(ncid)
        if kcount eq 0L then begin
           for idim=0,result0.ndims-1 do begin
               ncdf_diminq,ncid,idim,name,dim
               if name eq 'number_of_latitudes' then nr=dim
               if name eq 'number_of_longitudes' then nc=dim
               if name eq 'number_of_levels' then nth=dim
           endfor
           for ivar=0,result0.nvars-1 do begin
               result=ncdf_varinq(ncid,ivar)
               ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
               if result.name eq 'latitude' then alat=data
               if result.name eq 'longitude' then alon=data
               if result.name eq 'theta' then th=data
           endfor
           kcount=1L
        endif
        for ivar=0,result0.nvars-1 do begin
            result=ncdf_varinq(ncid,ivar)
            ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
            if result.name eq 'IPV' then pv2=data
            if result.name eq 'P' then p2=data
            if result.name eq 'U' then u2=data
            if result.name eq 'V' then v2=data
            if result.name eq 'QDF' then qdf2=data
            if result.name eq 'Q' then q2=data
            if result.name eq 'GPH' then gph2=data
            if result.name eq 'TTGW' then ttgw2=data
            if result.name eq 'SF' then sf2=data
            if result.name eq 'MARK' then mark2=data
        endfor
        ncdf_close,ncid
;
; save file in new location
;
        save,filename=odir+sdate+'.sav',alon,alat,th,pv2,p2,u2,v2,qdf2,q2,gph2,ttgw2,sf2,mark2
endfor          ; loop over days -30 to +30
endfor          ; loop over ES events
end
