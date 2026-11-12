# Historia zmian

Historia zaczyna się od initial Preview, następnie obejmuje wydania `0.1.0`, `0.1.1` i kolejne. Zmiany są grupowane według wersji wydania `Major.Minor.Release`. Kolejne buildy uzupełniają wpis tego samego wydania; nie mają osobnych sekcji ani oznaczeń w tej historii.


## 0.1.1

- Panel informacji PFD B38M łączy zapisany kod ICAO linii z numerem lotu, np. LOT i 131 daje LOT131, zachowując pełne callsigny.

- Menu nie jest odrysowywane przy niezmienionych nagłówkach; zmiany są łączone w jedno odświeżenie. Uzupełniono tłumaczenie podpowiedzi wyszukiwania wartości i naprawiono kopiowanie bieżącego katalogu tłumaczeń po Build/Make.

- Usunięto ponowne podpinanie już aktywnego menu podczas aktualizacji akcji, powodujące przejściowe przełączanie RTL/LTR i migotanie nagłówków.

- Naprawiono puste ilustracje raportu analizy w CHM. Przykłady obejmują pełniejsze raporty, fazy lotu, konfigurację, silniki, historię ATC i postęp GSX.

- Poprawiono polskie i zachodnioeuropejskie znaki w drzewie CHM; kompilacja sprawdza teraz kodowanie wszystkich etykiet w gotowym pliku.

- Rozbudowana pomoc CHM: 62 rozdziały w PL/EN/DE/ES, 228 lokalizowanych ilustracji osobnych paneli, wszystkie strony ECAM i katalog 398 standardowych parametrów. Przykłady planu/OFP używają zanonimizowanej pętli EPLL–EPLL. Poprawiono kodowanie spisu i rozmieszczenie obrazów.


- Panel informacji B38M: lewa strona dla CPT, prawa dla FO; poprawione opisy ustawień. Raport AI ma odpowiadać w aktualnym języku aplikacji. Uzupełniono tłumaczenia menu odtwarzania i diagnostyki PMDG 777.


- PFD A320 pokazuje przy wskazówce niezerową prędkość pionową w setkach ft/min; przy zerze odczyt jest ukryty.

- Zasoby aplikacji są odtwarzane ze źródeł RC; skompilowane RES nie są wersjonowane. Paczka portable jest przygotowywana bez hasła i z bieżącą dokumentacją.
- Tymczasowy MSFS24-FDR-Setup.exe wyświetla informację o pracach nad instalatorem/updaterem/dezinstalatorem i kończy działanie. Aktualizacje są zablokowane w ustawieniach i kodzie uruchomieniowym, także dla wcześniej włączonej opcji w INI; wydanie uruchamia się ręcznie po rozpakowaniu.

- Dodano FSLTLU z profilami wejść animacji 75 rodzin modeli, w tym reversów. Ghost sprawdza przy starcie zainstalowane FSLTL/AIG, wybiera najlepszy typ i livery (FSLTL przy remisie), a następnie modele domyślne; nagrania zapisują dodatkowe kanały ciągu i animacji.

- Ujednolicono opcjonalny dodatek jako MSFS24-FDR-Bridge; paczka portable zawiera zwykły folder do ręcznego skopiowania do Community.

- Uzupełniono metadane projektów i grupy testów Delphi oraz kontrolę zapisu przez TXmlIniFile.

- Domyślne ATC MSFS24: opcjonalny bridge odbiera JS_LISTENER_ATC, zapisuje tekst i surowe payloady; replay i ostatni komunikat korzystają z osi nagrania. Osobno zapisywane stany zezwoleń, pasów i stacji ATC/COM z SimConnect.

- Ghost replay w osobnym wątku i połączeniu SimConnect, z bazą SQLite w pamięci, doborem modeli FSLTL/AIPlane, interpolacją, animacjami i sterowaniem play/pause/stop/±10 s. Odświeżanie 5–60 Hz w ustawieniach; poprawiona przezroczystość ikony przewijania wstecz.

- CSS 737 Classic: wspólna obsługa wariantów 300/400/500 (B733/B734/B735), etykiet klap i rozpoznawania ICAO z nazwy samolotu.

