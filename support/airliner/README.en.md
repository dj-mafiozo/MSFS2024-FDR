# Common AIRLINER instrument L-vars

[Interface translations](../../Translation.en.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

The 31 catalog *AIRLINER* fields are instrument L-vars, requested as L:<name> through SimConnect_AddToDataDefinition, not standard A: SimVars. The catalog was extracted from 149 installed instrument files and includes AIRLINER prefixes and embedded A32NX_AIRLINER names. catalog.json preserves names, unit variants, source filenames and SHA-256 provenance. Sources include Asobo A320/737 MAX/747/787/CJ4 and installed FBW/FSS/LVFR instruments; this is not verified live Carenado coverage or an exhaustive enumeration of dynamically constructed names.

Initial references are AIRLINER_V1_SPEED, AIRLINER_VR_SPEED and AIRLINER_V2_SPEED in knots, AIRLINER_MINIMUM_DESCENT_ALTITUDE and AIRLINER_DECISION_HEIGHT in feet. Additional fields include VREF/VX/managed approach/green-dot speeds, phase, cruise/thrust-reduction/acceleration/transition altitudes, FLEX, takeoff flaps, thrust modes and TOC/TOD flags/positions. Exact definitions and supported reference mappings are in the manifest and generated telemetry/AirlinerCatalogU.pas.

A dedicated read-only SimConnect connection isolates optional requests. Each variable has its own definition/request; an unsupported field does not disable the others or stop primary recording. Missing/failed/NaN/stale data is null. Aircraft change, pause and stopped simulation reset the reader. Received zero cannot prove existence because SimConnect may return it for an absent L-var. These common values are secondary to verified aircraft SDK references; raw provenance/validity remains available.

The first snapshot is a baseline and later rows store changes with telemetry/sample time in the aircraft-data stream. Reconstruction exposes chart values and AI definitions. No cockpit commands or writes are sent.

To regenerate, supply the files found by `rg -l -i airliner <packages> -g '*.js' -g '*.xml' -g '*.html'` to tools/import_airliner_catalog.py. It extracts literal Get/SetSimVarValue/XML names, omits strings and dynamic constructions, and emits the manifest/catalog without copying manufacturer code. Rebuild after regeneration. tools/check_airliner_catalog.py checks PAS/manifest consistency; VerifyAirliner uses a mock DLL to check requests, failures, sentinels, history and precedence. Runtime values still need simulator verification.
