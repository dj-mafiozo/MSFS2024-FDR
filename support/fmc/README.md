# Historia ekranów FMC/MCDU

[Tłumaczenia interfejsu](../../Translation.pl.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


TFMCScreen posiada TStringList Lines: 14 wierszy po 24 znaki, ze spacjami i CRLF. FireDAC wyłącza StrsTrim. iFly dostarcza tekst/glify, kolory/czcionki, HTML i lampki; PMDG dostarcza Client Data CDU; Fenix/FBW pełny ekran przez zaktualizowany FlightPadFMC. Jasność nie jest dowodem zasilania, a numeryczne L-vary nie zastępują tekstu.

trip_fmc_screens zapisuje każdą zmianę tekstu, dostępności, zasilania lub metadanych z trip/sample, czasem symulatora i odbioru UTC, provider/device, kluczem strony, raw_text i parsed_json. Identyczne odczyty są pomijane. Power: -1 nieznane, 0 off, 1 on. Numer strony i MOD/TMPY są częścią historii; nie nadpisują zatwierdzonych referencji.

Bufor preflight zachowuje 4096 zmian oraz osobno ostatni stan każdej strony, przenoszony transakcyjnie do nowego tripu z oryginalnymi czasami. sample=0 oznacza obserwację bez istniejącej próbki telemetrii. Nagrywanie obejmuje obecnie już załadowany lot także przed pracą silników. Cache jest czyszczony przy zmianie samolotu, stop i rozłączeniu. Zamknięcie bez lotu traci bufor pamięciowy.

Analiza wybiera ostatni ekran/stronę/wartość sprzed zdarzenia, oddzielnie dla urządzeń, z całej historii — także spoza okna analizy. Ukryta strona oznacza ostatnią obserwację, nie ciągły odczyt pamięci FMC. Późniejsze strony nie przenikają do wcześniejszego kontaktu. MOD/TMPY nie staje się wartością aktywną. Widoczna pusta/niejednoznaczna wartość daje null, nie liczbę z innej kolumny.

Boeing: PERF INIT, N1 LIMIT, TAKEOFF REF i APPROACH REF, wybrane V-speeds/FLAP-SPD, osobna poprawka wiatru. iFly i PMDG dzielą parser do przyszłej weryfikacji. Airbus: INIT/PERF, VAPP/VLS, FLEX, klapy/THS, wysokości i minima; jednostki mas bez potwierdzenia pozostają tekstem. Zobacz Boeing-performance.md, Airbus-MCDU.md i IFly-display-storage.md.

Program nie naciska klawiszy ani nie przełącza stron. Pokaż odpowiednie strony podczas przygotowania lotu; ekrany krótsze od interwału mogą zostać pominięte. Stare raw ekrany są ponownie parsowane do kontekstu, bez nadpisywania historii. VerifyFMC/VerifyBoeingFMC/VerifyAirbusMCDU/VerifyIFlyDisplays są syntetyczne. Nie potwierdzają całego przepływu podczas rzeczywistego lotu. Szczegółowy protokół i ograniczenia w README.en.md.
