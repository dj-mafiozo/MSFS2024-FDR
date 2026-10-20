# GSX Pro recorded SDK values

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

The independent telemetry/GSXVarsU.pas reader requests 16 numeric L-vars through MSFS24 SimConnect. Each field has its own definition/request, so one unsupported variable does not block the others. No WASM module, control command or write is used.

The catalog includes boarding/deboarding/catering/refuelling/departure/deice service states; FSDT_VAR_Frozen for GSX pushback freeze (not simulator pause); current and total boarding/deboarding passenger counters; cargo activity and cargo percent for each direction; and raw deicing-fluid type. Current passenger counters may reset for another bus. Cargo percent is averaged between loaders. The current manual uses FSDT_GSX_DEICE_STATE, not the older DEICING_STATE name.

Service states: 1 callable, 2 unavailable, 3 bypassed, 4 requested, 5 active, 6 complete. Zero does not establish GSX presence or a valid service state: an absent L-var can also return zero. Status is received_not_verified, partial or unavailable. Invalid/missing values are null and data older than three seconds is not current.

A full baseline and later changes are stored under gsx_lvars in trip_aircraft_data, linked to the telemetry sample/time. Identical states are omitted. Playback exposes GSX.* chart/inspector values, preserving gaps; analysis receives definitions and reconstructed data. Recording spans the loaded flight, including boarding before start and deboarding after shutdown. Counters do not replace measured aircraft payload, mass or fuel.

This is an initial service/counter catalog, not every GSX variable or vehicle state. Source: DEVELOPERS — Interfacing with GSX in the official 291-page manual, pages 106–108; all 16 names were found. PDF SHA-256: ee4ae760168e7045d3598905d3e1b4a3ccb56337fdb50586e7456c3dc4feafc1. The proprietary manual is not bundled. VerifyGSX uses a mock SimConnect DLL; live GSX values have not been verified.
