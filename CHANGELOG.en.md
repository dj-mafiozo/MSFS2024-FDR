# Changelog

The history starts with the initial Preview, followed by releases **0.1.0**, **0.1.1** and later versions. Changes are grouped by release; individual build numbers are not listed.


## 0.1.1

- B38M PFD flight information combines the recorded airline ICAO designator and flight number, such as LOT and 131 becoming LOT131, while preserving complete callsigns.

- Avoid repainting unchanged menu headers and coalesce real changes into one redraw. Translate the value-search cue and deploy the current translation catalog after Build/Make.

- Avoid reattaching an already active menu during action updates, preventing transient RTL/LTR flips and menu-header flicker.

- Fixed blank analysis-report illustrations in CHM. Examples now include fuller reports, flight phases, configuration, engines, ATC history and GSX progress.

- Fixed Polish and Western European characters in CHM navigation; compilation now validates every label in the compiled file.

- Expanded CHM help: 62 chapters in PL/EN/DE/ES, 228 localized standalone-panel illustrations, every ECAM page and a catalog of 398 standard parameters. Plan/OFP examples use an anonymized EPLL–EPLL loop. Fixed contents encoding and image layout.


- B38M flight information: left for CPT, right for FO, with corrected settings labels. AI reports are instructed to use the current application language. Completed playback-menu and PMDG 777 diagnostic translations.


- A320 PFD displays nonzero vertical speed beside the pointer in hundreds of ft/min; the numeric readout is hidden at zero.

- Application resources rebuild from RC sources; compiled RES files are not versioned. Portable packaging produces an unencrypted ZIP with current documentation.
- The temporary MSFS24-FDR-Setup.exe only displays an installer/updater/uninstaller development notice and exits. Updates are disabled in settings and startup code, including previously enabled INI preferences; extract and run this release manually.

- Added FSLTLU animation input profiles for 75 model families, including reversers. Startup inventories installed FSLTL/AIG models; ghost selects the best ICAO/livery match, prefers FSLTL on ties and falls back to default models. Recordings capture additional thrust/visual channels.

- Renamed the optional addon to MSFS24-FDR-Bridge; the portable package contains a plain folder for manual copying into Community.

- Improved Delphi project/test-group metadata and added project save checks through TXmlIniFile.

- Native MSFS24 ATC: the optional bridge receives JS_LISTENER_ATC and stores text plus raw payloads; replay and the last-message label use recording time. Clearances, runways and ATC/COM station states are captured separately via SimConnect.

- Ghost replay uses its own thread, SimConnect connection and in-memory SQLite cache, with FSLTL/AIPlane matching, interpolation, animations and play/pause/stop/±10 s controls. Refresh rate is configurable from 5 to 60 Hz; repaired the rewind icon transparency.

- CSS 737 Classic: shared support for 300/400/500 variants (B733/B734/B735), flap labels and ICAO detection from aircraft titles.

- Move standard flaps_handle_index handling into FlapsHandleU with an explicit ICAO case and empty default DisplayValue. Coverage: 156 codes, 66 profiles, 30 aircraft without wing flaps and 60 unverified empty mappings. Standard A320 SimConnect indices include 1+F (six states), separate from the five-position SDK lever. MD-11 uses the recorded aircraft title to select TFDi/SkySim layouts; recorded position counts reject mismatched profiles. Add evidence from 26 configurations and a coverage CSV including default MSFS 2024 aircraft.

- Re-audit SDK headers and cockpit XML: 5118 fields have DisplayValue dictionaries (2313 additional). Correct GB18030 decoding recovers iFly enums/display glyph codes; Fenix ANIMTIP labels, FBW documentation and PMDG comments add selector values. Addon catalogs gain explicit boolean and momentary-button states. Mappings retain source/SHA-256 provenance; undocumented intermediate values and continuous ranges remain numeric.

- GSX Pro progress bars appear from Requested, retain completed status and follow backward timeline seeks. Separate passenger/cargo bars and current fuel-truck counter progress; services without counters use indeterminate indicators. Record the fuel-truck counter, its limit and hose connection state.

- Friendly switch values: catalogs include DisplayValue number=label dictionaries shared by the inspector and chart cursor. Boeing flap/autobrake positions retain untranslated cockpit labels; standard flap detents depend on aircraft type. GSX shows localized service stages, cumulative passengers against the newly recorded target count and actual cargo progress percentage, preserving unknown or missing values.

- Validate the simulator reported by SimConnect OPEN before subscribing: recording actions and telemetry are enabled only for MSFS 2024. Older and unknown simulators receive no subscriptions and show a localized compatibility message.

