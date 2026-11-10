# Flight Director replay

Standard capture appends AUTOPILOT FLIGHT DIRECTOR PITCH, BANK, PITCH EX1 and BANK EX1 in radians. Filtered channels take priority; EX1 is used only when a filtered value is absent/non-finite. A recorded zero remains a zero. The standard references use positive-down/left conventions, converted against actual recorded attitude to nose-up/right deviations for rendering.

B38M uses standard command angles with the recorded captain iFly FD switch when available; otherwise standard FD ACTIVE. It does not infer command angles from MCP lamps. Settings / Debug can disable B38M FD independently. A constant zero is not automatically classified as an unpopulated add-on channel.

A320 uses recorded FBW FMGC ARINC pitch/roll deviations and captain EIS selection when native engagement words are present. Invalid native SSM never falls back to an unrelated standard command. Otherwise standard commands and the Fenix captain FD selection, when recorded, are used. Each Airbus crossbar has independent validity. TRK/FPA crossbars are suppressed; the Flight Path Director bird and yaw guidance remain future work. Bars are hidden without valid attitude. This is pitch/roll FD replay, not a claim to implement every Airbus guidance symbol or failure annunciation.

Historical audit (2026-10-25, read-only): the local iFly B38M recording has 4568 samples and none of the four angular channels. Its standard packed FD ACTIVE flag is zero throughout; that does not prove proprietary iFly FD/AFDS was off. Missing historical angular samples remain NaN / SQLite NULL and cannot be recovered by schema migration.

VerifyFlightDirector tests standard radians/signs, selection/source priority, independent native ARINC validity, zero versus missing and SQLite NULL roundtrip. VerifyPFD737 and VerifyAirbusDisplays render synthetic command examples. ProbeFlightDirector reads standard channels for eight seconds without recording or controlling the simulator. The current probe returned SimConnect_Open E_FAIL because no simulator connection was available: live iFly/Fenix standard-channel population is unverified.

References:
- [Microsoft SimVar reference](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-autopilot-and-assistant-variables/)
- [Microsoft FD provider: reference sign conventions](https://github.com/microsoft/msfs-avionics-mirror/blob/main/src/garminsdk/components/nextgenpfd/horizon/FlightDirectorDataProvider.ts)
- [FBW native FD command/selection rendering](https://github.com/flybywiresim/aircraft/blob/master/fbw-a32nx/src/systems/instruments/src/PFD/AttitudeIndicatorFixed.tsx)
