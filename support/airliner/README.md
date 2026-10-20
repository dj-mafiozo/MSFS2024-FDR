# Wspólne zmienne AIRLINER przez SimConnect

[Tłumaczenia interfejsu](../../Translation.pl.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


`*AIRLINER*` w tym katalogu to **L-vary instrumentów**, odczytywane przez
`SimConnect_AddToDataDefinition` jako `L:<nazwa>`, a nie standardowe SimVary A:.
Katalog obejmuje obecnie **31 nazw**, znalezionych w 149 plikach instrumentów
z instalacji MSFS24 i Community. Uwzględnia nazwy z prefiksem AIRLINER oraz
z AIRLINER w środku, np. A32NX_AIRLINER. Pięć pierwotnych pól to:

| Nazwa | Interpretacja |
| --- | --- |
| AIRLINER_V1_SPEED | V1, węzły |
| AIRLINER_VR_SPEED | VR, węzły |
| AIRLINER_V2_SPEED | V2, węzły |
| AIRLINER_MINIMUM_DESCENT_ALTITUDE | MDA, stopy |
| AIRLINER_DECISION_HEIGHT | DH, stopy |

Nazwy i jednostki zweryfikowano w oficjalnym
[kodzie FMC FlyByWire](https://github.com/flybywiresim/aircraft/blob/master/fbw-a32nx/src/systems/instruments/src/MCDU/legacy/A32NX_FMCMainDisplay.ts).
Pełne nazwy, warianty jednostek, pliki źródłowe i ich SHA-256 znajdują się
w [catalog.json](catalog.json). Dodano m.in. VREF, VX, managed approach speed,
green-dot speeds, fazę lotu, wysokości przelotową/redukcji ciągu/akceleracji/
przejściową, FLEX, klapy startowe, tryby ciągu oraz pozycje i flagi TOC/TOD.
Nazwy pochodzą m.in. z instrumentów Asobo A320, 737 MAX, 747, 787, CJ4,
a także zainstalowanych dodatków FBW, FSS i LVFR. Nie potwierdzono osobno
wartości Carenado na żywo ani kompletności jego zamkniętych instrumentów.

Import nie kopiuje kodu producentów. Narzędzie
`tools/import_airliner_catalog.py` przyjmuje listę plików otrzymaną przez
`rg -l -i airliner <pakiety> -g '*.js' -g '*.xml' -g '*.html'`.
Wyciąga literalne nazwy L-varów z wywołań Get/SetSimVarValue i wyrażeń XML,
pomija nazwy konstruowane dynamicznie i dane typu string, a następnie
generuje `telemetry/AirlinerCatalogU.pas` i manifest. Nie jest to enumeracja aktywnych
L-varów podczas lotu ani gwarancja wykrycia wszystkich możliwych dodatków.
Po aktualizacji pakietów katalog można odtworzyć i ponownie skompilować FDR.
`check_airliner_catalog.py` porównuje katalog PAS z manifestem i jest częścią
`test.ps1`. Instrumenty samolotów nadal mogą dostarczać inne, nieujęte nazwy.

## Odczyt i ważność

`TSimConnectClient` utrzymuje dodatkowe połączenie SimConnect tylko do odczytu,
niezależne od głównej definicji telemetrii i dostawców SDK samolotów.
Każda zmienna ma własną definicję/żądanie: błąd jednej nie blokuje pozostałych.
Brak odpowiedzi, NaN, błąd lub przeterminowanie daje null. Zmiana tytułu
samolotu, pauza i zatrzymanie symulacji resetują opcjonalny czytnik.
Podstawowa rejestracja nie jest uzależniona od dostępności tych danych.

MSFS może zwrócić zero dla nieistniejącej L-var i nie gwarantuje, że dodatki
na bieżąco aktualizują wspólne zmienne. Dlatego status to
`received_not_verified`, a nie potwierdzenie obsługi danego samolotu.
Surowe zera i wartości sentinel pozostają zapisane, ale zero/ujemna wartość
nie staje się referencją V-speed. Dodatnie prędkości poniżej 400 kt są
udostępniane jako kandydaci referencji, ze źródłem i zastrzeżeniem ważności.
Nie nadpisują standardowych pól lotu ani referencji SDK/FMS konkretnego samolotu.

## Zapis, wykresy i analiza

`TFlightSample.AirlinerData` trafia do `trip_aircraft_data` pod kluczem
`airliner_lvars`. Historia używa istniejących delt i powiązania z próbką
(timestamp w `trip_data`). Powtórzony stan nie tworzy duplikatu, a utrata
odczytu jest jawnie zapisana. Wykresy mają prefiks `AirlinerLVar.` i luki
przy null. Analiza zawiera te dane w odtworzonej telemetrii oraz
`airliner_lvar_definitions` z jednostkami i opisem ograniczeń.
Nie zmieniano struktury podstawowego pakietu ani schematu tabel danych.

Test `VerifyAirliner` używa DLL-atrapy: 31 definicji i 31 żądań tylko do
odczytu, izolacja błędów, brak odpowiedzi, zera, zmiany w SQLite, wykresy,
kontekst AI i usuwanie lotu. To nie jest potwierdzenie wartości na żywym
samolocie w MSFS. Istniejące testy Fenix/FBW weryfikują nadal domyślne paczki
128-elementowe współdzielonego czytnika L-varów.
