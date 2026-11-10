# Testy MSFS Flight Data Recorder — Delphi VCL

[Polski](Testy.md) | [English](Testy.en.md) | [Deutsch](Testy.de.md) | [Español](Testy.es.md)

## Zgodność symulatora i wartości przełączników

VerifyFlapsHandle, VerifyParameterValues, VerifyUI i VerifyChartView — PASS: wydzielony case ICAO, A320 standard 6 kontra SDK 5 pozycji, 1+F, profile GA i ujemne detenty Stemme, różnice TFDi/SkySim MD-11, warunkowy Draco/ULAC, niezgodna liczba pozycji, brak danych i pusty fallback. Piąty test Python sprawdza zgodność danych z generowanym unitem. To weryfikacja syntetyczna, nie loty wszystkimi samolotami; 60 kodów pozostaje jawnie niepotwierdzonych.

Ponowny audyt DisplayValue — PASS: 4 testy Python parsera, pochodzenia i zgodności generatorów; VerifyParameterValues oraz VerifyAircraftSDK, VerifyFenix, VerifyFBW, VerifyAddonLVars, VerifyPMDG i VerifyPMDG777. Sprawdzono m.in. chińskie separatory, zakres cyfr zamiast fałszywego enuma, brak interpolacji nieopisanych pozycji, etykiety XML, kody znaków RTP, CSS press/release oraz zachowanie liczbowego fallbacku. 335 XML sprawdzonych, w 14 niepoprawnych XML użyto wyłącznie poprawnych samodzielnych fragmentów UseTemplate. Próby statyczne i atrapy, bez lotu na żywo.

VerifyUI i VerifyGSX — PASS: paski zdefiniowane w DFM, pojawienie w Requested, aktywny/zakończony stan, cofanie czasu, brak danych, odrębne liczniki pasażerów/bagażu oraz postęp i reset cysterny. Testy syntetyczne i atrapa SDK; bez próby z działającym GSX.

VerifySimulatorVersion, VerifySubscriptions, VerifyRecorderWorker, VerifySession, VerifySimBacklog, VerifyFlightPlan i VerifyRecordingWorker: PASS na atrapach/syntetycznej telemetrii. MSFS24 jest akceptowany dopiero po OPEN, MSFS20/FSX/P3D, nieznana i skrócona odpowiedź są odrzucane bez subskrypcji; ponowne połączenie przywraca zgodność. VerifyParameterValues, VerifyParameterNames i VerifyGSX: PASS dla pozycji klap/autobrake, ON/OFF, odrębnych detentów A320/737/777, nieznanych liczb, NaN, niezmiennych oznaczeń kokpitowych oraz tłumaczonych etapów i postępu GSX. Postęp bagażu jest procentem, nie liczbą sztuk. Brak nowych prób z działającym symulatorem lub GSX.

## A320 PFD i ECAM — Fenix / FBW

VerifyAirbusDisplays — PASS: wszystkie 13 stron i podglądy PNG, wybór Recorded kontra manual selector, mapowanie 11/12, zmiana czasu w obie strony, ręczna strona utrzymana podczas seek, pełna ważność ARINC/zero/SSM, aktywny CPC, priorytet rzeczywistych N1 FBW, zapis i odtworzenie SDK delta z SQLite, brak dawnych danych po clear, odłączanie i ikony 0/1, RTL/LTR i resize. VerifyInstrumentFrames — PASS: Fenix/FBW ↔ B38M przy obu odłączonych slotach, zachowana geometria i synchronizacja trzech ekranów. VerifyFBW — PASS po przebudowie MockFenixSim z nowym katalogiem; test utraty ostatniego batcha uogólniony na dowolną liczbę pól. VerifySixPack i VerifyViewState — PASS. Przejrzano PNG PFD, E/WD i HYD; brak lotu na żywo, porównania z działającym Fenix/FBW lub próby projektanta IDE.

Recorded / Z nagrania śledzi zapisane `A32NX_ECAM_SD_PAGE_TO_DISPLAY`, nie przycisk selektora; 11 oznacza CRUISE, 12 STS. Ręczny wybór strony pozostaje aktywny przy przewijaniu, powrót do Recorded przywraca śledzenie. Dopisano 47 odczytywanych pól FBW. Dane ARINC429 wymagają SSM normal operation, brakujące/nieprawidłowe są `--`. To pierwsza rekonstrukcja na podstawie danych, nie pełna emulacja DMC/FWC. Nie są wymyślane tryby FMA, komendy FD, teksty ostrzeżeń/STS, statusy zaworów ani sprawność układów. Z dostępnego XML Fenixa nie potwierdzono faktycznie wyświetlanej strony automatycznej; Recorded pokazuje wtedy brak danych, wszystkie strony można wybrać ręcznie. Olej pokazywany w procentach, bez zgadywania pojemności w kwartach. ECAM używa oznaczonych jednostek Airbus (kg, kg/h, psi, C); PFD zachowuje skonfigurowane jednostki taśm.

