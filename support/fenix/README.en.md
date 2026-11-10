Fenix A320 integration

[Interface translations](../../Translation.en.md)
=====================

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

The recorder automatically selects FenixA32X for aircraft titles containing
Fenix or the FNX_32/FNX A32 family identifiers. Generic aircraft retain standard
SimConnect telemetry; iFly continues to use its shared-memory SDK provider.

The native TFenixReader opens a separate, read-only SimConnect connection only
for Fenix. It reads 1748 catalog L-vars as FLOAT64/number in batches of 128,
below the SDK limit of 1000 entries per definition. SIM_FRAME updates supply
current values; database snapshots use the configured recording interval in ms.
No external application, WASM bridge, cockpit event transmission, or variable
writes are required. Only the existing SimConnect.dll is used.

Catalog source: Fenix common and aircraft-320 packages 3.0.0.7454, 3826 literal VAR_NAME* references across 55 model XML files (176 airplane model XML files audited), reduced to 1748 unique candidates. The main cockpit alone contains 772 names; panels and variants are modular attachments, including the separate CEO cockpit and CFM/IAE engines. JSON preserves source paths, template/animation contexts, per-file hashes and a catalog hash. Proprietary XML is not distributed.

300 names absent from current model declarations are retained as historical-only definitions, not subscribed. Playback discovers the keys actually recorded, preserving old circuit-breaker/renamed fields without adding new-catalog fields to old recordings. New snapshots identify both the cockpit hash and the complete model-inventory hash/package version. A missing declaration is not proof that the runtime L-var no longer exists.

New candidates include B_CONFIG_BARO_UNIT, N_CONFIG_ENGINETYPE, N_FC_BRAKE_LEFT/RIGHT and split autoland lamps. No automatic alias converts old boolean/annunciator values into new semantics. Existing gear/flap/FD-selection mappings remain declared in the new cockpit. No verified Fenix full-FMA, FD-command or automatically selected ECAM-page output is provided by these XML declarations.

Data flow:
- First state is a full baseline, later snapshots contain recursive changes.
- Chart parameters are named FenixLVar.<name>.
- AI receives raw fields, source/age/status and catalog definitions.
- S_MIP_GEAR: 0=UP/1=DOWN lever; overrides gear_handle_position.
- S_FC_FLAPS: handle detents 0..4; overrides flaps_handle_index. It is not a
  physical flap angle or a distinction between actual CONF 1 and CONF 1+F.
- A_FC_THROTTLE_*_INPUT is a 0..5 animation scale. It is recorded separately;
  it does not replace throttle percentage from SimConnect.
- S_FCU_AP1/AP2/ATHR are momentary buttons. I_FCU_AP1/AP2/ATHR are annunciator
  inputs. Neither is mapped blindly to the actual AP/A-THR active-mode flags.
- Physical gear positions, wheel contact, flight dynamics and weather continue
  to use standard SimConnect values where no verified equivalent is available.

No packet, invalid float, failed batch or expired data becomes null, never an
invented zero. Other healthy batches remain usable and optional errors cannot
stop the primary recorder. Data expires after max(1000, interval_ms)*3 ms of
transport age. Pause, aircraft title change and disconnect invalidate caches.
No fresh data for 30 seconds triggers an auxiliary reconnect with backoff.

SimConnect does not confirm whether each individual L-var exists. If it returns
zero for an absent name, this is indistinguishable from a genuine transported
zero. The saved validity text and AI context make this limitation explicit;
packet receipt alone is not proof that every name exists in a different Fenix
version. The local cockpit catalog identifies names for the supplied version.
No direct numeric FMC V1/VR/V2/VREF/VAPP fields were found in this catalog.

Regenerate the catalog after a Fenix update, then rebuild:
python tools/import_fenix_catalog.py "path/to/Cockpit_Behavior.xml" support/fenix/variables.json --previous support/fenix/variables.json
python tools/generate_fenix_catalog.py

Official SimConnect L-var documentation:
https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/SimConnect/API_Reference/Events_And_Data/SimConnect_AddToDataDefinition.htm

VerifyFenix uses a mock SimConnect DLL and tests actual transport calls, packet
parsing, provider selection, isolation, history, charts and analysis. A live
Fenix/MSFS session is still required to validate actual runtime variable values.

MCDU text is now available from a running updated FlightPadFMC Windows client
(full MCDU or Screen variant), through local read-only shared memory. See
../flightpad/README.md for installation, protocol, availability and tests.
