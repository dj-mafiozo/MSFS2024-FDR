# Pomoc CHM i F1

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

F1 lub Pomoc → Pomoc programu otwiera temat aktywnego widoku. Pomoc zawiera wprowadzenie, mapę, wykresy, analizę, ustawienia i informacje o programie. Język PL/EN/DE/ES odpowiada językowi interfejsu.

Budowanie: `python tools/build_help.py --require-chm`. Wymagany HTML Help Workshop; alternatywną ścieżkę do hhc.exe podaje zmienna HHC_EXE. Pełny build.ps1 również buduje pomoc. Bez kompilatora dostępny jest lokalny HTML; gdy brakuje CHM, F1 korzysta z HTML. Pliki wynikowe: bin/help. Do dystrybucji kopiuj cały katalog help razem z EXE.

Źródła tematów: pl/, en/, de/, es/. HHP/HHC i contexts.h definiują identyfikatory 100–600. Spisy HHC są kodowane w Windows-1250/1252 wymaganym przez stary kompilator; treść HTML jest UTF-8.
