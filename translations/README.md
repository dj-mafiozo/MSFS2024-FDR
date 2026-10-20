# Tłumaczenia PL / EN / DE / ES

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


Jedynym źródłem tłumaczeń jest `MSFS2024-FDR.i18n` w tym katalogu. To niezaszyfrowany, nieskompresowany katalog XML w formacie zainstalowanego pakietu i18n. Można edytować go w edytorze tego pakietu albo edytorze tekstowym UTF-8. Nie ma już równoległego katalogu JSON ani generowanego kodu Pascal z tekstami.

Każda definicja ma tłumaczenia `pl-PL`, `en-US`, `de-DE`, `es-ES`. Domyślny jest polski. Wybór w Narzędzia → Język lub Ustawienia → Ogólne zapisuje `[ui] language=...`. Anulowanie ustawień nie zmienia języka. Nazwy języków są podane w ich własnych językach.

Domena `Application` zawiera literały wywoływane przez `Tr(...)`. ID literałów wylicza `GetStringIdentifier` z pakietu i18n; zachowaj istniejące ID i używaj edytora pakietu przy dodawaniu literałów. Pakiet używa starszego wariantu MD5, więc nie należy bezwarunkowo zastępować go standardowym hashem. Domeny formularzy to nazwa klasy bez T, np. `frmMain`, `fraSimBrief`. ID właściwości to `.Caption`, `aSettings.Caption`, `cbProvider.Items[0]`. Teksty akcji są źródłem podpisów przycisków i pozycji menu. Tytuł raportu startu/lądowania jest wyznaczany w kodzie i aktualizowany po zmianie języka.

Uruchom `python tools/check_translations.py`. Kontrola sprawdza cztery języki, placeholdery Format, kodowanie i aktualność nazw komponentów DFM. Kompilacja skryptem oraz MSBuild kopiuje katalog obok EXE jako `bin/MSFS2024-FDR.i18n`. Do wydania programu należy dołączyć ten plik. Zmiana tekstów nie wymaga ponownej kompilacji EXE; jest odczytywana przy kolejnym uruchomieniu. Binarne testy/deweloperskie mogą też odczytać `../translations/MSFS2024-FDR.i18n`, jeśli obok EXE nie ma kopii. Brak obu plików jest błędem wdrożenia.

Nie tłumacz raw FMC/METAR/OFP, danych użytkownika, identyfikatorów SimVar/L-var, SQL ani kluczy API/JSON. Zapytania i raporty AI pozostają po polsku zgodnie z dotychczasowym wymaganiem. Licencja i zależność pakietu: `vendor/i18n`, `support/i18n/LICENSE`.

## Czytelne nazwy parametrów

Wykresy, lista wyboru, kolejność i inspektor wartości pokazują opisy z jednostkami, np. `Wysokość samolotu [ft]` i `Prędkość N1 — silnik 2 [%]`. Nazwy zmieniają język razem z interfejsem. Wyszukiwanie działa po opisie i surowym identyfikatorze; podpowiedź pokazuje oba.

Opisy są w domenach `Parameters` (pełne nazwy) i `ParameterWords` (słownik nazw SDK) pliku MSFS2024-FDR.i18n. Edytuj Translation; Value i ID zachowują stabilny identyfikator.