- Updated Fenix inventory for modular common/aircraft-320 packages 3.0.0.7454: 1748 current L-var candidates covering the CEO cockpit, panels, CFM/IAE and attachment variants. Retained 300 historical-only definitions without subscribing them. Replay discovers recorded Fenix keys instead of imposing the current catalog on old flights; snapshots retain catalog hash and package version.

- Exclude the technical iFly Tick18 counter before delta storage and from parameter lists. SimBrief GIF maps download in the background, are stored as BLOBs with the matching plan and render offline; removed the network filing section. Fixed mouse-wheel initialization in Loaded and docked tab client sizing on startup and activation.

- Fixed flickering and repeated panel resizing: unchanged docking topology no longer triggers realignment; status text is assigned only when its content changes.

- Weather: optional Community panel requests simulator METAR/TAF. MSFS and AviationWeather reports are stored independently, compared and shown in a decoded METAR dialog. Historical requests never fetch current simulator weather.
- UI fixes: parameter name/description search, GSX Pro tab, ATC message shown for 30 seconds of recording time, SimBrief hover scrolling, DFM map/chart/SimBrief frames and collapsed empty docking hosts.
- MSFS24 automatic recording waits for FLIGHT_START rather than aircraft loading. Destination metadata comes from the plan, including repair of missing indexed destinations in older recordings. Procedure geometry requests retry and log detailed diagnostics.

- Main-window panels retain their proportions when resized; dragging a splitter establishes a new ratio while respecting minimum space and hidden/detached views. EICAS/ECAM can dock beside or below a floating PFD and resize proportionally with it. Closing the host keeps other views alive; the central view-state store restores the dock host and side.

- Instrument antialiasing: shared supersampling follows the final pixel size, with grayscale-smoothed text and filtered downscaling. Supports scales below 100%, enlargement, panel resizing and detached windows. Horizon clipping masks scale with the render surface; supersampling memory is bounded.

- Smooth playback: views refresh on every timer tick, interpolating continuous standard telemetry, map position and chart cursor between recorded samples. Angular headings take the shortest path through north; discrete states and raw SDK payloads remain sample-held. Recording gaps and missing values are not filled with invented motion. Parameter-table rebuilds are limited to sample changes.

- Dock dragging uses a separate non-activating border preview window instead of desktop XOR drawing. Moving, dropping and cancelling remove the preview without leaving repeated outlines across monitors.

- Native VCL docking: drag tabs into floating windows and dock them back into tabs or four edge sites with split layouts and splitters. Existing detachable frames can also be docked. Tab order, dock hosts, layout and floating bounds persist; closing a detached tab returns it to the data panel. The application and main-window titles include the executable version.

- Moving the mouse over charts no longer seeks the timeline while playback is running. Mouse seeking resumes when paused.

- ATC / FSHud tab: recorded communication text, frequency and transmitting callsign synchronized with playback; history retains messages removed from the short FSHud list. Missing data is not reconstructed.

- Recording playback: play/pause, stop resetting to beginning and 1x, beginning/end, ±30 s jumps and 0.125/0.25/0.5/0.75/1/2/4/8/16x rates. Map, charts and detached instruments share the timeline. New recordings retain their configured initial sampling interval; older recordings use the median valid sample spacing or a 500 ms fallback. Both image lists have repaired alpha while preserving manual images and indices.

- B38M PFD: wind-flow arrow relative to TRUE heading and VOR/ADF 1/2 blocks with tuned frequency and available DME. New NAV/ADF channels are nullable REAL; older recordings do not gain synthetic values. Both PFDs switch selected IAS/Mach and show STD independently of numeric pressure availability; FBW uses native STD/QNH/QFE states. Momentary STD/SPD-MACH buttons are not latched mode states.

- FBW A320 minima: BARO, RADIO and NO DH from valid ARINC words, PFD readout and a minimum marker when it enters the altitude tape range. RADIO uses current radio height, not an absolute MSL minimum. B38M flight information can move left/right (CPT/FO) independently of hiding it. Selected minima values remain unconfirmed in the available iFly/Fenix catalogs; design DECISION HEIGHT is not treated as a pilot setting.

- Optional MAX flight-information panel alongside the PFD shows flight number, SDK transponder code including leading zeros, registration, SELCAL when available, recorded UTC/date and elapsed recording time. Hide it in Debug settings. Missing fields remain --; time never uses the replay computer clock.

