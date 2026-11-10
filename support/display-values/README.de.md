# Audit der Wertbeschriftungen

[Übersetzungshinweis](../../Translation.de.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

5118 Felder besitzen Zuordnungen, davon 2313 neue. Geprüft wurden SDK-Header von iFly, PMDG NG3 und PMDG 777 sowie 335 XML-Dateien verfügbarer Varianten. Weitere Bool-Werte stammen aus bereits inventarisierten expliziten XML-Einheiten, einschließlich Bell 407 und EC135.

`catalog.json` speichert Beschriftungen, Extraktionsregeln, Quelldateien und SHA-256. Hersteller-XML und SDK-Header werden nicht verteilt. Zur Laufzeit werden nur kompilierte Pascal-Kataloge verwendet. Generatoren erhalten Metadaten über `apply_display_values.py`.

Verwendet werden explizite Enums, ANIMTIP, eindeutige Press/Release-Zuweisungen und typisierte Bool-Werte. iFly-Kommentare werden als GB18030 gelesen. Nicht dokumentierte Zwischenwerte, umgekehrte FO-Sequenzen und private WASM-Zustände werden nicht erraten. Aus 14 fehlerhaften XML-Dateien werden nur eigenständig gültige UseTemplate-Fragmente gelesen. Zuordnungen beweisen keine Live-Verfügbarkeit.

Prüfung: `test.ps1 -Tests VerifyCatalogSources,VerifyParameterValues`, `python tools/apply_display_values.py --check` und Delphi VerifyParameterValues. Kein neuer Live-Test.

## Standard-SimConnect-Klappenindex

`FlapsHandleU.pas` enthält eine eigene ICAO-Auswahl mit leerem Standardschlüsselbuch. Quellen: `flaps.json`; Übersicht: [flaps-coverage.csv](flaps-coverage.csv). Generator: `python tools/generate_flap_profiles.py`, Prüfung mit `--check`.

156 Codes: 66 Profile, 30 Muster ohne Flügelklappen und 60 unbestätigte Muster. Keine vollständige Abdeckung aller Standardflugzeuge: lokale MSFS-2024-Konfigurationen sind verschlüsselt. Verwendet wurden 26 Addon-Konfigurationen, Simulatorhandbücher und Herstellerreferenzen. Unbekannte Fälle bleiben numerisch. Kein Live-Nachweis aller Profile.

A320-SimConnect hat sechs Stellungen einschließlich 1+F, der SDK-Hebel fünf. MD-11-Varianten TFDi/SkySim werden anhand des aufgezeichneten Titels unterschieden. Eine abweichende aufgezeichnete Positionsanzahl deaktiviert das Profil; gleiche Anzahl garantiert keine gleichen Winkel in fremden Modifikationen. Beschriftungen sind nominale Stellungen, keine gemessenen Oberflächenwinkel.
