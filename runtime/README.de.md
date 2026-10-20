# Build- und Laufzeitabhängigkeiten

[Übersetzungen der Oberfläche](../Translation.de.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Win64 mit Delphi 10.2 VCL/FireDAC bauen. Neben `MSFS2024-FDR.exe` gehören Win64 SimConnect.dll aus dem MSFS2024 SDK/Runtime, sqlite3.dll, WebView2Loader.dll aus WebView4Delphi bin64 und MSFS2024-FDR.i18n. Für Markdown-Berichte ist Microsoft Edge WebView2 Runtime erforderlich. Dieser Rekorder verwendet SQLite, unabhängig vom früheren iFly/Firebird-Rekorder.

WebView4Delphi-Quellen: vendor/WebView4Delphi-main oder benachbartes FSHudPanel/vendor. i18n: ../i18n/Packages, explizites -I18nRoot oder vendor/i18n/Packages; DPROJ verwendet dieselbe I18nRoot-Auswahl. Die Bibliothek ist statisch eingebunden, keine BPL erforderlich. MIT-Lizenz in support/i18n/LICENSE erhalten. Übersetzungstexte stehen jedoch extern in MSFS2024-FDR.i18n; Skript und MSBuild kopieren sie aus translations/ neben das EXE.

Laufzeit-DLLs, EXEs, private Datenbanken, Einstellungen und Logs sind in Git ausgeschlossen. build.ps1 kopiert DLLs aus SDK/lokalen Quellen. bin/settings.example.ini ist die sichere Vorlage; bei Updates keine private settings.ini ersetzen. Compilerdateien liegen in .build/<Platform>/<Config>, Test-DCUs getrennt nach Architektur. tools/package.py erzeugt Quell-/Programmpakete mit Lizenzhinweisen und sicheren Vorgaben ohne Aufzeichnungen oder Zugangsdaten.
