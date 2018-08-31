SpeciesNames = ['Temperature',$
                'H2O', $
                'O3',  $
                'N2O', $
                'HNO3']

GeoLoc = ['Pressure',$
          'Time',$
          'Latitude',$
          'Longitude',$
          'SolarZenithAngle',$
          'LocalSolarTime']

hdir='/aura3/data/HIRDLS_data/Datfiles/'
Hfile =hdir+'HIRDLS2_2000d276_MZ3_c1.he5'

;; load HIRDLS data all at once
hirdls = LoadAuraData(Hfile, [GeoLoc, SpeciesNames])


;; file header and tail for MLS
Mfileh =hdir+'MLS-Aura_L2GP-'
Mfilet ='_sAura2c--t_2000d276.he5'

;; loop over species
FOR is = 0,N_ELEMENTS(SpeciesNames)-1 DO $
BEGIN

SpeciesName = SpeciesNames(is)

;; construct MLS filename
Mfile = Mfileh + SpeciesName + Mfilet

;; load geolocation data for MLS from 1st species file
IF is EQ 0 THEN mls = LoadAuraData(Mfile, GeoLoc)

;; extend the mls structure with the species data
mls = LoadAuraData(Mfile, SpeciesName, mls)

END

HELP,/st, hirdls
HELP,/st, mls

END;;PROG
