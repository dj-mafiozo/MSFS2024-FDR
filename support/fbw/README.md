# Integracja FlyByWire A32NX

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


Tytuły A32NX lub FBW/FlyByWire wraz z A320 wybierają FBWA32NX; zwykły A320 i A380 nie pasują. Katalog ma 223 czytelne L-vary z dostarczonej dokumentacji Flight Deck API, z rozwiniętymi indeksami. Pomija 26 wpisów write-only/deprecated. Gotowość i jednostki prędkości uzupełnia oficjalna referencja. Manifest zachowuje SHA-256; pełna dokumentacja nie jest dołączana.

Wspólny TAircraftLVarReader pobiera grupy 128 FLOAT64/number na osobnym połączeniu tylko do odczytu. Zapis podlega interwałowi FDR, błędy pomocnicze nie kończą lotu. Brak/błąd/przeterminowanie daje null; odebrane zero nie dowodzi istnienia zmiennej. IS_READY=1 jest warunkiem nadpisania standardowych wartości i referencji VAPP, nie dowodem ważności każdego pola.

AUTOTHRUST_STATUS 0/1/2 oznacza off/armed/active. FBW detenty klap 0/1/2/3/4 mapują się na MSFS 0/2/3/4/5; nie są kątami powierzchni. FCU speed uwzględnia kreski i tryb IAS/Mach. VAPP jest referencją podejścia (z możliwością wpisu pilota), nie VREF; brak/zero/stare dane dają null. Lampka przycisku AP nie zastępuje faktycznego załączenia autopilota.

Historia ma pełny stan początkowy i delty; wykresy FBWLVar.<nazwa>. Cache resetuje się przy zmianie samolotu, pauzie i rozłączeniu. Pełny tekst MCDU wymaga połączonego, zaktualizowanego FlightPadFMC. VerifyFBW używa atrapy SimConnect; próba rzeczywistych wartości w symulatorze nadal jest potrzebna. Regeneracja: tools/import_fbw_catalog.py <plik.htm> support/fbw/variables.json, tools/generate_fbw_catalog.py, kompilacja. Szczegóły w README.en.md.
