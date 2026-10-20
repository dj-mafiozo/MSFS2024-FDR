# MSFS2024-FDR — Delphi 10.2 VCL Win64

[Übersetzungen der Oberfläche](Translation.de.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Nativer Flugrekorder und Viewer für Microsoft Flight Simulator 2024. Das derzeit private Projekt entstand ursprünglich aus MSFS-Flight-Data-Recorder (Qt); Architektur, Aufzeichnung, Datenbank, Oberfläche, Flugzeuganbindungen und Analyse wurden seitdem umfangreich neu aufgebaut. Quellenherkunft bleibt in NOTICE dokumentiert, AGPL-3.0 in LICENSE erhalten. Qt wird nicht verwendet.

## Oberfläche und getrennte Ansichten

Das neue Layout von frmMain bleibt erhalten. `aMapWindow` und `aGraphWindow` öffnen Karte bzw. Diagramme unabhängig in skalierbaren Fenstern. Der gesamte Inhalt von MapPanel und GraphPanel liegt in fraMapU/fraGraphU. Dieselben Frame-/Kontrollinstanzen wechseln den Parent; es entstehen keine zweiten Flugkopien. Im Hauptfenster verschwindet die ausgelagerte Ansicht. Schließen oder erneutes Betätigen derselben Aktion bringt sie zurück. Auch beide Ansichten können gleichzeitig getrennt sein. Flugauswahl, Zeitleiste, Cursor, Diagrammbereich und Aktionen bleiben verbunden. Beim Beenden des Hauptfensters werden die Zusatzfenster sicher geschlossen.

Diagramme konfigurieren: suchen, ohne Häkchen zu verlieren, mehr als acht Parameter wählen, Reihenfolge ändern oder ausblenden. frmChartsConfigure besitzt eigene ImageList/ActionList für Hoch/Runter/Ausblenden/OK/Abbrechen. Erst OK übernimmt die Arbeitskopie; Abbrechen verändert die Auswahl nicht. Präferenzen momentan nicht verfügbarer Flugzeugparameter bleiben erhalten.

Ziehen verschiebt die Zeit; Umschalt+Ziehen vergrößert die Auswahl; Strg+Mausrad zoomt; Doppelklick zeigt alles. Mausrad und Zoom funktionieren auch getrennt. Zeitleiste, Diagrammcursor, Kartenmarker und schreibgeschützter Inspektor sind synchron. Doppelklick öffnet eine Aufzeichnung. Splitter ändern Panelgrößen; Einstellungen stellt die Standardanordnung wieder her. Die angedockte Kartenhöhe bleibt beim Auslagern erhalten.

Die Karte unterstützt Verschieben/Mausrad, optionale OSM-Kacheln mit Quellenangabe/Cache, Route, Kontaktmarkierungen, PNG und KML mit Höhenumrechnung ft→m. Alle-Routen-Ansicht färbt Gruppen. Gruppen lassen sich anlegen, zuweisen, umbenennen oder ohne Fluglöschung entfernen. Große Datenbank-/Flugabfragen laufen weiterhin im UI-Thread und können vorübergehend blockieren.

## Start und Sprache

`bin/MSFS2024-FDR.exe` mit Win64 SimConnect.dll, sqlite3.dll, WebView2Loader.dll und MSFS2024-FDR.i18n im selben Verzeichnis starten. WebView2 Runtime rendert Markdown; Karte/Diagramme sind VCL/GDI. [Abhängigkeiten](runtime/README.de.md).

Polnisch ist Standard; Werkzeuge → Sprache oder Einstellungen → Allgemein bietet PL/EN/DE/ES. settings.ini speichert pl-PL/en-US/de-DE/es-ES; unbekannt fällt auf Polnisch zurück. Der externe [i18n-Katalog](translations/README.de.md) wird beim Bauen kopiert. Raw FMC/METAR/OFP, Benutzerdaten und technische Identifikatoren werden nicht übersetzt. KI-Aufträge und Berichte bleiben ausdrücklich Polnisch. Einstellungen haben Allgemein, Analyse und KI-Anbieter mit Codex/Gemini/Ollama-Unterseiten. bin/settings.example.ini ist eine Vorlage, keine private Konfiguration für Git.

## Aufzeichnung und Datenbank

Automatisch ab geladenem Flug und erster gültiger Telemetrie, auch bei ausgeschalteten Motoren, bis Flugende/Menü/Flugzeugwechsel/Trennung. Pause beendet den Flug nicht und erzeugt keine Proben; manueller Stopp deaktiviert die Automatik. Intervall in ms, Standard 500; 250 ist ein Ziel, keine garantierte Frequenz.

Ein Worker besitzt Aufzeichnung, Zusatzleser und eigene FireDAC-Verbindung. UI-Kommandos sind eingereiht; Status ist eine Kopie. SQLite nutzt WAL und getrennte Lese-/Schreibverbindungen. Wechsel/Beenden wartet auf den Worker. Keine aktiven WAL/SHM-Dateien löschen oder nur die laufende DB kopieren. Primärtelemetrie enthält vollständige Snapshots; optionale SDK-Ströme speichern Basis und Änderungen, gleiche Bildschirme/FSHud-Meldungen keine Duplikate.

Der Empfangsrückstand wird vor teurer Verarbeitung geleert, letzter Zustand und Boden/Luft-Übergänge bleiben erhalten. Surface 255 stoppt keine Aufzeichnung in der Luft. Zusatzfehler sind isoliert, Hauptdefinitions-/Anforderungsfehler werden protokolliert und abgebrochen. Flow-Ereignisse sind optional; FlightLoaded und Zehnsekunden-Prüfung dienen als Ersatz. Dessen komplettes Live-Flugende ist noch zu prüfen.

Der SimConnect-Katalog hat 709 Definitionen: 110 Zahlen, 70 gepackte Flags, 32 Werte je Motor bis 16 Motoren sowie Metadaten/Zeit. 84 Cockpitereignisse werden beobachtet, keine Steuerbefehle gesendet. Bestehende Qt-Datenbanken bleiben lesbar; fehlende Spalten werden ergänzt. Legacy-Snapshots werden transaktional mit Erhalt von Motor-/Bit-/Arraydaten repariert. Zeitzonenmigration läuft versioniert einmal. Vor Reparatur erzeugt die SQLite-Backup-API eine konsistente .before-native-<GUID>.db. Nicht zwei Rekorder auf derselben DB betreiben. msfs_fdr_debug.log/.old protokolliert FATAL/WARNING/INFO/TRACE/PROFILE.

## Flugzeuge und Zusatzquellen

Erkennung über Flugzeugtitel; bestätigte SDK-Werte haben Vorrang, sonst bleibt SimConnect. Fehlendes/veraltetes bleibt null. Eine Null-L-Var kann unbekannt sein; Herkunft und Gültigkeit bleiben sichtbar.

| Quelle | Umfang |
|---|---|
| iFly 737 MAX | Offizielles SDK 1.5 Shared Memory, 2411 Felder, zusammengesetzte Ziffernanzeigen und getrennte FMC-Texte/Stile/Lampen |
| [Fenix](support/fenix/README.de.md) | 1203 L-Vars, eigener lesender SimConnect |
| [FBW A32NX](support/fbw/README.de.md) | 223 L-Vars mit Bereitschaftsprüfung |
| [PMDG NG3](support/pmdg/README.de.md) | Offizielles Client Data SDK und beide CDU |
| [AIRLINER](support/airliner/README.de.md) | 31 gemeinsame Instrument-L-Vars |
| [GSX](support/gsx/README.de.md) | 16 Service-/Zähler-L-Vars |
| [FSHud](support/fshud/README.de.md) | Gefiltertes lokales Panelprotokoll, localhost:19786 |

[FMC-Verlauf](support/fmc/README.de.md) speichert Rohtext und konservative Performancewerte mit Zeiten. TAKEOFF REF liest ausgewählte V1/VR/V2 statt QRH; APPROACH REF ausgewähltes FLAP/SPD statt beliebiger Tabellenzeile. PERF INIT/N1 LIMIT liefern Gewichte, Kraftstoff, CI, Höhen, CG, Trimmung, angenommene/OAT-Temperaturen, N1, ACT/SEL, Derate und Bump. iFly/PMDG teilen vorläufig den Boeing-Parser, ein PMDG-Livevergleich fehlt. Fenix/FBW benötigen laufendes aktualisiertes [FlightPadFMC](support/flightpad/README.de.md); INIT/PERF ergänzt VAPP/VLS, FLEX, THS und weitere Werte. VLS ist nicht VREF. Verborgene Seiten sind letzte Beobachtungen, keine ständige Speicherabfrage.

## Analyse, Wetter und Planung

Fluginformation zeigt Kennungen, Flughäfen/Pisten, Zeit/Dauer, Datenanzahl, Ereignis-METARs, SimBrief-Prüfnachweise und letzte FMC-Referenzen vor Kontakten. Start und Landung haben eigene Berichtstitel. Codex CLI nutzt codex login und natives codex.exe; Gemini benötigt API-Schlüssel. [Ollama](support/ollama/README.de.md) sucht Modelle über GET /api/tags und analysiert über POST /api/chat. Keine automatische Modellinstallation. Analyse läuft im Hintergrund, speichert Markdown in der DB und rendert mit WebView2. Umschalt+Klick erzeugt einen neuen statt des gespeicherten Berichts.

Zeitfenster getrennt: Start 60 s vorher/30 danach, Landung 180/30, konfigurierbar. Kontextzahlen höchstens drei Dezimalstellen, rekursive Deltas mit ±0,0015 Totband gegen den letzten ausgegebenen Zustand; Rohaufzeichnung bleibt unverändert. Kurze Klappenrasten können analoge Controllerartefakte sein. AP/AT, einzelne Fahrwerksbeine, Wetter, Triebwerke und Referenzen kommen nach Verfügbarkeit hinzu. Konstante A/T-Anfluggeschwindigkeit kann bei fehlendem VREF nur eine gekennzeichnete Ersatzreferenz sein.

Temperatur/Druck sind lokal am Flugzeug, kein Flughafen-METAR/QNH. Startreferenz: letzte Bodenprobe bis Abheben; Landung: erste Bodenprobe ab Aufsetzen im ganzen Flug. Fehlendes bleibt ausdrücklich fehlend. Ereigniszeit-METAR ist getrennte Beobachtung. Pistenzuordnung nutzt Facilities, versetzte Schwellen, metrische Geometrie und rechtweisenden Kurs. Nicht zugeordnet bleibt leer; Abhebeort beweist nicht den exakten Rotationsbeginn. Komplexe Flughäfen/Seitenwind erfordern weitere Liveprüfung.

EFB-Plan über GET_EFB_ROUTE und Community-Brücke localhost:19787/efb-route; PLN ist Ersatzimport. Gleiche Routen werden dedupliziert, Änderungen je Flug erhalten. Keine erfundenen Prozedurkoordinaten. SimBrief-Benutzername/Pilot-ID ist konfigurierbar. Abrufen und Zuordnen sind getrennt; Flughäfen/Route und verfügbare Flugzeug-/Flugkennungen müssen passen. Ältere Pläne sind optional mit Nachweisen und Wiederverwendungshinweis zulässig. Aktueller Kontoplan wird nicht als Teststrecke angenommen. Rohantwort/OFP bleiben im Flug gespeichert.

SimBrief zeigt einklappbare VCL-Gruppen für Flug, Plan, Last, Route, Bemerkungen, ATC, LIDO-OFP, Piste, Karten und Flughäfen/Alternativen. Derselbe Frame kann in ein skalierbares Fenster wechseln. Mehrzeiliger Text wächst; das gesamte Panel scrollt. API-Pfadpräfixe und Flight-plan-downloads fehlen absichtlich. OFP bleibt in Originalsprache.

## Bauen und prüfen

Delphi 10.2, `src/MSFS2024-FDR.dproj`, Win64 oder build.ps1. i18n wird in ../i18n/Packages oder vendor/i18n/Packages gefunden; -I18nRoot/I18nRoot überschreibt dies. WebView4Delphi aus vendor oder Nachbarprojekt. Keine proprietären Hersteller-SDK-Binärdateien werden verteilt.

```powershell
python tools/check_translations.py
python tools/check_project.py
python tools/check_documentation.py
powershell -ExecutionPolicy Bypass -File test.ps1
python tools/check_dependencies.py
python tools/package.py
```

Units: NameU.pas; Formen frmNameU.pas/.dfm, Frames fraMapU/fraGraphU. Fachunterverzeichnisse in src; alle Units stehen ausdrücklich in DPR/DPROJ. DCU/OBJ/HPP/DCP/BPL liegen in .build/<Platform>/<Config>, Test-DCUs getrennt. Icons sind im DFM, auch im eigenständigen Chartdialog. [Testabdeckung und Grenzen](Testy.de.md): synthetische Tests beweisen keine Live-Flugzeugwerte oder Qualität eines KI-Modells. README/Testy gibt es auf Polnisch ohne Suffix und als .en/.de/.es.md.

## Aufnahmegruppen

Die Gruppenliste filtert Aufnahmen. Der leere Eintrag zeigt alle Aufnahmen einschließlich Flügen ohne Gruppe. Aktualisieren behält den Filter bei. Die Zuweisung öffnet einen eigenen Dialog mit der aktuellen Gruppe; OK speichert, Abbrechen verwirft Änderungen. „Ohne Gruppe“ entfernt die Zuweisung.

[MichaelHsu170/MSFS-Flight-Data-Recorder](https://github.com/MichaelHsu170/MSFS-Flight-Data-Recorder) — AGPL-3.0.

## Toolbar frames — 2026-10-18

Toolbar-Aktionen und ImageLists gehören jetzt fraMap/fraGraph und stehen in deren DFM-Dateien. Das Hauptmenü nutzt dieselben Aktionen; main behält Verweise und Fensterumschaltung. Das Diagramm-Frame führt Zoom aus. In ausgelagerten Fenstern bringen btnGraphWindow und btnMapWindow dasselbe Frame zurück zu frmMain. Bildindizes bleiben mit dem Hauptmenü kompatibel. TFrame-DFM-Eigenschaften und ungültige uses-Einträge der Diagrammkonfiguration wurden ebenfalls korrigiert.

## Bildschirmaufnahmen

Die Bilder zeigen die echte Anwendung mit synthetischen Testdaten, keinen real aufgezeichneten Flug.

![Hauptfenster: Karte, Diagramme und Inspektor](docs/screenshots/main.png)

![Diagramme im eigenen Fenster](docs/screenshots/charts-window.png)

![Über das Programm](docs/screenshots/about.png)

## CHM-Hilfe und F1

F1 oder Hilfe → Programmhilfe öffnet das Thema der aktiven Ansicht. Einstieg, Karte, Diagramme, Analyse, Einstellungen und Programminformationen sind enthalten. PL/EN/DE/ES folgen der Oberflächensprache.

Erstellen: `python tools/build_help.py --require-chm`. HTML Help Workshop erforderlich; HHC_EXE überschreibt den Pfad zu hhc.exe. build.ps1 erstellt ebenfalls die Hilfe. Ohne Compiler steht lokales HTML bereit; bei fehlender CHM öffnet F1 HTML. Ausgabe: bin/help. Das gesamte help-Verzeichnis neben der EXE verteilen.

Kleine Menüsymbole neu erstellen: `powershell -ExecutionPolicy Bypass -File tools/rebuild_toolbar_images.ps1 -List small`.

## Lesbare Parameternamen

Diagramme, Auswahl-/Reihenfolgelisten und Werteinspektor zeigen Beschreibungen mit Einheiten, etwa `Flughöhe [ft]` und `N1-Drehzahl — Triebwerk 2 [%]`. Die Sprache folgt der Oberfläche. Suche und Tooltips unterstützen lesbare Namen und Rohkennungen.

Datenbank, Flugmodell und Einstellungen behalten die Originalkennungen. Vollständige Beschriftungen decken 212 Standardparameter sowie AIRLINER, GSX und FSHud ab. Andere SDK/LVAR-Namen werden lesbar aufgeteilt; Quelle, Kürzel und Indizes bleiben erhalten. Unbekannte Felder bekommen keine geratenen Einheiten. Werte von 0–1 werden nicht als Prozentwerte beschriftet.


### Anzeigeeinheiten

Unter Einstellungen → Einheiten eine Zieleinheit je Quelleinheit wählen, z. B. ft → m, lb → kg, US gal → l. Die gleiche Einheit deaktiviert die Umrechnung. Diagramme (Kurven, Skalen, Cursor) und Parameteranzeige werden auch im separaten Fenster angepasst. Datenbank und Analysedaten bleiben im Original. Unbekannte SDK-Einheiten werden nicht geraten.


### Diagramme per Drag-and-drop

Unter Diagramme konfigurieren einen Parameter von links nach rechts an die gewünschte Position ziehen. Nach links ziehen blendet das Diagramm aus. Innerhalb der rechten Liste mit gedrückter Strg-Taste ziehen, um die Reihenfolge zu ändern. Eine Einfügelinie markiert das Ziel; beide Listen scrollen am Rand. Kontrollkästchen und Schaltflächen bleiben nutzbar. OK übernimmt die Arbeitskopie, Abbrechen verwirft Änderungen.


### Windows-Sprache, neun Sprachen und VersionInfo

Die erste Sprachwahl ist auto. Die Windows-Anzeigesprache wird unabhängig von Zahlen-/Datumsformaten erkannt. Regionale Varianten werden PL/EN/DE/ES/FR/RU/TR/IT/PT zugeordnet, sonst Englisch. Auto bleibt gespeichert; explizite bestehende Einstellungen bleiben erhalten. Menü und Einstellungen bieten zehn Optionen. Neue GUI-Beschriftungen sind übersetzt. Hilfe bleibt viersprachig, mit englischem Fallback für neue Sprachen. Neue Texte sind ein lokaler Qwen3-Erstentwurf mit Fachbegriffskorrekturen, ohne muttersprachliche Prüfung. VersionU liest EXE-Versionsdaten und Sprachblöcke; Info zeigt Dateiversion, ProductName und Copyright. Gemeinsamer Build: 2 (0.1.0.2); übrige Versionsnummern/Autorendaten unverändert. bump_build.py erhöht nur Build pro logischer Änderung; check_version.py prüft Vererbung. CLI nutzt MSBuild für aktuelle Versionsressourcen.


Erweiterung: Die Oberfläche unterstützt 25 Gebietsschemas. Neu: en-GB, fr-CA, pt-BR, de-AT, de-CH, be-BY, el-GR, uk-UA, hr-HR, cs-CZ, da-DK, nl-NL, fi-FI, nb-NO, sk-SK und sv-SE. Regionale Varianten werden getrennt gespeichert. be steht für Belarussisch; no/nb/nn verwenden die verfügbare Bokmål-Übersetzung, keine eigene Nynorsk-Version. Schweizer Deutsch verwendet ss statt ß. Die automatische Auswahl folgt der Windows-Anzeigesprache, ohne Zahlenformate zu ändern. Die Hilfe bleibt PL/EN/DE/ES, mit Basissprache oder Englisch als Ersatz. Neue Übersetzungen sind eine erste Fassung mit Terminologiekorrekturen und Strukturprüfung, ohne muttersprachliche Prüfung. Build: 0.1.0.3; andere Versions- und Autorendaten bleiben unverändert.


Die Oberfläche enthält 32 nach Code sortierte Gebietsschemas. Neu: ar-SA, he-IL, hi-IN, id-ID, ja-JP, vi-VN und zh-CN. ar/he wählen die jeweiligen Varianten; ältere Aliase iw/in werden he/id zugeordnet. Arabisch und Hebräisch verwenden RTL; Diagramme, Karten und FMC/METAR/OFP-Rohtexte bleiben LTR. Noto-Schriften aus assets/fonts werden mit OFL-Lizenzen und Herkunftsprüfsummen nach bin/fonts und in die Archive übernommen und nur privat geladen, ohne Systeminstallation. Hilfe und Dokumentation bleiben viersprachig. Hinweise zu Übersetzungsfehlern: Translation.de.md. Build 0.1.0.4.


StackTrace erfasst Aufrufstapel bei Ausnahmen. MSFS2024-FDR.pdb neben genau dem EXE aufbewahren, für das es erzeugt wurde; die Datei liegt im Archiv. Bei Fehlerberichten Programmversion und passenden Auszug aus msfs_fdr_debug.log beifügen. Quellcode-Builds benötigen map2pdb.exe im PATH; eine detaillierte MAP-Datei wird nach dem Kompilieren konvertiert.
