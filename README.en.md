# MSFS2024-FDR — Delphi 10.2 VCL Win64

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

## Separate map and chart windows

`aMapWindow` and `aGraphWindow`, shared by menu/toolbar, detach the complete MapPanel/GraphPanel contents into resizable windows. Frames fraMapU/fraGraphU keep the existing layout and the same control instances. The corresponding main panel hides; closing the window or repeating the action returns the frame. Both may be detached together. Trip selection, cursor, viewport and tools remain synchronized; the docked map height is retained. The chart dialog owns its own ImageList and ActionList, including Move/Hide/OK/Cancel. Cancel preserves the working-copy boundary.

Every project-owned README and Testy has a Polish default and .en.md/.de.md/.es.md counterparts with navigation. Run `python tools/check_documentation.py` to check coverage. Third-party documents and legal texts retain their originals.


Chart selection/order now lives in the separate **Configure charts** dialog (sliders icon). Filtering preserves checks, arrows reorder charts and the delete icon hides one. OK applies/persists the working copy; Cancel leaves it unchanged. Unavailable aircraft-specific preferences are retained. The obsolete parameter-panel height is no longer used; remaining panel/map sizes still persist. The manually redesigned interface and MSFS2024-FDR project name are preserved.

Icons are embedded in DFM; no Icons directory is required at runtime. Rebuild from original assets with `tools/rebuild_toolbar_images.ps1`. PL/EN/DE/ES are available through language actions. All three image lists (34 main-window, 6 SimBrief and 3 chart-dialog icons) preserve alpha transparency.



A native flight recorder, viewer and analysis application for Microsoft Flight Simulator 2024. The repository is currently private. The first implementation was based on the Qt project MSFS-Flight-Data-Recorder. The recording pipeline, architecture, database handling, interface, aircraft integrations and analysis have since been extensively rebuilt and expanded. Attribution remains in [NOTICE.en.md](NOTICE.en.md); the repository preserves AGPL-3.0 in LICENSE.

## Running and configuration

Build with Delphi 10.2 and run `bin/MSFS2024-FDR.exe`. Keep the Win64 SimConnect.dll, sqlite3.dll and WebView2Loader.dll beside it. WebView2 Runtime is needed for rendered Markdown reports. Qt is not used. Map and charts are VCL/GDI controls; recording uses a private FireDAC SQLite connection in a worker thread. See [runtime dependencies](runtime/README.en.md).

Polish is the default interface language. Select Polish, English, German or Spanish in **Tools → Language** or **Settings → General**. Selection is persisted as `[ui] language=en-US` in settings.ini. Codes are `pl-PL`, `en-US`, `de-DE` and `es-ES`; unknown codes fall back to Polish. Menu, forms, dialogs, chart hints, recording information and SimBrief sections are translated. Raw FMC text, API keys, SimVar/L-var identifiers, SQL/JSON schemas, flight data and previously generated reports remain source data. Analysis prompts/reports intentionally remain Polish, as requested. Details: [localization](translations/README.en.md).

The menu exposes database opening, PLN import, KML export, recording, refresh, route fit, flight information, settings and language selection. Existing toolbar actions remain available. The former “AI settings” action is now “Settings”. Use `bin/settings.example.ini` as a template; do not commit private settings, recordings, credentials or logs.

## Recording

Automatic recording starts after a flight is loaded and the first valid telemetry sample arrives, even with engines off. It continues through shutdown/deboarding until the flight ends, the menu is entered, the aircraft changes or the simulator disconnects. Pause does not end a trip and does not add samples. Manual Stop disables automatic recording. The interval is in milliseconds, default 500; 250 is a target, not a guaranteed cadence.

The worker owns all recording and auxiliary readers. UI commands are queued; UI status is a copied snapshot. SQLite uses WAL and separate read/write connections. Closing or switching databases waits for the recorder. Do not delete WAL/SHM files or copy only an active .db file as a backup. Main telemetry snapshots are complete, as in the original database; optional SDK streams use baselines and recursive deltas. Identical optional data, screens and FSHud messages are not duplicated.

