# Tłumaczenia interfejsu

[Tłumaczenia interfejsu](../Translation.pl.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


Jedynym źródłem tłumaczeń jest `MSFS2024-FDR.i18n` w tym katalogu. To niezaszyfrowany, nieskompresowany katalog XML w formacie zainstalowanego pakietu i18n. Można edytować go w edytorze tego pakietu albo edytorze tekstowym UTF-8. Nie ma już równoległego katalogu JSON ani generowanego kodu Pascal z tekstami.

Każda definicja zawiera 25 lokalizacji z rejestru LocalizationU. Język źródłowy to polski; przy pierwszym uruchomieniu wybór jest automatyczny. Wybór w Narzędzia → Język lub Ustawienia → Ogólne zapisuje `[ui] language=...`. Anulowanie ustawień nie zmienia języka. Nazwy języków są podane w ich własnych językach.

Domena `Application` zawiera literały wywoływane przez `Tr(...)`. ID literałów wylicza `GetStringIdentifier` z pakietu i18n; zachowaj istniejące ID i używaj edytora pakietu przy dodawaniu literałów. Pakiet używa starszego wariantu MD5, więc nie należy bezwarunkowo zastępować go standardowym hashem. Domeny formularzy to nazwa klasy bez T, np. `frmMain`, `fraSimBrief`. ID właściwości to `.Caption`, `aSettings.Caption`, `cbProvider.Items[0]`. Teksty akcji są źródłem podpisów przycisków i pozycji menu. Tytuł raportu startu/lądowania jest wyznaczany w kodzie i aktualizowany po zmianie języka.

Uruchom `python tools/check_translations.py`. Kontrola sprawdza wszystkie zarejestrowane lokalizacje, placeholdery Format, kodowanie i aktualność nazw komponentów DFM. Kompilacja skryptem oraz MSBuild kopiuje katalog obok EXE jako `bin/MSFS2024-FDR.i18n`. Do wydania programu należy dołączyć ten plik. Zmiana tekstów nie wymaga ponownej kompilacji EXE; jest odczytywana przy kolejnym uruchomieniu. Binarne testy/deweloperskie mogą też odczytać `../translations/MSFS2024-FDR.i18n`, jeśli obok EXE nie ma kopii. Brak obu plików jest błędem wdrożenia.

Nie tłumacz raw FMC/METAR/OFP, danych użytkownika, identyfikatorów SimVar/L-var, SQL ani kluczy API/JSON. Zapytania i raporty AI pozostają po polsku zgodnie z dotychczasowym wymaganiem. Licencja i zależność pakietu: `vendor/i18n`, `support/i18n/LICENSE`.

## Czytelne nazwy parametrów

Wykresy, lista wyboru, kolejność i inspektor wartości pokazują opisy z jednostkami, np. `Wysokość samolotu [ft]` i `Prędkość N1 — silnik 2 [%]`. Nazwy zmieniają język razem z interfejsem. Wyszukiwanie działa po opisie i surowym identyfikatorze; podpowiedź pokazuje oba.

Opisy są w domenach `Parameters` (pełne nazwy) i `ParameterWords` (słownik nazw SDK) pliku MSFS2024-FDR.i18n. Edytuj Translation; Value i ID zachowują stabilny identyfikator.


Domyślny wybór języka to auto. Aplikacja odczytuje język interfejsu użytkownika Windows, niezależnie od ustawień liczb/dat. Warianty regionalne są mapowane na PL/EN/DE/ES/FR/RU/TR/IT/PT; inne języki przechodzą na angielski. Wybór auto jest zapamiętywany i rozwiązywany ponownie po uruchomieniu. Istniejący jawny wybór języka pozostaje zachowany. Menu i Ustawienia obsługują automatyczny wybór oraz dziewięć języków. Katalog obejmuje nowe etykiety zmienionego GUI. Pomoc pozostaje w czterech dotychczasowych językach; dla nowych używana jest angielska. Nowe tłumaczenia są pierwszą wersją przygotowaną lokalnie przez Qwen3 z korektami terminologii i kontrolą struktury; nie są po przeglądzie native speakerów. VersionU czyta liczbowy i tekstowy VersionInfo z EXE z uwzględnieniem tablic językowych. O programie pokazuje rzeczywistą wersję, ProductName i copyright. Wspólny Build wynosi 2 (0.1.0.2); pozostałe numery i dane autora zachowano. tools/bump_build.py zwiększa tylko Build raz na logiczną zmianę; check_version.py kontroluje brak nadpisań konfiguracji. CLI buduje przez MSBuild, aby wygenerować aktualne zasoby wersji.


Rozszerzenie lokalizacji: interfejs obsługuje 25 lokalizacji. Dodano en-GB, fr-CA, pt-BR, de-AT, de-CH, be-BY, el-GR, uk-UA, hr-HR, cs-CZ, da-DK, nl-NL, fi-FI, nb-NO, sk-SK i sv-SE. Warianty regionalne są zapisywane osobno; be oznacza białoruski, a no/nb/nn wybierają dostępny norweski Bokmål. Nie jest to osobne tłumaczenie Nynorsk. Szwajcarski niemiecki używa ss zamiast ß. Detekcja automatyczna używa języka interfejsu Windows, bez zmiany formatów liczbowych. Pomoc pozostaje w PL/EN/DE/ES, z odpowiednim językiem bazowym lub angielskim jako zastępczym. Nowe tłumaczenia to pierwsza wersja z korektami terminologii i kontrolą struktury; nie przeszły przeglądu native speakera. Build: 0.1.0.3, pozostałe dane wersji i autora bez zmian.


Interfejs zawiera 32 lokalizacje, sortowane według kodu. Nowe: ar-SA, he-IL, hi-IN, id-ID, ja-JP, vi-VN i zh-CN. Skróty ar/he wybierają odpowiednie warianty; iw/in obsługiwane są jako starsze aliasy he/id. Arabski i hebrajski używają układu RTL; wykresy, mapy i surowe teksty FMC/METAR/OFP zachowują LTR. Fonty Noto w assets/fonts są dołączane do bin/fonts i paczek, ładowane prywatnie bez instalacji systemowej, razem z licencjami OFL i manifestem pochodzenia. Pomoc i dokumentacja pozostają w czterech językach. Zasady zgłaszania błędów tłumaczeń: Translation.pl.md. Build 0.1.0.4.
