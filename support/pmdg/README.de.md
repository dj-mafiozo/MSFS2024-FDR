# PMDG 737 NG3 SDK

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

PMDG 737 NG (-600/-700/-800/-900, BBJ/Fracht) wählt PMDGNG3. PMDG 777, MAX und andere Hersteller werden nicht zugeordnet. Der bereitgestellte offizielle PMDG_NG3_SDK.h beschreibt 916 Byte Hauptdaten mit 494 benannten Feldern nach Array-Auflösung sowie 1009 Byte je CDU. Reservierte Bytes sind keine Telemetrie. pack(8), maximale Feldausrichtung 4, Größe und Offsets wurden mit ctypes und unabhängig mit clang-cl geprüft. Der proprietäre Header wird nicht mitgeliefert.

Eine eigene SimConnect-Verbindung liest nur PMDG_NG3_Data und PMDG_NG3_CDU_0/1: ON_SET plus anfängliches ONCE. Keine Steuerbereiche, Client-Data-Schreibzugriffe oder Cockpitereignisse. CDU-Ausfälle stoppen den Hauptdatenstrom nicht.

Im aktiven Flugzeug-Optionsfile muss stehen:

```ini
[SDK]
EnableDataBroadcast=1
EnableCDUBroadcast.0=1
EnableCDUBroadcast.1=1
```

Der Header nennt 737NG3_Options.ini; die untersuchte MSFS24-737-600 verwendet `LocalState/WASM/MSFS2024/pmdg-aircraft-736/work/737_Options.ini`. Die Optionen waren bereits aktiv; die Installation wurde nicht verändert. Nach eigenen Änderungen Flugzeug neu laden.

V-Speeds sind kt; null gesetzte Geschwindigkeiten werden als nicht ausgewählte Referenz behandelt, Rohwerte bleiben erhalten. Landing altitude -32767 fehlt; andere negative Höhen können gültig sein. Negative TOD-/Zieldistanzen fehlen, TOD=0 ist gültig. MCP berücksichtigt Stromversorgung, Leeranzeige und IAS/Mach. Fahrwerkshebel OFF bleibt Rohzustand 1 und überschreibt UP/DOWN nicht. A/THR nutzt die Servoverbindung, AP die Pitch/Roll-Kontrolle einschließlich CWS, ohne CMD/LNAV/VNAV zu behaupten. SDK-Kraftstoff ist lb unabhängig von WeightInKg. Klappenanzeigen sind keine erfundenen Winkel; FMC-Einträge beschreiben geplante Konfiguration.

ON_SET hat keinen Heartbeat. Ein stabiler Zustand bleibt bis zur nächsten Meldung erhalten; data_update_age_ms bezeichnet das Paketalter, nicht einen frischen Messwert. Pause, Flugzeugwechsel und Trennung leeren Caches. Fehlende Hauptdaten lösen Wiederverbindung mit Warteintervallen aus. Der erste Datenbankzustand ist vollständig, spätere Einträge enthalten Änderungen; Diagramme `PMDGNG3.<Feld>`.

CDU: 24 Spalten × 14 Zeilen × Symbol/Farbe/Flags plus powered; Spalten sind die äußere Dimension. Text, Pfeile und Originalbytes bleiben erhalten. Ein ausgeschaltetes Display gilt nicht als aktuelle Referenz. Boeing-Seiten verwenden vorläufig den gemeinsamen iFly/PMDG-Parser; ein Livevergleich steht aus.

```text
python tools/generate_pmdg_catalog.py "Pfad/PMDG_NG3_SDK.h"
```

Neu kompilieren; zusätzlich entsteht `.build/VerifyPMDGLayout.cpp`. VerifyPMDG prüft API, Layout, Sentinels, CDU, Zustand, Verlauf und Analyse mit einer DLL-Attrappe. ProbePMDG ist ein optionaler lesender Liveprobe. Während der früheren Prüfung flog der Benutzer iFly; für den Test wurde kein Flugzeug gewechselt. Reale PMDG-Werte bleiben zu prüfen.