SimConnect polling drains the receive backlog before expensive processing, preserving the latest sample and ground/air transitions. Unknown surface type 255 does not stop airborne recording. Optional SDK errors are isolated from the main recorder; telemetry definition/request errors remain fatal and logged. Flight lifecycle Flow events are used when exported by SimConnect.dll; otherwise FlightLoaded and a ten-second state check provide compatibility. This fallback still needs a complete live end-of-flight test.

The generated SimConnect catalog contains 709 definitions: 110 numeric fields, 70 packed flags, 32 values per engine for up to 16 engines, plus metadata/times. The recorder observes 84 cockpit events without sending or masking commands. Event flood filtering and engine/gear/AP/AT/weather data are documented in [tests](Testy.en.md).

## Aircraft and auxiliary data

Aircraft title selects a provider. Verified aircraft-specific values take precedence over generic SimConnect equivalents; unsupported values retain generic telemetry. Missing/stale values remain null, never fabricated zeros.

| Provider | Read source and details |
|---|---|
| iFly 737 MAX | Official SDK 1.5 shared memory; display digits assembled into values; FMC text/styles/lamps stored separately. [Displays](support/fmc/IFly-display-storage.en.md) |
| Fenix A32X | Dedicated read-only SimConnect connection, 1203 catalog L-vars. [Fenix](support/fenix/README.en.md) |
| FBW A32NX | 223 readable Flight Deck API L-vars, readiness-aware mappings. [FBW](support/fbw/README.en.md) |
| PMDG 737 NG3 | Official read-only Client Data SDK and both CDU screens. [PMDG](support/pmdg/README.en.md) |
| Common AIRLINER | 31 catalog instrument L-vars, independent of aircraft provider. [Catalog](support/airliner/README.en.md) |
| GSX Pro | 16 read-only service/counter L-vars. [GSX](support/gsx/README.en.md) |
| FSHud | Optional local panel protocol, localhost:19786, filtered state/messages with timestamps. [FSHud](support/fshud/README.en.md) |

SimConnect may return zero for an absent L-var; receipt alone cannot prove existence. Provider status/provenance is retained. The application never sends cockpit commands through these readers.

FMC/MCDU screens have timestamped raw text and conservative performance parsing. iFly and PMDG share the Boeing page parser as a working assumption pending PMDG live comparison. TAKEOFF REF reads selected V1/VR/V2 separately from QRH. APPROACH REF reads selected FLAP/SPD, not an arbitrary VREF table row. PERF INIT and N1 LIMIT add weights, fuel, CI, cruise/transition altitude, CG, trim, assumed/OAT temperatures, N1 limits, ACT/SEL, derate and bump. Hidden pages are last observed values, not continuous memory reads. [Boeing fields](support/fmc/Boeing-performance.en.md).

Fenix/FBW full MCDU text requires a running, connected, updated FlightPadFMC Windows client. Local shared memory works between Win32 exporter and Win64 recorder. INIT/PERF pages provide Airbus performance references; VLS is distinct from VREF. [FlightPad](support/flightpad/README.en.md), [Airbus parser](support/fmc/Airbus-MCDU.en.md).

## Viewing and analysis

Double-click a recording to open it. Select parameters without an eight-chart limit, apply the selection, and reorder them on the chart-order tab. Drag pans time; Shift+drag selects a zoom range; Ctrl+wheel zooms. Buttons and the pan slider provide equivalent navigation. The timeline, chart cursor, map marker and read-only inspector synchronize. Splitters resize panels; dimensions persist. Settings offers a single restore-default-layout action.

The map supports drag/wheel navigation, optional OSM tiles with attribution/cache, route overlays, contact markers, PNG capture and KML export (altitude converted from feet to metres). All-routes view colours trips by group. Groups can be created, renamed, assigned and removed without deleting flights. Large history/flight loads still run on the UI thread and may temporarily block it.

