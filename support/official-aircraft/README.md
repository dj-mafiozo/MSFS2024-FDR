# Oficjalne samoloty — dobór parametrów

[Interface translations](../../Translation.pl.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Odczytano 120 pakietów i 2046 plików locpak z Official2020/OneStore oraz Official2024/OneStore. Nie otwierano zaszyfrowanych fsarchive. `locpak-audit.json` zawiera nazwy pakietów, plików, SHA-256 i jawne bindingi. Same identyfikatory tooltipów nie są nazwami SimVarów. W części tłumaczeń przetłumaczono także kod bindingu; takie nazwy nie nadają się do odczytu.

Subskrypcja standardowa jest wybierana na podstawie rzeczywistych ENGINE TYPE i NUMBER OF ENGINES, niezależnie od producenta i malowania: tłokowy → RECIP/PROP, odrzutowy → TURB bez RECIP/PROP, turbośmigłowy → TURB/PROP, elektryczny → PROP i parametry ogólne, bez turbin/tłoków. Indeksy ponad liczbę silników są pomijane. Pozostałe wspólne pola obecnego katalogu są zachowane. Nie jest to automatyczne tworzenie wszystkich możliwych SimVarów z tłumaczeń.

Bell 407: 72 dodatkowe bindingi; EC135: 234. Uwzględniono wyłącznie numeryczne wyrażenia powtarzające się bez zmian w co najmniej połowie zainstalowanych locale, minimum trzech. `A:` oznacza standardowy SimVar z podaną jednostką; pozostałe pozycje to L-vary. Są zapisywane jako surowe dane wybranego profilu, bez zgadywania znaczenia i nadpisywania parametrów wspólnych. Pozostałe pakiety nie dostarczyły wiarygodnego kompletnego katalogu dodatkowych zmiennych. Brak bindingu w locpak nie dowodzi braku zmiennej w samolocie.

Odtworzenie audytu: `python tools/audit_official_locpaks.py --packages-root <Packages>`, następnie generator katalogów opisany w `support/addon-lvars`. Audyt i testy transportu wykonano lokalnie; odbiór z tych samolotów podczas lotu pozostaje nieprzetestowany.
