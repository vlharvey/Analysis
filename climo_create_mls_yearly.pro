;
; create MLS yearly files
;
@stddat
@kgmt
@ckday
@kdate
;
; get WACCM latitude grid
;
restore,'/Volumes/Data/WACCM/WACCM4/mee00fpl_FW2/mee00fpl_FW2.cam2.h3.Year12_1002_Q.sav'
nr=n_elements(lat)
latbin=LAT
dy=latbin(1)-latbin(0)
dirh='/Volumes/earth/aura6/data/MLS_data/Datfiles_SOSST/raw_mls_v3.3_'
model_years=[2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014]
model_years=string(FORMAT='(i4)',long(model_years))
nyears=n_elements(model_years)
;
; loop over model years
;
for iyear=0L,nyears-1L do begin

lstmn=1 & lstdy=1 & lstyr=1995 & lstday=0
ledmn=12 & leddy=31 & ledyr=1995 & ledday=0	; choose any non leap year
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
kday=ledday-lstday+1L
if kday ne 365L then stop,'check kday'
sdate_all=strarr(kday)
icount=0
kcount=0
;
; loop over days
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; test for end condition and close windows.
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if icount eq kday then goto,saveit
      sdy=string(FORMAT='(i2.2)',idy)
      smn=string(FORMAT='(i2.2)',imn)
      sdate=smn+sdy
      sdate_all(icount)=sdate
      if sdate eq '0229' then stop,'check leap year?'	; there is no leap day in WACCM
;
; read data
;
      dum=findfile(dirh+model_years(iyear)+sdate+'.sav')
      if dum(0) eq '' then goto,jumpday
      restore,dum(0)
;
; declare yearly average and sigma arrays
;
      if kcount eq 0L then begin
         nl=n_elements(PMLS2)
         zindex=0*findgen(nl)
         for k=0L,nl-1L do begin
             index=where(pmls eq pmls2(k))
             if index(0) ne -1L then zindex(k)=1
         endfor
         index=where(zindex eq 1,nl)
         BROMLS_AVG=fltarr(nr,nl,kday)
         NBROMLS_AVG=fltarr(nr,nl,kday)
         CLOMLS_AVG=fltarr(nr,nl,kday)
         NCLOMLS_AVG=fltarr(nr,nl,kday)
         COMLS_AVG=fltarr(nr,nl,kday)
         NCOMLS_AVG=fltarr(nr,nl,kday)
         GPMLS_AVG=fltarr(nr,nl,kday)
         NGPMLS_AVG=fltarr(nr,nl,kday)
         H2OMLS_AVG=fltarr(nr,nl,kday)
         NH2OMLS_AVG=fltarr(nr,nl,kday)
         HCLMLS_AVG=fltarr(nr,nl,kday)
         NHCLMLS_AVG=fltarr(nr,nl,kday)
         HNO3MLS_AVG=fltarr(nr,nl,kday)
         NHNO3MLS_AVG=fltarr(nr,nl,kday)
         N2OMLS_AVG=fltarr(nr,nl,kday)
         NN2OMLS_AVG=fltarr(nr,nl,kday)
         O3MLS_AVG=fltarr(nr,nl,kday)
         NO3MLS_AVG=fltarr(nr,nl,kday)
         TPMLS_AVG=fltarr(nr,nl,kday)
         NTPMLS_AVG=fltarr(nr,nl,kday)
         kcount=1L
      endif
;
; resize O3, H2O, T, GPH
;
      index=where(zindex eq 1,nl)
      if nl ne 37L then stop,'check nl'
      GPMASK=reform(GPMASK(*,index))
      GPMLS=reform(GPMLS(*,index))
      H2OMASK=reform(H2OMASK(*,index))
      H2OMLS=reform(H2OMLS(*,index))
      O3MASK=reform(O3MASK(*,index))
      O3MLS=reform(O3MLS(*,index))
      TPMASK=reform(TPMASK(*,index))
      TPMLS=reform(TPMLS(*,index))