Runway association uses SimConnect facilities, nearby candidates, displaced thresholds, local metric geometry and true heading. Unmatched airports/runways remain empty. It requires further live verification on complex airports and crosswind operations. Rotation/touchdown distances are provided in metres to analysis; liftoff is not automatically the exact start of rotation.

Flight information shows identifiers, airports/runways, times/duration, data counts, event METARs, assigned SimBrief evidence and last observed FMC references before each contact. Missing data remains explicit.

Codex CLI (ChatGPT account), Gemini and Ollama are available in Settings. Analysis runs in the background, stores reports in the database and renders Markdown through WebView2. Shift+click regenerates a cached report. Codex requires `codex login` and a native codex.exe; Gemini needs its configured API key. Ollama discovers installed models via GET /api/tags and sends POST /api/chat with an explicit Polish task, context limit and timeout. No model is installed automatically. [Ollama](support/ollama/README.en.md).

Takeoff and landing have separate before/after analysis windows, default 60/30 and 180/30 seconds. Floating-point context is rounded to at most three decimals and recursive deltas use a ±0.0015 deadband against the last emitted state. Raw recordings are not rounded by this analysis filter. Short flap-detent transients are explained as possible analog-controller effects. AP/AT, separate gear legs, weather, engine parameters and aircraft references are supplied when available. Stable final-approach A/T speed may be an explicitly qualified reference when VREF is absent; it is not silently renamed VREF. [Precision](support/analysis/precision.en.md).

Ambient temperature/pressure are local at the aircraft, not airport METAR/QNH. Takeoff reference is the last on-ground sample at/before liftoff; landing reference is the first on-ground sample at/after touchdown, searched across the full trip. Missing reference is explicit. Event-time METARs are separate observations. [Weather](support/analysis/ground-weather.en.md).

## Plans, SimBrief and OFP

The native EFB planner is read through GET_EFB_ROUTE and the supplied Community bridge, localhost:19787/efb-route; PLN export/import is a fallback. Identical routes are deduplicated and changes retained per trip. Procedures without coordinates are not invented. [Flight plans](FLIGHT-PLANS.en.md).

Configure your own SimBrief username/Pilot ID. Fetching the latest plan is separate from attaching it: route/airport and available aircraft/flight identifiers must match. Older generation dates are optionally allowed only with supporting route/parameter evidence; the stored evidence marks reuse. Test routes are not assumed to be the account's current plan. Raw response and OFP are saved with the recording.

The SimBrief tab shows collapsible VCL groups for flight info, plan summary, loadsheet, route, remarks, ATC plan, LIDO OFP preview, runway analysis, maps and airport/alternate sections. The same frame opens in a resizable separate window. Multiline content grows to its line count, and the outer view handles the wheel. API property-path prefixes are not shown. Flight-plan downloads are omitted. OFP and raw externally supplied content retain their original language.

## Existing databases and diagnostics

The application uses SQLite, independently of the earlier iFly/Firebird recorder. Existing Qt tables remain readable; missing columns are added. Legacy snapshots without primary keys are rebuilt transactionally, retaining existing engine values/bits/arrays. Timezone correction is versioned and runs once. Before legacy correction/rebuild the SQLite backup API creates a coherent `.before-native-<GUID>.db` backup. Do not run two recorders on the same database. See [diagnosis](DIAGNOSIS.en.md).

`msfs_fdr_debug.log` and its `.old` predecessor contain state and failures; verbosity accepts FATAL/WARNING/INFO/TRACE/PROFILE. Optional source/status limitations are recorded rather than hidden.

## Building and testing

Open `src/MSFS2024-FDR.dproj` (Win64) or run `powershell -ExecutionPolicy Bypass -File build.ps1`. Install the i18n package beside this repository in `../i18n/Packages`, or pass `-I18nRoot` to scripts. WebView4Delphi source is resolved from vendor or the sibling FSHudPanel dependency. Runtime DLLs can come from the SDK/local runtime folder. No proprietary aircraft SDK binary is distributed.

