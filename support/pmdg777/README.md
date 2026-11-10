# PMDG 777 — SDK tylko do odczytu

[Tłumaczenia interfejsu](../../Translation.pl.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


Obsługiwane: oficjalny PMDG_777X_SDK.h, SHA-256 `3d0ecfb39fe7524a5017b63c7cb52f4d850b97f738ed5d4d8f1637afc1a676f7`. Katalog: 522 pola, blok danych 684 bajty; ekran CDU 1009 bajtów. Wszystkie offsety oraz rozmiary porównano z ctypes i niezależnymi static_assert oryginalnego nagłówka w clang-cl /Zp8. Nagłówek pozostaje lokalną referencją, nie jest dołączany do paczki.

W pliku PMDG `777_Options.ini`, sekcja `[SDK]`, włącz `EnableDataBroadcast=1` oraz `EnableCDUBroadcast.0=1`, `.1=1`, `.2=1`. FDR nie zmienia tych ustawień. Czyta `PMDG_777X_Data` oraz `PMDG_777X_CDU_0/1/2` przez SimConnect Client Data, z początkowym ONCE i aktualizacjami ON_SET. Nie wysyła sterowania ani zdarzeń.

Zapisywane są pola SDK, typowane V1/VR/V2/VREF i pozostałe referencje, trzy ekrany CDU, surowe komórki, kolor, mała czcionka, reverse/dim, zasilanie i EXEC/DSPY/FAIL/MSG/OFST. Poprawne AP, FD, AT ARM, podwozie, nastawy MCP i paliwo zastępują odczyty ogólne według jawnej semantyki SDK. A/T ARM lub lampka przycisku nie są utożsamiane z pracą serwomechanizmów autothrottle. Wartości zerowe niewyznaczonych V-speeds, ujemne niedostępne odległości i wysokość lądowania -32767 są przekazywane jako brak referencji. Przełączenie HDG/TRK i VS/FPA nie podmienia niewłaściwego parametru. Zmiany ekranów i wartości mają znaczniki czasu; identyczne pakiety są pomijane.

Generator: `tools/generate_pmdg777_catalog.py <lokalny nagłówek> --root <repo>`. Odtworzenie static_assert: `.build/VerifyPMDG777Layout.cpp`, do kompilacji z oryginalnym nagłówkiem. `VerifyPMDG777` korzysta z atrapy DLL i SQLite; próba z uruchomionym samolotem nie została wykonana.