- Standardowy flaps_handle_index przeniesiony do FlapsHandleU z jawnym case po ICAO i pustym DisplayValue domyślnie. 156 kody: 66 profile, 30 typów bez klap, 60 niepotwierdzonych pozostawionych pustych. A320 standardowego SimConnect rozróżnia 1+F (6 stanów) od 5-pozycyjnej dźwigni SDK. MD-11 wybiera profil TFDi/SkySim po tytule; liczba pozycji zapisana w nagraniu blokuje niedopasowane profile. Dodano metadane 26 konfiguracji oraz CSV pokrycia, również dla samolotów domyślnych MSFS 2024.

- Ponowny audyt SDK i XML kokpitów: 5118 pól z DisplayValue (2313 dodatkowych). Poprawne dekodowanie GB18030 nagłówka iFly odzyskuje enumy i kody znaków wyświetlaczy; etykiety ANIMTIP wzbogacają Fenix, dokumentacja FBW i komentarze PMDG uzupełniają selektory. Dodatkowe katalogi L-var otrzymują jawnie potwierdzone stany bool i przyciski chwilowe. Mapowania zachowują źródła oraz SHA-256, a zakresy i nieopisane wartości pozostają liczbami.

- Zakładka GSX Pro: paski postępu pojawiają się od Requested, zachowują zakończony stan i reagują na cofanie osi czasu. Osobne paski pasażerów i bagażu oraz licznik bieżącej cysterny; usługi bez liczników mają wskaźnik nieokreślony zamiast wymyślonego procentu. Zapisywane są także licznik i limit cysterny oraz podłączenie przewodu paliwowego.

- Czytelne wartości przełączników: katalogi zawierają pole DisplayValue ze słownikami liczba=opis, używanymi przez listę wartości i wykresy. Pozycje klap i autobrake 737 mają oznaczenia kokpitowe bez tłumaczenia; standardowe indeksy klap są zależne od typu samolotu. GSX pokazuje tłumaczone etapy, łączny licznik pasażerów względem nowo zapisywanej liczby docelowej i rzeczywisty procent obsługi bagażu; brakujące i nieznane dane nie są zgadywane.

- Sprawdzanie wersji symulatora w odpowiedzi SimConnect OPEN: nagrywanie i jego akcje są dostępne wyłącznie dla MSFS 2024. Starsze i nierozpoznane symulatory nie otrzymują subskrypcji; aplikacja wyświetla uprzejmy komunikat w wybranym języku.

- Aktualizacja katalogu Fenixa dla modułowych pakietów common/aircraft-320 3.0.0.7454: 1748 bieżących kandydatów L-var z kokpitu CEO, paneli, wariantów CFM/IAE i attachmentów. 300 starych nazw pozostaje wyłącznie do opisu historii. Odtwarzanie wykrywa zapisane klucze Fenixa zamiast narzucać nowy katalog starym lotom; nagrania zachowują hash całego katalogu i wersję pakietu.

- Pomijanie technicznego Tick18 przed zapisem delt iFly; licznik nie trafia do listy parametrów. SimBrief: mapy GIF pobierane w tle, zapisywane jako BLOB przy dopasowanym planie i wyświetlane offline; usunięto sekcję zgłaszania planu do sieci. Poprawiono inicjalizację scrolla po Loaded oraz alClient dokowanych zakładek przy starcie i aktywacji.

- Usunięto miganie i cykliczne zmiany rozmiaru paneli: niezmieniony układ dokowania nie wywołuje ponownego wyrównywania; pasek stanu odświeża tekst wyłącznie po zmianie treści.

- Pogoda: opcjonalny dodatek Community pobiera METAR/TAF z symulatora. Raporty MSFS i AviationWeather są zapisywane osobno, z porównaniem i oknem rozkodowanego METAR. Archiwalne żądania nie pobierają dzisiejszej pogody symulatora.
- Poprawki interfejsu: wyszukiwanie parametrów po nazwie lub opisie, zakładka GSX Pro, komunikat ATC widoczny przez 30 sekund czasu nagrania, przewijanie SimBrief bez focusa, framy mapy/wykresów/SimBrief w DFM oraz zwijanie pustych hostów dokowania.
- Automatyczny zapis MSFS24 czeka na zdarzenie FLIGHT_START zamiast samego załadowania samolotu. Cel jest przepisywany z planu, także do brakujących metadanych starszych nagrań. Pobieranie geometrii procedur ma ponowienia i szczegółową diagnostykę.

