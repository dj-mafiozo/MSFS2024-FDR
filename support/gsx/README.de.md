# Aufgezeichnete GSX-Pro-SDK-Werte

[Übersetzungen der Oberfläche](../../Translation.de.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Telemetry/GSXVarsU.pas liest unabhängig vom Flugzeug 20 numerische L-Vars über MSFS24 SimConnect. Jede hat eigene Definition/Anforderung; ein fehlendes Feld blockiert keine anderen. Keine WASM-Brücke, Steuerbefehle oder Schreibzugriffe.

Der Katalog enthält Boarding-/Deboarding-/Catering-/Betankungs-/Abflug-/Enteisungszustände, FSDT_VAR_Frozen für GSX-Pushback-Freeze (nicht Simulatorpause), aktuelle und gesamte Passagierzähler, Cargo-Aktivität/-Fortschritt für beide Richtungen und den Rohcode des Enteisungsmittels. Aktuelle Zähler können je Bus zurückgesetzt werden; Cargo-Prozent ist zwischen Ladern gemittelt. Das Handbuch nennt FSDT_GSX_DEICE_STATE, nicht die alte Bezeichnung DEICING_STATE.

Servicezustände: 1 anforderbar, 2 nicht verfügbar, 3 übersprungen, 4 angefordert, 5 aktiv, 6 abgeschlossen. Null beweist weder GSX-Verfügbarkeit noch gültigen Servicezustand; eine fehlende L-Var kann null liefern. Transportstatus received_not_verified, partial oder unavailable. Fehlende/ungültige Daten sind null; älter als drei Sekunden ist nicht aktuell.

Vollständige Basis und folgende Änderungen werden als gsx_lvars in trip_aircraft_data mit Telemetrie-/Zeitbezug gespeichert. Gleiches wird nicht dupliziert. Wiedergabe liefert GSX.* für Diagramme/Inspektor mit erhaltenen Lücken; Analyse erhält Zustandsdefinitionen und rekonstruierte Werte. Aufzeichnung umfasst Laden bis Ende einschließlich Boarding vor Motorstart und Deboarding nach Abschalten. Pause beendet keinen Flug. GSX-Zähler ersetzen keine gemessene Flugzeugmasse, Nutzlast oder Kraftstoffmenge.

Dies ist ein erster Service-/Zählerumfang, nicht jeder GSX-L-Var oder Fahrzeugzustand. Quelle: offizielles GSX-Handbuch, DEVELOPERS — Interfacing with GSX, Seiten 106–108 von 291; alle 20 Namen wurden gefunden. PDF-SHA-256: ee4ae760168e7045d3598905d3e1b4a3ccb56337fdb50586e7456c3dc4feafc1. Das Herstellerhandbuch wird nicht verteilt. VerifyGSX verwendet eine SimConnect-Attrappe; reale GSX-Werte sind noch nicht live bestätigt.

Anzeige: übersetzte Dienstzustände und Passagierfortschritt verwenden die kumulativen _TOTAL-Zähler aller Busse sowie FSDT_GSX_NUMPASSENGERS als separate Zielanzahl. Der Gepäckfortschritt ist ein Prozentwert, keine Stückzahl. Fehlende Zielwerte älterer Aufnahmen bleiben unbekannt.

Balken erscheinen ab Requested (4), bleiben bei aktiven (5) und abgeschlossenen (6) Diensten und verschwinden bei anderen/fehlenden Zuständen. FUEL_COUNTER / FUEL_COUNTER_MAX betrifft den aktuellen Tankwagen, nicht die gesamte Betankung, und kann bei einem neuen Wagen zurückgesetzt werden. Ohne zuverlässigen Zähler bleibt der Balken unbestimmt. FUELHOSE_CONNECTED wird ebenfalls aufgezeichnet. Quelle: dasselbe offizielle GSX-Handbuch, Seite 108.
