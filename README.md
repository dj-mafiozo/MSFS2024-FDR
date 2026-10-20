# MSFS2024-FDR — Delphi 10.2 VCL Win64

[Tłumaczenia interfejsu](Translation.pl.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

## Mapa i wykresy w osobnych oknach

Akcje `aMapWindow` i `aGraphWindow` oraz odpowiadające im przyciski/menu przenoszą widoki do niezależnych, skalowalnych okien. Cała dotychczasowa zawartość `MapPanel` i `GraphPanel` jest w ramkach `fraMapU` i `fraGraphU`; układ pozostał zachowany. Przenoszona jest ta sama instancja, więc zmiana nagrania, kursor, zakres wykresów i narzędzia pozostają zsynchronizowane. Wydzielony panel znika z głównego okna. Zamknięcie okna lub ponowne użycie akcji przywraca ramkę; można wydzielić oba widoki jednocześnie. Wysokość zadokowanej mapy pozostaje zachowana.

`frmChartsConfigure` znów ma własne `ImageList` i `ActionList`. Przesuwanie, ukrywanie, OK i Anuluj działają przez akcje z aktualizacją dostępności; ikony są w DFM i nie zależą od listy głównego formularza. Anuluj nie nadpisuje konfiguracji. Wszystkie własne README i Testy mają wersję polską bez sufiksu oraz `.en.md`, `.de.md`, `.es.md`. Sprawdzenie: `python tools/check_documentation.py`.


Konfiguracja parametrów i kolejności wykresów jest teraz w osobnym oknie **Ustaw wykresy** (ikona suwaków przy wykresach). Wyszukiwanie zachowuje zaznaczenia, kolejność zmienia się strzałkami, a kosz ukrywa wykres. OK stosuje i zapisuje zmiany, Anuluj pozostawia dotychczasowy wybór. Zachowane są też preferencje parametrów chwilowo niedostępnych dla innego samolotu. Zniknęła stara wysokość panelu parametrów; szerokości paneli i wysokość mapy nadal są zapamiętywane.

Ikony są wbudowane w DFM; do uruchomienia nie trzeba katalogu Icons. Odtwarzanie zasobu z oryginałów: `powershell -ExecutionPolicy Bypass -File tools/rebuild_toolbar_images.ps1`. Zachowany jest układ ręcznie przebudowanego interfejsu i nazwa projektu `MSFS2024-FDR`. Menu języka obsługuje PL/EN/DE/ES. Trzy listy ikon (34 w oknie głównym, 6 w SimBrief i 3 w konfiguracji wykresów) zachowują przezroczystość alfa.



## Interfejs i organizacja projektu

Domyślny język to polski. Menu **Narzędzia → Język** i okno **Ustawienia** pozwalają wybrać Polski, English, Deutsch lub Español; ustawienie zapisuje się w `[ui] language=pl-PL` / `en-US` / `de-DE` / `es-ES`. Menu główne udostępnia także bazę, import/eksport, nagrywanie, widok i informacje o locie. Dawny przycisk „Ustawienia AI” nazywa się teraz „Ustawienia”. Tłumaczenia przez zainstalowany pakiet i18n obejmują formularze, menu, dialogi, komunikaty oraz sekcje SimBrief. Raw FMC/METAR/OFP, identyfikatory telemetrii i dane nie są tłumaczone; raporty AI pozostają po polsku zgodnie z dotychczasowym wymaganiem.

Jedynym katalogiem tłumaczeń jest `translations/MSFS2024-FDR.i18n`, kopiowany obok EXE przy kompilacji skryptem lub MSBuild. Nie wymaga generowania kodu Pascal. Instrukcja: [translations/README.md](translations/README.md). Kompilacja szuka i18n w sąsiednim repozytorium lub `vendor/i18n/Packages`; można podać `-I18nRoot` / właściwość MSBuild I18nRoot. DCU i pochodne trafiają do `.build/<Platform>/<Config>`, a testy do osobnych podkatalogów `Tests`. Ustawienia mają zakładki Ogólne, Analiza i Silniki AI (Codex/Gemini/Ollama).

Unity mają nazwy `NazwaU.pas`, formularze `frmNazwaU.pas/.dfm`. `src` dzieli się na `core`, `data`, `recording`, `simconnect`, `telemetry`, `aircraft/{ifly,fenix,fbw,pmdg}`, `fmc`, `flightplan`, `weather`, `analysis`, `visualization`, `forms`, `frames` i `i18n`. Wszystkie 59 unitów są jawnie wpisane w DPR/DPROJ. FormActions.inc znajduje się w `forms/includes`. Usunięto prefiks Native z nazw własnych unitów/klas; typy platformy NativeInt/NativeUInt pozostają standardowymi typami Delphi.



Natywny rejestrator i analizator lotów dla Microsoft Flight Simulator 2024, rozwijany w Delphi 10.2 z interfejsem VCL. Repozytorium jest obecnie prywatne; w przyszłości może zostać udostępnione publicznie.

Pierwsza implementacja powstała na bazie projektu **MSFS-Flight-Data-Recorder**, napisanego w Qt. Od tego czasu architektura, obsługa nagrywania, interfejs, integracje z samolotami i analiza danych zostały rozlegle przebudowane, poprawione i rozbudowane. Obecna aplikacja jest znacząco innym rozwiązaniem, z zachowanym pochodzeniem części katalogów telemetrii/zdarzeń oraz fundamentów formatu bazy. Informacje o pochodzeniu i składnikach zewnętrznych pozostają w [NOTICE.md](NOTICE.md); tekst licencji AGPL-3.0 jest zachowany w repozytorium.

Katalog roboczy repozytorium: `C:\Users\Mateusz\Documents\GIT\MSFS2024-FDR`. Git nie przechowuje lokalnych baz, konfiguracji z kluczami/kontami, logów, wyników kompilacji ani bibliotek runtime. Przykładowa konfiguracja bez danych kont znajduje się w `bin/settings.example.ini`. Zależności lokalne opisuje `runtime/README.md`. Propozycja opisu pierwszego importu aplikacji znajduje się w [INITIAL_COMMIT.md](INITIAL_COMMIT.md).


Uruchom `bin/MSFS2024-FDR.exe`. Jest to osobny port dostarczonego projektu `MSFS-Flight-Data-Recorder-master`. Formularze są w DFM, logika w Pascalu, wykresy i mapa są kontrolkami VCL rysowanymi przez GDI. Program nie uzywa Qt. Mapa i wykresy pozostaja VCL/GDI; raport Markdown korzysta z WebView2.

Obok EXE należy umieścić `SimConnect.dll`, `sqlite3.dll`, `WebView2Loader.dll`, katalog `MSFS2024-FDR.i18n` i konfigurację. Baza `flight_data.db` zawiera format tabel oryginału: `trips`, `trip_data`, `trip_engine_data`, `trip_events`, `trip_liftoffs`, `trip_touchdowns`, `trip_groups`. Ta aplikacja jest niezależna od wcześniejszego rejestratora iFly/Firebird.

## Nagrywanie

Rejestrator działa w osobnym wątku z własnym połączeniem FireDAC. Odczyt SimConnect/SDK, przetwarzanie danych i zapis nie wykonują się w timerze VCL. Start/Stop, import PLN i żądanie METAR są kolejkowane; stan i błędy wracają do formularza jako kopia danych. SQLite używa WAL i oddzielnych połączeń dla zapisu oraz przeglądania. Zamknięcie aplikacji lub zmiana bazy czeka na zakończenie rejestratora. Podczas działania bazy pliki `-wal` i `-shm` należą do SQLite; nie należy ich usuwać ani kopiować samego pliku `.db` jako kopii aktywnej bazy.

Odbiór SimConnect opróżnia kolejkę przed kosztownym przetwarzaniem: zachowuje najnowszą próbkę oraz przejścia ziemia–powietrze. Nie zapisuje po kolei wszystkich zaległych ramek preflight. Log `SimConnect telemetry` podaje liczbę odebranych, przekazanych i scalonych ramek. Nieznana nawierzchnia (`surface_type=255`) nie zatrzymuje nagrywania w powietrzu. Interwał 250 ms jest celem, a rzeczywista częstotliwość zależy od czasu odczytu i zapisu.

Parser FMC odczytuje wybrane V1/VR/V2 z prawej kolumny TAKEOFF REF, oddzielnie od QRH. Na APPROACH REF źródłem wybranego VREF jest FLAP/SPD; korekta wiatru pozostaje osobną wartością. Surowe ekrany starych nagrań są ponownie parsowane podczas analizy. Istniejący raport AI należy wygenerować ponownie, aby uwzględnił poprawkę.

Okno **Informacje o nagraniu** pokazuje także dane referencyjne FMC sprzed każdego startu i lądowania: V-speeds, klapy, limity N1, assumed temperature/OAT, CG, trim oraz aktywne i wybrane tryby ciągu. Parser PERF INIT odczytuje również masy i paliwo w jednostkach ekranu, CI, wysokości i dostępne pola pogody planowanej. N1 LIMIT rozróżnia ACT/SEL po stronie startowej i climb, derate oraz bump. Szczegóły pól: [Boeing-performance.md](support/fmc/Boeing-performance.md).

Cyfry wyświetlaczy iFly są składane w parametry takie jak `Flight_Altitude_Indicator_Value`, `ADF_num_Value[1]` i `Fuel_Quantity_Indicator_Value[0]`. Tekst FMC, spakowane kolory/mała czcionka, sformatowany HTML i kontrolki FAIL/MSG/EXEC/CALL/OFST są zapisywane osobno w tabeli ekranów. Nie są powielane w nowych snapshotach ogólnych SDK. Szczegóły i ograniczenia: [IFly-display-storage.md](support/fmc/IFly-display-storage.md).

Program sam łączy się z MSFS24. Automatyczne nagranie zaczyna się po wczytaniu lotu i otrzymaniu pierwszej poprawnej próbki, również z wyłączonymi silnikami. Trwa do zakończenia lotu, powrotu do menu, zmiany samolotu lub rozłączenia. Wyłączenie silników nie kończy nagrania: obejmuje ono boarding i deboarding GSX. Nagrywaj/Zatrzymaj pozwalają sterować ręcznie; Zatrzymaj wyłącza automatykę. Pauza nie kończy tripu i nie zapisuje próbek. Interwał jest w milisekundach, domyślnie 500.

Jeżeli SimConnect udostępnia SubscribeToFlowEvent, używane są zdarzenia cyklu lotu. Dostarczona biblioteka nie eksportuje tej funkcji, dlatego działa zgodnościowy odczyt FlightLoaded oraz kontrola stanu co 10 sekund. Sam SimStop nie oznacza końca lotu. Rozpoznanie końca na żywo wymaga jeszcze sprawdzenia w pełnym locie.

Z oryginalnych makr wygenerowano 709 definicji SimConnect: 110 kolumn liczbowych, 70 pakowanych stanów logicznych, 32 wartości każdego z maksymalnie 16 silników oraz metadane/czasy. Są to okresowe pełne próbki, zgodnie z oryginałem; nie schemat delta wcześniejszego FDR iFly.

Program obserwuje 84 zdarzenia kokpitu i nie wysyła ani nie maskuje poleceń. Filtr zachowuje dwa progi oryginału: 3 powtórzenia w krótkich odstępach 500 ms blokują serię, a 3 wolniejsze wystąpienia w 5 s są wycofywane. FLAPS_INCR/DECR pomijają filtr. Kontakty powietrze/ziemia zapisują starty i lądowania, w tym kolejne kontakty w tym samym locie.

Lookup lotnisk/pasów używa natywnych funkcji facilities SimConnect, kolejki kontaktów, pięciu najbliższych kandydatów i danych progów przesuniętych. Wartości kontaktu są zapisywane przed zakończeniem lookupu. Geometria pasa korzysta z lokalnej projekcji metrycznej i prawdziwego kursu samolotu. Nie jest identycznym przepisaniem bardziej rozbudowanego algorytmu oryginału wykorzystującego także zamrożoną trajektorię podejścia; rozpoznanie pasa, szczególnie przy bocznym wietrze i złożonych lotniskach, wymaga sprawdzenia w MSFS. Brak dopasowania pozostawia niewypełnione pola; nie podstawia wymyślonego lotniska.

## Przeglądanie

- Otworz lot dwuklikiem w historii. Wybierz parametry bez limitu 8 i Pokaż wybrane wykresy. Kursor myszy na wykresie lub suwak czasu synchronizuje wykresy, marker mapy i inspektor wartości. Wartości silników niedostępne w starej bazie pozostają puste.
- Zakładki inspektora pokazują wartości, zdarzenia oraz starty/lądowania. Markery kontaktów na mapie są zielone dla startu, czerwone dla lądowania.
- Mapa wszystkich tras pokazuje odcinki departure–destination, z kolorami według grup. Grupę można utworzyć, przemianować, przypisać i usunąć bez usuwania lotów.
- Kółko myszy zmienia zoom mapy, przeciąganie przesuwa mapę. Mapa online OSM jest opcjonalna; bez niej pozostają trasa i marker. Pobierane są tylko kafelki bieżącego widoku, z dyskowym cache przez co najmniej 7 dni i identyfikującym User-Agent. Dane lotu nie są wysyłane do OSM. [Zasady kafelków](https://operations.osmfoundation.org/policies/tiles/).
- Eksport KML zapisuje trajektorię do Google Earth z wysokością przeliczoną ze stóp na metry. Zapis mapy PNG obejmuje widok i atrybucję.
- Odśwież odczytuje późniejsze zapisane próbki bieżącego lotu. Wczytywanie dużej historii/lotu działa obecnie w wątku UI i może chwilowo blokować okno.

## AI i konfiguracja

Analiza AI jest uruchamiana przyciskiem dla ostatniego startu/ladowania wybranego lotu. Dostawce Codex/Gemini i model wybiera sie w Ustawienia. Kontekst z bazy jest wysylany do wybranego dostawcy; wynik jest zapisywany w analysis_report i wyswietlany jako Markdown. Shift+klik wymusza nowy raport. Testy nie wykonuja rzeczywistych zapytan do chmury.

INI zachowuje interwał, automatykę, szerokości paneli oraz wybrane wykresy. `msfs_fdr_debug.log` zapisuje stan aplikacji i błędy; poprzedni log ma rozszerzenie `.old`. `[logging] verbose` obsługuje FATAL/WARNING/INFO/TRACE/PROFILE jako limit poziomu.

## Istniejące bazy Qt

Otwórz bazę przyciskiem Otwórz bazę. Nie uruchamiaj obu rejestratorów na tym samym pliku podczas nagrywania. Aktualny schemat jest odczytywany bez konwersji formatu. Brakujące kolumny są dodawane. Starszy schemat próbek bez klucza PRIMARY KEY jest przebudowywany transakcyjnie; przenoszone są istniejące kolumny silników 1/2, ich bity oraz stare tablice float engine_speed/load dla maksymalnie 4 silników. Brakujące wartości nie są wymyślane. Korekta starego znaku offsetu lokalnego jest wykonywana raz według `PRAGMA user_version`.

Przed przebudową/korektą tworzona jest spójna kopia przez SQLite backup API, z nazwą `.before-native-<GUID>.db`. Kopia może już zawierać dodane nullable kolumny, ale zachowuje dane sprzed przebudowy i korekty czasu. Duże migracje są obecnie synchroniczne; okno nie ma procentowego postępu Qt.

## Budowanie i sprawdzenie

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\test.ps1
```

Delphi 10.2 z FireDAC i MSFS SDK. Projekt IDE: `src/MSFS2024-FDR.dpr`. Regeneracja katalogu z oryginalnego drzewa: `python tools/generate_catalog.py`; gotowy `telemetry/TelemetryCatalogU.pas` jest dołączony, więc zwykłe budowanie nie wymaga generatora. Licencja portu i źródła pochodzenia są w LICENSE.txt/NOTICE.md.

Sprawdzono prawdziwe SQLite, automatyczne granice lotu z pakietami testowymi, wartości silników, bity, kontakty, timezone, KML, kasowanie, filtr powtórzeń, geometrię pasa, migrację i jej kopię/idempotencję oraz rzeczywisty formularz VCL i synchronizację czasu. Test filtra sprawdzono także mutacją progu (zmiana 3→4 powoduje błąd oczekiwanego zachowania). Zrzut okna testowego: `tests/native-preview.png`. Nie potwierdzono jeszcze całego lotu na żywym SimConnect, lookupów facilities w rzeczywistym scenerium ani odpowiedzi AI z kluczem. Brak testów oznacza brak potwierdzenia zgodności wszystkich przypadków brzegowych oryginału.


Recording/crash findings: [DIAGNOSIS.md](DIAGNOSIS.md).
The log now records trip stop reasons. Unhandled Windows exceptions attempt
to write `msfs_fdr_debug.dmp` next to the executable.


Live EFB route capture uses `GET_EFB_ROUTE`; no saved PLN file is required.
PLN files are optional explicit exports for later import.
Details: [FLIGHT-PLANS.md](FLIGHT-PLANS.md).


## Analizy AI po polsku

Domyslnym dostawca nowych analiz jest Codex CLI. Otworz **Ustawienia**,
wybierz Codex lub Gemini, opcjonalnie wpisz model oraz limit czasu Codex.
Pusta sciezka oznacza wykrywanie `codex.exe` w PATH lub standardowej instalacji npm.
Mozesz tez wskazac natywny EXE recznie (nie plik .cmd/.ps1).
Przed pierwszym uzyciem wykonaj `codex login` na tym samym koncie Windows.
Aplikacja korzysta ze zwyklego uwierzytelnienia CLI; nie kopiuje tokenow logowania.

Zapytanie zawiera polskie instrukcje, jednostki i dane wybranego kontaktu z pasem.
Model ma odpowiedziec po polsku, wskazac niepewnosci i nie wymyslac brakujacych
limitow samolotu. Raport wraca do obecnego okna i zapisuje sie w bazie.
Istniejace zapisane raporty pozostaja dostepne; **Shift + klik** przycisku analizy
wymusza nowy raport, np. po zmianie dostawcy lub dla starego raportu po angielsku.

Codex dziala jako ukryty proces w tle, z promptem i odpowiedzia UTF-8, osobnym
katalogiem roboczym, sandboxem read-only, limitem czasu i anulowaniem przy zamknieciu.
Dane analizy sa przekazywane do wybranego dostawcy AI; analiza nie jest lokalnym modelem.
Test VerifyAnalysis sprawdza transport przez podstawiony proces bez zapytan do chmury.
Rzeczywista analiza wymaga dzialajacego logowania i dostepnych limitow konta.

```ini
[ai]
provider=codex
codex_path=
codex_model=
timeout_seconds=180
gemini_api_key=
model=gemma-4-31b-it
```

Dokumentacja Codex: https://learn.chatgpt.com/docs/non-interactive-mode


Analiza startu/ladowania otrzymuje teraz serie probek: domyslnie 60 sekund przed
zdarzeniem i 30 sekund po nim (zmieniane w Ustawienia). Obejmuje AGL, IAS,
VS, g, pochylenie, kursy true/magnetic, track, mase, konfiguracje, stan na ziemi
oraz N1 i przepustnice. Kontekst podaje liczbe probek, rzeczywisty zakres, luki,
zaobserwowane maksimum g i pobliskie kontakty z pasem. Nie interpoluje brakow.
Przy analizie tuz po zdarzeniu ostatnie sekundy nie sa jeszcze dostepne: poczekaj
30 sekund i uzyj Shift+klik. Rzadki zapis moze pominac fizyczny szczyt g.
Surowy pitch SimConnect jest ujemny dla nosa w gore; dodatkowe pitch_nose_up_deg
odwraca znak dla czytelnosci. Definicje odleglosci, skal i odniesien kursow sa
przekazywane modelowi. Dotychczasowe dane bazy nie sa zmieniane.


Kontekst AI zawiera tez pogode z zapisanych probek SimConnect: wiatr, temperature
(C), widzialnosc (m), lokalne cisnienie przy samolocie (inHg) i cisnienie na
poziomie morza (mb/hPa). Sekcja weather wskazuje probke najblizsza zdarzeniu wraz
z przesunieciem czasu; przebieg pozostaje w samples. Nie jest to METAR/ATIS.
Punkt rosy, opady, chmury i porywy nie sa obecnie rejestrowane; model otrzymuje
jawna informacje o tych ograniczeniach. Dane FMC i rozpoznawanie konkretnego
samolotu pozostaja kolejnym etapem. Dla starych raportow uzyj Shift+klik analizy.


Raport AI jest teraz krotka ocena pilota: co wyszlo dobrze i do trzech wskazowek,
bez identyfikatorow, liczby probek czy opisu struktury danych. Szczegolowy kontekst
pozostaje przekazywany do analizy. Shift+klik generuje stary raport ponownie.
Raporty Markdown wyswietla WebView2 (naglowki, listy, pogrubienie, kursywa, kod,
cytaty); bez dostepnego runtime pozostaje widok tekstowy. Wymagany jest Edge
WebView2 Runtime oraz dolaczony WebView2Loader.dll. Mapa i wykresy pozostaja VCL.
Przycisk Zamknij zamyka niemodalne okno i zwalnia formularz.


Kontekst AI (schema_version=4) obejmuje wszystkie zapisane parametry numeryczne,
flagi i parametry silnikow z katalogu, w tym AP/FD, tryby autopilota, uzbrojenie
AT i autothrottle active, nastawy, trym, hamulce i spoilery. parameter_units oraz
engine_parameter_units pochodza z definicji odczytu SimConnect.
Pierwsza probka w oknie jest pelna. Kolejne zawieraja utc/t_seconds i tylko zmiany
wzgledem poprzedniego odtworzonego stanu. Obiekty silnikow sa scalane rekurencyjnie
wedlug numeru silnika. Brak pola oznacza bez zmian; null oznacza brak danych,
a false i zero sa rzeczywistymi wartosciami. Wszystkie znaczniki czasu pozostaja.
Porownanie jest dokladne, bez zaokraglania czy usredniania. Zmienia sie format
kontekstu wysylanego do AI, nie sposob zapisu istniejacych snapshotow w bazie.
Standardowe flagi SimConnect nie gwarantuja odwzorowania wlasnego FMA/FMC iFly.
V1/VR/V2 oraz inne jeszcze nierejestrowane dane FMC nie sa dopisywane sztucznie.
Dla zapisanych raportow uzyj Shift+klik, aby wygenerowac nowy z pelnym kontekstem.


Okna analizy startu i ladowania ustawia sie osobno w Ustawienia, w sekundach
czasu symulacji. Nowe ustawienia domyslne: start 60 s przed / 30 s po, ladowanie
180 s przed / 30 s po (dluzej obejmuje podejscie koncowe). Kazde pole: 1..300 s.
Klucze [ai]: takeoff_before_seconds, takeoff_after_seconds,
landing_before_seconds, landing_after_seconds. Stare context_before_seconds /
context_after_seconds pozostaja fallbackiem do pierwszego zapisania nowych
ustawien; nie sa nadpisywane. Analiza otrzymuje tylko istniejace probki danego
lotu. Dla starego raportu uzyj Shift+klik po zmianie okna.


Podwozie w analizie: landing_gear.center (przednie w 737), left i right,
zgodnie z indeksami SDK 0/1/2. Kazde ma extension_ratio (0 schowane, 1 wysuniete,
wartosci posrednie podczas ruchu), on_ground, wheel_rpm i warning_raw.
Pozycja dzwigni pozostaje oddzielna. Nowe nagrania zachowuja czesciowe wysuniecie;
stare nagrania calkowitoliczbowe nie odzyskaja utraconej precyzji. Dane podwozia
rowniez korzystaja z roznic miedzy probkami. Nie sa to dodatkowe czujniki blokad.
SDK: https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/SimVars/Aircraft_SimVars/Aircraft_Brake_Landing_Gear_Variables.htm


Nowe zdarzenia startu/ladowania zapisuja runway_length_m i runway_width_m z geometrii
pasa MSFS (metry; nie deklarowane TORA/LDA). Odleglosci od progu/osi pozostaja w stopach.
Po rozpoznaniu ICAO pobierany jest asynchronicznie biezacy METAR ze zrodla AWC:
https://aviationweather.gov/data/api/ . Zapis obejmuje surowy tekst, stacje,
czas obserwacji UTC, czas zlecenia/pobrania UTC, zrodlo i status/blad. Dane sa
przekazywane do AI razem ze zdarzeniem. To METAR swiata rzeczywistego, nie pogoda
symulatora: nie musi pasowac do recznej pogody ani daty/czasu lotu w MSFS.
Brak raportu lub internetu nie przerywa nagrywania. Zlecenie czeka do 5 minut na
rozpoznanie lotniska; stare zdarzenia nie sa uzupelniane dzisiejszym METAR-em.
Nieuzupelnione stare wymiary pasa pozostaja NULL. Po pobraniu METAR-u stary raport
AI mozna odswiezyc przez Shift+klik.


Wykresy: limit 8 usuniety, kolko myszy przewija pionowo liste wykresow.
Rysowany jest widoczny fragment, aby duzy wybor parametrow nie wymagal rysowania
wszystkich wykresow przy kazdym odswiezeniu. Grids sa tylko do odczytu.
Splittery pozwalaja zmieniac szerokosci historii/parametrow oraz wysokosci mapy
(dzielac obszar z wykresami) i listy parametrow (dzielac z inspektorem).
Te cztery rozmiary sa zapisywane w [layout] przy zamknieciu. Ustawienia zawieraja
wylacznie przycisk przywracania domyslnego ukladu zamiast liczbowych pol rozmiarow.

Przycisk Pobierz METAR z czasu zdarzen zleca pobranie raportow dla startow i ladowan
wskazanego nagrania wedlug ich czasu symulacji UTC i rozpoznanego ICAO. Uzywa
udokumentowanych parametrow AWC date/hours. Wybiera najnowsza obserwacje nie pozniejsza
niz zdarzenie i nie starsza niz 3 godziny; pozniejsze obserwacje sa odrzucane.
Dostepnosc zalezy od archiwum dostawcy (AWC dokumentuje ostatnie 30 dni).
Nie ma zastepowania brakujacego historycznego METAR-u dzisiejszym. Pole
metar_target_utc zapisuje zadany czas; metar_fetched_utc to czas pobrania.
To nadal rzeczywista obserwacja lotniskowa, nie pogoda ustawiona w MSFS.
Po zakonczeniu pobierania uzyj Shift+klik analizy, aby odnowic zapisany raport.


Zakladka Kolejnosc wykresow obok Parametry pozwala przesuwac wybrane wykresy
przyciskami w gore/w dol; kolejnosc zapisuje sie razem z wyborem parametrow.
Zoom + / Zoom - zmieniaja zakres czasu, Shift + lewy przycisk myszy zaznacza zakres
(rowniez od prawej do lewej), Ctrl+kolko zmienia skale, a Caly lot lub dwuklik
wykresu resetuje widok. Dodatkowy suwak przesuwa powiekszony fragment; poprzedni
suwak nadal steruje kursorem odczytu. Skala Y jest dopasowana do widocznego czasu.
Zwykle kolko nadal przewija liste wykresow.

Instrukcje AI uwzgledniaja krotkie przeskoki analogowej osi klap TCA Airbus
Captain Pack: powrot bez trwalej zmiany klap nie jest traktowany jako blad pilota.
Trwale zmiany konfiguracji pozostaja oceniane. Odleglosci rotacji/oderwania i
przyziemienia raportowane sa w metrach, z rozroznieniem poczatku rotacji i oderwania.
Przebieg zawiera przyblizone projekcje pozycji na os pasa w metrach; brakujace
polozenie nie jest wymyslane. Stabilna IAS utrzymywana przez A/T na final moze byc
pomocniczym punktem odniesienia, ale nie jest utozsamiana z VREF ani bezpiecznym
zapasem predkosci. Shift+klik analizy odswieza poprzednio zapisany raport.


Zwykle przeciaganie wykresu przesuwa widok w czasie bez zmiany skali.
Shift + przeciaganie zaznacza zakres do powiekszenia. Podwojny klik przywraca calosc.

Dla tytulu samolotu iFly 737 MAX 8 rejestrator automatycznie czyta oficjalne SDK
1.5 przez pamiec wspoldzielona i mutex (tylko odczyt). Odczyt SDK odbywa sie w ustawionym interwale zapisu, bez dodatkowego
przetwarzania 2411 pol w kazdej klatce symulatora. Odczytuje wszystkie 2411 pol,
ale zapisuje zlozone wartosci wyswietlaczy, a FMC i jego metadane osobno.
Pierwsza probka stanu jest pelna, kolejne zawieraja zmiany.
Pola numeryczne sa dostepne na wykresach jako iFlySDK.*, zrekonstruowany stan trafia do AI.
Odpowiedniki standardowe (dzwignie gazu, klap, podwozia, hamulec postojowy,
uzbrojenie A/T, wlacznik FD kapitana, wysokosc kabiny oraz nastawy MCP
HDG/ALT/IAS odczytane z poprawnych cyfr wyswietlaczy) maja pierwszenstwo przed SimConnect.
Lampki i polozenia wlacznikow pozostaja surowymi stanami SDK; nie sa utozsamiane
z fizycznym polozeniem podwozia ani aktywnym trybem autopilota. Pozostale dane,
w tym dynamika lotu i pogoda, pochodza z SimConnect. Brak SDK jest jawnie oznaczony
jako fallback; stary stan SDK nie jest przenoszony przez przerwe dostepnosci.
SDK 1.5 nie zawiera bezposrednich liczbowych V1/VR/V2/VREF z FMC.
Nowe integracje mozna dodawac przez TAircraftProvider i RegisterProvider.


Fenix A320 jest teraz wykrywany automatycznie na podstawie tytulu samolotu
(Fenix/FNX_32). Odczyt obejmuje 1203 L-vars z dostarczonego Cockpit_Behavior.xml,
przez osobne polaczenie SimConnect tylko do odczytu. Nie potrzeba mostka WASM.
Zapis, interwal ms, delty, wykresy i analiza AI dzialaja tak jak dla iFly;
parametry wykresow maja prefiks FenixLVar. Dane trafiaja do nowych nagran.
Dzwignie klap i podwozia maja pierwszenstwo z Fenixa; pozostale standardowe
wartosci zachowuja SimConnect, gdy nie ma potwierdzonego odpowiednika.
Gaz 0..5 oraz przyciski/kontrolki AP/A-THR pozostaja osobnymi surowymi wartosciami.
Brak odpowiedzi, uszkodzone pakiety i stare dane sa oznaczane null. SimConnect
nie potwierdza istnienia kazdego L-var: odebrane zero moze oznaczac rowniez
nieobecna zmienna, co jest opisane w danych dla AI. Szczegoly integracji,
aktualizacji katalogu i testow: support/fenix/README.md.


FlyByWire A32NX jest wykrywany automatycznie (A32NX lub FlyByWire/FBW + A320).
Odczyt obejmuje 223 czytelne L-vars z dostarczonej dokumentacji Flight Deck API,
z pominieciem komend, wpisow tylko do zapisu i oznaczonych jako deprecated.
Parametry FBWLVar.* trafiaja do nowych nagran, wykresow i AI. Wspolny czytnik
L-vars obsluguje Fenixa i FBW bez mostka WASM. Interwal zapisu pozostaje w ms.
Po gotowosci samolotu dane FBW dostarczaja stan A/THR, indeks klap przeliczony
na standardowa numeracje MSFS oraz poprawne nastawy IAS/Mach z FCU.
Analiza dostaje tez VAPP z FMS w wezlach (z uwzglednieniem wpisu pilota),
bez utozsamiania tej wartosci z VREF. Brak poprawnej wartosci oznacza null.
Szczegoly zakresu API, ograniczen i aktualizacji: support/fbw/README.md.


PMDG 737 NG3 jest wykrywany automatycznie dla rodziny 737 NG (bez MAX i 777).
Odczyt przez oficjalne SimConnect Client Data obejmuje 494 nazwane pola SDK
oraz oba opcjonalne CDU. Parametry wykresow maja prefiks PMDGNG3.; dane SDK,
CDU i referencje FMC trafiaja do analizy. V1, VR, V2 i VREF sa w wezlach;
nieustawione wartosci FMC sa oznaczane null, nie jako predkosc zero.
Wymagane EnableDataBroadcast=1 (CDU: EnableCDUBroadcast.0/1=1). W znalezionym
737_Options.ini dla lokalnego PMDG 737-600 wszystkie te opcje byly juz wlaczone.
Nowa integracja dotyczy nowych nagran. Szczegoly, cache ON_SET, opis
referencji FMC, aktualizacja katalogu i diagnostyka: support/pmdg/README.md.


Ekrany FMC/MCDU iFly i PMDG sa skladane do TStringList (14 x 24 znaki),
a pelny raw_text trafia do trip_fmc_screens tylko przy zmianie tekstu,
zasilania lub dostepnosci, z czasem symulatora i czasem odczytu. Zachowywane
sa koncowe spacje, puste wiersze, numery stron i osobne wersje MOD.
Pamiec przygotowania lotu przechowuje strony widziane przed uruchomieniem
silnikow i przypisuje je do nowego nagrania. Analiza dostaje ostatnie strony
PERF INIT, N1 LIMIT, TAKEOFF REF i APPROACH REF oraz inne widziane strony,
aktualne wedlug ostatniej obserwacji nie pozniejszej niz analizowane zdarzenie.
Podstawowy parser rozpoznaje jawne V1/VR/V2/VAPP/VREF i WIND CORR; inne wartosci
pozostaja w pelnym tekscie do dalszego parsowania. Program nie przelacza stron
FMC; trzeba je wyswietlic w samolocie. Szczegoly: support/fmc/README.md.

### Ekrany MCDU Fenix / FlyByWire z FlightPadFMC

FDR automatycznie wykrywa aktywnego klienta FlightPadFMC dla wybranego
samolotu i zapisuje tekst jego ekranu, scratchpad oraz zmiany z timestampami.
Uruchom zaktualizowany FenixA320MCDU/Screen albo FBWA320MCDU/Screen i polacz
go z serwerem FlightPadFMC. Nie wymaga ustawiania portu w FDR. Szczegoly:
[support/flightpad/README.md](support/flightpad/README.md).

### Ollama

W ustawieniach wybierz Ollama, podaj URL serwera (domyslnie
http://localhost:11434), nazwe modelu z `ollama list` i rozmiar kontekstu.
Zapytania i raporty pozostaja po polsku. Model musi byc juz zainstalowany.
Limit czasu obejmuje generowanie i wczytywanie modelu; anulowanie przerywa HTTP.
Po zmianie silnika ponow analize z Shift, jezeli raport jest juz zapisany.
Szczegoly: [support/ollama/README.md](support/ollama/README.md).

### Informacje o nagraniu

Zaznacz lot na liscie nagran i kliknij **Informacje o nagraniu**. Okno pokazuje
samolot, rejestracje, linie i numer lotu, grupe, lotniska i pasy, czasy UTC
i lokalne, czas zapisu oraz liczniki probek, zdarzen, kontaktow z pasem, SDK,
ekranow FMC i rewizji planu. Widoczny jest tez ostatni zapisany plan lotu.
**Odswiez** aktualizuje informacje podczas nagrywania. Czas obejmuje zapis
w symulatorze; nie jest czasem od oderwania do przyziemienia.

### Precyzja danych analizy

Liczby zmiennoprzecinkowe w JSON dla AI maja najwyzej 3 miejsca po przecinku.
Delty uzywaja martwej strefy +/-0.0015 wzgledem ostatniej wyslanej wartosci,
co ogranicza szum i zachowuje narastajace zmiany. Surowe dane bazy i wykresy
zachowuja pelna precyzje. Szczegoly: [support/analysis/precision.md](support/analysis/precision.md).

### METAR i wspolne AIRLINER L-vars

Informacje o nagraniu pokazuja zapisane METAR-y wszystkich startow i ladowan,
czas obserwacji/pobrania oraz status i blad, gdy raport jest niedostepny.
SimConnect dodatkowo czyta 31 L-vars zawierajacych AIRLINER, z katalogu
importowanego z instrumentow MSFS24 i Community. Obejmuje on m.in. V1/VR/V2,
VREF/VX, predkosci podejscia, FLEX, wysokosci, tryby ciagu i dane TOC/TOD.
Dane sa opcjonalne, zapisywane jako zmiany i dostepne na wykresach oraz w AI;
nie zastepuja SDK samolotu. Szczegoly: [support/airliner/README.md](support/airliner/README.md).

### Pogoda referencyjna analizy

AI dostaje `weather.ground_reference`: dla startu ostatnia probke na ziemi
przed oderwaniem, a dla ladowania pierwsza od przyziemienia. Brak odpowiedniej
probki nie jest zastepowany odczytem w powietrzu. Zmiany AMBIENT w locie
nie oznaczaja bledu QNH; cisnienie lokalne nie jest lotniskowym QNH.
Opis: [support/analysis/ground-weather.md](support/analysis/ground-weather.md).
# SimBrief

Kółko myszy nad widokiem SimBrief przewija cały Dispatch, również gdy wskaźnik znajduje się nad memo lub inną kontrolką ramki. Działa to w zakładce i osobnym oknie. Sekcja Flight Plan Downloads została usunięta z widoku.

Briefing Preview i pozostałe sekcje tekstowe dopasowują wysokość do liczby wierszy i wysokości czcionki. Zachowują podziały wierszy oraz odstępy. W pionie przewijany jest cały Dispatch; memo mają tylko przewijanie poziome dla szerokich wierszy. Zwijanie i ponowne rozwijanie przywraca wysokość wynikającą z treści.

Przycisk **Osobne okno** przenosi ten sam podgląd Dispatch do skalowalnego okna. Po zamknięciu widok wraca do zakładki z zachowanym planem i stanem sekcji. Okno jest modalne: główny formularz pozostaje zablokowany, a pobieranie i obsługa SimBrief są dostępne w nowym oknie. Treści uwag i planu ATC nie mają technicznych prefiksów JSON ani indeksów tablic. Dla pozostałych danych pozostają krótkie nazwy pól, bez ścieżek obiektów API.

Zakładka **SimBrief**, obok **Plan lotu**, jest niezależnym podglądem Dispatch. **Pobierz ostatni plan** pobiera aktualne wydanie dla wpisanego konta i zachowuje lokalną kopię `simbrief-latest.json`. Nie wymaga zgodności z wybranym nagraniem i nie przypisuje planu automatycznie. **Plan nagrania** pokazuje OFP już zapisany w wybranym tripie, a **Przypisz do nagrania** uruchamia dotychczasową walidację zgodności. W podglądzie lotniska pochodzą z odpowiedzi API; zrzuty ekranu ani trasy testowe nie definiują kierunku rzeczywistego lotu.

Podgląd ma 15 natywnych GroupBoxów: Flight Info, Flight Plan Summary, Load Sheet, Route, Dispatch Remarks, ATC Flight Plan, Briefing Preview / OFP, Runway Analysis, Flight Maps, Departure Airport, Arrival Airport, Alternate Airport, Takeoff Alternate, Enroute Alternate oraz Prefile on a Network. Każdy ma własny przycisk **Zwiń/Rozwiń**; stan sekcji jest zapamiętywany w `[simbrief_sections]`. Pierwsze trzy sekcje przedstawiają dane w polach, pozostałe mają przewijany tekst tylko do odczytu. Sekcje map, eksportów i prefile pokazują dane i odnośniki dostarczone przez API; nie wykonują zgłoszenia planu na żadnej sieci ani automatycznego pobierania załączników.

**Otwórz OFP** renderuje pełny oryginalny dokument HTML przez WebView2 w osobnym oknie. W sekcji Briefing Preview jest również jego tekst. Domyślna nazwa układu to **LIDO**, gdy odpowiedź nie zawiera `params.ofp_layout`; gdy SimBrief poda inny układ, podgląd pokazuje rzeczywisty układ i zachowuje oryginalny dokument. Sam odczyt ostatniego planu nie zmienia jego układu ani nie generuje nowego wydania w SimBrief.

Opcja **Dopuszczaj starszy plan** pozwala ponownie wykorzystać wcześniej przygotowany OFP. Domyślnie jest wyłączona; jej ustawienie jest zapamiętywane w `[simbrief] allow_older`. Przy różnicy dat ponad 12 godzin dopuszcza wyłącznie plan wcześniejszy, po sprawdzeniu zapisanej trasy EFB JSON lub PLN. Wszystkie dostępne punkty zapisanej trasy muszą występować w SimBrief w tej samej kolejności (w rozwiniętym navlogu, a przy jego braku w tekście trasy). Lotniska, TOC/TOD i punkty pasa są pomijane w porównaniu punktów. Przy EFB porównywane są również SID/STAR, gdy oba plany je podają. Brak porównywalnych punktów blokuje starszy import. Kontrola nie wymaga identycznej liczby punktów: plany mogą różnić się rozwinięciem procedur i dróg lotniczych.

Sprzeczny numer lotu, rejestracja, kod ICAO linii lub rozpoznawalny kod ICAO typu samolotu nadal blokują import. Parametry planowane, takie jak paliwo i masa, nie są wymagane jako identyczne z pomiarami w locie. Zgoda na starszy plan jest zapisywana przy konkretnym imporcie, dzięki czemu analiza ponownie sprawdza go według tej samej reguły. Informacje o tripie oraz kontekst modelu zawierają oznaczenie **SimBrief wygenerowany wcześniej** i datę generacji w kontekście. Prognozy, METAR-y, NOTAM-y i wiatry starego OFP są historycznymi danymi planistycznymi, nie aktualną pogodą.

Wybierz nagranie i otwórz **Informacje o nagraniu**. Wpisz nazwę użytkownika SimBrief lub Pilot ID i naciśnij **Import SimBrief**. Konto jest zapamiętywane w lokalnym `settings.ini`, sekcja `[simbrief]`, klucz `username`. Paczki dystrybucyjne mają to pole puste.

Import pobiera ostatni plan wyłącznie na żądanie użytkownika, bez cyklicznego odpytywania. Standardowo wymaga zgodnych lotnisk startu i lądowania oraz różnicy najwyżej 12 godzin między początkiem nagrania w czasie UTC symulatora a planowanym `sched_out`. Sprzeczny numer lotu lub rejestracja blokuje import. Brak danych lotnisk lub daty też blokuje przypisanie. Dla trwającego lotu brakujące lotniska można ustalić z ostatniej zapisanej trasy EFB JSON; rzeczywiście rozpoznane lotniska mają pierwszeństwo. To ostrożna kontrola zgodności, nie dowód tożsamości lotu; przy kilku identycznych lotach tego samego dnia zweryfikuj plan samodzielnie.

Pełna odpowiedź JSON, w tym oryginalny dokument OFP HTML, trafia do tabeli `trip_simbrief` w tej samej bazie. Ponowny import zastępuje przypisany plan; usunięcie tripu usuwa również OFP. **Zapisz OFP** eksportuje zapisany dokument HTML do otwarcia w przeglądarce lub wydruku do PDF. Import nie pobiera osobnego PDF ani wszystkich formatów eksportu SimBrief.

Analiza otrzymuje strukturę planu (trasa, samolot, masy, paliwo, czasy, lotniska i alternatywne) oraz pierwsze 24 000 znaków tekstu OFP bez znaczników i stylów. Pełny OFP pozostaje w bazie; skrócenie jest jawnie oznaczone w kontekście. Przed analizą zgodność jest ponownie sprawdzana. Instrukcja modelu rozróżnia wartości planowane i rzeczywiście zmierzone. Zapisany wcześniej raport AI trzeba wygenerować ponownie, aby uwzględnił nowy import.

Endpoint i ograniczenie odpytywania: [dokumentacja SimBrief/Navigraph](https://forum.navigraph.com/t/fetching-a-users-latest-ofp-data/5297).

# GSX Pro

Recorder odczytuje przez SimConnect 16 L-varów GSX Pro: stany usług, pushback freeze, pasażerów, cargo i typ płynu odladzającego. Zapisuje zmiany w trakcie aktywnego tripu, udostępnia parametry `GSX.*` na wykresach i przekazuje je do analizy. Szczegóły oraz ograniczenia: [support/gsx/README.md](support/gsx/README.md). Recording covers the loaded flight session, including engines-off ground services.

## FSHud

See [support/fshud/README.md](support/fshud/README.md) for protocol, recorded data, analysis context and live verification.

## Grupy nagrań

Lista grup filtruje nagrania. Pusta pozycja oznacza wszystkie nagrania, również bez grupy. Odświeżanie zachowuje filtr. Przypisywanie otwiera osobny dialog z aktualną grupą; OK zapisuje, Anuluj zachowuje przypisanie. „Bez grupy” usuwa przypisanie.

[MichaelHsu170/MSFS-Flight-Data-Recorder](https://github.com/MichaelHsu170/MSFS-Flight-Data-Recorder) — AGPL-3.0.

## Toolbar frames — 2026-10-18

Akcje toolbarów i ich ImageListy należą teraz do fraMap/fraGraph i są zapisane w ich DFM-ach. Menu frmMain korzysta z tych samych akcji; main zachowuje tylko odwołania i obsługę przełączania okien. Zoom wykonuje frame wykresów. btnGraphWindow i btnMapWindow w odłączonym oknie przywracają ten sam frame do frmMain. Indeksy ikon pozostają zgodne z menu głównym. Poprawiono też właściwości TFrame w DFM i błędne wpisy uses konfiguracji wykresów.

## Zrzuty ekranu

Zrzuty przedstawiają rzeczywisty interfejs aplikacji uruchomionej na syntetycznych danych testowych. Nie są zapisem rzeczywistego lotu.

![Główne okno: mapa, wykresy i inspektor](docs/screenshots/main.png)

![Wykresy w osobnym oknie](docs/screenshots/charts-window.png)

![O programie](docs/screenshots/about.png)

## Pomoc CHM i F1

F1 lub Pomoc → Pomoc programu otwiera temat aktywnego widoku. Pomoc zawiera wprowadzenie, mapę, wykresy, analizę, ustawienia i informacje o programie. Język PL/EN/DE/ES odpowiada językowi interfejsu.

Budowanie: `python tools/build_help.py --require-chm`. Wymagany HTML Help Workshop; alternatywną ścieżkę do hhc.exe podaje zmienna HHC_EXE. Pełny build.ps1 również buduje pomoc. Bez kompilatora dostępny jest lokalny HTML; gdy brakuje CHM, F1 korzysta z HTML. Pliki wynikowe: bin/help. Do dystrybucji kopiuj cały katalog help razem z EXE.

Małe ikony menu przebudujesz poleceniem `powershell -ExecutionPolicy Bypass -File tools/rebuild_toolbar_images.ps1 -List small`.

## Czytelne nazwy parametrów

Wykresy, lista wyboru, kolejność i inspektor wartości pokazują opisy z jednostkami, np. `Wysokość samolotu [ft]` i `Prędkość N1 — silnik 2 [%]`. Nazwy zmieniają język razem z interfejsem. Wyszukiwanie działa po opisie i surowym identyfikatorze; podpowiedź pokazuje oba.

W bazie, modelu lotu i konfiguracji nadal są oryginalne identyfikatory. Są pełne opisy 212 podstawowych parametrów oraz AIRLINER, GSX i FSHud. Pozostałe nazwy SDK/LVAR są rozdzielane na czytelne słowa, z zachowaniem źródła, skrótów i indeksów. Nieznanym polom nie przypisujemy zgadywanych jednostek. Wartości 0–1 nie są podpisywane jako procenty bez konwersji.


### Jednostki prezentacji

W Ustawieniach → Jednostki wybierz jednostkę docelową osobno dla każdej jednostki źródłowej, np. ft → m, lb → kg, US gal → l. Pozostawienie tej samej jednostki wyłącza konwersję. Zmiana działa na wykresy (linie, skale, kursor) i podgląd parametrów, również w odłączonym oknie. Baza i dane do analizy pozostają oryginalne. Nie zgadujemy jednostek nieopisanych pól SDK.


### Przeciąganie wykresów

W Ustawieniach wykresów przeciągnij parametr z lewej listy na prawą, aby dodać go we wskazanym miejscu. Przeciągnięcie z prawej na lewą ukrywa wykres. Ctrl+przeciągnięcie wewnątrz prawej listy zmienia kolejność; linia pokazuje miejsce wstawienia. Obie listy przewijają się przy krawędzi podczas przeciągania. Checkboxy i przyciski nadal działają. OK zatwierdza kopię roboczą, Anuluj zachowuje poprzedni wybór.


### Język Windows, dziewięć języków i VersionInfo

Domyślny wybór języka to auto. Aplikacja odczytuje język interfejsu użytkownika Windows, niezależnie od ustawień liczb/dat. Warianty regionalne są mapowane na PL/EN/DE/ES/FR/RU/TR/IT/PT; inne języki przechodzą na angielski. Wybór auto jest zapamiętywany i rozwiązywany ponownie po uruchomieniu. Istniejący jawny wybór języka pozostaje zachowany. Menu i Ustawienia obsługują automatyczny wybór oraz dziewięć języków. Katalog obejmuje nowe etykiety zmienionego GUI. Pomoc pozostaje w czterech dotychczasowych językach; dla nowych używana jest angielska. Nowe tłumaczenia są pierwszą wersją przygotowaną lokalnie przez Qwen3 z korektami terminologii i kontrolą struktury; nie są po przeglądzie native speakerów. VersionU czyta liczbowy i tekstowy VersionInfo z EXE z uwzględnieniem tablic językowych. O programie pokazuje rzeczywistą wersję, ProductName i copyright. Wspólny Build wynosi 2 (0.1.0.2); pozostałe numery i dane autora zachowano. tools/bump_build.py zwiększa tylko Build raz na logiczną zmianę; check_version.py kontroluje brak nadpisań konfiguracji. CLI buduje przez MSBuild, aby wygenerować aktualne zasoby wersji.


Rozszerzenie lokalizacji: interfejs obsługuje 25 lokalizacji. Dodano en-GB, fr-CA, pt-BR, de-AT, de-CH, be-BY, el-GR, uk-UA, hr-HR, cs-CZ, da-DK, nl-NL, fi-FI, nb-NO, sk-SK i sv-SE. Warianty regionalne są zapisywane osobno; be oznacza białoruski, a no/nb/nn wybierają dostępny norweski Bokmål. Nie jest to osobne tłumaczenie Nynorsk. Szwajcarski niemiecki używa ss zamiast ß. Detekcja automatyczna używa języka interfejsu Windows, bez zmiany formatów liczbowych. Pomoc pozostaje w PL/EN/DE/ES, z odpowiednim językiem bazowym lub angielskim jako zastępczym. Nowe tłumaczenia to pierwsza wersja z korektami terminologii i kontrolą struktury; nie przeszły przeglądu native speakera. Build: 0.1.0.3, pozostałe dane wersji i autora bez zmian.


Interfejs zawiera 32 lokalizacje, sortowane według kodu. Nowe: ar-SA, he-IL, hi-IN, id-ID, ja-JP, vi-VN i zh-CN. Skróty ar/he wybierają odpowiednie warianty; iw/in obsługiwane są jako starsze aliasy he/id. Arabski i hebrajski używają układu RTL; wykresy, mapy i surowe teksty FMC/METAR/OFP zachowują LTR. Fonty Noto w assets/fonts są dołączane do bin/fonts i paczek, ładowane prywatnie bez instalacji systemowej, razem z licencjami OFL i manifestem pochodzenia. Pomoc i dokumentacja pozostają w czterech językach. Zasady zgłaszania błędów tłumaczeń: Translation.pl.md. Build 0.1.0.4.


StackTrace zbiera stosy wywołań dla błędów. Zachowaj MSFS2024-FDR.pdb obok dokładnie tej wersji EXE, z którą został wygenerowany; paczka zawiera ten plik. Przy zgłoszeniu dołącz wersję aplikacji i odpowiedni fragment msfs_fdr_debug.log. Kompilacja ze źródeł wymaga map2pdb.exe w PATH; szczegółowa mapa jest generowana i przetwarzana po kompilacji.
