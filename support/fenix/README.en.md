Fenix A320 integration

[Interface translations](../../Translation.en.md)
=====================

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

The recorder automatically selects FenixA32X for aircraft titles containing
Fenix or the FNX_32/FNX A32 family identifiers. Generic aircraft retain standard
SimConnect telemetry; iFly continues to use its shared-memory SDK provider.

The native TFenixReader opens a separate, read-only SimConnect connection only
for Fenix. It reads 1203 catalog L-vars as FLOAT64/number in batches of 128,
below the SDK limit of 1000 entries per definition. SIM_FRAME updates supply
current values; database snapshots use the configured recording interval in ms.
No external application, WASM bridge, cockpit event transmission, or variable
writes are required. Only the existing SimConnect.dll is used.

Catalog source: 2096 non-empty VAR_NAME* parameters in Cockpit_Behavior.xml,
reduced to 1203 unique names. The JSON preserves templates, parameter names,
animation context and source XML SHA-256. The source XML is not distributed.

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
python tools/import_fenix_catalog.py "path/to/Cockpit_Behavior.xml" support/fenix/variables.json
python tools/generate_fenix_catalog.py

Official SimConnect L-var documentation:
https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/SimConnect/API_Reference/Events_And_Data/SimConnect_AddToDataDefinition.htm

VerifyFenix uses a mock SimConnect DLL and tests actual transport calls, packet
parsing, provider selection, isolation, history, charts and analysis. A live
Fenix/MSFS session is still required to validate actual runtime variable values.

MCDU text is now available from a running updated FlightPadFMC Windows client
(full MCDU or Screen variant), through local read-only shared memory. See
../flightpad/README.md for installation, protocol, availability and tests.
