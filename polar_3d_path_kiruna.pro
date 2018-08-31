
; polar stereographic zoom of kiruna range ring and 
; haloe tangent paths colored by theta

@stddat
@kgmt
@ckday
@kdate
@rd_haloe_3d
@tangent_path
@range_ring

; set color table
loadct,38
mcolor=byte(!p.color)
mcolor=fix(mcolor)
if mcolor eq 0 then mcolor=255
icmm1=mcolor-1
icmm2=mcolor-2
!noeras=1
nh=1
dtr=ASIN(1.0)/90.
rtd=1./dtr
rad=6.37E6

runtitle=' HALOE Tangent Paths as a function of altitude'
month=['January ','February ','March ','April ','May ','June ',$
'July ','August ','September ','October ','November ','December ']

theta=[2400.,2200.,2000.,1800.,1600.,1400.,1200.,1000.,900.,800.,$
       700.,600.,550.,525.,500.,475.,450.,425.,400.,390.,380.,370.,$
       360.,350.,340.,330.,320.,310.,300.,290.,280.,270.,260.,250.,240.]
nth=n_elements(theta)
xcolor=fltarr(nth)

; define viewport location
setplot='x'
read,'setplot?',setplot
colbw='col'

nclus=10
lstmn=3
lstdy=10
lstyr=96
ledmn=3
leddy=10
ledyr=96
lstday=0
ledday=0
print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 or lstyr gt 1999 then stop,'Year out of range '
if ledyr lt 1991 or ledyr gt 1999 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

; Longitude and latitude ranges
minlon=0.
maxlon=360.
minlat=0.
maxlat=90.
windvec='y'

; define viewport location 
nxdim=750
nydim=750
xorig=[0.2]
yorig=[0.2]
xlen=0.7
ylen=0.7
cbaryoff=0.03
cbarydel=0.01

if setplot ne 'ps' then begin
   lc=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif

if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='kiruna_3d_path.ps'
   if colbw ne 'bw' and colbw ne 'gs' then device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
   !p.thick=2.0                   ;Plotted lines twice as thick
   !p.charsize=1.0
endif

; Compute initial Julian date
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      iyr1 = iyr-1900

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '

; Set plot boundaries
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      erase
      !psym=0
      set_viewport,xmn,xmx,ymn,ymx

; Title
      date=strcompress(string(FORMAT='(I2,A2,I4)',idy,', ',iyr))
      mtitle='!6'+month(imn-1)+date+runtitle

      shift=0.
      radius=2500.
      lat=67.84
      lon=20.41
      latm1=lat -  ((radius*1000.+200000.)*360.)/ 40000000.
      lonm1=lon - (((radius*1000.+200000.)*360.)/(40000000.*cos(lat*!pi/180.)))
      latp1=lat +  ((radius*1000.+200000.)*360.)/ 40000000
      lonp1=lon + (((radius*1000.+200000.)*360.)/(40000000.*cos(lat*!pi/180.)))
      if latp1 gt 90. then begin
         latp1=90.-(latp1-90.)
         shift=180.
      endif
      print,lat,lonm1
      print,latp1,lon+shift
      print,lat,lonp1
      print,latm1,lon

; Polar stereographic projection 
;     MAP_SET,nh*90,0,-90*nh,/stereo,/contin,/grid,/noborder,/noera,$
;             color=lc,title=mtitle

; Limited area projection about Kiruna
      MAP_SET,/stereo,/contin,/grid,/noborder,/noera,latdel=10.,londel=20.,$
              color=lc,title=mtitle,$
              limit=[lat,lonm1,latp1,lon+shift,lat,lonp1,latm1,lon]
              
; range ring around Kiruna
     !psym=8
     a=findgen(3)*(2*!pi/3.)
     a=reform([a,a(0)],4)
     usersym,2*cos(a),2*sin(a),/fill
     oplot,[lon,lon],[lat,lat],color=lc
     !psym=0
     range_ring,lat,lon,radius,360,bear,latp,lonp
     tindex=where(lonp gt 180.,icount)
     if (icount gt 0) then lonp(tindex) = lonp(tindex)-360.
     index=where(latp le 90.)
     oplot,lonp(index),latp(index),color=lc

;***Read HALOE data
      rd_haloe_3d,imn,idy,iyr1,nhal,thal,xhal,yhal,xsat,ysat,ch4,hf,h2o,halo3,$
               hcl,halxno2,xno,halext,halcomp,haldens,halmedr,haldisw,$
               halconc,halsurf,halvolu,haleffr

      if nhal gt 0 then begin

; draw HALOE tangent path length of 600 km at each level
         !psym=8
         a=findgen(10)*(2*!pi/10.)/2.
         a=reform([a,a(0)],11)
         usersym,cos(a),sin(a),/fill
         xcolor=reverse(mcolor*((1.+findgen(nth))/float(nth+1)))
         for n=0,nhal-1 do begin
             xn=fltarr(nclus,nth)
             yn=fltarr(nclus,nth)
             zn=fltarr(nclus,nth)
             tangent_path,n,nclus,nth,theta,xhal,yhal,xsat,ysat,xn,yn,zn
             for k=nth-1,0,-1 do $
                 oplot,xn(*,k),yn(*,k),color=xcolor(k)
             xyouts,xhal(n,nth/2),yhal(n,nth/2),strcompress(strmid(thal(n,nth/2),0,10))
         endfor
      endif

; color bar
      yval=.05
      xval0=.075
      dy=.05
      color=reverse(mcolor*((1.+findgen(nth))/float(nth+1)))
      for i=nth-1,0,-2 do begin
          if setplot eq 'ps' then box=0B*bytarr(2,1)
          if setplot eq 'x' then box=0B*bytarr(40,20)
          box=color(i)+box
          if setplot eq 'ps' then tv,box,xval0,yval,xsize=.1,ysize=.05,/normal
          if setplot eq 'x' then tv,box,xval0,yval,/normal
          xyouts,xval0-.05,yval,strcompress(fix(theta(i))),/normal
          yval=yval+dy
      endfor
      xyouts,xval0-.05,yval+.01,'!6Theta (K)',/normal

; Close PostScript file and return control to X-windows
      if setplot eq 'ps' then begin
         device, /close
         set_plot, 'x'
         !p.font=0
         !p.thick=1.0
      endif

goto, jump
end