- Panele głównego okna zachowują proporcje podczas zmiany rozmiaru; przesunięcie splittera ustala nową proporcję, z uwzględnieniem minimum miejsca i ukrytych/odłączonych widoków. EICAS/ECAM można zadokować do odłączonego okna PFD, obok lub pod nim; wspólny układ skaluje się proporcjonalnie. Zamknięcie hosta pozostawia pozostałe okna przy życiu, a host i kierunek dokowania są przywracane przez centralny zapis stanu.

- Antyaliasing renderowanych przyrządów: wspólny supersampling dopasowany do docelowego rozmiaru w pikselach, z wygładzonym tekstem i filtrowanym zmniejszaniem. Obsługuje pomniejszenie poniżej 100%, powiększenie, zmianę rozmiaru panelu i odłączone okna. Przeskalowano też maski przycinania horyzontu; buforowanie ogranicza dodatkowe zużycie pamięci.

- Płynne odtwarzanie: widoki odświeżają się w każdym takcie zegara, z interpolacją standardowych parametrów ciągłych, pozycji na mapie i kursora wykresów pomiędzy próbkami. Kierunki przechodzą najkrótszą drogą przez północ; stany dyskretne i surowe dane SDK nie są interpolowane. Przerwy nagrania i brakujące wartości nie są uzupełniane sztucznym ruchem. Ograniczono przebudowywanie tabeli parametrów do zmian próbki.

- Podgląd przeciągania przy dokowaniu jest osobnym, nieaktywnym oknem z przezroczystym środkiem zamiast obrysu XOR rysowanego po pulpicie. Ruch, upuszczenie i anulowanie usuwają podgląd bez pozostawiania wielokrotnych ramek na monitorach.

- Natywne dokowanie VCL: przeciąganie zakładek do osobnych okien, ponowne dokowanie w zakładkach lub w czterech strefach krawędziowych z podziałami i splitterami. Dotychczasowe odłączane ramki także można dokować. Układ, kolejność zakładek, hosty i geometria okien są zapamiętywane; zamknięcie odłączonej zakładki przywraca ją do panelu danych. Tytuły aplikacji i głównego okna zawierają wersję odczytaną z EXE.

- Podczas aktywnego odtwarzania ruch myszy nad wykresami nie zmienia pozycji osi czasu. Po pauzie przewijanie myszą działa ponownie.

- Zakładka ATC / FSHud: zapisany tekst komunikacji, częstotliwość i nadawca zsynchronizowane z osią czasu; historia zachowuje również wiadomości usunięte z krótkiej listy FSHud. Brakujące dane nie są rekonstruowane.

- Odtwarzanie nagrań: start/pauza, stop z resetem do początku i 1x, początek/koniec, skoki ±30 s oraz tempo 0.125/0.25/0.5/0.75/1/2/4/8/16x. Mapa, wykresy i odłączone przyrządy korzystają ze wspólnej osi czasu. Nowe nagrania zachowują skonfigurowany początkowy interwał próbkowania; dla starszych jest estymowany z mediany poprawnych odstępów, z rezerwą 500 ms. Poprawiono alfa ikon obu list, zachowując ręcznie dodane grafiki i ich indeksy.

- PFD B38M: strzałka kierunku przepływu wiatru względem kursu TRUE oraz bloki VOR/ADF 1 i 2 z częstotliwością i dostępnym DME. Nowe kanały NAV/ADF zapisywane są jako nullable REAL; stare nagrania nie otrzymują sztucznych wartości. Oba PFD przełączają wybraną prędkość IAS/Mach i pokazują STD niezależnie od dostępności liczbowego ciśnienia; FBW korzysta z natywnych stanów STD/QNH/QFE. Chwilowe przyciski STD/SPD-MACH nie są traktowane jako trwałe stany.

