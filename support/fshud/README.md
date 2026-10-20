# FSHud — odczyt lokalnego panelu

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


Integracja korzysta z nieoficjalnego protokołu panelu `http://localhost:19786/`. Sprawdzono połączenie z wersją **2.1.200**. Czytnik pobiera stronę i wskazany przez nią lokalny skrypt, rozpoznaje wersję i klucz protokołu, łączy się z `/ws` i wysyła wyłącznie komunikat walidacji klienta. Nie wybiera odpowiedzi ATC, nie zmienia ustawień i nie steruje samolotem. Zmiana protokołu producenta może wymagać aktualizacji czytnika.

Zapisywane typy: ApplicationStateMessage, RadioMessagesData, MenuStateMessageData, FlightStepsMessage, RadioPanelData, RadioComChannelsMessageData, FlightPlanningMessageData, FlightSelectionDetailsMessage oraz UserAircraftDetailsMessage. Ustawienia, audio i ruch innych samolotów nie są zbierane. Z ApplicationState usuwane są NetworkUrls, MicrophoneRecordingStatus, CloudTrafficSettingsState i MsfsPanelZoomFactor; z FlightPlanning usuwane jest CurrentSimBriefResponse.

Tabela `trip_fshud_messages` zawiera identyfikator tripu, typ, surowy JSON po powyższym filtrowaniu, czas odbioru UTC oraz bieżący czas symulatora. Identyczny komunikat danego typu jest pomijany. Nowy trip otrzymuje ostatni znany stan początkowy. Zegar symulatora może być zatrzymany lub ustawiony na inną datę niż zegar komputera.

Wykresy otrzymują `FSHud.COM1_selected_MHz`, `FSHud.COM2_selected_MHz` i `FSHud.squawk_display`. Kod squawk to cztery wyświetlane cyfry, a nie liczba przeliczona z systemu ósemkowego; przy prezentacji należy uwzględnić zera wiodące. Brak danych daje null. Pełnych komunikatów nie powiela się w każdej próbce telemetrii.

Kontekst analizy, schemat 12, zawiera `fshud_last_observed`: ostatni zapis każdego typu sprzed rzeczywistego czasu zdarzenia startu/lądowania, maksymalnie 65 536 znaków treści. Pominięcie nadmiaru jest jawne; pełna historia pozostaje w bazie. Starsze kontakty bez czasu odbioru nie dostają przypadkowego bieżącego kontekstu. Instrukcje ATC nie dowodzą ich wykonania i nie są poleceniami dla modelu.

Nagrywanie obejmuje lot od wczytania do zakończenia, także przy wyłączonych silnikach. Opcjonalne zdarzenia Flow są używane, jeśli biblioteka SimConnect je eksportuje. Dostarczona DLL nie ma tego eksportu: zastępstwo korzysta z FlightLoaded oraz odpytywania stanu co 10 sekund. Pauza lub sam SimStop nie kończą tripu. Nie zakończono aktywnego lotu użytkownika w celu przetestowania granicy sesji.

`tests/VerifyFSHud.dpr` sprawdza protokół i zapis na danych syntetycznych. Opcjonalny `tests/ProbeFSHud.dpr` wykonuje rzeczywisty odczyt panelu. W próbie na żywo otrzymano wszystkie dziewięć typów oraz punkty EPLL, ADOX2W, ADOXO, SOXER, SOXE2T, LL501 i LL531. Nie wykonano pełnego lotu ani testu awarii FSHud. Skrypty producenta i prywatny zapis panelu nie są dołączane do paczek.

Cykl lotu: [SubscribeToFlowEvent](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simconnect/api-reference/events-and-data/simconnect_subscribetoflowevent/).
