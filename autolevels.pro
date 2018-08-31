pro autolevels,mn,mx,ninc,lev,center

;-----------------------------------------------------------------------
; procedure to generate nice contour levels at uniform intervals
;   J. Al-Saadi Dec 02 1999
;
; inputs
;   mn		the minimum data value
;   mx		the maximum data value
;   ninc	the number of intervals
;
; outputs
;   lev		array (ninc+1) of contour levels
;
; optional arguments
;   center	force contour levels to be equally distributed around 0;
;		if this argument is present, centering will occur
;               (Note that if mn = -mx then centering is automatic)
;
; discussion
;   - the contour interval will be one of the members of array "inc",
;     times the appropriate power of 10
;   - because only standard values of contour increments will be used,
;     the lev array may extend past mn and/or mx
;   - if mn or mx are zero, zero will be an endpoint of the lev array
;   - if mn<0 and mx>0, the lev array will include a zero (exactly),
;     which may force the lev array to extend past mn and/or mx
;-----------------------------------------------------------------------

inc=[1.,2.,2.5,4.,5.,8.,10.]

ran=mx-mn

cc=n_elements(center)
if cc ge 1 then begin
  num = abs(mx) > abs(mn)
  ran=2.*num
endif

ranscal=ran/float(ninc)
a=alog10(ranscal)
power=floor(a)
mag=10.^power
val=ranscal/mag
i=where(inc ge val)
;print,a,power,mag,val,inc(i(0))

del=float(inc(i(0)))*mag

check=0
case 1 of
  ((mn eq -mx) or (cc ge 1)): begin
    lev=del*(1+findgen(ninc/2))
    lev=[-reverse(lev),0.,lev]
  end
  (mn ge 0): begin
    lev=mn+del*findgen(ninc+1)
    if lev(ninc) ne mx then check=1
  end
  (mx le 0): begin
    lev=mx-del*findgen(ninc+1)
    lev=reverse(lev)
    if lev(0) ne mn then check=1
  end
  else: begin
    lev=mn+del*findgen(ninc+1)
    check=2
  end
endcase

; make sure that levels are integer multiples of the increment
if check eq 1 then begin
  test=lev(0) mod del
  if test ne 0 then begin
    lev=lev-test
    ; if shifting to integer multiples doesn't encompass input mn/mx, must
    ; recompute with larger increment
    if lev(0) gt mn or lev(ninc) lt mx then begin
      ran= (mx>lev(ninc)) - (mn<lev(0))
      ranscal=ran/float(ninc)
      a=alog10(ranscal)
      power=floor(a)
      mag=10.^power
      val=ranscal/mag
      i=where(inc ge val)
      del=float(inc(i(0)))*mag
      lev=mn+del*findgen(ninc+1)
      ; ensure that recomputed levels are integer multiples
      test=lev(0) mod del
      if test ne 0 then begin
        lev=lev-test
      endif
    endif
  endif
endif

; if levels encompass zero, ensure that zero is a level
if check eq 2 then begin
  test=where(lev eq 0.,count)
  if count ne 1 then begin
    test=where(lev gt 0.)
    shift=lev(test(0))
    ; if shifting to include zero doesn't encompass input mn/mx, must
    ; recompute with larger increment
    if lev(ninc)-shift ge mx then begin
      lev=lev-shift
    endif else begin
      mx2=mx+shift
      ran=mx2-mn
      ranscal=ran/float(ninc)
      a=alog10(ranscal)
      power=floor(a)
      mag=10.^power
      val=ranscal/mag
      i=where(inc ge val)
      del=float(inc(i(0)))*mag
      lev=mn+del*findgen(ninc+1)
      test=where(lev eq 0.,count)
      ; ensure that zero is a level in recomputed levels
      if count ne 1 then begin
        test=where(lev gt 0.)
        shift=lev(test(0))
        lev=lev-shift
      endif
    endelse
  endif
endif

; center if extent of levels is much larger than [mn,mx]
if check gt 0 and mn ne 0 and mx ne 0 then begin
  imn=where(lev le mn,countn)
  imx=where(lev ge mx,countx)
  if countn gt 1 or countx gt 1 then begin
    ishift=(countx-countn)/2
    lev=lev-del*float(ishift)
  endif
endif

;print,del
;print,lev

end
