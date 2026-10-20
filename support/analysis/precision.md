# Precyzja i histereza danych analizy

[English](precision.en.md)

Kontekst AI (precyzja od schema_version=8) zaokrągla liczby zmiennoprzecinkowe do
**maksymalnie trzech miejsc po przecinku**. Dotyczy to obiektów i tablic,
w tym zdarzenia, pogody, statystyk, danych SDK, silników i referencji FMC.
Końcowe zera nie są dopisywane. Liczby całkowite i identyfikatory Int64 są
zachowane bez konwersji przez Double. Tekst, w tym surowe strony FMC/MCDU,
pozostaje niezmieniony. Ujemne zero jest normalizowane do zera.

Dla kolejnych próbek działa martwa strefa **±0,0015** w jednostce danego
parametru. Porównanie następuje po zaokrągleniu, względem ostatniego
**wysłanego i odtworzonego** stanu, a nie ostatniego surowego odczytu.
Pomijane małe zmiany mogą więc narastać i zostaną wysłane po przekroczeniu
progu. Różnica 0,001 jest pomijana, a 0,002 przekracza próg. Dodatkowa
tolerancja 1e-12 osłania samo porównanie przed błędem arytmetyki Double.
Jest to martwa strefa względem ostatniej przekazanej wartości, nie filtr
średniej ruchomej ani osobne progi zależne od typu parametru.

Przykład: odczyty 1,00049 → 1,00051 → 1,0014 → 1,0021 dają bazę 1,000,
dwa pominięcia i zmianę na 1,002. Drobne wahania przy granicy zaokrąglenia
nie powodują przełączania delt między sąsiednimi wartościami co próbkę.

Zmiany logiczne, całkowite oraz jawne null nie podlegają tłumieniu. Czas
`utc` i zaokrąglone `t_seconds` pozostają w każdej próbce. Zniknięcie pola
jest sygnalizowane null; nie jest ono powtarzane, gdy stan już oznacza brak
danych. Rekurencyjne porównywanie tablic uwzględnia tę samą martwą strefę.

Przetwarzanie dotyczy **wyłącznie kontekstu analizy AI**. Baza nagrań,
historia zmian SDK i wykresy zachowują dotychczasową precyzję. Statystyki
i projekcje na pas są obliczane przed końcowym zaokrągleniem. Współrzędne
geograficzne w JSON analizy również mają trzy miejsca (około 111 m dla
0,001° szerokości); do oceny położenia względem pasa służą osobno obliczone
odległości metryczne. Mapa korzysta z niezaokrąglonych danych bazy.

`VerifyPrecision.dpr` sprawdza rekurencyjne zaokrąglenie, identyfikator
większy od 2^53, pozostawienie tekstu i danych źródłowych, szum na granicy
zaokrąglenia, narastanie małych zmian, wahania wsteczne, stan AP oraz czas
każdej próbki. Istniejące testy kontekstu nadal sprawdzają silniki,
null/braki/powroty, AP/A/T, pogodę i odtwarzanie kolejnych stanów.
