# Referencja pogody przy kontakcie z pasem

[English](ground-weather.en.md)

W MSFS24 `AMBIENT TEMPERATURE`, `AMBIENT PRESSURE` i `BAROMETER PRESSURE`
są obliczane w pozycji samolotu użytkownika. Nie są raportem lotniskowym.
Temperatura i lokalne ciśnienie mogą zmieniać się wraz z wysokością i miejscem
lotu; sama taka zmiana nie dowodzi zmiany lotniskowego QNH ani błędu nastawy.

Dokumentacja: [MSFS24 Miscellaneous Variables](https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/SimVars/Miscellaneous_Variables.htm).
AMBIENT PRESSURE ma jednostkę inHg i nie jest QNH zredukowanym do poziomu
morza. BAROMETER PRESSURE ma jednostkę mb/hPa, ale nie należy automatycznie
utożsamiać go z potwierdzonym QNH konkretnego lotniska. Wcześniejszy opis
tego pola jako ciśnienia na poziomie morza w kontekście analizy został poprawiony.

Kontekst AI w wersji 10 zawiera `weather.ground_reference`:

- Start: ostatnia próbka tego tripu z `sim_on_ground=true` w chwili oderwania
  lub wcześniej.
- Lądowanie: pierwsza próbka tego tripu z `sim_on_ground=true` w chwili
  przyziemienia lub później. Dalsze próbki po odbiciu i podczas dobiegu nie
  zastępują pierwszego kontaktu.
- Wyszukiwanie obejmuje cały trip, także poza wybranym oknem analizy.
- Referencja zawiera czas UTC, temperaturę, ciśnienia, wiatr, widzialność,
  wysokość i współrzędne samolotu oraz nastawę KOHLSMAN w hPa.
- Gdy brak odpowiedniej próbki, `available=false` i opis przyczyny. Nie ma
  zastępowania jej próbką w powietrzu, próbką najbliższą zdarzeniu ani danymi
  innego tripu. Brakujące wartości wybranej próbki pozostają null.

Prompt poleca używać wyłącznie tej referencji dla pogody symulatora przy
ocenianym starcie/lądowaniu. Pozostałe próbki pogody nadal są dostępne jako
przebieg warunków przy samolocie, z wyraźnym zakazem interpretowania zmian
wysokościowych jako błędnego QNH. Nawet referencyjne AMBIENT PRESSURE na
ziemi nie może być bezpośrednio porównywane z nastawą QNH bez uwzględnienia
wysokości lotniska i różnicy definicji.

METAR pozostaje osobną obserwacją stacji z własnym czasem. Nie zmieniamy
wartości w bazie, nie przeliczamy AMBIENT PRESSURE na domniemane QNH i nie
dopisujemy nieotrzymanych informacji FSHud. Korekta obowiązuje również przy
ponownym analizowaniu starych nagrań. Istniejący raport należy wygenerować
ponownie przez kliknięcie analizy z Shift.

`VerifyGroundWeather` sprawdza wybór ostatniej/pierwszej próbki, pominięcie
późniejszego kontaktu po odbiciu, referencję spoza okna analizy, rozdzielenie
nastawy od ciśnienia otoczenia i brak zastępowania danych przy ich braku.
