pro read_tidi_vec0307a,ncfile,nvec,nalts,date_len,two_telescopes,ut_date,lat,lon,sza,alt_retrieved,time,$
    ms_time,ut_time,rec_index,data_ok,lst,lza,mlat,mlon,track,table_id,measure_track,flight_dir,ascending,$
    in_saa,u_p9,var_u_p9,v_p9,var_v_p9,u_p15,var_u_p15,v_p15,var_v_p15,u_bb,var_u_bb,v_bb,var_v_bb,ver_p9,$
    var_ver_p9,t_doppler_p9,var_t_doppler_p9,ver_p15,var_ver_p15,t_doppler_p15,var_t_doppler_p15,ver_bb,$
    var_ver_bb,t_doppler_bb,var_t_doppler_bb
    
ncid=ncdf_open(ncfile)
result=ncdf_inquire(ncid)
for idim=0,result.ndims-1 do begin
    ncdf_diminq,ncid,idim,name,dim
    if name eq 'nvec' then nvec=dim
    if name eq 'nalts' then nalts=dim
    if name eq 'date_len' then date_len=dim
    if name eq 'two_telescopes' then two_telescopes=dim
;    print,'read ',name,' dimension ',dim
endfor
for ivar=0,result.nvars-1 do begin
    result=ncdf_varinq(ncid,ivar)
    ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
    if result.name eq 'ut_date' then ut_date=data				; byte(nvec, date_len)
    if result.name eq 'lat' then lat=data					; float(nvec)
    if result.name eq 'lon' then lon=data					; float(nvec)
    if result.name eq 'sza' then sza=data					; float(nvec)
    if result.name eq 'alt_retrieved' then alt_retrieved=data			; float(nalts)
    if result.name eq 'time' then time=data					; int(nvec)
    if result.name eq 'ms_time' then ms_time=data				; short(nvec)
    if result.name eq 'ut_time' then ut_time=data				; int(nvec)
    if result.name eq 'rec_index' then rec_index=data				; int(nvec)
    if result.name eq 'data_ok' then data_ok=data				; byte(nvec)
    if result.name eq 'lst' then lst=data					; float(nvec)
    if result.name eq 'lza' then lza=data					; float(nvec)
    if result.name eq 'mlat' then mlat=data					; float(nvec)
    if result.name eq 'mlon' then mlon=data					; float(nvec)
    if result.name eq 'track' then track=data					; float(nvec)
    if result.name eq 'table_id' then table_id=data				; int(nvec)
    if result.name eq 'measure_track' then measure_track=data			; byte(nvec)
    if result.name eq 'flight_dir' then flight_dir=data				; byte(nvec)
    if result.name eq 'ascending' then ascending=data				; byte(nvec)
    if result.name eq 'in_saa' then in_saa=data					; byte(nvec)

    if result.name eq 'u_p9' then u_p9=data 					; float(nvec, nalts)
    if result.name eq 'var_u_p9' then var_u_p9=data				; float(nvec, nalts)
    if result.name eq 'v_p9' then v_p9=data					; float(nvec, nalts)
    if result.name eq 'var_v_p9' then var_v_p9=data				; float(nvec, nalts)
    if result.name eq 'u_p15' then u_p15=data					; float(nvec, nalts)
    if result.name eq 'var_u_p15' then var_u_p15=data				; float(nvec, nalts)
    if result.name eq 'v_p15' then v_p15=data					; float(nvec, nalts)
    if result.name eq 'var_v_p15' then var_v_p15=data				; float(nvec, nalts)
    if result.name eq 'u_bb' then u_bb=data					; float(nvec, nalts)
    if result.name eq 'var_u_bb' then var_u_bb=data				; float(nvec, nalts)
    if result.name eq 'v_bb' then v_bb=data					; float(nvec, nalts)
    if result.name eq 'var_v_bb' then var_v_bb=data				; float(nvec, nalts)

    if result.name eq 'ver_p9' then ver_p9=data					; float(nvec, two_telescopes, nalts)
    if result.name eq 'var_ver_p9' then var_ver_p9=data				; float(nvec, two_telescopes, nalts)
    if result.name eq 't_doppler_p9' then t_doppler_p9=data			; float(nvec, two_telescopes, nalts)
    if result.name eq 'var_t_doppler_p9' then var_t_doppler_p9=data		; float(nvec, two_telescopes, nalts) 
    if result.name eq 'ver_p15' then ver_p15=data				; float(nvec, two_telescopes, nalts)
    if result.name eq 'var_ver_p15' then var_ver_p15=data			; float(nvec, two_telescopes, nalts)
    if result.name eq 't_doppler_p15' then t_doppler_p15=data			; float(nvec, two_telescopes, nalts)
    if result.name eq 'var_t_doppler_p15' then var_t_doppler_p15=data		; float(nvec, two_telescopes, nalts)
    if result.name eq 'ver_bb' then ver_bb=data					; float(nvec, two_telescopes, nalts)
    if result.name eq 'var_ver_bb' then var_ver_bb=data				; float(nvec, two_telescopes, nalts)
    if result.name eq 't_doppler_bb' then t_doppler_bb=data			; float(nvec, two_telescopes, nalts)
    if result.name eq 'var_t_doppler_bb' then var_t_doppler_bb=data		; float(nvec, two_telescopes, nalts)

;    print,'read ',result.name,' variable ',min(data),max(data)
endfor

ncdf_close,ncid
return
end