- Minima FBW A320: BARO, RADIO i NO DH z ważnych słów ARINC, opis na PFD i znacznik na taśmie wysokości w widocznym zakresie. RADIO używa bieżącej wysokości radiowej, nie jest traktowane jako wysokość MSL. Panel informacji B38M można przenosić lewo/prawo (CPT/FO) niezależnie od jego ukrycia. Wartości minimów iFly/Fenix nie są obecnie potwierdzone w dostępnych katalogach; projektowe DECISION HEIGHT nie jest używane jako nastawa pilota.

- Opcjonalny panel informacji MAX przy PFD pokazuje numer lotu, kod transpondera SDK (z zerami wiodącymi), rejestrację, SELCAL jeśli dostępny oraz UTC, datę i czas od początku nagrania. Panel można ukryć w ustawieniach Debug. Brakujące dane pozostają oznaczone --; czas nie korzysta z zegara komputera.

- PFD B38M dopasowano do wzorców: krzyżowy FD, wspólne tło horyzontu, wyrównane taśmy i półróża kursowa, GS/TAS/wiatr. Opcjonalny AoA w ustawieniach Debug korzysta z zapisywanego INCIDENCE ALPHA. Nastawy MCP odzyskiwane są również z cyfr SDK iFly; rekonstrukcja N1/MCP SPD nie wymaga prawdziwej standardowej flagi A/T, jeżeli stan potwierdzają SDK ARM i lampka trybu. FMA nadal jest estymowane.

- Dodano odtwarzanie Flight Directora w PFD A320 i B38M, zapis standardowych komend FD/EX1 w radianach i opcję wyłączenia FD B38M. Brakujące dane historyczne pozostają niedostępne; rzeczywiste zero nie jest brakiem danych. Źródła i ograniczenia: `support/fbw/flight-director.md`.

- Rozwijanie wybranych SID/STAR/APP przez SimConnect Facilities: przejścia pasa/enroute/IAF, ograniczenia, odcinki RF/AF i missed approach. Snapshot navdata jest zapisywany wraz z oryginalnym planem w nagraniu i odtwarzany offline. Holdingi HA/HF/HM zachowują parametry i mają schematyczny symbol na mapie, missed approach jest ciemnoszare. FMA B38M/iFly jest rekonstruowane z zapisanych lampek MCP i SimVarów; podpis FMA RECONSTRUCTED wskazuje, że to przybliżenie, szczególnie VNAV, THR HLD i FLARE. Nie jest to bezpośredni odczyt FMA z dodatku.

- Dodano dekodowanie zapisanych trybów FMA FBW i katalog tekstów E/WD z formatowaniem, zegarem migania z nagrania i zachowaniem nieznanych kodów. Ustawienia Debug pozwalają wymusić rodzinę instrumentów. Mapa pokazuje ograniczenia PLN i uzupełnia bezimienne punkty z navlogu SimBrief po GPS. Pełne STS wymaga dodatkowego źródła danych; zakres opisuje `support/fbw/display-protocol.md`.

- Natywne framy A320 PFD i ECAM (E/WD + SD) dla Fenix/FBW, podmiana i odłączanie we wspólnych panelach; 13 ręcznych stron SD i Recorded oparte na faktycznym indeksie FBW. Dodane 47 pól FBW, dekodowanie ARINC429 z SSM i jawne braki zamiast zgadywanych stanów. Automatyczna strona Fenixa pozostaje niedostępna przy obecnych źródłach.

- Potwierdzony import jedno- i wielolotowych baz Qt przez dialog w DFM do osobnych plików `.mfzr`, bez modyfikowania źródła i duplikatów przy ponownym imporcie. Eksport legacy zachowuje wersję migracji offsetów czasu lokalnego.

- Eksport pojedynczego nagrania do SQLite legacy zgodnego ze schematem pierwowzoru Qt: wyłącznie standardowa telemetria, silniki, zdarzenia i kontakty, bez rozszerzeń MSFS24-FDR. Nowa akcja menu i dialog zapisu; atomowa podmiana pliku docelowego i niezmieniane źródło.

- Oddzielny kontener widoków i stały panel suwaków osi czasu w DFM; splitter instrumentów nie przestawia ani nie zmienia rozmiaru panelu suwaków po zmianie rozmiaru i odłączaniu widoków.