[ECAM](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/ecam/), [E/WD](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/ecam/ecam-e-wd/), [SD](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/ecam/sd/), [PFD](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/pfd/), [FBW SD source](https://github.com/flybywiresim/aircraft/tree/master/fbw-a32nx/src/systems/instruments/src/SD).

## Import baz Qt

`VerifyLegacyExport` — PASS: import pliku zgodnego z Qt do biblioteki, odtwarzanie 3 próbek i 6 wierszy silników, dokładność N1, brakujące rozszerzenia jako NaN i zachowane +02:00. Wielolotowy fixture Qt rozdzielony na dwa `.mfzr`, po 3 próbki każdego lotu bez przecieków; powtórny import nie duplikuje wpisów, oba źródła zachowują SHA-256. Dialog/menu DFM w VerifyInstrumentFrames; regresja starszego importu/podglądu w VerifyRecordingImport. Syntetyczne SQLite/VCL, bez próby na żywo.

## Eksport lotu do pierwowzoru Qt

`VerifyLegacyExport` — PASS: dwa loty źródłowe, wyeksportowany tylko wskazany; 3 próbki, 6 powiązanych wierszy silników, jeden komplet kontaktów i zdarzenie, tylko używana grupa; Unicode i niezaokrąglone N1. Siedem tabel, 130 kolumn trip_data i 35 trip_engine_data, brak rozszerzeń i raportów. SHA-256 źródła bez zmian przy podglądzie read-only; odrzucone nadpisanie źródła, nieistniejący lot i błąd NOT NULL w środku kopiowania zachowują poprzedni cel oraz usuwają plik tymczasowy. Niezależny odczyt Python sqlite3 porównał nazwy, typy i kolejność wszystkich kolumn telemetrii z nagłówkiem klonu Qt. Test DFM menu/dialogu w VerifyInstrumentFrames. Bez ręcznego otwarcia w GUI Qt; zgodność zweryfikowana schematem i zapytaniami SQLite.

## Stabilny układ instrumentów i osi czasu

Panel suwaków pozostaje bezpośrednio w CenterPanel, a mapa, wykresy, instrumenty i ich splittery mają osobny ViewsPanel w DFM. Splitter instrumentów nie może już wybierać panelu suwaków jako sąsiada do zmiany rozmiaru. Przy powrocie widoków porządkowane są pozycje instrumentów i separatorów.

VerifyInstrumentFrames: PASS — osobne kontenery, brak nakładania widoków na oś czasu, splitter bezpośrednio nad instrumentami po zmianach wysokości okna 650/750/850 oraz po odłączeniu/powrocie PFD/EICAS. VerifyDetachedViews i VerifyViewState: regresje odłączania, synchronizacji i konfiguracji. Próby syntetyczne VCL/SQLite/INI; bez próby na żywo i bez ręcznego testu projektanta IDE.

## Skalowanie panelu silników i EICAS

Usunięto ScrollBox z obu framów i odziedziczone wpisy z frmMain DFM. Widok zajmuje dostępny obszar klienta pod toolbarem. EICAS zachowuje proporcje; ogólne zegary renderują pełny układ do bufora, dobierają kolumny do rozmiaru panelu i skalują całość. Próbki nie zmieniają rozmiaru kontrolki. Splitter PFD/EICAS ma jawne alLeft, szerokość 6, MinSize 100, AutoSnap=False, rsUpdate i zapis szerokości po przesunięciu.

`VerifyInstrumentFrames`, `VerifyEngineGauges`, `VerifyB38MEICAS`, `VerifyViewState` — PASS. Dodatkowe asercje sprawdzają brak ScrollBox, alClient i dokładną wysokość pozostałą pod toolbarem, kolejność panel–splitter–panel, wyłączone AutoSnap oraz synchronizację i odłączanie. Testy syntetyczne VCL/SQLite/INI; bez lotu na żywo ani ręcznej próby projektanta IDE.

## Dobór framów według ICAO i wspólne skale PFD

- `VerifyInstrumentFrames` — PASS: ICAO B38M wybiera `ikB38MPFD`; sam tytuł MAX 8 tego nie robi; B736/B737/B738/B739 pozostają ogólne. Dwa osobne framy zadeklarowane w DFM zastępują six-pack i panel silników. Zmiana B38M → B738 → B38M z dwoma odłączonymi oknami zachowuje geometrię, właściwego rodzica, synchronizację i ikony 0/1. Powrót przyciskiem i X, przejście do GA oraz piksele taśmy IAS zaliczone.
- `VerifySixPack`, `VerifyPFD737`, `VerifyB38MEICAS`, `VerifyEngineGauges`, `VerifyDetachedViews`, `VerifyViewState` — PASS. Testy pikselowe ILS dostosowane do nowego układu, bez zmiany oczekiwanych kierunków odchylenia, niezależnych flag, GPS exclusion ani pustych rombów na krańcach. Test 1000 zmian kursora przy 3003 etykietach nadal nie wykonuje wyszukiwań indeksów; zmiana ICAO unieważnia pamięć profilu. Sześć miejsc odłączania zastępuje poprzednie siedem, bez osobnego `view.pfd737`.
- Naprawiono `sync_test_projects.py`: nowy projekt musi zawierać `DelphiCompile`, inaczej MSBuild może zgłosić sukces bez EXE. Nowy test i regresje skompilowano i uruchomiono po naprawie. Test zarejestrowany w `Tests.groupproj`; jednostki i metadane framów w DPR/DPROJ.
- Debug/Release Win64 i Setup skompilowane; kontrole projektu, wersji, dokumentacji i tłumaczeń zaliczone. Weryfikacja syntetyczna VCL/SQLite/INI oraz renderów; bez lotu na żywo i bez próby projektanta IDE. Poniższe wcześniejsze sekcje opisują poprzednie etapy; aktualny dobór framów obowiązuje jak wyżej.

## EICAS B38M i dodatkowe parametry

- `VerifyB38MEICAS` — PASS: automatyczny wybór po tytule iFly MAX 8 lub zapisanym ICAO B38M niezależnie od livery, powrót do zwykłych zegarów dla innych samolotów; niezależne N1/N2/EGT/FF/olej/wibracje obu silników. Sprawdzono surowe psf i odczyt 53 psi, detenty klap i nieliniowe położenie wskazówki, przeliczenie galonów na masę tylko przy znanej dodatniej gęstości, NaN zamiast zgadywanego zera.
- Ten sam test — PASS: piksele bursztynowej lampki FUEL FILTER BYPASS z SDK i niezależnego ENG FAIL, zanik komunikatu po utracie flagi, brak ostrzeżenia silnikowego z lampki APU lub samego zerowego ciśnienia. Starter ma etykietę STARTER ACTIVE, nie START VALVE OPEN. Przejrzano wygenerowany `tests/b38m-eicas-preview.png`. Zmiana proporcji, RTL/LTR, przewijanie w obie strony, odłączanie i powrót tej samej instancji z ikonami 0/1 przeszły.
- SQLite — PASS w `VerifyB38MEICAS`: zapis i odtworzenie 0,813 ilości oleju, TAT 24,37 i paliwa centralnego 1250,75. Utworzono starszą strukturę bez nowych kolumn, zachowując próbki; odczyt i kontekst AI działają z NaN/NULL, N1 pozostaje 84,7. SHA-256 pliku przed/po podglądzie jest identyczny. Ponowne otwarcie do zapisu migruje schemat, a brakujące historyczne wartości pozostają NULL.
- `VerifySubscriptions` — PASS: nowe ilości oleju tylko dla istniejących silników, TAT i zbiornik centralny w aktywnym locie; na postoju menu nadal tylko trzy zmienne identyfikacyjne. Kolejność AircraftLoaded/SimStart/FlightLoaded, usuwanie subskrypcji i odrzucanie starych pakietów nadal przechodzą na atrapie DLL. `VerifyPort`, `VerifyRecordingImport`, `VerifyDetachedViews`, `VerifyViewState`, `VerifyPFD737`, `VerifyEngineGauges` i `VerifyContext` również przeszły.
- Katalog rozszerzono na końcu: dotychczasowe indeksy nie zmienione; nowe pola mają REAL, nazwy interfejsu w 32 językach. Nowy unit jest w DPR/DPROJ, nowy test w Tests.groupproj. Bez lotu na żywo i bez porównania pełnej logiki ostrzeżeń z iFly. Nie ma potwierdzonych źródeł START VALVE OPEN, THRUST ani FUEL FLOW w sprawdzonym SDK 1.5. Ilość oleju jako stosunek pojemności i jednostki pomiarów sprawdzono w [oficjalnym SDK](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-engine-variables/); nie oznacza to litrów ani limitów silnika.

## Skalowanie PFD i osobny PFD 737

- `VerifySixPack` — PASS: render w szerokim panelu 900×200 wykorzystuje wysokość na horyzont, V/S ma tarczę i wskazówkę z odczytem −677 ft/min. Dotychczasowe testy geometrii wysokościomierza, stałego VSI, cache, ILS, braków danych, jednostek i dokowania przechodzą. Skale i napisy nie zmieniają zakresu wraz z próbką. Przejrzano `tests/pfd-wide-preview.png`.
- `VerifyPFD737` — PASS: nowy natywny frame DFM i renderer. Sprawdzono surowe wartości IAS/ALT i znak pitch, piksele rombów LOC/GS, stałą nieliniową skalę V/S (1000 → 0,5; 2000 → 0,75; 6000 → 1), znak i ograniczenie, NaN, zmianę proporcji 600×640 / szeroką / wąską / miniaturową, przewijanie do przodu i do tyłu, tę samą instancję w osobnym oknie, ikonę 0/1 i LTR przy języku hebrajskim. Przejrzano `tests/pfd737-preview.png`.
- `VerifyDetachedViews` — PASS: zakładka PFD 737 jest w frmMain.dfm, główna oś czasu aktualizuje ją także po odłączeniu, zamknięcie przywraca zakładkę i ikonę. `VerifyViewState` — PASS: rozszerzony na siedem widoków, z `view.pfd737`, niezależnymi rozmiarami i automatycznym odtwarzaniem stanu po ponownym utworzeniu frmMain.
- Nowy test dopisano do `tests/Tests.groupproj`; oba unity oraz metadane TFrame są w DPR i DPROJ. Testy są syntetyczne; nie wykonywano lotu ani porównania z działającą awioniką 737 i nie otwierano projektanta IDE. FMA jest obecnie opisem dostępnych flag AP/FD/A/T; renderer nie odtwarza nieznanych trybów ani komend FD.

## Przebudowany frmMain, ikony i prezentacja danych

- Po wizualnej kontroli `native-preview.png` usunięto duplikat silników z SixPack w frmMain: osobny EnginePanel pozostaje aktywny, a przyrządy zachowują wysokość w nowym niskim panelu. Regresja `VerifyDetachedViews` sprawdza tę wysokość. Dodatkowo przeszły `VerifyFMCReplay`, `VerifySimBriefUI`, `VerifySixPack` i `VerifyUI` po zmianach toolbarów.
- `VerifyDetachedViews` — PASS: nowe panele zamiast usuniętych zakładek, odłączanie i powrót tej samej instancji, ukrywanie kontenera/splitterów po odłączeniu obu przyrządów, odtwarzanie po zamknięciu. Ikony 0/1 zmieniają się także po zamknięciu krzyżykiem. Sprawdzono render obu ikon wszystkich sześciu framów na białym i czarnym tle, bez nieprzezroczystych narożników.
- `VerifyRecordingTree` — PASS: pełny i obcięty klucz lokalizacyjny ATCCOM z tytułem iFly MAX 8 daje B38M; A32NX daje A20N; istniejący poprawny ICAO pozostaje bez zmian, nierozpoznany klucz daje UNKNOWN, nazwa urządzenia Windows jest odrzucana. Dotychczasowe filtrowanie, sortowanie, lokalizacja i brakujące pliki nadal działają. Surowe metadane i ścieżki istniejących nagrań nie są przepisywane.
- `VerifyEngineGauges` — PASS: 7632 surowych psf daje 53 psi dla wskaźnika oleju, a wartość przechowywana w modelu pozostaje 7632; NaN nie staje się zerem. Dotychczasowe typy silników, synchronizacja, dokowanie i odczyt NULL nadal przechodzą.
- `VerifyRecorderWorker` — PASS: atrapa samego otwarcia SimConnect zgłasza E_FAIL, worker pozostaje gotowy, bez Failed/Error i wyświetla lokalizowane Oczekiwanie na MSFS; ponowienia są ograniczone interwałem. Dotychczasowy test błędów poleceń, SQLite i responsywności VCL przechodzi. Nie testowano działającego symulatora ani realnego zerwania transmisji.
- `VerifyRecordingImport` — PASS: nowa hierarchia paneli w DFM, migracja/import i tryb podglądu bez worker/SimConnect. `VerifyViewState` sprawdza sześć niezależnych okien oraz zapis nowych wymiarów dolnych paneli. Wszystkie próby używają izolowanych plików i atrap; nie otwierano projektanta IDE.

## SixPack i ILS na uproszczonym PFD

- `VerifySixPack` — PASS: rzeczywisty render VCL do bitmapy. Sprawdzono piksele rombów LOC/GS po obu stronach środka, stałość skal przy zmianach pitch/bank, niezależną utratę sygnału LOC i GS, wyłączenie ILS przy GPS, NaN, ograniczenie zakresu i puste romby na końcach skali. Test kilku kolejnych klatek kontroluje również usuwanie poprzednich wskazań. Przejrzano wygenerowany `tests/pfd-ils-preview.png`.
- Ten sam test — PASS: bezpośrednia klasa bazowa SixPack to `TFrame`; wcześniejsze testy stałego zakresu VSI, cache indeksów, mechaniki wysokościomierza, baro, metrycznych wskazań, dokowania, synchronizacji i migracji brakujących pól nadal przechodzą.
- `VerifyDetachedViews` — PASS: odczyt głównego DFM, obecność i odłączanie/ponowne dokowanie SixPack oraz pozostałych framów, zachowana synchronizacja. `check_project.py` sprawdza teraz także bezpośrednie dziedziczenie po `TFrame` wszystkich klas użytych jako `inline` w DFM.
- Próby syntetyczne; nie sprawdzano lotu z rzeczywistym ILS ani ponownego otwierania formularza w projektancie Delphi. DFM zakładki SixPack pozostaje zachowany; nie odtwarzano zmian zapisanych po wybraniu Ignore.
- Zakresy HSI CDI ±127 i GSI ±119 oraz flagi sygnału potwierdzono w [oficjalnym SDK MSFS 2024](https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/SimVars/Aircraft_SimVars/Aircraft_RadioNavigation_Variables.htm). To wychylenia wskazówki, nie kąty w stopniach.

## Mutex rejestratora i zgodność framów z projektantem

- `VerifySetup`: rzeczywisty nazwany obiekt Windows `MSFS24-FDR-Run_Once`; pierwsze uruchomienie uzyskuje uchwyt, drugie zostaje odrzucone, zamknięcie uchwytu pozwala uruchomić ponownie. Sprawdzono wykrywanie mutexu przez instalator.
- `VerifySetupUI`: rzeczywisty modalny formularz DFM `frmSetupRunning`, `bsDialog`, `mrRetry` i `mrCancel`. Timer testowy trzykrotnie wybiera Ponów; dopiero zwolnienie mutexu dopuszcza kontynuację. Anuluj zgłasza przerwanie operacji i pozostawia mutex rejestratora aktywny. Regresja małego aktualizatora i awarii API również przeszła.
- `VerifyUI`: odczyt DFM frmMain, utworzenie i pokazanie interfejsu VCL, wykresy, mapa i synchronizacja przeszły po zmianie baz framów przyrządów i silników na bezpośredni `TFrame`. Nie wykonano ręcznego ponownego otwarcia formularza w projektancie Delphi; zgodność projektanta wymaga jeszcze potwierdzenia w IDE.
- Bez zamykania rzeczywistego rejestratora, bez instalowania do Program Files i bez zmian produkcyjnego rejestru. Test wykrywania procesu starszego EXE bez mutexu nie był wykonywany jako osobna próba procesu.

## 0.1.1 — Instalator w Setup, i18n, konserwacja i PEM

Wykonano w Delphi 10.2 Win64, na izolowanych plikach i formularzach VCL. Nie uruchamiano produkcyjnego instalatora na prawdziwej instalacji ani nie zmieniano prywatnych danych użytkownika.

- `VerifySetupMaintenance`: lista Auto + 32 identyczne kody językowe jak w aplikacji; Windows autodetect przy braku preferencji, zapis i ponowny odczyt `[ui] language`, tłumaczenia kreatora i dialogu danych we wszystkich językach, RTL dla arabskiego/hebrajskiego i powrót do LTR. Weryfikowano rzeczywiste formularze z DFM.
- Ten sam test w wariancie `SETUP_RESOURCE_TEST` uruchomiono z kopii EXE w katalogu bez zewnętrznych fontów i katalogu i18n. Potwierdził osadzony katalog oraz rejestrację pięciu fontów z pamięci, następnie ponownie sprawdził 32 języki i BiDiMode.
- Konserwacja: wykrycie istniejącej instalacji i strony radiobuttonów, wybór naprawy, powrót do wyboru, odczyt wersji z metadanych przy brakującym EXE. Naprawa odtworzyła brakujący EXE i uszkodzony plik; znacznik czasu zdrowego pliku pozostał bez zmian. Osobny test listy wydań potwierdził wybór dokładnej wersji i brak cichego przejścia na nowszą przy jej niedostępności.
- Zachowanie danych: wszystkie cztery kombinacje ustawienia/nagrania, katalog Recordings, indeks, logi i WAL luźnego nagrania. Operacje wykonywano wyłącznie w `TestPathsU`.
- `tests/VerifyReleasePEM.dpr`: efemeryczny RSA-3072 zapisany jako zaszyfrowany AES-256 PKCS#8 PEM poza repozytorium, jawne hasło testowe przekazane przez stdin. Skompilowano izolowany natywny PackageRelease z kluczem publicznym tej pary; zebrał rzeczywiste binaria runtime z testowego bin, utworzył zaszyfrowany ZIP i manifest, podpisał oba przez OpenSSL i zweryfikował przez CNG. Porównano SHA-256 i wypakowane bajty EXE. Ustawienia, cache i private.pem nie trafiły do paczki, a congratulations.mfz nie został wypakowany.
- Po kompilacji podmieniono public.pem w źródłach i przy EXE: poprawny podpis nadal przeszedł, ponieważ używany jest klucz wkompilowany. Zmieniona sygnatura manifestu została odrzucona przed utworzeniem katalogu rozpakowania. Błędne hasło PEM przerwało pełne pakowanie i nie pozostawiło ZIP-a ani jego niekompletnych plików publikacji.
- Regresja: VerifySetup, VerifySetupUI, VerifySetupSignature, VerifySetupMaintenance, VerifyGlobalLocales, VerifyLocaleExpansion, VerifyVersionLanguage, VerifyRTLReturn, VerifyReport, VerifyFMCReplay, VerifyUI, VerifyAppStorage, VerifyRecordingImport — przeszły. Dodatkowo skompilowano osobny PackageRelease.dproj w MSBuild oraz aplikację Debug/Release i Setup 0.1.1.19. Kontrole projektu, zależności, wersji, 1076 definicji tłumaczeń w 32 językach i dokumentacji przeszły.

Operacje rejestru, skrótów i uruchamiania procesów instalacyjnych były atrapami. Nie sprawdzano rzeczywistego UAC, systemowych skojarzeń, pełnej instalacji/naprawy/dezinstalacji, certyfikatu Authenticode ani lotu w MSFS. Hasło i klucz produkcyjny nie zostały wygenerowane; generator wymaga lokalnego wyboru hasła. Nie opublikowano wydania. Test podpisanego ZIP-a dotyczył pary testowej, nie gotowej produkcyjnej paczki. Pozostałe wpisy poniżej opisują wcześniejszy stan, w tym poprzedni klucz CNG.

## 0.1.1 - Menu Start

Menu Start: folder DJ M@fi0z0™ zawiera skr?t aplikacji oraz Odinstaluj MSFS24-FDR wskazuj?cy Setup.exe z /uninstall. Oba podlegaj? istniej?cej opcji Menu Start. VerifySetup sprawdzi? migracj? starego skr?tu, cele i argumenty, wy??czenie opcji oraz usuwanie w?asnych skr?t?w z zachowaniem plik?w innych produkt?w. Operacje skr?t?w by?y atrapami w izolowanym katalogu, bez zmiany prawdziwego Menu Start.

## 0.1.1 ? OmniXML

Edycja exe.xml u?ywa teraz interfejs?w IXMLDocument/IXMLNode i natywnego backendu OmniXML, bez automatyzacji OLE i bez MSXML. VerifySetup sprawdza XML przed CoInitialize: dodanie/usuni?cie w?asnego wpisu, idempotencj?, zachowanie obcych wpis?w i komentarzy, pusty dokument, Unicode i znaki specjalne w ?cie?ce, deklaracj? UTF-8 oraz odrzucanie DTD i uszkodzonego XML. Test instalacji dzia?a na izolowanych plikach i atrapach operacji systemowych; nie zmieniano produkcyjnego exe.xml.

## 0.1.1 — Podpisy wydań

Instalator testowano na syntetycznych plikach w izolowanym katalogu; rejestr, procesy i skróty zastąpiono atrapami. Nie instalowano aplikacji w rzeczywistym Program Files ani nie zmieniano systemowego exe.xml.

- `VerifySetup`: numeryczne porównanie wersji, wybór paczki GitHub i odrzucanie draftów/obcych URL; szyfrowanie i odczyt ZIP, błędne hasło, korupcja CRC, archiwum bez szyfrowania, traversal/ADS/nazwy urządzeń. `congratulations.mfz` nie jest wypakowywany. MSXML zachowuje obce wpisy, nie duplikuje własnego i odrzuca DTD. Instalacja/aktualizacja/dezinstalacja działają na prawdziwych plikach testowych; sprawdzono rollback kopiowanych plików, manifest i wymianę setup.upd. Sprawdzono też DFM changeloga i zapis opcji aktualizacji.
- `VerifySetupUI`: formularz kreatora, opcje i cofanie, mały layout 440×130; lokalny serwer HTTP zwraca błąd API, brak nowszego wydania i błąd pobrania. Test potwierdza aktywność pętli VCL i uruchomienie starej aplikacji bez ponownego sprawdzania aktualizacji.
- `VerifySetupSignature`: prawdziwe Windows CNG i efemeryczny klucz testowy RSA-3072; poprawny PSS/SHA-256/sól32 oraz odrzucanie zmienionego podpisu, skrótu, soli20 i pustego klucza. Izolowana zapamiętana wersja nie może zostać zmniejszona.
- Paczka wydania: podpisanie .NET RSACng i weryfikacja natywnym kodem Delphi/CNG, kontrola CRC i wszystkich bajtów po rozpakowaniu, brak wypakowanego decoya. Niezależny Python zipfile potwierdził zgodność ZipCrypto na jawnym haśle testowym.
- Regresja: VerifyReport, VerifyFMCReplay, VerifyUI, VerifyRecordingImport, VerifyAppStorage, VerifyRTLReturn. Debug/Release Win64 i osobny Setup kompilowane w Delphi 10.2; kontrola jawnych unitów, projektów testowych i tłumaczeń.

Nie sprawdzano rzeczywistego UAC, certyfikatu Authenticode, publikacji ani lotu w MSFS. Test kopiowania nie oznacza pełnej transakcyjności rejestru, skrótów i XML przy awarii zasilania. Klucz produkcyjny pozostaje w magazynie CNG profilu wydawcy; test RSA używa klucza efemerycznego.

Weryfikacja ko?cowa w docelowym repozytorium: Debug i Release Win64 oraz Setup 0.1.1.16. Wszystkie dziewi?? wymienionych test?w i kontrole projektu, zale?no?ci, wersji, 1048 definicji t?umacze?/32 j?zyk?w oraz dokumentacji przesz?y. Gotowa paczka ma 80 szyfrowanych wpis?w. Osobna pr?ba na kopii paczki odrzuci?a zmieniony ZIP, podpis ZIP, manifest, podpis manifestu oraz brak podpisu manifestu ? katalog rozpakowania nie powsta? w ?adnym przypadku. Przeniesiono sze?? grup ustawie? kompilatora wygenerowanych przez IDE przed import CodeGear.Delphi.Targets; w trzech DFM frame ponownie usuni?to w?a?ciwo?ci zastrze?one dla TForm, zachowuj?c wymiary.

## 0.1.2.15 — Import, podgląd i zasoby DFM

Wykonano testy na syntetycznych danych SQLite i formularzach VCL, bez uruchamiania produkcyjnego EXE na prywatnej bazie ani połączenia z MSFS.

- `VerifyRecordingImport`: migracja jednego lotu, dopisanie następnego do już oznaczonej jako przetworzona bazy legacy, ponowny import bez duplikacji, porównanie SHA-256 oryginału; wykrywanie luźnego `.mfzr`, powtórny skan bez duplikacji oraz izolacja błędnego pliku. Import pliku już należącego do indeksu nie duplikuje nagrania.
- Ten sam test uruchamia osobny proces z jednym argumentem wskazującym rzeczywisty syntetyczny `.mfzr`. Sprawdza parametry lotu, trzy zakładki przyrządów z DFM, ukrycie LeftPanel i splittera, wyłączenie nagrywania i zarządzania, bezpieczne bezpośrednie wywołanie zablokowanych handlerów oraz brak domyślnego indeksu i blokady rejestratora. Osobno próbuje usunąć dane przez połączenie read-only: SQLite odrzuca zapis, a SHA-256 nagrania pozostaje identyczny. Renderowanie obu ikon importu na jasnym tle ma przezroczysty narożnik.
- Regresja: `VerifyUI`, `VerifyDetachedViews`, `VerifyHelpAbout`, `VerifyGroups`, `VerifyPort`, `VerifyLegacy`, `VerifyRecorderWorker`, `VerifySession`, `VerifyViewState`, `VerifyFMCReplay`, `VerifyMetar`, `VerifyRecordingFiles`, `VerifyRecordingTree`, `VerifyRecordingUI`, `VerifyRecordingWorker`, `VerifyTripInfo` — wszystkie przeszły. Zakres wcześniejszych testów opisano poniżej.

Nie wykonywano rzeczywistego lotu ani ręcznego klikania systemowego dialogu wyboru pliku. Użyto rzeczywistego SQLite i procesów potomnych; nie sprawdzano każdej możliwej fizycznej korupcji pliku. Nowy test zarejestrowano w Tests.groupproj i domyślnym test.ps1.

Weryfikacja końcowa w docelowym repozytorium: Debug i Release Win64 skompilowane w Delphi 10.2, VersionInfo 0.1.2.15. Powtórnie przeszły VerifyRecordingImport, VerifyRecordingUI i VerifyViewState oraz kontrole projektu, wersji, katalogu 1044 tłumaczeń w 32 językach i dokumentacji. Kopia katalogu w bin jest identyczna ze źródłową. Poprawiono kolejność ustawień MSBuild i hooka wdrażania tłumaczeń; pliki pomocnicze osobnego instalatora nie są traktowane jako unity aplikacji rejestratora.

## 0.1.0.14 — indeks i osobne pliki lotów

Wykonano na syntetycznych danych SQLite/VCL, z izolowanymi katalogami `TestPathsU`:

- `VerifyRecordingFiles`: dwa kolejne nagrania w oddzielnych plikach; indeks bez tabel telemetrii; przejścia recording/finalizing/completed; ścieżki ICAO i nazwy z datą; rozdzielenie próbek/zdarzeń; brakujący plik zachowuje metadane; odrzucanie wyjścia ścieżką poza magazyn. Migracja trzech lotów z jednej bazy: grupy, kolizje nazw, surowe teksty FMC, JSON formatowania i kontrolek, dodatkowa tabela `trip`, wersja schematu, ponowne otwarcie bez powtórnego upgrade oraz idempotencja. Oryginał porównany bajt po bajcie.
- Ten sam test uruchamia proces potomny i kończy go przez `TerminateProcess`, bez destruktorów i checkpointu. Sprawdzono istniejący WAL, odzyskanie zatwierdzonej próbki, stan interupted, awarię pomiędzy rename a zapisem ścieżki w indeksie oraz zachowanie uszkodzonego pliku i metadanych przy błędzie integralności.
- `VerifyRecordingTree`: kolejność wszystkich poziomów według najnowszego potomka, kolejność rodzeństwa, pełne miesiące PL/DE, identyfikatory nowych tłumaczeń, zerowane składniki czasu, ikony 29/63, prefiks aktywnego nagrania, zachowanie zaznaczenia, grupa + wyszukiwanie bez rozróżniania wielkości liter, puste filtry i usuwanie pustych gałęzi z prezentacji, ukrycie brakującego pliku bez usuwania metadanych.
- `VerifyRecordingUI`: rzeczywisty formularz z migrowanym plikiem, zaznaczenie/dwuklik, parametry i ramki przyrządów, niedostępny aktywny węzeł, reset wyszukiwania i wybór folderu. Zautomatyzowany dialog odzyskiwania: odmowa nie usuwa pliku ani metadanych, następny start pyta ponownie, zgoda umożliwia otwarcie odzyskanego nagrania.
- `VerifyRecordingWorker`: rzeczywisty wątek rejestratora, syntetyczny SimConnect, blokada zapisu SQLite w pojedynczym pliku; heartbeat VCL i nieblokujące polecenia, wiele próbek, finalizacja ścieżki/statusu oraz poprawne zamknięcie.

Nowe programy dodano do `tests/Tests.groupproj` i domyślnego `test.ps1`. Testy poprzedniego interfejsu używają drzewa zamiast usuniętego DBGrid. `VerifyFMCReplay` przeniesiono z globalnego TEMP do izolowanego katalogu testu. Nie uruchamiano produkcyjnego EXE na prywatnej bazie użytkownika, nie wykonywano lotu w MSFS ani nie certyfikowano odzyskiwania wszystkich fizycznie uszkodzonych baz. Historia poprzednich testów poniżej pozostaje aktualna dla opisanych tam wersji.

Weryfikacja końcowa: przeszło 15 zestawów regresyjnych (`VerifyUI`, `VerifyDetachedViews`, `VerifyHelpAbout`, `VerifyGroups`, `VerifyPort`, `VerifyLegacy`, `VerifyRecorderWorker`, `VerifySession`, `VerifyViewState`, `VerifyFMCReplay`, `VerifyMetar` oraz cztery nowe testy nagrań). Miesiące sprawdzono też dla ar-SA i he-IL z kalendarzem gregoriańskim. Test UI obejmuje potwierdzone usunięcie tylko wybranego pliku oraz odmowę usunięcia zajętego pliku bez utraty metadanych i z bezpiecznym wyczyszczeniem inspektora. Debug i Release Win64 kompilują się w Delphi 10.2; VersionInfo: 0.1.0.14. Kontrole projektu, wersji, katalogu tłumaczeń i dokumentacji przeszły.


Lista nagrań używa `vstRecordings: TVirtualStringTree` zgodnie z nowym układem formularza. Stan wyłączenia węzłów jest natywny; odświeżanie zachowuje wybór, rozwinięte katalogi i pozycję przewijania. Do budowania potrzebne są źródła Virtual TreeView V8: domyślnie sąsiedni `..\Virtual-TreeView\Source`, ewentualnie `vendor\Virtual-TreeView\Source`. Można podać `-VirtualTreeRoot` do `build.ps1`/`test.ps1` lub `/p:VirtualTreeRoot=...` do MSBuild. Ta sama ścieżka obowiązuje w projekcie IDE i grupie testów. Wersja EXE nie wymaga dodatkowej biblioteki uruchomieniowej tego komponentu.


Ponowiono komplet 16 wymienionych zestawów po przejściu na TVirtualStringTree (łącznie z VerifyTripInfo). Dodatkowo w docelowym repozytorium przeszły VerifyRTLReturn i VerifyGlobalLocales: 32 języki, fonty i przełączanie RTL/LTR. Razem 18 zestawów regresyjnych. Obejrzano syntetyczny native-preview.png z VerifyUI: widoczne drzewo, lokalizowany miesiąc, ikony i zaznaczone nagranie. Końcowe Debug/Release Win64 oraz pięć izolowanych testów magazynu/informacji o locie w docelowym repozytorium: PASS.


## 0.1.0.13 — zakresy, indeksy i wysokościomierz (2026-10-21)

Rozszerzono istniejący `VerifySixPack` (już wpisany w `Tests.groupproj`). Syntetyczne nagranie zawiera VSI 100 i -5600 ft/min, NaN, Infinity oraz krótszą tablicę wartości. Zakres od pierwszej próbki wynosi 6000 ft/min i pozostaje stały podczas przewijania w obu kierunkach. Przy braku VSI minimum wynosi 2000. Także IAS ma zakres stały dla podpiętych danych. Zmiana ft/min→m/s zachowuje iloraz wartości i zakresu. Nie oceniano wskazań w locie MSFS.

Testowa podklasa listy liczy wywołania IndexOf: 3003 etykiety i 1000 kolejnych SetPoint nie powodują kolejnych wyszukiwań. Sprawdzono zmianę kolejności przy tej samej liczbie etykiet, przemianowanie na nieznany parametr, zmianę obiektu nagrania oraz Clear. Revision zachowuje działanie klienta OnChange. To kontrola ścieżki TSixPackDisplay, nie pomiar czasu całej aplikacji ani panelu silników. Przy niezmiennych etykietach edycja samych wartości wymaga Clear do ponownego wyznaczenia zakresów; normalny replay nie modyfikuje podpiętych próbek.

Dla 12500 ft test sprawdza kąty trzech wskazówek 180°/90°/45°, niezmienność po ft→m i odczyt 3810 m. Porównuje także piksel na rzeczywistej długiej wskazówce renderu przed/po konwersji, a nie samą funkcję pomocniczą. Dodatkowo -500 ft (zawijanie wskazówki), NaN, dotychczasowe ILS/baro, odłączanie, mały rozmiar, RTL i NULL po migracji. Obejrzano `tests/six-pack-metric-preview.bmp`: legenda FT i metryczny odczyt z zachowaną mechaniką stopową.

Zaliczone testy regresji: VerifySixPack, VerifyDetachedViews, VerifyViewState, VerifyDisplayUnits, VerifyEngineGauges, VerifyPort, VerifyUI. Nie powtarzano całej listy 53 Verify. Zmiana TPlotLabels dotyczy modelu pamięci; definicje SQL i zapis surowych danych pozostają bez zmian. Build zwiększony raz do 0.1.0.13; kontrole projektu i istniejącej grupy testów wymagane jak poprzednio.


Końcowa próba w docelowym repozytorium: wszystkie siedem wymienionych testów ponownie PASS. Debug i Release Win64 zbudowane z VersionInfo 0.1.0.13. Brak zmian konfiguracji/bazy użytkownika; produkcyjnego EXE nie uruchamiano.


## 0.1.0.12 — zapis stanu widoków (2026-10-21)

Nowy `VerifyViewState` zarejestrowany w `tests/Tests.groupproj` i domyślnej liście `test.ps1`. Test syntetyczny VCL/INI/SQLite, bez lotu ani otwierania prywatnej konfiguracji. Przechodzi wielokrotne utworzenie i zniszczenie frmMain na izolowanej konfiguracji: sześć odłączanych frame'ów (w tym SimBrief), różne pozycje/rozmiary, zamknięcie aplikacji bez utraty stanu odłączenia, automatyczne odtworzenie, powrót przyciskiem i przez X, niezależność pozostałych okien oraz zachowanie geometrii po zwinięciu. Dodatkowy nieznany wcześniej frame `future_hud` potwierdza rozszerzalność rejestru bez osobnego kodu zapisu.

Dalsze asercje: maksymalizacja zachowuje normalne wymiary, minimalizacja nie zapisuje wymiarów ikony i nie odtwarza zminimalizowanego okna, ponowny `Restore` nie otwiera zwiniętego widoku, reset zwija widoki i usuwa ich sekcje, błędne/powtórzone ID są odrzucane, przeliczanie rozmiaru po emulowanej zmianie DPI oraz naprawa współrzędnych poza ekranem/MaxInt i nieprawidłowego rozmiaru/PPI. Nie odłączano fizycznie monitorów ani nie zmieniano DPI Windows — test emuluje wartości INI.

Zaliczone testy regresji: VerifyViewState, VerifyDetachedViews, VerifyUI, VerifySimBriefUI, VerifyRTLReturn, VerifySixPack, VerifyEngineGauges. Nie uruchamiano ponownie całego zestawu 53 Verify; wpis o 52 testach poprzedniej wersji opisuje tamten przebieg. Kontrole DPR/DPROJ, grupy testów, i18n, wersji, fontów i dokumentacji przechodzą. Usunięto ponownie właściwości TForm zapisane przez IDE w DFM six-packa, zachowując ręczne wymiary i wygląd. Numer Build zwiększono raz do 0.1.0.12.


Końcowa weryfikacja w docelowym repozytorium: wszystkie siedem powyższych testów ponownie PASS; aplikacja zbudowana jako Debug i Release Win64 z VersionInfo 0.1.0.12. Nowy test zbudowano również przez docelowy target `Tests.groupproj` w kopii roboczej i uruchomiono powstały EXE. Nie uruchamiano produkcyjnego EXE ani migracji prywatnych danych.


## 0.1.0.11 — izolacja baz i panele przyrządów (2026-10-21)

Wykonano pełny zestaw **52 programów Verify** przez `test.ps1`: wszystkie zakończyły się kodem 0/PASS. To testy syntetyczne SQLite/VCL i atrapy SimConnect/IPC/HTTP/CLI; nie wykonano lotu ani walidacji wskazań z uruchomionym MSFS. Zachowano istniejące testy regresji nagrywania, katalogów samolotów, FMC, FSHud, GSX, analizy, SimBrief, wykresów, jednostek, języków, RTL, migracji i wersji.

- `TestPathsU`, pierwszy unit Verify*, tworzy osobny katalog `.build/test-data/<nazwa>/<PID>-<tick>`. Przekierowuje bazy i ustawienia `PORT_TEST`; kopiuje tylko zależności testowe i fixtures. Testy migracji nadal pracują na własnych tymczasowych drzewach. VerifyPort, VerifyLegacy i testy VCL sprawdzono ponownie na nowych ścieżkach. Dane użytkownika z `bin`/LocalAppData nie są otwierane przez te testy.
- `VerifySixPack`: valid LOC/GS z niezależną normalizacją ±127/±119, blokada CDI GPS, utrata GS przy zachowanym LOC, brak flag/NaN, aktualne baro 1026 hPa, fallback 29.92 inHg→hPa i STD. Dotychczasowe próby obejmują znak pitch, heading wrap, pomiar turn/ball, jednostki, resize, odłączanie i migrację brakujących kolumn. Ograniczenie: kierunek wskazań i wygląd wymagają jeszcze porównania w locie.
- Nowy `VerifyEngineGauges`: klasyfikacja czterech układów, tłokowy/turboprop/jet, 0/1/2/4/16 silników i błędna liczba, osobne wartości N1, RPM/CHT/ITT/condition, odrzucanie niepasujących grup, poprawne zero paliwa i ukrywanie brakujących opcjonalnych wskazań, jednostka A, odłączanie/przywracanie tego samego frame, zmiana próbki, RTL→LTR, mały rozmiar i render bitmapy. Zapis/odczyt nowych pól i tytułu samolotu, precyzyjne ITT oraz SQL NULL→NaN dla nieodczytanych silników/ILS. Obejrzano `tests/engine-gauges-preview.bmp`.
- `VerifyDetachedViews`: dodatkowo panel silników w frmMain, przycisk powrotu, Close i synchronizacja z etykietą czasu. `VerifySubscriptions`: istniejąca atrapa potwierdza dobór typu/liczby silników i wyłączenie odczytu po zakończeniu sesji.
- Poprawka FireDAC: brakujący parametr silnika dostaje typ przed Clear/NULL. Wcześniej nowy test ujawnił błąd „Parameter V32 data type is unknown”; po poprawce PASS. Nie maskuje się brakujących danych zerami.

Dodane 123 pola SimConnect zachowują stare offsety: 11 wspólnych i 7 rodzin ×16 silników. Nowe kolumny są nullable; wcześniejsze nagrania nie zyskują wstecznie brakujących danych. Katalog ma 834 pola / 7080 bajtów, 123 kolumny liczbowe i 39 rodzin kolumn silników. Kontrole projektu potwierdzają 88 unitów w DPR/DPROJ, 1034 definicje i18n ×32 locale, fonty/licencje, dokumentację, katalogi add-on/AIRLINER i spójność wersji 0.1.0.11. Kontrola i18n weryfikuje strukturę/placeholdery/Unicode, nie poprawność terminologii przez native speakera; nowe opisy parametrów mają także techniczny fallback angielski.

Zegary mają ogólne skale, bez odwzorowania limitów konkretnego samolotu. `ikGaGlass` i `ikAirlinerPFD` są uproszczonym wspólnym widokiem, bez pełnego FMA, FD/PFD/ND Boeinga/Airbusa. Klasyfikacja używa dostępnego tytułu i danych silnika; niestandardowe nazwy mogą wymagać rozszerzenia. Referencje jednostek/flag: [engine SimVars](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-engine-variables/), [radio/navigation SimVars](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-radio-navigation-variables/).


Weryfikacja końcowa: wszystkie 63 projekty w `tests/Tests.groupproj` zbudowano przez MSBuild Delphi 10.2 (Debug/Win64, wydawca IPC Win32). Dodatkowo sprawdzono domyślne ustawienia grupy bez parametru Platform i uruchomiono jej EXE VerifyEngineGauges/VerifySixPack. Poprawiono ścieżkę zasobów VCL oraz flagi dostępności platform w metadanych IDE. Po scaleniu ręcznego formatowania ponownie PASS: VerifyEngineGauges, VerifySixPack, VerifyDetachedViews, VerifyPort, VerifyLegacy, VerifyDisplayUnits. Nowy test sprawdza też przejścia NULL→wartość→NULL na przygotowanym zapytaniu, ułamkowe baro 1026.35 i tłumaczenia nowych podpisów. Skale silników są wspólne dla porównywanych silników; baro zapisuje się jako REAL bez obcinania części ułamkowej.


Końcowa próba w docelowym repozytorium wykazała także trzy problemy checkoutu/zapisu IDE: porównywanie rekordów Name bez tolerancji spacji, sumy licencji OFL wrażliwe na CRLF oraz właściwości TForm (ClientHeight/ClientWidth/OldCreateOrder/PixelsPerInch/TextHeight) w DFM six-packa. Kontrole nazw i licencji poprawiono bez osłabiania weryfikacji nazw/treści/fontów; DFM zachowuje ręczne wymiary i wygląd jako poprawny TFrame. Kontrola licencji w ZIP też toleruje wyłącznie różnicę LF/CRLF. W repozytorium powtórzono siedem testów, dodając VerifyAddonLVars. Debug i Release Win64 0.1.0.11 przebudowano; programu produkcyjnego nie uruchamiano, bez migracji prywatnych danych podczas testowania.


## 0.1.0.10 — subskrypcje lotu i natywny six-pack (21.10.2026)

Pełny `test.ps1`: **51 programów PASS**, Delphi 10.2 Win64, odizolowane dane. Kontrole: 85 unitów DPR/DPROJ, 1014 definicji × 32 locale, fonty, wersja i dokumentacja: PASS. Nie uruchamiano produkcyjnego EXE ani migracji prywatnej bazy. Starsze wyniki poniżej są historią.

- `VerifySubscriptions` + nowy `MockLifecycleSim.dll`: po połączeniu tylko trzy pola identyfikacyjne; brak pełnego odczytu w menu; aktywacja przez AircraftLoaded/SimStart bez FlightLoaded; różne kolejności FlightLoaded/SimStart; 2 silniki odrzutowe, 4 tłokowe i 1 turbośmigłowy; odrzucanie nadmiarowych indeksów i niepasujących rodzin; przebudowa przy ponownym AircraftLoaded tego samego modelu; zmiana tytułu wykryta także w pakiecie pełnej telemetrii; anulowanie żądań i czyszczenie definicji; odrzucenie starego pakietu po zakończeniu; sam cached AircraftLoaded nie wznawia lotu; SimStart korzysta ze świeżego potwierdzenia FlightLoaded, odrzuca MAINMENU. Tylko mock DLL, bez symulatora.
- `VerifyAddonLVars`: osiem katalogów i 5050 pól, selekcja wyłącznie providera TFDi dla tego tytułu; zamknięcie przy nieaktywnym locie; izolacja brakującego pola, ograniczona kolejka ONCE, null, zapis zmian i odczyt na wykresie. Po scaleniu formatowania rozszerzono test o jawny standardowy binding `A:LIGHT NAV`: usunięcie prefiksu A i przekazanie jednostki bool do transportu.
- `VerifySixPack`: rzeczywisty natywny render VCL, ta sama próbka na osi czasu, odwrócenie znaku pitch, normalizacja 361° → 1°, wskazywana wysokość, rzeczywista prędkość zakrętu i kulka; ta sama instancja frame po odłączeniu/zamknięciu; RTL/LTR; jednostki i zachowanie surowych danych; nieprawidłowy indeks i brak pola; mały rozmiar; odtworzenie starego schematu bez dwóch kolumn i migracja; NULL zachowany jako NaN podczas replay. `six-pack-preview.bmp` obejrzano; PNG w `docs/screenshots/six-pack.png` jest syntetyczną próbką, nie zrzutem lotu na żywo.
- Rozszerzony `VerifyDetachedViews`: zakładka głównego okna, odłączenie i powrót przyciskiem/Close, synchronizacja czasu i odczyt indicated_altitude. Asercje six-pack umieszczono w osobnej procedurze po błędzie generatora kodu Delphi 10.2 w rozbudowanym programie testowym; zakres asercji zachowano.
- Powtarzalny audyt lokalny: **120 pakietów, 2046 locpaków**, wyłącznie jawne dane; metadane i SHA-256 w `support/official-aircraft/locpak-audit.json`. Przetłumaczonych nazw kodu nie użyto jako SimVarów. Bell 407: 72 bindingi, EC135: 234. **18 wariantów** sześciu rodzin komercyjnych, 39 XML: poprzednie pięć rodzin nadal 3298 L-varów; TFDi MD-11 GE/PW/pasażerski/towarowy dodaje 1446. Katalog rodzinny to suma dostępnych nazw, nie dowód działania każdego pola w każdym wariancie.

Definicje nowych wskazań sprawdzono w [oficjalnych szablonach przyrządów SDK](https://docs.flightsimulator.com/msfs2024/html/5_Content_Configuration/Models/ModelBehaviors/TemplateExplorer/Asobo_EX1/Common/Interior/Templates/ParametersFn/Instrument_ParametersFn.html) i [SimVars](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-system-variables/). Odbiór danych podczas rzeczywistego lotu i wszystkie warianty samolotów pozostają **nieprzetestowane na żywo**. TFDi korzysta z literalnych L-varów modeli, bez niedostarczonego nagłówka/binarnego SDK. Zera nie potwierdzają dostępności L-varów; six-pack nie emuluje awarii ani dynamiki fizycznych przyrządów.

Końcowa kompilacja wdrożonego repozytorium **Debug i Release Win64 PASS**, FileVersion **0.1.0.10**, zgodny katalog tłumaczeń i symbole PDB. Zachowano równoległe ręczne formatowanie czterech plików. Po scaleniu ponownie wykonano VerifyAddonLVars (w tym standardowy binding z jednostką), VerifyDetachedViews i VerifySixPack: PASS. Plików zainstalowanych samolotów ani prywatnych nagrań/ustawień nie zmieniano.

## 0.1.0.9 — rozszerzony eksport A320 i integracje samolotów

Pełny `test.ps1`: **49 programów PASS** (Delphi 10.2, izolowane dane). Nowe `VerifyPMDG777`, `VerifyAddonLVars` i `VerifyFlightPadAppearance` sprawdzają 522 pola SDK i trzy CDU, 3298 L-varów pięciu rodzin, izolowanie błędów, kolejkę odczytu, zapis tylko zmian oraz rzeczywisty IPC Win32 → Win64 z kolorami, małą czcionką, kontrolkami, zmianami samego formatowania i niedostępnością ekranu. Rozszerzony `VerifyFMCReplay` sprawdza automatyczne rozpoznanie rodziny oraz zakładki CDU.

Układ wszystkich pól oryginalnego nagłówka PMDG 777 zweryfikowano niezależnie przez clang-cl (offsetof/sizeof): PASS. FlightPad: `ExportTests` i `ExportAppearanceTests` Win32 PASS; cztery aplikacje Fenix/FBW MCDU/Screen skompilowane. Kontrole projektu (73 unity), wersji, tłumaczeń i katalogów SDK/L-varów: PASS. Nie wykonano testu na żywo w symulatorze: testy DLL są mockami; zera nie dowodzą dostępności L-vara. Nie zmieniano plików samolotów ani prywatnych danych.

Kompilacja wdrożonego repozytorium Debug i Release Win64: PASS, FileVersion 0.1.0.9; zgodność katalogu tłumaczeń i symbole PDB: PASS. Końcowy `check_project.py`: 73 unity PASS. Przy kontroli wykryto właściwości formularza w aktualnym DFM SimBrief; zamieniono ClientHeight/ClientWidth na Height/Width i usunięto trzy właściwości dostępne tylko dla TForm, zachowując aktualny układ. Produkcyjnego EXE nie uruchamiano.

## 0.1.0.8 — natywne widoki, dane w AppData, FMC/MCDU (21.10.2026)

**Pełny `test.ps1`: 46 programów Delphi — PASS** w odizolowanej kopii roboczej, Delphi 10.2 Win64. Kontrole katalogu 32 języków (1011 definicji), 68 unitów w DPR/DPROJ, fontów, wersji i dokumentacji: PASS. Starsze sekcje poniżej są historią, a nie wymaganiami bieżącej wersji.

Kompilacja zainstalowanych źródeł Debug i Release Win64: PASS, FileVersion 0.1.0.8, zgodny katalog tłumaczeń i symbole PDB. Kontrola importów PE i braku odwołań do loadera WebView2: PASS. Paczka `dist/native-storage-fmc-0.1.0.8/MSFS2024-FDR-Win64-0.1.0.8.zip`: 72 pliki, CRC/odczyt zwrotny, x64, załadowanie obu DLL z rozpakowanej paczki (SQLite 3.45.3), trzy tła FMC, cztery CHM; bez WebView2, Community, prywatnej konfiguracji i bazy. Nie uruchamiano produkcyjnego EXE, aby nie migrować prywatnych danych podczas testów.

- `VerifyAppStorage`: rzeczywista baza SQLite z zatwierdzonym rekordem w WAL, zamrożona rodzina DB/WAL/SHM jak po awaryjnym wyjściu; migracja i odczyt rekordu 12345; przeniesienie ustawień/logów; blokada przez uchwyt zapisujący bez częściowego celu; brak nadpisania istniejącej bazy/ustawień; ponowne wywołanie; odzyskanie publikacji `migration.pending`; plik źródłowy z atrybutem tylko do odczytu pozostaje, a kopia użytkownika jest zapisywalna. Wyłącznie katalogi testowe; nie migrowano prywatnej bazy ani prawdziwego Program Files. Produkcja wybiera LocalAppData, natomiast `PORT_TEST` izoluje dane obok testowego EXE.
- `VerifyFMCReplay`: dwa urządzenia, wybór ostatniego ekranu bez sięgania w przyszłość, przeliczenie UTC z offsetem i sufiksem dnia tygodnia, rozstrzygnięcie wspólnego czasu przez ID, przejścia power-off/unavailable, niezależność urządzeń, czyszczenie po zmianie lotu, przeniesienie tej samej instancji frame i powrót przez Close. Sprawdzenie LTR fizycznego CDU po hebrajskim i powrocie do PL. Natywny zrzut `tests/fmc-replay-preview.bmp` obejmuje tło B737, kolory, małą czcionkę i kontrolki EXEC/MSG; zrzut został obejrzany.
- `VerifyDetachedViews`: dodatkowo prawdziwe podpięcie FMC do `frmMain`, aktualizacja przez TimelineChange, wybór drugiego nagrania przy odłączeniu, przycisk powrotu, Close i zamknięcie głównego okna z odłączonym FMC. Dotychczasowe próby mapy/wykresów nadal PASS.
- `VerifyReport`, `VerifyFMCReplay`, `VerifySimBriefUI`: natywne TMemo bez wewnętrznych pasków i obramowania, Consolas, ReadOnly, zachowanie spacji/encje HTML, wzrost wysokości przy ponad 100 liniach, przewijanie kontenera; natywne pogrubienia/nagłówki/listy/kursywa/kod w TRichEdit, poprawne tytuły i zamykanie raportu. Zaktualizowano stary warunek testu ssHorizontal do wymaganego ssNone.
- `VerifyHelpAbout`: własny jawny lot testowy zamiast zależności od ostatniego nagrania pozostawionego przez wcześniejszy test. Pozostałe testy obejmują recorder/worker/WAL, parsery FMC, SDK na atrapach, SimBrief, pogodę, precyzję, jednostki, ikony, języki i RTL/LTR.

Nie wykonano lotu na żywo ani testu instalatora (nie jest jeszcze dodany). Starsze nagrania i tekstowy eksport FlightPad Fenix/FBW nie zawierają brakujących styli/kontrolek; renderer ich nie odtwarza przez zgadywanie. B777 to obsługa grafiki, nie nowa integracja SDK. Testy nie potwierdzają wszystkich wersji komercyjnych dodatków.


Po ostatniej poprawce ponowiono VerifyDetachedViews, VerifyChartsConfigure, VerifyLocalization i VerifyUI: PASS. Dodatkowo sprawdzono odwrotną kolejność zamykania okien, zachowanie opisu zakresu po zmianie języka, brak przechwytywania scrolla osobnego okna przez główne oraz wszystkie 43 ikony niezależnym porównaniem PNG.


## Osobne ramki i przywrócone akcje — 18 października 2026

**35 programów Delphi: PASS; 4 kontrole metadanych: PASS.** Pełny `test.ps1` uruchomiono w odizolowanej kopii. Nowa kontrola dokumentacji została wykonana dodatkowo po wygenerowaniu wersji językowych. Pozostałe sekcje poniżej są historią wcześniejszych wersji.

`VerifyDetachedViews` tworzy dwa syntetyczne loty o różnych osiach czasu. Odłącza niezależnie mapę i wykresy, także oba jednocześnie; porównuje tożsamość instancji i zakres przed/po przeniesieniu. Sprawdza synchronizację kursora z główną osią czasu, przełączenie nagrania podczas odłączenia, scroll/zoom ramki, tłumaczenie tytułów okien, przywracanie po Close i po akcji, wysokość mapy/splitter, wielokrotne otwarcie i zamknięcie oraz zniszczenie głównego okna z oboma widokami na zewnątrz. Faktyczny przycisk konfiguracji w odłączonych wykresach otwiera modalny dialog; timer sprawdza własne ikony dialogu i zamyka go przez akcję Anuluj. Nie używa symulatora ani modelu AI.

`VerifyChartsConfigure` sprawdza własną listę 3 ikon i 5 akcji, aktywność przy granicach listy, kolejność przez `aMoveUp`, ukrycie przez `aHide`, `aAccept`/`aCancel`, filtrowanie, zachowanie obcych parametrów i brak modyfikacji wejścia przed akceptacją. Nadal działa porównanie PNG obu pozostałych list i nieprzezroczystych flag. `VerifyUI` zachowuje kontrolę obecnego układu, zmienianych wymiarów MapPanel, splitterów, list tylko do odczytu, osi czasu i raportów otwieranych przez menu. `VerifyLocalization` obejmuje przeniesienie tłumaczenia etykiety do domeny fraGraph oraz akcje nowych okien.

`check_project.py`: 59 unitów jawnie w DPR/DPROJ, w tym dwie ramki i wspólny formularz okna. `check_translations.py`: 581 definicji w PL/EN/DE/ES i aktualne nazwy kontrolek. `check_airliner_catalog.py`: zgodność katalogu. `check_documentation.py`: komplet czterech wersji każdego własnego README i Testy oraz poprawne linki językowe. Dokumenty producentów i licencje pozostają oryginalne.

Testy są syntetyczne/lokalne. Nie wykonano nowego lotu ani produkcyjnego zapytania AI; dotychczasowe ograniczenia live pozostają. Log: `tests/verification.log`.


## Katalog .i18n, cztery języki i przegląd UI — 18 października 2026

**34 programy Delphi + 3 kontrole metadanych: PASS.** Uruchomiono `powershell -ExecutionPolicy Bypass -File test.ps1` w odizolowanej kopii źródeł. Po ostatniej korekcie dynamicznego opisu wykresów ponowiono VerifyLocalization, VerifyUI i VerifyReport. Konfiguracje Win64 Debug i Release skompilowano przez MSBuild/DPROJ. Poniższe starsze sekcje są historią wcześniejszych wersji; opis generatora JSON i nieaktywnych DE/ES nie dotyczy obecnej wersji.

- `check_translations.py`: rzeczywisty plik `translations/MSFS2024-FDR.i18n`, **422 literały i 150 właściwości**, komplet PL/EN/DE/ES, zachowane argumenty Format, Unicode bez zastępczych znaków, unikalne definicje i istniejące kontrolki DFM. Katalog załadowano przez bibliotekę i18n, nie własny parser aplikacji.
- `VerifyLocalization`: polski domyślnie; przełączanie przez faktyczne akcje PL/EN/DE/ES i aktualizacja otwartych formularzy, menu oraz dynamicznych opisów wykresów. Każda akcja głównego okna ma pozycję w menu i handler. Odczyt/zapis wyboru czterech języków, brak zmiany po Anuluj, trzy zakładki ustawień i trzy podzakładki dostawców, opisy i listy wyboru, tłumaczenie ramki/sekcji SimBrief, wywołanie z wątku i niezmieniony separator liczb.
- `VerifyReport`: osobne tytuły startu i lądowania, ponowne użycie okna, przełączanie języka tytułu (także DE/ES), zachowanie własnego tytułu dokumentu HTML/OFP. Zachowane testy Markdown, escapowania HTML i rzeczywistego przycisku Zamknij zwalniającego niemodalny formularz.
- `VerifyUI`: zapisane raporty obu zdarzeń otwierane przez nowe pozycje menu, kontrola ich podpisów bez wywoływania modelu AI. Nadal sprawdzane: modalne ustawienia wykresów, ponad 8 parametrów, kolejność/anulowanie, powiększanie, przesuwanie, oś czasu, mapa, plan, blokada edycji gridów, double-click nagrania i zapis wymiarów paneli.
- `VerifyChartsConfigure`: niezależna kopia konfiguracji i pozostałe dotychczasowe przypadki. Obie listy ikon: 34 główne + 6 SimBrief. Każdy piksel PNG porównany z niezależnym rysowaniem oryginału przez VCL na RGB(123,151,179), tolerancja 3 na kanał. Flaga BMP zachowuje wszystkie kolory, w tym czarne pasy, i przezroczysty margines. Przełączanie rzeczywistymi przyciskami nagrywania i starszego planu SimBrief w obie strony.
- `VerifySimBriefUI`: tworzenie TFrame z paskiem narzędzi bez błędu braku parenta, 15 sekcji, podgląd EPLL–EGLL, zwijanie/pamięć stanu, scroll całej zawartości, wielowierszowe memo i OFP, osobne okno i powrót ramki, dopasowanie pola konta/paska przy szerokości 240 px oraz treści tylko do odczytu.
- `check_project.py`: 56 unitów w DPR/DPROJ; dodatkowo wszystkie katalogi DCU/OBJ/HPP/DCP/BPL muszą prowadzić do `.build/$(Platform)/$(Config)`, a projekt musi wdrażać plik `.i18n`. Debug wymaga jawnej ścieżki zasobów VCL Release przy braku lokalnego EnvOptions.proj; po jej dodaniu kompilacja przeszła. Nowych DCU w `src` po kompilacjach: 0. Testy Win32/Win64 używają osobnych katalogów DCU.

Pozostałe testy nagrywania, bazy, delt, pogody, SimBrief, FMC/MCDU, iFly/Fenix/FBW/PMDG, GSX, FSHud i dostawców AI przeszły jako część pełnego zestawu. To testy syntetyczne/lokalne atrapy. Nie wykonano nowego lotu w MSFS ani wywołań produkcyjnych modeli AI. Obejrzano zrzuty ustawień (Ogólne/Analiza/Silniki AI), SimBrief i pasków narzędzi. Log pełnego przebiegu: `tests/verification.log`; instrukcja katalogu: `translations/README.md`.


## Przegląd ręcznych zmian interfejsu — 18 października 2026

Pełny zestaw po dostosowaniu do ręcznych zmian: **34 programy Delphi + 3 kontrole metadanych, PASS**. Po dodaniu opisów ikon ponowiono VerifyLocalization oraz VerifyChartsConfigure: PASS. Nowy projekt zachowuje nazwę `MSFS2024-FDR.dpr/.dproj`, skrypty i paczki wskazują właściwy EXE. Wszystkie 56 unitów są jawnie wpisane w DPR/DPROJ. Katalog i18n obejmuje 420 literałów i 130 właściwości komponentów; generator wykrywa odwołania do usuniętych/przemianowanych komponentów.

- **VerifyChartsConfigure:** niezależna kopia parametrów, filtrowanie bez utraty zaznaczeń, dodawanie/usuwanie wyboru, przesuwanie góra/dół i granice, ukrycie wykresu synchronizowane z checkboxem, zachowanie ustawień nieobecnych parametrów innych samolotów, brak zmiany danych wywołującego przed akceptacją, centrowanie przycisków po resize i PL/EN.
- **VerifyUI:** otwarcie nowego okna przez faktyczną akcję; timer testowy wybiera ponad 8 parametrów i akceptuje modalne okno. Ponowne otwarcie testuje kolejność, kolejne — Anuluj bez zmiany aktywnych wykresów. Zoom jest wywoływany przez akcje, a nie wyłącznie stare przyciski; pozostają testy scrolla, suwaka, mapy, inspektora i zapisu rozmiarów pozostałych paneli.
- **Ikony:** zachowane 26 indeksów. Dla PNG porównano każdy z 484 pikseli z niezależnym renderowaniem oryginalnego PNG przez VCL na tle RGB(123,151,179), z tolerancją 3 na kanał za zaokrąglenia. Pokryte są RGBA i paletowe PNG/tRNS. Porównano też wszystkie piksele oryginalnej flagi BMP, w tym ciemne pasy, oraz przezroczyste marginesy. Ikony nie są naprawiane przez usuwanie każdego czarnego koloru. Źródłowe pliki w Icons pozostają niezmienione. Obraz toolbar-preview.png oraz native-preview.png sprawdzono wizualnie.
- **Akcje:** kliknięcie rzeczywistego przycisku automatycznego nagrywania przełącza stan w obu kierunkach. PL/EN jest przełączane przez akcję, niedostępne DE/ES nie przełącza pozornie na polski. Sprawdzono angielskie opisy ikon.
- **Formularze/ramka:** poprawiono sekcje published komponentów, stare identyfikatory i18n oraz błędne właściwości formularza w DFM TFrame. Destruktor ramki sprawdza istnienie timera, a resize nie używa nieutworzonych kontrolek. VerifySimBriefUI, VerifyTripInfo, VerifyReport, VerifyOllama/Models i VerifyLocalization przeszły po aktualizacji nazw komponentów.

Lista obrazów ma 32-bitową przezroczystość, bez maskowania czarnego koloru; Vcl.XPMan zapewnia Common Controls v6 również dla kompilacji bezpośrednim dcc64. Pomocniczy RebuildToolbarImages odczytuje RGBA oraz paletę i tRNS, nie modyfikuje plików PNG/BMP. Zasób jest wbudowany w DFM. Testy używają syntetycznych danych/atrap, nie stanowią nowego lotu w MSFS.



## Lokalizacja i reorganizacja projektu — 18 października 2026

Po zmianie nazw unitów/klas, przeniesieniu źródeł do podkatalogów i wprowadzeniu lokalizacji wykonano pełny `test.ps1`: **33 programy testowe zakończyły się PASS**. Atrapy MockFlightPad32, MockFenixSim i MockPMDGSim zostały ponownie skompilowane. Kontrole projektu, katalogu AIRLINER oraz zgodności wygenerowanych tłumaczeń również przeszły. Pełny zestaw ponowiono po dodaniu komunikatów walidacji SimBrief i konfiguracji Ollama: 33 programy + 3 kontrole, PASS.

`VerifyLocalization` sprawdza:

- polski język domyślny, fallback nieznanego kodu oraz fallback nieznanego tekstu;
- DFM, przycisk Ustawienia, menu Plik/Narzędzia/Język i zmianę PL → EN → PL w otwartym głównym oknie;
- język nowo otwieranych Ustawień i raportu, tekst przycisku Zamknij i etykiety ramki SimBrief;
- dynamiczne tytuły sekcji SimBrief w obu językach po odtworzeniu tego samego payloadu;
- zapis `[ui] language`, odczyt wyboru z INI oraz brak zmiany języka po samym wczytaniu/anulowaniu ustawień;
- tłumaczenie elementów combo dostawców i wieloliniowego opisu DFM;
- odczyt tekstu w osobnym wątku oraz zachowanie `FormatSettings.DecimalSeparator`;
- renderowanie otwartego okna Ustawienia w English do `tests/settings-en-preview.png`; podgląd sprawdzono wizualnie.

Po dodaniu kontroli combo/opisu i podglądu ponowiono test lokalizacji osobno: PASS. Po pełnym zestawie uzupełniono jeszcze tłumaczenia opisów źródła planu, pustych sekcji i etykiet API w podglądzie oraz nagłówka bieżącego planu. Dla tych zmian ponowiono VerifyUI, VerifySimBriefUI i VerifyLocalization: PASS. Implementacja odczytu, parserów i schemat zapisu pozostały bez zmian. `VerifyMetar` porównuje teraz zlokalizowany prefiks błędu zamiast sztywnego tekstu angielskiego; sprawdzany przypadek pustej obserwacji pozostał ten sam.

`tools/check_project.py`: wszystkie **55** lokalnych unitów są wpisane dokładnie raz w DPR/DPROJ; nazwa unit odpowiada plikowi, pliki mają U, formularze mają DFM, własne klasy nie mają prefiksu TNative. Aktualizowano również include i ścieżki generatorów, testów, kompilacji oraz metadane IDE Win64.

`tools/generate_translations.py --check`: **420** literałów i **103** właściwości formularzy/ramki; oba języki i zgodne placeholdery Format, wygenerowany katalog zgodny z JSON. Katalog jest wbudowany i korzysta z TLocalizer/TTranslator pakietu i18n. Test nie uruchamia chmury ani modelu AI.

`build.ps1`: kompilacja Delphi 10.2 Win64 PASS, z lokalnymi zależnościami vendor oraz rekurencyjnymi ścieżkami src. `check_dependencies.py`: Win64 PE, brak importów Qt. `package.py`: paczki źródłowa/release z nowym układem, JSON tłumaczeń, dokumentacją PL/EN, źródłami/licencją MIT i18n i konfiguracją language=pl-PL; asercje obecności plików i braku baz/lokalnych kluczy PASS.

Dodatkowo rozpakowano gotową paczkę źródłową do osobnego katalogu `.build/source-smoke` i skompilowano przez zawarty w niej `build.ps1`, ze wskazaniem nieistniejącego SDKRoot wymuszającym lokalny runtime: PASS. Kompilacja użyła źródeł i18n/WebView4Delphi z paczki, bez sąsiednich projektów. To weryfikuje także przenośność układu katalogów. W docelowym repozytorium wykonano również MSBuild dla MSFS2024-FDR.dproj, Config=Release, Platform=Win64: PASS.

W trakcie pracy zachowano równoległe formatowanie unitów w docelowym repozytorium. Dla czytnika i katalogu iFly oraz kolejnych unitów porównano tokeny poza formatowaniem; w IFlyDisplays dodatkowo rozdzielono grupowe deklaracje tych samych typów. Ponowione VerifyAircraftSDK i VerifyIFlyDisplays: PASS. Końcowe paczki powstają bezpośrednio z docelowego repozytorium, aby zachować jego bieżący układ kodu.

To regresja na danych syntetycznych/atrapach i kontrola interfejsu. Nie wykonano w ramach tej zmiany nowego pełnego lotu MSFS, oceny modelu AI ani testu rzeczywistej telemetrii wszystkich producentów. Historyczne próby na żywo opisane niżej zachowują swój pierwotny zakres. Surowe FMC, METAR/OFP i raporty już zapisane w bazie nie są przepisywane przy zmianie języka.



Ostatnie pelne uruchomienie: **18.10.2026**, wyswietlacze iFly i metadane FMC. **32/32 programow testowych PASS**, dwie kontrole metadanych PASS, 53 lokalne jednostki w DPR/DPROJ. Kompilacja atrap i wydawcy Win32 poprawna.

## Wyświetlacze iFly i metadane ekranów — 18 października 2026

Przygotowanie repozytorium `.`: sprawdzono przez git check-ignore 13 ścieżek lokalnych/wygenerowanych, które mają być pomijane, oraz 15 ścieżek źródeł, zasobów, dokumentacji i konfiguracji przykładowej, które mają pozostać dostępne do importu. Wszystkie reguły przeszły. git ls-files --others --exclude-standard wskazał 151 nowych plików kandydujących do importu; wśród nich nie było baz, lokalnych konfiguracji, bibliotek ani wyników kompilacji. Zmiany dotyczą .gitignore i opisów, bez zmiany kodu aplikacji; nie powtarzano pełnych testów Delphi. Nie wykonano git add, commita ani push. Reguły ignorowania nie usuwają plików wcześniej śledzonych przez Git.

Ustalenie zakresu PMDG NG/MAX: sprawdzono ścieżkę ParseFMCValues — zarówno iFly737MAX, jak i PMDGNG3 korzystają ze wspólnego ParseBoeingPerformance oraz wspólnego odczytu V-speeds. Zapisano to jako założenie robocze w Boeing-performance.md. Nie zmieniano zachowania parsera ani transportów i nie wykonano dodatkowego testu na żywo w PMDG. Nie zweryfikowano numeracji aktualizacji oprogramowania FMC; nie jest ona używana do wyboru parsera.

Dodano `aircraft/ifly/IFlyDisplaysU.pas`, zaktualizowano DPR/DPROJ i kontrolę projektu. Odczyt i layout 2411 pól SDK pozostają bez zmian; składanie i usuwanie segmentów dotyczy kopii zapisywanej w historii ogólnej. Tabela FMC otrzymuje nullable kolumny style_json, annunciators_json i formatted_html przez istniejącą migrację EnsureTable. Kontekst analizy ma wersję 13. Opis formatu: `support/fmc/IFly-display-storage.md`.

Nowy VerifyIFlyDisplays jest testem syntetycznym z osobną bazą SQLite. Sprawdza:

- Złożenie Flight Altitude 35000 i podpisanego Landing Altitude -500, HDG 123, VS -1500, Fuel Quantity 03875 jako 3875 oraz ADF 0890.0 jako 890 z aktywnym czwartym punktem. IRS zachowuje N51436 i osobną maskę punktów 7. Wygaszony wyświetlacz daje null. Nieokreślona pozycja kropki Mach nie daje zmyślonej wartości.
- Rozróżnienie pól cyfr od przełączników o nazwach kończących się np. _1_Status. Pozostałe pola SDK nie są arbitralnie kasowane.
- Zapis parametrów złożonych oraz brak LSKChar, LSK_Color, lamp CDU i pojedynczych cyfr Flight Altitude w trip_aircraft_data. Oryginalny odczyt w pamięci nadal zawiera tekst potrzebny do osobnego zapisu FMC.
- Osobne rekordy dwóch CDU. Zmiany wyłącznie małej czcionki, wyłącznie koloru oraz wyłącznie EXEC dopisują kolejne rekordy FMC, nie zwiększając liczby identycznych stanów ogólnych SDK. Zapis EXEC zachowuje jasność BRI=2.
- Spakowanie 24 komórek w 48 znaków hex w każdym wierszu, HTML z małą czcionką i kolorem magenta oraz escapowanie znaków < i & z surowego tekstu. Test sprawdza wygenerowany HTML, nie jego wizualne odwzorowanie w przeglądarce.
- Dostępność Flight_Altitude_Indicator_Value na wykresie, bazową wartość 35000 i późniejszą deltę 36000. Nowy wykaz parametrów nie zawiera pojedynczych kolorów LSK.
- Zachowanie kontrolek i spakowanych stylów przy buforowaniu/flush preflight do kolejnego tripu. Usuwanie danych testowych wraz z tripem.

Ponownie uruchomiono VerifyAircraftSDK: kontrolowany odczyt z pamięci współdzielonej nadal zwraca wszystkie 2411 pól, nadpisania SimConnect i istniejące parametry SDK działają, a wykresy zachowują przerwy przy utracie SDK. VerifyFMC ponownie sprawdził tekst, glify, stare surowe ekrany, strony MOD, deduplikację i parser referencji.

Przejrzano oficjalny SDK_Defines.h: kody cyfr, wygaszenia, znaków, glifów i kontrolek. Test nie potwierdza wszystkich 26 grup podczas lotu. IRS/RTP mają tryby alfanumeryczne, których nie należy utożsamiać z jedną wielkością fizyczną. Kolejność pięciu pozycji Fuel Quantity oraz jednostki i zachowanie wyświetlaczy trzeba jeszcze porównać na żywo; syntetyczny test sprawdza przyjętą kolejność indeksów, nie zastępuje tej próby. Nie wykonywano nowego lotu ani nie kasowano danych z bazy użytkownika.

## Rozszerzenie stron referencyjnych Boeinga — 18 października 2026

Dodano `fmc/BoeingFMCValuesU.pas` i wpisano jednostkę jawnie w DPR oraz DPROJ. Parser jest wywoływany przez wspólne ParseFMCValues; nowe pola trafiają do tego samego zapisu i kontekstu analizy co V-speeds. Zakres i jednostki opisuje `support/fmc/Boeing-performance.md`. Rozszerzono natywne okno informacji o nagraniu bez dodawania formularza tworzonego w kodzie: nadal używa istniejącego DFM i memo tylko do odczytu.

Nowy `VerifyBoeingFMC.dpr` sprawdza:

- N1 LIMIT z układem podanym przez użytkownika: TO jest aktywny po lewej, CLB wybrany po prawej; nieoznaczone TO-1/TO-2/TO-B nie są traktowane jako wybrane. Rating aktywnego TO wynosi 28K, derate 0, assumed temperature jest null, OAT +14°C, oba limity N1 93,8%.
- Inny ekran z aktywnym TO-1 oraz wybranym TO-B: derate aktywny 10%, wybrany rating 29K i bump true. Założona temperatura +45°C pozostaje oddzielna od OAT -10°C. Te przypadki są syntetyczne.
- TAKEOFF REF: klapy 15°, CG 22,1%, trim 3,95 units, limity N1 oraz prawa kolumna prędkości niezależna od QRH.
- PERF INIT: GW 51,1 w jednostkach wyświetlacza, cruise CG 22,1%, FL130 jako 13 000 ft, brak planowanego paliwa, fuel 6,0 i źródło SENS, ZFW 45,1, reserves 2,1, CI 60 oraz transition altitude 6500 ft. Nieokreślone wiatr i ISA deviation pozostają null. Nie potwierdzono w tym teście dodatnich wartości pól pogodowych PERF INIT.
- Zapis surowych stron z pustym starym parsed_json, ponowny odczyt przez okno informacji, VREF 137 i klapy lądowania 40°, CG/trim i aktywny tryb. Dla osobnych kontaktów startu i lądowania używane są wcześniejsze ekrany: późniejsza zmiana klap na 25° nie przenika do obu wcześniejszych zdarzeń.

Pierwszy test wykazał różnicę lokalnego zapisu przecinka przy odczycie TJSONNumber.Value, mimo poprawnego JSON. Asercje liczb i prezentację w memo oparto na poprawnym zapisie liczbowym JSON; wykonano ponowną próbę. Dotychczasowy VerifyTripInfo nadal sprawdza bazowe informacje, czas trwania, METAR-y, odświeżanie i przycisk zamknięcia. Testy nie odpytywały symulatora, nie zmieniały stron FMC ani nie wykonywały lotu na żywo. Nie potwierdzają wszystkich układów FMC poszczególnych dodatków.

## Próbki lotu i parser iFly FMC — 18 października 2026

Sprawdzono bazę z `katalog źródłowego legacy flight_data.db` oraz log rejestratora. Źródło otwarto przez SQLite w trybie tylko do odczytu i wykonano spójną kopię diagnostyczną w `.build`. Nie zmieniano oryginalnych danych, konfiguracji ani plików wykonywalnych w tym katalogu. Prywatna kopia i surowe logi diagnostyczne nie są dołączane do paczek.

Trip 4 zawiera 5256 próbek: 5251 z flagą ziemi i tylko 5 z flagą powietrza. Pierwsze 5250 próbek obejmuje czas symulatora 11:28:04–11:33:58; log pokazuje przetwarzanie od 23:51 do około 00:46 czasu komputera. Kolejne próbki mają czasy 11:39:28, 11:44:35, 11:49:51, 11:53:28, 11:55:58 i 12:02:00. Największa luka wynosi 362,512 s. Kontakty startu i lądowania zapisano osobno o 11:36:53 i 11:58:53. To nie jest poprawny przebieg zapisu co 250 ms; układ wskazuje na zaległą kolejkę ramek. Interwał był liczony według czasu przetwarzania, więc kosztowny callback mógł utrwalać po kolei stare ramki zamiast bieżącego stanu. Zewnętrzny EXE miał datę 17.10.2026 21:57 i nie zawierał późniejszego przeniesienia rejestratora do wątku.

Odbiór używa teraz GetNextDispatch, gdy DLL udostępnia tę funkcję, z ograniczeniem czasu/liczby pakietów na przebieg. Kosztowne przetwarzanie SDK i zapis następują po odbiorze, dla najnowszej ramki. Zachowane są ramki początkowa oraz przejścia ziemia–powietrze, żeby nie zgubić startu, przyziemienia i odbicia. Zastępczy CallDispatch również odracza przetwarzanie próbek. Log co 30 sekund podaje received/delivered/coalesced. Nie odtwarza się sztucznych brakujących próbek. Przy bardzo wolnym odbiorniku rzeczywisty interwał może nadal przekroczyć zadany, ale nie powinien narastać koszt odtwarzania każdej starej ramki.

Usunięto także niezależny błędny warunek odrzucający całą próbkę przy surface_type=255. Nieznana nawierzchnia nie unieważnia pozostałej telemetrii. Nie da się udowodnić, ile ramek zewnętrznego lotu odrzucił właśnie ten filtr, ponieważ odrzuconych ramek nie ma w bazie.

Parser TAKEOFF REF odczytuje wybraną prawą kolumnę V1/VR/V2, pomijając propozycje QRH po lewej. APPROACH REF odczytuje wybraną parę FLAP/SPD, nie zgaduje VREF z tabeli kilku konfiguracji. Zwraca dodatkowo approach_flaps_deg; wind_correction_kt pozostaje osobnym polem. Puste/wyczyszczone wartości dają null. Przy analizie wszystkie zapisane surowe ekrany są ponownie parsowane aktualnym kodem, również iFly i PMDG, bez destrukcyjnej migracji parsed_json. Wcześniej wygenerowany raport AI wymaga ponownego wygenerowania.

Rozszerzono VerifyFMC: różne propozycje QRH i wybrane 124/125/137, brak wybranego V1 przy istniejącym QRH, wybrane 40/137 oraz 30/142, wyczyszczenie --/--- bez podstawienia wartości z tabeli, oddzielne wind correction +5. W bazie testowej podmieniono stare parsed_json na null; kontekst odzyskuje wartości z surowych ekranów. Rozszerzono VerifySession: sześć kolejnych próbek powietrznych z surface_type=255 i interwałem 250 ms oraz oba kontakty przy nieznanej nawierzchni.

Nowy VerifySimBacklog przekazuje 1000 syntetycznych ramek, z trzema zmianami kontaktu i celowo wolnym odbiornikiem. Odbiornik dostaje pięć callbacków: stan początkowy, trzy przejścia i najnowszą próbkę z czasem 999. Osobny Feed pozostaje synchroniczny. Test nie odtwarza prawdziwego transportu DLL ani pełnego lotu.

Oddzielnie skompilowano ProbeSavedFMC i odczytano kopię rzeczywistej bazy w trybie ReadOnly. Przeparsowano 219 ekranów; uzyskano 12 ekranów z wybranymi prędkościami startowymi i 7 z wybraną konfiguracją podejścia. Ekrany 139/140 dały 124/125/137; ekran 208 dał vref_kt=137, approach_flaps_deg=40 i wind_correction_kt=5. Późniejsze ekrany 212/213 zawierają już wybrane 40/136 i są tak odczytywane. Nie podstawiano prędkości na podstawie oczekiwań użytkownika. Ten program diagnostyczny nie jest dodatkowym zestawem automatycznym.

Po zmianach nie wykonano pełnego nowego lotu na żywo. Utraconej telemetrii nie można odzyskać z kilku zachowanych próbek; naprawa parsera może wykorzystać zachowany surowy FMC.

## Nagrywanie w osobnym wątku — 18 października 2026

`recording/RecorderWorkerU.pas` jest właścicielem rejestratora i osobnego połączenia FireDAC. Tworzenie, odczyt SimConnect/SDK, obsługa FSHud, parsowanie planu, zapis próbek, kontaktów, zdarzeń i odbiór wyników METAR odbywają się w tym wątku. VCL przekazuje polecenia Start/Stop/PLN/METAR przez ograniczoną kolejkę i odczytuje kopię stanu pod krótką blokadą. Blokada nie obejmuje SQL, odczytu SDK ani pracy rejestratora. Nie ma Synchronize ani wywołań kontrolek formularza z wątku.

Połączenie formularza pozostaje osobne. SQLite używa WAL, JournalMode=WAL już przy otwarciu, LockingMode=Normal i SharedCache=False. Wątek otwiera istniejący schemat przygotowany przez główne połączenie; nie wykonuje równoległej migracji. Nie tworzy formularzowego kursora FireDAC i używa SilentMode. Błędy są publikowane w stanie i logu. Zmiana bazy lub zamknięcie formularza zatrzymuje i dołącza wątek przed zwolnieniem jego zasobów. Zamykanie może czekać na trwającą operację; nie porzuca zapisu w tle.

Nowy `VerifyRecorderWorker.dpr` korzysta z syntetycznego źródła próbek uruchamianego w tym samym wątku co produkcyjny rejestrator. Sprawdza rzeczywisty zapis do osobnej bazy SQLite, identyfikator wątku różny od głównego, poprawną konfigurację WAL, uruchomienie tripu i zapis wielu próbek. Główne połączenie celowo trzyma transakcję zapisu przez 300 ms: w tym czasie VCL przetwarza wiadomości i timer nalicza kolejne wywołania, a Configure/Command/Snapshot wracają bez czekania na SQL. Po zwolnieniu blokady zapis jest kontynuowany, kolejkowany PLN dociera do rejestratora, niepoprawny plik daje błąd w stanie, Stop i zwolnienie wątku kończą pracę. Sprawdzono także zwolnienie jeszcze nieuruchomionego wątku. Test nie łączy się z symulatorem, FSHud ani usługami pogodowymi.

Wstępne próby współbieżnego otwierania ujawniły blokady SQLite wynikające z konfiguracji połączeń. Samo ustawienie PRAGMA po otwarciu nie wystarczało; poprawiono parametry otwarcia obu połączeń. Docelowy test wymusza konflikt podczas zapisywania próbek, a nie zakłada, że otwarcie istniejącego schematu zawsze wymaga zapisu.

Nie wykonano jeszcze długiego nagrania na żywo w MSFS ani pomiaru płynności podczas pełnego lotu. Ładowanie bardzo dużego nagrania do wykresów i inne działania przeglądarki historii nadal wykonują się w VCL; ta zmiana przenosi rejestrator, a nie całą aplikację, do tła.


## Sesja lotu i FSHud — 18 października 2026

Dodano VerifySession i VerifyFSHud. Automatyczne testy używają PORT_TEST: nie łączą się z rzeczywistym FSHud. Aktualny projekt obejmuje 50 lokalnych jednostek, jawnie wpisanych w DPR i DPROJ.

- VerifySession: pierwsza próbka z wyłączonymi silnikami otwiera trip; boarding, uruchomienie i wyłączenie silników nie dzielą sesji. Pauza zachowuje trip. FLIGHT_END kończy zapis, stare próbki nie otwierają go ponownie, załadowanie kolejnego lotu otwiera nowy trip, MAINMENU.FLT zatrzymuje zapis. Sprawdzono liczbę tripów i zapisanych próbek. Są to wywołania syntetyczne, nie zakończenie lotu w MSFS.
- VerifyPort: dostosowano oczekiwanie do nowej granicy sesji. Próbka po wyłączeniu silników nadal należy do tripu, a dopiero sygnał końca zamyka nagranie. Pierwsze uruchomienie pełnej serii wykryło stare oczekiwanie zakończenia po zgaszeniu silników; po aktualizacji testu wykonano ponowną weryfikację.
- VerifyFSHud: kodowanie/dekodowanie AES i UTF-8, odrzucanie niepoprawnej ramki, walidacja klienta, dozwolone typy, filtrowanie prywatnych pól, pomijanie identycznych komunikatów, zapis czasu odbioru i czasu symulatora, COM1/COM2 oraz czterocyfrowego squawk, odtworzenie wykresów, migracja czasu kontaktu i usuwanie historii wraz z tripem. Sztuczna przyszła wiadomość z takim samym czasem symulatora nie trafia do kontekstu wcześniejszego kontaktu: ograniczenie działa według rzeczywistego czasu odbioru.

Oddzielna próba na żywo: skompilowano i uruchomiono tests/ProbeFSHud.dpr wobec localhost:19786. Natywny klient połączył się z FSHud 2.1.200 i odebrał wszystkie dziewięć obsługiwanych typów. W treści znaleziono EPLL, ADOX2W, ADOXO, SOXER, SOXE2T, LL501 i LL531. Panel podał czas symulatora SAT 11:22:05Z 17-OCT-2026; nie jest to data odbioru komunikatu. Nie wysyłano wyborów ATC ani zmian ustawień. Diagnostyka PowerShell została zablokowana przez antywirusa; nie wyłączano ochrony, a właściwy czytnik Delphi przeszedł próbę odczytu. Prywatny JSON i skrypt producenta pozostały w .build i nie są pakowane.

Sprawdzono eksporty dostarczonej oraz zainstalowanej biblioteki SDK SimConnect: brak SubscribeToFlowEvent. Kod zachowuje opcjonalne Flow i zastępczy odczyt FlightLoaded, odpytywany co 10 sekund. Nie podmieniano biblioteki na SimConnect_internal.dll. Nie przerwano aktywnego lotu użytkownika: zakończenie sesji na żywo, pełny lot, GSX boarding/deboarding i zachowanie podczas CTD pozostają do sprawdzenia w symulatorze. Próba FSHud potwierdza odczyt bieżącego protokołu, nie zgodność przyszłych wersji.


## Zakres i interpretacja wyników

Dokument opisuje testy znajdujące się w tym projekcie i wykonane podczas jego rozwoju. Podstawowym dowodem automatycznej weryfikacji jest `tests/verification.log`: kompilacja dwóch bibliotek pomocniczych, wydawcy Win32 oraz 32 programów testowych zakończonych komunikatami `PASS`. Testy sprawdzają warunki w kodzie i zgłaszają wyjątek przy niezgodności; `test.ps1` przerywa pracę po błędzie kompilacji lub niezerowym kodzie zakończenia.

Weryfikacja transportu za pomocą atrap DLL i pamięci współdzielonej potwierdza działanie czytników wobec kontrolowanych pakietów. Nie jest testem kompletnego lotu w MSFS ani potwierdzeniem, że każda wersja dodatku publikuje identyczne dane. Testy analizy AI sprawdzają przekazywanie danych i obsługę procesu, a nie trafność ocen pilotażu wygenerowanych przez model.

## Uruchamianie i środowisko

Środowisko użyte do weryfikacji: Windows, Delphi 10.2, kompilator `dcc64` 32.0, Win64, VCL, FireDAC i SQLite. WebView4Delphi jest potrzebne do kompilacji formularza raportu. Biblioteki wykonawcze obejmują `sqlite3.dll`, `SimConnect.dll` oraz `WebView2Loader.dll`.

Z katalogu projektu:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\test.ps1 *> .\tests\verification.log
python .\tools\check_dependencies.py
python .\tools\package.py
```

Skrypty kompilują od nowa (`-B`); testy otrzymują symbol `PORT_TEST`. `test.ps1` ustawia `TEMP` i `TMP` na `.build/test-temp` i przywraca poprzednie wartości po zakończeniu. Testy tworzą własne bazy i konfiguracje; nie otwierają bazy użytkownika. Część plików diagnostycznych i kopii migracyjnych pozostaje jako materiał do sprawdzenia. Uruchomienia korzystające z nazwanych obiektów Windows nie powinny nakładać się na siebie.

## 1. VerifyPort — rejestrator, SimConnect i baza

- Wprowadzenie kontrolowanych pakietów SimConnect uruchamia automatycznie lot po wykryciu pracy silników. Opcjonalny wyjątek SDK nie kończy rozpoczętego nagrywania.
- Sprawdzany jest znak strefy czasowej: godzina lokalna 12:00 odpowiada zapisowi z przesunięciem `+02:00`.
- Przejście ziemia–powietrze zapisuje jedno oderwanie, a powietrze–ziemia jedno przyziemienie. Wyłączenie silników na ziemi kończy lot.
- Odczyt zapisanych próbek odtwarza dane drugiego silnika i spakowane flagi logiczne autopilota.
- Seria kolejnych pakietów, także po opcjonalnym błędzie SDK, daje **121 zapisanych snapshotów**. To regresja problemu zatrzymywania zapisu po kilku próbkach.
- Eksport KML ma oczekiwaną kolejność współrzędnych i przeliczenie wysokości ze stóp na metry, np. 1000 ft → 304,8 m.
- Usunięcie lotu usuwa jego próbki i dane silników.
- Filtr zdarzeń tłumi szybki zalew powtórzeń, wycofuje zdarzenia rozpoznane później jako wolniejszy zalew i przepuszcza powtórzenia zmian klap zgodnie ze swoją regułą.
- Geometria pasa dopasowuje pozycję na osi i odległość wzdłuż pasa, a odrzuca pozycję poza pasem.

## 2. VerifyLegacy — migracja starych baz

Test tworzy bazę o dawnym układzie tabeli, z danymi dwóch silników w kolumnach próbki i spakowanymi flagami. Ponowne otwarcie wykonuje migrację.

- Wersja migracji strefy czasowej wynosi 1; błędny historyczny znak `-02:00` zostaje poprawiony na `+02:00`.
- Powstają dwa rekordy silników, z poprawnym stanem spalania drugiego silnika.
- Wczytany wykres odtwarza N1 drugiego silnika równe 46.
- Powstaje jedna kopia `before-native-*.db`.
- Kolejne otwarcie nie odwraca ponownie strefy czasowej: migracja jest idempotentna.

## 3. VerifyUI — formularze i współpraca paneli

Test uruchamia rzeczywisty formularz VCL na sztucznym nagraniu i zapisuje `tests/native-preview.png`.

- Odtworzenie DFM, utworzenie i pokazanie głównego formularza.
- Domyślne okna analizy: start 60 s przed / 30 s po; lądowanie 180 s przed / 30 s po. Odczyt dawnego wspólnego ustawienia 42/17 s.
- Niezależny zapis i odczyt okien startu 65/25 s i lądowania 240/45 s; ograniczenie wartości do obsługiwanego zakresu. Zapis i odczyt dostawcy AI, modelu i timeoutu.
- Przypisanie obsługi dwukliku historii; wyłączenie edycji gridów historii, zdarzeń, kontaktów i inspektora.
- Utworzenie 32 wykresów i przewijanie ich kółkiem myszy, bez dawnego ograniczenia do ośmiu.
- Pozycja splitterów mapy i listy parametrów względem właściwych paneli.
- Ponad 200 pól w inspektorze i na liście wyboru parametrów; dostępność przycisków analizy i przeglądu.
- Zmiana kolejności wykresów, aktywacja suwaka przesuwania po powiększeniu i wyłączenie go po powrocie do pełnego widoku.
- Synchronizacja etykiety czasu z pozycją osi czasu oraz wyświetlenie zapisanego planu EPLL.
- Zapis wysokości paneli mapy i parametrów w konfiguracji: odpowiednio 320 i 210.

Test sprawdza zdarzenia i właściwości kontrolek. Samo istnienie PNG nie jest automatyczną oceną wyglądu wszystkich możliwych rozmiarów okna.

## 4. VerifyDiagnostics — log i minidump

Wpis diagnostyczny musi znaleźć się w trwałym logu. Test sprawdza zainstalowanie filtra awarii, wywołuje kontrolowaną ścieżkę diagnostyczną i sprawdza minimalną długość oraz sygnaturę `MD` pliku minidump. Potwierdza powstanie pliku z nagłówkiem Windows, nie pełną analizę stosu dowolnej przyszłej awarii.

## 5. VerifyFlightPlan — PLN i trasa EFB

- Wczytanie dostarczonych fixture'ów EPMO i EPLL. EPMO zawiera poprawną procedurę **SOXE4C**; EPLL zachowuje ADOX2W, SOXE2T, LL501 i ILSZ.25.
- Brak współrzędnych w PLN nie powoduje tworzenia fikcyjnych punktów.
- Przeliczenie współrzędnych DMS daje oczekiwaną szerokość 52,5 i długość −20,25.
- Parsowanie trasy EFB zachowuje sekwencję lotnisk, procedur i punktów. Brak pozycji punktu przerywa linię na mapie zamiast łączyć odcinki przez nieznaną pozycję.
- Lokalny most HTTP dostarcza trasę do rejestratora. Trasa otrzymana przed rozpoczęciem lotu zostaje przypisana przy starcie nagrania.
- Identyczna trasa nie tworzy duplikatu, zmiana tworzy nową rewizję. Odczyt bazy odtwarza plan; usunięcie lotu usuwa rewizje.
- Kontrolowany pakiet stanu systemowego SimConnect przekazuje ścieżkę planu.

To test parsera, lokalnego mostu i zapisu. Nie zastępuje próby `GET_EFB_ROUTE` z rzeczywistym planerem podczas lotu.

## 6. VerifyAnalysis — proces Codex i polski tekst

Program testowy uruchamia własny tryb udający CLI, bez zapytania do chmury.

- Prompt zawiera żądanie odpowiedzi po polsku, a polskie znaki przechodzą przez UTF-8 na standardowym wejściu bez uszkodzenia.
- Argumenty procesu, polecenie `exec` i ścieżka wyniku docierają do procesu potomnego; wynik z polskimi znakami jest odczytywany poprawnie.
- Niezerowy kod zakończenia 7 i komunikat „brak logowania” trafiają do błędu aplikacji.
- Przekroczenie czasu przerywa proces w oczekiwanym limicie; ręczne anulowanie kończy pracę i zwraca właściwy komunikat.
- Używana jest ścieżka uruchamiania procesu bez widocznego okna konsoli.

Nie sprawdzano tym testem logowania do konta, dostępności usługi ani jakości odpowiedzi rzeczywistego modelu.

## 7. VerifyContext — okno analizy i delty

Fixture obejmuje **181 snapshotów** co 0,5 s, przez północ, z 120 próbkami przed oderwaniem i 60 po nim oraz próbką zdarzenia.

- Pierwszy stan stanowi pełną bazę; kolejne zawierają zmiany. Rozmiar delt jest mniejszy niż połowa rozmiaru powtarzanych pełnych stanów.
- Powtórzone wartości są pomijane, ale zmiana na `false`, jawny `null`, zniknięcie silnika i jego powrót pozostają rozróżnialne.
- Rekonstrukcja kolejnych stanów odtwarza AP, A/T i widzialność.
- Okno obejmuje przejście przez północ, zachowuje szczyt 2,3 g po zdarzeniu i normalizuje znak pochylenia do nosa w górę.
- Dekodowany jest kontakt z ziemią i przekazywana sekwencja pobliskich oderwań/przyziemień.
- Pogoda z próbki najbliższej zdarzeniu, temperatura przed nim i widzialność po nim pozostają dostępne. Ciśnienie lokalne w inHg i ciśnienie odniesione do poziomu morza są oddzielne.
- Osobno zachowane są ułamkowe wysunięcie podwozia, obroty prawego koła oraz niezależny kontakt przedniego i lewego podwozia.
- Odległość od progu 1000 ft daje 304,8 m; odchylenie boczne zachowuje znak po przeliczeniu na metry.
- Liczby zdarzenia są liczbami JSON. Krótsze skonfigurowane okno daje pięć próbek.

## 8. VerifyReport — Markdown i zamykanie raportu

Sprawdzane jest generowanie nagłówka, pogrubienia, kodu w linii, listy punktowanej i numerowanej. Surowy HTML, w tym `<script>`, jest escapowany. Wywołanie przycisku zamknięcia niemodalnego formularza powoduje jego zniszczenie po przetworzeniu komunikatów VCL. Test nie ocenia wizualnie pełnego renderowania HTML w każdej wersji WebView2.

## 9. VerifyMetar — raport pogody przy zdarzeniu

Test korzysta wyłącznie z lokalnego serwera odpowiedzi HTTP.

- Asynchroniczny odbiór METAR zapisuje surowy tekst, czas obserwacji i czas pobrania.
- Automatyczne pobranie nie dopisuje aktualnej pogody do dawnych kontaktów jako pogody historycznej.
- Kontekst analizy zawiera METAR i długość pasa 2500 m.
- Jawne zlecenie wyszukania raportu z chwili dawnego startu lub lądowania zapisuje status oczekiwania i docelowy czas historyczny.
- Brak raportu daje jawny status `unavailable`, zamiast pustego tekstu udającego sukces.

Test nie potwierdza dostępności zewnętrznego archiwum METAR ani zgodności realnego raportu lotniskowego z pogodą ustawioną w symulatorze.

## 10. VerifyChartView — obsługa widoku wykresów

Pełny zakres fixture'u wynosi 100–200, więc test obejmuje oś czasu, która nie zaczyna się od zera. Sprawdzane są: mapowanie kursora po powiększeniu, zwykłe przeciąganie przesuwające widok bez zmiany jego szerokości, zaznaczenie z Shift także od prawej do lewej, przesunięcie do końca zakresu, powiększenie przez Ctrl+kółko i przywrócenie pełnego zakresu.

## 11. VerifyAircraftSDK — iFly

Test tworzy kontrolowaną pamięć współdzieloną o formacie oficjalnego SDK i używa rzeczywistego czytnika.

- Rozpoznanie iFly MAX8 z livery LOT; odrzucenie innego producenta i iFly 737-700.
- Odczyt wszystkich **2411 pól** z bloku SDK. Pierwszeństwo SDK dla pozycji klap i wybranych wskazań, przeliczenie przepustnicy oraz zachowanie dynamiki lotu z SimConnect.
- Składanie cyfr wybranego kursu i IAS; wygaszone cyfry nie nadpisują poprawnego celu z SimConnect.
- Zapis pełnego stanu, pominięcie identycznego, zapis zmiany i pominięcie niezmienionych pól w delcie.
- Rekonstrukcja po rozłączeniu nie przenosi starych danych. Wykres zachowuje wartość między zmianami, pokazuje lukę przy braku SDK i wraca po odzyskaniu danych.
- Analiza dostaje definicje pól, jednostki i stany odtworzone sprzed początku okna, a także informację o niedostępności SDK.
- Stan SDK `NOT_RUNNING` jest odrzucany; usunięcie lotu usuwa historię SDK.

To próba na kontrolowanym bloku, nie odczyt z pracującego iFly.

## 12. VerifyFenix — Fenix A32X

`MockFenixSim.dll` eksportuje interfejs używany przez czytnik. Test przechodzi przez rzeczywiste wywołania DLL, ale odpowiedzi są sztuczne.

- Automatyczne rozpoznanie tytułów Fenix/FNX, brak dopasowania iFly i zwykłego Asobo A320. Brak żądań Fenix dla innego samolotu.
- Odczyt **1203 L-varów**, podział na ograniczone paczki, zgodność nazw, typów i jednostek; licznik zapisów do symulatora pozostaje zerowy.
- Pierwszeństwo pozycji podwozia i klap oraz zapis źródła wartości. Wejście animacji przepustnicy nie jest traktowane jako procent ciągu, a lampka AP jako rzeczywisty stan autopilota.
- Brak paczki, NaN, opcjonalny wyjątek i błędna długość odrzucają tylko brakujące lub uszkodzone dane. `QUIT` i brak odpowiedzi unieważniają stan; prawdziwe zera pozostają zerami.
- Ponowne połączenie przywraca dane; przeterminowane pakiety są odrzucane.
- Zmiana livery lub samolotu resetuje cache. Brak SDK zachowuje dane SimConnect i usuwa stare nadpisania.
- Zapis zmian, wykres z luką i odzyskaniem danych, definicje i historia w analizie, brak przenoszenia wartości między dostawcami oraz usuwanie danych lotu.

## 13. VerifyFBW — FlyByWire A32NX

Test korzysta z tej samej biblioteki transportowej z odpowiednim katalogiem danych.

- Rozpoznaje FlyByWire/A32NX; odrzuca Fenix, Asobo A320 i FBW A380.
- Katalog obejmuje **223 odczytywalne pola**; nie zawiera wycofanych pól AP, setterów ani zdarzeń sterujących. Wywołania pozostają tylko do odczytu.
- Mapowanie pozycji klap FBW 3 na standardową pozycję 4, stany uzbrojenia i działania A/THR, wybrana IAS i VAPP z FMS. Lampka AP nie zastępuje rzeczywistego stanu AP.
- Podczas inicjalizacji nie powstają nadpisania ani fikcyjne VAPP. Mach jest oddzielony od IAS; kreski FCU nie nadpisują celu.
- Brak paczki, NaN, opcjonalny błąd, zły pakiet, `QUIT`, brak odpowiedzi i transportowane zera mają oczekiwaną semantykę.
- Zmiana samolotu resetuje stan. Zapis obejmuje tylko zmiany, odtwarzanie wykresu zachowuje surowe detenty, pokazuje lukę i powrót. Definicje i VAPP trafiają do analizy; usunięcie lotu usuwa historię.

## 14. VerifyPMDG — PMDG 737 NG3

`MockPMDGSim.dll` kontroluje transport Client Data i liczy wywołania.

- Rozpoznanie 736/737/B738; odrzucenie 777, MAX i innego producenta.
- Mapowanie trzech obszarów: głównego i dwóch CDU, właściwe nazwy, identyfikatory, rozmiary i żądania `ON_SET`/`ONCE`; brak zapisów i sterowania samolotem.
- Dekodowanie **494 pól**, w tym bajtów, wartości ze znakiem, ujemnej wysokości lotniska, 32-bitowych flag bez znaku i tekstu zakończonego NUL.
- CDU: 14 wierszy, układ kolumnowy, strzałki oraz zachowanie surowych flag symbolu, koloru i fontu.
- AP, serwo A/T, paliwo w funtach, pionowy cel MCP, IAS i Mach. Wygaszony lub niezasilany MCP nie nadpisuje poprawnych celów. Pozycja dźwigni podwozia OFF nie jest sprowadzana do UP/DOWN.
- V1/VR/V2/VREF są prawidłowo odczytywane; brakujące prędkości i sentinel wysokości dają `null`. Ujemna odległość TOD oznacza brak wartości, natomiast zero pozostaje prawidłowe.
- NaN i nieprawidłowa wartość logiczna powodują stan częściowy bez fałszywego nadpisania. Model 0 oznacza inicjalizację.
- Brak lub błąd opcjonalnego CDU nie blokuje danych głównych. Błąd, ucięty pakiet, `QUIT` i brak odpowiedzi unieważniają odpowiedni stan.
- Ostatni poprawny stan `ON_SET` pozostaje dostępny także po 60 s bez sztucznego wymogu heartbeat; zachowany jest wiek danych.
- Zmiana samolotu czyści cache; zapis delt, odtwarzanie wykresów z lukami, kontekst AI z referencjami FMC i usunięcie historii działają na kontrolowanych danych.

## 15. VerifyFMC — tekst ekranów i ostatnie wartości

- Dwa niezależne CDU iFly, `TStringList` po 14 wierszy × 24 kolumny, CRLF, spacje końcowe i dekodowanie symboli. Jasność nie jest używana do wymyślania stanu zasilania.
- Zachowanie numeru strony, np. `TAKEOFF_REF:1/2`, oraz rozpoznanie PERF INIT, N1 LIMIT i APPROACH REF.
- Ekstrakcja jawnych V1, VR, V2, VREF i wind correction, także z prawostronnych pól. Niejednoznaczna tabela VREF nie jest automatycznie traktowana jako wybrana prędkość.
- Identyczne ekrany nie tworzą kolejnych rekordów. Zapis i odczyt `raw_text` zachowują pełną długość, puste wiersze i spacje; sprawdzana jest również funkcja SQL `length`. To regresja domyślnego przycinania tekstu przez FireDAC.
- Kontekst dla chwili zdarzenia zawiera ostatnio oglądane strony spoza krótkiego okna próbek, ale nie zawiera ekranów z przyszłości.
- Ostatnie wartości są oddzielne dla urządzeń. MOD pozostaje osobną obserwacją i nie nadpisuje wykonanych wartości. Jawne skasowanie prędkości daje `null`.
- Niepełny ekran oznacza niedostępność; obsługiwany jest wspólny format ekranów PMDG. Zmiana samego zasilania jest zapisywana mimo identycznego tekstu, a zniknięcie dostawcy unieważnia ekran.
- Bufor przed uruchomieniem silników: identyczne obserwacje są pomijane; nawet po ograniczeniu historii do jednej pozycji zachowane pozostają ostatnie strony PERF INIT i N1 LIMIT. Opróżnienie bufora przypisuje je do lotu jako `sample=0` i czyści bufor.
- Usunięcie lotu usuwa zapisane ekrany.

## 16. VerifyFlightPad — tekst Fenix/FBW między procesami Win32 i Win64

- Kontrola stałego rozmiaru protokołu `packed record`: 776 bajtów.
- Niezainicjalizowany ekran jest niedostępny. Poprawna publikacja zachowuje 14 × 24 spacje i CRLF; aktualizacja heartbeat nie zmienia czasu obserwacji niezmienionego tekstu.
- Oddzielenie profili Fenix i FBW. Zbyt krótki tekst i jawne rozłączenie dają niedostępność.
- Kontrolowana modyfikacja pakietu sprawdza odrzucenie heartbeat sprzed 6 s i nieobsługiwanej wersji 99. Zamknięcie wydawcy usuwa dostępność.
- Test uruchamia **osobny proces Win32 `MockFlightPad32.exe`**, a produkcyjny czytnik Win64 odczytuje jego mapping. Sprawdzane są identyfikator procesu, automatyczne wyszukanie uruchomionego wydawcy i oba profile.
- Eksport przechodzi do ogólnego kontraktu CDU: 14 wierszy, scratchpad, strzałka Unicode; brak wymyślonego stanu elektrycznego zasilania.
- Dwa identyczne odczyty tworzą jeden zapis ekranu w bazie; V-speed trafia do kontekstu analizy. Rejestr dostawców dołącza CDU po wykryciu tytułu odpowiedniego samolotu.
- Po zatrzymaniu procesu kolejny zapis oznacza ekran jako niedostępny. Usunięcie lotu usuwa historię zewnętrznego ekranu.

To rzeczywisty test komunikacji między procesami i bitowościami, ale dane ekranu są sztuczne. Nie wymaga uruchomionego symulatora ani FlightPadFMCServer.

## 17. VerifyAirbusMCDU — parser Fenix i FBW

Te same scenariusze są wykonywane dla `FenixA32X` i `FBWA32NX` na syntetycznych ekranach 14 × 24:

- TAKE OFF: klasyfikacja strony, V1/VR/V2, FLEX, klapy, THS UP/DN, transition altitude, osobne thrust-reduction/acceleration i engine-out acceleration altitude.
- Pary label/data oraz V1 w jednej linii. Scratchpad jest ignorowany; błędna wartość lewej kolumny nie pobiera liczby z prawej.
- APPR: VAPP, VLS i różnica jako additive, bez wymyślania VREF ani wind correction. QNH hPa/inHg z unieważnieniem alternatywnej jednostki, temperatura ujemna, wiatr magnetyczny, transition level, minima BARO/RADIO, FINAL i jednoznaczne LDG CONF.
- Kreski zamiast prędkości unieważniają wynik i additive. Błędny kierunek wiatru i niejednoznaczna konfiguracja dają null.
- INIT A: trasa, cost index, cruise FL i temperatura. INIT B: osobny klucz historii i zachowanie masy/paliwa jako tekstu bez zgadywania jednostek.
- F-PLN z tekstem przypominającym V1 nie jest parsowane. TMPY ma status oczekującej modyfikacji. Ekran niedostępny lub wyłączony nie dostarcza danych.
- SQLite: pola trafiają do parsed_json. Następnie test celowo zastępuje parsed_json pustym obiektem, a klucz strony dawnym OTHER:LEGACY, aby sprawdzić ponowne parsowanie starszego raw_text przy analizie.
- Kontekst dla wybranego czasu odtwarza wykonane V1 sprzed TMPY i VAPP sprzed późniejszej zmiany. Rozpoznaje strony Airbus, zachowuje źródło wartości i usuwa historię razem z lotem.

Źródła i ograniczenia: [Airbus-MCDU.md](support/fmc/Airbus-MCDU.md). Test nie potwierdza odczytu konkretnej wersji Fenix/FBW w rzeczywistym locie.

## 18. VerifyOllama — lokalne API analizy

- Adres domyślny, normalizacja końcówki `/api/chat` bez jej powielania i odrzucenie protokołu FTP.
- Utworzenie formularza DFM z trzema dostawcami. Domyślny URL Ollama oraz zapis/odczyt wyboru dostawcy, modelu i adresu w INI.
- Lokalny serwer testowy na losowym porcie otrzymuje POST na prefiks `/proxy/api/chat`, model `test:local`, `stream=false`, `options.num_ctx=32768` i jeden prompt użytkownika. Prompt zawiera wymaganie języka polskiego i poprawne znaki „żółć”.
- Polski raport Markdown wraca bez uszkodzenia UTF-8. Osobne pole `thinking` nie jest dołączane do raportu.
- HTTP 404 zachowuje kod błędu; `error` w odpowiedzi API zachowuje komunikat. Błędny JSON, brak wiadomości, pusta treść i `done=false` kończą analizę błędem bez zapisywania częściowego raportu.
- Serwer opóźnia pierwszy bajt o 2,5 s. Limit 1 s przerywa żądanie i kończy analizę przed 2 s. Anulowanie po 150 ms kończy ją przed 1,5 s.
- Brak nazwy modelu jest zgłaszany jawnie.

Test nie wymaga instalacji Ollama, nie pobiera modeli i nie wysyła zapytań do prawdziwego modelu. Nie potwierdza jakości raportu ani wydajności konkretnego modelu/sprzętu. Konfiguracja i kontrakt API: [support/ollama/README.md](support/ollama/README.md).

## 19. VerifyOllamaModels — lista zainstalowanych modeli

- GET `/api/tags` dla domyślnego adresu, prefiksu reverse proxy i adresu zakończonego `/api/chat`.
- Sortowanie i usuwanie powtarzających się nazw. Prawidłowa pusta lista, niepoprawny JSON, brak models, pusta nazwa oraz HTTP 503.
- Formularz DFM: odświeżanie rozpoczyna się bez blokowania UI, combobox dostaje modele, zachowuje wcześniejszy wybór i umożliwia wybór innego modelu.
- Zapisany model nieobecny na serwerze pozostaje w polu, z osobnym komunikatem. Pusta lista i błąd serwera mają różne komunikaty.
- Podczas opóźnionego pobierania zmiana URL i ponowienie anuluje stare żądanie; zastosowana zostaje lista nowego adresu.
- Zamknięcie formularza i osobne anulowanie pracownika kończą żądanie przed upływem sekundy, mimo opóźnionej odpowiedzi.

Test używa lokalnego serwera na losowym porcie i syntetycznych nazw modeli; nie pobiera ani nie uruchamia modeli Ollama.

Dodatkowa próba tylko do odczytu na działającym serwerze `http://localhost:11434/api/tags` (PowerShell `Invoke-RestMethod`, 17.10.2026) zwróciła: `codellama:7b`, `llama3.1:latest`, `gemma3:4b`, `qwen3:8b`. Potwierdza to dostępność endpointu i listę zainstalowanych modeli w chwili próby. Nie wykonano generowania raportu tymi modelami ani ręcznego testu dropdownu na tym serwerze.

## 20. VerifyTripInfo — informacje o wybranym nagraniu

- Utworzenie formularza z DFM i wczytanie wskazanego tripu z testowej bazy.
- Nazwa wybranego samolotu, liczba próbek i widok tylko do odczytu.
- Nagranie bez zakończenia: czas liczony do ostatniej próbki (10 s) i jawny komunikat o braku zapisanego zakończenia.
- Po zakończeniu lotu odświeżenie pokazuje stan zakończony i czas 20 s.
- Przycisk zamknięcia ma ustawiony wynik modalny. Nieistniejący trip pokazuje komunikat zamiast poprzednich danych.

Test korzysta wyłącznie z własnej bazy SQLite. Nie symuluje ręcznego otwierania okna z listy nagrań; główny formularz z nowym przyciskiem tworzy również `VerifyUI`.

## 21. VerifyPrecision — zaokrąglanie i martwa strefa delt

- Rekurencyjnie najwyżej trzy miejsca po przecinku w obiektach i tablicach; wartości ujemne i bardzo małe.
- Dokładny całkowity identyfikator 9007199254740993, pozostawienie tekstu liczb i obiektu źródłowego.
- Siedem rzeczywistych próbek w bazie: szum przy granicy zaokrąglenia jest pomijany, narastająca zmiana 1,00049 → 1,0021 daje deltę 1,002, kolejne niewielkie wahania są pomijane, a 1,0044 daje deltę 1,004.
- Zmiana AP na false przechodzi bez tłumienia; każda próbka zachowuje utc i t_seconds.
- Końcowy kontekst, w tym statystyki, ma znormalizowaną precyzję. Surowa wartość w SQLite pozostaje identyczna z oryginalnym odczytem.

Szczegóły progu i konsekwencje dla współrzędnych: [support/analysis/precision.md](support/analysis/precision.md).

## 22. VerifyAirliner — wspólne AIRLINER L-vary

- Importowany katalog 31 nazw zawierających AIRLINER, również z prefiksem A32NX_. Transport wykonuje osobną definicję i żądanie dla każdego pola z poprawną nazwą, typem i jednostką odczytu; licznik zapisów do symulatora pozostaje zerowy.
- Brak ostatniej odpowiedzi daje null dla ostatniego pola katalogu bez blokowania VR. NaN, wyjątek i błędna długość pakietu unieważniają V1 bez utraty VR.
- QUIT i brak odpowiedzi dają unavailable. Zera pozostają w surowych polach, ale nie tworzą referencji prędkości.
- Dwa jednakowe stany dają jeden rekord historii. Zmiana V1 jest odtwarzana na wykresie po wcześniejszym podtrzymaniu wartości; utrata danych tworzy lukę.
- Kontekst analizy zawiera dane i definicje jednostek; usunięcie lotu usuwa też tę historię.

Test działa na DLL-atrapie. Nie potwierdza, że dany dodatek publikuje wspólne zmienne w rzeczywistym locie. Czytnik jest opcjonalny i nie zastępuje SDK samolotu. Szczegóły: [support/airliner/README.md](support/airliner/README.md).

Katalog rozszerzono po skanowaniu plików JS/XML/HTML instrumentów MSFS24 i Community: 31 literalnych nazw w 149 plikach. Zachowano jednostki, pochodzenie i hashe, bez kodu producentów. `check_airliner_catalog.py` sprawdza liczbę i kolejność nazw, zgodność jednostek, brak duplikatów i obecność źródeł. To dodatkowa kontrola metadanych, obok kontroli DPR/DPROJ i 26 programów Delphi.

Rozszerzono też `VerifyTripInfo`: zapisane METAR-y startu i lądowania są widoczne jednocześnie, zachowane są czasy obserwacji i pobrania, a brak raportu pokazuje status unavailable i komunikat błędu. Formularz nie pobiera nowej pogody podczas tego testu.

## 23. VerifyGroundWeather — referencja pogody na ziemi

- Sekwencja próbek ziemia/lot/kontakt/odbicie/kolejny kontakt z różną pogodą.
- Start otrzymuje ostatnią próbkę na ziemi przed oderwaniem, lądowanie pierwszą na ziemi od przyziemienia, bez zastąpienia jej późniejszym kontaktem.
- Nastawa KOHLSMAN pozostaje oddzielona od ciśnienia otoczenia; referencja ma właściwy czas i temperaturę.
- Okno analizy zerowej długości nie usuwa referencji znalezionej poza nim; typ zdarzenia wybiera właściwą regułę.
- Trip bez próbki referencyjnej ma available=false i nie otrzymuje pogody innego tripu ani zastępstwa z powietrza.
- Prompt zawiera regułę ground_reference. Test dotyczy budowania kontekstu, nie gwarantuje przestrzegania instrukcji przez każdy model AI.

Interpretacja pól i źródło SDK: [support/analysis/ground-weather.md](support/analysis/ground-weather.md).

## Narzędzia dodatkowe i próby na żywo

### FlightPadFMC — model eksportu i kompilacja klientów

W zewnętrznym projekcie `FlightPadFMC/Windows/tests/ExportTests.dpr` utworzono i wykonano test obu wariantów modelu Airbus. Sprawdzono: początkową niedostępność, brak fałszywego ekranu po samej zmianie LED, przyjęcie pełnego komunikatu ekranu, string długości 364 jednostek UTF-16, 14 wierszy, wyrównanie lewej etykiety i prawej wartości, numer strony, scratchpad, końcowe spacje i reset dostępności.

Po instalacji źródeł skompilowano ponownie cztery rzeczywiste projekty Win32: `FenixA320MCDU`, `FenixA320Screen`, `FBWA320MCDU` i `FBWA320Screen`. Potwierdzono identyczność bajtową wspólnej jednostki IPC z FDR. Powtarzalne polecenie: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/verify_flightpad.ps1`; log: `tests/flightpad-export.log`. Kompilacja nie uruchamia klientów ani serwera.

Patch integracji sprawdzono poleceniem `git apply --reverse --check` na zmodyfikowanym projekcie: obejmuje aktualnie naniesione zmiany. Nie wykonano jeszcze próby z rzeczywistym ekranem Fenix/FBW podczas lotu.

### CheckDFM

Pomocniczy program konwertuje tekst DFM do postaci binarnej przez `ObjectTextToBinary`. Weryfikuje składnię zasobu, nie tworzy formularza. Nie jest częścią 26 zestawów `test.ps1`; utworzenie aktualnego formularza sprawdza `VerifyUI`.

### ProbePMDG

Opcjonalna próba odczytu z działającego symulatora. W wykonanej próbie załadowany był iFly, a nie PMDG, więc nie potwierdzono odbioru danych z rzeczywistego PMDG. Wyników testu z atrapą nie należy przedstawiać jako testu lotnego PMDG.

### ProbeFMCScreens

Opcjonalna próba iFly: otwiera nazwane obiekty SDK, odczytuje stan i próbuje złożyć ekrany przez produkcyjny kod. Podczas wykonanej próby mutex był dostępny (`wait=0`), model wynosił 1, ale stan SDK wynosił **0 — NOT_RUNNING**. Dostawca zwrócił `unavailable_simconnect_fallback`; oba CDU miały `available=False` i zero wierszy. Potwierdzono dostępność obiektów i prawidłowe odrzucenie nieaktywnego SDK. **Nie potwierdzono odbioru tekstu z pracującego FMC iFly** i nie pomijano kontroli stanu SDK.

### Układ binarny SDK PMDG

Wykonano dodatkowe porównanie rozmiarów i offsetów z oficjalnym nagłówkiem przez kompilator C++ `clang-cl`: blok główny 916 bajtów, CDU 1009 bajtów, zgodność offsetów pól. Jest to sprawdzenie układu binarnego, nie działania samolotu. Oryginalny nagłówek producenta i lokalne pliki robocze nie są dystrybuowane w paczce projektu.

## Kompilacja, zależności i paczki

- `build.ps1`: pełna kompilacja aplikacji Win64 z produkcyjnego DPR.
- `check_dependencies.py`: kontrola importów PE; brak Qt, WebView2 ładowane dynamicznie dla raportów.
- `package.py`: utworzenie paczki programu i źródeł, zachowanie struktury katalogów, brak baz, cache IDE i skonfigurowanych kluczy API. Źródła zawierają testy, log weryfikacji i dokumentację.
- Po pakowaniu wykonano porównanie bajtowe wybranych nowych źródeł FMC, czytnika/rejestratora i kontekstu analizy, testów FMC, dokumentacji FMC oraz logu ze źródłowym ZIP-em. EXE i osadzony ZIP źródeł porównano bajtowo z plikami roboczymi.
- Uzupełnienie projektu: wszystkie lokalne jednostki `src/*.pas` powinny mieć jawne wpisy w `MSFS2024-FDR.dpr` i `DCCReference` w `MSFS2024-FDR.dproj`. Po dodaniu jednostki trzeba uaktualnić oba pliki, wykonać kompilację i odpowiednie testy. Sam kompilator może znaleźć jednostkę pośrednio, ale nie zastępuje to aktualnej listy w IDE.
- `tools/check_project.py`, uruchamiany na początku `test.ps1`, porównuje listę jednostek z DPR i DPROJ, wykrywa braki, duplikaty i odwołania do nieistniejących źródeł. To dodatkowa kontrola metadanych projektu, poza 26 programami testowymi Delphi.

## Granice dotychczasowej weryfikacji

Nie wykonano automatycznego pełnego lotu dla wszystkich obsługiwanych samolotów, testu wielogodzinnego nagrywania ani pomiaru wydajności wszystkich pól przy minimalnym interwale. Testy transportu nie potwierdzają aktualności każdej wartości publikowanej przez producenta. Tekst Fenix/FBW ma teraz źródło w FlightPadFMC, sprawdzone na modelu i sztucznym wydawcy, ale jeszcze nie w rzeczywistym locie. Potwierdzenie końcowe wymaga nagrania rzeczywistego lotu, obejrzenia odpowiednich stron FMC oraz sprawdzenia ich historii i czasów w bazie.
## SimBrief — zakres weryfikacji integracji

### VerifySimBriefUI — natywny podgląd Dispatch

Dekodowanie HTML: ponownie skompilowano i uruchomiono `VerifySimBrief` i `VerifySimBriefUI`. Sprawdzono zwykły ampersand (`&ft`), nieznaną encję, `&amp;`, encje dziesiętne i szesnastkowe Unicode (w tym znak spoza BMP), niedozwolone wartości Unicode i brak podwójnego dekodowania `&amp;lt;`. Test formularza zawiera uwagi z `&ft &amp; DATA`; wszystkie sekcje nadal się wczytują, a tekst jest zachowany. Początkowa asercja wykryła przesunięcie indeksów przy składaniu wyniku; poprawiono je zgodnie z indeksowaniem TMatch od 1 w Delphi. Oba zestawy zakończyły się PASS. Wspólny dekoder działa również dla tekstu OFP przekazywanego do analizy. Nie odtwarzano błędu na rzeczywistym bieżącym planie z konta użytkownika; pełnego zestawu testów nie powtarzano.

Automatyczna wysokość sekcji: ponownie skompilowano i uruchomiono test UI. Krótki, trzywierszowy OFP otrzymuje wysokość poniżej 200 px; treść ponad 100 wierszy zwiększa sekcję ponad 1000 px. Sprawdzono odtworzenie wysokości po zwijaniu oraz brak pionowego scrollbara memo (`ssHorizontal`). Wysokość jest obliczana z liczby wierszy i pomiaru czcionki, z zapasem na nagłówek, przycisk i poziomy scrollbar. Zmiana zastępuje wcześniejszą stałą wysokość 640 px. Wynik PASS; pełnego zestawu testów po tej lokalnej zmianie nie powtarzano.

Przewijanie Dispatch: ponownie uruchomiono test UI po dodaniu lokalnej obsługi WM_MOUSEWHEEL. Sprawdzono przewijanie z pola konta i z memo na nadrzędnym ScrollBoxie oraz pominięcie wiadomości skierowanej do kontrolki spoza ramki. Potwierdzono 15 sekcji i brak komponentu `SB_downloads`. Obsługa dotyczy zarówno zakładki, jak i tej samej ramki przeniesionej do osobnego okna. Jest to syntetyczna próba przekazania wiadomości, bez fizycznej myszy. Pełnego zestawu 26 programów po tej lokalnej poprawce nie powtarzano.

Poprawka Briefing Preview: ponownie skompilowano i uruchomiono `VerifySimBriefUI`. Syntetyczny HTML zawiera wiersze LF wewnątrz PRE. Sprawdzono co najmniej trzy osobne wiersze TMemo, dokładne zachowanie wcięcia i odstępów `  FUEL    TIME`, wysokość rozwinięcia co najmniej 600 px oraz zachowanie tej wysokości po zwinięciu i rozwinięciu. Wynik PASS. Wykonano kompilację aplikacji i aktualizację paczek; pełnego zestawu 25 testów po tej lokalnej poprawce nie powtarzano.

Rozszerzenie: sprawdza zachowanie tekstu uwag i ATC bez `dx_rmk`, `flightplan_text` i `atc /`. Timer testowy zamyka rzeczywiste modalne okno `TfrmSimBrief` po sprawdzeniu, że zawiera tę samą ramkę, ma `bsSizeable` i daje się przeskalować. Po zamknięciu sprawdzane są powrót ramki do poprzedniego rodzica i ponowne włączenie przycisku. Nie jest to ręczny test użytkownika ani ponowne pobranie aktualnego planu z serwera.

Nowy test tworzy formularz VCL z produkcyjnym `TfraSimBrief`, bez połączenia sieciowego. Syntetyczny plan ma trasę EPLL–EGLL, niezależną od nagrań testowych. Sprawdzane są: 16 GroupBoxów, lotniska z payloadu w opisie, blokada przypisania bez tripu, dostępność przycisku oryginalnego OFP, przycisk w każdej sekcji, zwijanie i odtworzenie stanu po ponownym wczytaniu, tryb tylko do odczytu, zawijanie przycisków przy małej szerokości, zachowanie pełnego JSON i zachowanie poprzedniego podglądu po błędnej odpowiedzi. Program zapisuje `tests/simbrief-preview.png` do kontroli wyglądu. Nie uruchamia renderowania OFP w WebView2 ani żądania HTTP i nie testuje działania odnośników do zewnętrznych serwisów.

Dodatkowo sprawdzono domyślną nazwę układu LIDO, połączenie kodu linii z numerem lotu i listę kilku alternatywnych lotnisk w formacie JSON v2. Pierwsza asercja zawijania oczekiwała jednej kolumny przy szerokości okna 290 px, choć dwa przyciski mieściły się obok siebie; próbę skorygowano do szerokości 240 px i test przeszedł. Zapisany PNG obejrzano: nagłówki, pola wartości i przyciski nie nakładają się, a sekcje tworzą pionowy przewijany widok. `VerifyUI` sprawdza również, że zakładka SimBrief znajduje się bezpośrednio za Planem lotu i zawiera ramkę. Brak ręcznej próby nowego przycisku pobierania na rzeczywistym koncie.

Rozszerzenie starszych planów: syntetyczny OFP ze starszą datą wymaga jawnej opcji i zapisanej porównywalnej trasy. Test sprawdza akceptację zgodnych punktów w EFB, utrwalenie opcji w bazie i ponowną walidację w analizie, ostrzeżenie w kontekście modelu i oknie informacji, odrzucenie zmienionej rejestracji, numeru lotu oraz punktu trasy mimo zgody na starszą datę. Zmiana zapisanej trasy po imporcie usuwa niezgodny plan z kontekstu AI. Kontrola domyślna nadal odrzuca różnicę dat ponad 12 h. To testy offline; nie wykonano nowego pobrania z SimBrief ani lotu w symulatorze.

Dodatkowe asercje sprawdzają niezgodny typ ICAO i kod linii, porównanie z rozwiniętym navlogiem, odrzucenie zamienionej kolejności punktów i innego SID, odczyt punktów z syntetycznego PLN oraz odrzucenie innego lotniska w PLN. Pierwsze uruchomienie rozszerzonego zestawu wykryło nieobsługiwany odczyt pola INTEGER jako `AsBoolean` w FireDAC/SQLite; zmieniono odczyt opcji na `AsInteger <> 0`. Ponowny samodzielny test SimBrief zakończył się PASS.

`VerifySimBrief.dpr` używa wyłącznie syntetycznej odpowiedzi JSON i własnej tymczasowej bazy SQLite. Sprawdza zgodność obu lotnisk, daty UTC symulatora, numeru lotu (w tym zera wiodące) i rejestracji; odrzucenie innego celu, brakującego celu, innej rejestracji, numeru lotu, starej daty i nieprawidłowej daty. Sprawdza również uzupełnienie celu z zapisanej trasy EFB podczas aktywnego lotu i pierwszeństwo rzeczywistego lotniska nad planem EFB. Sprawdza ponowny import bez duplikatów, zachowanie oryginalnego HTML OFP, przekazanie struktury i dekodowanego tekstu OFP do kontekstu, pominięcie stylów, ograniczenie tekstu dla modelu do 24 000 znaków z jawnym oznaczeniem skrócenia i zachowaniem pełnego OFP w bazie, ponowną walidację przed analizą, obecność informacji w formularzu, powiązanie zdarzeń przycisków/timera oraz usunięcie danych wraz z tripem.

Osobno wykonano odczyt rzeczywistego endpointu SimBrief JSON v2 dla konta użytkownika: HTTP 200, prawidłowy JSON, kompletna sekcja `text.plan_html` i link eksportu PDF. Potwierdzono rzeczywisty format dat ISO UTC, pól lotnisk, numeru lotu i rejestracji. Ta próba była wykonana przez PowerShell; nie jest testem transportu HTTP Delphi ani dowodem zgodności pobranego planu z wybranym nagraniem. Prywatnej odpowiedzi nie dołączono do paczek.

Nie wykonano ręcznego importu w uruchomionej aplikacji, testu przerwanego połączenia sieciowego ani generowania raportu AI z rzeczywistym OFP. Testy nie weryfikują dostępności usługi w przyszłości. Pobieranie działa w wątku z timeoutami; przy zamykaniu formularza aplikacja czeka na zakończenie aktywnego żądania. Nie ma cyklicznego odpytywania ani pobierania osobnego PDF: pełny OFP jest zachowywany jako HTML w surowym JSON i eksportowany z bazy.

## VerifyGSX — opcjonalne dane GSX Pro

Osobno pobrano oficjalny podręcznik GSX Pro (291 stron) i porównano wszystkie 16 nazw katalogu z tekstem SDK na stronach 106–108. Kontrola wykryła różnicę względem starszego nazewnictwa: bieżąca dokumentacja wymienia `FSDT_GSX_DEICE_STATE`, co uwzględniono w kodzie przed końcowym pełnym przebiegiem testów. Hash PDF i źródło zapisano w `support/gsx/README.md`; samego PDF nie dołączono do paczek. Jest to sprawdzenie dokumentacji, nie odczyt z działającego GSX.

Nowy zestaw używa rozszerzonej atrapy `MockFenixSim.dll`, rozpoznającej osobny klient GSX i weryfikującej nazwy `L:FSDT_*`, jednostkę `number`, typ FLOAT64, liczbę osobnych definicji/żądań oraz brak wywołań zapisu. Sprawdza 16 pól, wartości stanu 5, brak pojedynczego pola, NaN, wyjątek SimConnect, błędny rozmiar pakietu, zakończenie sesji, brak odpowiedzi i zachowanie surowych zer ze statusem `received_not_verified`.

W osobnej tymczasowej bazie SQLite zapisuje stan początkowy, identyczny stan i zmianę 5→6. Sprawdza pomijanie identycznej historii, rekonstrukcję wartości 5/5/6 na wykresie `GSX.FSDT_GSX_BOARDING_STATE`, lukę po utracie danych, obecność definicji i danych GSX w kontekście AI oraz usunięcie historii razem z tripem. Nie wykonano rzeczywistego boardingu, tankowania, pushbacku ani odladzania z działającym GSX; test nie potwierdza dostępności każdej zmiennej w zainstalowanej wersji producenta. Nie zmieniano polityki startu i końca tripu.


## VerifyGroups — 2026-10-18

Sprawdzono `VerifyGroups`: filtrowanie każdej grupy, pusta pozycja i brak wyboru jako brak filtra, zachowanie filtra po odświeżeniu, bieżąca grupa w dialogu bsDialog, OK/Anuluj, przypisanie, usunięcie przypisania oraz pusta grupa. Test używa syntetycznej bazy SQLite i rzeczywistych formularzy VCL, bez symulatora. Dodano formularz do DPR/DPROJ (60 jednostek) i cztery tłumaczenia. Pełny zestaw obejmuje teraz 36 programów Delphi oraz cztery kontrole metadanych.

## Toolbar frames — 2026-10-18

Akcje toolbarów i ich ImageListy należą teraz do fraMap/fraGraph i są zapisane w ich DFM-ach. Menu frmMain korzysta z tych samych akcji; main zachowuje tylko odwołania i obsługę przełączania okien. Zoom wykonuje frame wykresów. btnGraphWindow i btnMapWindow w odłączonym oknie przywracają ten sam frame do frmMain. Indeksy ikon pozostają zgodne z menu głównym. Poprawiono też właściwości TFrame w DFM i błędne wpisy uses konfiguracji wykresów.

Rozszerzono VerifyDetachedViews: własność ActionList/ImageList, powiązanie menu z akcjami frame, lokalny zoom oraz rzeczywiste kliknięcia obu przycisków przywracania. Ponowiono VerifyUI, VerifyLocalization, VerifyChartsConfigure i VerifyGroups oraz cztery kontrole metadanych. To testy syntetyczne VCL/SQLite bez symulatora. Wywołania testowe używają lokalnych referencji frame; Delphi 10.2 Win64 generował zapis pod adres 0 dla powtórzonego zagnieżdżonego odwołania property w argumentach wywołania.

## MSBuild / Delphi 10.2 — 2026-10-19

Poprawka zgodności projektu z IDE Delphi 10.2: usunięto AfterTargets z DeployTranslations, a zadanie dopisano po importach do BuildDependsOn i MakeDependsOn. Wcześniejsze testy z MSBuild 4 nie obejmowały starszego parsera projektu w IDE. Kontrola check_project.py odrzuca teraz BeforeTargets/AfterTargets i sprawdza dołączenie kopiowania tłumaczeń do obu ścieżek. Sprawdzono kompilację Build i Make dla Win64 oraz zgodność katalogu bin z translations. Bez ręcznej próby w IDE.

Schemat MSBuild 2.0 zaakceptował poprawiony target i odrzucił wersję z AfterTargets, odtwarzając błąd IDE. Poprawiono uses frmSettingsU: `OllamaAnalysisU`. Build Debug, Make Debug i Build Release Win64 przeszły; logi potwierdzają wykonanie DeployTranslations.

## Unit scope names — 2026-10-19

Przestrzenie nazw Delphi 10.2: Winapi było już w Base, ale zgłoszona kompilacja IDE nie rozwiązała Windows w i18nLocalizer. Dodano pełne Unit scope names w obu bazowych grupach Windows i w Debug/Release Win32/Win64, bez polegania wyłącznie na dziedziczeniu wartości Base. Nie zmieniano źródeł zainstalowanego i18n. check_project.py sprawdza jawne Winapi/System/Vcl/Xml/Data we wszystkich tych grupach. Zweryfikowano Build Debug i Release oraz Make Debug Win64 z kontrolą argumentu -NS w komendzie dcc64. Nie wykonywano ręcznej kompilacji w IDE.

## TFrame DFM — 2026-10-19

Poprawiono DFM fraMap/fraGraph: ClientHeight/ClientWidth zastąpiono Height/Width, usunięto OldCreateOrder, PixelsPerInch i TextHeight. Oba widoki dziedziczą bezpośrednio po TFrame; lokalizacja nadal uruchamia się raz po przypisaniu Parent i reaguje na zmianę języka przez Translator. Zachowano aktualne rozmiary, układ i nazwy użytkownika (btnChartsConfigure). Kontrola projektu odrzuca właściwości formularzy w DFM frame’ów i sprawdza adnotacje TFrame w DPR; akceptuje prawidłowo dziedziczone przestrzenie nazw zapisane przez IDE. Próba negatywna odtworzyła błąd na DFM sprzed poprawki. Ponowiono VerifyDetachedViews, VerifyLocalization i VerifyUI (syntetyczne VCL/SQLite, bez MSFS); sprawdzono utworzenie, odłączanie/przywracanie obu widoków oraz tłumaczenia. Wykonano Build Debug/Release Win64. Bez ręcznego testu projektanta IDE.

Dodatkowo odtworzono Windows not found: ustawienia DCC były po imporcie CodeGear.Delphi.Targets. Przeniesiono grupy konfiguracji przed import bez zmiany ich wartości; BuildDependsOn/MakeDependsOn pozostają po importach. Dodano kontrolę kolejności do check_project.py.

## Linear charts — 2026-10-19

Rysowanie wykresów zmieniono na prosty odcinek między kolejnymi sąsiednimi próbkami. Usunięto poziomy odcinek poprzedzający skok oraz przedłużanie ostatniej wartości do prawej krawędzi. Ponowiono istniejące VerifyChartView i VerifyUI: zoom, przesuwanie, wybór zakresu, kursor i tworzenie VCL. Testy syntetyczne, bez MSFS; Build Debug/Release Win64.

## About / menu / CHM — 2026-10-19

Dodano VerifyHelpAbout: renderowanie przezroczystego narożnika ikony 16×16 na kolorowym tle, zachowanie 34 indeksów, ukrywanie sześciu pozycji menu z Action=nil i przywrócenie po podpięciu, aAboutExecute → modalny frmAbout, Zamknij i zmiana języka PL/EN/DE/ES, konteksty mapy/wykresów oraz cztery pliki CHM. Rzeczywisty WM_HELP otworzył przeglądarkę HTML Help, którą test zamknął. Zapisano i obejrzano zrzuty VCL na danych syntetycznych do docs/screenshots. Skompilowano cztery CHM-y (po sześć tematów); kompilator HHC wymagał spisu treści w kodowaniu Windows, a jego pracę odizolowano od ścieżek z kropką i testowego TEMP. Ponowiono VerifyDetachedViews, VerifyLocalization, VerifyChartsConfigure i VerifyUI oraz cztery kontrole metadanych. Domyślny zestaw ma teraz 37 programów Delphi; w tej zmianie uruchomiono pięć, bez lotu w MSFS. Build Debug/Release Win64 i paczki źródłowa/aplikacji sprawdzone.

## Parameter names — 2026-10-19

Dodano VerifyParameterNames: 212 opisów SimConnect, metadane jednostek (w tym 0–1), numer silnika i indeks tablicy 0, przejście przez wszystkie katalogi iFly/Fenix/FBW/PMDG/AIRLINER, języki PL/EN/DE/ES, wyszukiwanie po opisie i ID. Test dwóch różnych ID z identycznym opisem potwierdza poprawne przesuwanie, ukrywanie i zaznaczanie; zachowane są nieznane preferencje innych samolotów. Odczyt nagrania potwierdza oryginalne etykiety modelu/bazy po wywołaniu funkcji UI. Ponowiono VerifyChartsConfigure, VerifyChartView, VerifyLocalization, VerifyUI, VerifyHelpAbout i VerifyAircraftSDK; po dodaniu opisów AIRLINER/GSX/FSHud ponowiono dwa testy nazw i UI. Razem osiem różnych programów Delphi oraz cztery kontrole metadanych; bez MSFS, na danych syntetycznych i mockach. Domyślny zestaw ma teraz 38 programów, projektu nie opisujemy jako ponownie przetestowanego w całości. Uaktualniono zrzuty w README. Sprawdzono Build Debug/Release Win64 i pakowanie.

Uwzględniono zapisany w trakcie prac dwupanelowy układ formularza i jego aktualne wymiary. Podpięto Na początek/Na koniec/Pokaż wykres; test VerifyParameterNames sprawdza te operacje na surowych ID. Usunięto powielony pusty handler aMoveFirstExecute. Zachowano sześć wybranych ikon strzałek, odbudowując kanał alfa; test pikseli obejmuje teraz 46 ikon. Narzędzie i testy obsługują katalogi Icons/16x16 i Icons/22x22. Ponowiono VerifyChartsConfigure, VerifyParameterNames, VerifyDetachedViews i VerifyHelpAbout po scaleniu zmian IDE. Kopia starego formularza jest zachowana w src/Forms/__history/parameter-names-20261019-141233. Ustawienia konfiguracji DPROJ mają standardową kolejność przed źródłami i importami.

Test regresji VerifyChartsConfigure: zachowanie proporcji list po przesunięciu splittera i powiększeniu/pomniejszeniu okna; format bitmap przycisków zgodny z TSpeedButton Delphi 10.2. Test syntetyczny VCL, bez MSFS.


### Jednostki prezentacji

Testy syntetyczne: VerifyDisplayUnits sprawdza ft/m, ft/min/m/s, kt/km/h, lb/kg, galony USA/litry, temperaturę z przesunięciem, ciśnienie, NaN/Infinity, odrzucenie niezgodnych jednostek, nieznane SDK, zapis/opcje ustawień, tłumaczenia i buforowanie 64 wykresów. Ponadto zaliczone VerifyParameterNames, VerifyChartView, VerifyUI, VerifyChartsConfigure i VerifyHelpAbout (35 ikon głównych i małych, przezroczystość nowej ikony). Brak próby na żywo z MSFS i pomiaru płynności na nagraniu użytkownika. Buforowanie pozostaje włączone także powyżej 16 wykresów; powtarzające się wskazanie tej samej próbki nie odświeża całego podglądu.

2026-10-19 — paczka flightsim.to: świeża kompilacja Release Win64, kontrola zależności PE, 66 plików ZIP, kontrola CRC i zgodności odczytu, architektury x64 EXE/DLL, ładowanie trzech DLL z rozpakowanej paczki, cztery CHM i HTML, rozmiary plików layout opcjonalnego mostka EFB. Potwierdzono brak źródeł Pascal, baz nagrań, logów, prywatnej konfiguracji i cache kont. Rzeczywisty EXE z ZIP uruchomił responsywne główne okno i zamknął się normalnie (exit 0). Pięć angielskich zrzutów z kopii istniejącego nagrania, obejrzanych wizualnie. Bez próby na żywo z MSFS. Nie publikowano; binarna paczka robocza wymaga rozwiązania udostępniania Corresponding Source zgodnie z obecną AGPL.



### Przeciąganie wykresów

Nowy VerifyChartDrag: testy syntetyczne callbacków VCL — dodawanie/usuwanie między listami, miejsce wstawienia/pusta lista/koniec, brak duplikatów, Ctrl wymagany do reorder, identyczne etykiety z różnymi raw ID, usuwanie przy aktywnym filtrze, anulowanie, obce źródła, stan timera przewijania, natywne kliknięcie checkboxa i izolacja kopii roboczej. Zrzut linii wstawienia obejrzany. Zaliczone także VerifyChartsConfigure, VerifyParameterNames, VerifyDetachedViews i VerifyLocalization. Poprawiono stare oczekiwanie trzech zakładek ustawień w teście lokalizacji na cztery (z Jednostkami). Bez fizycznej próby przeciągania myszą i pomiaru przewijania przy nieruchomym kursorze. Domyślna lista test.ps1 zawiera teraz 40 programów.


### Język Windows, dziewięć języków i VersionInfo

VerifyVersionLanguage sprawdza 14 wariantów regionalnych/fallbacków, Windows UI language, utrwalanie auto zamiast języka efektywnego, akcje dziewięciu języków, zapis/Anuluj ustawień, dokładne podpisy nowych języków, Unicode firmy/copyright, odczyt wersji z EXE i etykietę wersji About. Obejrzano zrzuty FR ustawień i RU About. Zaliczone VerifyLocalization, VerifyParameterNames, VerifyHelpAbout, VerifyChartsConfigure, VerifyDisplayUnits i VerifyChartDrag; stare testy dostosowano do ręcznej zmiany MainPanel na MainGroupBox, 40 ikon i 10 pozycji języka. Test bump_build na kopii: 0.1.0.2 → 0.1.0.3; produkcyjny projekt pozostaje 0.1.0.2. Kontrola katalogu: 987 pozycji, wszystkie dziewięć języków, placeholdery i powiązania DFM. Testy syntetyczne, bez zmieniania języka Windows i bez lotu MSFS. Domyślna lista testów zawiera 41 programów; nie uruchamiano całego zestawu w tej zmianie.


Rozszerzenie języków (0.1.0.3): VerifyLocaleExpansion sprawdza 30 przypadków normalizacji regionów, aliasów i fallbacku; wszystkie 25 akcji językowych; dokładne tytuły ustawień, indeksy listy i zapis/odczyt wariantów; tryb auto, brak zmiany separatora dziesiętnego i dostępność pomocy zastępczej. Generuje obrazy formularza dla be-BY, el-GR i pt-BR. Testy są syntetyczne, bez MSFS. Kontrola katalogu obejmuje 1003 definicje w 25 lokalizacjach, znaczniki Format, Unicode i powiązania DFM. Lista domyślna zawiera 42 programy testowe; nie oznacza to wykonania całej listy w tej zmianie. Uruchomiony zakres regresji: VerifyLocaleExpansion, VerifyVersionLanguage, VerifyLocalization, VerifyParameterNames, VerifyHelpAbout, VerifyChartsConfigure, VerifyDisplayUnits, VerifyChartDrag. Nowe teksty nie przeszły przeglądu native speakera; testy nie oceniają jakości językowej całego katalogu.


VerifyGlobalLocales: test syntetyczny 32 pozycji sortowanych kodem, aliasów, pięciu prywatnie ładowanych plików fontów i brakujących glifów siedmiu próbek pisma. Sprawdza BiDiMode aplikacji/formularza, przejścia RTL/LTR i powrót etykiet do pozycji kotwic, zachowanie LTR danych surowych, mapy i osi czasu, zapis/odczyt ustawień oraz obrazy siedmiu języków. check_fonts.py weryfikuje źródła, SHA-256, format fontów i dwie licencje OFL. check_documentation.py kontroluje cztery Translation.*.md i linki u góry README. Lista domyślna ma 43 programy; nie oznacza wykonania całego zestawu. Brak prób w MSFS i przeglądu językowego native speakerów.


Wykonany zakres tej zmiany: 11 testów zakończonych PASS: VerifyGlobalLocales, VerifyLocaleExpansion, VerifyVersionLanguage, VerifyLocalization, VerifyChartsConfigure, VerifyDetachedViews, VerifyDisplayUnits, VerifyHelpAbout, VerifyParameterNames, VerifyChartDrag, VerifyReport.


Sprawdzono również świeże okna tworzone już w trybie arabskim/hebrajskim: kierunek RTL i położenie etykiet po prawej stronie.


0.1.0.5 — VerifyRTLReturn: start aplikacji z zapisanym ar-SA, otwarcie menu przez WM_INITMENUPOPUP, przejście do en-US oraz cztery przejścia ar-SA/he-IL → pl-PL. Sprawdza kierunek VCL i bity HWND (WS_EX_RTLREADING, WS_EX_RIGHT, WS_EX_LEFTSCROLLBAR, WS_EX_LAYOUTRTL) wszystkich widocznych podkontrolek, układ paneli, brak znaków & w nazwach języków oraz niezmienione ImageIndex wszystkich 32 akcji. Ustawienia testowe są przywracane; bin/settings.ini użytkownika nie jest używany. Wybrany zakres zakończony PASS: VerifyRTLReturn, VerifyGlobalLocales, VerifyDetachedViews, VerifyLocalization. Wyłącznie testy syntetyczne, bez lotu w MSFS. Lista domyślna zawiera 44 programy, nie wykonano jej w całości.


0.1.0.6: test VerifyRTLReturn rozszerzony o rzeczywiste flagi MFT_RIGHTORDER/MFT_RIGHTJUSTIFY całego drzewa HMENU, otwarcie podmenu i przejście hebrajski → Automatycznie. Przed poprawką test wykazał pozostawione flagi; po poprawce PASS. Pozostałe zaliczone testy: VerifyGlobalLocales, VerifyDetachedViews, VerifyHelpAbout. Bez prób lotu w MSFS. Zachowano StackTrace i dyrektywy StackFrames; sprawdzono kompilację Debug z generowaniem PDB.


VerifyVersionLanguage — PASS (EXE VersionInfo 0.1.0.6).


0.1.0.7 — pakowanie: usunięto dodatek mateusz-efb-ifly i katalogi Community/Optional-Community z pakietów, parametr --addon oraz instrukcje jego instalacji. Walidacja ZIP sprawdza brak dodatku; zmiana dotyczy dystrybucji, bez dodatkowych testów zachowania VCL.

Dodano dekodowanie zapisanych trybów FMA FBW i katalog tekstów E/WD z formatowaniem, zegarem migania z nagrania i zachowaniem nieznanych kodów. Ustawienia Debug pozwalają wymusić rodzinę instrumentów. Mapa pokazuje ograniczenia PLN i uzupełnia bezimienne punkty z navlogu SimBrief po GPS. Pełne STS, FMA iFly/B38M oraz rozwinięcie procedur/holdingów/missed approach wymagają dodatkowego źródła danych; zakres opisuje `support/fbw/display-protocol.md`.

Synthetic coverage: VerifyAirbusDisplays (FMA words, EWD codes, missing/unknown data, debug override), VerifyFlightPlan (PLN constraints and OFP coordinates). Live simulator validation not performed.

Rozwijanie wybranych SID/STAR/APP przez SimConnect Facilities: przejścia pasa/enroute/IAF, ograniczenia, odcinki RF/AF i missed approach. Snapshot navdata jest zapisywany wraz z oryginalnym planem w nagraniu i odtwarzany offline. Holdingi HA/HF/HM zachowują parametry i mają schematyczny symbol na mapie, missed approach jest ciemnoszare. FMA B38M/iFly jest rekonstruowane z zapisanych lampek MCP i SimVarów; podpis FMA RECONSTRUCTED wskazuje, że to przybliżenie, szczególnie VNAV, THR HLD i FLARE. Nie jest to bezpośredni odczyt FMA z dodatku.

VerifyProcedureRoute: mock Facilities API exports and headers, out-of-order parents, ItemIndex ordering, wrong runway exclusion, RF geometry, holding/missed constraints, repeated expansion, SQLite and offline replay. VerifyIFlyFMA: lamp encoding, mode priorities, AP/FD, ILS/armed GS, altitude capture and missing data. VerifyPFD737, VerifyFlightPlan, VerifySimBrief, VerifySubscriptions: regression checks. No live simulator or IDE designer validation. VerifyProcedureRoute disables the Delphi 10.2 Win64 optimizer to avoid compiler internal error URW1237; application builds retain their normal settings. DLL mock projects now explicitly set GenDll, preventing stale .dll use when the compiler otherwise writes a library to .exe.

Dodano odtwarzanie Flight Directora w PFD A320 i B38M, zapis standardowych komend FD/EX1 w radianach i opcję wyłączenia FD B38M. Brakujące dane historyczne pozostają niedostępne; rzeczywiste zero nie jest brakiem danych. Źródła i ograniczenia: `support/fbw/flight-director.md`.
VerifyFlightDirector, ProbeFlightDirector, VerifyAirbusDisplays, VerifyPFD737: synthetic replay tests; live simulator channels not verified.

PFD B38M dopasowano do wzorców: krzyżowy FD, wspólne tło horyzontu, wyrównane taśmy i półróża kursowa, GS/TAS/wiatr. Opcjonalny AoA w ustawieniach Debug korzysta z zapisywanego INCIDENCE ALPHA. Nastawy MCP odzyskiwane są również z cyfr SDK iFly; rekonstrukcja N1/MCP SPD nie wymaga prawdziwej standardowej flagi A/T, jeżeli stan potwierdzają SDK ARM i lampka trybu. FMA nadal jest estymowane.
VerifyPFD737: synthetic AoA/radians/ground/missing/optional/render checks. VerifyIFlyFMA: 22 recorded AFDS configurations plus synthetic cases; no authoritative recorded FMA text, no live comparison.

Opcjonalny panel informacji MAX przy PFD pokazuje numer lotu, kod transpondera SDK (z zerami wiodącymi), rejestrację, SELCAL jeśli dostępny oraz UTC, datę i czas od początku nagrania. Panel można ukryć w ustawieniach Debug. Brakujące dane pozostają oznaczone --; czas nie korzysta z zegara komputera.
VerifyPFD737: synthetic panel rendering/hide, recorded midnight crossing, reverse seek, invalid time, missing SELCAL and squawk leading zero. VerifyFlightDirector: SQLite flight metadata roundtrip. No live test.

Minima FBW A320: BARO, RADIO i NO DH z ważnych słów ARINC, opis na PFD i znacznik na taśmie wysokości w widocznym zakresie. RADIO używa bieżącej wysokości radiowej, nie jest traktowane jako wysokość MSL. Panel informacji B38M można przenosić lewo/prawo (CPT/FO) niezależnie od jego ukrycia. Wartości minimów iFly/Fenix nie są obecnie potwierdzone w dostępnych katalogach; projektowe DECISION HEIGHT nie jest używane jako nastawa pilota.
VerifyPFDMinima: synthetic ARINC BARO/RADIO/NO DH, zero/missing, relative RA, off-scale/amber marker. VerifyPFD737: CPT/FO panel position and return. VerifyAirbusDisplays: BARO visual fixture. No live comparison.

PFD B38M: strzałka kierunku przepływu wiatru względem kursu TRUE oraz bloki VOR/ADF 1 i 2 z częstotliwością i dostępnym DME. Nowe kanały NAV/ADF zapisywane są jako nullable REAL; stare nagrania nie otrzymują sztucznych wartości. Oba PFD przełączają wybraną prędkość IAS/Mach i pokazują STD niezależnie od dostępności liczbowego ciśnienia; FBW korzysta z natywnych stanów STD/QNH/QFE. Chwilowe przyciski STD/SPD-MACH nie są traktowane jako trwałe stany.
VerifyPFDReadouts: synthetic native/standard mode priority, STD vs QNH 1013, QFE/invalid ARINC, IAS/Mach/blank MCP, VOR/ADF/OFF/zero/missing DME, TRUE-relative wind and SQLite NULL/frequency roundtrip. VerifyPFD737/VerifyAirbusDisplays snapshots; VerifySubscriptions checks NAV/ADF only during flight. No live test.

Odtwarzanie nagrań: start/pauza, stop z resetem do początku i 1x, początek/koniec, skoki ±30 s oraz tempo 0.125/0.25/0.5/0.75/1/2/4/8/16x. Mapa, wykresy i odłączone przyrządy korzystają ze wspólnej osi czasu. Nowe nagrania zachowują skonfigurowany początkowy interwał próbkowania; dla starszych jest estymowany z mediany poprawnych odstępów, z rezerwą 500 ms. Poprawiono alfa ikon obu list, zachowując ręcznie dodane grafiki i ich indeksy.
VerifyPlayback: deterministic playback clock/rates/pause/seek/gaps/end/stop, stored and inferred cadence, SQLite and read-only legacy schema. VerifyInstrumentFrames: DFM actions, timer/glyph switching and transparent icon drawing in both sizes. Synthetic only, no simulator required.


FSHud ATC: VerifyFSHud sprawdza tekst legacy i MessageItems, częstotliwość, znak nadawcy, cofanie czasu i zachowanie historii po Removed na sztucznych pakietach. Schemat potwierdzony odczytem lokalnego panelu FSHud. Nie wykonano próby transmisji ATC podczas lotu. Nagrania bez sim_utc i wiadomości sprzed dostępnej historii nie są odtwarzane; audio nie jest zapisywane.

Blokada kursora wykresów podczas odtwarzania: kompilacja formularza i regresja VerifyInstrumentFrames; ręczna próba ruchu myszy podczas odtwarzania pozostaje do wykonania.


Dokowanie VCL: VerifyNativeDocking testuje rzeczywiste komponenty VCL na syntetycznych kontrolkach: wypinanie zakładki, dokowanie boczne, zapis/odczyt hosta i drzewa DockManager, zamknięcie z powrotem do zakładek oraz zachowanie kontrolek podczas zamykania aplikacji. VerifyDetachedViews i VerifyViewState sprawdzają zgodność dotychczasowych sześciu odłączanych widoków i stanów po restarcie. Próba ręczna przeciągania w działającym symulatorze nie została wykonana.


VerifyNativeDocking dodatkowo sprawdza 50 przesunięć jednego okna podglądu, ujemne współrzędne ekranowe, pusty środek regionu, ukrycie po zakończeniu/anulowaniu i usunięcie HWND po zniszczeniu obiektu przeciągania. Test syntetyczny WinAPI/VCL; ręczna próba na konfiguracji monitorów ze zgłoszenia nie została wykonana.


VerifyPlayback: interpolacja w połowie odstępu i przy niezmienionym indeksie próbki, kurs 359→1°, pozycja przez południk 180°, zachowanie zer/bool/SDK i NaN, brak zmiany oryginalnych tablic oraz blokada interpolacji przez przerwę nagrania. Dane syntetyczne; płynność wizualna na rzeczywistym nagraniu nie została oceniona ręcznie.


VerifyInstrumentRender: rzeczywiste piksele krawędzi, clipping i przywracanie stanu DC dla skal 25/50/75/100/125/150/200/300%, plus render PFD B38M/A320, six-pack i EICAS do PNG z kontrolą wizualną podglądu. Test syntetyczny WinAPI/VCL, nie jest próbą zmiany DPI między fizycznymi monitorami. VerifyInstrumentFrames sprawdza regresję osadzonych i odłączanych przyrządów.


VerifyPanelProportions: wielokrotny resize zagnieżdżonych paneli bez narastającego błędu zaokrągleń, nowe proporcje po splitterze, ukryte panele i minimalna przestrzeń środkowa. Rzeczywiste okna VCL PFD/EICAS: dokowanie boczne i pionowe, wielokrotne skalowanie oraz bezpieczne zamknięcie hosta bez zamykania silników. Testy syntetyczne; ręczne przeciąganie podczas lotu nie było wykonywane.


Zweryfikowano offline: VerifySimWeather (osobne źródła, kolejka HTTP, rozkodowanie i porównanie, DFM), test_weather_bridge.js (atrapa Coherent), VerifyReplayExtras (FLIGHT_START i 30 s ATC), VerifyUI (filtrowanie i wypięcie wszystkich zakładek), VerifySimBriefUI, VerifyRecordingFiles (cel z zapisanego PLN). Bez próby pogody i geometrii procedur na żywym MSFS; symulator nie był uruchomiony. Pełnego dumpa CTD nie analizowano.

Regresja migania: VerifyUI mierzy zdarzenia OnResize paneli i paska stanu podczas 100 niezmienionych odświeżeń. Przed poprawką: 400; po poprawce: 0. Test obejmuje również wypięcie wszystkich zakładek i ponowne dokowanie. Próba syntetyczna VCL.


VerifySimBriefMaps: lokalny HTTP zwraca GIF i błędny HTML; sprawdzono BLOB, zgodność z wersją planu, odtwarzanie DFM po zatrzymaniu serwera, brak ponownego pobierania i usuwanie obrazów wraz z lotem. VerifySimBriefUI wysyła WM_MOUSEWHEEL przez kolejkę Windows i sprawdza runtime binding po Loaded; w DFM nie ma OnMessage. VerifyNativeDocking i VerifyUI sprawdzają alClient bez wypinania oraz brak cyklicznych resize. VerifyIFlyDisplays sprawdza brak delty przy zmianie samego Tick18. Jedna rzeczywista mapa z zapisanych linków SimBrief: HTTP 200, poprawny nagłówek GIF, 32904 bajty, bez przekierowania (próba pobrania przez Python, nie pełny test live GUI). Designer IDE nie był sterowany automatycznie.


Fenix 3.0.0.7454: statyczny audyt 176 XML w pakietach common i aircraft-320, 3826 deklaracji w 55 plikach, 1748 bieżących kandydatów i 300 nazw historycznych. VerifyCatalogSources.dpr sprawdza przenoszenie pól do attachmentów, duplikaty, hashe, rozdzielenie historii i wybór wyłącznie pakietów tej samej wersji (bez liveries). VerifyFenix używa przebudowanej atrapy DLL i sprawdza 1748 odczytów, null/zero/przeterminowanie, historię starych nieznanych nazw i brak subskrypcji wycofanych breakerów. Bez próby na uruchomionym nowym Fenixie; deklaracje nie dowodzą dostępności runtime, jednostek ani pełnego FMA/FD.

- CSS Classic: VerifyFlapsHandle obejmuje B733/B734/B735; test syntetyczny etykiet, bez próby na żywo z wariantami 300/400.

Ghost/ATC: VerifyGhostReplay + MockGhostSim sprawdza SQLite :memory:, właściciela połączenia, tworzenie/freeze/animacje/usuwanie, pauzę, ±10 s, brak danych i MSFS24-only. VerifyNativeATC sprawdza HTTP, SQLite, deduplikację, czas replay i wygaszanie komunikatu; VerifyATCBridge.js parsowanie payloadów. VerifyIDEProjectSave sprawdza zapis kopii DPROJ przez TXmlIniFile. Próby syntetyczne, bez walidacji na żywo FSLTL/ATC ani zapisu z otwartego IDE (niedostępny kanał pulpitu).

Grupy IDE: check_project_groups.py — PASS dla 2 grup i 101 projektów (GUID, ścieżki, targety, wersje i węzły IDE). VerifyIDEProjectSave — PASS: zapis/ponowny odczyt 103 izolowanych kopii grup/projektów przez TXmlIniFile. Build głównego groupproj Release Win64 — PASS (aplikacja + instalator). Rzeczywisty zapis w otwartym IDE nadal wymaga potwierdzenia po przeładowaniu grupy; sam test XML nie dowodzi usunięcia crasha IDE.

Bridge/FSLTL: VerifyBridgeInstall — PASS dla wykrywania Community, instalacji/aktualizacji/naprawy, pozostawienia zdrowych plików i usuwania tylko własnych plików. VerifyBridgeSignature — PASS: dwie szyfrowane warstwy ZIP, osobne podpisy RSA-3072/PSS i manifesty, błędne hasło/produkt oraz uszkodzony payload, wyłącznie efemeryczny klucz CNG. VerifyAIModelMatching i rozszerzony VerifyGhostReplay — PASS dla FSLTL/AIG, typu/livery i fallbacku bez zainstalowanej biblioteki. VerifySetupUI, VerifySetupMaintenance, VerifySetupSignature, VerifyUI i VerifySubscriptions — PASS. Profile FSLTL: 75 rodzin, 134 hashe XML z lokalnego klona Base; bez modeli/tekstur w dystrybucji. Wszystkie próby są izolowane/syntetyczne; bez instalowania do prawdziwego Community i bez potwierdzenia animacji na żywo. Początkowe błędy testu kryptograficznego wynikały z pełnego woluminu montowanego pod Dane_HDD; po oczyszczeniu wyłącznie wygenerowanych fixture/DCU test przeszedł.


## Installer source split

`VerifySetupArchitecture` creates the base DFM wizard for two unrelated synthetic
products, checks independent Program Files/release identities and navigation,
and links no FDR units. `VerifySetupUI` exercises the inherited MSFS page, back
navigation, default Community checkbox, modal retry/cancel and asynchronous
update fallback. `VerifySetupMaintenance` covers all 32 locales, RTL/LTR,
retention choices and exact-version repair. Signature, bridge ownership and
IDE XML-save probes remain isolated tests. The signed/encrypted full packager
interop test generates an encrypted ephemeral RSA key outside all repositories;
production private keys are not used. Windows installation and registry writes
are test doubles; no live installation, MSFS or Community directory is changed.

Shared sources live beside the recorder repository in `setup-common`,
`setup-core` and `MSFS24-FDR-Setup`. Version information comes directly from the
Common submodule (`src/Common/VersionU.pas`), without modifying that submodule.
The core's final license text will be supplied by the author. No new Git
repositories were created.


Release update gate: VerifySetup now checks disabled controls, forced false on save, legacy/manual INI opt-in rejection and a blocked programmatic check request. The distributed Setup is a native message-only stub, built without installer/private inputs. The real installer remains development code and requires explicit `tools/build_setup.ps1 -RealInstaller`.


Compiled resources: *.res are ignored and absent from the Git index. Main, stub
and i18n resources rebuild from checked-in *.rc (and original bitmap/icon inputs)
using tools/build_resources.py and the Windows SDK Resource Compiler. Independent
MSBuild test projects rebuild these resources through Tests.Shared.props.


Installer separation: recorder Core no longer contains the product/key unit and the
recorder DPR has no installer/common updater imports. VerifySetup uses the recorder
mutex and confirms the independent installer detects it; disabled update settings
and programmatic requests remain covered by the same isolated regression.


Regresje `Verify*.dpr` używają DUnitX (91 projektów, w tym nowy VerifyCatalogSources). Testy Python z tests przeniesiono do DPR: asercje są natywne; testowane narzędzia importu Python są uruchamiane przez CLI z izolowanymi fixture. Mocki i sondy pozostają samodzielnymi programami/DLL. Każdy DPR ma DPROJ i wpis w Tests.groupproj, synchronizowane przez tools/sync_test_projects.py. test.ps1 buduje projekty MSBuild, uruchamia formatter przed kompilacją i usuwa testowe MAP/RSM w finally. Pełny wynik bieżącego przebiegu opisano w docs/releases/0.1.1-review.md. Test języka AI obejmuje wszystkie 32 lokalizacje bez wywoływania modelu; test PFD sprawdza piksele panelu po lewej dla CPT i po prawej dla FO.

Pomoc: VerifyHelpContexts sprawdza 62 rozdziały w czterech językach, wszystkie HelpContext z DFM, zgodny język ilustracji i katalog 398 parametrów. build_help.py dodatkowo dekompiluje każdy CHM i porównuje bajty stron/obrazów ze źródłami. Galeria obejmuje 228 ilustracji; dane telemetrii są syntetyczne, plan/OFP to zanonimizowany przykład pętli EPLL–EPLL. VerifyPFD737 obejmuje tworzenie ramek we wszystkich 32 językach, VerifyRTLReturn stabilność położenia menu podczas aktualizacji akcji, VerifySimWeather chmury METAR bez CB/TCU.

Kodowanie pomocy: VerifyHelpContexts czyta HTML/HHC właściwą stroną Windows, sprawdza polskie znaki i brak encji w nazwach spisu. build_help.py sprawdza wszystkie 248 etykiet bezpośrednio w skompilowanych strumieniach #STRINGS oraz obecność #TOCIDX, korzystając z CLI 7-Zip.

Regresja raportu: VerifyReport korzysta z tego samego HelpScreenshotU co generator pomocy. Sprawdza zachowanie treści i render RichEdit do bitmapy przez EM_FORMATRANGE; generator weryfikuje też obecność pikseli tekstu w ilustracji. Raport demonstracyjny PL/EN/DE/ES ma osobne zrzuty początku i dalszych wniosków. Dane lotu mają monotoniczne znaczniki co 20 s i jawnie zapisany interwał, fazy lotu oraz zmienną konfigurację/GSX/ATC.
