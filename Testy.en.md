# Tests — MSFS2024-FDR Delphi VCL

[Polski](Testy.md) | [English](Testy.en.md) | [Deutsch](Testy.de.md) | [Español](Testy.es.md)

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
