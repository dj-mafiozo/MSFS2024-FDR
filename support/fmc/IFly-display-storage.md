# Zapis wyświetlaczy iFly SDK 1.5

[English](IFly-display-storage.en.md)

SDK nadal jest odczytywane w całości. Dopiero kopia przeznaczona do `trip_aircraft_data` jest składana i pomniejszana; oryginalny odczyt pozostaje dostępny dla parsera FMC i istniejących nadpisań SimConnect. Nie zmieniono katalogu ani layoutu SDK.

`aircraft/ifly/IFlyDisplaysU.pas` składa 26 grup: Flight/Landing Altitude Indicator, Course 1/2, HDG, ALT, SPD, VS, transponder, dwa ADF, cztery NAV, trzy Fuel Quantity Indicator, dwa okna IRS oraz sześć okien RTP. Wynik zachowuje indeksy tablic, np. `Fuel_Quantity_Indicator_Value[0]`, `ADF_num_Value[1]`, `NAV_num_Value[0][1]`. W nowych snapshotach poszczególne cyfry tych grup są usuwane. Pozostałe przełączniki i kontrolki SDK pozostają bez zmian.

Każda grupa ma `_Value`, `_Text` oraz `_DisplayStatus`. Dla niepoprawnego, nieznanego, wygaszonego lub testowego stanu liczba jest null; `_Text` zachowuje zera wiodące, spacje, znaki i litery. `_Codes` przechowuje spakowane kody cyfr dla stanów, których nie można sprowadzić do wartości. `_Points` to maska flag punktów, jeśli grupa je udostępnia. IRS zachowuje tekst kierunkowy, np. `N51436`, i maskę punktów; parser nie zgaduje z tego współrzędnych. Nieokreślona w SDK pozycja kropki Mach daje `decimal_unspecified` i null zamiast wymyślonej liczby.

ADF uwzględnia wskazany punkt dziesiętny; NAV składa miejsca 100/10/1/0.1/0.01. RTP składa trzy pozycje przed i trzy po punkcie, gdy flaga punktu jest aktywna; obsługuje również litery z tabeli SDK. Fuel Quantity składa pięć pozycji w kolejności indeksów 0–4. To odczyt wyświetlacza, nie niezależny pomiar masy; nie zakłada KG/LB ani nazw zbiorników. Układ i jednostki paliwa oraz szczególne tryby IRS/RTP wymagają jeszcze sprawdzenia podczas pracy rzeczywistego dodatku.

`LSKChar`, `LSK_Color`, `LSK_SmallFont` oraz pięć kontrolek CDU nie trafiają ponownie do ogólnej historii SDK. `trip_fmc_screens` zawiera:

| Kolumna | Zawartość |
|---|---|
| `raw_text` | Dotychczasowe 14 wierszy po 24 znaki z odwzorowanymi glifami |
| `style_json` | `color-font-nibbles-v1`: 14 ciągów po 48 znaków hex, dwa nibbles na komórkę: kolor i mała czcionka; F oznacza nieznane |
| `annunciators_json` | FAIL, MSG, EXEC, CALL, OFST: 0 OFF, 1 DIM, 2 BRI; brak/nieprawidłowy kod daje null |
| `formatted_html` | Bezpiecznie escapowany tekst z kolorami, tłem i małą czcionką, bez skryptów i zewnętrznych zasobów |
| `parsed_json` | Dotychczasowe dane referencyjne odczytane z tekstu |

Zmiana tylko koloru, małej czcionki albo kontrolki zapisuje nowy ekran z timestampem, nawet gdy tekst jest identyczny. Samo ponowne odczytanie identycznego ekranu nie dopisuje wiersza. Bufor preflight zachowuje wygląd i kontrolki, również po konwersji do wspólnego formatu CDU. Do kontekstu analizy trafiają kontrolki, natomiast duży HTML nie jest powielany w promptach.

Schemat istniejącej bazy otrzymuje nullable kolumny bez kasowania wcześniejszych danych. Stare surowe pola SDK pozostają w historii; wartości złożone są dodawane podczas odczytu, po rekonstrukcji delt. Nowe parametry liczbowe są dostępne na wykresach. Stare rekordy FMC bez metadanych nie dostają wymyślonych kolorów ani stanów kontrolek. Kontekst analizy ma wersję 13 i definicje nowego formatu.

Testy są syntetyczne; szczegóły w `Testy.md`. Źródło mapowania: dostarczony oficjalny `MSFS_MAX8_SDK_v1.5/737MAX_SDK/sdk/SDK_Defines.h` oraz wygenerowany katalog projektu. SDK definiuje znaczenia kodów cyfr, wygaszenia, znaków i glifów; nie wszystkie zależne od trybu znaczenia wyświetlanego tekstu są w nim opisane.
