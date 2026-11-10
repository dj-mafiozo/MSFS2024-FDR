[Übersetzungen der Oberfläche](../Translation.de.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

F1

[Übersetzungen der Oberfläche](../Translation.de.md)


F1 öffnet das Panelthema über HelpContext im DFM. PL/EN/DE/ES enthalten 62 Themen, Inhaltsbaum und Volltextsuche. Jedes CHM enthält Screenshots seiner Sprache mit synthetischen Daten.

Quellen: manual.pl.txt, manual.en.txt, manual.de.txt, manual.es.txt. generate_help.py erzeugt HTML, HHC/HHP und stabile Kontextaliase. Keine globale Linkleiste hinzufügen; Cockpitkennungen bleiben unverändert.

Nach UI-Änderungen tools/capture_help.ps1 und python tools/build_help.py --require-chm ausführen. HTML Help Workshop nötig (HHC_EXE). capture.json prüft Bild-/Quellhashes. Paketerstellung kompiliert neu und verwirft veraltete Bilder. Nur vier CHMs aus bin/help verteilen, keine HTML-Dateien, losen Bilder oder Buildmanifeste. Quellen/Bilder bleiben im Repository.

CHM-Kodierung: manual.*.txt bleibt UTF-8. Generierte HTML/HHC/HHP verwenden Windows-1250 für PL und Windows-1252 für EN/DE/ES mit binärem TOC. Keine UTF-8-/Zahlenreferenzen in HHC-Bezeichnungen verwenden. build_help.py prüft alle ANSI-Titel in #STRINGS und #TOCIDX. 7-Zip CLI (auch in PeaZip) wird automatisch oder über SEVENZIP_EXE gefunden.

Beispielberichte: example-analysis.pl/en/de/es.txt. Flug-/Bildszenario: tests/CaptureHelpScreenshots.dpr; Instrumentwerte: tests/HelpDemoDataU.pas. HelpScreenshotU rendert RichEdit über EM_FORMATRANGE und weist leere Textbilder zurück.
