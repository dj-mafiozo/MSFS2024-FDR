# Plany lotu z EFB MSFS2024

Podstawowym źródłem jest GET_EFB_ROUTE, odczytywane przez dodatek mateusz-efb-ifly. Gdy jego aplikacja EFB jest otwarta, co 5 s wysyła pełny JSON trasy do odbiornika loopback 127.0.0.1:19787/efb-route. Sam iframe iFly nadal używa localhost:8084. Nie zmieniamy planera ani FMC.

1. Zaktualizuj EXE/DLL, zachowując własne flight_data.db i settings.ini.
2. Skopiuj Community/mateusz-efb-ifly z paczki do Community i uruchom ponownie MSFS.
3. Przygotuj trasę w domyślnym planerze, otwórz aplikację EFB iFly i sprawdź status wysłania do FDR.
4. Rejestrator zachowuje najnowszą trasę dla bieżącego/kolejnego nagrania. Zmiana zapisuje rewizję trip_flight_plans, identyczne ponowienia są pomijane. Zakładka Plan lotu pokazuje ostatnią wersję i surowy JSON/XML.

Zamknięcie/pauza aplikacji EFB zatrzymuje przesyłanie; otwórz ją ponownie po edycji planu. Odbiornik jest wyłącznie lokalny, ogranicza rozmiar i waliduje format. Dokładne parametry i historyczny zakres prób: [FLIGHT-PLANS.en.md](FLIGHT-PLANS.en.md).

PLN jest opcją ręcznego eksportu/importu, nie plikiem automatycznie zapisywanym przez planer. Przykładowe pętle EPMO/EPLL nie są domyślną trasą użytkownika. Poprawny SID EPMO to SOXE4C, nie wcześniejsza literówka SOXE4J. Koordynaty DMS i natywny JSON EFB są parsowane; brakujące punkty procedur nie są wymyślane. Mapa pokazuje tylko jawne współrzędne. Trasa pętli porównuje także kolejność punktów; sama zgodność lotnisk startu/mety nie wystarcza.

SimBrief jest niezależnym źródłem. Pobranie najnowszego planu nie przypisuje go automatycznie do dowolnego tripu. Opcja starszego planu wymaga zgodnej zapisanej trasy i dostępnych parametrów, z jawną informacją o wcześniejszym wygenerowaniu. Zachowywane są payload i OFP. Podgląd Dispatch/LIDO ma własną zakładkę oraz osobne skalowalne okno.
