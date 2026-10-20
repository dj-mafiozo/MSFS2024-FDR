FlyByWire A32NX Flight Deck API integration
=========================================

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Aircraft titles containing A32NX, or FlyByWire/FBW plus A320, automatically
select FBWA32NX. Generic A320 and FBW A380 are not matched. Fenix and iFly
retain their existing providers. No new runtime dependency or WASM is needed.

223 readable raw L-vars are compiled into aircraft/fbw/FBWCatalogU.pas. The catalog comes
from the user-supplied saved Flight Deck API HTML. Write-only commands, events
and entries marked deprecated are excluded (26 rows). Explicit {1|2} patterns
are expanded. Standard MSFS variables are not treated as custom L-vars.
Readiness and VAPP/managed-speed entries supplement the saved HTML using the
official custom-L-var reference linked from that page. Only variable-name and
unit/type facts are taken from that reference.

The existing Fenix reader and the FBW reader share TAircraftLVarReader: batches
of 128 FLOAT64/number entries, a dedicated read-only SimConnect connection,
SIM_FRAME updates and bounded nonblocking queue polling. Database snapshots
follow the configured interval in milliseconds. Invalid, failed, stale or
missing reply data is null. Received zero is retained as raw data, with the
same explicit limitation as Fenix: SimConnect cannot verify individual L-var
existence, so zero does not prove that a variable exists in a given version.

IS_READY must be 1 before standard-value overrides or the VAPP reference are
used. Initialization preserves generic SimConnect values. The readiness flag
only establishes JS readiness; it does not validate every individual variable.

Verified mappings:
- AUTOTHRUST_STATUS 0/1/2: off/armed/active; maps A/THR arm and active flags.
- Native FLAPS_HANDLE_INDEX 0/1/2/3/4 maps to standard MSFS 0/2/3/4/5, as the
  provided documentation specifies that standard slot 1 is unused. Raw native
  handle positions remain available separately; they are not surface angles.
- FCU speed display is used only when not dashed. Explicit mode distinguishes
  knots from Mach, preserving the generic target for invalid/blank values.
- FMS VAPP is saved in performance_reference.vapp_kt when positive and ready.
  It includes an MCDU pilot override and must not be called VREF. Zero/unset,
  stale or unready data produces a null reference. V1/VR/V2 are not invented.
- AP button lights do not override actual autopilot engagement flags.

Initial state is a full baseline; later database rows contain recursive
changes. Charts expose FBWLVar.<name>. AI receives raw values, field meanings,
readiness, provenance and performance_reference. Existing recordings do not
gain values that were not recorded. Title changes, pauses and disconnects
clear caches; failed auxiliary reads cannot stop basic recording.

Regenerate after updating the supplied documentation, then rebuild:
python tools/import_fbw_catalog.py "A32NX Flight Deck API - FlyByWire Simulations Documentation.htm" support/fbw/variables.json
python tools/generate_fbw_catalog.py

The source HTML SHA-256 is recorded in variables.json and the compiled catalog.
The original saved HTML and its assets are not bundled in the release.

Official reference:
https://github.com/flybywiresim/aircraft/blob/master/fbw-a32nx/docs/a320-simvars.md

VerifyFBW checks provider selection, transport calls, command exclusion,
readiness, flap conversion, A/THR, IAS/Mach/dashes, VAPP, failure handling,
isolation, deltas, chart history and AI. It uses a mock DLL; real FBW runtime
variable values still need confirmation in a running simulator session.

MCDU text is now available from a running updated FlightPadFMC Windows client
(full MCDU or Screen variant), through local read-only shared memory. See
../flightpad/README.md for installation, protocol, availability and tests.