```powershell
python tools/check_translations.py
python tools/check_project.py
powershell -ExecutionPolicy Bypass -File test.ps1
python tools/check_dependencies.py
python tools/package.py
```

Source units use `NameU.pas`; forms use `frmNameU.pas/.dfm`. `src` is grouped into core, data, recording, simconnect, telemetry, aircraft/provider, fmc, flightplan, weather, analysis, visualization, forms, frames and i18n. Every Pascal unit is explicitly listed in DPR/DPROJ. Translation text is loaded from MSFS2024-FDR.i18n beside the executable; no i18n BPL is required. See [test coverage and live limitations](Testy.en.md). Automated fixtures do not establish real-aircraft integration or AI report quality.

The sole catalog is `translations/MSFS2024-FDR.i18n`; builds copy it beside the executable. No Pascal catalog generation is required. Settings use General, Analysis and AI providers tabs, with Codex/Gemini/Ollama subpages. Compiler intermediates go to `.build/<Platform>/<Config>`; test DCUs use platform-specific Tests directories. Menu items share all toolbar actions. Report captions distinguish takeoff/landing, including cached reports.

## Recording groups

The group list filters recordings. The empty entry includes all recordings, including ungrouped trips. Refresh preserves the filter. Assignment opens a separate dialog showing the current group; OK saves, Cancel preserves the assignment. “Ungrouped” clears the assignment.

[MichaelHsu170/MSFS-Flight-Data-Recorder](https://github.com/MichaelHsu170/MSFS-Flight-Data-Recorder) — AGPL-3.0.

## Toolbar frames — 2026-10-18

Toolbar actions and image lists now belong to fraMap/fraGraph and are stored in their DFMs. The main menu uses the same actions; main retains references and window switching. The chart frame handles zoom. In detached windows, btnGraphWindow and btnMapWindow return the same frame to frmMain. Icon indices remain compatible with the main menu. TFrame DFM properties and invalid chart-configuration uses entries were also corrected.

## Screenshots

Screenshots show the real application running on synthetic test data, not a recorded real flight.

![Main window: map, charts and inspector](docs/screenshots/main.png)

![Charts in a separate window](docs/screenshots/charts-window.png)

![About](docs/screenshots/about.png)

## CHM help and F1

F1 or Help → Help contents opens the active view topic. Topics cover getting started, map, charts, analysis, settings and About. PL/EN/DE/ES follow the interface language.

Build: `python tools/build_help.py --require-chm`. Requires HTML Help Workshop; set HHC_EXE to override the hhc.exe path. The full build.ps1 also builds help. Without the compiler, local HTML is available; F1 falls back to HTML when CHM is missing. Output: bin/help. Distribute the entire help directory beside the EXE.

Rebuild small menu icons using `powershell -ExecutionPolicy Bypass -File tools/rebuild_toolbar_images.ps1 -List small`.

## Readable parameter names

Charts, selection/order lists and the value inspector show descriptions with units, e.g. `Aircraft altitude [ft]` and `N1 speed — engine 2 [%]`. Labels follow the interface language. Search accepts both labels and raw identifiers; tooltips show both.

The database, flight model and preferences retain original identifiers. Complete captions cover 212 standard parameters plus AIRLINER, GSX and FSHud. Other SDK/LVAR names are split into readable words while preserving provider, acronyms and indices. Unknown fields do not receive guessed units. Fractional 0–1 values are not mislabeled as percentages.


### Display units

In Settings → Units choose a target for each source unit, e.g. ft → m, lb → kg, US gal → l. Keeping the source unit disables conversion. Charts (curves, scales, cursor) and the parameter inspector update, including detached windows. Stored data and analysis inputs retain their original units. Unknown SDK units are never guessed.
