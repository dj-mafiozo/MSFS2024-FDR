# Parsowanie MCDU Fenix A32X i FlyByWire A32NX

[English](Airbus-MCDU.en.md)

Źródłem jest pełny ekran z uruchomionego i połączonego FlightPadFMC.
`fmc/AirbusMCDUValuesU.pas` parsuje już złożone wiersze; nie potrzebuje dodatkowego
połączenia z samolotem. Dane trafiają do `trip_fmc_screens.parsed_json` razem
z dotychczasowym tekstem i timestampami. Kontekst analizy odczytuje ostatnie
wartości widziane przed zdarzeniem, oddzielnie dla dostawcy i urządzenia.

## Rozpoznawane strony i pola

| Strona / etykieta | Klucze wyniku |
| --- | --- |
| PERF TAKE OFF: V1, VR, V2 | `v1_kt`, `vr_kt`, `v2_kt` |
| FLX TO TEMP / FLEX TO TEMP | `flex_to_temperature_c` |
| FLAPS/THS | `takeoff_flaps`, `takeoff_ths_nose_up_deg` |
| TRANS ALT | `transition_altitude_ft` |
| THR RED/ACC | `thrust_reduction_altitude_ft`, `acceleration_altitude_ft` |
| ENG OUT ACC | `engine_out_acceleration_altitude_ft` |
| RWY | `takeoff_runway` |
| PERF APPR: VAPP, VLS, jawne VREF | `vapp_kt`, `vls_kt`, `vref_kt` |
| VAPP i VLS z tej samej strony | `approach_speed_additive_kt` = VAPP−VLS |
| QNH | `approach_qnh_hpa` albo `approach_qnh_inhg` |
| TEMP | `approach_temperature_c` |
| MAG WIND | `approach_wind_magnetic_deg`, `approach_wind_kt` |
| TRANS LVL | `transition_level_fl` |
| FINAL | `final_approach` |
| MDA / BARO / DH / RADIO | `minimum_descent_altitude_ft`, `barometric_minimum_ft`, `decision_height_ft`, `radio_minimum_ft` |
| LDG CONF, jednoznaczna pojedyncza wartość | `landing_configuration` |
| INIT A: FROM/TO, ALTN, FLT NBR | `from_to`, `alternate_airport`, `flight_number` |
| COST INDEX / CI | `cost_index` |
| CRZ FL/TEMP | `cruise_flight_level`, `cruise_temperature_c` |
| INIT B: ZFW/ZFWCG, BLOCK | `zero_fuel_weight_cg_display`, `block_fuel_display` |

Rozpoznawane są również tytuły CLB, CRZ, DES i GO AROUND. Ich obsługiwane
etykiety performance przechodzą przez ten sam parser. Nie oznacza to
parsowania wszystkich predykcji tych stron. INIT A i B mają osobne klucze
historii; B jest rozpoznawana także po etykietach ZFW/BLOCK. Numery stron
pozostają w kluczu. TMPY i MOD są obserwacjami oczekującymi, oddzielonymi
od wykonanych wartości.

## Zasady interpretacji

- Etykiety i wartości są odczytywane z tej samej połowy ekranu, ze standardowych
  par wierszy etykieta–wartość. Obsługiwane są też jawne wpisy w jednej linii.
  Scratchpad i nierozpoznane strony, np. F-PLN, nie służą do ekstrakcji.
- Brak etykiety oznacza brak nowej obserwacji tego pola. Widoczna etykieta
  z pustą, kreskowaną, niejednoznaczną lub nieprawidłową wartością daje `null`.
  Parser nie pożycza liczby z przeciwnej kolumny.
- QNH rozdziela hPa i inHg; zmiana jednostki unieważnia poprzedni wariant.
  Ciśnienie, temperatura i wiatr są **wpisami MCDU**, nie pomiarem aktualnej
  pogody ani raportem METAR. Wiatr ma kierunek magnetyczny.
- VLS pozostaje odrębne od VREF. Różnica VAPP−VLS nie jest automatycznie
  przypisywana do `wind_correction_kt`: może zawierać inne składniki.
- THS ma dodatni znak dla UP i ujemny dla DN. Bez jawnego kierunku nie
  powstaje liczba udająca rozstrzygniętą nastawę trimu.
- Konfiguracja podana w MCDU jest referencją, nie dowodem wykonanej pozycji
  klap. Wiersz oferujący jednocześnie CONF3 i FULL nie jest zgadywany.
- Jednostki masy i paliwa mogą zależeć od konfiguracji samolotu. Bez informacji
  o nich ZFW/ZFWCG i BLOCK pozostają stringami `*_display`, zamiast arbitralnie
  przypisywać im tony, kilogramy lub funty.
- Wszystkie nieobsługiwane dane pozostają w surowym tekście do dalszego
  parsowania. Typowane referencje SDK mają pierwszeństwo w analizie.

Analiza ponownie parsuje również wcześniej zapisane surowe ekrany Airbusów,
więc istniejące nagrania z `raw_text` zyskują nowe pola bez migracji lub
modyfikowania historii. Stare `parsed_json` w bazie nie jest nadpisywane.
Późniejsze ekrany nie przenikają do oceny wcześniejszego zdarzenia.

Układ i znaczenie etykiet FBW zweryfikowano na podstawie
[oficjalnej dokumentacji strony PERF](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/mcdu/perf/).
Fenix korzysta z tych samych obsługiwanych etykiet standardowego układu
Airbus; inne układy pozostają surowym tekstem. Testy są wykonywane na
syntetycznych ekranach obu dostawców, bez potwierdzenia w rzeczywistym locie.
