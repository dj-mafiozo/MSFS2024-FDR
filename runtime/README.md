# Zależności lokalne

[Tłumaczenia interfejsu](../Translation.pl.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


Pliki EXE/DLL nie są przechowywane w Git. Lokalnie `runtime/SimConnect.dll` i `runtime/sqlite3.dll` mogą służyć jako źródła dla skryptu kompilacji, jeżeli nie ma odpowiadających im bibliotek w lokalnych katalogach SDK/projektu pierwotnego.

Do kompilacji potrzebne są Delphi 10.2 z VCL/FireDAC oraz WebView4Delphi. W samodzielnym katalogu repozytorium umieść lokalną zależność WebView4Delphi w `vendor/WebView4Delphi-main` (źródła oraz `bin64/WebView2Loader.dll`). Skrypty obsługują tę ścieżkę jako zastępstwo sąsiedniego projektu FSHudPanel. Zachowaj licencję zależności. WebView2 Runtime jest potrzebny do raportów HTML.

Skrypty `build.ps1` i `test.ps1` uruchamiaj z katalogu repozytorium. Wyniki trafiają do `bin`, `tests` i `.build`; `.gitignore` pomija lokalne biblioteki, konfiguracje oraz wygenerowane pliki. `bin/settings.example.ini` można skopiować lokalnie jako `bin/settings.ini`, a konta i klucze ustawić w aplikacji.

Pakowanie pełnego wydania przez `tools/package.py` wymaga również lokalnego dodatku EFB w `efb-addon` lub w sąsiednim `MSFS24IFlyEFB`, zgodnie ze skryptem, oraz wyników kompilacji/testów. Archiwum źródłowe wcześniejszego wydania zawierało taki układ zależności. Samo dodanie plików projektu do Git nie pobiera ani nie instaluje bibliotek.

Do uruchomienia wymagany jest też katalog `MSFS2024-FDR.i18n` obok EXE. Skrypt kompilacji i DPROJ/MSBuild kopiują go z `translations/`; tłumaczenia nie są już wbudowane w kod Pascal.
