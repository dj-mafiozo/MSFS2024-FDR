# GSX Pro — rejestrowane dane SDK

[Tłumaczenia interfejsu](../../Translation.pl.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


Niezależny od samolotu czytnik `telemetry/GSXVarsU.pas` odczytuje 16 numerycznych L-varów przez SimConnect MSFS24. Każde pole ma osobną definicję i żądanie, dzięki czemu błąd pojedynczej zmiennej nie blokuje pozostałych. Nie jest potrzebny osobny moduł WASM. Czytnik nie wysyła komend i niczego nie zapisuje do GSX.

| Parametry | Znaczenie |
|---|---|
| `FSDT_GSX_BOARDING_STATE`, `FSDT_GSX_DEBOARDING_STATE` | Stan boardingu i deboardingu |
| `FSDT_GSX_CATERING_STATE`, `FSDT_GSX_REFUELING_STATE` | Stan cateringu i tankowania |
| `FSDT_GSX_DEPARTURE_STATE`, `FSDT_GSX_DEICE_STATE` | Stan usługi odlotowej i odladzania |
| `FSDT_VAR_Frozen` | Flaga zamrożenia samolotu przez GSX podczas pushbacku; nie pauza symulatora |
| `FSDT_GSX_NUMPASSENGERS_BOARDING`, `FSDT_GSX_NUMPASSENGERS_DEBOARDING` | Bieżące liczniki pasażerów, mogą być zerowane dla kolejnego autobusu |
| `FSDT_GSX_NUMPASSENGERS_BOARDING_TOTAL`, `FSDT_GSX_NUMPASSENGERS_DEBOARDING_TOTAL` | Liczniki łączne dla procesu |
| `FSDT_GSX_BOARDING_CARGO`, `FSDT_GSX_DEBOARDING_CARGO` | Trwa ładowanie lub rozładowywanie bagażu/cargo |
| `FSDT_GSX_BOARDING_CARGO_PERCENT`, `FSDT_GSX_DEBOARDING_CARGO_PERCENT` | Postęp procesu 0–100, uśredniony między loaderami |
| `FSDT_GSX_DEICING_TYPE` | Surowy kod typu płynu odladzającego |

Stan usługi: 1 — dostępna do wywołania, 2 — niedostępna, 3 — pominięta, 4 — zamówiona, 5 — wykonywana, 6 — zakończona. Zero nie jest potwierdzeniem obecności GSX ani poprawnie rozpoznanym stanem usługi. SimConnect może zwrócić zero również dla nieistniejącego L-vara. Dlatego status transportu to `received_not_verified`, `partial` albo `unavailable`; niedostępne lub nieprawidłowe liczby są zapisywane jako null. Dane starsze niż 3 sekundy nie są używane jako aktualne.

Pełny stan początkowy i dalsze zmiany trafiają do `trip_aircraft_data` pod kluczem `gsx_lvars`, z powiązaniem do próbki telemetrii i jej czasu. Nie ma osobnego duplikowanego zapisu identycznych wartości. Odtwarzanie dodaje parametry `GSX.*` do wykresów i inspektora; luki danych pozostają lukami. Kontekst analizy zawiera definicje stanów i zrekonstruowane dane GSX.

Nagrywanie obejmuje załadowaną sesję do końca, łącznie z boardingiem przed uruchomieniem silników i deboardingiem po ich wyłączeniu. Pauza nie kończy lotu. Liczniki GSX nie zastępują zmierzonej masy, ładunku ani paliwa samolotu.

Zakres jest pierwszym zestawem usług, nie pełnym katalogiem wszystkich L-varów GSX, poleceń sterowania ani nowszych stanów poszczególnych pojazdów. Źródło: sekcja „DEVELOPERS — Interfacing with GSX” w [oficjalnym podręczniku GSX Pro](https://www.virtualisoftware.com/update/setup/fsdtroot/couatl/GSX/GSX_manual_MSFS.pdf). Podręcznik producenta nie jest dołączany do paczek.

Testy korzystają z atrapy SimConnect. Nie wykonano weryfikacji odczytu podczas rzeczywistego działania GSX Pro.

Weryfikacja katalogu: oficjalny PDF (291 stron), strony 106–108. Wszystkie 16 nazw znaleziono w tekście podręcznika. SHA-256 PDF: `ee4ae760168e7045d3598905d3e1b4a3ccb56337fdb50586e7456c3dc4feafc1`. Bieżąca dokumentacja podaje `FSDT_GSX_DEICE_STATE` (nie starszą nazwę `DEICING_STATE`).
