[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

[Translation notice](../../Translation.pl.md)

# Profile modeli FSLTL i AIG

Katalog zawiera wyłącznie fakty o parametrach animacji, kody ICAO, identyfikator commita i hashe źródeł. Modele, tekstury i XML FSLTL nie są dołączane do programu.

Przy starcie aplikacja w tle odczytuje zainstalowane konfiguracje w Community. Ghost przecina te dane z listą modeli SimConnect. Typ ICAO i livery mają pierwszeństwo; przy równym dopasowaniu wygrywa FSLTL, następnie AIG, a na końcu model domyślny. Dokładny AIG B38M wygrywa z zastępczym FSLTL B738. Wpisy STUB mają niższy priorytet.

FSLTLU używa wygenerowanych profili wejść animacji, w tym ujemnego ciągu i stanu podwozia dla reversów. Niezapisywalne zmienne są wyłączane po błędzie SimConnect; zgodność wizualna wymaga testów na żywo. Import: `python tools/import_fsltl.py --source <lokalny klon Base>`; kontrola bez dostępu do addonu: `python tools/import_fsltl.py --check`.
