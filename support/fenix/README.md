# Integracja Fenix A32X

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


Tytuł samolotu zawierający Fenix lub identyfikatory FNX_32/FNX A32 wybiera FenixA32X. Dedykowane połączenie SimConnect tylko do odczytu pobiera 1203 L-vary FLOAT64/number w grupach po 128; odświeżanie SIM_FRAME, zapis z interwałem rejestratora. Nie wysyła poleceń, nie wymaga WASM. Katalog pochodzi z 2096 parametrów VAR_NAME* dostarczonego Cockpit_Behavior.xml; manifest zachowuje kontekst i SHA-256, pełny XML nie jest dystrybuowany.

Stan początkowy jest pełny, dalsze rekordy zawierają zmiany. Wykresy: FenixLVar.<nazwa>. S_MIP_GEAR mapuje dźwignię UP/DOWN, S_FC_FLAPS detenty 0–4. Animacja przepustnic 0–5 nie jest procentem ciągu. Przyciski AP/A-THR i ich lampki nie są bezpośrednim dowodem aktywnego trybu. Pozycje podwozia, kontakt kół, pogoda i dynamika bez zweryfikowanych odpowiedników pozostają z SimConnect.

Brak/błąd/NaN/przeterminowanie daje null, nie zero. Ważność: max(1000, interwał_ms)*3; po 30 s bez danych następuje pomocniczy reconnect z backoff. Pauza, zmiana samolotu i rozłączenie kasują cache. Odebrane zero nie dowodzi istnienia L-vara. Nie znaleziono bezpośrednich numerycznych V1/VR/V2/VREF/VAPP w tym katalogu; pełny ekran daje zaktualizowany FlightPadFMC. VerifyFenix używa atrapy DLL; dane rzeczywistego Fenixa wymagają próby na żywo.

Regeneracja: tools/import_fenix_catalog.py <Cockpit_Behavior.xml> support/fenix/variables.json, następnie tools/generate_fenix_catalog.py i kompilacja. Szczegóły transportu i ograniczeń w README.en.md; ekran MCDU w ../flightpad/README.md.
