# Zależności lokalne

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)
[Tłumaczenia interfejsu](../Translation.pl.md)


## Dane użytkownika i natywny podgląd FMC — 0.1.0.8

Ustawienia, baza `flight_data.db`, logi, zrzut awarii, cache mapy i pliki robocze analiz trafiają do `%LocalAppData%\MSFS24-FDR\`. Katalog jest tworzony przed inicjalizacją aplikacji. DLL, tłumaczenia, fonty, pomoc i grafiki `Assets` pozostają przy EXE, więc program nie wymaga prawa zapisu w Program Files. Instalator zostanie dodany osobno.

Przy pierwszym uruchomieniu zamknij poprzednią wersję. Ustawienia, domyślna baza wraz z WAL/SHM oraz logi z katalogu EXE zostaną przeniesione przed otwarciem bazy. Istniejące dane w AppData mają pierwszeństwo: konfliktowe pliki źródłowe pozostają bez zmian i nie są scalane. Przy braku prawa usunięcia starego pliku zachowana zostaje jego kopia w katalogu programu. Przerwana publikacja migracji jest wznawiana z `migration.pending`; aktywny zapis starej bazy blokuje migrację z komunikatem. Przed aktualizacją warto zachować kopię zamkniętej bazy.

WebView2 nie jest używany ani wymagany. OFP wyświetla natywny, tylko do odczytu `TMemo` z Consolas, bez obramowania i własnych pasków przewijania; wysokość wynika z liczby linii, przewija się kontener. Raport AI używa natywnego `TRichEdit` (nagłówki, pogrubienia i listy), bez wykonywania HTML lub skryptów.

Zakładka **FMC/MCDU** pokazuje ostatni zapisany ekran danego urządzenia nie późniejszy od kursora osi czasu. Wybierz urządzenie z listy. Przycisk **Osobne okno** przenosi ten sam frame do okna `bsDialog`; ponowne kliknięcie lub zamknięcie dokuje go ponownie. Zmiana nagrania i czasu działa także po odłączeniu. Tła B737/A320/B777 skalują się proporcjonalnie; kolory, małe znaki i kontrolki są odtwarzane z zapisanych `style_json` i `annunciators_json`. Brak zasilania lub niedostępny ekran nie pokazuje starego tekstu. Starsze nagrania i obecny tekstowy eksport FlightPad dla Fenixa/FBW nie zawierają pełnego formatowania/kontrolek — podgląd nie zgaduje brakujących danych. Obsługa tła B777 nie dodaje sama w sobie rejestratora SDK PMDG 777.



Pliki EXE/DLL nie są przechowywane w Git. Lokalnie `runtime/SimConnect.dll` i `runtime/sqlite3.dll` mogą służyć jako źródła dla skryptu kompilacji, jeżeli nie ma odpowiadających im bibliotek w lokalnych katalogach SDK/projektu pierwotnego.


Skrypty `build.ps1` i `test.ps1` uruchamiaj z katalogu repozytorium. Wyniki trafiają do `bin`, `tests` i `.build`; `.gitignore` pomija lokalne biblioteki, konfiguracje oraz wygenerowane pliki. `bin/settings.example.ini` można skopiować lokalnie jako `bin/settings.ini`, a konta i klucze ustawić w aplikacji.

Pakowanie pełnego wydania przez `tools/package.py` wymaga również lokalnego dodatku EFB w `efb-addon` lub w sąsiednim `MSFS24IFlyEFB`, zgodnie ze skryptem, oraz wyników kompilacji/testów. Archiwum źródłowe wcześniejszego wydania zawierało taki układ zależności. Samo dodanie plików projektu do Git nie pobiera ani nie instaluje bibliotek.

Do uruchomienia wymagany jest też katalog `MSFS2024-FDR.i18n` obok EXE. Skrypt kompilacji i DPROJ/MSBuild kopiują go z `translations/`; tłumaczenia nie są już wbudowane w kod Pascal.
