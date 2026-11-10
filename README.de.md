[Übersetzungshinweise](Translation.de.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

# MSFS24-FDR

Natives Aufnahme-/Analyseprogramm für **Microsoft Flight Simulator 2024**, Windows 10/11 Win64. Kein MSFS 2020, FSX oder Prepar3D. Vorbereitetes Release: **0.1.1**; vollständige EXE-Version in Fenstertitel und Info.

## Portable installieren

1. Vollständiges ZIP ohne Kennwort mit Unterordnern entpacken.
2. `MSFS2024-FDR.exe` starten; DLLs, Schriften, Grafiken und `help/*.chm` behalten.
3. Optional `Optional-Community/MSFS24-FDR-Bridge` nach [Anleitung](community/Bridge/README.en.md) in Community kopieren. Der Recorder selbst ist kein Community-Addon.

`MSFS24-FDR-Setup.exe` zeigt nur einen Entwicklungshinweis, installiert/deinstalliert/aktualisiert nicht. Beide Updateoptionen sind gesperrt. Manuell bei geschlossenem Programm aktualisieren und Benutzerdaten erhalten. Qt/WebView2 unnötig.

## Aufnahmen und Speicher

- Einstellungen, Protokolle, Cache und `flight_data.mfzi` unter `%LocalAppData%\MSFS24-FDR`.
- Je Flug eine SQLite-`.mfzr` in `Recordings\Flugzeug_ICAO\Abflug_ICAO\YYYY\MM\...`, benannt nach Aufnahmebeginn. Baum mit lokalisierten Monaten, neueste zuerst.
- Suche/Gruppen, Import von .mfzr, alter flight_data.db und ursprünglichem Qt-Format; Legacy-Export eines Flugs ohne FDR-Erweiterungen.
- Migration behält Quellen. Abgelegte Dateien werden erkannt; Wiederherstellung nach Absturz kann unvollständig sein. Fehlende Dateien löschen keine Indexmetadaten.
- `MSFS2024-FDR.exe ".\Recordings\flight.mfzr"`: Einzelvorschau ohne Bibliothek, Aufnahme oder SimConnect.

Gesamten Datenordner bei geschlossenem Programm sichern. Aktive SQLite-WAL/SHM nicht löschen; persönliche INI nicht durch Beispiel ersetzen.

## Funktionen

| Bereich | Umfang |
|---|---|
| Aufnahme | Manuell/automatisch nach Ready for flight, gespeichertes Millisekundenintervall, typ-/triebwerksabhängige Daten. |
| Replay | Gemeinsame Zeit, kontinuierliche Interpolation, Pause/Stop, ±30 s, Anfang/Ende, 0.125–16x; Schalter diskret. |
| Andocken | Abtrennbare Tabs/Frames, Haupt-/schwebende Hosts, gespeicherter Zustand und individuelle Geometrie, proportionale Panels. |
| Instrumente | Six-pack, Kolben/Turboprop/Jet, B38M PFD/EICAS, A320 PFD/ECAM; Antialiasing und Seitenverhältnis. |
| B38M | FD, rekonstruiertes FMA, vorhandene ILS/Baro/STD/IAS-Mach/Minima, Wind/VOR/ADF; optional AoA und Info CPT links/FO rechts. |
| A320 | Fenix/FBW PFD/E/WD, 13 SD-Seiten und Recorded, vorhandene FD/FMA/Warnungen/STS/Minima. |
| FMC/MCDU | Erfasste Bildschirme/Anzeigen, Format/Hintergrund, automatischer Gerätetyp und separates synchrones Fenster. |
| Karte/Plan | Spur, Magenta-Plan, Punkte/Beschränkungen, verfügbare SID/STAR/Anflüge/Holdings, Fehlanflug dunkelgrau; PNG/KML. |
| SimBrief | Monospace-OFP, gespeicherte Karten; keine Netzwerkeinreichung historischer Pläne. |
| ATC/GSX | FSHud und verfügbares natives ATC über Bridge, Zeitnachricht; GSX-Zustand/Fortschritt einschließlich Betanken. |
| Wetter | Simulator und aviationweather.gov getrennt, verfügbare METAR/TAF, Dekodierung/Vergleich. |
| Ghost | Visuelles KI-Flugzeug, installiertes AIG/FSLTL oder Fallback, unterstützte Animationen, ±10 s, 5–60 Hz. |
| KI | Codex CLI/Gemini/Ollama, Start-/Landungsfenster, Markdown in angeforderter Anwendungssprache. |

Verfügbarkeit hängt von tatsächlich erfassten Addon-Daten ab; fehlend ist nicht Null/OFF. iFly-FMA und Warnungen sind teilweise Rekonstruktionen. Fenix/FBW MCDU benötigt passenden FlightPadFMC-Client. Kommerzielle Addons, Modelle und Dienste separat. KI kann irren; ausschließlich Simulatorgebrauch.

## Sprache und Hilfe

32 Gebietsschemas, zuerst Windows-Erkennung mit Regionalvarianten und englischem Fallback. Werkzeuge → Sprache/Einstellungen → Allgemein. Rohes FMC/METAR/OFP und Cockpitkennungen bleiben gleich; neue KI-Berichte werden in der aktuellen Sprache angefordert. Gespeicherte Berichte übersetzen sich nicht selbst.

F1: CHM PL/EN/DE/ES mit 62 Themen, Baum, Suche und passenden Sprachscreenshots. Andere UI-Sprachen verwenden Englisch. Nur CHM wird verteilt. [Hilfe pflegen](help/README.de.md).

## Bauen und testen

Delphi 10.2 Win64, Python 3.11+, Windows SDK rc.exe, HTML Help Workshop. `git submodule update --init --recursive`; VersionU aus src/Common, VCL-Abhängigkeiten unter vendor/angegebenen Pfaden. [Runtime](runtime/README.de.md).

- `powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1`: Anwendung, Stub, RC und Hilfe. Delphi via -DelphiRoot/BDS/Registry/PATH, SDK via -SDKRoot/MSFS_SDK.
- `powershell -NoProfile -ExecutionPolicy Bypass -File test.ps1`: registrierte DUnitX-Tests; Installerintegration braucht entsprechende Nachbar-Repositories. Jeder DPR hat DPROJ/Gruppeneintrag.
- `tools/capture_help.ps1`, dann `python tools/build_help.py --require-chm`: Sprachbilder erneuern und aktuelle Hilfe erstellen.
- `python tools/package_flightsim.py`: vollständiges unverschlüsseltes ZIP, Hilfe neu bauen, CRC/Version/Manifest prüfen, keine automatische Veröffentlichung.

Vor Kompilierung läuft Tools/Formatter/Format_MSFS24-FDR.exe /nogui. RES aus RC, Test-MAP/RSM werden entfernt. [Tests](Testy.de.md), [Release](docs/releases/0.1.1.en.md), [Changelog](CHANGELOG.en.md).

## Herkunft und Meldungen

Aus [MichaelHsu170/MSFS-Flight-Data-Recorder](https://github.com/MichaelHsu170/MSFS-Flight-Data-Recorder), ursprünglich Qt, umfassend neu aufgebaut. Anwendung [AGPL-3.0](LICENSE), Komponenten [NOTICE](NOTICE.en.md), Karten © OpenStreetMap contributors.

[Probleme melden](https://github.com/dj-mafiozo/MSFS2024-FDR/issues): vollständige Version, Addon, Schritte und Logs; persönliche Daten/Schlüssel vorher prüfen.
