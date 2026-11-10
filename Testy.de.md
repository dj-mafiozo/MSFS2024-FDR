# Tests — MSFS2024-FDR

[Polski](Testy.md) | [English](Testy.en.md) | [Deutsch](Testy.de.md) | [Español](Testy.es.md)

## Simulator-Kompatibilität und Schalterwerte

VerifyFlapsHandle, VerifyParameterValues, VerifyUI und VerifyChartView — PASS: ICAO-Auswahl, sechs A320-SimConnect-Zustände statt fünf SDK-Hebelpositionen, 1+F, GA- und negative Stemme-Stellungen, MD-11-Varianten, abweichende Positionsanzahl und leerer Fallback. Fünf Python-Tests einschließlich Generatorprüfung bestanden. Synthetisch, keine Flüge mit allen Mustern; 60 Codes bleiben unbestätigt.

DisplayValue-Audit — PASS: vier Python-Tests für Parser, Herkunft und Generatoren sowie VerifyParameterValues, VerifyAircraftSDK, VerifyFenix, VerifyFBW, VerifyAddonLVars, VerifyPMDG und VerifyPMDG777. Geprüft wurden Trennzeichen, Ziffernbereiche, Enum-Lücken, XML-Beschriftungen, RTP-Zeichen und Zahlen-Fallback. 335 XML-Dateien geprüft; aus 14 fehlerhaften Dateien wurden nur eigenständig gültige UseTemplate-Fragmente verwendet. Statische Analyse und Attrappen, kein Live-Flug.

VerifyUI und VerifyGSX — PASS: DFM-Fortschrittsanzeigen ab Requested, aktive/abgeschlossene Zustände, Rückwärtssuche, fehlende Daten, Passagier-/Gepäckfortschritt und Tankwagenzähler mit Rücksetzung. Synthetische Tests und SDK-Attrappe; kein Live-GSX-Test.

VerifySimulatorVersion, VerifySubscriptions, VerifyRecorderWorker, VerifySession, VerifySimBacklog, VerifyFlightPlan und VerifyRecordingWorker: PASS mit Attrappen/synthetischen Daten. MSFS24 wird erst nach OPEN akzeptiert; MSFS20/FSX/P3D sowie unbekannte oder verkürzte Antworten erhalten keine Abonnements. VerifyParameterValues, VerifyParameterNames und VerifyGSX: PASS für Schalterbeschriftungen, Flugzeug-spezifische Klappenrasten, unbekannte Werte, NaN und übersetzte GSX-Zustände/Fortschritte. Gepäckfortschritt wird als Prozentwert angezeigt. Kein neuer Live-Test mit Simulator oder GSX.

## A320 PFD und ECAM — Fenix / FBW

VerifyAirbusDisplays — PASS: 13 Seiten/PNG, tatsächlicher Index statt Selektor, Zuordnung 11/12, Vor-/Rücklauf, manuelle Auswahl, ARINC-SSM/Null/ungültige Daten, aktiver CPC, FBW-N1-Priorität, SQLite-Deltas, Clear, Auslagern/Symbole, RTL/LTR/Resize. VerifyInstrumentFrames: PASS Fenix/FBW ↔ B38M, zwei ausgelagerte Slots, Geometrie und drei synchronisierte Anzeigen. VerifyFBW nach neuem MockFenixSim, VerifySixPack und VerifyViewState: PASS. PFD/EWD/HYD-PNG geprüft; kein Liveflug, kein Vergleich mit laufendem Fenix/FBW und kein IDE-Designer-Test.

Recorded/Aufzeichnung folgt dem aufgezeichneten tatsächlichen FBW-Displayindex, nicht dem Selektor; 11=CRUISE, 12=STS. Manuelle Auswahl bleibt beim Spulen erhalten. 47 zusätzliche FBW-Felder; ARINC429 nur bei gültigem Normalbetrieb-SSM, sonst `--`. Erste datenbasierte Darstellung, keine vollständige DMC/FWC-Emulation: keine erfundenen FMA-/FD-Kommandos, Warn-/STS-Texte, Ventilzustände oder Systemfunktion. Das vorhandene Fenix-XML bestätigt keine automatische Displayseite; Recorded bleibt dann unbekannt, manuelle Seiten funktionieren. Ölmenge in Prozent, keine angenommene Quart-Kapazität. ECAM: kg, kg/h, psi, C; PFD-Einheiten nach Einstellung.

