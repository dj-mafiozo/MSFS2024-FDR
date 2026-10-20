# Dane referencyjne FMC Boeinga

[English](Boeing-performance.en.md)

Na obecnym etapie iFly 737 MAX i PMDG 737 NG (`PMDGNG3`) korzystają z tego samego parsera układu stron PERF INIT, N1 LIMIT, TAKEOFF REF i APPROACH REF. Transport danych pozostaje właściwy dla danego dodatku. Nie różnicujemy parsera według domniemanego numeru aktualizacji oprogramowania FMC: ewentualne różnice zostaną dodane po porównaniu rzeczywistych ekranów PMDG. Jest to założenie robocze, nie potwierdzenie zgodności wszystkich wersji NG/MAX.

`fmc/BoeingFMCValuesU.pas` rozszerza wspólny parser stron zapisanych jako TStringList. Czyta tylko widoczne strony; nie naciska klawiszy FMC. Nowe wartości są zapisywane w `parsed_json` razem z surowym ekranem, a analiza starszych ekranów ponownie wykonuje parsowanie. Historia zmian i czasy obserwacji pozostają w `trip_fmc_screens`.

| Strona | Pola |
|---|---|
| TAKEOFF REF | `takeoff_flaps_deg`, `takeoff_n1_left_pct`, `takeoff_n1_right_pct`, `takeoff_cg_pct`, `takeoff_trim_units`, dotychczasowe V1/VR/V2 |
| N1 LIMIT | `assumed_temp_c`, `oat_c`, limity N1 lewy/prawy; `takeoff_mode_active`, `takeoff_mode_selected`, `climb_mode_active`, `climb_mode_selected` |
| N1 LIMIT — wybrany/aktywny start | `takeoff_active_rating_k`, `takeoff_selected_rating_k`, analogicznie `derate_pct` i `bump` |
| PERF INIT | `gross_weight_display`, `cruise_cg_pct`, `cruise_altitude_ft`, `planned_fuel_display`, `fuel_display`, `fuel_source`, `zfw_display`, `reserves_display`, `cost_index`, `transition_altitude_ft` |
| PERF INIT — pogoda planowana | `cruise_wind_deg`, `cruise_wind_kt`, `isa_dev_f`, `isa_dev_c`, `top_of_climb_oat_f`, `top_of_climb_oat_c` |
| APPROACH REF | Dotychczasowy wybrany `vref_kt`, `approach_flaps_deg` oraz osobna korekta wiatru |

Znaczniki ACT/SEL są przypisywane do połowy wiersza: lewa to tryb startowy, prawa to tryb wznoszenia. Przykład `<TO   <ACT> <SEL>   CLB>` daje aktywny TO i wybrany CLB. Nie oznacza wyboru TO-1, TO-2 ani TO-B tylko dlatego, że te opcje są wyświetlone poniżej. TO-1 oznacza derate 10%, TO-2 20%, TO-B flagę bump; nominalne K jest odczytywane z wiersza nad oznaczoną opcją, bez zgadywania brakującego ratingu.

`----/ +14°C` daje assumed temperature null i OAT +14°C. `+45 / -10°C` daje assumed temperature +45°C oraz OAT -10°C. N1 na tych stronach jest limitem/celem, nie pomiarem aktualnych obrotów silnika. Trim to jednostki trymowania stabilizatora; CG to procent MAC. `FL130` jest przeliczane na 13 000 ft. Wartości mas i paliwa z sufiksem `_display` zachowują liczby ekranu; parser nie zgaduje KG/LB. Puste pola oraz kreski dają null, a nie zero.

Okno informacji o nagraniu pokazuje odczytane V-speeds, klapy, N1, assumed temperature/OAT, CG/trim, tryby aktywne i wybrane, rating/derate/bump oraz podstawowe dane PERF INIT. Dla każdego startu i lądowania wybiera stan sprzed czasu tego kontaktu, osobno dla każdego urządzenia. Gdy nie ma kontaktów, pokazuje ostatni dostępny stan nagrania. Ukryte strony nie są odświeżane; wyświetlony stan oznacza ostatni odczyt, nie dowód ciągłej aktualności. Strony MOD nie zastępują zatwierdzonych wartości.

`VerifyBoeingFMC` używa syntetycznych ekranów odpowiadających zgłoszeniu. Sprawdza ACT/SEL po obu stronach, TO-1 i TO-B, temperaturę założoną versus OAT, N1, klapy/CG/trim, PERF INIT i konwersję FL oraz stan informacji przed kontaktami. Nie jest testem nowego lotu w MSFS ani wszystkich formatów stron różnych producentów.
