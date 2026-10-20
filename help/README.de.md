# CHM-Hilfe und F1

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

F1 oder Hilfe → Programmhilfe öffnet das Thema der aktiven Ansicht. Einstieg, Karte, Diagramme, Analyse, Einstellungen und Programminformationen sind enthalten. PL/EN/DE/ES folgen der Oberflächensprache.

Erstellen: `python tools/build_help.py --require-chm`. HTML Help Workshop erforderlich; HHC_EXE überschreibt den Pfad zu hhc.exe. build.ps1 erstellt ebenfalls die Hilfe. Ohne Compiler steht lokales HTML bereit; bei fehlender CHM öffnet F1 HTML. Ausgabe: bin/help. Das gesamte help-Verzeichnis neben der EXE verteilen.

Themenquellen: pl/, en/, de/, es/. HHP/HHC und contexts.h definieren IDs 100–600. Inhaltsverzeichnisse nutzen Windows-1250/1252 für den alten Compiler; HTML-Seiten sind UTF-8.
