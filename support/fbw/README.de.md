# FlyByWire A32NX

[Übersetzungen der Oberfläche](../../Translation.de.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Titel mit A32NX oder FlyByWire/FBW zusammen mit A320 wählen FBWA32NX. Ein allgemeiner A320 oder FBW A380 passt nicht. Der Katalog enthält 223 lesbare L-Vars aus der bereitgestellten Flight Deck API-Dokumentation. Explizite Indizes werden aufgelöst, 26 veraltete oder nur schreibbare Einträge ausgeschlossen. Bereitschaft und Geschwindigkeitseinheiten ergänzen die offiziellen Referenzen. Manifest und Katalog enthalten den SHA-256 der Quelle; die vollständige HTML-Dokumentation wird nicht verteilt.

TAircraftLVarReader liest FLOAT64/number in Gruppen von 128 über eine getrennte Verbindung ohne Schreibzugriff. SIM_FRAME liefert Aktualisierungen; Datenbankeinträge folgen dem FDR-Intervall. Fehler des Zusatzlesers beenden die Hauptaufzeichnung nicht. Fehlende/veraltete Werte sind null, ein empfangener Nullwert bestätigt keine Existenz. IS_READY=1 ist Voraussetzung für Standardwert-Überschreibungen und VAPP, beweist aber nicht die Gültigkeit jedes Feldes.

AUTOTHRUST_STATUS 0/1/2 bedeutet aus/bereit/aktiv. Klappenrasten 0/1/2/3/4 entsprechen MSFS 0/2/3/4/5; sie sind keine Flächenwinkel. Die FCU-Geschwindigkeitsanzeige berücksichtigt Striche und IAS/Mach. VAPP kann eine Piloteneingabe enthalten und ist nicht VREF. Null, fehlende Bereitschaft oder veraltete Daten ergeben keine Referenz. AP-Tasterleuchten ersetzen nicht den tatsächlichen Einschaltzustand.

Verlauf: vollständiger Anfang und rekursive Änderungen; Diagramme `FBWLVar.<Name>`. Flugzeugwechsel, Pause und Trennung leeren den Cache. Verifizierte SDK-Referenzen haben Vorrang; alte Aufzeichnungen erhalten keine zuvor nicht erfassten Werte. Vollständigen MCDU-Text liefert der aktualisierte, verbundene [FlightPadFMC-Client](../flightpad/README.de.md).

```text
python tools/import_fbw_catalog.py "A32NX Flight Deck API - FlyByWire Simulations Documentation.htm" support/fbw/variables.json
python tools/generate_fbw_catalog.py
```

Danach neu kompilieren. VerifyFBW prüft Erkennung, Transport, Bereitschaft, Klappen/A-THR, IAS/Mach, VAPP, Fehler, Verlauf und Analyse mit einer DLL-Attrappe. Die realen Variablenwerte müssen im Simulator bestätigt werden. Referenz: https://github.com/flybywiresim/aircraft/blob/master/fbw-a32nx/docs/a320-simvars.md.