;
; loop over years and retain all data
;
      print,'restored '+dum(0)
      for j=0L,nr-1L do begin
          ym1=latbin(j)-dy/2.
          yp1=latbin(j)+dy/2.
          yindex=where(latitude ge ym1 and latitude lt yp1,nprof)
          if yindex(0) ne -1L then begin
        
          for n=0L,nprof-1L do begin
          for k=0L,nl-1L do begin
              if BROMASK(yindex(n),k) ne -99. then begin
                 BROMLS_AVG(j,k,icount)=BROMLS_AVG(j,k,icount)+BROMLS(yindex(n),k)
                 NBROMLS_AVG(j,k,icount)=NBROMLS_AVG(j,k,icount)+1L
              endif
              if CLOMASK(yindex(n),k) ne -99. then begin
                 CLOMLS_AVG(j,k,icount)=CLOMLS_AVG(j,k,icount)+CLOMLS(yindex(n),k)
                 NCLOMLS_AVG(j,k,icount)=NCLOMLS_AVG(j,k,icount)+1L
              endif
              if COMASK(yindex(n),k) ne -99. then begin
                 COMLS_AVG(j,k,icount)=COMLS_AVG(j,k,icount)+COMLS(yindex(n),k)
                 NCOMLS_AVG(j,k,icount)=NCOMLS_AVG(j,k,icount)+1L
              endif
              if GPMASK(yindex(n),k) ne -99. then begin
                 GPMLS_AVG(j,k,icount)=GPMLS_AVG(j,k,icount)+GPMLS(yindex(n),k)
                 NGPMLS_AVG(j,k,icount)=NGPMLS_AVG(j,k,icount)+1L
              endif
              if H2OMASK(yindex(n),k) ne -99. then begin
                 H2OMLS_AVG(j,k,icount)=H2OMLS_AVG(j,k,icount)+H2OMLS(yindex(n),k)
                 NH2OMLS_AVG(j,k,icount)=NH2OMLS_AVG(j,k,icount)+1L
              endif
              if HCLMASK(yindex(n),k) ne -99. then begin
                 HCLMLS_AVG(j,k,icount)=HCLMLS_AVG(j,k,icount)+HCLMLS(yindex(n),k)
                 NHCLMLS_AVG(j,k,icount)=NHCLMLS_AVG(j,k,icount)+1L
              endif
              if HNO3MASK(yindex(n),k) ne -99. then begin
                 HNO3MLS_AVG(j,k,icount)=HNO3MLS_AVG(j,k,icount)+HNO3MLS(yindex(n),k)
                 NHNO3MLS_AVG(j,k,icount)=NHNO3MLS_AVG(j,k,icount)+1L
              endif
              if N2OMASK(yindex(n),k) ne -99. then begin
                 N2OMLS_AVG(j,k,icount)=N2OMLS_AVG(j,k,icount)+N2OMLS(yindex(n),k)
                 NN2OMLS_AVG(j,k,icount)=NN2OMLS_AVG(j,k,icount)+1L
              endif
              if O3MASK(yindex(n),k) ne -99. then begin
                 O3MLS_AVG(j,k,icount)=O3MLS_AVG(j,k,icount)+O3MLS(yindex(n),k)
                 NO3MLS_AVG(j,k,icount)=NO3MLS_AVG(j,k,icount)+1L
              endif
              if TPMASK(yindex(n),k) ne -99. then begin
                 TPMLS_AVG(j,k,icount)=TPMLS_AVG(j,k,icount)+TPMLS(yindex(n),k)
                 NTPMLS_AVG(j,k,icount)=NTPMLS_AVG(j,k,icount)+1L
              endif
          endfor
          endfor
          endif
      endfor	; bin data in latitude
;print,max(TPMLS_AVG),max(O3MLS_AVG),max(N2OMLS_AVG),max(HNO3MLS_AVG),max(HCLMLS_AVG),max(H2OMLS_AVG),max(GPMLS_AVG),max(COMLS_AVG),max(CLOMLS_AVG),max(BROMLS_AVG)
;print,max(NTPMLS_AVG(*,*,icount)),max(NO3MLS_AVG(*,*,icount)),max(NN2OMLS_AVG(*,*,icount)),max(NHNO3MLS_AVG(*,*,icount)),max(NHCLMLS_AVG(*,*,icount)),max(NH2OMLS_AVG(*,*,icount)),max(NGPMLS_AVG(*,*,icount)),max(NCOMLS_AVG(*,*,icount)),max(NCLOMLS_AVG(*,*,icount)),max(NBROMLS_AVG(*,*,icount))
jumpday:
      icount=icount+1L
