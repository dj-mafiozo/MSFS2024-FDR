# Ekrany MCDU z FlightPadFMC

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


FDR automatycznie odczytuje pełny tekst ekranu z uruchomionego klienta Windows
FlightPadFMC dla Fenixa A32X lub FlyByWire A32NX. Obsługiwane są programy
`FenixA320MCDU`, `FenixA320Screen`, `FBWA320MCDU` i `FBWA320Screen`.
Trzeba uruchomić **zaktualizowany EXE** i połączyć go z serwerem FlightPadFMC.
Sam stary proces bez eksportera nie dostarcza ekranu.

## Eksporter

W `Windows/Common/ScreenModel.pas` funkcja `TScreenModel.ExportText` składa
aktualnie renderowane komórki w `TStringList` i zwraca `Lines.Text`:
14 wierszy po 24 znaki UTF-16, każdy zakończony CRLF, łącznie 364 jednostki
UTF-16. Zachowane są wyrównanie, spacje, puste wiersze, symbole i scratchpad.
`HasScreen` odróżnia odebrany ekran od początkowego pustego modelu; reset
unieważnia ekran. Kolory i fonty nie są częścią eksportowanego stringa.

`FMCMain` publikuje tekst na swoim istniejącym timerze tylko jako dostępny,
gdy transport jest połączony, model odebrał ekran i nie ma nakładki statusu.
Nie naciska klawiszy, nie przełącza stron i nie uruchamia dodatkowego serwera.
Eksport działa także w wariancie Screen i przy zminimalizowanym oknie,
dopóki działa pętla komunikatów aplikacji.

## Protokół lokalny

Wspólny plik `fmc/FlightPadScreenIPCU.pas` jest identyczny w FDR i FlightPadFMC.
Pakiet v1 ma stałe **776 bajtów**, `packed record`, bez wskaźników i typów
zależnych od bitowości. Dzięki temu klient Win32 współpracuje z FDR Win64.

- Mapping: `Local\FlightPadFMC.Screen.v1.<profil>.<PID>`.
- Mutex: ta sama nazwa z końcówką `.Lock`.
- Profile: `FenixA320` i `FBWA320`.
- Pakiet zawiera wersję, rozmiar, PID, heartbeat, czas zmiany ekranu
  (`GetTickCount64` i UTC FILETIME), dostępność, długość oraz tekst.
- Dostęp chroni mutex z nieblokującym oczekiwaniem. Nieudana próba nie blokuje UI.
- Czytnik sprawdza procesy w bieżącej sesji i otwiera wyłącznie mappingi
  odczytu. Nie tworzy ani nie uruchamia FlightPadFMC.
- Brak procesu/mapowania, niedostępny ekran, nieznany format, błędne CRLF,
  długość lub heartbeat starszy niż 5 s oznacza brak dostępnego ekranu.
- Przy kilku instancjach tego samego profilu wybierany jest dostępny ekran
  z najnowszym czasem zmiany. Drugie urządzenie MCDU nie jest dopisywane
  sztucznie: obecny model Airbus FlightPadFMC pokazuje jeden ekran `left`.

Obie aplikacje powinny działać w tej samej sesji Windows i z kompatybilnymi
uprawnieniami dostępu do obiektów nazwanych. Nie są potrzebne porty sieciowe
ani ścieżki instalacji zapisane w ustawieniach FDR.

## Rejestracja

Po rozpoznaniu samolotu `AircraftTelemetry` dołącza `cdu/0` do danych
`FenixA32X` lub `FBWA32NX`, niezależnie od dostępności ich liczbowych L-varów.
Źródło ma nazwę `FlightPadFMC/<profil>`. Stan elektrycznego zasilania pozostaje
nieznany: samo połączenie klienta nie dowodzi zasilania MCDU.

Tekst przechodzi przez istniejący zapis `trip_fmc_screens`: tylko zmiany,
timestamp symulatora i czas obserwacji FDR, historia stron, bufor przed startem
silników oraz ostatnie wartości dostępne w chwili zdarzenia dla analizy.
Oryginalny czas zmiany w eksporterze jest dodatkowo dostępny w danych
samolotu jako `observed_filetime_utc`; heartbeat nie zmienia tego pola.
Zamknięcie, rozłączenie lub zatrzymanie heartbeat unieważnia bieżący ekran.
Ostatnie wcześniej oglądane strony nadal są historią, nie świeżym odczytem
ukrytych stron FMC. Odczyt FDR odbywa się przy skonfigurowanym interwale,
więc bardzo krótkie przejścia między stronami mogą zostać pominięte.

## Testy i odtwarzanie zmian

`VerifyFlightPad` uruchamia `MockFlightPad32.exe` i sprawdza rzeczywiste IPC
między procesami Win32/Win64, oba profile, wykrywanie procesu, Unicode,
niezmienny czas przy heartbeat, zły format/wersję, zatrzymanie eksportera,
integrację dostawców, zapis zmian i kontekst analizy. To test sztucznego
wydawcy ekranu, nie lot z rzeczywistym Fenix/FBW.

`Windows/tests/ExportTests.dpr` w FlightPadFMC testuje produkcyjny model
ekranu obu Airbusów, wyrównanie, scratchpad i reset dostępności. Cztery
klienty Windows zostały skompilowane po zmianach.

`FlightPadFMC-export.patch` zawiera zmiany względem odczytanej wersji projektu
FlightPadFMC, w tym wspólny eksporter, wpisy DPR/DPROJ i test modelu.
Z katalogu głównego FlightPadFMC można sprawdzić zgodność przez
`git apply --check <ścieżka-do-patcha>`, a na niezmodyfikowanej bazie zastosować
`git apply <ścieżka-do-patcha>`. Nie należy stosować ponownie do już
zaktualizowanych plików. Licencja źródeł FlightPadFMC znajduje się obok.
