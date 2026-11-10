[Translation notes](Translation.en.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

# MSFS24-FDR

Native flight recorder/replay for **Microsoft Flight Simulator 2024**, Windows 10/11 Win64. MSFS 2020, FSX and Prepar3D are unsupported. Preparing release **0.1.1**; the full EXE version appears in the title and About.

## Portable installation

1. Extract the complete ZIP without a password, preserving folders.
2. Run `MSFS2024-FDR.exe`, retaining the DLLs, fonts, graphics and `help/*.chm`.
3. Optionally install `Optional-Community/MSFS24-FDR-Bridge` in Community following [its guide](community/Bridge/README.en.md). The recorder itself is not a Community addon.

`MSFS24-FDR-Setup.exe` is a notice-only stub. It does not install/uninstall/update; both update options are disabled. Update manually with the app closed, preserving user data. Qt/WebView2 are not required.

## Recordings and storage

- Settings, logs, caches and the `flight_data.mfzi` index: `%LocalAppData%\MSFS24-FDR`.
- Each flight is a SQLite `.mfzr` under `Recordings\Aircraft_ICAO\Departure_ICAO\YYYY\MM\...`. Filenames use recording start time. The tree shows localized month names, newest flights first.
- Search/groups filter the library. Import `.mfzr`, legacy `flight_data.db` and original Qt-recorder databases; export one legacy flight without FDR extensions.
- Migration preserves the source, dropped files are discovered and interrupted flights can be recovered. Missing files retain index metadata.
- Preview: `MSFS2024-FDR.exe ".\Recordings\flight.mfzr"` shows that flight only, without library, recording or SimConnect.

Back up the complete data folder with the app closed. Do not remove active SQLite WAL/SHM files or replace personal settings with the example INI.

## Features

| Area | Capabilities |
|---|---|
| Recording | Manual or automatic after Ready for flight; stored millisecond sampling interval; subscriptions selected by aircraft/engine. |
| Replay | Shared timeline, continuous-value interpolation, pause/stop, ±30 s, beginning/end and 0.125–16x. Switch states stay discrete. |
| Docking | Detachable tabs/frames, main/floating hosts, saved state and independent geometry, proportional panels. |
| Instruments | Six-pack, piston/turboprop/jet gauges, B38M PFD/EICAS and A320 PFD/ECAM; antialiasing and preserved aspect ratio. |
| B38M | FD, reconstructed FMA, available ILS/baro/STD/IAS-Mach/minima, wind and VOR/ADF; optional AoA and flight info, CPT left/FO right. |
| A320 | Fenix/FBW PFD, E/WD, 13 SD pages plus Recorded, available FD/FMA/warnings/STS/minima. |
| FMC/MCDU | Recorded text/annunciators, formatting/backgrounds, automatic device family and detachable synchronized view. |
| Map/plan | Actual track, magenta plan, fixes/constraints, available SID/STAR/approach/holds; dark-gray missed approach; PNG/KML. |
| SimBrief | Monospace OFP, downloaded maps stored with the flight; no filing old plans on online networks. |
| ATC/GSX | FSHud and available bridge-based native ATC, recent-message caption; service state and measured progress including refueling. |
| Weather | Separate simulator/aviationweather.gov reports, available METAR/TAF, decoding/comparison. |
| Ghost | Separate visual AI aircraft, installed AIG/FSLTL matching or fallback, supported animations, ±10 s and 5–60 Hz. |
| AI | Codex CLI, Gemini or Ollama, independent takeoff/landing windows, Markdown reports requested in the application language. |

Availability depends on what the aircraft/addon version actually recorded. Missing is not zero/OFF. iFly FMA and some warnings are reconstructions, not guaranteed avionics copies. Fenix/FBW MCDU needs a compatible FlightPadFMC client. Commercial addons, model libraries and services are separate. AI may be wrong; simulator use only.

## Languages and help

32 locales, initially Windows-language autodetection with regional handling and English fallback. Change in Tools → Language or Settings → General. Raw FMC/METAR/OFP and cockpit legends stay unchanged. New AI prompts request the current application language; saved reports do not translate themselves.

F1 opens contextual CHM help. PL/EN/DE/ES manuals have 62 topics, a hierarchy, search and matching-language screenshots; other UI languages use English. Only CHM help ships. [Help sources and maintenance](help/README.en.md).

## Build and tests

Delphi 10.2 Win64, Python 3.11+, Windows SDK `rc.exe` and HTML Help Workshop. Initialize `git submodule update --init --recursive`. `VersionU` comes from `src/Common`; VCL dependencies are vendored or selected through paths. [Runtime dependencies](runtime/README.en.md).

- `powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1`: application, stub, resources and help. Delphi uses `-DelphiRoot`, `BDS`, registration or PATH; MSFS SDK uses `-SDKRoot`/`MSFS_SDK`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File test.ps1`: registered projects and native DUnitX regressions. Installer integration tests need the corresponding sibling repositories. Every DPR has a DPROJ/group entry.
- `tools/capture_help.ps1`, then `python tools/build_help.py --require-chm`: regenerate localized screenshots after UI changes and compile current help.
- `python tools/package_flightsim.py`: complete unencrypted portable ZIP, rebuilt help and content/CRC/version/EXE-manifest checks; no automatic publication.

The bundled `Tools/Formatter/Format_MSFS24-FDR.exe /nogui` runs before compilation. RC rebuilds ignored RES; test MAP/RSM outputs are cleaned. [Test results/limits](Testy.en.md), [release notes](docs/releases/0.1.1.en.md), [changelog](CHANGELOG.en.md).

## Credits and issues

Started from [MichaelHsu170/MSFS-Flight-Data-Recorder](https://github.com/MichaelHsu170/MSFS-Flight-Data-Recorder), originally Qt, then extensively rebuilt. Application: [AGPL-3.0](LICENSE); dependencies: [NOTICE](NOTICE.en.md). Maps: © OpenStreetMap contributors.

[Report issues](https://github.com/dj-mafiozo/MSFS2024-FDR/issues) with full version, addon/version, steps and logs. Check for personal data and never share API keys or account secrets.