- Usunięte ScrollBoxy z paneli silników i EICAS; pełne skalowanie do dostępnego obszaru bez zmiany rozmiaru kontrolki przez próbki. Poprawiony splitter PFD/EICAS, zmiana rozmiaru na żywo i zapamiętywanie podziału.

- Wybór `ikB38MPFD` wyłącznie dla ICAO B38M: dedykowane framy PFD/EICAS zastępują widoki ogólne w panelach przyrządów i silników. Odłączenie, ikony, geometria oraz oś czasu pozostają wspólne także po zmianie samolotu; B736–B739 zachowują generic PFD. Wspólne taśmy IAS/ALT i nieliniowy wskazówkowy V/S także na generic PFD, kompaktowy HDG pod horyzontem. Naprawiony generator projektów testów nie pomija kompilacji.

- Automatyczny EICAS dla B38M w odłączanym panelu silników: niezależne N1/EGT/N2/FF, olej, wibracje, paliwo i klapy oraz komunikaty z dostępnych flag. Nowe SimVary TAT, ilości oleju, zbiorników paliwa i kątów klap; odtwarzanie i analiza starych plików zachowują braki jako niedostępne dane.

- Obsługa przebudowanych dolnych paneli przyrządów i silników z zapisem rozmiarów; wspólna zmiana ikon odłączania 0/1, przezroczyste zasoby framów, poprawna prezentacja ICAO zamiast kluczy ATCCOM, ciśnienie oleju w psi oraz spokojne oczekiwanie na MSFS przy E_FAIL podczas otwierania SimConnect.

- Osobne skale ILS LOC/GS z rombami na uproszczonym PFD, niezależne flagi ważności sygnałów i ukrywanie wskazań przy braku danych lub źródle GPS; kontrola bezpośredniego dziedziczenia framów osadzonych w DFM.

- Bezpośrednie dziedziczenie osadzonych framów przyrządów i silników po TFrame dla zgodności z projektantem Delphi; lokalizacja nie modyfikuje komponentów w trybie projektowania.

- Blokada pojedynczego uruchomienia rejestratora.



- Edycja autostartu exe.xml przez natywne interfejsy XML Delphi i OmniXML, bez automatyzacji OLE/MSXML.


### Wydanie portable

- ZIP bez hasła: rozpakowanie i ręczne uruchomienie MSFS2024-FDR.exe.
- Dołączony Setup tylko wyświetla komunikat o pracach i kończy działanie. Aktualizacje automatyczne/ręczne pozostają zablokowane także dla wcześniej włączonych ustawień.
- Natywny formatowany podgląd changelogu: po polsku dla polskiego interfejsu, w pozostałych językach po angielsku.

### Nagrywanie i przechowywanie

- Osobny plik SQLite `.mfzr` dla każdego lotu oraz indeks metadanych `flight_data.mfzi` w `%LocalAppData%\MSFS24-FDR`.
- Hierarchia plików według typu samolotu, lotniska startu, roku i miesiąca; nazwy zawierające czas rozpoczęcia lotu i lotniska.
- Przyrostowa migracja lotów ze starej bazy `flight_data.db`, z zachowaniem oryginału, grup, telemetrii, zdarzeń i danych FMC/MCDU.
- Wykrywanie podrzuconych plików `.mfzr` oraz import nagrań i baz legacy z menu i paska narzędzi.
- Wykrywanie przerwanych zapisów i przywracanie nagrań po awarii za zgodą użytkownika.
- Zapisywanie statusu nagrania i blokowanie otwierania lotów będących w trakcie zapisu lub finalizacji.

### Przeglądanie nagrań

- Drzewo nagrań: typ samolotu → lotnisko startu → rok → lokalizowana nazwa miesiąca → lot, od najnowszego nagrania.
- Łączenie filtrowania według grupy i wyszukiwania; zachowanie zaznaczenia, rozwinięcia gałęzi i pozycji przewijania.
- Ukrywanie brakujących plików bez usuwania ich metadanych.
- Podgląd pojedynczego `.mfzr` wskazanego w parametrze uruchomienia: tylko do odczytu, bez lewego panelu, nagrywania, zarządzania nagraniami i połączenia SimConnect.