[ECAM](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/ecam/), [E/WD](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/ecam/ecam-e-wd/), [SD](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/ecam/sd/), [PFD](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/pfd/), [FBW SD source](https://github.com/flybywiresim/aircraft/tree/master/fbw-a32nx/src/systems/instruments/src/SD).

## Qt-Datenbanken importieren

`VerifyLegacyExport` — PASS: Qt-Import/Bibliothek und Wiedergabe von 3 Messpunkten/6 Triebwerkszeilen, N1-Präzision, fehlende Erweiterungen als NaN und +02:00 erhalten. Mehrflug-Qt-Fixture in zwei `.mfzr` mit je 3 Messpunkten ohne Vermischung getrennt; erneuter Import ohne Duplikate, Quell-SHA-256 unverändert. VerifyInstrumentFrames prüft DFM-Dialog/Menü; VerifyRecordingImport ältere Import-/Vorschauregressionen. Synthetische SQLite/VCL-Prüfung, kein Liveflug.

## Flug für die ursprüngliche Qt-Anwendung exportieren

`VerifyLegacyExport` — PASS: zwei Quellflüge, nur der gewählte mit 3 Messpunkten, 6 verknüpften Triebwerkszeilen, Kontakten/Ereignis/Gruppe exportiert. Unicode und N1-Präzision erhalten; sieben Tabellen, 130/35 Telemetriespalten, keine Erweiterungen/Berichte. SHA-256 der schreibgeschützten Quelle unverändert; Quellüberschreiben, fehlender Flug und NOT-NULL-Fehler während Kopieren erhalten alte Zieldatei und entfernen temporäre Ausgabe. Python sqlite3 vergleicht Spalten mit Qt-Header. VerifyInstrumentFrames prüft DFM-Menü/Dialog. Kein manueller Qt-GUI-Test; Schema/SQLite geprüft.

## Stabile Anordnung von Instrumenten und Zeitachse

Das Reglerpanel bleibt direkt in CenterPanel; Karte, Diagramme, Instrumente und Splitter liegen in einem eigenen ViewsPanel in DFM. Der Instrumentensplitter kann das Reglerpanel nicht mehr als Größenänderungsziel wählen. Beim Zurückholen wird die Reihenfolge der Instrumente und Trenner wiederhergestellt.

VerifyInstrumentFrames: PASS — getrennte Container, keine Überlappung, Splitter direkt über Instrumenten nach Fensterhöhen 650/750/850 und PFD/EICAS-Auslagern/Rückkehr. VerifyDetachedViews und VerifyViewState prüfen Auslagern, Synchronisierung und gespeicherte Konfiguration. Synthetische VCL/SQLite/INI-Prüfung, kein Liveflug oder manueller IDE-Designer-Test.

## Skalierung von Triebwerks- und EICAS-Panels

ScrollBox aus beiden Frames und geerbte Einträge aus frmMain DFM entfernt. Anzeigen füllen den Bereich unter der Werkzeugleiste. EICAS behält das Seitenverhältnis; allgemeine Anzeigen zeichnen ein vollständiges gepuffertes Layout, wählen die Spalten nach Panelgröße und skalieren alles. Messwerte verändern die Kontrollgröße nicht. Splitter: alLeft, Breite 6, MinSize 100, AutoSnap=False, rsUpdate; Breite nach Verschieben gespeichert.

`VerifyInstrumentFrames`, `VerifyEngineGauges`, `VerifyB38MEICAS`, `VerifyViewState` — PASS. Zusätzliche Prüfungen: keine ScrollBox, alClient und verbleibende Höhe, Panel–Splitter–Panel, kein AutoSnap und synchrones Auslagern/Rückkehr. Synthetische VCL/SQLite/INI-Tests, kein Liveflug oder manueller IDE-Designer-Test.

## ICAO-Auswahl der Frames und gemeinsame PFD-Skalen

- `VerifyInstrumentFrames` — PASS: nur ICAO B38M wählt `ikB38MPFD`; MAX-8-Titel allein reicht nicht. B736–B739 bleiben allgemein. Zwei DFM-Frames ersetzen Sixpack und Triebwerksanzeigen. Aufnahmewechsel B38M → B738 → B38M bei zwei ausgelagerten Fenstern behält Geometrie, Elternkomponenten, Zeitsynchronisierung und Symbole 0/1. Rückkehr per Taste/X, GA-Rückfall und IAS-Bandpixel bestanden.
- `VerifySixPack`, `VerifyPFD737`, `VerifyB38MEICAS`, `VerifyEngineGauges`, `VerifyDetachedViews`, `VerifyViewState` — PASS. ILS-Pixel an das neue Layout angepasst; Richtung, unabhängige Gültigkeit, GPS-Ausschluss und hohle Endanschläge geprüft. 1000 Cursorwechsel mit 3003 Labels ohne Indexsuche; ICAO-Wechsel erneuert Profilcache. Sechs Fensterplätze statt sieben, kein eigenes `view.pfd737`.
- Testprojektgenerator repariert: `DelphiCompile` darf nicht fehlen, sonst kann MSBuild Erfolg ohne EXE melden. Neuer Test und Regressionen danach kompiliert/ausgeführt; Registrierung in Tests.groupproj und DPR/DPROJ ergänzt.
- Win64 Debug/Release und Setup kompiliert; Projekt-, Versions-, Dokumentations- und Übersetzungsprüfung bestanden. Synthetische VCL/SQLite/INI- und Renderprüfung, kein Liveflug oder IDE-Designer-Test. Ältere Abschnitte dokumentieren frühere Schritte; aktuelle Frame-Auswahl gilt wie hier beschrieben.

## B38M EICAS und zusätzliche Parameter

- `VerifyB38MEICAS` — PASS: automatische Auswahl nach MAX-8-Titel oder gespeichertem B38M-ICAO unabhängig von Livery, generische Anzeigen für andere Flugzeuge; getrennte N1/N2/EGT/FF/Öl/Vibration, rohe psf gegenüber 53 psi, Klappenrastungen/Zeiger, Kraftstoffmasse nur mit Dichte und NaN statt erfundener Null.
- Gleicher Test — PASS: SDK-Kraftstofffilterlampe und separates ENG FAIL anhand Pixeln, Entfernen alter Meldungen, kein Triebwerksalarm durch APU-Lampe oder nur Null-Öldruck. Starter heißt STARTER ACTIVE, nicht START VALVE OPEN. `tests/b38m-eicas-preview.png` visuell geprüft. Größenänderungen, RTL/LTR, Zeitachse vor/zurück, Abdocken/Andocken und Symbole 0/1 bestanden.
- SQLite — PASS: Ölmenge 0,813, TAT 24,37 und Mitteltank 1250,75 präzise gespeichert/gelesen. Älteres Schema mit erhaltenen Zeilen erzeugt: Vorschau und KI-Kontext liefern NaN/NULL, N1 bleibt 84,7. SHA-256 vor/nach Vorschau identisch; schreibende Migration erhält fehlende historische Werte als NULL.
- `VerifySubscriptions` — PASS: Ölmenge nur vorhandener Triebwerke, TAT/Mitteltank bei aktivem Flug, im Menü nur drei Identitätsfelder; Ereignisreihenfolge, Abmeldung und alte Pakete auf DLL-Attrappe bestanden. Auch `VerifyPort`, `VerifyRecordingImport`, `VerifyDetachedViews`, `VerifyViewState`, `VerifyPFD737`, `VerifyEngineGauges`, `VerifyContext` bestanden.
- Neue Felder am Katalogende ohne Änderung alter Indizes, REAL und Bezeichnungen in 32 Sprachen; Unit/Test in DPR/DPROJ/Tests.groupproj. Kein echter Flug oder vollständiger Warnlogikvergleich. SDK 1.5 liefert hier keine bestätigten START-VALVE-OPEN-, THRUST-/FUEL-FLOW-Flags. Öl-Kapazitätsverhältnis und Einheiten gemäß [offiziellem SDK](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-engine-variables/), keine Liter oder Triebwerksgrenzen.

## PFD-Skalierung und separates PFD 737

- `VerifySixPack` — PASS: 900×200-Panel mit höhenfüllendem Horizont und V/S-Zeiger sowie −677-ft/min-Anzeige. Höhenmessermechanik, fester VSI-Bereich, Cache, ILS, fehlende Daten, Einheiten und Andocken weiterhin korrekt. Keine sampleabhängige Skalenänderung. `tests/pfd-wide-preview.png` visuell geprüft.
- `VerifyPFD737` — PASS: nativer DFM-Frame und Renderer; IAS/ALT-Rohwerte und Pitch-Vorzeichen, LOC-/GS-Rautenpixel, feste nichtlineare VSI-Skala (1000 → 0,5; 2000 → 0,75; 6000 → 1), Vorzeichen/Begrenzung, NaN, normale/breite/schmale/kleine Größen, vorwärts/rückwärts, dieselbe ausgelagerte Instanz, Symbole 0/1 und LTR bei Hebräisch. `tests/pfd737-preview.png` visuell geprüft.
- `VerifyDetachedViews` — PASS: PFD 737 im Haupt-DFM, Zeitsynchronisierung auch ausgelagert, Rückkehr beim Schließen. `VerifyViewState` — PASS: sieben Ansichten einschließlich `view.pfd737`, unabhängige Geometrie und Wiederherstellung nach Neustart.
- Neuer Test in `tests/Tests.groupproj`, beide Units und Frame-Metadaten in DPR/DPROJ. Nur synthetisch; kein echter Flug, kein Vergleich mit laufender 737-Avionik, kein IDE-Designer-Test. Der FMA-Bereich zeigt vorhandene AP-/FD-/A/T-Flags, keine erfundenen Modi oder FD-Kommandobalken.

## Neues frmMain, Symbole und Datenanzeige

- Die Sichtprüfung von `native-preview.png` zeigte doppelte Motoranzeigen, die SixPack im niedrigen Panel verdeckten. frmMain nutzt nun EnginePanel separat und reserviert die Höhe für Instrumente; `VerifyDetachedViews` prüft dies. Auch `VerifyFMCReplay`, `VerifySimBriefUI`, `VerifySixPack` und `VerifyUI` nach den Toolbar-Änderungen bestanden.
- `VerifyDetachedViews` — PASS: neue Panel-Hosts, Abdocken/Andocken derselben Instanz, Ausblenden von Container/Splittern bei zwei ausgelagerten Instrumenten und Wiederherstellung beim Schließen. Symbole wechseln 0/1, auch beim Schließen über X. Beide Symbole aller sechs Frames auf weißem/schwarzem Hintergrund auf transparente Ecken geprüft.
- `VerifyRecordingTree` — PASS: vollständige/abgeschnittene ATCCOM-Schlüssel mit iFly-MAX-8-Titel ergeben B38M, A32NX ergibt A20N; gültige ICAO bleiben erhalten, unbekannte Schlüssel ergeben UNKNOWN, Windows-Gerätenamen werden abgewiesen. Filter, Sortierung, Sprache und fehlende Dateien weiterhin korrekt. Rohmetadaten und vorhandene Dateipfade bleiben unverändert.
- `VerifyEngineGauges` — PASS: 7632 rohe psf werden als 53 psi angezeigt, Modellwert bleibt 7632; NaN bleibt fehlend. Regressionen für Motortyp, Synchronisierung, Andocken und NULL bestanden.
- `VerifyRecorderWorker` — PASS: simuliertes E_FAIL beim Öffnen von SimConnect führt zum lokalisierten Wartezustand ohne Failed/Error; Wiederholungen sind begrenzt. SQLite-, Befehlsfehler- und VCL-Tests bestanden. Kein echter Simulator-/Verbindungsabbruchtest.
- `VerifyRecordingImport` — PASS: neue DFM-Hierarchie, Migration/Import und Vorschau ohne Worker/SimConnect. `VerifyViewState` prüft sechs Fenster und gespeicherte untere Panelgrößen. Nur isolierte Dateien/Attrappen; IDE-Designer nicht geöffnet.

## SixPack und ILS im vereinfachten PFD

- `VerifySixPack` — PASS: echtes VCL-Bitmap-Rendering. Pixeltests für LOC-/GS-Rauten auf beiden Seiten, feste Skalen bei Pitch/Bank, unabhängigen Signalausfall, GPS-Ausschluss, NaN, Begrenzung und hohle Endanschlagsymbole. Aufeinanderfolgende Bilder prüfen auch das Entfernen alter Anzeigen. `tests/pfd-ils-preview.png` wurde visuell geprüft.
- Weiterhin PASS: direkte TFrame-Basisklasse, fester VSI-Bereich, Indexcache, Höhenmessermechanik, Baro, metrische Anzeigen, Andocken, Synchronisierung und Migration fehlender Felder.
- `VerifyDetachedViews` — PASS: Haupt-DFM, vorhandenes SixPack und weitere Frames, Abdocken/Andocken und Synchronisierung. `check_project.py` prüft die direkte TFrame-Ableitung aller Inline-Klassen im DFM.
- Nur synthetische Tests; kein echter ILS-Flug und kein erneutes Öffnen im Delphi-Designer. Das SixPack-DFM blieb erhalten; nach Ignore gespeicherte Änderungen wurden nicht rekonstruiert.
- HSI CDI ±127, GSI ±119 und Signalflags gemäß [offiziellem MSFS-2024-SDK](https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/SimVars/Aircraft_SimVars/Aircraft_RadioNavigation_Variables.htm): Zeigerausschläge, keine Winkel in Grad.

## Recorder-Mutex und Frames für den Formulardesigner

- `VerifySetup`: echtes benanntes Windows-Objekt `MSFS24-FDR-Run_Once`; erster Zugriff erfolgreich, zweiter abgewiesen, nach Freigabe Neustart möglich. Erkennung durch den Installer geprüft.
- `VerifySetupUI`: echtes modales DFM-Formular `frmSetupRunning` mit `bsDialog`, `mrRetry` und `mrCancel`. Ein Test-Timer wiederholt dreimal; erst die Freigabe des Mutex erlaubt die Fortsetzung. Abbrechen beendet den Vorgang, der Recorder-Mutex bleibt aktiv. Regression des kleinen Updaters und des API-Ausfalls bestanden.
- `VerifyUI`: Laden des frmMain-DFM, Erstellen/Anzeigen, Karte, Diagramme und Synchronisierung nach direkter TFrame-Ableitung der Instrumenten-/Triebwerk-Frames bestanden. Erneutes Öffnen im Delphi-Designer wurde nicht durchgeführt und muss im IDE bestätigt werden.
- Kein echter Recorder beendet, keine Installation in Program Files und keine produktiven Registry-Änderungen. Der Prozess-Fallback für ältere EXE ohne Mutex wurde nicht separat mit einem laufenden Prozess geprüft.

## 0.1.1 — Setup-Struktur, i18n, Wartung und PEM

Geprüft mit Delphi 10.2 Win64 auf isolierten Dateien und echten DFM-Formularen, ohne produktive Installation oder Änderung persönlicher Daten.

- VerifySetupMaintenance prüft Auto und dieselben 32 Gebietsschemacodes, Windows-Erkennung, INI-Speicherung, übersetzte Assistenten-/Datendialoge, arabisches/hebräisches RTL und Rückkehr zu LTR. Der Modus SETUP_RESOURCE_TEST lief ohne externe Schrift- oder Katalogdateien und registrierte alle fünf eingebetteten Schriften aus dem Speicher.
- Wartung: Optionsfelder bei vorhandener Installation, Reparatur und Zurück, Versionsmetadaten bei fehlender EXE, Wiederherstellung fehlender/beschädigter Dateien bei unveränderten Zeitstempeln gesunder Dateien. Die Versionsauswahl aktualisiert nicht stillschweigend, wenn das gewünschte alte Paket fehlt.
- Alle vier Kombinationen zum Behalten von Einstellungen und Flügen wurden mit Recordings, Index, Protokollen und WAL einer losen Aufnahme ausschließlich in TestPathsU geprüft.
- tests/VerifyReleasePEM.dpr erzeugt einen flüchtigen RSA-3072-Schlüssel als AES-256-verschlüsseltes PKCS#8 außerhalb des Repositorys. Ein nativer Test-Packager sammelt echte Binärdateien, verschlüsselt das ZIP, signiert ZIP/Manifest über OpenSSL mit Testpasswort ausschließlich über stdin und prüft mit CNG. SHA-256 und EXE-Bytes stimmen; private Dateien bleiben ausgeschlossen und die Testdatei wird nie entpackt.
- Austausch der public.pem nach Kompilierung ändert die gültige Prüfung nicht: verwendet wird der eingebettete Schlüssel. Manipulierte Manifestsignaturen werden vor dem Entpacken abgelehnt. Eine falsche Passphrase bricht die Paketierung ab und entfernt unvollständige Paketdateien.
- Erfolgreich: VerifySetup, VerifySetupUI, VerifySetupSignature, VerifySetupMaintenance, VerifyGlobalLocales, VerifyLocaleExpansion, VerifyVersionLanguage, VerifyRTLReturn, VerifyReport, VerifyFMCReplay, VerifyUI, VerifyAppStorage, VerifyRecordingImport. Debug/Release, Setup 0.1.1.19 und das separate PackageRelease-IDE-Projekt wurden gebaut; Projekt-, Abhängigkeits-, Versions-, Übersetzungs- und Dokumentationsprüfungen bestanden.

Registry, Systemverknüpfungen und Installationsstarts verwenden Test-Doubles. Echte UAC, Zuordnungen, vollständige Installation/Reparatur/Entfernung, Authenticode und Simulatorflug wurden nicht geprüft. Produktionsschlüssel benötigen eine lokal gewählte Passphrase; kein Produktions-PEM oder Produktionspaket wurde erzeugt oder veröffentlicht. Signaturtests verwenden ein kurzlebiges Testpaar. Ältere Abschnitte beschreiben den bisherigen CNG-Schlüssel.

## 0.1.1 - Menu Start

Der Startmen?ordner DJ M@fi0z0™ enth?lt Programm- und Deinstallationsverkn?pfung (Setup.exe /uninstall). Beide folgen der Startmen?option. VerifySetup pr?fte Migration, Ziele und Argumente, deaktivierte Option und Erhalt fremder Produkte beim Entfernen. Verwendet wurden isolierte Test-Doubles, nicht das echte Startmen?.

## 0.1.1 ? OmniXML

exe.xml wird mit IXMLDocument/IXMLNode und dem nativen OmniXML-Backend bearbeitet, ohne OLE-Automatisierung oder MSXML. VerifySetup pr?ft XML vor CoInitialize: Einf?gen/Entfernen, Wiederholbarkeit, Erhalt fremder Eintr?ge und Kommentare, leeres Dokument, Unicode und Sonderzeichen in Pfaden, UTF-8 sowie Ablehnung von DTD und ung?ltigem XML. Installationstests verwenden isolierte Dateien und Test-Doubles; die produktive exe.xml blieb unver?ndert.

## 0.1.1 — Signierte Veröffentlichungen

Delphi 10.2 Win64 Debug/Release und das separate Setup-Projekt wurden kompiliert. VerifySetup pr?ft Versionsreihenfolge, GitHub-Pakete, ZIP-Verschl?sselung und Entschl?sselung, falsches Passwort, besch?digte Daten, unsichere Pfade und das Auslassen der Testdatei. Au?erdem werden MSXML-Zusammenf?hrung und DTD-Ablehnung, Installation, Aktualisierung und Deinstallation mit echten isolierten Dateien, R?cknahme fehlgeschlagener Kopiervorg?nge, Setup-Austausch, Changelog-DFM und Einstellungen gepr?ft. VerifySetupUI pr?ft Navigation, Optionen, die kompakte Fortschrittsanzeige und drei lokale HTTP-Szenarien bei weiterhin reagierender VCL-Oberfl?che.

VerifySetupSignature verwendet Windows CNG und einen fl?chtigen RSA-3072-Testschl?ssel. Gepr?ft werden g?ltige PSS-Signaturen mit SHA-256 und 32 Byte Salz sowie die Ablehnung ver?nderter Signaturen, Hashwerte, 20-Byte-Salze und fehlender Schl?ssel. Eine isoliert gespeicherte Versionsuntergrenze darf nicht sinken. Die Paketpr?fung signiert mit .NET RSACng und verifiziert mit Delphi/CNG vor der CRC- und Bytepr?fung. Python zipfile hat unabh?ngig eine Testdatei mit ?ffentlichem Testpasswort entschl?sselt. Regression: VerifyReport, VerifyFMCReplay, VerifyUI, VerifyRecordingImport, VerifyAppStorage und VerifyRTLReturn.

Registry-, Verkn?pfungs- und Prozessoperationen verwenden Test-Doubles. Es wurden keine echte Program-Files-Installation, UAC-Abfrage, ?nderung der produktiven exe.xml, Authenticode-Signierung, Ver?ffentlichung oder Simulatorflug durchgef?hrt. Die R?cknahme von Dateikopien garantiert keine vollst?ndige Transaktion von Registry, XML und Verkn?pfungen bei Stromausfall. Die Produktionssignatur verwendet den Herausgeberschl?ssel; der fl?chtige Testschl?ssel wird daf?r nicht verwendet.

Die abschlie?ende Pr?fung im Zielrepository war erfolgreich: Debug/Release Win64 und Setup 0.1.1.16, alle neun genannten Tests sowie Projekt-, Abh?ngigkeits-, Versions-, ?bersetzungs- und Dokumentationspr?fungen. Das signierte Paket enth?lt 80 verschl?sselte Eintr?ge. Ver?nderte ZIP-Daten, ZIP-Signatur, Manifest, Manifestsignatur sowie eine fehlende Manifestsignatur wurden vor Beginn des Entpackens abgelehnt. Sechs vom IDE erzeugte Compiler-Eigenschaftsgruppen stehen nun vor dem Delphi-Targets-Import; drei Frame-DFMs wurden bei unver?nderten Abmessungen von unzul?ssigen Formulareigenschaften bereinigt.

## 0.1.2.15 — Import, Vorschau und DFM-Ressourcen

Die Tests verwendeten synthetische SQLite-Daten und echte VCL-Formulare, ohne private Aufnahmen im Produktionsprogramm zu öffnen oder eine MSFS-Verbindung aufzubauen.

- `VerifyRecordingImport`: Erstimport, zusätzlicher Flug in einer bereits verarbeiteten Legacy-Datenbank, wiederholter Import ohne Duplikate und SHA-256-Prüfung der Quelle; Erkennung einer hinzugefügten `.mfzr`, wiederholter Scan und Isolation ungültiger Dateien. Bereits indizierte Dateien werden nicht erneut importiert.
- Ein Kindprozess erhält genau einen vorhandenen synthetischen `.mfzr`-Pfad. Geprüft werden Telemetrie, drei Instrumentenregister aus DFM, ausgeblendetes LeftPanel samt Splitter, gesperrte Aufnahme- und Verwaltungsaktionen, sichere direkte Handler-Aufrufe sowie das Fehlen des Standardindex und der Aufnahmesperre. SQLite lehnt einen Schreibversuch über eine schreibgeschützte Verbindung ab; der SHA-256-Wert bleibt unverändert. Beide Importsymbole zeigen transparente Ecken auf hellem Hintergrund.
- Bestandene Regressionen: `VerifyUI`, `VerifyDetachedViews`, `VerifyHelpAbout`, `VerifyGroups`, `VerifyPort`, `VerifyLegacy`, `VerifyRecorderWorker`, `VerifySession`, `VerifyViewState`, `VerifyFMCReplay`, `VerifyMetar`, `VerifyRecordingFiles`, `VerifyRecordingTree`, `VerifyRecordingUI`, `VerifyRecordingWorker`, `VerifyTripInfo`.

Kein Live-Flug und kein manueller Dateiauswahldialog wurden getestet. Reales SQLite und Kindprozesse wurden eingesetzt; nicht jede physische Dateibeschädigung ist abgedeckt. Der neue Test steht in Tests.groupproj und im standardmäßigen test.ps1.

Abschlussprüfung im Zielrepository: Debug und Release Win64 mit Delphi 10.2 erfolgreich, VersionInfo 0.1.2.15. VerifyRecordingImport, VerifyRecordingUI und VerifyViewState sowie Projekt-, Versions-, Dokumentations- und Katalogprüfungen (1044 Definitionen, 32 Sprachen) erneut bestanden. Der bereitgestellte Katalog entspricht der Quelle. Die Reihenfolge der MSBuild-Einstellungen und Übersetzungsbereitstellung wurde korrigiert; Hilfsdateien des separaten Installers gehören nicht zur Unit-Prüfung des Rekorders.

## 0.1.0.14 — Aufnahmeindex und einzelne Flugdateien

Mit synthetischen SQLite-/VCL-Daten in isolierten `TestPathsU`-Verzeichnissen ausgeführt:

- `VerifyRecordingFiles`: getrennte Dateien, reiner Metadatenindex, Statusübergänge, ICAO-/Zeitpfade, getrennte Proben/Ereignisse, erhaltene Metadaten bei fehlenden Dateien, Pfadschutz. Migration dreier Flüge prüft Gruppen, Namenskollisionen, FMC-Rohtext/Formatierung/Lampen, zusätzliche trip-Tabelle, Schemaversion, erneutes Öffnen ohne Upgrade, Idempotenz und bytegleiches Original.
- Hartes Beenden eines Kindprozesses mit `TerminateProcess`: bestätigtes WAL bleibt erhalten, Probe wird wiederhergestellt, Unterbrochen-Status bleibt; Unterbrechung zwischen Umbenennen und Index-Commit sowie beschädigte Datei/Metadaten werden geprüft.
- `VerifyRecordingTree`: Sortierung aller Ebenen und Geschwister, vollständige PL-/DE-Monatsnamen, neue Übersetzungskennungen, Zeitformat, Symbole, Statuspräfix, Auswahl, kombinierte Gruppen-/Textfilter, leere Filter und ausgeblendete fehlende Dateien.
- `VerifyRecordingUI`: echter Hauptdialog, migrierte Aufnahme, Auswahl/Doppelklick, Parameter/Instrumente, gesperrter aktiver Knoten, Suchreset und Ordnerauswahl. Automatische Wiederherstellungsdialoge prüfen Ablehnen ohne Datenverlust, erneute Nachfrage und Öffnen nach Zustimmung.
- `VerifyRecordingWorker`: echter Rekorderthread mit simuliertem SimConnect, SQLite-Schreibkonflikt im Einzelflug, VCL-Heartbeat und nicht blockierende Befehle, mehrere Proben, Pfad-/Statusabschluss und Beenden.

Neue Projekte sind in `tests/Tests.groupproj` und `test.ps1` registriert. Alte UI-Tests verwenden den Baum. `VerifyFMCReplay` verwendet isolierten Testspeicher statt globalem TEMP. Kein Produktionsstart gegen private Daten, kein Live-MSFS-Flug und keine universelle Wiederherstellung physisch beschädigter Datenbanken wurden getestet. Die frühere versionsbezogene Testhistorie folgt.

Abschlussprüfung: 15 Regressionstests bestanden (Oberfläche, ausgelagerte Ansichten, Hilfe, Gruppen, Datenbank/Migration, Thread/Sitzung, Fensterzustand, FMC, METAR und vier neue Aufnahmetests). Arabische/hebräische Monate werden mit gregorianischen Daten geprüft. Löschtests prüfen bestätigtes Einzelflug-Löschen und eine belegte Datei ohne Metadatenverlust und ohne veralteten Inspektor. Delphi 10.2 Debug/Release Win64 erfolgreich, VersionInfo 0.1.0.14. Projekt-, Versions-, Übersetzungs- und Dokumentationsprüfungen bestanden.


Die Liste verwendet `vstRecordings: TVirtualStringTree` im neuen Formularlayout, mit nativ deaktivierten Knoten und Erhalt von Auswahl, aufgeklappten Ordnern und Scrollposition. Zum Bauen werden Virtual-TreeView-V8-Quellen unter `..\Virtual-TreeView\Source` oder `vendor\Virtual-TreeView\Source` benötigt. Alternativ `-VirtualTreeRoot` bei `build.ps1`/`test.ps1` oder `/p:VirtualTreeRoot=...` bei MSBuild angeben. IDE und Testgruppe teilen dieselbe Einstellung. Das EXE benötigt dafür keine zusätzliche Laufzeitbibliothek.


Nach dem Wechsel zu TVirtualStringTree wurden alle 16 Tests einschließlich VerifyTripInfo wiederholt. Im Zielrepository bestanden zusätzlich VerifyRTLReturn und VerifyGlobalLocales: 32 Sprachen, Schriften und RTL/LTR. Insgesamt 18 Regressionstests. Die synthetische native-preview.png aus VerifyUI wurde auf Baumtext, Monatsnamen, Symbole und Auswahl geprüft. Abschließende Debug-/Release-Win64-Builds und fünf isolierte Speicher-/Fluginfotests im Zielrepository: PASS.


## 0.1.0.13 — Bereiche, Indizes und Höhenmesser (2026-10-21)

Bestehenden `VerifySixPack` aus `Tests.groupproj` erweitert. Synthetischer Replay mit VSI 100/-5600 ft/min, NaN, Infinity und kurzer Werteliste. Bereich ab erster Probe 6000 ft/min, unverändert beim Vor-/Zurückspulen; ohne VSI Mindestbereich 2000. IAS ebenfalls fest. ft/min→m/s erhält das Verhältnis Wert/Bereich. Keine Live-MSFS-Prüfung.

Zählende Listen-Unterklasse: 3003 Etiketten und 1000 folgende SetPoint-Aufrufe ohne weitere IndexOf-Suchen. Geprüft: Reihenfolgeänderung bei gleicher Anzahl, unbekannter Parametername, Wechsel der Aufnahme, Clear und Erhalt von OnChange-Clients trotz Revision. Prüft den TSixPackDisplay-Zugriff, keine Zeitmessung der gesamten Anwendung oder Triebwerksanzeige. Werteänderung ohne Schemaänderung erfordert Clear zur neuen Bereichsberechnung; Replay behandelt gebundene Proben als unveränderlich.

12500 ft ergeben 180°/90°/45° für die Zeiger, unverändert nach ft→m bei Zahlenwert 3810 m. Zusätzlich Pixel auf dem tatsächlich gerenderten langen Zeiger vor/nach Umrechnung geprüft. Weitere Abdeckung: -500 ft, NaN, ILS/Baro, Auslagern, kleine Größen, RTL und migrierte NULL-Werte. `tests/six-pack-metric-preview.bmp` betrachtet: FT-Legende, Meterwert und Fußmechanik.

Erfolgreich: VerifySixPack, VerifyDetachedViews, VerifyViewState, VerifyDisplayUnits, VerifyEngineGauges, VerifyPort, VerifyUI. Nicht alle 53 Verify wiederholt. TPlotLabels betrifft nur das Speichermodell; SQL/Rohdatenspeicherung unverändert. Build einmal auf 0.1.0.13 erhöht; Projekt-/Gruppenprüfung bleibt erforderlich.


Abschlusslauf im Ziel-Repository: alle sieben genannten Tests erneut PASS. Debug und Release Win64 mit VersionInfo 0.1.0.13 gebaut. Keine Benutzerkonfiguration/-datenbank geändert und keine Produktions-EXE gestartet.


## 0.1.0.12 — Speicherung der Ansichten (2026-10-21)

Neu: `VerifyViewState` in `tests/Tests.groupproj` und der Standardliste `test.ps1`. Nur synthetische VCL/INI/SQLite-Tests, kein Flug und keine privaten Einstellungen. Wiederholtes Erzeugen/Zerstören von frmMain prüft sechs Frames einschließlich SimBrief, getrennte Positionen/Größen, Erhalt des ausgelagerten Zustands beim Beenden, automatische Wiederherstellung, Rückkehr per Taste/X, unabhängige Nachbarfenster und Erhalt der Geometrie nach Einbetten. Ein zusätzlicher `future_hud`-Frame bestätigt Erweiterbarkeit ohne eigene Speicherroutinen.

Weitere Prüfungen: normale Maße bei Maximierung, keine Icon-Maße/minimierter Start, einmalige Wiederherstellung, Reset mit Einbetten/Löschen der Abschnitte, ungültige/doppelte IDs, emulierte DPI-Umrechnung und Korrektur von Offscreen-/MaxInt-Koordinaten sowie ungültiger Größe/PPI. Keine physische Monitortrennung oder Änderung der Windows-DPI; simulierte INI-Werte.

Erfolgreiche Regression: VerifyViewState, VerifyDetachedViews, VerifyUI, VerifySimBriefUI, VerifyRTLReturn, VerifySixPack, VerifyEngineGauges. Nicht alle 53 Verify erneut ausgeführt; der frühere Eintrag über 52 Tests beschreibt die Vorversion. Projekt-/Gruppen-, i18n-, Versions-, Font- und Dokumentationsprüfungen bestehen. Erneut vom IDE gespeicherte TForm-Eigenschaften im Six-Pack-DFM entfernt, manuelle Maße/Darstellung erhalten. Build einmal auf 0.1.0.12 erhöht.


Abschlussprüfung im Ziel-Repository: alle sieben genannten Tests erneut PASS; Debug und Release Win64 mit VersionInfo 0.1.0.12 erfolgreich gebaut. Neuer Test auch über seinen `Tests.groupproj`-Target in der Arbeitskopie gebaut und die erzeugte EXE ausgeführt. Keine Produktions-EXE gestartet und keine privaten Daten migriert.


## 0.1.0.11 — getrennte Testdatenbanken und Instrumente (2026-10-21)

Alle **52 Verify-Programme** der vollständigen `test.ps1`-Suite endeten mit Code 0/PASS. Es handelt sich um synthetische SQLite/VCL-Tests und SimConnect/IPC/HTTP/CLI-Mocks, nicht um einen MSFS-Flug. Bestehende Tests für Recorder, Flugzeuge, FMC, FSHud, GSX, Analyse, SimBrief, Diagramme, Einheiten, Sprachen/RTL, Migration und Version bleiben erhalten.

- `TestPathsU` erzeugt pro Verify-Prozess `.build/test-data/<Name>/<PID>-<tick>`, leitet Datenbanken/PORT_TEST-Einstellungen um und kopiert Testabhängigkeiten/Fixtures. Migrationstests verwenden weiterhin eigene temporäre Verzeichnisse. VerifyPort, VerifyLegacy und VCL-Tests bestehen mit diesen Pfaden; private bin/LocalAppData-Datenbanken werden nicht geöffnet.
- `VerifySixPack` prüft LOC/GS-Normalisierung ±127/±119, gültige Signale, Ausschluss des GPS-CDI, GS-Ausfall bei weiter gültigem LOC, fehlende Flags/NaN, eingestellte 1026 hPa, Fallback von 29.92 inHg und STD. Bestehende Tests für Pitch, Heading, Turn/Ball, Einheiten, Größe, Auslagerung und Schema-Migration bleiben bestehen. Die Zeigerrichtung benötigt noch einen Vergleich im Simulator.
- Neu: `VerifyEngineGauges` prüft vier Layoutklassen, Kolben/Turboprop/Jet, 0/1/2/4/16 Triebwerke und ungültige Anzahl, getrennte N1-Werte, RPM/CHT/ITT/Condition, Filterung ungeeigneter Gruppen, echten Null-Kraftstoffstand gegenüber fehlenden Werten, Ampere, Auslagern/Rückkehr desselben Frames, Zeitsynchronisation, RTL/LTR und kleine Größen. Datenbanktests prüfen Flugzeugtitel, genaue ITT und NULL→NaN. Bitmap `tests/engine-gauges-preview.bmp` wurde betrachtet.
- `VerifyDetachedViews` prüft zusätzlich den Triebwerks-Frame im Hauptfenster, Rückkehr-Taste, Close und Zeitbeschriftung. `VerifySubscriptions` prüft weiterhin Typ/Anzahl und Abmeldung nach Sitzungsende.
- FireDAC benötigt vor Clear/NULL einen Parametertyp. Der zunächst gefundene Fehler „Parameter V32 data type is unknown“ ist behoben; fehlende Werte werden nicht als Null erfunden.

123 neue SimConnect-Felder behalten alte Offsets: 11 gemeinsame und 7 Familien ×16 Triebwerke; neue Spalten sind nullable. Alte Aufzeichnungen erhalten keine nachträglich erfundenen Daten. Katalog: 834 Felder/7080 Bytes, 123 numerische Spalten, 39 Triebwerksfamilien. Strukturprüfungen: 88 DPR/DPROJ-Units, 1034 i18n-Einträge ×32 Locale, Fonts/Lizenzen, Dokumentation, Add-on/AIRLINER und Version 0.1.0.11. Keine muttersprachliche Terminologieprüfung; neue Parametertexte besitzen auch einen englischen technischen Fallback.

Allgemeine Skalen ohne flugzeugspezifische Grenzwerte; Glass/PFD ist eine vereinfachte gemeinsame Darstellung ohne vollständiges FMA/FD/PFD/ND. Eigene Flugzeugtitel können zusätzliche Klassifikationsregeln benötigen. Referenzen: [Triebwerks-SimVars](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-engine-variables/), [Navigation](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-radio-navigation-variables/).


Abschlussprüfung: alle 63 Projekte aus `tests/Tests.groupproj` mit Delphi 10.2 MSBuild gebaut (Debug/Win64, IPC-Publisher Win32). Gruppenstandard ohne Platform-Argument sowie die erzeugten VerifyEngineGauges/VerifySixPack-EXE geprüft. VCL-Ressourcenpfade und IDE-Plattformflags korrigiert. Nach Zusammenführung der manuellen Formatierung erneut PASS: VerifyEngineGauges, VerifySixPack, VerifyDetachedViews, VerifyPort, VerifyLegacy und VerifyDisplayUnits. Zusätzliche Prüfungen: NULL→Wert→NULL mit vorbereitetem Statement, Baro 1026.35 und neue Übersetzungen. Gleiche Skalen für verglichene Triebwerke; Baro als REAL ohne Abschneiden der Nachkommastellen.


Die Abschlussprüfung im Ziel-Repository fand außerdem leerzeichenabhängige Name-Einträge, CRLF-abhängige OFL-Hashes und TForm-Eigenschaften ClientHeight/ClientWidth/OldCreateOrder/PixelsPerInch/TextHeight im Six-Pack-DFM. Prüfungen tolerieren Formatierung/Zeilenenden, behalten aber Inhalts-/Fontvalidierung. Der gültige TFrame bewahrt manuelle Maße und Darstellung; ZIP-Lizenzen tolerieren nur LF/CRLF. Sieben Tests einschließlich VerifyAddonLVars wurden im Repository wiederholt. Debug/Release Win64 0.1.0.11 neu gebaut; Produktions-EXE nicht gestartet und keine privaten Daten migriert.


## 0.1.0.10 — Flugsubskriptionen und natives Six-pack (21.10.2026)

Vollständiges `test.ps1`: **51 Programme PASS**, Delphi 10.2 Win64, isolierte Daten. Projekt (85 Units), 1014 Definitionen in 32 Sprachen, Schriftarten, Version und Dokumentation PASS. Produktionsprogramm und private Datenmigration wurden nicht ausgeführt.

- `VerifySubscriptions`/Mock-DLL: drei Identifikationsfelder im Leerlauf; AircraftLoaded/SimStart ohne FlightLoaded, Ereignisreihenfolgen; Jet/Kolben/Turboprop und Motoranzahl; Neustart desselben Modells; Titelwechsel im Datenpaket; Abmeldung, Definitionsbereinigung, Verwerfen alter Pakete; zwischengespeicherter AircraftLoaded-Zustand aktiviert nicht das Menü. SimStart prüft den aktuellen Flugzustand.
- `VerifyAddonLVars`: acht Profile/5050 Felder; nur passender TFDi-Provider; Schließen bei inaktivem Flug; begrenzte ONCE-Warteschlange, Fehlerisolierung, NULL, Änderungsspeicherung und Diagramme. Nach Zusammenführen der Formatierung zusätzlicher Transporttest für `A:LIGHT NAV` und bool-Einheit.
- `VerifySixPack`: natives VCL-Rendering; Zeitprobe, Pitch-Vorzeichen, 361° → 1°, angezeigte Höhe, gemessene Drehrate/Kugel; gleicher Frame beim Abdocken/Schließen; RTL, Einheiten, fehlende Daten, Größenänderung; Migration eines Schemas ohne zwei Spalten; NULL bleibt NaN. Screenshot geprüft, `docs/screenshots/six-pack.png` zeigt synthetische Daten.
- Erweiterter `VerifyDetachedViews`: Hauptfensterintegration, Rückkehr per Taste/Close und Zeitsynchronisierung. Assertions in separater Prozedur nach Delphi-10.2-Codegeneratorfehlern im vergrößerten Testprogramm, gleicher Prüfumfang.
- Lokaler Audit: **120 Pakete, 2046 locpak-Dateien**, Quellen und Hashes, keine verschlüsselten Archive. Übersetzte Code-Namen ausgeschlossen. Bell 407: 72 Bindings, EC135: 234. **18 Varianten/39 XML**: bisherige fünf Familien 3298 L-vars, TFDi MD-11 GE/PW/Passagier/Fracht zusätzlich 1446. Vereinigungsmenge pro Familie beweist keine Verfügbarkeit aller Felder je Variante.

Semantik anhand der offiziellen [SDK-Vorlagen](https://docs.flightsimulator.com/msfs2024/html/5_Content_Configuration/Models/ModelBehaviors/TemplateExplorer/Asobo_EX1/Common/Interior/Templates/ParametersFn/Instrument_ParametersFn.html) geprüft. **Keine Live-Simulatorprüfung**. TFDi verwendet explizite Modell-L-vars statt eines nicht vorhandenen binären SDK-Headers. Null beweist keine verfügbare L-var. Six-pack emuliert keine Instrumentenausfälle oder Dynamik.

Abschließende **Debug-/Release-Win64-Kompilierung PASS**, FileVersion **0.1.0.10**, übereinstimmender Übersetzungskatalog und PDB-Symbole. Parallele manuelle Formatierung in vier Dateien erhalten. VerifyAddonLVars (einschließlich Standard-Binding/Einheit), VerifyDetachedViews und VerifySixPack nach Zusammenführung erneut PASS. Installierte Flugzeugdateien und private Aufnahmen/Einstellungen unverändert.

## 0.1.0.9 — A320-Export und Flugzeugintegrationen

Vollständiges `test.ps1`: **49 Programme PASS**, Delphi 10.2 mit isolierten Daten. Die neuen Tests prüfen 522 SDK-Felder, drei CDU, 3298 L-vars aus fünf Familien, Fehlerisolierung, begrenzte Abfragen und Speicherung nur bei Änderungen. Echter Win32 → Win64 IPC prüft RGB, kleine Schrift, Kontrolllampen, reine Formatänderungen und nicht verfügbare Anzeigen; Replay prüft automatische Flugzeugerkennung und CDU-Tabs.

Unabhängige clang-cl-Prüfung aller offsetof/sizeof-Werte gegen den originalen PMDG-777-Header: PASS. FlightPad `ExportTests` und `ExportAppearanceTests` Win32: PASS; vier Fenix/FBW MCDU/Screen-Programme kompiliert. Projektprüfung (73 Units), Version, Übersetzungen und Kataloge: PASS. Kein Live-Test im Simulator; DLL-Tests verwenden Mocks. Null beweist nicht die Existenz einer L-var. Flugzeugdateien und private Daten blieben unverändert.

Debug und Release Win64 im Zielrepository: PASS, FileVersion 0.1.0.9; Übersetzungskatalog und PDB-Symbole: PASS. Abschließende Projektprüfung: 73 Units PASS. Im aktuellen SimBrief-DFM wurden ClientHeight/ClientWidth durch Height/Width ersetzt und drei nur für TForm gültige Eigenschaften entfernt; das aktuelle Layout blieb erhalten. Die Produktions-EXE wurde nicht gestartet.

## 0.1.0.8 — native Ansichten, AppData und FMC/MCDU (21.10.2026)

**Vollständiges `test.ps1`: 46 Delphi-Programme — PASS**, isolierte Arbeitskopie, Delphi 10.2 Win64. Prüfungen für 32 Sprachen/1011 Katalogeinträge, 68 DPR/DPROJ-Units, Schriften, Version und Dokumentation: PASS. Ältere Abschnitte dokumentieren frühere Versionen.

Debug-/Release-Win64-Builds der installierten Quellen: PASS, FileVersion 0.1.0.8, passender Katalog/PDB. PE-Importprüfung und fehlende WebView2-Loader-Referenz: PASS. ZIP unter `dist/native-storage-fmc-0.1.0.8/`: 72 Dateien, CRC/Rücklesen, x64 und Laden beider DLLs nach Entpacken (SQLite 3.45.3), drei FMC-Bilder/vier CHMs; ohne WebView2, Community oder private Einstellungen/Datenbank. Das Produktions-EXE wurde nicht gestartet; private Daten wurden beim Prüfen nicht migriert.

`VerifyAppStorage`: echte SQLite-WAL-Daten (Datensatz 12345), eingefrorene DB/WAL/SHM-Dateien, Einstellungen/Logs, aktiver Schreibzugriff als Sperre, kein Teilziel, Konflikte ohne Überschreiben, Wiederholung, Wiederaufnahme aus `migration.pending`, schreibgeschützte Quelle mit beschreibbarer Benutzerkopie. Nur Testordner; keine privaten Daten und kein echtes Program Files wurden migriert. Produktion nutzt LocalAppData; `PORT_TEST` isoliert Testdaten neben dem Test-EXE.

`VerifyFMCReplay`: zwei Geräte, letzter Bildschirm bis Cursorzeit, UTC-Offsets/Wochentag-Suffix, ID-Reihenfolge bei gleicher Zeit, Aus-/Nicht-verfügbar-Zustände, Geräteisolation, Leeren und derselbe Frame beim Ab-/Andocken. Physisches CDU bleibt bei Hebräisch/Polnisch LTR. Der native Screenshot `tests/fmc-replay-preview.bmp` wurde visuell geprüft: B737-Hintergrund, Farben, kleine Schrift, EXEC/MSG. `VerifyDetachedViews` prüft zusätzlich Main-Zeitleiste, Aufzeichnungswechsel im separaten Fenster, Rückkehrknopf/Close und Beenden.

Berichts-/SimBrief-Tests prüfen schreibgeschütztes, rahmenloses Consolas-TMemo ohne eigene Scrollleisten, Leerzeichen/HTML-Entities, Höhe für über 100 Zeilen, äußeres Scrollen und native Rich-Text-Formatierung sowie Titel/Schließen. Die alte ssHorizontal-Erwartung wurde durch ssNone ersetzt. `VerifyHelpAbout` erzeugt eigene Daten statt vom vorherigen Test abzuhängen. Bestehende Recorder/WAL-, SDK-Attrappen-, FMC-, Wetter-, SimBrief-, Einheiten-, Symbol- und Sprachtests bleiben erfolgreich.

Kein Live-Flug/Installer-Test; ein Installer fehlt noch. Alte/textbasierte Fenix/FBW-Daten enthalten keine vollständigen Stile/Lampen. B777-Grafik ist keine neue SDK-Integration. Attrappen bestätigen nicht jede kommerzielle Add-on-Version.


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

2026-10-19 — flightsim.to-Prüfpaket: neuer Win64-Release-Build, PE-Abhängigkeiten, 66 ZIP-Einträge, CRC/Lesevergleich, x64-EXE/DLLs, drei DLLs aus dem entpackten Paket geladen, vier CHM/HTML und EFB-Dateigrößen geprüft. Keine Pascal-Quellen, Aufnahmen, Logs, private Konfiguration oder Kontocaches enthalten. Die tatsächliche EXE zeigte ein reagierendes Hauptfenster und beendete sich regulär (Exit 0). Fünf englische Screenshots aus einer Aufnahmekopie visuell geprüft. Kein Live-MSFS-Test und kein Upload. Für öffentliche Verteilung bleibt der Zugang zum Corresponding Source gemäß bestehender AGPL zu klären.



### Diagramme per Drag-and-drop

VerifyChartDrag prüft synthetische VCL-Callbacks: Hinzufügen/Entfernen, Einfügeposition/leere Liste/Ende, Duplikate, Strg-Bedingung, gleiche Anzeigenamen mit unterschiedlichen IDs, Filter, Abbruch, fremde Quellen, Timerzustand, native Kontrollkästchenklicks und Arbeitskopie. Einfügemarker visuell geprüft. VerifyChartsConfigure, VerifyParameterNames, VerifyDetachedViews und VerifyLocalization bestanden. Veraltete Erwartung der Einstellungen von drei auf vier Registerkarten korrigiert. Kein physischer Mausversuch oder Zeitmessung des automatischen Scrollens. test.ps1 enthält standardmäßig 40 Programme.


### Windows-Sprache, neun Sprachen und VersionInfo

VerifyVersionLanguage prüft 14 regionale Varianten/Fallbacks, Windows-Sprache, dauerhaftes Auto, neun Sprachaktionen, Einstellungen/Abbrechen, genaue Überschriften, Unicode und EXE/About-Version. Französische Einstellungen und russisches Infofenster visuell geprüft. VerifyLocalization, VerifyParameterNames, VerifyHelpAbout, VerifyChartsConfigure, VerifyDisplayUnits und VerifyChartDrag bestanden. Alte Tests an GroupBox, 40 Symbole und zehn Sprachauswahlen angepasst. Build-Helfer auf Kopie: 0.1.0.2 zu 0.1.0.3. Katalog: 987 Definitionen, neun Sprachen, Platzhalter/DFM geprüft. Synthetisch; keine Änderung der Windows-Sprache und kein MSFS-Flug. Standardliste: 41 Programme; kein vollständiger Gesamtlauf.


Spracherweiterung (0.1.0.3): VerifyLocaleExpansion prüft 30 Regional-/Alias-/Fallback-Fälle, alle 25 Sprachaktionen, Einstellungstitel, Listenindizes und gespeicherte Regionalvarianten, Automatik, unverändertes Dezimaltrennzeichen und Hilfe-Fallback. Bildschirmbilder: be-BY, el-GR, pt-BR. Nur synthetische Tests, ohne MSFS. Katalogprüfung: 1003 Definitionen, 25 Gebietsschemas, Format-Platzhalter, Unicode und DFM-Verknüpfungen. Die Standardliste enthält 42 Programme; nicht alle wurden für diese Änderung ausgeführt. Ausgeführte Regression: VerifyLocaleExpansion, VerifyVersionLanguage, VerifyLocalization, VerifyParameterNames, VerifyHelpAbout, VerifyChartsConfigure, VerifyDisplayUnits, VerifyChartDrag. Keine muttersprachliche Prüfung; die Tests bestätigen nicht die sprachliche Qualität.


VerifyGlobalLocales: synthetische Prüfung von 32 nach Code sortierten Einträgen, Aliasen, fünf privat geladenen Schriftdateien und Glyphen für sieben Schriftproben. Prüft BiDiMode, RTL/LTR-Wechsel, wiederhergestellte Ankerpositionen, LTR für Rohdaten/Karte/Zeitachse, Einstellungen und sieben Bildschirmbilder. check_fonts.py prüft Herkunft, SHA-256, Dateiformate und zwei OFL-Lizenzen. check_documentation.py prüft vier Translation.*.md und README-Links. Standardliste: 43 Programme; nicht gleichbedeutend mit vollständiger Ausführung. Keine Live-Prüfung in MSFS oder muttersprachliche Prüfung.


Ausgeführter Umfang dieser Änderung: 11 Tests bestanden: VerifyGlobalLocales, VerifyLocaleExpansion, VerifyVersionLanguage, VerifyLocalization, VerifyChartsConfigure, VerifyDetachedViews, VerifyDisplayUnits, VerifyHelpAbout, VerifyParameterNames, VerifyChartDrag, VerifyReport.


Zusätzlich geprüft: neue Fenster bei bereits aktivem Arabisch/Hebräisch, RTL und rechts angeordnete Beschriftungen.


0.1.0.5 — VerifyRTLReturn startet mit gespeichertem ar-SA, öffnet das Sprachmenü über WM_INITMENUPOPUP, wechselt zu en-US und prüft vier Wechsel ar-SA/he-IL → pl-PL. Prüft VCL-Richtung, native HWND-RTL-Flags im Kontrollbaum, Panelpositionen, Sprachnamen ohne & und unveränderte ImageIndex-Werte aller 32 Sprachaktionen. Testeinstellungen werden wiederhergestellt; bin/settings.ini des Benutzers bleibt unberührt. Bestanden: VerifyRTLReturn, VerifyGlobalLocales, VerifyDetachedViews, VerifyLocalization. Nur synthetisch, ohne MSFS-Flug. Standardliste: 44 Programme, nicht vollständig ausgeführt.


0.1.0.6: VerifyRTLReturn prüft native MFT_RIGHTORDER/MFT_RIGHTJUSTIFY-Flags im gesamten HMENU-Baum, das Öffnen von Untermenüs und Hebräisch → Automatisch. Fehler vor der Korrektur reproduziert, danach PASS. Weitere bestandene Tests: VerifyGlobalLocales, VerifyDetachedViews, VerifyHelpAbout. Kein Live-Flug in MSFS. StackTrace/StackFrames erhalten; Debug-Kompilierung mit PDB-Erzeugung geprüft.


VerifyVersionLanguage — PASS (EXE VersionInfo 0.1.0.6).


0.1.0.7 — Paketierung: mateusz-efb-ifly, Community/Optional-Community, --addon und Installationshinweise entfernt. ZIP-Prüfung kontrolliert das Fehlen des Add-ons. Nur Distribution; keine zusätzlichen VCL-Verhaltenstests.

FBW-FMA-Modi und E/WD-Texte werden aus der Aufnahme dekodiert; Formatierung, Blinkzeit und unbekannte Kennungen bleiben erhalten. Debug-Einstellungen können die Instrumentenfamilie erzwingen. Die Karte zeigt PLN-Beschränkungen und ergänzt unbenannte Punkte anhand des SimBrief-Navlogs. Vollständige STS-, iFly-FMA- und Verfahrensdaten fehlen weiterhin; siehe `support/fbw/display-protocol.md`.

Synthetic coverage: VerifyAirbusDisplays (FMA words, EWD codes, missing/unknown data, debug override), VerifyFlightPlan (PLN constraints and OFP coordinates). Live simulator validation not performed.

Ausgewählte SID/STAR/APP-Verfahren werden über SimConnect Facilities mit Übergängen, Beschränkungen, RF/AF-Bögen und Fehlanflug erweitert. Der Navdata-Snapshot wird mit dem Originalplan gespeichert und offline wiedergegeben. Holdings haben schematische Symbole; Fehlanflüge sind dunkelgrau. Die iFly/B38M-FMA wird aus MCP-Lampen und SimVars rekonstruiert und als FMA RECONSTRUCTED gekennzeichnet; insbesondere VNAV, THR HLD und FLARE sind Näherungen.

VerifyProcedureRoute: mock Facilities API exports and headers, out-of-order parents, ItemIndex ordering, wrong runway exclusion, RF geometry, holding/missed constraints, repeated expansion, SQLite and offline replay. VerifyIFlyFMA: lamp encoding, mode priorities, AP/FD, ILS/armed GS, altitude capture and missing data. VerifyPFD737, VerifyFlightPlan, VerifySimBrief, VerifySubscriptions: regression checks. No live simulator or IDE designer validation. VerifyProcedureRoute disables the Delphi 10.2 Win64 optimizer to avoid compiler internal error URW1237; application builds retain their normal settings. DLL mock projects now explicitly set GenDll, preventing stale .dll use when the compiler otherwise writes a library to .exe.

Flight-Director-Wiedergabe für Nick/Roll in A320 und B38M, Standard-FD/EX1-Aufzeichnung in Radiant und eine Abschaltoption für B38M ergänzt. Fehlende historische Werte bleiben unbekannt; Null bleibt gültig. Quellen und Grenzen: `support/fbw/flight-director.md`.
VerifyFlightDirector, ProbeFlightDirector, VerifyAirbusDisplays, VerifyPFD737: synthetic replay tests; live simulator channels not verified.

B38M-PFD mit Kreuzzeiger-FD, durchgehendem Horizonthintergrund, ausgerichteten Skalen, Kompass-Halbrose und GS/TAS/Wind. Optionaler AoA in Debug nutzt aufgezeichnetes INCIDENCE ALPHA. iFly-MCP-Ziffern liefern Sollwerte; ARM und Moduslampen ergänzen falsche Standard-A/T-Werte. FMA bleibt geschätzt.
VerifyPFD737: synthetic AoA/radians/ground/missing/optional/render checks. VerifyIFlyFMA: 22 recorded AFDS configurations plus synthetic cases; no authoritative recorded FMA text, no live comparison.

Optionales MAX-Fluginformationsfeld neben dem PFD mit Flugnummer, SDK-Transpondercode einschließlich führender Nullen, Kennzeichen, SELCAL falls vorhanden sowie aufgezeichneter UTC, Datum und Aufzeichnungsdauer. In Debug ausblendbar. Fehlende Werte bleiben --; keine Computeruhr.
VerifyPFD737: synthetic panel rendering/hide, recorded midnight crossing, reverse seek, invalid time, missing SELCAL and squawk leading zero. VerifyFlightDirector: SQLite flight metadata roundtrip. No live test.

FBW-A320-Minima BARO, RADIO und NO DH aus gültigen ARINC-Wörtern; Anzeige und Markierung im sichtbaren Höhenband. RADIO nutzt die aktuelle Funkhöhe statt einer absoluten MSL-Höhe. B38M-Fluginformationen links/rechts (CPT/FO) umschaltbar. iFly/Fenix-Minima nicht bestätigt; Design-DECISION HEIGHT wird nicht als Piloteneinstellung verwendet.
VerifyPFDMinima: synthetic ARINC BARO/RADIO/NO DH, zero/missing, relative RA, off-scale/amber marker. VerifyPFD737: CPT/FO panel position and return. VerifyAirbusDisplays: BARO visual fixture. No live comparison.

B38M-PFD: Windströmungspfeil relativ zum TRUE-Kurs sowie VOR/ADF 1/2 mit Frequenz und verfügbarem DME. Neue NAV/ADF-Werte sind nullable REAL; alte Aufzeichnungen erhalten keine erfundenen Werte. Beide PFDs unterstützen gewählte IAS/Mach und STD ohne numerischen Druck; FBW nutzt native STD/QNH/QFE-Zustände. Tastendrücke sind keine dauerhaften Moduszustände.
VerifyPFDReadouts: synthetic native/standard mode priority, STD vs QNH 1013, QFE/invalid ARINC, IAS/Mach/blank MCP, VOR/ADF/OFF/zero/missing DME, TRUE-relative wind and SQLite NULL/frequency roundtrip. VerifyPFD737/VerifyAirbusDisplays snapshots; VerifySubscriptions checks NAV/ADF only during flight. No live test.

Aufzeichnungswiedergabe mit Start/Pause, Stopp mit Rücksetzen auf Anfang und 1x, Anfang/Ende, ±30 s und 0.125 bis 16x. Gemeinsame Zeitachse für Karte, Diagramme und getrennte Instrumente. Neue Aufzeichnungen speichern das anfängliche Abtastintervall; ältere nutzen den Median gültiger Abstände oder 500 ms. Alpha beider Bildlisten repariert; manuelle Symbole und Indizes bleiben erhalten.
VerifyPlayback: deterministic playback clock/rates/pause/seek/gaps/end/stop, stored and inferred cadence, SQLite and read-only legacy schema. VerifyInstrumentFrames: DFM actions, timer/glyph switching and transparent icon drawing in both sizes. Synthetic only, no simulator required.


Natives VCL-Docking: VerifyNativeDocking prüft gelöste Registerkarten, seitliches Andocken, Speicherung des Dock-Ziels und des DockManager-Baums, Rückkehr beim Schließen und die Lebensdauer der Steuerelemente mit synthetischen VCL-Daten. VerifyDetachedViews und VerifyViewState prüfen die Kompatibilität der sechs vorhandenen Ansichten. Manuelles Ziehen während eines Simulatorflugs wurde nicht getestet.


VerifyPlayback prüft die Interpolation zwischen Abtastungen ohne Indexwechsel, den Kurswechsel 359→1°, die Datumsgrenze, unveränderte Bool-/SDK-Zustände und NaN, den Schutz der Originaldaten und Aufzeichnungslücken. Synthetische Daten; die visuelle Flüssigkeit einer echten Aufzeichnung wurde nicht manuell bewertet.


VerifyInstrumentRender prüft Kantenpixel, Clipping und DC-Wiederherstellung bei 25/50/75/100/125/150/200/300% sowie PNG-Ansichten von B38M/A320-PFD, Six-Pack und EICAS mit Sichtkontrolle. Synthetischer WinAPI/VCL-Test; kein Wechsel zwischen physischen Monitoren mit unterschiedlicher DPI.


VerifyPanelProportions prüft wiederholtes verschachteltes Skalieren ohne Rundungsdrift, neue Splitterproportionen, ausgeblendete Bereiche und Mindestplatz. Echte VCL-Fenster prüfen seitliches/vertikales PFD/EICAS-Docking und sicheres Schließen des Hosts. Synthetische Tests; kein manuelles Ziehen während eines Simulatorflugs.


Offline geprüft: VerifySimWeather (getrennte Quellen, HTTP, METAR, DFM), test_weather_bridge.js (Coherent-Attrappe), VerifyReplayExtras (FLIGHT_START, 30 Sekunden ATC), VerifyUI, VerifySimBriefUI und VerifyRecordingFiles. Kein Live-Test von Wetter oder Verfahren: Simulator nicht gestartet. Kein vollständiger CTD-Dump analysiert.


VerifySimBriefMaps prüft HTTP-Attrappen, GIF/BLOB-Speicherung, Planidentität, Offline-Anzeige und Löschung. SimBriefUI prüft WM_MOUSEWHEEL über die Windows-Warteschlange und Loaded ohne DFM-OnMessage. Docking/UI prüfen alClient und ruhende Größen. Tick18 allein erzeugt kein Delta. Ein echtes SimBrief-GIF wurde mit Python geladen (HTTP 200, 32904 Bytes); kein vollständiger Live-GUI-Test. IDE-Designer nicht automatisiert.


Fenix 3.0.0.7454: statischer Audit von 176 XMLs, 1748 aktuellen Kandidaten und 300 historischen Namen. Python-Tests prüfen modulare Varianten und Paketversionen; VerifyFenix verwendet eine neu gebaute DLL-Attrappe und erhält alte gespeicherte Felder. Kein Live-Test des aktualisierten Fenixa; Verfügbarkeit, Einheiten und volle FMA/FD-Ausgänge nicht bestätigt.

Ghost/ATC: VerifyGhostReplay und MockGhostSim prüfen SQLite im Speicher, Thread-Zuordnung, Erzeugen/Freeze/Animation/Entfernen, Pause und ±10 s. VerifyNativeATC prüft Speicherung und Wiedergabe, VerifyATCBridge.js die Textauswertung. VerifyIDEProjectSave speichert eine DPROJ-Kopie mit TXmlIniFile. Nur synthetische Tests; Live-FSLTL/ATC und Speichern in der geöffneten IDE sind noch nicht geprüft.

IDE-Gruppen: check_project_groups.py — PASS für 2 Gruppen und 101 Projekte. VerifyIDEProjectSave — PASS für 103 isolierte XML-Kopien mit TXmlIniFile. Hauptgruppe Release Win64 — PASS (Anwendung und Setup). Das Speichern in der geöffneten IDE muss nach dem Neuladen noch bestätigt werden.

Bridge/FSLTL: VerifyBridgeInstall, VerifyBridgeSignature, VerifyAIModelMatching und VerifyGhostReplay — PASS: Community-Erkennung, Installation/Update/Reparatur/Entfernen, zwei verschlüsselte und separat signierte ZIP-Ebenen, ICAO/Bemalung sowie FSLTL/AIG-Fallback. VerifySetupUI, VerifySetupMaintenance, VerifySetupSignature, VerifyUI und VerifySubscriptions — PASS. 75 Modellfamilien und 134 XML-Hashes, keine Modelle/Texturen im Paket. Nur isolierte Tests mit temporärem CNG-Schlüssel; keine echte Community-Installation oder Live-Animation geprüft.


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


Die Verify*.dpr-Regressionen verwenden DUnitX (91 Projekte einschließlich VerifyCatalogSources). Die Python-Tests aus tests wurden nach DPR übertragen: native Assertions prüfen Produktionswerkzeuge über deren CLI mit isolierten Testdaten. Mocks und Diagnoseprogramme bleiben eigenständig. Jeder DPR besitzt DPROJ und einen Eintrag in Tests.groupproj; tools/sync_test_projects.py hält sie synchron. test.ps1 formatiert vor dem Kompilieren und entfernt MAP/RSM im finally-Block. Ergebnisse: docs/releases/0.1.1-review.md. Die Sprachtests decken 32 Gebietsschemas ohne Modellaufruf ab; PFD-Pixeltests prüfen CPT links und FO rechts.
