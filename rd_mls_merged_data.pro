pro rd_mls_merged_data,yymmdd,norbit,t_mls,$
    x_mls,y_mls,th_mls,xs_mls,ys_mls,p_mls,z_mls,$
    ptr_mls,ztr_mls,thtr_mls,cl_mls,m_mls,hno3_mls,$
    no2_mls,o3_mls,h2o_mls
yymmdd=0L
norbit=150000L
t=0.
y=0.
x=0.
ys=0.
xs=0.
p=0.
z=0.
p_trop=0.
z_trop=0.
th_trop=0.
cl=0.
m=0L
ch3cndat=0.
clodat=0.
hno3dat=0.
o3dat=0.
h2odat=0.
t_mls=9999+fltarr(norbit)
x_mls=9999+fltarr(norbit)
y_mls=9999+fltarr(norbit)
th_mls=9999+fltarr(norbit)
xs_mls=9999+fltarr(norbit)
ys_mls=9999+fltarr(norbit)
p_mls=9999+fltarr(norbit)
z_mls=9999+fltarr(norbit)
ptr_mls=9999+fltarr(norbit)
ztr_mls=9999+fltarr(norbit)
thtr_mls=9999+fltarr(norbit)
cl_mls=9999+fltarr(norbit)
m_mls=9999+intarr(norbit)
ch3cn_mls=9999.+fltarr(norbit)
clo_mls=9999.+fltarr(norbit)
hno3_mls=9999.+fltarr(norbit)
o3_mls=9999.+fltarr(norbit)
h2o_mls=9999.+fltarr(norbit)
;
; loop over theta levels
;
readf,4,yymmdd
readf,4,norbit
if norbit gt 0L then begin
   for i=0L,norbit-1L do begin
       readf,4,t,y,x,th,xs,ys,p,z,p_trop,z_trop,th_trop,cl,m
       t_mls(i)=t
       x_mls(i)=x
       y_mls(i)=y
       th_mls(i)=th
       xs_mls(i)=xs
       ys_mls(i)=ys
       p_mls(i)=p
       z_mls(i)=z
       ptr_mls(i)=p_trop
       ztr_mls(i)=z_trop
       thtr_mls(i)=th_trop
       cl_mls(i)=cl
       m_mls(i)=m
       readf,4,o3dat,hno3dat,h2odat,clodat,ch3cndat
       ch3cn_mls(i)=ch3cndat
       clo_mls(i)=clodat
       hno3_mls(i)=hno3dat
       o3_mls(i)=o3dat
       h2o_mls(i)=h2odat
       readf,4,o3dat,hno3dat,h2odat,clodat,ch3cndat
   endfor
   index=where(t_mls ne 9999.,norbit)
   if index(0) ne -1 then begin
      t_mls=t_mls(index)
      x_mls=x_mls(index)
      y_mls=y_mls(index)
      th_mls=th_mls(index)
      xs_mls=xs_mls(index)
      ys_mls=ys_mls(index)
      p_mls=p_mls(index)
      z_mls=z_mls(index)
      ptr_mls=ptr_mls(index)
      ztr_mls=ztr_mls(index)
      thtr_mls=thtr_mls(index)
      cl_mls=cl_mls(index)
      m_mls=m_mls(index)
      ch3cn_mls=ch3cn_mls(index)
      clo_mls=clo_mls(index)
      hno3_mls=hno3_mls(index)
      o3_mls=o3_mls(index)
      h2o_mls=h2o_mls(index)
   endif
close,4
endif
return
end