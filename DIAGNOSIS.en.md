# Recording and crash diagnosis - 2026-10-15

Database inspected read-only: `F:\Tools\Mfz\MSFS24_FDR_Delphi-mfz\flight_data.db`.
Integrity check: OK. 23 trips, 2044 snapshots, 4088 engine rows.
Trip 1 contains 2021 snapshots (2026-10-14 21:21:09 to 21:29:45 UTC).
Most subsequent trips contain one snapshot; repeated starts approximately every
three seconds match the reconnect timer. The project bin database is empty.
The original database was not modified.

## Changes

Previously every asynchronous SIMCONNECT_RECV_EXCEPTION became a fatal error.
The GUI stopped the trip, disconnected, then reconnected. An optional cockpit
or airport request error could therefore interrupt otherwise valid telemetry.
Auxiliary errors are now logged without ending the flight. Telemetry definition
and request errors remain fatal. SimConnect_GetLastSentPacketID associates
errors with individual definitions/events; exception code, send ID and parameter
index are logged. Old logs contain no SDK exception codes, so the exact request
responsible for the historical short sessions cannot be proven.

The RequestFacilityData_EX1 binding lacked its sixth argument, char Type.
The local official MSFS 2024 SDK header declares six arguments; the binding now
passes zero explicitly instead of letting the DLL read an arbitrary stack byte.

Incoming telemetry is validated against request ID, definition ID, field count,
flags and packet size. Unrelated packets cannot overwrite the current sample.

Logging now records executable path, flight start/stop, snapshot counts,
simulator/engine states and callback/GUI exceptions. Startup/shutdown errors are
shown and logged. A secondary stop error cannot prevent disconnection. Failure
to write the log does not raise another exception.

A Windows unhandled exception filter attempts to write msfs_fdr_debug.dmp next
to the executable. Forced process termination and fail-fast errors may bypass
the filter. Dumps can contain process data. No global Windows settings changed.

## Windows Error Reporting evidence

- Qt, Oct 11 17:24:23: Qt6Graphs.dll, 0xc0000094 (integer divide by zero).
- Qt, Oct 15 00:50:30: ASUS GPU Tweak III GTIII-OSD64.dll 3.0.7.9,
  0xc0000005, offset 0xb84e3.
- Delphi, Oct 14 23:31/23:32 and Oct 15 00:12: 0xc0000005,
  unknown module / StackHash_c4dc. All three protected WER reports list ASUS
  OSD injection modules. This makes an overlay conflict a suspect, but does not
  establish the cause of the Delphi crashes. No useful crash stack was available.

For live verification, exclude both recorders from ASUS GPU Tweak III OSD,
then run the updated executable with the existing database. Keep .log,
.log.old and .dmp if it crashes again. Do not delete flight_data.db.
ASUS settings have not been changed automatically.

## Verification

Delphi 10.2 Win64 build and four test suites passed: VerifyPort (including
121 continuous snapshots with repeated optional SDK errors), VerifyLegacy,
VerifyUI, VerifyDiagnostics (persistent log and Windows minidump header).
Tests use separate databases. A live flight with the updated EXE is still needed.


## Próbki lotu i parser iFly FMC — 18 października 2026

Sprawdzono bazę z `F:\Tools\Mfz\MSFS24_FDR_Delphi-mfz` oraz log rejestratora. Źródło otwarto przez SQLite w trybie tylko do odczytu i wykonano spójną kopię diagnostyczną w `.build`. Nie zmieniano oryginalnych danych, konfiguracji ani plików wykonywalnych w tym katalogu. Prywatna kopia i surowe logi diagnostyczne nie są dołączane do paczek.