- B38M PFD now follows the reference layout with crossbar FD, full attitude background, aligned tapes, compass half-rose and GS/TAS/wind. Optional AoA in Debug settings uses recorded INCIDENCE ALPHA. iFly SDK MCP digits recover selected targets; reconstructed N1/MCP SPD can use SDK ARM and mode lamps when standard A/T is false. FMA remains estimated.

- Added A320 and B38M pitch/roll Flight Director replay, standard FD/EX1 capture in radians and a B38M FD disable option. Missing historical values remain unavailable; real zero remains valid. Sources and limitations: `support/fbw/flight-director.md`.

- Selected SID/STAR/APP procedures are expanded through SimConnect Facilities, including runway/enroute/IAF transitions, restrictions, RF/AF arcs and missed approach. A navdata snapshot is stored with the original route and replayed offline. HA/HF/HM holds retain their parameters and use schematic map symbols; missed approach is dark gray. B38M/iFly FMA is reconstructed from recorded MCP lamps and SimVars, labelled FMA RECONSTRUCTED. It is an approximation, especially VNAV, THR HLD and FLARE, rather than direct add-on FMA output.

- Added recorded FBW FMA mode decoding and the E/WD text catalog with formatting, replay-time flashing and visible unknown IDs. Debug settings can override the instrument family. The map displays PLN restrictions and resolves unnamed fixes against the SimBrief navlog by coordinates. Full STS still requires an additional data source; see `support/fbw/display-protocol.md`.

- Native A320 PFD/ECAM (E/WD + SD) frames for Fenix/FBW in existing detachable slots; 13 manual SD pages and Recorded following the actual FBW display index. Added 47 FBW fields, SSM-validated ARINC429 decoding and explicit missing values. Fenix automatic page remains unavailable from current sources.

- Verified single/multi-flight Qt database import through a DFM dialog into separate `.mfzr` files, preserving sources and avoiding repeat-import duplicates. Legacy export preserves the local-time offset migration version.

- Export one recording to the original Qt SQLite schema with standard telemetry, engines, events and contacts only, excluding MSFS24-FDR extensions. New menu action/save dialog, atomic destination replacement and unchanged source recording.

- Separate DFM view container and timeline footer; resizing or detaching views no longer lets the instrument splitter displace or resize the slider panel.

- Removed engine/EICAS ScrollBoxes; entire displays fit the available client area without sample-driven control resizing. Fixed PFD/EICAS splitter with live resizing and persisted split width.

- ICAO B38M alone selects `ikB38MPFD`: dedicated PFD/EICAS frames replace generic instruments/engines in their existing panels. Dock/float, icons, geometry and timeline survive aircraft changes; B736–B739 retain generic PFD. Generic PFD shares IAS/ALT tapes and nonlinear pointer V/S with B38M and uses compact heading below the horizon. Fixed test-project generation to prevent silently skipped compilation.

- Automatic B38M EICAS in the detachable engine frame: independent N1/EGT/N2/FF, oil, vibration, fuel, flaps and recorded-state messages. Added TAT, oil quantity, tank quantities and flap angles; legacy replay/analysis preserves missing data without modifying read-only files.

- Support for the rebuilt lower instrument/engine panels and saved splitter sizes; centralized detach/dock icons, transparent frame glyphs, ICAO designators instead of ATCCOM keys, oil pressure in psi, and a waiting state for SimConnect_Open E_FAIL without duplicate status errors.

- Dedicated ILS LOC/GS diamond scales on the simplified PFD, independent signal-valid flags, no ILS indications for missing/GPS data, and validation of direct TFrame ancestry for DFM inline frames.

- Direct TFrame ancestry for inline instrument and engine frames for Delphi designer compatibility; localization skips components in design mode.

- Single-instance recorder mutex prevents duplicate recorder instances.





### Portable release

- Extract the unencrypted ZIP and run MSFS2024-FDR.exe manually.
- The included Setup EXE only displays a development notice and exits. Automatic/manual updates remain disabled, including previously enabled settings.
- Native formatted changelog viewer: Polish for the Polish interface, English for other interface languages.

### Recording and storage

- One SQLite `.mfzr` file per flight and a metadata-only `flight_data.mfzi` index in `%LocalAppData%\MSFS24-FDR`.
- File hierarchy based on aircraft type, departure airport, year and month; filenames include recording start time and airport identifiers.
- Incremental migration from legacy `flight_data.db`, retaining the original, groups, telemetry, events and FMC/MCDU data.
- Discovery of dropped recording files, explicit recording/legacy database import, recording lifecycle states and recovery prompts after crashes.
- A newest-first recording tree with localized months, combined group/search filtering and retained selection and expansion state.
- Missing files are hidden without deleting their metadata.
- Read-only, single-recording command-line preview without the left panel, recording controls or SimConnect.
- User settings, logs, caches and working files moved out of the application directory, with migration of existing data.