### Dane użytkownika i integracje

- Przeniesienie ustawień, logów, cache i danych roboczych do `%LocalAppData%\MSFS24-FDR`, z migracją danych z katalogu aplikacji i przygotowaniem do instalacji w Program Files.
- Usunięcie zależności od WebView2: natywny podgląd OFP w `TMemo` i raportów Markdown w `TRichEdit`.
- Odtwarzanie ekranów FMC/MCDU z tłem urządzenia, formatowaniem i stanem kontrolek według wybranego czasu nagrania; automatyczny dobór rodziny urządzenia z danych samolotu.
- Integracja oficjalnego SDK PMDG 777, obejmująca parametry samolotu oraz trzy CDU z formatowaniem i kontrolkami.
- Osobne katalogi L-varów dla PMDG DC-6, CSS 737 Classic, Maddog X, SkySim DC-9/MD-11 i TFDi MD-11 oraz wybranych oficjalnych śmigłowców Asobo.
- Subskrypcje telemetrii dobierane do wykrytego samolotu, typu i liczby silników oraz aktywnej sesji lotu; po zakończeniu pozostają zmienne potrzebne do wykrycia kolejnego lotu.

### Przyrządy i interfejs

- Synchronizowane z osią czasu widoki klasycznych przyrządów lotu, silników i FMC/MCDU, z możliwością odłączania do osobnych okien.
- Centralne zapamiętywanie stanu odłączenia, pozycji i rozmiaru poszczególnych widoków.
- Zakładki i ramki przyrządów, silników oraz FMC/MCDU zdefiniowane w DFM.
- Poprawione przezroczyste ikony importu oraz tłumaczenie akcji importowania.

### Utrzymanie

- Poprawiona kolejność ustawień projektu Delphi i kopiowania katalogu tłumaczeń po kompilacji.
- Testy importu przyrostowego, wykrywania plików, podglądu tylko do odczytu i integracji widoków; szczegóły w [Testy.md](Testy.md).

## 0.1.0

