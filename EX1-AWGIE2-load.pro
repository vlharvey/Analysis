
Hfile  = 'HIRDLS2_2000d276_MZ3_c1.he5'

;; file header and tail for MLS
Mfileh = 'MLS-Aura_L2GP-'
Mfilet = '_sAura2c--t_2000d276.he5'

SpeciesName = 'Temperature'

;; construct MLS filename
Mfile = Mfileh + SpeciesName + Mfilet

;; load HIRDLS time and geolocation
status = GET_AURA(Hfile, 'Time', HIRTIM)
status = GET_AURA(Hfile, 'Latitude', HIRLAT)
status = GET_AURA(Hfile, 'Longitude', HIRLON)
status = GET_AURA(Hfile, 'Pressure', HIRPRES)

;; load MLS time and geolocation
status = GET_AURA(Mfile, 'Time', MLSTIM) 
status = GET_AURA(Mfile, 'Latitude', MLSLAT) 
status = GET_AURA(Mfile, 'Longitude', MLSLON) 
status = GET_AURA(Mfile, 'Pressure', MLSPRES)


;; load HIRDLS and MLS species
status = GET_AURA(Hfile, SpeciesName, HIRDATA)
status = GET_AURA(Mfile, SpeciesName, MLSDATA) 

HELP

END;;PROG
