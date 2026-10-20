# Tests — MSFS2024-FDR

[Polski](Testy.md) | [English](Testy.en.md) | [Deutsch](Testy.de.md) | [Español](Testy.es.md)

Nach der letzten Korrektur bestanden VerifyDetachedViews, VerifyChartsConfigure, VerifyLocalization und VerifyUI erneut. Zusätzlich geprüft: umgekehrte Schließreihenfolge, Bereichsbeschriftung beim Sprachwechsel, getrennte Mausradereignisse ohne Zugriff des Hauptfensters und alle 43 Icons durch unabhängige PNG-Vergleiche.


## Aktueller Prüfstand: getrennte Ansichten und Aktionen

35 Delphi-Testprogramme bestanden. Dazu bestehen vier Metadatenkontrollen: check_project.py, check_translations.py, check_airliner_catalog.py und check_documentation.py. Die Dokumentationsprüfung wurde nach Erstellen der Sprachdateien zusätzlich ausgeführt. Debug und Release Win64 werden über DPROJ/MSBuild geprüft; Buildskript und Paketprüfung gehören zur Auslieferungskontrolle. Ältere Testberichte nennen noch 33/34 Programme, den früheren JSON-Generator oder deaktivierte DE/ES: das beschreibt historische Versionen.

Die Tests verwenden isolierte Datenbanken und lokale HTTP-/SimConnect-/IPC-Attrappen, keine private Flugdatenbank. PORT_TEST verhindert eine produktive Simulatoraufzeichnung. Ein Test mit echtem Windows-Shared-Memory-Transport ist weiterhin ein synthetischer Herausgeber, kein Flugzeug-Livetest. Auch ein gültiger Modell-HTTP-Vertrag bestätigt keine Qualität der KI-Bewertung.

## Reproduzieren

```powershell
python tools/check_project.py
python tools/check_translations.py
python tools/check_airliner_catalog.py
python tools/check_documentation.py
powershell -ExecutionPolicy Bypass -File test.ps1
```

Delphi 10.2 ist erforderlich. Der vollständige Lauf kompiliert neu; Win32-MockFlightPad32 spricht mit dem Win64-Rekorder. i18n und WebView4Delphi werden aus Nachbarprojekt oder vendor aufgelöst. Test-DCUs liegen getrennt unter .build/Win32/Tests und .build/Win64/Tests. Beispiele für eine Teilmenge:

```powershell
& ./test.ps1 -Tests @('VerifyDetachedViews','VerifyChartsConfigure','VerifyLocalization','VerifyUI')
```

## Abdeckung je Programm

