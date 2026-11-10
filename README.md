[Uwagi o tłumaczeniach](Translation.pl.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

# MSFS24-FDR

Natywny rejestrator i odtwarzacz lotów dla **Microsoft Flight Simulator 2024**, Windows 10/11 Win64. MSFS 2020, FSX i Prepar3D nie są obsługiwane. Przygotowywane wydanie: **0.1.1**; pełna wersja EXE jest widoczna w tytule i O programie.

## Instalacja portable

1. Wypakuj całą paczkę ZIP bez hasła, zachowując podkatalogi.
2. Uruchom `MSFS2024-FDR.exe`. Pozostaw dołączone DLL, fonty, grafiki i `help/*.chm`.
3. Opcjonalny `Optional-Community/MSFS24-FDR-Bridge` skopiuj do Community według [instrukcji](community/Bridge/README.en.md). Sam rejestrator nie jest dodatkiem Community.

`MSFS24-FDR-Setup.exe` jest stubem wyświetlającym informację o pracach. Nie instaluje, nie usuwa i nie aktualizuje. Obie opcje aktualizacji są wyłączone. Aktualizuj ręcznie przy zamkniętym programie, zachowując dane użytkownika. Qt i WebView2 nie są wymagane.

## Nagrania i dane

- Ustawienia, logi, cache i indeks `flight_data.mfzi`: `%LocalAppData%\MSFS24-FDR`.
- Każdy lot jest osobną bazą SQLite `.mfzr`, pod `Recordings\ICAO_typu\ICAO_odlotu\YYYY\MM\...`. Nazwa zawiera datę i czas rozpoczęcia nagrania. Drzewo używa lokalizowanej nazwy miesiąca, z najnowszymi lotami na górze.
- Wyszukiwanie i grupy filtrują bibliotekę. Import obejmuje `.mfzr`, legacy `flight_data.db` i format pierwotnego rejestratora Qt; eksport legacy jednego lotu pomija rozszerzenia FDR.
- Migracja zachowuje źródło; pliki podrzucone do magazynu są wykrywane. Po awarii możliwe jest odzyskanie niepełnego nagrania. Brak pliku nie kasuje metadanych indeksu.
- Podgląd: `MSFS2024-FDR.exe ".\Recordings\lot.mfzr"` otwiera tylko ten plik, bez biblioteki, nagrywania i SimConnect.

Kopiuj zapasowo cały katalog danych przy zamkniętej aplikacji. Nie usuwaj aktywnych plików SQLite WAL/SHM. Zastąpienie osobistego INI plikiem przykładowym kasuje własne ustawienia.

## Możliwości

| Obszar | Funkcje |
|---|---|
| Nagrywanie | Ręczne lub automatyczne po Ready for flight; interwał w ms, zapisany z lotem; subskrypcje zależne od samolotu i silników. |
| Odtwarzanie | Wspólna oś czasu, płynna interpolacja danych ciągłych, pauza/stop, skoki ±30 s, początek/koniec, 0.125–16x. Przełączniki pozostają dyskretne. |
| Dokowanie | Wypinanie zakładek i ramek, dokowanie do okna głównego i pływających hostów, zapis stanu i osobnej geometrii, proporcje paneli. |
| Przyrządy | Six-pack, zegary silników tłokowych/turboprop/jet, B38M PFD/EICAS i A320 PFD/ECAM. Antyaliasing i skalowanie z zachowaniem proporcji. |
| B38M | FD, rekonstruowane FMA i dostępne ILS/baro/STD/IAS-Mach/minima, wiatr i VOR/ADF. Opcjonalne AoA i panel informacji: CPT lewo, FO prawo. |
| A320 | Fenix/FBW PFD, E/WD, 13 stron SD i Recorded, dostępne FD/FMA/ostrzeżenia/STS/minima. |
| FMC/MCDU | Zapisane ekrany i kontrolki, formatowanie i tła, automatyczny typ z lotu, wspólny czas i odłączane okno. |
| Plan i mapa | Ślad rzeczywisty, plan magenta, punkty/ograniczenia i dostępne SID/STAR/podejścia/holdingi; missed approach ciemnoszare; PNG/KML. |
| SimBrief | OFP monospace, mapy pobierane i zapisywane z nagraniem, bez zgłaszania historycznych planów do sieci. |
| ATC i GSX | Zapis FSHud i dostępnego natywnego ATC przez bridge; napis ostatniego komunikatu; usługi GSX i mierzone postępy, także tankowanie. |
| Pogoda | Oddzielne raporty symulatora i aviationweather.gov, METAR/TAF według dostępności, dekodowanie i porównanie. |
| Ghost | Osobny wizualny samolot AI, dobór zainstalowanego AIG/FSLTL lub fallback, wspierane animacje, ±10 s, 5–60 Hz. |
| AI | Codex CLI, Gemini lub Ollama, okna startu/lądowania, raport Markdown i żądanie odpowiedzi w języku aplikacji. |

Dostępność zależy od danych faktycznie zapisanych przez daną wersję samolotu/dodatku. Brak danych nie oznacza zera ani OFF. FMA iFly oraz część ostrzeżeń są rekonstrukcją, nie gwarantowaną kopią awioniki. Fenix/FBW MCDU wymagają kompatybilnego klienta FlightPadFMC; dodatki komercyjne, modele AI i usługi nie są dołączone. AI może się mylić; program służy wyłącznie symulatorom.

## Język i pomoc

32 lokalizacje, domyślnie autodetekcja języka Windows z obsługą wariantów regionalnych i fallbackiem do angielskiego. Zmiana: Narzędzia → Język lub Ustawienia → Ogólne. Dane FMC/METAR/OFP i oznaczenia kokpitu nie są tłumaczone; nowa analiza AI otrzymuje instrukcję języka aplikacji. Zapisane raporty nie zmieniają samoczynnie języka.

F1 otwiera kontekstową pomoc CHM. Podręcznik PL/EN/DE/ES zawiera 62 tematów, drzewo, wyszukiwanie i zrzuty danego języka. Pozostałe języki korzystają z angielskiego. W dystrybucji są wyłącznie CHM. [Źródła i aktualizacja pomocy](help/README.md).

## Budowanie i testy

Delphi 10.2 Win64, Python 3.11+, Windows SDK `rc.exe` i HTML Help Workshop. Inicjalizuj submoduły: `git submodule update --init --recursive`. `VersionU` pochodzi z `src/Common`; biblioteki VCL są w vendor lub wskazywanych katalogach. Zależności runtime: [instrukcja](runtime/README.md).

- `powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1`: kompilacja aplikacji i stuba, zasobów oraz pomocy. Delphi: parametr `-DelphiRoot`, `BDS`, rejestr lub PATH; MSFS SDK: `-SDKRoot`/`MSFS_SDK`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File test.ps1`: grupa testowa i natywne regresje DUnitX. Testy integracji instalatora wymagają odpowiednich repozytoriów obok. Każdy DPR ma DPROJ i wpis w `tests/Tests.groupproj`.
- `tools/capture_help.ps1` odświeża lokalizowane ilustracje po zmianie UI. `python tools/build_help.py --require-chm` sprawdza aktualność i buduje CHM.
- `python tools/package_flightsim.py` przygotowuje pełną paczkę portable bez hasła, przebudowuje pomoc i sprawdza zawartość, CRC, wersje i manifesty EXE. Nie publikuje jej automatycznie.

Przed kompilacją używany jest `Tools/Formatter/Format_MSFS24-FDR.exe /nogui`. RES są produktami RC, nie źródłami Git. Testowe MAP/RSM są czyszczone. [Wyniki i ograniczenia testów](Testy.md), [wydanie](docs/releases/0.1.1.pl.md), [historia](changelog.md).

## Autorstwo i zgłoszenia

Projekt rozpoczął się od [MichaelHsu170/MSFS-Flight-Data-Recorder](https://github.com/MichaelHsu170/MSFS-Flight-Data-Recorder), pierwotnie Qt. Implementacja, interfejs, dane i integracje zostały rozbudowane. Licencja aplikacji: [AGPL-3.0](LICENSE); pozostałe komponenty: [NOTICE](NOTICE.md). Mapy: © OpenStreetMap contributors.

[Zgłoś problem](https://github.com/dj-mafiozo/MSFS2024-FDR/issues), podając pełną wersję, samolot/dodatek, kroki i logi. Nie udostępniaj kluczy API, kont ani osobistych danych bez sprawdzenia.
