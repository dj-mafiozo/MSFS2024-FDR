# MCDU-Bildschirme aus FlightPadFMC

[Übersetzungen der Oberfläche](../../Translation.de.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

FDR liest vollständigen Text aus einem laufenden, verbundenen und aktualisierten Windows-Client: FenixA320MCDU, FenixA320Screen, FBWA320MCDU oder FBWA320Screen. Ein altes EXE ohne Exporter liefert keinen Text. FDR startet weder Client noch Server und drückt keine Tasten.

TScreenModel.ExportText in Windows/Common/ScreenModel.pas bildet sichtbare Zellen in TStringList ab und liefert Lines.Text: 14 Zeilen × 24 UTF-16-Zeichen mit CRLF, insgesamt 364 UTF-16-Einheiten. Ausrichtung, Leerzeichen, Leerzeilen, Symbole und Scratchpad bleiben erhalten. HasScreen unterscheidet einen empfangenen Bildschirm vom leeren Anfang; Reset macht ihn ungültig. Farben/Schriftgrößen sind nicht Teil dieses Textformats.

FMCMain veröffentlicht über seinen vorhandenen Timer nur bei verbundenem Transport, empfangenem Bildschirm und ohne Status-Overlay. Voll- und Screen-Clients funktionieren minimiert, solange ihre Nachrichtenschleife läuft. Seiten werden nicht automatisch umgeschaltet.

## Lokales Protokoll

FlightPadScreenIPCU ist abgesehen vom Unitnamen mit der FlightPadFMC-Implementierung identisch. v1 ist ein 776-Byte-packed-record ohne Zeiger oder bitnessabhängige Typen; Win32-Exporter und Win64-FDR sind kompatibel.

- Mapping `Local\FlightPadFMC.Screen.v1.<Profil>.<PID>`, Mutex mit zusätzlichem `.Lock`.
- Profile FenixA320 und FBWA320; Header mit Version, Größe, PID, Heartbeat, Änderungstick/UTC FILETIME, Verfügbarkeit, Länge und Text.
- Nicht blockierender Mutex; der Leser sucht Prozesse der aktuellen Windows-Sitzung und öffnet nur lesend.
- Fehlender Prozess/Mapping, ungültiges Format/CRLF/Länge oder Heartbeat älter als fünf Sekunden: nicht verfügbar.
- Bei mehreren Instanzen gewinnt der verfügbare Bildschirm mit neuester Änderung. Das aktuelle Airbus-Modell exportiert nur einen linken Bildschirm; kein zweites MCDU wird erfunden.

Beide Anwendungen benötigen dieselbe Sitzung und kompatible Objektberechtigungen. Kein konfigurierter Installationspfad oder Netzwerkport ist nötig.

## Aufzeichnung und Prüfung

Nach Flugzeugerkennung gelangt cdu/0 unabhängig von numerischen L-Vars in den gemeinsamen FMC-Verlauf. Quelle FlightPadFMC/<Profil>; Stromversorgung bleibt unbekannt, denn eine Verbindung beweist keine eingeschaltete MCDU. Änderungen speichern Simulator- und Beobachtungszeit; observed_filetime_utc erhält die ursprüngliche Änderungszeit des Exporters. Heartbeat verändert sie nicht. Schließen/Trennen/veralteter Heartbeat machen die aktuelle Anzeige ungültig. Zuletzt gesehene Seiten bleiben historische Beobachtungen; sehr kurze Anzeigen zwischen Abfragen können fehlen.

VerifyFlightPad startet MockFlightPad32 und prüft echtes Win32/Win64-IPC, Profile/PID-Auswahl, Unicode, Zeitstabilität, ungültige Pakete, Verfügbarkeit, Verlauf und Analyse. Dies ist kein echter Fenix/FBW-Flug. Windows/tests/ExportTests.dpr im FlightPadFMC-Projekt prüft beide Produktionsmodelle, Scratchpad und Reset; die vier Windows-Clients wurden im früheren Entwicklungsschritt kompiliert.

FlightPadFMC-export.patch enthält Exporter, Projektmetadaten und Modelltest. Im FlightPadFMC-Stamm erst `git apply --check <Patch>` ausführen, dann auf unveränderter Basis `git apply <Patch>`. Nicht erneut auf schon aktualisierte Quellen anwenden. tools/verify_flightpad.ps1 vergleicht gemeinsame Implementierungen und kompiliert lokale Clients. Die MIT-Lizenz liegt daneben.