| Programm | Überprüft |
|---|---|
| VerifyPort | SQLite-Schema, Felder/Flags/Motoren, Ereignisse, Kontakte, KML und Gruppen. |
| VerifyLegacy | Transaktionale Migration alter Snapshots, Backup, Motorwerte und einmalige Zeitkorrektur. |
| VerifyUI | DFM, echte Aktionen/dialoge, über acht Diagramme, Reihenfolge/Abbruch, Timeline, schreibgeschützte Grids und Layoutspeicherung. |
| VerifyDiagnostics | Dauerhaftes Fehlerlog und lesbarer Windows-Minidump-Header. |
| VerifyFlightPlan | EPMO/EPLL-PLN, DMS, GET_EFB_ROUTE-JSON, lokaler Bridge-Verkehr, Revisionen und Deduplizierung. |
| VerifyAnalysis | Polnischer Auftrag, Providerwahl und Analysevertrag ohne Produktionsmodell. |
| VerifyContext | Zeitfenster, Vor-/Nachlauf, Chronologie, Deltas, AP/AT/Fahrwerk/Wetter und keine zukünftigen Werte. |
| VerifyReport | Markdown/HTML-Escaping, tatsächliches Schließen, Start-/Landungstitel, Liveübersetzung und OFP-Titel. |
| VerifyMetar | Ereigniszeit, Stations-/UTC-Prüfung, Antworten/Fehler und Speicherung auf lokalen Fixtures. |
| VerifyChartView | Viewport mit Zeitursprung, Cursor, Ziehen/Pan, umgekehrte Bereichsauswahl, Strg+Mausrad und Reset. |
| VerifyAircraftSDK | iFly Shared Memory, 2411 Felder, Erkennung, Einheiten/Vorrang, Deltas und Wiederverbindung. |
| VerifyFenix | 1203 L-Vars in SimConnect-Attrappe, 128er-Pakete, ungültige/null/veraltete Werte und Providerisolierung. |
| VerifyFBW | 223 L-Vars, Bereitschaft, Klappen, A/THR, IAS/Mach/Striche und VAPP. |
| VerifyPMDG | Client-Data-IDs/Layout, primitive Dekodierung, Sentinels, Gear OFF, MCP und spaltenorientierte CDU. |
| VerifyFMC | 14×24-Text, Unicode/Glyphen/CRLF, exakte DB-Zeichen, Seitennummer/MOD, Vorbereitung und Zeitgrenzen. |
| VerifyFlightPad | Echtes Win32-/Win64-IPC mit MockFlightPad32, Profile/PID, Heartbeat, UTF-16 und Ausfälle. |
| VerifyAirbusMCDU | Fenix/FBW INIT/PERF-Parser: VAPP/VLS, FLEX, THS, Höhen, Wetter und Minima ohne Einheitenraten. |
| VerifyOllama | Lokaler HTTP-Chat, UTF-8-Auftrag, Kontext, Markdown, unvollständige Antworten, Timeout und Abbruch. |
| VerifyOllamaModels | GET tags, Sortierung/Duplikate, leere/fehlerhafte Liste, URL-Wechsel und asynchrones Schließen. |
| VerifyTripInfo | Ausgewähltes Flugzeug, Zähler, offene/beendete Dauer, METAR/FMC, Refresh und nur Lesen. |
| VerifyPrecision | Drei Dezimalstellen, ±0,0015 Totband gegen letzten ausgegebenen Zustand, Null und Rundungsrauschen. |
| VerifyAirliner | 31 getrennte L-Var-Anforderungen, Fehlerisolierung, Null-Sentinels, Verlauf, Diagramme und Analyse. |
| VerifyGroundWeather | Letzte Start-Bodenprobe/erste Landungs-Bodenprobe, Bounce-Ausschluss, ganzer Flug und kein stiller Ersatz. |
| VerifySimBrief | Offline-Abgleich von Flug/Route/Datum, optionale ältere Pläne mit Nachweis, OFP-Speicherung und Ablehnungen. |
| VerifySimBriefUI | 15 VCL-Gruppen, EPLL–EGLL-Preview, Einklappen, Gesamtscroll, Memo-Höhe, schmales Layout und separates Fenster. |
| VerifyGSX | 16 lesende Variablen, Null/Fehler/Frische, Zustandsdeltas, Wiedergabelücken und Definitionen. |
| VerifySession | Geladener Flug bis Ende, Motoren aus, Pause/Stop/Menu/Flugzeugwechsel und keine Doppelstarts. |
| VerifyFSHud | Synthetischer Panel-Handshake, Frames/Filter, neun Typen, Zeit/Deduplizierung und Analysegrenzen. |
| VerifyRecorderWorker | Worker-eigene DB/Leser, Befehlswarteschlange, Statuskopien und Beenden ohne VCL-Blockierung durch Aufnahme. |
| VerifySimBacklog | 1000 Pakete werden fünf Callbacks; neuester Zeitpunkt und drei Bodenübergänge bleiben erhalten. |
| VerifyBoeingFMC | Ausgewählte V1/VR/V2/VREF, FLAP/SPD, ACT/SEL, Derate/Bump, N1, CG/Trim und PERF INIT. |
| VerifyIFlyDisplays | Zusammengesetzte Ziffernanzeigen, Leer-/Vorzeichen-/IRS-Zustände, FMC-Farben/Fonts/HTML und CDU-Lampen. |
| VerifyLocalization | PL/EN/DE/ES, echte Menüaktionen, Formulare/Frames, Einstellungen speichern/abbrechen, Threads und Zahlenformat. |
| VerifyChartsConfigure | Eigene ActionList/ImageList, Auswahlkopie, Filtern/Reihenfolge/Ausblenden, OK/Abbrechen und Alpha-Icons. |
| VerifyDetachedViews | Dieselben Karten-/Diagrammframes, gleichzeitiges Auslagern, Rückkehr per Aktion/Schließen, Bereich/Cursor/Flug, Mausrad, Sprache und Hauptfensterende. |


## Details der aktuellen Oberflächenprüfung

