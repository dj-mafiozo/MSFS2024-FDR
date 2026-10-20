# Diagnoza nagrywania i awarii

Angielski szczegółowy zapis historyczny: [DIAGNOSIS.en.md](DIAGNOSIS.en.md).

Odczytano bez modyfikacji F:\Tools\Mfz\MSFS24_FDR_Delphi-mfz\flight_data.db. Integrity check: OK; 23 loty, 2044 próbki, 4088 wierszy silników. Lot 1 miał 2021 próbek z 14 października 2026, 21:21:09–21:29:45 UTC. Większość kolejnych miała jedną próbkę, a odstępy około 3 s odpowiadały ponownemu łączeniu.

Wcześniej każdy asynchroniczny SIMCONNECT_RECV_EXCEPTION kończył sesję. Obecnie błędy opcjonalnych zdarzeń/facilities są izolowane, a błędy definicji i żądania telemetrii pozostają krytyczne. GetLastSentPacketID wiąże wyjątek z żądaniem; log podaje kod, send ID i indeks. Stare logi nie pozwalają udowodnić dokładnego historycznego sprawcy.

Poprawiono sygnaturę RequestFacilityData_EX1 (szósty argument char Type), walidację identyfikatorów/rozmiarów danych i obsługę starych schematów SQLite. Migracja zachowuje silniki i wersjonuje korektę strefy czasu; przed zmianą powstaje spójny backup SQLite. Nie wolno uznawać brakujących pól za zero. Dokładny historyczny zakres testów migracji, logów i minidumpów jest w Testy.md oraz wersji angielskiej tego dokumentu.

Nagrywanie działa obecnie w osobnym wątku z prywatnym połączeniem FireDAC, WAL i kolejką poleceń. SimConnect opróżnia backlog przed kosztownym przetwarzaniem, scala zaległe próbki i zachowuje przejścia ziemia–powietrze. surface_type=255 w powietrzu nie kończy tripu. Nagrywanie obejmuje całą załadowaną sesję, nie tylko pracę silników. Interwał 250 ms jest celem, a nie dowodem błędnej konfiguracji; rzeczywista częstotliwość zależy od odczytu i zapisu.

msfs_fdr_debug.log zapisuje stan, wyjątki i diagnostykę kolejki; plik .old jest poprzednim logiem. Minidump wspiera analizę awarii natywnych. Próbki testowe i atrapy DLL potwierdzają kontrakty/obsługę awarii, ale nie zastępują długiego lotu na żywo. Powtarzalne awarie MSFS/sterowników/SDK wymagają osobnej korelacji z logami symulatora. Historyczne liczby dotyczą badanej kopii, nie bieżącej bazy użytkownika.