goto,jump
;
; save yearly file
;
saveit:
;
; average data
;
index=where(NBROMLS_AVG gt 1.)
if index(0) ne -1L then BROMLS_AVG(index)=BROMLS_AVG(index)/float(NBROMLS_AVG(index))
index=where(NCLOMLS_AVG gt 1.)
if index(0) ne -1L then CLOMLS_AVG(index)=CLOMLS_AVG(index)/float(NCLOMLS_AVG(index))
index=where(NCOMLS_AVG gt 1.)
if index(0) ne -1L then COMLS_AVG(index)=COMLS_AVG(index)/float(NCOMLS_AVG(index))
index=where(NGPMLS_AVG gt 1.)
if index(0) ne -1L then GPMLS_AVG(index)=GPMLS_AVG(index)/float(NGPMLS_AVG(index))
index=where(NH2OMLS_AVG gt 1.)
if index(0) ne -1L then H2OMLS_AVG(index)=H2OMLS_AVG(index)/float(NH2OMLS_AVG(index))
index=where(NHCLMLS_AVG gt 1.)
if index(0) ne -1L then HCLMLS_AVG(index)=HCLMLS_AVG(index)/float(NHCLMLS_AVG(index))
index=where(NHNO3MLS_AVG gt 1.)
if index(0) ne -1L then HNO3MLS_AVG(index)=HNO3MLS_AVG(index)/float(NHNO3MLS_AVG(index))
index=where(NN2OMLS_AVG gt 1.)
if index(0) ne -1L then N2OMLS_AVG(index)=N2OMLS_AVG(index)/float(NN2OMLS_AVG(index))
index=where(NO3MLS_AVG gt 1.)
if index(0) ne -1L then O3MLS_AVG(index)=O3MLS_AVG(index)/float(NO3MLS_AVG(index))
index=where(NTPMLS_AVG gt 1.)
if index(0) ne -1L then TPMLS_AVG(index)=TPMLS_AVG(index)/float(NTPMLS_AVG(index))
print,max(TPMLS_AVG),max(O3MLS_AVG),max(N2OMLS_AVG),max(HNO3MLS_AVG),max(HCLMLS_AVG),max(H2OMLS_AVG),max(GPMLS_AVG),max(COMLS_AVG),max(CLOMLS_AVG),max(BROMLS_AVG)
;
; check
;
erase
!type=2^2+2^3
loadct,39
mcolor=byte(!p.color)
mcolor=fix(mcolor)
device,decompose=0
if mcolor eq 0 then mcolor=255
nlvls=20
col1=1+mcolor*findgen(20)/nlvls
ilat=where(min(abs(latbin-0.94736842)) eq abs(latbin-0.94736842))
plotarray=transpose(reform(TPMLS_AVG(ilat,*,*)))
omin=min(plotarray)
omax=max(plotarray)
level=omin+((omax-omin)/nlvls)*findgen(nlvls+1)
index=where(sdate_all  ne '')
contour,plotarray,index,pmls,levels=level,c_color=col1,/cell_fill,/noeras,yrange=[max(pmls),min(pmls)],/ylog,$
        xrange=[1.,kday],xticks=6,ytitle='Pressure',xtitle='DOY',charsize=1.5,min_value=-99.,title='MLS Temp '+model_years(iyear)
contour,plotarray,index,pmls,levels=level,c_color=0,/follow,/noeras,/overplot
;
; save yearly file
;
ofile=dirh+model_years(iyear)+'_daily_zm.sav'
save,file=ofile,sdate_all,latbin,pmls,BROMLS_AVG,CLOMLS_AVG,COMLS_AVG,GPMLS_AVG,H2OMLS_AVG,HCLMLS_AVG,HNO3MLS_AVG,N2OMLS_AVG,O3MLS_AVG,TPMLS_AVG
endfor	; loop over years
end
