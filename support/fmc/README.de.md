# FMC/MCDU-Bildschirmverlauf

[Übersetzungen der Oberfläche](../../Translation.de.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

TFMCScreen besitzt TStringList Lines: 14 Zeilen zu 24 Zeichen, einschließlich Leerzeichen und CRLF. FireDAC deaktiviert StrsTrim. iFly liefert Zeichen/Glyphen, komprimierte Farben/Schriften, HTML und CDU-Lampen; PMDG liefert Client Data CDU; Fenix/FBW benötigen den aktualisierten [FlightPadFMC-Client](../flightpad/README.de.md). Helligkeit beweist keine Stromversorgung; numerische L-Vars ersetzen keinen Text.

trip_fmc_screens speichert jede Änderung von Text, Verfügbarkeit, Stromversorgung oder Darstellung mit trip/sample, Simulator- und Empfangszeit UTC, provider/device, Seitenschlüssel, raw_text und parsed_json. Unveränderte Zustände werden ausgelassen. Power: -1 unbekannt, 0 aus, 1 ein. Seitennummer und MOD/TMPY bleiben getrennt und ersetzen keine ausgeführten Referenzen.

Der Vorbereitungspuffer behält 4096 Änderungen und zusätzlich den letzten Zustand jeder Seite. Beim Flugbeginn wird er transaktional mit Originalzeiten zugeordnet; sample=0 bedeutet Beobachtung ohne vorhandene Telemetrieprobe. Die heutige Sitzungsaufzeichnung erfasst auch den geladenen Flug vor dem Motorstart. Flugzeugwechsel, Stopp und Trennung leeren den Cache; Beenden ohne Flug verliert den Speicherpuffer.

Die Analyse wählt den letzten Bildschirm, die letzte Seite und die letzten geparsten Werte vor dem Ereignis aus dem gesamten Verlauf, je Gerät getrennt, auch außerhalb des Analysefensters. Spätere Beobachtungen bleiben ausgeschlossen. Verborgene Seiten sind zuletzt beobachtete Werte, keine laufende Abfrage des FMC-Speichers. Leere oder mehrdeutige Werte ergeben null. MOD/TMPY wird nicht als aktiv ausgeführt behandelt. Typisierte SDK-Referenzen haben Vorrang.

Boeing: PERF INIT, N1 LIMIT, TAKEOFF REF, APPROACH REF; ausgewählte V1/VR/V2 statt QRH-Spalte und FLAP/SPD statt beliebiger VREF-Tabellenzeile, Windkorrektur getrennt. iFly/PMDG teilen vorläufig den Parser. Airbus: INIT/PERF, VAPP/VLS, FLEX, Klappen/THS, Höhen und Minima; VLS ist nicht VREF und unbestätigte Gewichtseinheiten bleiben Text. Technische Feldlisten stehen in Boeing-performance.md, Airbus-MCDU.md und IFly-display-storage.md.

Die Anwendung navigiert nicht selbst und drückt keine Tasten. Relevante Seiten während der Vorbereitung anzeigen; kürzere Übergänge als das Abfrageintervall können fehlen. Alte Rohbildschirme werden für den Kontext erneut geparst, ohne den historischen Datensatz zu überschreiben. VerifyFMC/VerifyBoeingFMC/VerifyAirbusMCDU/VerifyIFlyDisplays sind synthetisch. Der frühere optionale iFly-Liveprobe meldete SDK state=0; vollständiger Liveempfang ist dadurch nicht bestätigt.
