# Boeing FMC performance references

For now iFly 737 MAX and PMDG 737 NG (PMDGNG3) share the PERF INIT, N1 LIMIT, TAKEOFF REF and APPROACH REF parser. Transport remains provider-specific. This is a working assumption pending real PMDG screen comparison, not a claim of compatibility across every NG/MAX software revision.

fmc/BoeingFMCValuesU.pas parses displayed TStringList rows without pressing keys. Changes are stored with raw text/observation timestamps in trip_fmc_screens.parsed_json; older raw screens are reparsed for analysis without overwriting history.

| Page | Fields |
|---|---|
| TAKEOFF REF | Selected V1/VR/V2 from the right column (separate from QRH), takeoff_flaps_deg, takeoff_n1_left_pct/right_pct, takeoff_cg_pct, takeoff_trim_units |
| N1 LIMIT | assumed_temp_c, oat_c, left/right N1; active/selected takeoff/climb modes; active/selected rating_k, derate_pct, bump |
| PERF INIT | gross_weight_display, cruise_cg_pct, cruise_altitude_ft, planned_fuel_display, fuel_display/source, zfw_display, reserves_display, cost_index, transition_altitude_ft |
| PERF INIT weather | cruise_wind_deg/kt, isa_dev_f/c, top_of_climb_oat_f/c |
| APPROACH REF | Selected vref_kt and approach_flaps_deg from FLAP/SPD, separate wind_correction_kt |

ACT/SEL markers apply to their half of the row: left takeoff, right climb. `<TO   <ACT> <SEL>   CLB>` means active TO and selected CLB, not one of the alternatives below it. TO-1 is 10% derate, TO-2 20%, TO-B bump. Nominal K comes from the row above the marked option; missing rating is not invented.

`----/ +14°C` means no assumed temperature and OAT +14°C. `+45 / -10°C` gives assumed +45°C, OAT -10°C. N1 here is a limit/target, not measured engine speed. Trim uses stabilizer units, CG percent MAC. FL130 converts to 13,000 ft. `_display` mass/fuel keeps the number without guessing KG/LB. Empty/dashed/invalid fields become null, not zero. MOD pages do not replace executed references.

Recording information and AI choose the last observed value at/before each contact separately per device; without contacts, information shows the last recorded state. Navigating away does not refresh hidden pages. VerifyBoeingFMC covers ACT/SEL, derate/bump, temperatures, N1/flaps/CG/trim, PERF INIT/FL conversion and event-time information on synthetic screens. A real PMDG comparison and full simulator flights remain outstanding.
