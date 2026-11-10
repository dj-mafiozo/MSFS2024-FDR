# Weitere Flugzeuge — L-vars aus Modell-XML

[Übersetzungen](../../Translation.de.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


PMDG DC-6: 904; CSS 737 Classic: 1221; Maddog X: 365; SkySim DC-9: 488; SkySim MD-11: 320; zusammen 3298 herstellerspezifische Namen. Alle angegebenen Modell-XML einschließlich Außenmodellen und DC-6A/B/BP wurden geprüft. `fields.json` enthält Quellhashes/Einheiten, 24 aircraft.cfg-Titel und ausgeschlossene dynamische/ungültige Namen; keine Original-XML.

In der DC-6-Dokumentation fehlt ein öffentlicher Daten-SDK-Header; es wird keine 737/777-Struktur verwendet. Gelesen werden nur wörtliche `(L:...)`, keine `(>L:...)`-Schreibzugriffe oder geratenen Vorlagennamen. Je Feld maximal eine offene ONCE-Anfrage; Fehler werden isoliert, Intervall/Pump begrenzt, keine dauerhafte SIM_FRAME-Warteschlange.

Rohwerte sind semantisch unbestätigt. Eine fehlende L-var kann Null liefern; Empfang beweist keine Unterstützung/Bereitschaft. Fehler/NaN/fehlende Daten bleiben null. Keine geratenen Einheiten oder Standard-SimVar-Ersetzung. Änderungshistorie, Diagramme und KI erhalten den Hinweis. Keine vollständigen FMS-Bildschirme oder Steuerung für diese Modelle.

Bekannte aircraft.cfg-Titel/Markennamen werden erkannt. Unbekannte Bemalungstitel können beim Standard-SimConnect bleiben; beliebige MD-11 (z.B. TFDi) werden nicht SkySim zugeordnet.

Generator: `tools/generate_addon_lvars.py --models-root <Ordner> --root <Repo>`. Unterordner PMDGDC6/CSS737/MaddogX/SkySimDC9/SkySimMD11 enthalten lokale XML/CFG. `VerifyAddonLVars`: Attrappen, kein Live-Flug.
## 0.1.0.10 — Subskriptionen je aktiver Sitzung

Im Leerlauf werden nur TITLE, ENGINE TYPE und NUMBER OF ENGINES einmal pro Sekunde gelesen, ergänzt durch System-/Flow-Ereignisse. FlightLoaded, AircraftLoaded und SimStart erneuern die Identifikation. SimStart kann den aktuellen FlightLoaded-Zustand abfragen. Ein zwischengespeicherter AircraftLoaded-Zustand startet keine Aufzeichnung im Menü. Laden/Sitzungsende schließt Telemetrie und Provider; SimStop unterbricht Subskriptionen. Pause oder vorübergehender SimStop teilt allein keine Aufzeichnung. Alte Paketgenerationen werden verworfen. AIRLINER wird nicht mehr für jedes Flugzeug abgefragt.

Acht Flugzeug-Units ersetzen den großen Katalog; AddonLVarCatalogU ist nur ein Register. 18 Varianten aus sechs kommerziellen Familien wurden geprüft. Die bisherigen fünf behalten 3298 Namen; TFDi MD-11 GE/PW (Passagier/Fracht) ergänzt 1446 explizite XML-L-vars. Kein binäres SDK: am angegebenen Ort lag kein entsprechender Header vor. Familienkataloge sind Vereinigungsmengen; Verfügbarkeit hängt von der Variante ab. Gemeinsame Modelle bedeuten nicht fehlende Variablen. Siehe `support/addon-lvars/variant-audit.json`. Offizielle locpak-Dateien ergänzen 306 Bell-407/EC135-Bindings: insgesamt 5050 Felder in acht Profilen. Null beweist keine verfügbare L-var.

