GeoLoc = ['Pressure', $
          'Time',$
          'Latitude',$
          'Longitude',$
          'SolarZenithAngle',$
          'LocalSolarTime']

SpeciesName = 'Temperature'

Hfile = 'HIRDLS2_2000d276_MZ3_c1.he5'

;; file header and tail for MLS
Mfileh = 'MLS-Aura_L2GP-'
Mfilet = '_sAura2c--t_2000d276.he5'

;; construct MLS filename
Mfile = Mfileh + SpeciesName + Mfilet

hirdls = LoadAuraData(Hfile, [GeoLoc, SpeciesName])
mls    = LoadAuraData(Mfile, [GeoLoc, SpeciesName])


HELP,/st, hirdls
HELP,/st, mls

END;;PROG