Wydanie po initial Preview. Zakres na podstawie [commita wydania](https://github.com/dj-mafiozo/MSFS2024-FDR/commit/64073c2e213d2e697a9d6b78023ec530ed2ac2d7).

### Języki, fonty i układ interfejsu

- Automatyczne wykrywanie języka interfejsu Windows z angielskim jako językiem zastępczym.
- Rozszerzenie interfejsu do 32 lokalizacji, w tym wariantów regionalnych; zachowywanie wyboru regionu i sortowanie języków według kodów.
- Usunięcie widocznych znaczników skrótów z nazw języków.
- Informacje o automatycznym pochodzeniu tłumaczeń w czterech językach i odnośniki do zgłaszania błędów terminologii na GitHubie.
- Dołączone fonty Noto dla obsługiwanych alfabetów, ładowane prywatnie bez instalowania w Windows, wraz z licencjami OFL i sumami kontrolnymi.
- Dobór fontów do nazw języków i obsługa układów RTL dla arabskiego i hebrajskiego, przy zachowaniu LTR dla map, wykresów, osi czasu i treści technicznych.
- Poprawiony powrót z RTL do LTR, także po przełączeniu z hebrajskiego na automatyczny wybór języka oraz w istniejących oknach i podmenu.

### Diagnostyka, wersjonowanie i dystrybucja

- Integracja Delphi-StackTrace, ramek stosu oraz generowania dopasowanych symboli PDB dołączanych do paczek.
- Odczyt VersionInfo pliku EXE i prezentowanie wersji w oknie informacji o programie.
- Centralna konfiguracja wersji i niezależne zwiększanie numeru Build.
- Poprawki kolejności ustawień projektu, ścieżek zależności i poleceń po kompilacji dla Delphi 10.2.
- Usunięcie dodatku `mateusz-efb-ifly` i zawartości Community z paczek dystrybucyjnych.
- Rozszerzone kontrole lokalizacji, RTL, menu, dokumentacji i pakowania; wyniki testów opisane w czterech językach.

## Preview

Pierwsza publiczna wersja demonstracyjna. Zakres na podstawie [initial commita](https://github.com/dj-mafiozo/MSFS2024-FDR/commit/d94814179575b4918a5088e708664360e1270942), oznaczonego tagiem initial Preview.

### Rejestrator i dane

- Natywna aplikacja Windows x66 w Delphi 10.2 VCL, FireDAC i SQLite, wywodząca się z aplikacji Qt Michaela Hsu; zachowane uznanie autorstwa i licencja AGPL-3.0.
- Automatyczne i ręczne nagrywanie całej sesji lotu z konfigurowalnym interwałem, w osobnym wątku, z kolejką poleceń i diagnostyką.
- Rejestrowanie telemetrii samolotu, silników, sterowania, AP/A/T, poszczególnych elementów podwozia, pogody i zdarzeń kokpitu.
- SQLite w trybie WAL, osobne połączenia odczytu i zapisu, migracja starszych baz, naprawa schematu oraz kopie bezpieczeństwa.
- Zapis zmian danych dodatkowych i ekranów FMC/MCDU z timestampami, surowym tekstem oraz dostępnymi metadanymi prezentacji.

### Integracje i planowanie

- Czytniki iFly 737 MAX SDK, Fenix A32X, FlyByWire A32NX i PMDG 737 NG3; preferowanie potwierdzonych danych producenta nad ogólnymi odpowiednikami.
- Składanie obsługiwanych wyświetlaczy segmentowych i odczyt ekranów Fenix/FBW przez kompatybilny eksport FlightPadFMC.
- Parsowanie stron Boeing PERF INIT, N1 LIMIT, TAKEOFF REF i APPROACH REF oraz dostępnych stron Airbus INIT/PERF: prędkości referencyjne, klapy, masy, CG, trim, temperatury i limity ciągu.
- Obsługa wspólnych zmiennych AIRLINER, stanów usług GSX Pro oraz opcjonalnego odczytu panelu i wiadomości FSHud.
- Import PLN, zapis rewizji planu, eksport KML oraz opcjonalne pobieranie trasy domyślnego EFB przez lokalny mostek.
- Integracja SimBrief: dopasowanie planu do nagrania, opcjonalne starsze zgodne OFP, zapis briefingu i zwijany widok Dispatch z podglądem LIDO.
- Pobieranie METAR dla startu i lądowania z rozróżnieniem pogody lotniskowej i warunków lokalnych przy samolocie.

### Wizualizacja i analiza

- Synchronizowane mapa, wykresy, oś czasu i inspektor parametrów.
- Wybór i kolejność wykresów bez dawnego limitu ośmiu, przesuwanie myszą, powiększanie zaznaczenia i nawigacja po czasie.
- Odłączane widoki mapy i wykresów z zachowaniem synchronizacji, rozmiarów paneli i układu okien.
- Czytelne lokalizowane nazwy parametrów, wyszukiwanie po nazwie lub identyfikatorze i opcjonalna konwersja jednostek bez zmiany danych źródłowych.
- Grupy nagrań, filtrowanie, modalne przypisywanie do grupy, informacje o locie oraz otwieranie nagrania dwuklikiem.
- Opcjonalne analizy startu i lądowania przez Codex CLI, Gemini lub Ollama, z wykrywaniem modeli Ollama i zapisem raportów.
- Niezależne okna czasowe analiz, dane pogodowe i referencje FMC, zaokrąglanie wartości kontekstu oraz histereza delt.
- Raporty po polsku, renderowanie Markdown przez używany w tym wydaniu WebView2.

### Dokumentacja i paczka

- Interfejs po polsku, angielsku, niemiecku i hiszpańsku z edytowalnym katalogiem `.i18n`.
- Dokumentacja i kontekstowa pomoc F1 w czterech językach, CHM oraz lokalny HTML.
- Paczka aplikacji bez środowiska Qt, z wymaganymi bibliotekami, licencjami, kontrolą zawartości i sumami kontrolnymi.
- Testy syntetyczne i sprawdzenie kompilacji Win64; ograniczenia integracji i prób w symulatorze opisane oddzielnie w dokumentacji testów.
