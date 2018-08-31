;-----------------------------------------------------------------------------------------------------------------------------
;;Produces Figure 2 for France et al 2010, latitude time plot of temperature at the stratopause
;	 -------------------------------
;       |         Jeff France           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 03/12/2009      |
;	 -------------------------------
;
;
;
;-----------------------------------------------------------------------------------------------------------------------------
;

@/Volumes/MacD68-1/france/idl_files/stddat			; Determines the number of days since Jan 1, 1956
@/Volumes/MacD68-1/france/idl_files/kgmt			; This function computes the Julian day number (GMT) from the
								;    day, month, and year information.
@/Volumes/MacD68-1/france/idl_files/ckday			; This routine changes the Julian day from 365(6 if leap yr)
								;    to 1 and increases the year, if necessary.
@/Volumes/MacD68-1/france/idl_files/kdate			; gives back kmn,kdy information from the Julian day #.
@/Volumes/MacD68-1/france/idl_files/rd_ukmo_nc3			; reads the data from nc3 files
@/Volumes/MacD68-1/france/idl_files/date2uars			; This code returns the UARS day given (jday,year) information.
@/Volumes/MacD68-1/france/idl_files/plotPosition		; defines positions for n number of plots
@/Volumes/MacD68-1/france/idl_files/rd_GEOS5_nc3
@/Volumes/MacD68-1/france/idl_files/rd_waccm_nc3

;------------------------------------

;Plot code
loadct,39

icolmax=byte(!p.color)
device,decompose=0
!NOERAS=-1s
!P.FONT=0 ; arial, bold
!p.charsize=2.5
SETPLOT='x'
read,'setplot',setplot
nxdim=800
nydim=800

n = 6
lndscp = 1

;call plot position procedure
plotPosition, n, lndscp, posL, posP

!p.thick=2


px1a = .05
px1b = 0.9
px2a = .05
px2b = .9

py1a = .4
py1b = .94
py2a = .36
py2b = .61
py3a = .035
py3b = .285

NHarray = [153,114,51,0,0,0,0,0,0,0,30,131]
SHarray = [0,0,0,0,0,9,59,86,119,33,0,0]

NH = fltarr(total(NHarray))
SH = fltarr(total(SHarray))

nh[0:152] = 1L
nh[153:266] = 2L
nh[267:317] = 3L
nh[318:347] = 11L
nh[348:478] = 12L

sh[0:8] = 6L
sh[9:67] = 7L
sh[68:153] = 8L
sh[153:271] = 9L
sh[272:304] = 10L







if setplot ne 'ps' then begin
 lc=icolmax
 window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
; !p.background=160
endif
if setplot eq 'ps' then begin
  ; lc=0
   set_plot,'ps'
  device,/color,landscape=1,bits=8,filename='idl.ps', /inches, xsize = 22, ysize = 16
endif


    !type=2^2+2^3
    erase
	loadct, 39
plothist, nh, bin = 1L, color = 255

   if setplot eq 'ps' then begin
       device, /close
 
spawn,'pstopnm -dpi=300 -landscape idl.ps'spawn,'pnmtopng idl001.ppm > /Volumes/MacD68-1/france/France_et_al_2011/Figures/Histogram_Fig.png'
spawn,'rm idl001.ppm idl.ps'
;        spawn,'convert idl.ps -rotate -90 '+ 
    endif



end
