# Pochodzenie i składniki zewnętrzne

[English](NOTICE.en.md)

Pierwsza implementacja MSFS2024-FDR bazowała na dostarczonym projekcie MSFS-Flight-Data-Recorder-master, napisanym w Qt. Od tego czasu architektura, nagrywanie, interfejs, integracje samolotów, baza i analiza zostały rozlegle przebudowane, poprawione i rozszerzone. Obecna aplikacja jest znacząco inną implementacją, z zachowaniem informacji o pierwowzorze i pochodzeniu wykorzystanych elementów.

Pierwotny projekt: GNU Affero General Public License v3; tekst licencji w LICENSE. Katalogi telemetrii/zdarzeń i fundamenty schematu SQLite pochodzą z jego makr/definicji. Qt/QML/Qt Graphs/Qt WebEngine/Qt WebChannel nie są używane ani dystrybuowane. Aplikacja korzysta z Delphi VCL/FireDAC, SQLite i Microsoft SimConnect. Mapa zachowuje atrybucję OpenStreetMap. Raporty używają WebView4Delphi i Microsoft WebView2; zachowaj licencje tych zależności przy dystrybucji.

Katalog iFly: 2411 pól, pack(8), 3240 bajtów, dostarczony oficjalny SDK 1.5 SDK_Defines.h. SHA-256 nagłówka: 0de480c86c173b0e69a79a406bfe4d90671a5417e0d88a2a9779a36fc0de02d4. Nie dołączamy binariów iFly ani pełnego SDK.

Katalog Fenix pochodzi z nazw parametrów szablonów dostarczonego Cockpit_Behavior.xml; nie jest oficjalnym SDK Fenixa. Pełny XML i binaria samolotu nie są dołączane.

FBW A32NX wykorzystuje nazwy i metadane dostarczonej dokumentacji Flight Deck API oraz fakty o gotowości i jednostkach prędkości z oficjalnego a320-simvars.md. Pełna dokumentacja, pliki samolotu i jego binaria nie są dołączane.

PMDG NG3 wykorzystuje nazwy pól, layout, stałe i opisy z dostarczonego PMDG_NG3_SDK.h, Copyright (c) 2025 Precision Manuals Development Group. Pełny zastrzeżony nagłówek i binaria nie są dołączane. Odczytywane są wyłącznie obszary Client Data danych/CDU.

Lokalizacja wykorzystuje pakiet i18n, Copyright (C) 2010–2014 Kambiz Khojasteh, licencja MIT. Kopia w support/i18n/LICENSE. Pakiet jest linkowany do EXE; źródła zależności w paczce źródłowej zachowują jego licencję. FlightPadFMC ma odrębną licencję MIT w support/flightpad/LICENSE.md. Własne pliki *.en.md są angielskimi wersjami dokumentacji projektu, nie zamiennikami tekstów licencji.

Pierwowzór: [MichaelHsu170/MSFS-Flight-Data-Recorder](https://github.com/MichaelHsu170/MSFS-Flight-Data-Recorder), autor MichaelHsu170, AGPL-3.0. Punktem wyjścia była dostarczona wersja Qt5; nie oznacza to wersji Qt używanej obecnie przez upstream.
