# Fenix A32X

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Flugzeugtitel mit Fenix oder FNX_32/FNX A32 wählen automatisch FenixA32X. Andere Flugzeuge behalten ihre SimConnect-Daten; iFly verwendet weiterhin sein eigenes SDK. Der Katalog enthält 1203 eindeutige L-Vars aus 2096 VAR_NAME*-Parametern der bereitgestellten Cockpit_Behavior.xml. Kontext und SHA-256 bleiben im Manifest; die Herstellerdatei wird nicht verteilt.

TFenixReader nutzt eine getrennte SimConnect-Verbindung ausschließlich zum Lesen: FLOAT64/number, Pakete zu 128 Feldern, SIM_FRAME-Aktualisierung und Datenbankintervall in Millisekunden. Keine zusätzlichen Programme, WASM-Module, Cockpitbefehle oder Schreibzugriffe sind erforderlich.

Der erste Zustand ist vollständig, danach werden Änderungen gespeichert. Diagramme verwenden `FenixLVar.<Name>`. S_MIP_GEAR bedeutet UP/DOWN; S_FC_FLAPS enthält Hebelrasten 0–4, keine physikalischen Winkel und keine sichere Unterscheidung CONF 1/1+F. Die Gashebelanimation 0–5 ersetzt keinen Schubprozentsatz. AP/A-THR-Taster und Leuchten beweisen keinen aktiven Betriebsmodus. Ohne bestätigtes Gegenstück stammen Fahrwerksposition, Radkontakt, Flugbewegung und Wetter weiterhin aus SimConnect.

Fehlende, ungültige oder veraltete Daten werden null. Gültigkeitsdauer: max(1000, Intervall_ms)*3 ms; nach 30 s ohne Daten wird mit Warteintervallen neu verbunden. Pause, Flugzeugwechsel und Verbindungsabbruch leeren den Cache. Ein empfangener Nullwert beweist nicht die Existenz einer L-Var; SimConnect kann ihn auch für unbekannte Namen liefern. Im Katalog wurden keine direkten numerischen V1/VR/V2/VREF/VAPP gefunden. Vollständigen MCDU-Text liefert ein verbundener, aktualisierter FlightPadFMC-Client: [Protokoll](../flightpad/README.de.md).

Nach einem Fenix-Update Katalog neu erzeugen und kompilieren:

```text
python tools/import_fenix_catalog.py "Pfad/Cockpit_Behavior.xml" support/fenix/variables.json
python tools/generate_fenix_catalog.py
```

VerifyFenix prüft API-Aufrufe, Erkennung, Fehlerisolierung, Nullwerte, Verlauf, Diagramme und Analyse mit einer DLL-Attrappe. Tatsächliche Werte erfordern eine laufende Fenix/MSFS-Sitzung. Die Tests bestätigen keine reale Integration jeder Fenix-Version.