VerifyDetachedViews öffnet zwei künstliche Flüge mit unterschiedlicher Zeitachse, lagert beide Ansichten aus und vergleicht Objektidentitäten sowie den Zoom. Ein Diagrammklick bewegt die Hauptzeitleiste; deren Änderung aktualisiert den synchronen Zustand. Mausrad/Pan/Zoom und Flugwechsel werden bei ausgelagertem Frame ausgeführt. Das echte Konfigurationssymbol öffnet den modalen Chartdialog; ein Testtimer bestätigt dessen eigene Icons und schließt über aCancel. Sprachwechsel aktualisiert separate Fenstertitel. Unterschiedliche Schließreihenfolgen, Wiederholungen und Hauptfensterzerstörung mit zwei offenen Zusatzfenstern sind abgedeckt. Das Layout erhält Kartenhöhe und Splitter; neue Ersatzinstanzen sind nicht zulässig.

VerifyChartsConfigure prüft eigene drei Icons/fünf Aktionen, Aktivierung an Listenrändern, Suche ohne Häkchenverlust, unsichtbare Parameterpräferenzen, Reihenfolge, Ausblenden, Kopie bis OK und Abbruch ohne Übernahme. PNG-Vergleich verwendet unabhängige VCL-Zeichnung auf RGB(123,151,179), Toleranz 3 pro Farbkanal; dunkle BMP-Flaggenstreifen bleiben deckend. Die Bilder werden nicht durch Entfernen aller schwarzen Pixel repariert. Alpha-Ressourcen bleiben im DFM reproduzierbar.

Projektprüfung verlangt jede Unit in DPR/DPROJ, passende Form-/Frame-Ressourcen und .build-Ausgabepfade. Katalogprüfung kontrolliert vier Sprachen, Formatargumente, Unicode, doppelte Einträge und existierende DFM-Komponenten. Dokumentationsprüfung verlangt für jedes eigene README und Testy die vier Sprachdateien mit gültiger Navigation. Fremdquellen, SDK-Dokumente, Lizenztexte und generierte Buildordner werden nicht umgeschrieben.

## Artefakte und Grenzen

Testlog: tests/verification.log; erzeugte Vorschaubilder werden lokal geprüft und nicht als Produktionsdaten behandelt. Paketierung enthält Quellen, DFM, externen Sprachkatalog, Abhängigkeits-/Lizenzhinweise und sichere Beispielkonfiguration ohne private DB, Zugangsdaten oder lokale IDE-Zustände. Win64-Importprüfung bestätigt keine Qt-Abhängigkeit. WebView2 wird nur für HTML-Berichte dynamisch geladen.

Historische Livebeobachtungen: FSHud 2.1.200 lieferte neun Meldungstypen und die EPLL-Teststrecke; das war kein kompletter Flug/Ausfalltest. Ein iFly-Bildschirmprobe fand SDK state=0, also keine bestätigte Bildschirmübertragung. PMDG wurde nicht live geprüft, weil der Benutzer iFly flog; sein Flugzeug wurde nicht gewechselt. GSX und Fenix/FBW-Laufzeitwerte benötigen gesonderte Liveprüfung. Früher bereitgestellte EPMO/EPLL-PLN-Dateien wurden geparst, aber PLN wird vom EFB nicht automatisch gespeichert. Die Tests beenden keinen aktiven Benutzerflug.

Keine neue Live-Flugsitzung und kein produktiver KI-Auftrag wurde für diese Änderung ausgeführt. Ungeprüft bleiben echte Flugzeugversionsunterschiede, komplette Session-Ende-Grenzen, komplexe Pisten/Seitenwind, Vorhandensein einzelner L-Vars und Modellqualität. Empfangene Nullen können fehlende Variablen darstellen. Fehlendes/stales wird deshalb ausdrücklich als null oder unbestätigt geführt.

## VerifyGroups — 2026-10-18

`VerifyGroups` prüft Gruppenfilter, leeren Eintrag und fehlende Auswahl ohne Filter, Filtererhalt beim Aktualisieren, aktuelle Zuweisung im bsDialog, OK/Abbrechen, Zuweisung und Aufhebung sowie leere Gruppen. Verwendet werden synthetische SQLite-Daten und echte VCL-Formulare ohne Simulator. Das Formular ist in DPR/DPROJ eingetragen (60 Units) und in vier Sprachen übersetzt. Die gesamte Suite umfasst nun 36 Delphi-Programme und vier Metadatenprüfungen.

