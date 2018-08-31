function getprof_idl,nlevels

prof={satid:bytarr(4), rectyp:bytarr(2), instid:bytarr(12), $
      reccnt:bytarr(8), spare:0, totpts:long(0), ndatpt:long(0), $
      fstind:long(0), rectim:lonarr(2), lat:0.0, long:0.0, $
       soltime:0.0, solzen:0.0, qu:fltarr(nlevels),err:fltarr(nlevels)}
return,prof

end
