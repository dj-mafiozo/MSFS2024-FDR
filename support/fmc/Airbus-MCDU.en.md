# Fenix A32X and FlyByWire A32NX MCDU parsing

Full text comes from a running connected updated FlightPadFMC client. fmc/AirbusMCDUValuesU.pas parses assembled rows without a second aircraft connection. Raw text, parsed_json and timestamps remain in trip_fmc_screens. Analysis selects last observations before the event separately per provider/device, including older pages outside the analysis window; future observations are excluded.

| Page/label | Parsed reference |
|---|---|
| PERF TAKE OFF V1/VR/V2 | v1_kt, vr_kt, v2_kt |
| FLX/FLEX TO TEMP | flex_to_temperature_c |
| FLAPS/THS | takeoff_flaps, takeoff_ths_nose_up_deg |
| TRANS ALT; THR RED/ACC; ENG OUT ACC; RWY | transition_altitude_ft, thrust_reduction_altitude_ft, acceleration_altitude_ft, engine_out_acceleration_altitude_ft, takeoff_runway |
| PERF APPR VAPP/VLS/explicit VREF | vapp_kt, vls_kt, vref_kt; same-page VAPP minus VLS as approach_speed_additive_kt |
| QNH; TEMP; MAG WIND | approach_qnh_hpa/inhg, approach_temperature_c, approach_wind_magnetic_deg/kt |
| TRANS LVL; FINAL | transition_level_fl, final_approach |
| MDA/BARO/DH/RADIO | minimum_descent_altitude_ft, barometric_minimum_ft, decision_height_ft, radio_minimum_ft |
| Unambiguous LDG CONF | landing_configuration |
| INIT A FROM/TO, ALTN, FLT NBR, CI, CRZ FL/TEMP | from_to, alternate_airport, flight_number, cost_index, cruise_flight_level, cruise_temperature_c |
| INIT B ZFW/ZFWCG, BLOCK | zero_fuel_weight_cg_display, block_fuel_display |

CLB/CRZ/DES/GO AROUND titles are recognized and supported performance labels parsed, not every prediction. INIT A/B and page numbers have distinct history keys; B can be recognized from ZFW/BLOCK labels. TMPY/MOD remains pending and separate from executed values.

Label/value pairs are read from the same screen half or explicit inline values. Scratchpad and unknown pages such as F-PLN are not extraction sources. Absent labels add no observation; a visible blank/dashed/ambiguous/invalid value yields null, not the opposite column's number. QNH unit changes invalidate the other unit. MCDU pressure/temperature/wind are pilot/FMS entries, not current weather or METAR; wind is magnetic.

VLS is distinct from VREF; VAPP−VLS is not automatically wind_correction_kt. THS is positive UP, negative DN, unknown without explicit direction. Planned landing configuration does not prove actual flap position; a row offering CONF3 and FULL is not guessed. Unspecified mass/fuel units retain strings rather than guessed tonnes/kg/lb. Unsupported text remains raw. Typed SDK references have precedence.

Older raw Airbus screens are reparsed for context, preserving the original database history. Tests use synthetic Fenix/FBW screens, not a verified live flight. Supported FBW label layout follows its official PERF documentation; other Fenix layouts remain raw.
