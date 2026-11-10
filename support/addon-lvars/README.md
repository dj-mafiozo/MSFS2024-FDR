# Dodatkowe samoloty — katalog L-varów z modeli XML

[Tłumaczenia interfejsu](../../Translation.pl.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


PMDG DC-6: 904; CSS 737 Classic: 1221; Leonardo Maddog X: 365; SkySim DC-9 (DC93/DC91F): 488; SkySim MD-11: 320. Razem 3298 unikatowych nazw w obrębie swoich dostawców. Odczytano wszystkie XML z podanych katalogów modeli, także zewnętrzne i DC-6A/B/BP. `fields.json` zawiera pliki źródłowe i SHA-256, jednostki źródłowe, 24 tytuły aircraft.cfg oraz pominięte nazwy dynamiczne/nieprawidłowe. Pełnych XML nie rozpowszechniamy.

Brak publicznego nagłówka SDK w wskazanej dokumentacji DC-6 nie jest zastępowany strukturą 737/777. Dla tych pięciu rodzin odczytujemy dosłowne `(L:...)`, nie zapisy `(>L:...)`; szablony `#...#` nie są zgadywane. Dostęp jest tylko do odczytu przez SimConnect, z izolacją błędu pojedynczej zmiennej i najwyżej jednym oczekującym ONCE na pole. Odpytywanie jest ograniczone interwałem i skończonym pumpem; brak ciągłej kolejki SIM_FRAME dla tysięcy pól.

To surowe, niezweryfikowane semantycznie kanały modeli. Nieistniejący L-var może zwrócić zero; sam odebrany numer nie dowodzi obsługi ani gotowości systemu. Błędy/NaN/brak danych są null. Nie wymuszamy jednostek fizycznych i nie podmieniamy standardowych SimVarów na podstawie samej nazwy. Wartości trafiają do historii zmian, wykresów i kontekstu AI z tym ograniczeniem. Nie dodaje to pełnych ekranów FMS DC-6/DC-9/MD-11/Maddog ani sterowania samolotem.

Rozpoznawane są potwierdzone tytuły bazowych aircraft.cfg i jednoznaczne nazwy producentów/dodatków. Nieznana nazwa niestandardowej livery może pozostać przy zwykłym SimConnect; celowo nie klasyfikujemy dowolnego MD-11 jako SkySim (np. TFDi).

Odtworzenie: `tools/generate_addon_lvars.py --models-root <folder> --root <repo>`. Folder zawiera podkatalogi PMDGDC6/CSS737/MaddogX/SkySimDC9/SkySimMD11 z lokalnymi XML i CFG. Test `VerifyAddonLVars` używa atrap, nie lotu na żywo.
## 0.1.0.10 — subskrypcje według aktywnego lotu

W bezczynności odczytywane są tylko TITLE, ENGINE TYPE i NUMBER OF ENGINES (raz na sekundę), a stan sesji śledzą zdarzenia systemowe i Flow. FlightLoaded, AircraftLoaded i SimStart wyzwalają odświeżenie identyfikacji; SimStart może potwierdzić lot aktualnym stanem FlightLoaded. Sam zapamiętany stan AircraftLoaded nie uruchamia nagrywania w menu. Zakończenie sesji/ładowanie wyłącza pełny odczyt i providery; SimStop zawiesza subskrypcje. Pauza lub chwilowy SimStop nie zastępuje jawnej granicy sesji przy podziale nagrań. Pakiety starych generacji są odrzucane. Wspólny katalog AIRLINER nie jest odczytywany dla każdego samolotu.

Duży katalog podzielono na osiem unitów samolotów; AddonLVarCatalogU to niewielki rejestr. Sprawdzono 18 wariantów sześciu rodzin komercyjnych: pierwsze pięć zachowuje 3298 nazw, TFDi MD-11 (GE/PW, pasażerski/towarowy) dodaje 1446. TFDi używa jawnych L-varów XML modelu, nie nieistniejącego w podanej lokalizacji nagłówka/binarnego API SDK. Katalog to suma nazw danej rodziny; dostępność konkretnego pola nadal zależy od wariantu. Referencje do modeli wspólnych nie oznaczają braku zmiennych. Metadane: `support/addon-lvars/variant-audit.json`. Dodatkowe 306 bindingów Bell 407/EC135 pochodzi z audytu oficjalnych locpaków. Łącznie 5050 pól w ośmiu profilach; zero nadal nie potwierdza istnienia L-vara.

