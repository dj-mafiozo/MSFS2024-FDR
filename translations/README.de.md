# Übersetzungen PL / EN / DE / ES

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Einzige Textquelle ist MSFS2024-FDR.i18n in diesem Verzeichnis: ein unkomprimierter UTF-8-XML-Katalog im Format des installierten i18n-Pakets. Mit dessen Editor oder einem UTF-8-Texteditor bearbeiten. Es gibt keinen parallelen JSON-Katalog und keinen Pascal-Textgenerator.

Jede Definition enthält pl-PL, en-US, de-DE und es-ES. Polnisch ist Standard. Werkzeuge → Sprache oder Einstellungen → Allgemein speichert [ui] language=...; Abbrechen wendet nichts an. Sprachnamen bleiben in ihrer eigenen Sprache.

Application enthält Tr(...)-Literale. IDs erhalten und neue Literale mit Editor/GetStringIdentifier erzeugen: die Bibliothek verwendet eine ältere MD5-Variante, nicht immer Standard-MD5. Form-/Frame-Domänen sind Klassennamen ohne T, etwa frmMain, fraMap und fraGraph. Eigenschaften heißen beispielsweise .Caption, aSettings.Caption oder cbProvider.Items[0]. Aktionen besitzen den gemeinsamen Text für Menü und Buttons. Dynamische Fenstertitel werden bei Sprachänderungen aktualisiert.

`python tools/check_translations.py` prüft vier Sprachen, Format-Platzhalter, Unicode und DFM-Verweise. Buildskript/MSBuild kopieren den Katalog als bin/MSFS2024-FDR.i18n neben das EXE. Bei Auslieferung mitgeben. Textänderungen benötigen Neustart, keine Neukompilierung. Entwicklungs-/Testprogramme können ersatzweise ../translations/MSFS2024-FDR.i18n lesen; fehlen beide, ist die Installation unvollständig.

FMC/METAR/OFP-Rohtext, Benutzerdaten, SimVar-/L-Var-Namen, SQL/API/JSON-Schlüssel nicht übersetzen. KI-Anfragen und Berichte bleiben wie angefordert auf Polnisch. README und Testy-Dokumentation liegen ohne Suffix auf Polnisch sowie mit .en.md, .de.md und .es.md vor. Herstellerdokumente und Lizenztexte bleiben Originale. Bibliothek/Lizenz: vendor/i18n und support/i18n/LICENSE.

## Lesbare Parameternamen

Diagramme, Auswahl-/Reihenfolgelisten und Werteinspektor zeigen Beschreibungen mit Einheiten, etwa `Flughöhe [ft]` und `N1-Drehzahl — Triebwerk 2 [%]`. Die Sprache folgt der Oberfläche. Suche und Tooltips unterstützen lesbare Namen und Rohkennungen.

Beschriftungen stehen in den Domänen `Parameters` und `ParameterWords` von MSFS2024-FDR.i18n. Translation bearbeiten; Value und ID behalten stabile Kennungen.