## Toolbar frames — 2026-10-18

Toolbar-Aktionen und ImageLists gehören jetzt fraMap/fraGraph und stehen in deren DFM-Dateien. Das Hauptmenü nutzt dieselben Aktionen; main behält Verweise und Fensterumschaltung. Das Diagramm-Frame führt Zoom aus. In ausgelagerten Fenstern bringen btnGraphWindow und btnMapWindow dasselbe Frame zurück zu frmMain. Bildindizes bleiben mit dem Hauptmenü kompatibel. TFrame-DFM-Eigenschaften und ungültige uses-Einträge der Diagrammkonfiguration wurden ebenfalls korrigiert.

VerifyDetachedViews prüft zusätzlich ActionList/ImageList-Eigentümer, gemeinsame Menü-/Frame-Aktionen, lokalen Zoom und echte Klicks auf beide Rückkehrschaltflächen. VerifyUI, VerifyLocalization, VerifyChartsConfigure, VerifyGroups und vier Metadatenprüfungen wurden wiederholt. Synthetische VCL/SQLite-Tests ohne Simulator. Lokale Frame-Referenzen umgehen einen Delphi-10.2-Win64-Codegenerierungsfehler bei wiederholten verschachtelten Property-Verweisen in Aufrufargumenten.

## MSBuild / Delphi 10.2 — 2026-10-19

Kompatibilitätskorrektur für die Delphi-10.2-IDE: AfterTargets bei DeployTranslations entfernt und das Ziel nach den Imports an BuildDependsOn und MakeDependsOn angehängt. Frühere MSBuild-4-Prüfungen deckten den älteren Projektparser der IDE nicht ab. check_project.py verbietet nun BeforeTargets/AfterTargets und prüft beide Abhängigkeitsketten. Win64 Build und Make sowie identische bin/translations-Kataloge geprüft. Kein manueller IDE-Test.

Das MSBuild-2.0-Schema akzeptierte das korrigierte Ziel und lehnte AfterTargets ab; der IDE-Fehler wurde reproduziert. frmSettingsU nutzt wieder `OllamaAnalysisU`. Win64 Build Debug, Make Debug und Build Release erfolgreich; Logs bestätigen DeployTranslations.

## Unit scope names — 2026-10-19

Delphi-10.2-Unit-Scopes: Winapi war bereits in Base enthalten; der gemeldete IDE-Build fand Windows in i18nLocalizer dennoch nicht. Vollständige explizite Scope-Listen stehen nun in beiden Windows-Plattformgruppen sowie Debug/Release Win32/Win64. Installierte i18n-Quellen bleiben unverändert. check_project.py prüft Winapi/System/Vcl/Xml/Data in diesen Gruppen. Win64 Build Debug/Release und Make Debug einschließlich dcc64 -NS geprüft. Kein manueller IDE-Build.

## TFrame DFM — 2026-10-19

DFMs von fraMap/fraGraph korrigiert: ClientHeight/ClientWidth durch Height/Width ersetzt; OldCreateOrder, PixelsPerInch und TextHeight entfernt. Beide Ansichten erben direkt von TFrame; Lokalisierung startet weiterhin nach dem ersten Parent und Translator verarbeitet Sprachwechsel. Aktuelle Benutzermaße, Layout und Namen (btnChartsConfigure) bleiben erhalten. Projektprüfungen erkennen Form-Eigenschaften in Frame-DFMs und fehlende TFrame-DPR-Anmerkungen; geerbte IDE-Namensräume bleiben erlaubt. Negativtest erkannte die alten fehlerhaften DFMs. VerifyDetachedViews, VerifyLocalization und VerifyUI mit synthetischen VCL/SQLite-Daten ohne MSFS wiederholt; Erstellen, Auslagern/Rückkehr und Sprachen geprüft. Debug/Release Win64 gebaut. Kein manueller IDE-Designer-Test.

Windows not found ebenfalls reproduziert: DCC-Einstellungen standen nach CodeGear.Delphi.Targets. Konfigurationsgruppen ohne Wertänderung vor den Import verschoben; BuildDependsOn/MakeDependsOn bleiben danach. Reihenfolgeprüfung in check_project.py ergänzt.

## Linear charts — 2026-10-19