Trip 4 zawiera 5256 próbek: 5251 z flagą ziemi i tylko 5 z flagą powietrza. Pierwsze 5250 próbek obejmuje czas symulatora 11:28:04–11:33:58; log pokazuje przetwarzanie od 23:51 do około 00:46 czasu komputera. Kolejne próbki mają czasy 11:39:28, 11:44:35, 11:49:51, 11:53:28, 11:55:58 i 12:02:00. Największa luka wynosi 362,512 s. Kontakty startu i lądowania zapisano osobno o 11:36:53 i 11:58:53. To nie jest poprawny przebieg zapisu co 250 ms; układ wskazuje na zaległą kolejkę ramek. Interwał był liczony według czasu przetwarzania, więc kosztowny callback mógł utrwalać po kolei stare ramki zamiast bieżącego stanu. Zewnętrzny EXE miał datę 17.10.2026 21:57 i nie zawierał późniejszego przeniesienia rejestratora do wątku.

Odbiór używa teraz GetNextDispatch, gdy DLL udostępnia tę funkcję, z ograniczeniem czasu/liczby pakietów na przebieg. Kosztowne przetwarzanie SDK i zapis następują po odbiorze, dla najnowszej ramki. Zachowane są ramki początkowa oraz przejścia ziemia–powietrze, żeby nie zgubić startu, przyziemienia i odbicia. Zastępczy CallDispatch również odracza przetwarzanie próbek. Log co 30 sekund podaje received/delivered/coalesced. Nie odtwarza się sztucznych brakujących próbek. Przy bardzo wolnym odbiorniku rzeczywisty interwał może nadal przekroczyć zadany, ale nie powinien narastać koszt odtwarzania każdej starej ramki.

Usunięto także niezależny błędny warunek odrzucający całą próbkę przy surface_type=255. Nieznana nawierzchnia nie unieważnia pozostałej telemetrii. Nie da się udowodnić, ile ramek zewnętrznego lotu odrzucił właśnie ten filtr, ponieważ odrzuconych ramek nie ma w bazie.

Parser TAKEOFF REF odczytuje wybraną prawą kolumnę V1/VR/V2, pomijając propozycje QRH po lewej. APPROACH REF odczytuje wybraną parę FLAP/SPD, nie zgaduje VREF z tabeli kilku konfiguracji. Zwraca dodatkowo approach_flaps_deg; wind_correction_kt pozostaje osobnym polem. Puste/wyczyszczone wartości dają null. Przy analizie wszystkie zapisane surowe ekrany są ponownie parsowane aktualnym kodem, również iFly i PMDG, bez destrukcyjnej migracji parsed_json. Wcześniej wygenerowany raport AI wymaga ponownego wygenerowania.

Rozszerzono VerifyFMC: różne propozycje QRH i wybrane 124/125/137, brak wybranego V1 przy istniejącym QRH, wybrane 40/137 oraz 30/142, wyczyszczenie --/--- bez podstawienia wartości z tabeli, oddzielne wind correction +5. W bazie testowej podmieniono stare parsed_json na null; kontekst odzyskuje wartości z surowych ekranów. Rozszerzono VerifySession: sześć kolejnych próbek powietrznych z surface_type=255 i interwałem 250 ms oraz oba kontakty przy nieznanej nawierzchni.

Nowy VerifySimBacklog przekazuje 1000 syntetycznych ramek, z trzema zmianami kontaktu i celowo wolnym odbiornikiem. Odbiornik dostaje pięć callbacków: stan początkowy, trzy przejścia i najnowszą próbkę z czasem 999. Osobny Feed pozostaje synchroniczny. Test nie odtwarza prawdziwego transportu DLL ani pełnego lotu.

Oddzielnie skompilowano ProbeSavedFMC i odczytano kopię rzeczywistej bazy w trybie ReadOnly. Przeparsowano 219 ekranów; uzyskano 12 ekranów z wybranymi prędkościami startowymi i 7 z wybraną konfiguracją podejścia. Ekrany 139/140 dały 124/125/137; ekran 208 dał vref_kt=137, approach_flaps_deg=40 i wind_correction_kt=5. Późniejsze ekrany 212/213 zawierają już wybrane 40/136 i są tak odczytywane. Nie podstawiano prędkości na podstawie oczekiwań użytkownika. Ten program diagnostyczny nie jest dodatkowym zestawem automatycznym.

Po zmianach nie wykonano pełnego nowego lotu na żywo. Utraconej telemetrii nie można odzyskać z kilku zachowanych próbek; naprawa parsera może wykorzystać zachowany surowy FMC.