### Integrations and visualization

- WebView2 removed: native OFP text and Markdown report rendering.
- Timeline-synchronized FMC/MCDU replay with device backgrounds, recorded formatting and annunciators, and automatic aircraft-family selection.
- Official PMDG 777 SDK integration, including three CDUs.
- Separate L-var catalogs for PMDG DC-6, CSS 737 Classic, Maddog X, SkySim DC-9/MD-11, TFDi MD-11 and selected official Asobo helicopters.
- Telemetry subscriptions selected by aircraft, engine configuration and flight-session state; idle subscriptions retained for detecting the next flight.
- Detachable six-pack and engine instrument frames, synchronized to the recording timeline.
- Central storage of each detachable view's docking state, position and size.
- Instrument, engine and FMC/MCDU tabs and frames declared in DFM.
- Import icon transparency, localization and Delphi project/deployment fixes.
- Additional synthetic regression tests; see [Testy.en.md](Testy.en.md) for executed checks and limitations.

## 0.1.0

Based on the [release commit](https://github.com/dj-mafiozo/MSFS2024-FDR/commit/64073c2e213d2e697a9d6b78023ec530ed2ac2d7).

- Automatic Windows display-language detection with English fallback and 32 interface locales, including regional variants.
- Regional language selections retained, languages sorted by code and visible mnemonic markers removed from language names.
- Translation notices and GitHub correction guidance in four documentation languages.
- Privately loaded Noto fonts for supported scripts, with OFL licenses and provenance checksums.
- Arabic and Hebrew RTL layouts, while maps, charts, timelines and technical content remain LTR.
- Correct RTL-to-LTR restoration, including Hebrew-to-Automatic switching, existing windows and native submenus.
- Delphi-StackTrace, stack frames and matching packaged PDB diagnostic symbols.
- Executable VersionInfo shown in About; centralized version metadata and independent build increments.
- Delphi 10.2 project ordering, dependency path and post-build command fixes.
- The iFly Community EFB add-on removed from distribution archives.
- Expanded localization, RTL, menu, documentation and package validation.

## Preview

Based on the [initial commit](https://github.com/dj-mafiozo/MSFS2024-FDR/commit/d94814179575b4918a5088e708664360e1270942).

- Standalone Delphi 10.2 VCL x66 application, extensively rebuilt from Michael Hsu's Qt recorder, retaining attribution and AGPL-3.0 licensing.
- Automatic/manual full-session recording with configurable sampling, a dedicated worker thread and diagnostic logging.
- Aircraft, engine, control, AP/A/T, individual landing gear, weather and cockpit-event capture.
- SQLite WAL storage, separate reader/writer connections, legacy migration, schema repair and backups.
- Timestamped auxiliary data and FMC/MCDU screen changes, including raw text and available presentation metadata.
- iFly 737 MAX SDK, Fenix A32X, FlyByWire A32NX and PMDG 737 NG3 integrations, supported segmented displays and FlightPadFMC screen export.
- Boeing PERF INIT, N1 LIMIT, TAKEOFF REF and APPROACH REF parsing, plus available Airbus INIT/PERF data and performance references.
- Common AIRLINER variables, GSX service states and optional FSHud panel/message capture.
- PLN import, saved plan revisions, KML export and optional default-EFB route bridging.
- SimBrief matching, optional older matching OFPs, saved briefings and a collapsible Dispatch/LIDO view.
- Takeoff/landing METAR observations, distinguished from ambient weather at the aircraft.
- Synchronized map, charts, timeline and parameter inspector; chart selection/reordering without the former eight-chart limit.
- Mouse panning and range zoom, detached map/chart windows, readable parameter names and optional display-unit conversion.
- Recording groups, filters, modal group assignment, flight information and double-click opening.
- Optional Codex CLI, Gemini and Ollama analysis with independent event windows, weather and FMC references, rounded context values and delta hysteresis.
- Polish analysis reports, rendered through WebView2 in this release.
- Polish, English, German and Spanish interfaces and documentation, editable `.i18n` catalog and F1 CHM/HTML help.
- Runtime packaging without Qt, with dependency licenses, integrity checks and documented synthetic/live-test limitations.
