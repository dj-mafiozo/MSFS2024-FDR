# Übersetzungen der Oberfläche

[Übersetzungen der Oberfläche](../Translation.de.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Einzige Textquelle ist MSFS2024-FDR.i18n in diesem Verzeichnis: ein unkomprimierter UTF-8-XML-Katalog im Format des installierten i18n-Pakets. Mit dessen Editor oder einem UTF-8-Texteditor bearbeiten. Es gibt keinen parallelen JSON-Katalog und keinen Pascal-Textgenerator.

Jede Definition enthält alle 25 Gebietsschemas aus LocalizationU. Polnisch ist die Quellsprache; die erste Sprachauswahl erfolgt automatisch. Werkzeuge → Sprache oder Einstellungen → Allgemein speichert [ui] language=...; Abbrechen wendet nichts an. Sprachnamen bleiben in ihrer eigenen Sprache.

Application enthält Tr(...)-Literale. IDs erhalten und neue Literale mit Editor/GetStringIdentifier erzeugen: die Bibliothek verwendet eine ältere MD5-Variante, nicht immer Standard-MD5. Form-/Frame-Domänen sind Klassennamen ohne T, etwa frmMain, fraMap und fraGraph. Eigenschaften heißen beispielsweise .Caption, aSettings.Caption oder cbProvider.Items[0]. Aktionen besitzen den gemeinsamen Text für Menü und Buttons. Dynamische Fenstertitel werden bei Sprachänderungen aktualisiert.

`python tools/check_translations.py` prüft alle registrierten Gebietsschemas, Format-Platzhalter, Unicode und DFM-Verweise. Buildskript/MSBuild kopieren den Katalog als bin/MSFS2024-FDR.i18n neben das EXE. Bei Auslieferung mitgeben. Textänderungen benötigen Neustart, keine Neukompilierung. Entwicklungs-/Testprogramme können ersatzweise ../translations/MSFS2024-FDR.i18n lesen; fehlen beide, ist die Installation unvollständig.

FMC/METAR/OFP-Rohtext, Benutzerdaten, SimVar-/L-Var-Namen, SQL/API/JSON-Schlüssel nicht übersetzen. KI-Anfragen und Berichte bleiben wie angefordert auf Polnisch. README und Testy-Dokumentation liegen ohne Suffix auf Polnisch sowie mit .en.md, .de.md und .es.md vor. Herstellerdokumente und Lizenztexte bleiben Originale. Bibliothek/Lizenz: vendor/i18n und support/i18n/LICENSE.

## Lesbare Parameternamen

Diagramme, Auswahl-/Reihenfolgelisten und Werteinspektor zeigen Beschreibungen mit Einheiten, etwa `Flughöhe [ft]` und `N1-Drehzahl — Triebwerk 2 [%]`. Die Sprache folgt der Oberfläche. Suche und Tooltips unterstützen lesbare Namen und Rohkennungen.

Beschriftungen stehen in den Domänen `Parameters` und `ParameterWords` von MSFS2024-FDR.i18n. Translation bearbeiten; Value und ID behalten stabile Kennungen.


Die erste Sprachwahl ist auto. Die Windows-Anzeigesprache wird unabhängig von Zahlen-/Datumsformaten erkannt. Regionale Varianten werden PL/EN/DE/ES/FR/RU/TR/IT/PT zugeordnet, sonst Englisch. Auto bleibt gespeichert; explizite bestehende Einstellungen bleiben erhalten. Menü und Einstellungen bieten zehn Optionen. Neue GUI-Beschriftungen sind übersetzt. Hilfe bleibt viersprachig, mit englischem Fallback für neue Sprachen. Neue Texte sind ein lokaler Qwen3-Erstentwurf mit Fachbegriffskorrekturen, ohne muttersprachliche Prüfung. VersionU liest EXE-Versionsdaten und Sprachblöcke; Info zeigt Dateiversion, ProductName und Copyright. Gemeinsamer Build: 2 (0.1.0.2); übrige Versionsnummern/Autorendaten unverändert. bump_build.py erhöht nur Build pro logischer Änderung; check_version.py prüft Vererbung. CLI nutzt MSBuild für aktuelle Versionsressourcen.


Erweiterung: Die Oberfläche unterstützt 25 Gebietsschemas. Neu: en-GB, fr-CA, pt-BR, de-AT, de-CH, be-BY, el-GR, uk-UA, hr-HR, cs-CZ, da-DK, nl-NL, fi-FI, nb-NO, sk-SK und sv-SE. Regionale Varianten werden getrennt gespeichert. be steht für Belarussisch; no/nb/nn verwenden die verfügbare Bokmål-Übersetzung, keine eigene Nynorsk-Version. Schweizer Deutsch verwendet ss statt ß. Die automatische Auswahl folgt der Windows-Anzeigesprache, ohne Zahlenformate zu ändern. Die Hilfe bleibt PL/EN/DE/ES, mit Basissprache oder Englisch als Ersatz. Neue Übersetzungen sind eine erste Fassung mit Terminologiekorrekturen und Strukturprüfung, ohne muttersprachliche Prüfung. Build: 0.1.0.3; andere Versions- und Autorendaten bleiben unverändert.


Die Oberfläche enthält 32 nach Code sortierte Gebietsschemas. Neu: ar-SA, he-IL, hi-IN, id-ID, ja-JP, vi-VN und zh-CN. ar/he wählen die jeweiligen Varianten; ältere Aliase iw/in werden he/id zugeordnet. Arabisch und Hebräisch verwenden RTL; Diagramme, Karten und FMC/METAR/OFP-Rohtexte bleiben LTR. Noto-Schriften aus assets/fonts werden mit OFL-Lizenzen und Herkunftsprüfsummen nach bin/fonts und in die Archive übernommen und nur privat geladen, ohne Systeminstallation. Hilfe und Dokumentation bleiben viersprachig. Hinweise zu Übersetzungsfehlern: Translation.de.md. Build 0.1.0.4.
