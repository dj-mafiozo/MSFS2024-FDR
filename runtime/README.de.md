# Build- und Laufzeitabhängigkeiten

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)
[Übersetzungen der Oberfläche](../Translation.de.md)


## Benutzerdaten und native FMC-Wiedergabe — 0.1.0.8

Einstellungen, `flight_data.db`, Logs, Absturzabbild, Karten-Cache und Analyse-Arbeitsdateien liegen jetzt unter `%LocalAppData%\MSFS24-FDR\`. Der Ordner wird vor der Initialisierung erstellt. DLLs, Übersetzungen, Schriften, Hilfe und `Assets` bleiben beim EXE; Schreibrechte in Program Files sind nicht erforderlich. Der Installer folgt später.

Vor dem ersten Start die alte Version schließen. Einstellungen, Standarddatenbank samt WAL/SHM und Logs werden vor dem Öffnen aus dem EXE-Ordner übernommen. Vorhandene AppData-Dateien werden nicht überschrieben; Konflikte bleiben unverändert im Quellordner, ohne Zusammenführung. Fehlt das Löschrecht, bleibt die alte Kopie erhalten. Eine unterbrochene Übernahme wird aus `migration.pending` fortgesetzt; ein aktiver alter Schreiber führt zu einer Startfehlermeldung. Vor Updates die geschlossene Datenbank sichern.

WebView2 wird nicht mehr benötigt. OFP verwendet ein schreibgeschütztes natives `TMemo` mit Consolas, ohne Rahmen/eigene Scrollleisten, mit zeilenabhängiger Höhe; der äußere Container scrollt. KI-Berichte verwenden natives `TRichEdit` mit Überschriften, Fettdruck und Listen; HTML/Skripte werden nicht ausgeführt.

**FMC/MCDU** zeigt pro Gerät den letzten gespeicherten Bildschirm bis zur Cursorzeit. **Separates Fenster** verschiebt denselben Frame in ein `bsDialog`-Fenster; Schließen oder erneutes Klicken dockt ihn an. Zeit und Aufzeichnung bleiben synchron. B737/A320/B777-Hintergründe werden proportional skaliert; gespeicherte `style_json`/`annunciators_json` steuern Farben, kleine Zeichen und Lampen. Bei Ausfall oder fehlender Verfügbarkeit bleibt kein alter Text stehen. Alte Aufzeichnungen und der bisherige reine Fenix/FBW-FlightPad-Text enthalten keine vollständigen Format-/Lampendaten; diese werden nicht erfunden. Das B777-Bild ergänzt keinen PMDG-777-SDK-Rekorder.




Laufzeit-DLLs, EXEs, private Datenbanken, Einstellungen und Logs sind in Git ausgeschlossen. build.ps1 kopiert DLLs aus SDK/lokalen Quellen. bin/settings.example.ini ist die sichere Vorlage; bei Updates keine private settings.ini ersetzen. Compilerdateien liegen in .build/<Platform>/<Config>, Test-DCUs getrennt nach Architektur. tools/package.py erzeugt Quell-/Programmpakete mit Lizenzhinweisen und sicheren Vorgaben ohne Aufzeichnungen oder Zugangsdaten.
