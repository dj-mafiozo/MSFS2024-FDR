# Weather reference at runway contact

MSFS24 AMBIENT TEMPERATURE, AMBIENT PRESSURE and BAROMETER PRESSURE refer to the user's aircraft position. They are not airport reports. Temperature/local pressure can change with altitude and position; that alone proves neither an airport QNH change nor an incorrect altimeter setting. AMBIENT PRESSURE is inHg and is not sea-level QNH. BAROMETER PRESSURE is mb/hPa but is not automatically verified QNH for a particular airport.

AI context contains weather.ground_reference. For takeoff it uses the last sim_on_ground=true sample at or before liftoff; for landing, the first such sample at or after touchdown. The full trip is searched, beyond the analysis window. Later rollout or bounce samples do not replace the landing reference. UTC, temperature, pressures, wind, visibility and altimeter settings are preserved when available. Missing reference remains explicit; airborne extrema do not substitute for it. Ground state is a simulator flag, not independent proof of a specific wheel touching.

METAR remains a separate timestamped airport observation. The model is instructed to use the ground reference when discussing local weather and not accuse the pilot of an altimeter error solely from airborne ambient changes. Matching station/time and the actual pressure definition still matter; neither a remote report nor a local SimVar is silently called confirmed QNH.

VerifyGroundWeather uses synthetic trips to check full-trip search, takeoff/landing choice, first-contact preservation, missing references, payload definitions and prompt guidance. See [MSFS variables](https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/SimVars/Miscellaneous_Variables.htm).
