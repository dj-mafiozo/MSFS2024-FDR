# Integracja SDK PMDG 737 NG3

[Tłumaczenia interfejsu](../../Translation.pl.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


PMDG 737 NG (-600/-700/-800/-900, warianty BBJ/cargo) wybiera PMDGNG3; 777, MAX i inni producenci nie pasują. Dostarczony oficjalny PMDG_NG3_SDK.h definiuje 916-bajtowy blok danych, 494 nazwane pola po rozwinięciu tablic i 1009-bajtowy ekran CDU. Layout pack(8) zweryfikowano niezależnie przez ctypes i clang-cl. Zastrzeżony pełny nagłówek nie jest dystrybuowany.

Czytnik otwiera osobne połączenie SimConnect tylko do odczytu obszarów PMDG_NG3_Data/CDU_0/CDU_1, ON_SET i początkowe ONCE. Nie mapuje sterowania, nie zapisuje Client Data i nie wysyła zdarzeń. Opcjonalny błąd CDU nie zatrzymuje głównych danych.

W aktywnym pliku opcji samolotu sekcja [SDK] wymaga EnableDataBroadcast=1, EnableCDUBroadcast.0=1 i EnableCDUBroadcast.1=1. Nagłówek wymienia 737NG3_Options.ini; badana instalacja MSFS24 737-600 używała LocalState/WASM/MSFS2024/pmdg-aircraft-736/work/737_Options.ini. Opcje były już włączone; nie zmieniano konfiguracji. Po własnej zmianie przeładuj samolot.

V-speeds są w kt; zero referencji jest niewybrane/null, ale raw zero pozostaje. Landing altitude -32767 jest niedostępne; inne ujemne wysokości mogą być poprawne. Ujemne dystanse TOD/destination są niedostępne, TOD=0 poprawne. MCP uwzględnia zasilanie/kreski/IAS/Mach. Gear OFF pozostaje osobnym stanem raw, bez fałszywego nadpisania UP/DOWN. A/THR korzysta z faktycznego połączenia serwa, AP z kontroli pitch/roll (także CWS), bez dopisywania CMD/LNAV/VNAV. Paliwo SDK jest w lb niezależnie od opcji ekranu. Wskaźniki klap nie są wymyślonym kątem ani indeksem dźwigni.

ON_SET nie ma heartbeat; stabilne dane pozostają do nowego broadcastu. data_update_age_ms to wiek pakietu, nie potwierdzenie świeżego pomiaru. Pauza/zmiana samolotu/rozłączenie resetują cache. Snapshoty mają interwał FDR, pełny początek i delty; wykresy PMDGNG3.<pole>.

CDU: 24 kolumny ×14 wierszy × symbol/kolor/flagi + powered, kolumny są zewnętrznym wymiarem. Tekst, strzałki i raw bajty są zachowywane; wyłączony ekran nie jest aktualną referencją. Parser stron Boeinga jest obecnie wspólny z iFly jako założenie robocze, do porównania na żywo. Regeneracja: tools/generate_pmdg_catalog.py <nagłówek>, kompilacja; generator tworzy też .build/VerifyPMDGLayout.cpp. VerifyPMDG używa atrapy DLL. Próby rzeczywistego PMDG nie wykonano, ponieważ użytkownik leciał iFly. Szczegóły w README.en.md.
