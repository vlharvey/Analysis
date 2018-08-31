;
; print average theta at altitudes from 5 to 100 km every 5 km
;
@rd_haloe_o3_soundings
@stddat
@kgmt
@ckday
@kdate

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
device,decompose=0
setplot='x'
;read,'setplot=',setplot
mcolor=icolmax
nlvls=20
col1=1+indgen(nlvls)*mcolor/nlvls
icmm1=icolmax-1
icmm2=icolmax-2
setplot='x'
read,'setplot=',setplot
nxdim=600 & nydim=600
xorig=[0.10]
yorig=[0.15]
cbaryoff=0.02
cbarydel=0.02
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
dirh='/aura3/data/HALOE_data/Sound_data/haloe_'
ifile='                             '
lstmn=1 & lstdy=7 & lstyr=1 & lstday=0
ledmn=1 & leddy=7 & ledyr=1 & ledday=0
;
; Ask interactive questions- get starting/ending date
;
print, ' '
print, '      UKMO Version '
print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; test for end condition and close windows.
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
;
; read UKMO data
;
      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      uyr=strmid(syr,2,2)
      ifile=mon(imn-1)+sdy+'_'+uyr
;
; read satellite ozone soundings
;
      sfile=mon(imn-1)+sdy+'_'+syr
      rd_haloe_o3_soundings,dirh+sfile+'_o3.sound',norbith,thal,$
         xhal,yhal,tropph,tropzh,tropthh,modeh,o3hal,phal,$
         thhal,zhal,clhal,qo3hal,nlevh

          if setplot eq 'ps' then begin
             lc=0
             set_plot,'ps'
             xsize=nxdim/100.
             ysize=nydim/100.
             !p.font=0
             device,font_size=9
             device,/landscape,bits=8,filename='haloe_z_of_theta_'+ifile+'.ps'
             device,/color
             device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                     xsize=xsize,ysize=ysize
          endif
          erase
          !type=2^2+2^3
          xmn=xorig(0)
          xmx=xorig(0)+0.8
          ymn=yorig(0)
          ymx=yorig(0)+0.8
          set_viewport,xmn,xmx,ymn,ymx
          date=strcompress(string(FORMAT='(A3,A1,I2,A2,I4)',$
                           month(imn-1),' ',idy,', ',iyr))
plot,THHAL(0,*),ZHAL(0,*),psym=2,yrange=[0,150],xrange=[0,10000]
index=where(yhal gt 0.)
oplot,thhal(index,*),zhal(index,*),psym=3
for i=0,100,5 do begin
    index=where(abs(zhal-float(i)) lt 2.)
    if index(0) ne -1 then begin
       result=moment(thhal(index))
       print,i,result(0)
    endif
endfor

      if setplot eq 'ps' then begin
         device, /close
          spawn,'convert -trim haloe_z_of_theta_'+ifile+'.ps '+$
          ' -rotate -90 haloe_z_of_theta_'+ifile+'.jpg'
      endif
stop
      icount=icount+1L
      goto,jump
end
