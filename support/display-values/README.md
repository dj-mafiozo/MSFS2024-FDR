# Audyt etykiet wartości

[Informacja o tłumaczeniach](../../Translation.pl.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Zmapowano 5118 pól, w tym 2313 dodatkowych. Skontrolowano nagłówki SDK iFly, PMDG NG3 i PMDG 777 oraz 335 XML wszystkich dostępnych wariantów Fenix/FBW/iFly/DC-6/CSS/Maddog/SkySim/TFDi. Pozostałe opisy bool pochodzą z wcześniej zinwentaryzowanych jawnych jednostek XML, także Bell 407 i EC135.

`catalog.json` zawiera etykiety, regułę ekstrakcji, referencje do plików źródłowych i SHA-256. Nie zawiera kodu XML ani nagłówków SDK. Ponowny audyt wymaga lokalnych źródeł; runtime używa wyłącznie skompilowanych katalogów Pascal. Generatory zachowują metadane przez `apply_display_values.py`.

Mapowane są jawne enumy, ANIMTIP, jawne press=1/release=0 oraz typowane bool. Komentarze iFly odczytywane są jako GB18030. Dla niepełnych enumów mapowane są tylko opisane wartości. Nie zgadujemy środków zakresu, kierunku odwróconych selektorów FO, zaszyfrowanych danych ani prywatnego stanu WASM. Z 14 wadliwych XML odzyskiwane są wyłącznie samodzielnie poprawne fragmenty UseTemplate. Dostępność danych w locie pozostaje niezależna od możliwości opisania ich wartości.

Uruchom `test.ps1 -Tests VerifyCatalogSources,VerifyParameterValues` i `python tools/apply_display_values.py --check`. Testy Delphi VerifyParameterValues sprawdzają rzeczywistą prezentację. Brak nowej weryfikacji na żywo.

## Indeks klap standardowego SimConnect

`FlapsHandleU.pas` zawiera osobny case po ICAO; globalny `SimFields[].DisplayValue` dla flaps_handle_index pozostaje pusty. Profile i źródła są w `flaps.json`, pełna lista w [flaps-coverage.csv](flaps-coverage.csv). Generator: `python tools/generate_flap_profiles.py` (lub `--check`). Kontrola testowa wykrywa rozbieżność między JSON a unitem.

156 jawne kody: 66 mają profil (część zależy od tytułu dodatku), 30 oznacza typy bez klap, 60 pozostaje niepotwierdzonych. To nie jest deklaracja pełnego odwzorowania wszystkich domyślnych samolotów. Lokalne konfiguracje domyślnych pakietów MSFS 2024 były zaszyfrowane; użyto 26 dostępnych konfiguracji dodatków, instrukcji symulatorowych i profili referencyjnych producentów. Status `reference_profile` nie oznacza sprawdzenia w locie. Nieznane/niejednoznaczne przypadki zwracają pusty słownik, więc UI pokazuje liczbę.

Standardowy indeks Airbusa 0/1/2/3/4/5 oznacza UP/1/1+F/2/3/FULL. To inna zmienna niż 0..4 dźwigni SDK. TFDi i SkySim MD-11 mają różne układy mimo wspólnego ICAO; nie rozstrzygamy tego bez tytułu. Zapisane FLAPS NUM HANDLE POSITIONS ma pierwszeństwo: niezgodność liczby pozycji wyłącza profil. Nie potwierdza to zgodności kątów w dowolnej modyfikacji innego producenta z tym samym ICAO. Oznaczenia nominalnych detentów nie są pomiarem aktualnego wychylenia powierzchni.
