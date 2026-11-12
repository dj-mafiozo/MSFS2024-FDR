# Tests — MSFS2024-FDR Delphi VCL

[Polski](Testy.md) | [English](Testy.en.md) | [Deutsch](Testy.de.md) | [Español](Testy.es.md)

## Simulator compatibility and switch values

VerifyFlapsHandle, VerifyParameterValues, VerifyUI and VerifyChartView — PASS: isolated ICAO switch, six standard A320 states vs five SDK lever positions, 1+F, GA and negative Stemme detents, TFDi/SkySim MD-11 differences, conditional Draco/ULAC, model-count mismatch, missing values and empty fallback. A fifth Python test checks generated-unit consistency. Synthetic validation only, not flights in every aircraft; 60 codes remain explicitly unverified.

DisplayValue re-audit — PASS: four Python parser/provenance/generator tests; VerifyParameterValues, VerifyAircraftSDK, VerifyFenix, VerifyFBW, VerifyAddonLVars, VerifyPMDG and VerifyPMDG777. Includes full-width separators, digit ranges, undocumented enum gaps, XML labels, RTP glyphs, CSS press/release and numeric fallback. Scanned 335 XML files; 14 malformed files contributed only independently valid UseTemplate fragments. Static analysis and mocks; no live flight.

VerifyUI and VerifyGSX — PASS: DFM progress bars, Requested visibility, active/completed states, backward seeks, missing data, passenger/cargo progress and fuel-truck counter/reset. Synthetic tests and SDK mock; no live GSX trial.

VerifySimulatorVersion, VerifySubscriptions, VerifyRecorderWorker, VerifySession, VerifySimBacklog, VerifyFlightPlan and VerifyRecordingWorker: PASS with mocks/synthetic telemetry. MSFS24 is accepted after OPEN; MSFS20/FSX/P3D, unknown and truncated replies receive no subscriptions. Reconnection restores compatibility. VerifyParameterValues, VerifyParameterNames and VerifyGSX: PASS for flap/autobrake labels, booleans, distinct A320/737/777 detents, unknown values, NaN, untranslated cockpit labels and localized GSX stages/progress. Cargo progress is a percentage, not a bag count. No new live simulator or GSX trial.

## A320 PFD and ECAM — Fenix / FBW

VerifyAirbusDisplays — PASS: 13 pages and PNG renders, actual display vs selector, 11/12 mapping, forward/reverse seek, manual selection persistence, valid/zero/invalid ARINC SSM, active CPC, FBW N1 precedence, SQLite SDK delta replay, clearing, detach/icons, RTL/LTR and resizing. VerifyInstrumentFrames — PASS: Fenix/FBW ↔ B38M with both slots detached, geometry and three-screen synchronization. VerifyFBW — PASS after rebuilding MockFenixSim; final missing-batch assertion generalized for catalog growth. VerifySixPack and VerifyViewState — PASS. Inspected PFD/EWD/HYD PNGs; no live flight, comparison against running Fenix/FBW or IDE designer trial.

Recorded follows captured `A32NX_ECAM_SD_PAGE_TO_DISPLAY`, not the manual selector: 11 is CRUISE, 12 STS. Manual page selection survives seeking; Recorded resumes following. Added 47 read-only FBW fields. ARINC429 values require normal-operation SSM; missing/invalid values show `--`. Initial data-driven reconstruction, not full DMC/FWC emulation: no invented FMA modes, FD commands, warning/STS text, valve states or system health. Available Fenix XML does not confirm the displayed automatic page; Recorded remains unavailable there, while all manual pages work. Oil quantity uses percent, without guessing quart capacity. ECAM uses labeled Airbus units (kg, kg/h, psi, C); PFD tapes respect configured units.