Diagramme verbinden benachbarte Messpunkte jetzt durch gerade Linien. Waagerechte Stufen vor Änderungen und Verlängerung des letzten Wertes bis zum rechten Rand entfernt. Bestehende VerifyChartView- und VerifyUI-Prüfungen für Zoom, Verschieben, Bereichsauswahl, Cursor und VCL-Erstellung wiederholt. Synthetische Tests ohne MSFS; Win64 Debug/Release gebaut.

## About / menu / CHM — 2026-10-19

VerifyHelpAbout ergänzt: transparente Ecke eines 16px-Symbols auf farbigem Hintergrund, 34 stabile Indizes, sechs ausgeblendete Menüpunkte bei Action=nil und Wiederherstellung, modales About über aAboutExecute, Schließen und PL/EN/DE/ES-Sprachwechsel, Karten-/Diagrammkontexte und vier CHMs. WM_HELP öffnete die echte HTML-Hilfe, die der Test wieder schloss. Synthetische VCL-Screenshots erstellt und angesehen. Vier CHMs mit je sechs Themen kompiliert; HHC benötigt Windows-kodierte Inhaltsverzeichnisse und eine isolierte temporäre Umgebung. VerifyDetachedViews, VerifyLocalization, VerifyChartsConfigure, VerifyUI und vier Metadatenprüfungen wiederholt. Standardsuite jetzt 37 Delphi-Programme; für diese Änderung fünf ausgeführt, ohne MSFS. Debug/Release Win64 und Pakete geprüft.

## Parameter names — 2026-10-19

VerifyParameterNames ergänzt: 212 SimConnect-Namen, Einheiten einschließlich 0–1, Triebwerks- und nullbasierte Arrayindizes, alle iFly/Fenix/FBW/PMDG/AIRLINER-Kataloge, vier Sprachen und Suche nach Namen/Rohkennung. Zwei IDs mit gleicher Beschriftung prüfen Reihenfolge, Ausblenden, Auswahl und Erhalt fremder Flugzeugpräferenzen. Datenbank-/Modellkennungen bleiben nach Anzeige unverändert. VerifyChartsConfigure, VerifyChartView, VerifyLocalization, VerifyUI, VerifyHelpAbout und VerifyAircraftSDK wiederholt; Namen/UI nach AIRLINER/GSX/FSHud ergänzt erneut geprüft. Acht Delphi-Programme plus vier Metadatenprüfungen, synthetisch/Mock ohne MSFS. Standardsuite jetzt 38 Programme; nicht die gesamte Suite neu ausgeführt. README-Bilder aktualisiert. Debug/Release Win64 und Pakete geprüft.

Aktuelles zweigeteiltes Layout und während der Arbeit gespeicherte Maße übernommen. An den Anfang/Ans Ende/Diagramm anzeigen verbunden und Rohkennungen in VerifyParameterNames geprüft. Doppelten leeren aMoveFirstExecute-Handler entfernt. Sechs gewählte Pfeilsymbole mit neuem Alphakanal erhalten; Pixeltests prüfen nun 46 Symbole. Tools/Tests unterstützen Icons/16x16 und Icons/22x22. Nach IDE-Abgleich vier UI-/Namenstests wiederholt. Alte Formularkopie unter src/Forms/__history/parameter-names-20261019-141233 erhalten. DPROJ-Konfigurationen stehen vor Quellen und Imports.

VerifyChartsConfigure: benutzerdefiniertes Teilungsverhältnis beim Vergrößern/Verkleinern erhalten; kompatibles Bitmapformat für Delphi 10.2 TSpeedButton. Synthetischer VCL-Test ohne MSFS.


### Anzeigeeinheiten

Synthetische Tests: VerifyDisplayUnits prüft Entfernung, Steigrate, Geschwindigkeit, Masse, US-Volumen, Temperaturversatz, Druck, NaN/Infinity, inkompatible Einheiten, unbekannte SDK-Werte, Einstellungen, Übersetzungen und Pufferung mit 64 Diagrammen. VerifyParameterNames, VerifyChartView, VerifyUI, VerifyChartsConfigure und VerifyHelpAbout ebenfalls bestanden (35 große/kleine Symbole, Transparenz des neuen Symbols). Kein Live-MSFS-Test und keine Messung mit einer Benutzeraufnahme. Pufferung bleibt über 16 Diagrammen aktiv; derselbe Cursor-Messpunkt löst keine vollständige Aktualisierung aus.
