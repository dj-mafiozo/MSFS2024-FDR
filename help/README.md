[Tłumaczenia interfejsu](../Translation.pl.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

F1

[Tłumaczenia interfejsu](../Translation.pl.md)


F1 otwiera temat panelu przez HelpContext w DFM. Pomoc PL/EN/DE/ES ma 62 tematów, hierarchiczny spis i wyszukiwanie. Każdy CHM zawiera zrzuty zgodnego języka, wykonane na syntetycznych danych.

Źródła treści: manual.pl.txt, manual.en.txt, manual.de.txt, manual.es.txt. generate_help.py tworzy HTML, HHC/HHP i stabilne aliasy kontekstów. Nie dodawaj paska linków do wszystkich tematów. Standardowe oznaczenia kokpitowe pozostają nieprzetłumaczone.

Po zmianie UI uruchom tools/capture_help.ps1, a następnie python tools/build_help.py --require-chm. Wymagany HTML Help Workshop (HHC_EXE). capture.json sprawdza zgodność obrazów z kodem interfejsu. Pakowanie ponownie kompiluje CHM i odrzuca nieaktualne zrzuty. Dystrybucja: wyłącznie cztery CHM w bin/help, bez źródłowych HTML, obrazów i manifestów. Źródła i zrzuty pozostają w repo.

Kodowanie CHM: źródłowe manual.*.txt pozostają UTF-8. Generator zapisuje wejściowe HTML/HHC/HHP jako Windows-1250 dla PL i Windows-1252 dla EN/DE/ES, z binarnym TOC. Nie przywracaj UTF-8 ani encji liczbowych w etykietach HHC. Kompilator zapisuje nawigację ANSI; build_help.py sprawdza wszystkie etykiety w #STRINGS i obecność #TOCIDX. Wymagany CLI 7-Zip (także z PeaZip), wykrywany automatycznie lub przez SEVENZIP_EXE.

Dane raportu demonstracyjnego: example-analysis.pl/en/de/es.txt. Scenariusz lotu i zrzuty: tests/CaptureHelpScreenshots.dpr; wartości instrumentów: tests/HelpDemoDataU.pas. HelpScreenshotU renderuje RichEdit przez EM_FORMATRANGE i odrzuca pusty obraz tekstu.