[ECAM](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/ecam/), [E/WD](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/ecam/ecam-e-wd/), [SD](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/ecam/sd/), [PFD](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/pfd/), [FBW SD source](https://github.com/flybywiresim/aircraft/tree/master/fbw-a32nx/src/systems/instruments/src/SD).

## Import Qt databases

`VerifyLegacyExport` — PASS: import Qt-compatible file into the library, replay 3 samples/6 engine rows, exact N1, unavailable extensions as NaN and preserved +02:00. Multi-flight Qt fixture split into two `.mfzr` with 3 samples each and no leakage; repeat import is idempotent, both source SHA-256 hashes unchanged. VerifyInstrumentFrames checks DFM dialog/menu; VerifyRecordingImport covers older import/preview regressions. Synthetic SQLite/VCL, no live flight.

## Export a flight to the original Qt application

`VerifyLegacyExport` — PASS: two source flights, only selected flight exported; 3 samples, 6 linked engine rows, selected contacts/event/group; Unicode and unrounded N1. Seven tables, 130 trip_data and 35 trip_engine_data columns, no extensions/reports. Unchanged read-only source SHA-256; source overwrite, missing trip and a mid-copy NOT NULL violation preserve the old destination and remove temporary output. Independent Python sqlite3 comparison checked telemetry names/types/order against the cloned Qt header. VerifyInstrumentFrames covers DFM action/menu/dialog loading. No manual Qt GUI opening; compatibility verified through schema and SQLite queries.

## Stable instrument/timeline layout

The slider panel remains directly in CenterPanel; maps, charts, instruments and their splitters belong to a separate ViewsPanel declared in DFM. The instrument splitter can no longer select the timeline panel as its resize target. Restoring views also reestablishes instrument/separator ordering.

VerifyInstrumentFrames: PASS — separate containers, no view/timeline overlap and splitter immediately above instruments after 650/750/850 window-height changes and PFD/EICAS detach/return. VerifyDetachedViews and VerifyViewState cover detach, synchronization and saved configuration regressions. Synthetic VCL/SQLite/INI only; no live flight or manual IDE designer trial.

## Engine/EICAS panel scaling

Removed ScrollBox from both frames and inherited frmMain DFM entries. Displays fill the client area below their toolbar. EICAS preserves aspect ratio; generic gauges render a complete buffered layout, select columns for available dimensions and scale the whole layout. Samples never resize the control. PFD/EICAS splitter explicitly uses alLeft, width 6, MinSize 100, AutoSnap=False and rsUpdate, persisting width on movement.

`VerifyInstrumentFrames`, `VerifyEngineGauges`, `VerifyB38MEICAS`, `VerifyViewState` — PASS. Added assertions for absent ScrollBoxes, alClient and exact remaining height, panel–splitter–panel adjacency, disabled AutoSnap and synchronized dock/float behavior. Synthetic VCL/SQLite/INI only; no live flight or manual IDE designer trial.

## ICAO frame selection and shared PFD scales

- `VerifyInstrumentFrames` — PASS: B38M selects `ikB38MPFD`; a MAX 8 title alone does not; B736/B737/B738/B739 stay generic. Separate DFM frames replace six-pack and engine instruments. B38M → B738 → B38M with two detached windows preserves bounds, parents, timeline and 0/1 icons. Return button/X, GA fallback and IAS tape pixels passed.
- `VerifySixPack`, `VerifyPFD737`, `VerifyB38MEICAS`, `VerifyEngineGauges`, `VerifyDetachedViews`, `VerifyViewState` — PASS. ILS pixel coordinates follow the new layout while retaining direction, independent validity, GPS exclusion and hollow end-stop checks. 1000 cursor changes with 3003 labels still perform no index searches; changing ICAO invalidates the profile cache. Six view slots replace seven; no independent `view.pfd737` remains.
- Fixed `sync_test_projects.py`: missing `DelphiCompile` could report successful MSBuild without compiling an EXE. New test and regressions were compiled and executed after the fix. Registered in `Tests.groupproj`; units/frame metadata listed in DPR/DPROJ.
- Win64 Debug/Release and Setup built; project/version/documentation/translation checks passed. Synthetic VCL/SQLite/INI and render verification only; no live flight or IDE designer trial. Earlier sections below describe previous stages; the current frame selection is as documented here.

## B38M EICAS and additional parameters

- `VerifyB38MEICAS` — PASS: automatic selection by iFly MAX 8 title or recorded B38M ICAO regardless of livery, generic gauges for other aircraft; independent engine N1/N2/EGT/FF/oil/vibration, raw psf versus 53 psi, flap detents/nonlinear needle, density-dependent fuel mass and NaN instead of invented zero.
- Same test — PASS: amber fuel-filter SDK lamp and independent ENG FAIL pixels, clearing stale messages, no engine warning from APU oil lamp or zero pressure alone. Starter is labeled STARTER ACTIVE, not START VALVE OPEN. Visually inspected `tests/b38m-eicas-preview.png`. Aspect changes, RTL/LTR, forward/backward seek, detach/return of the same frame and 0/1 icons passed.
- SQLite — PASS: precise oil quantity 0.813, TAT 24.37 and center fuel 1250.75 round-trip. Rebuilt an older schema while preserving rows; read-only replay and AI context tolerate missing columns as NaN/NULL and retain N1=84.7. File SHA-256 is identical before/after preview. Writable reopening migrates schema without replacing historical missing values with zero.
- `VerifySubscriptions` — PASS: oil quantity only for existing engines, TAT and center tank while active, still only three identity fields when idle; lifecycle ordering, unsubscribe and stale packets pass on a mock DLL. `VerifyPort`, `VerifyRecordingImport`, `VerifyDetachedViews`, `VerifyViewState`, `VerifyPFD737`, `VerifyEngineGauges` and `VerifyContext` also passed.
- Appended catalog fields preserve earlier indices and use REAL storage; readable captions cover 32 locales. Registered unit/test in DPR/DPROJ/Tests.groupproj. No live flight or full iFly warning-logic comparison. Inspected SDK 1.5 exposes no confirmed START VALVE OPEN, THRUST or FUEL FLOW source here. Oil capacity ratio and units were checked against the [official SDK](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-engine-variables/); these are not litres or engine limits.

## Responsive PFD and separate PFD 737

- `VerifySixPack` — PASS: a 900×200 host retains a full-height horizon and pointer V/S with a −677 ft/min readout. Altimeter geometry, stable VSI, cache, ILS, missing data, units and docking regressions pass. Scales do not change with each sample. `tests/pfd-wide-preview.png` was visually inspected.
- `VerifyPFD737` — PASS: native DFM frame and renderer; raw IAS/ALT and pitch sign, LOC/GS diamond pixels, fixed nonlinear VSI (1000 → 0.5; 2000 → 0.75; 6000 → 1), sign/clamping, NaN, standard/wide/narrow/tiny aspect ratios, forward/backward timeline, same detached instance, 0/1 icons and physical LTR under Hebrew. `tests/pfd737-preview.png` was visually inspected.
- `VerifyDetachedViews` — PASS: PFD 737 is declared in frmMain DFM; main timeline updates it while detached; Close restores tab/icon. `VerifyViewState` — PASS: extended to seven views, including `view.pfd737`, independent geometry and automatic restoration across frmMain restarts.
- Registered the new test in `tests/Tests.groupproj` and both units/frame metadata in DPR/DPROJ. Synthetic tests only; no live flight, comparison with operating 737 avionics or IDE designer test. The initial FMA area reports available AP/FD/A/T flags rather than fabricating modes or FD command bars.

## Rebuilt frmMain, icons and data presentation

- Visual inspection of `native-preview.png` exposed duplicate embedded engines obscuring SixPack in the short new panel; frmMain now uses its separate EnginePanel and reserves SixPack height for instruments. `VerifyDetachedViews` checks that height. `VerifyFMCReplay`, `VerifySimBriefUI`, `VerifySixPack` and `VerifyUI` also passed after toolbar changes.
- `VerifyDetachedViews` — PASS: new panel hosts replace removed tabs; detach/redock preserves instances, hiding both instruments hides their container/splitters, closing restores them. Detach/dock icons switch 0/1 including window Close. Both glyphs of all six frames were rendered on white/black backgrounds to check transparent corners.
- `VerifyRecordingTree` — PASS: full/truncated ATCCOM keys plus an iFly MAX 8 title resolve to B38M, A32NX to A20N; explicit ICAO codes remain unchanged, unknown keys yield UNKNOWN, Windows device names are rejected. Existing filters, sorting, localization and missing-file behavior still pass. Raw metadata and existing recording paths are preserved.
- `VerifyEngineGauges` — PASS: 7632 raw psf displays as 53 psi for oil, while model values remain 7632; NaN stays unavailable. Existing engine-type, synchronization, docking and NULL-replay tests pass.
- `VerifyRecorderWorker` — PASS: mocked SimConnect open raises E_FAIL; worker stays ready with no Failed/Error and a localized waiting status. Retries are throttled; command-error, SQLite and VCL heartbeat regressions pass. No live simulator or real telemetry-disconnection test was performed.
- `VerifyRecordingImport` — PASS: new DFM hierarchy, migration/import and preview without worker/SimConnect. `VerifyViewState` checks six independent windows plus saved lower-panel dimensions. All tests use isolated files/mocks; the IDE designer was not opened.

## SixPack and simplified PFD ILS

- `VerifySixPack` — PASS: real VCL bitmap rendering. Pixel assertions cover LOC/GS diamonds on both sides of center, scales fixed during pitch/bank changes, independent LOC/GS signal loss, GPS exclusion, NaN, range clamping and hollow end-stop symbols. Consecutive frames also check removal of stale indications. The generated `tests/pfd-ils-preview.png` was visually inspected.
- The same test — PASS: SixPack directly derives from `TFrame`; fixed VSI range, index caching, altimeter mechanics, baro, metric readouts, docking, synchronization and missing-field migration regressions still pass.
- `VerifyDetachedViews` — PASS: main DFM loading, SixPack and other frames present, detach/redock and synchronization. `check_project.py` now validates direct `TFrame` ancestry for every DFM `inline` class.
- Synthetic tests only; no live ILS flight or reopening in the Delphi designer was performed. The SixPack tab DFM remains intact; no changes saved after Ignore were reconstructed.
- HSI CDI ±127, GSI ±119 and validity flags were checked against the [official MSFS 2024 SDK](https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/SimVars/Aircraft_SimVars/Aircraft_RadioNavigation_Variables.htm). These are needle deflections, not angles in degrees.

## Recorder mutex and designer-compatible frames

- `VerifySetup`: real Windows named object `MSFS24-FDR-Run_Once`; first acquisition succeeds, a duplicate is rejected, releasing the handle permits restart, and setup detects the live mutex.
- `VerifySetupUI`: actual DFM modal form `frmSetupRunning`, `bsDialog`, `mrRetry` and `mrCancel`. A test timer retries three times; continuation occurs only after releasing the recorder mutex. Cancel aborts the operation while retaining the recorder mutex. Small-updater/API-failure regression also passed.
- `VerifyUI`: frmMain DFM loading, creation/display, map, charts and synchronization passed after changing instrument/engine frames to direct `TFrame` ancestry. Reopening the form in the Delphi designer was not performed; IDE confirmation remains outstanding.
- No real recorder was terminated, no Program Files installation or production registry changes were made. The older-EXE process fallback without a mutex was not separately exercised with a live process.

## 0.1.1 — Setup consolidation, i18n, maintenance and PEM

Verified with Delphi 10.2 Win64 using isolated files and real DFM-backed VCL forms, without running production setup or modifying personal data.

- VerifySetupMaintenance covers Auto plus the same 32 locale codes, initial Windows detection, shared INI persistence, translated wizard/retention controls in every locale, Arabic/Hebrew RTL and LTR restoration. Its SETUP_RESOURCE_TEST build ran from a directory without external fonts/catalog, registered all five embedded fonts from memory and repeated the locale checks.
- Maintenance tests cover existing-installation radio buttons, repair/back navigation, version metadata when the EXE is missing, restoration of missing/corrupt files and unchanged healthy timestamps. Exact-version release selection refuses an unavailable installed version instead of upgrading.
- All four independent settings/flight retention combinations cover Recordings, the index, logs and loose-recording WAL files in TestPathsU only.
- tests/VerifyReleasePEM.dpr generates an ephemeral AES-256 encrypted PKCS#8 RSA-3072 key outside the repository. A native fixture PackageRelease gathers real runtime binaries from its test bin, encrypts a ZIP, creates and signs ZIP/manifest through OpenSSL using stdin-only fixture credentials and verifies through CNG. SHA-256 and extracted EXE bytes match; private files are excluded and the decoy is never extracted.
- Replacing source/runtime public.pem after compilation does not affect valid verification: the compiled key is used. A changed manifest signature is rejected before extraction. An incorrect PEM passphrase aborts native packaging and removes incomplete ZIP/signature/manifest files.
- Passed: VerifySetup, VerifySetupUI, VerifySetupSignature, VerifySetupMaintenance, VerifyGlobalLocales, VerifyLocaleExpansion, VerifyVersionLanguage, VerifyRTLReturn, VerifyReport, VerifyFMCReplay, VerifyUI, VerifyAppStorage, VerifyRecordingImport. Recorder Debug/Release, Setup 0.1.1.19 and the separate PackageRelease IDE project built successfully. Project, dependencies, version, 1076 definitions/32 locales and documentation checks passed.

Registry, system shortcuts and installer process launches use doubles. No live UAC, associations, complete machine installation/repair/removal, Authenticode certificate or simulator flight was tested. Production PEM generation requires the publisher’s local passphrase; no production key, release package or public upload was created by this change. Signed-package testing used a disposable fixture pair. Older entries below describe the previous implementation, including the former CNG key.

## 0.1.1 - Menu Start

Start menu shortcuts now reside in DJ M@fi0z0™: the application and an uninstall shortcut targeting Setup.exe /uninstall. Both follow the existing Start menu option. VerifySetup passed legacy migration, targets/arguments, unchecked-option cleanup and uninstall preserving other products. Shortcut operations use isolated test doubles, not the real Start menu.

## 0.1.1 ? OmniXML

exe.xml editing now uses IXMLDocument/IXMLNode and the native OmniXML backend, without OLE automation or MSXML. VerifySetup runs XML checks before CoInitialize: insertion/removal, idempotence, preservation of other entries and comments, empty-document creation, Unicode and escaped paths, UTF-8 declaration, and DTD/malformed XML rejection. Installation tests use isolated files and system-operation doubles; the production exe.xml was not modified.

## 0.1.1 — Release signatures

Delphi 10.2 Win64 Debug/Release and the separate Setup project were built. `VerifySetup` covers numeric version ordering, GitHub assets, encrypted ZIP round-trip, wrong password, corruption, unsafe paths, no decoy extraction, MSXML merge/DTD rejection, real isolated install/update/remove files, file-copy rollback, setup replacement, changelog DFM and update settings. `VerifySetupUI` exercises wizard navigation, options, the 440×130 progress layout and three loopback HTTP failure/no-update scenarios with a live VCL heartbeat and old-app fallback.

`VerifySetupSignature` uses native CNG and an ephemeral RSA-3072 test key: valid SHA-256/PSS/salt32, changed signature/hash, salt20 and missing-key rejection, plus an isolated persistent rollback floor. Package QA signs with .NET RSACng and verifies through Delphi/CNG before byte/CRC read-back; Python zipfile independently decoded a public-password fixture. Regression: VerifyReport, VerifyFMCReplay, VerifyUI, VerifyRecordingImport, VerifyAppStorage, VerifyRTLReturn.

System registry, shortcut and process operations use test doubles. No real Program Files installation, UAC prompt, production exe.xml modification, Authenticode certificate, public upload or simulator flight was tested. File-copy rollback is not a claim of complete registry/XML/shortcut power-loss atomicity. Production signing uses the publisher profile key, never the ephemeral test key.

Final verification in the target repository passed: Debug/Release Win64 and Setup 0.1.1.16; all nine listed tests; project, dependencies, version, 1048 translation definitions/32 locales and documentation checks. The signed package contains 80 encrypted entries. Separate copied-package trials rejected modified ZIP bytes, ZIP signature, manifest, manifest signature and a missing manifest signature before creating any extraction directory. Six IDE-generated compiler property groups were moved before the Delphi targets import; invalid TForm-only properties were removed from three frame DFMs while preserving dimensions.

## 0.1.2.15 — Import, preview and DFM resources

Tests used synthetic SQLite data and real VCL forms, without opening private recordings in the production EXE or connecting to MSFS.

- `VerifyRecordingImport`: initial migration, appending a flight to an already processed legacy database, repeated imports without duplication and SHA-256 comparison of the source; discovery of a dropped `.mfzr`, idempotent rescanning and invalid-file isolation. Importing an already indexed file does not duplicate it.
- A child process receives exactly one existing synthetic `.mfzr` path. It checks loaded telemetry, three DFM instrument tabs, hidden LeftPanel/splitter, disabled recording and management actions, safe direct calls to blocked handlers, and absence of the default index and recorder lock. SQLite rejects a separate write attempt through a read-only connection; the recording SHA-256 remains unchanged. Both import icons render transparent corners on a light background.
- Passed regression suites: `VerifyUI`, `VerifyDetachedViews`, `VerifyHelpAbout`, `VerifyGroups`, `VerifyPort`, `VerifyLegacy`, `VerifyRecorderWorker`, `VerifySession`, `VerifyViewState`, `VerifyFMCReplay`, `VerifyMetar`, `VerifyRecordingFiles`, `VerifyRecordingTree`, `VerifyRecordingUI`, `VerifyRecordingWorker`, `VerifyTripInfo`. Their previous coverage is documented below.

No live flight or manual interaction with the system file picker was performed. Tests use real SQLite and child processes; they do not certify every possible physical file corruption. The new test is registered in Tests.groupproj and the default test.ps1.

Final verification in the destination repository: Delphi 10.2 Debug and Release Win64 builds succeeded, VersionInfo 0.1.2.15. VerifyRecordingImport, VerifyRecordingUI and VerifyViewState passed again, along with project, version, documentation and 1044-definition/32-locale catalog checks. The deployed catalog matches its source. MSBuild settings and translation deployment hook ordering were corrected; support files for the separate installer are excluded from recorder unit validation.

## 0.1.0.14 — recording index and individual flight files

Executed with synthetic SQLite/VCL data in isolated `TestPathsU` directories:

- `VerifyRecordingFiles`: two independent recordings, metadata-only index, recording/finalizing/completed transitions, ICAO/timestamp paths, sample/event isolation, retained missing-file metadata and traversal rejection. Three-flight migration checks groups, filename collisions, raw FMC text/styles/lamps, an extra trip-scoped table, schema version, reopen without repeated upgrade, retry idempotence and byte-for-byte unchanged source.
- The same test hard-terminates a child process with `TerminateProcess`, bypassing destructors/checkpoint. It verifies committed WAL recovery, interrupted status, recovery after rename but before index publication, and damaged-file/metadata retention after integrity failure.
- `VerifyRecordingTree`: ordering of every folder level and siblings, PL/DE full month names, new translation identifiers, padded timestamps, icons, active prefix, selection retention, combined case-insensitive search/group filtering, blank filters and missing-file hiding without metadata deletion.
- `VerifyRecordingUI`: actual main form, migrated file opening/double click, inspector/instrument integration, disabled active node, search reset and folder selection. Automated recovery dialogs verify decline retention, repeated offer next launch and accepted recovery opening.
- `VerifyRecordingWorker`: real recorder thread with synthetic SimConnect, individual-file SQLite contention, VCL heartbeat/nonblocking commands, multiple samples, final path/status and clean shutdown.

New programs are registered in `tests/Tests.groupproj` and default `test.ps1`. Old UI tests now use the tree. `VerifyFMCReplay` uses isolated test storage instead of global TEMP. The production application was not launched against private recordings; no live MSFS flight or universal recovery of physically damaged databases was tested. Earlier version-specific test history follows.

Final validation: all 15 regression suites passed (UI, detached views, help/about, groups, database/legacy, worker/session, saved views, FMC replay, METAR and four new recording suites). Arabic/Hebrew month tests enforce Gregorian dates. UI deletion covers confirmed single-file removal and a busy-file failure that preserves metadata and safely clears the inspector. Delphi 10.2 Debug/Release Win64 builds succeeded, VersionInfo 0.1.0.14. Project/version/translation/documentation checks passed.


The recording list uses `vstRecordings: TVirtualStringTree`, preserving the updated form layout. Disabled nodes are native; refresh retains focus, expanded folders and scrolling. Builds require Virtual TreeView V8 sources, detected in sibling `..\Virtual-TreeView\Source` or `vendor\Virtual-TreeView\Source`. Override with `-VirtualTreeRoot` in `build.ps1`/`test.ps1`, or `/p:VirtualTreeRoot=...` in MSBuild. The IDE project and test group share this setting. The executable needs no additional runtime library for this component.


All 16 suites were repeated after switching to TVirtualStringTree, including VerifyTripInfo. VerifyRTLReturn and VerifyGlobalLocales also passed in the target repository: 32 languages, fonts and RTL/LTR transitions. Total: 18 regression suites. The synthetic VerifyUI native-preview.png was visually checked for tree text, localized month, icons and selection. Final target-repository Debug/Release Win64 builds and five isolated storage/trip-info tests: PASS.


## 0.1.0.13 — ranges, bindings and altimeter (2026-10-21)

Extended the existing `VerifySixPack`, already registered in `Tests.groupproj`. Synthetic replay contains VSI 100/-5600 ft/min, NaN, Infinity and a short value array. The range is 6000 ft/min from the first sample and remains unchanged while scrubbing both ways; missing VSI falls back to 2000. IAS also has a fixed bound-recording range. ft/min→m/s preserves value/range ratio. No live MSFS validation.

A counting list subclass verifies that 3003 labels and 1000 subsequent SetPoint calls produce no further IndexOf lookups. Tests cover same-count label reordering, renaming to an unknown parameter, plot switching and Clear; Revision preserves OnChange subscribers. This checks TSixPackDisplay's access path, not whole-application or engine-panel timing. Editing values without a schema change requires Clear to recalculate ranges; normal replay treats bound samples as immutable.

At 12500 ft, the three angles are 180°/90°/45° and remain unchanged after ft→m, with a 3810 m numeric readout. The test also checks a pixel on the actual long rendered needle before/after conversion, not just a helper function. Other coverage: -500 ft wrapping, NaN, existing ILS/baro, detachment, small sizes, RTL and migrated NULL data. Visually inspected `tests/six-pack-metric-preview.bmp`: FT legend, metric readout and foot-based geometry.

Passing regression: VerifySixPack, VerifyDetachedViews, VerifyViewState, VerifyDisplayUnits, VerifyEngineGauges, VerifyPort, VerifyUI. The complete 53-Verify list was not repeated. TPlotLabels changes the in-memory model only; SQL definitions/raw storage remain unchanged. Build incremented once to 0.1.0.13; project/group checks remain required.


Final destination-repository run: all seven listed tests passed again. Debug and Release Win64 built with VersionInfo 0.1.0.13. No user configuration/database changes or production EXE launch.


## 0.1.0.12 — view-state persistence (2026-10-21)

New `VerifyViewState` is registered in `tests/Tests.groupproj` and the default `test.ps1` list. Synthetic VCL/INI/SQLite only; no flight or private settings. Repeated creation/destruction of frmMain verifies six detachable frames including SimBrief, independent positions/sizes, preserving detached state on application shutdown, automatic restoration, button/X docking, independent siblings and floating geometry retained after docking. An additional previously unknown `future_hud` frame proves registry extensibility without per-frame save routines.

Further assertions cover maximized normal bounds, minimized-window geometry and normal startup, restore-once behavior after explicit docking, reset docking/section removal, invalid/duplicate IDs, emulated DPI conversion and recovery of offscreen/MaxInt coordinates and invalid size/PPI. Monitors were not physically disconnected and Windows DPI was not changed; the test seeds INI values.

Passing regression: VerifyViewState, VerifyDetachedViews, VerifyUI, VerifySimBriefUI, VerifyRTLReturn, VerifySixPack and VerifyEngineGauges. The complete 53-Verify suite was not repeated; the preceding 52-test entry describes the previous version's run. Project/group, i18n, version, font and documentation checks pass. TForm-only properties saved by the IDE in the six-pack DFM were removed again, preserving manual dimensions/appearance. Build incremented once to 0.1.0.12.


Final destination-repository verification: all seven tests above passed again; application Debug and Release Win64 builds succeeded with VersionInfo 0.1.0.12. The new test was also built through its `Tests.groupproj` target in the working copy and the resulting EXE was run. No production EXE launch or private-data migration.


## 0.1.0.11 — isolated databases and instruments (2026-10-21)

The complete `test.ps1` suite of **52 Verify programs** returned exit code 0/PASS. These are synthetic SQLite/VCL tests and SimConnect/IPC/HTTP/CLI mocks, not a live MSFS flight or instrument validation. Existing recorder, aircraft, FMC, FSHud, GSX, analysis, SimBrief, charts, units, localization/RTL, migration and version coverage was retained.

- `TestPathsU`, initialized first by Verify*, creates `.build/test-data/<name>/<PID>-<tick>` for each process, redirects databases and PORT_TEST settings, and copies test dependencies/fixtures. Migration tests retain their private temporary trees. VerifyPort/VerifyLegacy and VCL tests passed with the new paths; user bin/LocalAppData databases are not opened.
- `VerifySixPack`: valid independent LOC/GS normalization ±127/±119, GPS CDI exclusion, GS loss with LOC retained, missing flags/NaNs, selected 1026 hPa baro, 29.92 inHg fallback and STD. Existing pitch, heading, measured turn/ball, unit conversion, resize, detach and missing-column migration tests remain. Needle direction/appearance still need live comparison.
- New `VerifyEngineGauges`: all four layout classes; piston/turboprop/jet; 0/1/2/4/16 engines and invalid count; independent N1; RPM/CHT/ITT/condition values; inappropriate groups excluded; valid zero fuel versus missing optional values; ampere unit; same-frame detach/return and sample updates; RTL/LTR; small sizes and bitmap rendering. Database roundtrip covers aircraft title, precise ITT and NULL→NaN for unavailable engine/ILS data. `tests/engine-gauges-preview.bmp` was visually inspected.
- `VerifyDetachedViews` additionally verifies the main engine frame, return button, Close and timeline label synchronization. `VerifySubscriptions` retains mock coverage of engine-type/count filtering and session teardown.
- Missing FireDAC engine parameters now receive a type before Clear/NULL. The test initially exposed “Parameter V32 data type is unknown”; it passes after the fix. Missing values are not replaced by fabricated zeroes.

123 appended SimConnect fields preserve old offsets: 11 common and 7 families ×16 engines. New columns are nullable; historical recordings cannot gain unavailable data retrospectively. Catalog: 834 fields /7080 bytes, 123 numeric columns, 39 engine-column families. Static checks cover 88 DPR/DPROJ units, 1034 i18n definitions ×32 locales, fonts/licenses, documentation, add-on/AIRLINER metadata and version 0.1.0.11. Translation checks validate structure/placeholders/Unicode, not native-speaker terminology; new parameter descriptions also have a technical English fallback.

Gauge scales are generic, with no aircraft-specific operating limits. `ikGaGlass`/`ikAirlinerPFD` are simplified shared presentations without complete Boeing/Airbus FMA/FD/PFD/ND. Classification uses available title/engine data; custom titles may need more rules. References: [engine SimVars](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-engine-variables/), [radio/navigation SimVars](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-radio-navigation-variables/).


Final validation: all 63 projects in `tests/Tests.groupproj` built with Delphi 10.2 MSBuild (Debug/Win64; IPC publisher Win32). Group defaults without a Platform argument and the resulting VerifyEngineGauges/VerifySixPack executables were also checked. VCL resource paths and IDE platform availability flags were corrected. After merging manual formatting, VerifyEngineGauges, VerifySixPack, VerifyDetachedViews, VerifyPort, VerifyLegacy and VerifyDisplayUnits passed again. New assertions cover NULL→value→NULL in a prepared statement, fractional 1026.35 baro and translated new captions. Engine scales are shared across compared engines; baro uses REAL without fractional truncation.


Final validation in the destination repository also exposed three checkout/IDE-save issues: whitespace-sensitive Name records, OFL license hashes sensitive to CRLF and TForm-only ClientHeight/ClientWidth/OldCreateOrder/PixelsPerInch/TextHeight in the six-pack DFM. Name/license checks were fixed while retaining content/font validation; the valid TFrame resource preserves manual dimensions/appearance. ZIP license validation also tolerates LF/CRLF only. Seven tests were repeated in the repository, including VerifyAddonLVars. Debug/Release Win64 0.1.0.11 were rebuilt; the production EXE was not launched and private data was not migrated during tests.


## 0.1.0.10 — flight subscriptions and native six-pack (2026-10-21)

Full `test.ps1`: **51 programs PASS**, Delphi 10.2 Win64, isolated data. Checks: 85 project units, 1014 definitions across 32 locales, fonts, version and documentation PASS. The production EXE and private database migration were not run. Earlier sections are historical.

- `VerifySubscriptions`/`MockLifecycleSim`: only three identity fields while idle; AircraftLoaded/SimStart activation without FlightLoaded; event ordering; two jet/four piston/one turboprop engines; inappropriate families and excess indices excluded; same-aircraft reload; title changes detected inside full packets; cancellation/definition clearing; stale packet rejection; cached aircraft state cannot activate in the menu; SimStart uses fresh flight confirmation and rejects MAINMENU. Mock DLL only.
- `VerifyAddonLVars`: eight profiles/5050 fields, only the matching TFDi provider opens, inactive closure, bounded ONCE queue, isolated failure/nulls, change-only SQLite and chart replay. After merging current formatting, added transport validation for standard `A:LIGHT NAV`, stripping A and preserving bool units.
- `VerifySixPack`: native VCL render; recorded sample/time, pitch sign, 361° → 1° heading, indicated altitude and measured turn/ball; same frame detach/Close; RTL; units without raw-data changes; missing fields/invalid indices; small resize; old schema without two columns upgraded; SQL NULL remains NaN in replay. The screenshot was inspected; `docs/screenshots/six-pack.png` is synthetic, not live-flight evidence.
- Extended `VerifyDetachedViews`: main-window tab, detach/button/Close, timeline and indicated altitude. Six-pack assertions are in a separate procedure after Delphi 10.2 code-generation errors in the enlarged test program; assertions were retained.
- Reproducible local audit: **120 packages/2046 locpaks**, metadata/hashes only, no encrypted archives. Translated calculator names excluded. Bell 407: 72 bindings; EC135: 234. **18 variants/39 XML files** across six commercial families: original five retain 3298 L-vars; TFDi MD-11 GE/PW passenger/freighter adds 1446. A family union does not prove support for every field in each variant.

New instrument semantics checked against official [SDK templates](https://docs.flightsimulator.com/msfs2024/html/5_Content_Configuration/Models/ModelBehaviors/TemplateExplorer/Asobo_EX1/Common/Interior/Templates/ParametersFn/Instrument_ParametersFn.html) and [SimVars](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-system-variables/). **No live simulator/aircraft verification**. TFDi uses literal model L-vars, not an unavailable binary SDK/header. Zero does not prove L-var availability; six-pack does not emulate instrument failures/dynamics.

Final deployed-repository **Debug and Release Win64 builds PASS**, FileVersion **0.1.0.10**, matching translations and PDB symbols. Concurrent manual formatting in four files was preserved. VerifyAddonLVars (including standard binding/units), VerifyDetachedViews and VerifySixPack passed again after merging. Installed aircraft files and private recordings/settings were not modified.

## 0.1.0.9 — A320 export and aircraft integrations

Full `test.ps1`: **49 programs PASS**, Delphi 10.2 with isolated data. New `VerifyPMDG777`, `VerifyAddonLVars`, and `VerifyFlightPadAppearance` cover 522 SDK fields and three CDUs, 3298 L-vars across five families, isolated failures, bounded polling, change-only storage, and real Win32 → Win64 IPC including RGB, small fonts, lamps, formatting-only changes and unavailable screens. Extended replay tests cover automatic aircraft family detection and CDU tabs.

Independent clang-cl offsetof/sizeof verification against the original PMDG 777 header: PASS for every field. FlightPad Win32 `ExportTests` and `ExportAppearanceTests`: PASS; all four Fenix/FBW MCDU/Screen clients compiled. Project (73 units), version, translations and SDK/L-var catalog checks: PASS. No live simulator verification: DLL tests use mocks; a zero does not prove an L-var exists. Aircraft files and private data were not changed.

Deployed repository Debug and Release Win64 builds: PASS, FileVersion 0.1.0.9; matching translations and PDB symbols: PASS. Final project check: 73 units PASS. The current SimBrief DFM contained form-only properties; ClientHeight/ClientWidth became Height/Width and three form-only properties were removed while preserving its current layout. The production EXE was not launched.

## 0.1.0.8 — native views, AppData and FMC/MCDU (2026-10-21)

**Full `test.ps1`: 46 Delphi programs — PASS**, isolated working copy, Delphi 10.2 Win64. Catalog validation (32 locales, 1011 definitions), 68 DPR/DPROJ units, fonts, version and documentation checks: PASS. Older sections below are historical.

Installed-source Debug and Release Win64 builds: PASS, FileVersion 0.1.0.8, matching catalog and PDB. PE imports and absence of the WebView2 loader reference: PASS. The 72-file `dist/native-storage-fmc-0.1.0.8/MSFS2024-FDR-Win64-0.1.0.8.zip` passed CRC/read-back, x64 checks and loading both runtime DLLs after extraction (SQLite 3.45.3); it includes three FMC backgrounds/four CHMs, without WebView2, Community or private settings/database. The production EXE was not launched, so private data was not migrated during verification.

`VerifyAppStorage` uses real committed SQLite WAL data (record 12345), a frozen DB/WAL/SHM family, settings/log movement, an active writer lock, no partial target, existing-target conflict preservation, repeated migration, interrupted publication recovery, and a read-only source with a writable migrated copy. Only test directories were touched. No personal database or real Program Files migration was performed. Production uses LocalAppData; `PORT_TEST` isolates fixtures beside the test executable.

`VerifyFMCReplay` checks two devices, last-at-or-before seek, UTC offsets and recorder weekday suffixes, equal-time ID ordering, off/unavailable transitions, device isolation, clearing, same-frame detach/Close docking and physical CDU LTR after Hebrew/Polish switches. The native `tests/fmc-replay-preview.bmp` screenshot was inspected: B737 background, colors, small font, EXEC/MSG lamps. `VerifyDetachedViews` also tests the actual Main timeline wiring, changing recordings while detached, button/Close docking and main shutdown.

`VerifyReport`, `VerifyFMCReplay` and `VerifySimBriefUI` cover native read-only, borderless, scrollbar-free Consolas TMemo; spaces/entities; line-count height beyond 100 lines; outer scrolling; native rich-text headings/bold/lists/italic/code; report titles and Close. The old horizontal-scroll expectation was updated to ssNone. `VerifyHelpAbout` now creates its own fixture instead of depending on a previous test's last trip. Existing recorder/worker/WAL, mock aircraft SDK, FMC, SimBrief, weather, precision, units, icons and language tests also pass.

No live flight or installer test was performed; the installer is not included yet. Old/text-only Fenix/FBW recordings cannot provide missing style/lamp metadata. B777 image support is not a new SDK integration. Mock tests do not certify every commercial add-on version.


After the final correction, VerifyDetachedViews, VerifyChartsConfigure, VerifyLocalization and VerifyUI passed again. Added checks cover the reverse close order, viewport-label preservation across language changes, isolation of detached wheel events from the main form, and all 43 icons through independent PNG comparisons.


## Detached frames and restored actions — 18 October 2026

**35 Delphi programs passed, plus 4 metadata checks.** The full suite ran in an isolated source copy; the new documentation check ran additionally after writing the language files. Older sections below describe historical versions.

VerifyDetachedViews creates two synthetic trips with different time spans, detaches each view and both together, compares control identity/viewport, checks cursor/timeline and trip changes while detached, wheel/zoom, localized titles, close/action restoration, map height/splitter, repeated toggles and main destruction with both windows open. The actual detached chart-configuration button opens the modal dialog; a timer checks its own icons and cancels through its action. No live simulator or production AI request is involved.

VerifyChartsConfigure now checks its own three icons/five actions, selection-dependent action state, moving/hiding through actions, acceptance/cancellation, filtering, unavailable preferences and working-copy isolation. VerifyUI retains current layout, MapPanel sizing, splitters, read-only grids, timeline and cached report actions. VerifyLocalization covers the moved fraGraph property and new window actions.

check_project validates 59 explicit source units, including two frames and the shared window. check_translations validates 581 four-language definitions and component references; check_airliner_catalog validates provenance; check_documentation requires all four versions of every project-owned README/Testy and working language links. Vendor documentation and licenses remain original. Full log: tests/verification.log. Earlier live-integration limitations still apply.


## External .i18n catalog, four languages and UI regression — 18 October 2026

**34 Delphi test programs plus 3 metadata checks passed** in an isolated source copy via test.ps1. VerifyLocalization, VerifyUI and VerifyReport were rerun after the final dynamic chart-hint correction. Win64 Debug and Release were compiled through DPROJ/MSBuild. Older sections below are historical; the former JSON generator and disabled DE/ES no longer describe the current application.

- Catalog validation: the actual uncompressed i18n file contains 422 literals and 150 properties, with complete PL/EN/DE/ES coverage, matching Format arguments, valid Unicode, unique entries and current DFM bindings. Runtime tests load it through the real i18n package.
- Localization: real four-language menu actions, existing/new forms, dynamic chart hints, shared menu/toolbar actions and handlers, four-language persistence/cancel behavior, three settings tabs and three provider subpages, SimBrief sections, worker lookups and unchanged numeric formatting.
- Reports: takeoff versus landing titles, reused windows, live language changes including German/Spanish, preservation of explicit HTML/OFP titles, Markdown/escaped HTML and the actual nonmodal Close action. UI tests open both cached reports through menu actions without calling AI.
- Icons: all 34 main and 6 SimBrief icons are compared pixel by pixel with independent VCL drawing of the original PNG on RGB(123,151,179), tolerance 3 per channel. Opaque BMP flag colors and transparent margins remain intact. Actual auto-record and older-plan toolbar toggles are exercised.
- SimBrief: parentless frame construction, toolbar/action wiring, 15 native sections, EPLL–EGLL preview, collapse persistence, overall wheel scrolling, full-height multiline/OFP content, detached window/reattachment and account/toolbar fit at 240 px.
- Project metadata: all 56 units explicitly listed, DCU/OBJ/HPP/DCP/BPL paths constrained to `.build/$(Platform)/$(Config)`, and a catalog deployment target. The missing VCL resource search path in Debug was fixed; both configurations then compiled with zero newly generated DCUs under src. Test intermediates are separated by platform.

The full recording/database/delta/weather/SimBrief/FMC/aircraft/GSX/FSHud/AI-provider suite passed using synthetic data and local mocks. No new live simulator flight or production AI request was performed. Settings tabs, SimBrief and toolbar screenshots were visually inspected. Full log: `tests/verification.log`. Catalog maintenance/deployment: `translations/README.en.md`.


## Manual UI refactor review — 18 October 2026

Full suite: **34 Delphi test programs plus 3 metadata checks passed**. VerifyLocalization and VerifyChartsConfigure were rerun after adding icon tooltips. All 56 source units remain explicit in DPR/DPROJ; build/package tools preserve the manually renamed MSFS2024-FDR project. The catalog has 420 messages and 130 component properties and now rejects stale translated component names.

VerifyChartsConfigure tests an isolated selection/order working copy, filtering without losing checks, add/remove/reorder/hide, boundaries, unavailable-aircraft preferences, cancellation isolation, resize and PL/EN. VerifyUI opens the actual modal dialog through its action, selects more than eight charts, accepts, reorders and cancels a later change; zoom is exercised through actions. Existing map/scroll/timeline/inspector/layout tests remain.

For all PNG icons, every 22x22 pixel is compared against independent VCL rendering of the original PNG on RGB(123,151,179), with a three-level/channel rounding tolerance. RGBA and indexed palette/tRNS sources are covered. The opaque German BMP flag is checked against every original pixel and transparent margins, preserving dark stripes. All 26 indices remain stable. The real auto-record toolbar button is clicked twice to verify toggling. Screenshots toolbar-preview.png and native-preview.png were visually inspected.

The review also fixes stale translation IDs after component renames, published component fields, invalid form-only properties in the TFrame DFM, partial-construction cleanup and resize guards. SimBrief/UI, trip info, reports, Ollama/models and localization regression passed. Polish/English actions work; German/Spanish remain disabled pending catalogs instead of silently selecting Polish.

Icons are encoded in DFM using proper alpha with Common Controls v6 (Vcl.XPMan), including direct dcc64 builds. tools/rebuild_toolbar_images.ps1 reproduces the resource from unchanged original Icons assets. Tests are synthetic/local and do not constitute a new MSFS flight.



## Localization/source reorganization, 18 October 2026

The complete suite passed after refactoring: **33 Delphi test executables**, plus project, AIRLINER and translation metadata checks. The complete run was repeated after adding SimBrief/Ollama validation translations: all 36 PASS results. The three transport fixtures MockFlightPad32/MockFenixSim/MockPMDGSim were rebuilt. The new translation-generation consistency check also passes independently and is now part of test.ps1. The localization test was rerun after extending its combo/help-text and rendered-settings checks. Only remaining dynamic plan-source/empty-section/API-label and current-plan header translations were added afterwards; VerifyUI, VerifySimBriefUI and VerifyLocalization were rerun for those changes. No recorder/parser/database algorithm changed.

Run `powershell -ExecutionPolicy Bypass -File test.ps1`. A selected test can be run with `-Tests VerifyLocalization`. Delphi 10.2 dcc64 builds the tests; MockFlightPad32 uses dcc32 for real cross-bitness IPC. Test databases/configuration/processes are isolated under tests/.build, not the user's recordings. Test files are generated artifacts excluded from Git. Full compiler output is captured locally during verification.

## Executable coverage

### VerifyPort

native SQLite schema, automatic trips, telemetry/engines, contacts, timezone, KML, deletion, flood filter and runway geometry.

### VerifyLegacy

legacy samples, engine columns/bits, readback, backup, timezone correction and repeat-open idempotence.

### VerifyUI

VCL DFM, native map/charts, parameter selection, synchronized timeline and inspector. PNG saved.

### VerifyDiagnostics

persistent error log and readable Windows minidump header.

### VerifyFlightPlan

actual EPMO/EPLL plans, DMS, EFB route, loopback bridge, per-flight revisions, deduplication and SimConnect path.

### VerifyAnalysis

hidden Codex process, UTF-8 Polish query/result, argument quoting, CLI failure, timeout and cancellation. No cloud requests.

### VerifyContext

full parameter baseline, AP/AT transitions, recursive deltas, engine null/removal/reappearance, reconstructed weather and reduced payload across 181 snapshots.

### VerifyReport

Markdown formatting, escaped HTML and nonmodal Close button.

### VerifyMetar

async METAR storage, observation/capture time, no historical backfill, unavailable response, runway metres and analysis context. Mock server only.

### VerifyChartView

chart viewport, nonzero origin, cursor mapping, reverse drag zoom, panning, Ctrl+wheel and reset.

### VerifyAircraftSDK

official SDK shared memory, aircraft detection, all 2411 fields, precedence, units, delta persistence, chart replay, disconnect/reconnect and cleanup.

### VerifyFenix

automatic Fenix matching, 1203 L-vars via mock SimConnect DLL, batching, read-only API, provenance, zeros/null/stale/partial/malformed/error/reconnect, delta storage, charts, AI and provider isolation.

### VerifyFBW

FBW title detection, readable API catalog, real DLL calls, optional failures, readiness, A/THR, flap mapping, IAS/Mach/dashes, VAPP, cache isolation, delta history, charts and AI. Mock only.

### VerifyPMDG

PMDG NG3 typed Client Data, 494 fields, signed/float/text decoding, FMC sentinels, AP/AT, MCP blank/power/Mach, gear OFF, CDU layout/arrows/colors, optional failures, provider reset, cached ON_SET, delta history, charts and AI. Mock only.

### VerifyFMC

iFly/PMDG TStringList screens, glyphs, raw text round trip, change-only history, timestamps, per-page/as-of-event cache, V-speeds/wind correction, MOD isolation, cleared/ambiguous values, power/unavailability and cleanup.

### VerifyFlightPad

FlightPad Win32/Win64 text IPC, running process detection, Fenix/FBW isolation, heartbeat, unavailable/malformed/version rejection, Unicode, aircraft integration, change-only FDR and AI context. Mock publishers only.

### VerifyAirbusMCDU

Fenix/FBW MCDU TAKEOFF/APPR/INIT parsing, V-speeds, FLEX/THS/altitudes, QNH units, wind/minima, nulls, scratchpad/column isolation, TMPY, timestamped history and as-of-event analysis. Synthetic screens only.

### VerifyOllama

Ollama settings/DFM, UTF-8 Polish chat and Markdown, custom URL, HTTP/API/JSON/empty/incomplete errors, model validation, timeout and cancellation. Local mock only.

### VerifyOllamaModels

Ollama GET tags, proxy URLs, sorted/deduplicated models, empty/malformed/HTTP failures, async dropdown, selection retention, URL replacement and close/cancellation. Local mock only.

### VerifyTripInfo

trip info DFM, selected aircraft, sample count, unfinished/completed duration, refresh, read-only view, close action and missing trip.

### VerifyPrecision

recursive three-decimal analysis JSON, exact integer IDs, untouched strings/raw DB, hysteresis against emitted state, cumulative drift, jitter suppression and AP/timestamps.

### VerifyAirliner

common AIRLINER read-only SimConnect L-vars, per-field isolation, zeros/null/errors, optional delta storage, chart replay/gaps, AI definitions and cleanup. Mock only.

### VerifyGroundWeather

last pre-liftoff ground/first landing ground weather, bounce exclusion, outside-window selection, missing reference without fallback, trip isolation and prompt policy.

### VerifySimBrief

SimBrief offline matching, stale/mismatched/incomplete rejection, raw OFP storage, decoded analysis excerpt, revalidation, DFM actions and deletion.

### VerifySimBriefUI

SimBrief native Dispatch frame, 15 groups, EPLL-EGLL preview, collapse persistence, responsive toolbar, read-only sections, independent preview and original OFP action.

### VerifyGSX

GSX Pro read-only SimConnect L-vars, per-field isolation, zeros/null/errors, optional delta storage, chart replay/gaps, AI definitions and cleanup. Mock only.

### VerifySession

loaded-flight recording with engines off, engine start/shutdown continuity, pause/resume, explicit flight end, next flight and main-menu fallback.

### VerifyFSHud

FSHud codec Unicode/malformed frames, validation, read-only allowlist, privacy filter, duplicate suppression, timestamped raw messages, snapshot history and cleanup. Offline only.

### VerifyRecorderWorker

recorder owns background connection/thread, VCL heartbeat and nonblocking commands under SQLite contention, WAL, queued PLN/errors, shutdown and unstarted cleanup. No simulator or network.

### VerifySimBacklog

1000 queued telemetry packets become five callbacks, latest timestamp retained and all three ground transitions preserved; slow consumer does not replay every historical frame. Synthetic only.

### VerifyBoeingFMC

Boeing performance pages, ACT/SEL sides, derate versus bump, assumed temperature versus OAT, N1, flaps/CG/trim, PERF INIT display units and trip information as of each contact. Synthetic only.

### VerifyIFlyDisplays

assembled iFly displays, blank/sign/decimal/IRS states, compact SDK history and charts, separate FMC text/styles/HTML/CDU lamps, appearance-only changes and preflight retention. Synthetic only.

### VerifyLocalization

Polish default, live English/Polish menu/forms/frame, dynamic SimBrief, saved language, cancel, worker lookup and invariant number formatting.

## Additional localization assertions

VerifyLocalization covers Polish default, unknown-locale/source fallback, live PL/EN/PL main menu/button translation, newly created settings/report/frame, dynamic cached SimBrief titles, persisted language, load/cancel semantics, provider combo items, multiline DFM help, worker-thread lookup and unchanged numeric decimal separator. It renders the shown English Settings form to settings-en-preview.png for visual inspection. AI prompts/reports remain Polish by design; raw aircraft/protocol/flight data is not translated.

The project checker verifies all 55 Pascal units appear exactly once in DPR/DPROJ, file/unit identity, U suffixes, paired form DFM and removal of project TNative class names. The translation generator validates 420 message literals and 103 form/frame properties, both locales, Format placeholders and exact generated-source consistency. The catalog is genuine i18n TLocalizer/TTranslator data embedded in the executable.

## Build, artifacts and dependencies

build.ps1 successfully builds the Win64 release with Delphi 10.2 and recursive source/dependency paths. check_dependencies.py verifies AMD64 PE imports and no Qt dependency. WebView2 loads dynamically for reports. package.py verifies the source/release archives retain the reorganized source, English/Polish docs, JSON catalog sources, i18n source/license and safe Polish defaults without private databases/keys. The source checker and translation check are rerunnable without the IDE.

The optional tools/verify_flightpad.ps1 compares the external exporter implementation allowing only unit-name/newline normalization; the recorder's unit was renamed without changing the IPC layout. Prior PMDG independent layout tests used ctypes and SDK clang-cl /Zp8, confirming 916-byte data, 1009-byte CDU and every member offset. Those are layout tests, not live packet verification.

The completed source archive was extracted under .build/source-smoke and built with its own build.ps1, an intentionally nonexistent SDKRoot and bundled runtime/i18n/WebView4Delphi fallbacks: PASS. No sibling project was required.

## Scope and live limitations

Most integration tests use synthetic telemetry/screens, a mock SimConnect DLL, local fixture HTTP/WebSocket services or a hidden mock Codex process. They exercise actual API bindings, failures, queues, database round trips and UI contracts; they do not establish real aircraft runtime values or AI quality. Ollama tests neither download a model nor call a real model. Codex tests do not send a cloud request.

Earlier FSHud probing received all nine supported message types and the EPLL test-route points from local panel version 2.1.200. Earlier PMDG probing could not verify live values because the user's active aircraft was iFly; no aircraft was switched. The optional iFly FMC probe found SDK state=0, so it did not establish live screen reception. FlightPad exporter/client compilation and synthetic Win32/Win64 IPC are distinct from a real aircraft/server connection. The full end-of-flight compatibility boundary, complex runway matching, long-duration recording and each manufacturer's runtime SDK data still need full simulator flights. No new live flight was performed for localization.

Historical database inspection, SDK hashes, probe limitations and detailed individual cases remain in the Polish test record and component English notes. Existing data was not modified for these tests.

The authoritative repository also passed MSBuild of src/MSFS2024-FDR.dproj with Config=Release and Platform=Win64.

Concurrent source formatting in the authoritative repository was preserved. Token comparisons found no logic changes; IFlyDisplays also expanded equivalent grouped declarations. VerifyAircraftSDK and VerifyIFlyDisplays were rerun: PASS. Final archives are built directly from that repository to preserve its current formatting.

## VerifyGroups — 2026-10-18

`VerifyGroups` covers each group filter, empty entry and no selection as no filter, refresh retention, current assignment in the bsDialog, OK/Cancel, assignment/unassignment and empty groups. It uses synthetic SQLite data and real VCL forms, without a simulator. The form is registered in DPR/DPROJ (60 units) and translated into four languages. The full suite now contains 36 Delphi programs and four metadata checks.

## Toolbar frames — 2026-10-18

Toolbar actions and image lists now belong to fraMap/fraGraph and are stored in their DFMs. The main menu uses the same actions; main retains references and window switching. The chart frame handles zoom. In detached windows, btnGraphWindow and btnMapWindow return the same frame to frmMain. Icon indices remain compatible with the main menu. TFrame DFM properties and invalid chart-configuration uses entries were also corrected.

Extended VerifyDetachedViews covers ActionList/ImageList ownership, shared menu/frame actions, local zoom and real clicks on both return buttons. Repeated VerifyUI, VerifyLocalization, VerifyChartsConfigure, VerifyGroups and four metadata checks. These are synthetic VCL/SQLite tests without the simulator. Tests use local frame references: Delphi 10.2 Win64 emitted a write to address zero for repeated nested property references in call arguments.

## MSBuild / Delphi 10.2 — 2026-10-19

Delphi 10.2 IDE compatibility fix: removed AfterTargets from DeployTranslations and appended the target to BuildDependsOn and MakeDependsOn after imports. Earlier MSBuild 4 checks did not cover the older project parser inside the IDE. check_project.py now rejects BeforeTargets/AfterTargets and verifies translation deployment in both dependency chains. Validated Win64 Build and Make plus matching bin/translations catalogs. No manual IDE test.

The MSBuild 2.0 schema accepted the fixed target and rejected AfterTargets, reproducing the IDE error. Corrected frmSettingsU uses to `OllamaAnalysisU`. Win64 Build Debug, Make Debug and Build Release passed; logs confirm DeployTranslations executed.

## Unit scope names — 2026-10-19

Delphi 10.2 unit scopes: Winapi was already present in Base, but the reported IDE build failed to resolve Windows in i18nLocalizer. Explicit complete scope lists were added to both Windows platform groups and Debug/Release Win32/Win64, without relying solely on Base inheritance. Installed i18n sources were not changed. check_project.py validates explicit Winapi/System/Vcl/Xml/Data in these groups. Validated Win64 Build Debug/Release and Make Debug, checking dcc64 -NS arguments. No manual IDE build.

## TFrame DFM — 2026-10-19

Fixed fraMap/fraGraph DFMs: replaced ClientHeight/ClientWidth with Height/Width and removed OldCreateOrder, PixelsPerInch and TextHeight. Both views now derive directly from TFrame; localization still initializes once after parenting and Translator handles language changes. Current user dimensions, layout and names (btnChartsConfigure) are retained. Project checks reject form-only properties in frame DFMs and verify DPR TFrame annotations while accepting inherited IDE namespace settings. A negative check rejected the original malformed DFMs. Repeated VerifyDetachedViews, VerifyLocalization and VerifyUI using synthetic VCL/SQLite without MSFS, covering creation, detach/return and languages. Built Debug/Release Win64. No manual IDE designer test.

Also reproduced Windows not found: DCC settings appeared after CodeGear.Delphi.Targets. Moved configuration groups before the import without changing their values; BuildDependsOn/MakeDependsOn remain after imports. Added an ordering check to check_project.py.

## Linear charts — 2026-10-19

Charts now draw a straight segment between adjacent samples. Removed the horizontal step before each change and the trailing hold to the right edge. Repeated existing VerifyChartView and VerifyUI checks for zoom, pan, range selection, cursor and VCL creation. Synthetic tests without MSFS; Win64 Debug/Release builds.

## About / menu / CHM — 2026-10-19

Added VerifyHelpAbout: transparent 16px icon corner on a colored background, 34 stable indices, six menu items hidden with Action=nil and restored on rebinding, modal About through aAboutExecute, Close and live PL/EN/DE/ES translation, map/chart help contexts and four CHMs. Real WM_HELP opened HTML Help, which the test closed. Captured and inspected synthetic-data VCL screenshots for docs/screenshots. Compiled four CHMs with six topics each; legacy HHC requires Windows-encoded contents and an isolated temporary path/environment. Repeated VerifyDetachedViews, VerifyLocalization, VerifyChartsConfigure, VerifyUI and four metadata checks. The default suite now has 37 Delphi programs; five ran for this change, without MSFS. Verified Debug/Release Win64 builds and source/application packages.

## Parameter names — 2026-10-19

Added VerifyParameterNames: 212 SimConnect captions, unit metadata including 0–1 fractions, engine and zero-based array indices, all iFly/Fenix/FBW/PMDG/AIRLINER catalogs, PL/EN/DE/ES and label/raw-ID search. Two distinct IDs with identical captions verify reorder/hide/check identity and retention of unavailable aircraft preferences. Loading a recording confirms model/database IDs remain raw after display lookup. Repeated VerifyChartsConfigure, VerifyChartView, VerifyLocalization, VerifyUI, VerifyHelpAbout and VerifyAircraftSDK; repeated name/UI checks after AIRLINER/GSX/FSHud captions. Eight distinct Delphi programs plus four metadata checks, using synthetic/mock data without MSFS. Default suite now has 38 programs; this change did not rerun the entire suite. README screenshots refreshed. Debug/Release Win64 builds and packaging verified.

Merged the current two-panel form layout and dimensions saved during the work. Wired Move first/Move last/Show chart and tested their raw-ID behavior in VerifyParameterNames. Removed a duplicate empty aMoveFirstExecute handler. Preserved the six chosen arrow icons and rebuilt alpha; pixel tests now cover 46 icons. Tools/tests support Icons/16x16 and Icons/22x22. Repeated VerifyChartsConfigure, VerifyParameterNames, VerifyDetachedViews and VerifyHelpAbout after the IDE merge. The old-form copy is preserved under src/Forms/__history/parameter-names-20261019-141233. DPROJ configurations use standard ordering before sources and imports.

VerifyChartsConfigure regression: preserve the user splitter ratio when growing/shrinking the window; Delphi 10.2 TSpeedButton-compatible bitmap format. Synthetic VCL test, no MSFS.


### Display units

Synthetic tests: VerifyDisplayUnits covers distance, vertical speed, airspeed, mass, US volume, affine temperature, pressure, NaN/Infinity, incompatible units, unknown SDK values, settings persistence/options, localization and buffering with 64 charts. VerifyParameterNames, VerifyChartView, VerifyUI, VerifyChartsConfigure and VerifyHelpAbout also passed (35 main/small icons, new icon transparency). No live MSFS session or user-recording smoothness measurement. Buffering remains enabled above 16 charts; repeated hover over the same sample does not refresh the whole inspector.

2026-10-19 — flightsim.to review package: fresh Win64 Release, PE dependency check, 66 ZIP entries, CRC/read-back validation, x64 EXE/DLL validation, three DLLs loaded from extraction, four CHMs/HTML, optional EFB layout sizes. Confirmed no Pascal source, recordings, logs, private configuration or account cache. Actual extracted EXE opened a responsive main window and closed gracefully (exit 0). Five English screenshots from a copy of an existing recording were visually reviewed. No live MSFS test. No upload; binary-only review package requires a Corresponding Source arrangement under the current AGPL license.



### Chart drag and drop

New VerifyChartDrag: synthetic VCL callback tests for cross-list add/remove, insertion/empty/end drops, deduplication, Ctrl-only reordering, duplicate captions with distinct raw IDs, filtered removal, cancellation, foreign sources, scroll timer state, native checkbox clicks and working-copy isolation. Visually reviewed the insertion marker screenshot. VerifyChartsConfigure, VerifyParameterNames, VerifyDetachedViews and VerifyLocalization also passed. Updated the stale localization-test expectation from three settings tabs to four, including Units. No physical mouse-drag trial or stationary-pointer autoscroll timing test. The default test.ps1 list now contains 40 programs.


### Windows language, nine locales and VersionInfo

VerifyVersionLanguage covers 14 regional/fallback cases, Windows UI language, persistent auto mode, nine language actions, settings save/cancel, exact localized captions, company/copyright Unicode, EXE version parsing and the About version label. French settings and Russian About screenshots were visually reviewed. VerifyLocalization, VerifyParameterNames, VerifyHelpAbout, VerifyChartsConfigure, VerifyDisplayUnits and VerifyChartDrag passed. Stale tests were adapted to the manual MainPanel/MainGroupBox rename, 40 icons and ten language choices. bump_build on a copy changed 0.1.0.2 to 0.1.0.3; the actual project remains 0.1.0.2. Catalog checks cover 987 definitions, nine locales, placeholders and DFM bindings. Synthetic tests; Windows language was not changed and no MSFS flight was run. The default list contains 41 verification programs; the entire suite was not rerun for this change.


Locale expansion (0.1.0.3): VerifyLocaleExpansion checks 30 regional/alias/fallback cases, all 25 language actions, exact settings titles, list indices and regional preference persistence; automatic mode, unchanged decimal separator and help fallback. It captures settings screenshots for be-BY, el-GR and pt-BR. Synthetic tests only, without MSFS. Catalog validation covers 1003 definitions in 25 locales, Format placeholders, Unicode and DFM bindings. The default suite contains 42 programs; this does not mean the entire suite was run for this change. Regression scope executed: VerifyLocaleExpansion, VerifyVersionLanguage, VerifyLocalization, VerifyParameterNames, VerifyHelpAbout, VerifyChartsConfigure, VerifyDisplayUnits, VerifyChartDrag. New text has not had native-speaker review; these tests do not certify linguistic quality.


VerifyGlobalLocales: synthetic checks for 32 code-sorted choices, aliases, five privately loaded font files and missing glyphs in seven script samples. Checks application/form BiDiMode, RTL/LTR transitions and restored label anchor positions, raw data/map/time-axis LTR, persisted settings and screenshots for all seven new languages. check_fonts.py verifies sources, SHA-256, font signatures and two OFL licenses. check_documentation.py checks four Translation.*.md notices and top-of-README links. The default list contains 43 programs; this does not mean the whole suite was run. No MSFS live test or native-speaker review.


Executed scope for this change: 11 tests passed: VerifyGlobalLocales, VerifyLocaleExpansion, VerifyVersionLanguage, VerifyLocalization, VerifyChartsConfigure, VerifyDetachedViews, VerifyDisplayUnits, VerifyHelpAbout, VerifyParameterNames, VerifyChartDrag, VerifyReport.


Also checked fresh windows created while Arabic/Hebrew is already active: RTL direction and right-hand label placement.


0.1.0.5 — VerifyRTLReturn starts with persisted ar-SA, opens the language menu through WM_INITMENUPOPUP, switches to en-US, then performs four ar-SA/he-IL → pl-PL round trips. Checks VCL direction and native HWND RTL reading/right/left-scrollbar/layout flags throughout the control tree, panel placement, clean language captions and unchanged ImageIndex values for all 32 language actions. Test settings are restored; the user bin/settings.ini is not used. Selected scope passed: VerifyRTLReturn, VerifyGlobalLocales, VerifyDetachedViews, VerifyLocalization. Synthetic only; no MSFS flight. The default suite contains 44 programs and was not run in full.


0.1.0.6: VerifyRTLReturn now checks actual MFT_RIGHTORDER/MFT_RIGHTJUSTIFY flags throughout the HMENU tree, popup initialization and Hebrew → Automatic. The test reproduced stale flags before the fix and passed afterward. Other passing tests: VerifyGlobalLocales, VerifyDetachedViews, VerifyHelpAbout. No live MSFS flight. StackTrace and StackFrames directives retained; Debug compilation with PDB generation verified.


VerifyVersionLanguage — PASS (EXE VersionInfo 0.1.0.6).


0.1.0.7 — packaging: removed mateusz-efb-ifly and Community/Optional-Community payloads, --addon argument and bundled-install instructions. ZIP validation checks that no add-on is present. Distribution-only change; no additional VCL behavior tests.

Added recorded FBW FMA mode decoding and the E/WD text catalog with formatting, replay-time flashing and visible unknown IDs. Debug settings can override the instrument family. The map displays PLN restrictions and resolves unnamed fixes against the SimBrief navlog by coordinates. Full STS, iFly/B38M FMA and expanded procedures/holds/missed approach still require an additional data source; see `support/fbw/display-protocol.md`.

Synthetic coverage: VerifyAirbusDisplays (FMA words, EWD codes, missing/unknown data, debug override), VerifyFlightPlan (PLN constraints and OFP coordinates). Live simulator validation not performed.

Selected SID/STAR/APP procedures are expanded through SimConnect Facilities, including runway/enroute/IAF transitions, restrictions, RF/AF arcs and missed approach. A navdata snapshot is stored with the original route and replayed offline. HA/HF/HM holds retain their parameters and use schematic map symbols; missed approach is dark gray. B38M/iFly FMA is reconstructed from recorded MCP lamps and SimVars, labelled FMA RECONSTRUCTED. It is an approximation, especially VNAV, THR HLD and FLARE, rather than direct add-on FMA output.

VerifyProcedureRoute: mock Facilities API exports and headers, out-of-order parents, ItemIndex ordering, wrong runway exclusion, RF geometry, holding/missed constraints, repeated expansion, SQLite and offline replay. VerifyIFlyFMA: lamp encoding, mode priorities, AP/FD, ILS/armed GS, altitude capture and missing data. VerifyPFD737, VerifyFlightPlan, VerifySimBrief, VerifySubscriptions: regression checks. No live simulator or IDE designer validation. VerifyProcedureRoute disables the Delphi 10.2 Win64 optimizer to avoid compiler internal error URW1237; application builds retain their normal settings. DLL mock projects now explicitly set GenDll, preventing stale .dll use when the compiler otherwise writes a library to .exe.

Added A320 and B38M pitch/roll Flight Director replay, standard FD/EX1 capture in radians and a B38M FD disable option. Missing historical values remain unavailable; real zero remains valid. Sources and limitations: `support/fbw/flight-director.md`.
VerifyFlightDirector, ProbeFlightDirector, VerifyAirbusDisplays, VerifyPFD737: synthetic replay tests; live simulator channels not verified.

B38M PFD now follows the reference layout with crossbar FD, full attitude background, aligned tapes, compass half-rose and GS/TAS/wind. Optional AoA in Debug settings uses recorded INCIDENCE ALPHA. iFly SDK MCP digits recover selected targets; reconstructed N1/MCP SPD can use SDK ARM and mode lamps when standard A/T is false. FMA remains estimated.
VerifyPFD737: synthetic AoA/radians/ground/missing/optional/render checks. VerifyIFlyFMA: 22 recorded AFDS configurations plus synthetic cases; no authoritative recorded FMA text, no live comparison.

Optional MAX flight-information panel alongside the PFD shows flight number, SDK transponder code including leading zeros, registration, SELCAL when available, recorded UTC/date and elapsed recording time. Hide it in Debug settings. Missing fields remain --; time never uses the replay computer clock.
VerifyPFD737: synthetic panel rendering/hide, recorded midnight crossing, reverse seek, invalid time, missing SELCAL and squawk leading zero. VerifyFlightDirector: SQLite flight metadata roundtrip. No live test.

FBW A320 minima: BARO, RADIO and NO DH from valid ARINC words, PFD readout and a minimum marker when it enters the altitude tape range. RADIO uses current radio height, not an absolute MSL minimum. B38M flight information can move left/right (CPT/FO) independently of hiding it. Selected minima values remain unconfirmed in the available iFly/Fenix catalogs; design DECISION HEIGHT is not treated as a pilot setting.
VerifyPFDMinima: synthetic ARINC BARO/RADIO/NO DH, zero/missing, relative RA, off-scale/amber marker. VerifyPFD737: CPT/FO panel position and return. VerifyAirbusDisplays: BARO visual fixture. No live comparison.

B38M PFD: wind-flow arrow relative to TRUE heading and VOR/ADF 1/2 blocks with tuned frequency and available DME. New NAV/ADF channels are nullable REAL; older recordings do not gain synthetic values. Both PFDs switch selected IAS/Mach and show STD independently of numeric pressure availability; FBW uses native STD/QNH/QFE states. Momentary STD/SPD-MACH buttons are not latched mode states.
VerifyPFDReadouts: synthetic native/standard mode priority, STD vs QNH 1013, QFE/invalid ARINC, IAS/Mach/blank MCP, VOR/ADF/OFF/zero/missing DME, TRUE-relative wind and SQLite NULL/frequency roundtrip. VerifyPFD737/VerifyAirbusDisplays snapshots; VerifySubscriptions checks NAV/ADF only during flight. No live test.

Recording playback: play/pause, stop resetting to beginning and 1x, beginning/end, ±30 s jumps and 0.125/0.25/0.5/0.75/1/2/4/8/16x rates. Map, charts and detached instruments share the timeline. New recordings retain their configured initial sampling interval; older recordings use the median valid sample spacing or a 500 ms fallback. Both image lists have repaired alpha while preserving manual images and indices.
VerifyPlayback: deterministic playback clock/rates/pause/seek/gaps/end/stop, stored and inferred cadence, SQLite and read-only legacy schema. VerifyInstrumentFrames: DFM actions, timer/glyph switching and transparent icon drawing in both sizes. Synthetic only, no simulator required.


Native VCL docking: VerifyNativeDocking checks floating tabs, side docking, dock-host and DockManager-tree persistence, close-to-return and control lifetime with synthetic VCL controls. VerifyDetachedViews and VerifyViewState cover compatibility with the six existing detachable views. Manual dragging during a live simulator flight was not tested.


VerifyNativeDocking additionally checks 50 moves of a single preview HWND, negative screen coordinates, a hollow border region, hiding at drag completion/cancellation and HWND destruction. Synthetic WinAPI/VCL test; the reported monitor configuration has not been manually reproduced.


VerifyPlayback covers mid-sample interpolation without advancing the sample index, 359→1° heading wrap, map motion across the date line, sample-held Boolean/SDK values, NaN preservation, unchanged recording arrays and recording-break suppression. Synthetic data; visual smoothness on a real recording has not been manually assessed.


VerifyInstrumentRender checks actual edge pixels, clipping and DC restoration at 25/50/75/100/125/150/200/300%, plus B38M/A320 PFD, six-pack and EICAS PNG rendering with visual inspection. Synthetic WinAPI/VCL test, not a physical per-monitor DPI transition test. VerifyInstrumentFrames covers embedded/detached instrument regressions.


VerifyPanelProportions checks repeated nested resizing without rounding drift, new splitter ratios, hidden panels and minimum center space. Real VCL PFD/EICAS windows cover horizontal/vertical docking, repeated resizing and closing a host without closing the engine view. Synthetic tests; manual dragging during a simulator flight was not performed.


Offline checks: VerifySimWeather (independent sources, HTTP queue, decoding/comparison, DFM), test_weather_bridge.js (mock Coherent), VerifyReplayExtras (FLIGHT_START and 30-second ATC), VerifyUI (search and all-tabs undocking), VerifySimBriefUI, VerifyRecordingFiles (destination from stored PLN). No live simulator weather/procedure trial: simulator was not running. No full CTD dump analysis.


VerifySimBriefMaps covers mock HTTP GIF/invalid HTML, BLOB storage, plan identity, offline DFM rendering with the server stopped, no redundant downloads and deletion. VerifySimBriefUI posts WM_MOUSEWHEEL through the Windows queue and checks Loaded runtime binding without DFM OnMessage. Native docking/UI tests check client fill without redocking and zero idle resize events. iFly display tests check that Tick18-only changes create no SDK delta. One real SimBrief map returned HTTP 200 and a valid 32904-byte GIF without redirects, fetched with Python; not a complete live GUI trial. IDE designer was not automated.


Fenix 3.0.0.7454 static audit: 176 XMLs across common/aircraft-320, 3826 references in 55 files, 1748 active candidates and 300 historical-only names. VerifyCatalogSources.dpr checks moved attachment fields, deduplication, hashes, history partition and matching-version package selection excluding liveries. VerifyFenix uses a rebuilt mock DLL for 1748 reads, null/zero/staleness, old recorded keys and no retired-breaker subscriptions. No live trial on the updated Fenix; declarations do not establish runtime availability, units or full FMA/FD outputs.

Ghost/ATC: VerifyGhostReplay + MockGhostSim covers the in-memory SQLite cache, thread ownership, create/freeze/animate/remove, pause, ±10 s and MSFS24 gating. VerifyNativeATC checks HTTP, persistence, deduplication, replay and expiry; VerifyATCBridge.js checks payload text extraction. VerifyIDEProjectSave writes an isolated DPROJ copy via TXmlIniFile. Synthetic only; live FSLTL/ATC and saving in the open IDE remain unverified (desktop channel unavailable).

IDE groups: check_project_groups.py — PASS for 2 groups and 101 projects (GUIDs, paths, targets, versions and IDE nodes). VerifyIDEProjectSave — PASS: writes/reloads 103 isolated group/project copies with TXmlIniFile. Main group Release Win64 build — PASS (application + Setup). Saving in the open IDE still needs confirmation after reloading the group; the XML test alone does not prove the IDE crash is fixed.

Bridge/FSLTL: VerifyBridgeInstall PASS covers Community detection, install/update/repair, unchanged timestamps and owned-file-only removal. VerifyBridgeSignature PASS covers two encrypted ZIP layers, independent RSA-3072/PSS signatures/manifests, wrong password/product and tampered payload, using an ephemeral CNG key only. VerifyAIModelMatching and extended VerifyGhostReplay PASS cover FSLTL/AIG type/livery choice and fallback when a library is absent. VerifySetupUI, VerifySetupMaintenance, VerifySetupSignature, VerifyUI and VerifySubscriptions PASS. The fact-only FSLTL catalog covers 75 families and 134 model XML hashes from the local Base clone. All checks are isolated/synthetic; no real Community installation or live animation trial. Initial crypto-test failures were caused by the full Dane_HDD mounted volume; tests passed after removing generated fixture/DCU artifacts only.


## Installer source split

`VerifySetupArchitecture` creates the base DFM wizard for two unrelated synthetic
products, checks independent Program Files/release identities and navigation,
and links no FDR units. `VerifySetupUI` exercises the inherited MSFS page, back
navigation, default Community checkbox, modal retry/cancel and asynchronous
update fallback. `VerifySetupMaintenance` covers all 32 locales, RTL/LTR,
retention choices and exact-version repair. Signature, bridge ownership and
IDE XML-save probes remain isolated tests. The signed/encrypted full packager
interop test generates an encrypted ephemeral RSA key outside all repositories;
production private keys are not used. Windows installation and registry writes
are test doubles; no live installation, MSFS or Community directory is changed.

Shared sources live beside the recorder repository in `setup-common`,
`setup-core` and `MSFS24-FDR-Setup`. Version information comes directly from the
Common submodule (`src/Common/VersionU.pas`), without modifying that submodule.
The core's final license text will be supplied by the author. No new Git
repositories were created.


Release update gate: VerifySetup now checks disabled controls, forced false on save, legacy/manual INI opt-in rejection and a blocked programmatic check request. The distributed Setup is a native message-only stub, built without installer/private inputs. The real installer remains development code and requires explicit `tools/build_setup.ps1 -RealInstaller`.


Compiled resources: *.res are ignored and absent from the Git index. Main, stub
and i18n resources rebuild from checked-in *.rc (and original bitmap/icon inputs)
using tools/build_resources.py and the Windows SDK Resource Compiler. Independent
MSBuild test projects rebuild these resources through Tests.Shared.props.


Installer separation: recorder Core no longer contains the product/key unit and the
recorder DPR has no installer/common updater imports. VerifySetup uses the recorder
mutex and confirms the independent installer detects it; disabled update settings
and programmatic requests remain covered by the same isolated regression.


The Verify*.dpr regressions use DUnitX (91 projects, including the new VerifyCatalogSources). Python tests from tests have moved to DPR: assertions are native; production Python import tools are exercised through their CLI with isolated fixtures. Mocks and probes remain standalone executables/DLLs. Each DPR has a DPROJ and a Tests.groupproj entry, synchronized by tools/sync_test_projects.py. test.ps1 builds MSBuild projects, runs the formatter before compilation and removes test MAP/RSM files in finally. Current run results are recorded in docs/releases/0.1.1-review.md. AI language tests cover all 32 locales without calling a model; PFD tests check panel pixels on the left for CPT and on the right for FO.

Help: VerifyHelpContexts checks 62 topics in four languages, all DFM HelpContext IDs, screenshot languages and the 398-parameter catalog. build_help.py decompiles each CHM and compares page/image bytes with sources. The 228 screenshots use synthetic telemetry and an anonymized EPLL loop/OFP. VerifyPFD737 constructs frames in all 32 locales; VerifyRTLReturn checks menu position through action updates; VerifySimWeather covers clouds without CB/TCU.

Help encoding: VerifyHelpContexts reads HTML/HHC using the matching Windows codepage and checks Polish glyphs and literal TOC labels. build_help.py verifies all 248 labels directly in compiled #STRINGS and checks #TOCIDX using the 7-Zip CLI.

Report regression: VerifyReport shares HelpScreenshotU with the help capture tool. It checks retained text and native EM_FORMATRANGE bitmap rendering; capture also requires visible text pixels. PL/EN/DE/ES reports have opening/continuation images. Flight fixtures have monotonic 20 s timestamps and stored interval, flight phases, changing configuration, GSX and ATC.

`VerifyRTLReturn` also forces 40 `CM_MENUCHANGED` notifications on an already attached menu, checking native HMENU flags and stable header positions after switching from RTL to automatic language selection.

The menu regression counts native WM_NCPAINT messages: 40 unchanged-header notifications must not repaint the frame, while a changed header must repaint. Version tests compare the deployed i18n catalog with its source and check English/Polish recording, value and chart search cues.

`tools/check_project_units.py` checks all application, test and tool DPRs for explicit relative project-unit paths and matching DCCReference entries. `--fix` adds missing declarations without rebuilding XML configuration; test.ps1 runs this check. RTL/VCL/vendor libraries retain their configured search paths.

Full runs and `VerifyReleasePEM` build both application and stub before the signing fixture so their executable VersionInfo values match.

Explicit-DPR-path audit: the full run compiled the suite and passed 93 of 94 DUnitX cases plus the standalone RTL regression. The sole failure was a stale stub version in the packaging fixture; after adding the missing executable-build dependency, `VerifyReleasePEM` passed on recheck (94/94 overall). Token comparison of 103 DPRs and configuration comparison of 104 DPROJs preserved code and metadata except the added paths/references and Build.

B38M PFD regression covers LOT131 from legacy LOT/131 fields, full callsigns, whitespace, leading zeroes, suffixes and missing airline/number. Historical values were confirmed using read-only SQLite queries.

The remaining standalone VerifyRTLReturn scenario now uses DUnitX with preserved assertions and separate Setup/TearDown for its settings backup. All Verify programs use DUnitX.
