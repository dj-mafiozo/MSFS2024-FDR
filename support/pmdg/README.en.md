PMDG 737 NG3 SDK integration

[Interface translations](../../Translation.en.md)
===========================

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

PMDG 737 NG aircraft titles select PMDGNG3 automatically (737-600/-700/-800/
-900, BBJ and cargo variants from the supplied model list). Other manufacturers,
PMDG 777 and PMDG 737 MAX do not select this provider.

The official user-supplied PMDG_NG3_SDK.h defines a 916-byte PMDG_NG3_Data
structure with 494 named scalar/string fields after array expansion. Reserved
padding is not telemetry. Generated offsets follow default MSVC pack(8), with
maximum alignment 4 because this structure has no double or pointer fields.
The generator cross-checks ctypes offsets. An independent clang-cl compilation
against the unmodified header verified sizeof and every member offsetof.

The native reader opens a separate read-only SimConnect connection and maps
only PMDG_NG3_Data, PMDG_NG3_CDU_0 and PMDG_NG3_CDU_1. It subscribes ON_SET plus
an initial ONCE request. It never maps controls, writes client data, sends
cockpit events or changes simulator variables. Each received block replaces
its cache atomically; optional CDU failures do not stop main SDK recording.

Enable broadcasting in the aircraft's active options file:
[SDK]
EnableDataBroadcast=1
EnableCDUBroadcast.0=1
EnableCDUBroadcast.1=1

The SDK header calls this 737NG3_Options.ini. In the inspected MSFS 2024 737-600
installation the active file is 737_Options.ini, under:
LocalState/WASM/MSFS2024/pmdg-aircraft-736/work/
All three options were already enabled; no simulator configuration was changed.
If changing them in another installation, reload the aircraft afterwards.

Data handling:
- Database snapshots use the configured millisecond interval; first state is
  full, later rows contain recursive changes. Charts use PMDGNG3.<field>.
- SDK data, field definitions, update ages, FMC references and both optional
  CDU screens are included in analysis context.
- FMC V1/VR/V2/LandingVREF are in knots. Zero is unset and becomes null in
  performance_reference, while raw SDK zeros remain available for inspection.
- FMC landing altitude -32767 is unavailable. Other negative elevations are
  valid. Negative TOD/destination distances are unavailable; TOD zero is valid.
- MCP IAS/Mach selection respects blank flags and MCP power. Gear lever OFF
  is retained as raw state 1 and does not overwrite the standard up/down handle.
- A/THR active uses actual servo connection; AFS pitch/roll control supplies
  autopilot_master (including CWS). This does not assert CMD/LNAV/VNAV modes.
- SDK fuel quantities are pounds regardless of the WeightInKg display option.
- Flap pointers are raw SDK indications, not a fabricated physical angle or
  handle index. FMC takeoff/landing flap entries are planned configuration.

SDK ON_SET does not provide a separate heartbeat. Stable state is retained
until a new broadcast, not invalidated just because switches did not change.
data_update_age_ms is the age since the last SDK packet, not proof of a fresh
measurement. Pauses, aircraft title changes and connection loss clear caches.
Missing main data retries with backoff and preserves generic SimConnect data.

CDU payloads are 1009 bytes: 24 columns x 14 rows x (symbol/color/flags) plus
powered. Columns are the outer array dimension. Analysis receives 14 readable
rows, power state and exact raw cell bytes (hex), preserving colors and font
flags. Special arrow symbols are decoded. Unpowered screens must not be used
as current FMC inputs. Typed SDK references retain priority. Displayed Boeing pages are also parsed through the shared iFly/PMDG parser as a working assumption pending live PMDG comparison.

Regenerate after obtaining a new SDK header, then rebuild:
python tools/generate_pmdg_catalog.py "path/to/PMDG_NG3_SDK.h"
The original proprietary header is not bundled; fields.json records its SHA-256
and explicit member/field offsets. The generator emits .build/VerifyPMDGLayout.cpp
for optional compilation against that original header.

VerifyPMDG uses a mock SimConnect DLL to test actual API calls, IDs/definition
sizes, packet validation, primitive decoding, FMC sentinels, MCP blank/power,
gear OFF, CDU column-major layout/arrows/colors, cached state, provider changes,
delta history, charts and AI. ProbePMDG.dpr is an optional live read-only probe.
The simulator inspected during development was flying iFly, so live PMDG data
could not be verified without changing the user's aircraft. No aircraft change
was performed.
