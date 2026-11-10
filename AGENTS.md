# Utrzymanie projektu Delphi

- Przy dodawaniu lub usuwaniu jednostek aktualizuj równocześnie `src/MSFS2024-FDR.dpr` i wpisy `DCCReference` w `src/MSFS2024-FDR.dproj`. Formularze zachowują odpowiednie zasoby DFM i metadane formularza w DPROJ.
- Uruchamiaj `python tools/check_project.py`; kontrola jest również częścią `test.ps1`.
- Aktualizuj `Testy.md` po zmianie zakresu testów. Rozróżniaj testy na atrapach, próby na żywo, pominięte próby i ograniczenia. Nie opisuj niewykonanej próby jako zaliczonej.

- Po każdej zmianie kodu zwiększ tylko ostatnią składową Build we wspólnej konfiguracji Base (All Configurations) w DPROJ, raz na logiczny zestaw zmian. Użyj `python tools/bump_build.py`. Nie zmieniaj samodzielnie Major, Minor, Release ani ProductVersion i danych autora. Nie dodawaj nadpisań VerInfo w konfiguracjach/platformach. Sprawdzaj `python tools/check_version.py`.

- Każdy nowy test/sondę/atrapę z `tests/*.dpr` rejestruj w `tests/Tests.groupproj` przez `python tools/sync_test_projects.py`. Testy Verify używają `TestPathsU` jako pierwszej jednostki i izolowanych baz; zachowuj wspólne ustawienia `Tests.Shared.props`.

- Aktualizuj `changelog.md` przy zmianach zachowania aplikacji. Grupuj zmiany wyłącznie według wersji wydania `Major.Minor.Release` (np. `0.1.1`), od najnowszej. Nie dodawaj numerów Build, osobnych wpisów dla buildów ani informacji, w którym buildzie pojawiła się zmiana. Kolejne zmiany w tym samym wydaniu dopisuj do istniejącej sekcji. Nie odtwarzaj niepotwierdzonej historii wydań.

- Numeracja historii wydań: initial Preview, następnie `0.1.0`, `0.1.1` i kolejne; obecnie przygotowywane wydanie to `0.1.1`. Numeru wydania w changelogu nie wyprowadzaj automatycznie z bieżącego VersionInfo EXE. Wpisy historyczne potwierdzaj tagami i commitami Git.

- Aktualizuj angielski `CHANGELOG.en.md` razem z polskim `changelog.md`, zachowując numerację wydań bez buildów. Prywatne `../setup-core/src/ZipPasswordU.pas` i `congratulations.mfz` nie mogą trafić do Git ani archiwów źródeł; nie wypisuj hasła ani nie przekazuj go argumentem procesu. Paczki FDR portable twórz bez hasła przez tools/package_flightsim.py; prywatny szyfrujący packager dotyczy osobno rozwijanego instalatora.

- Instalator: `../MSFS2024-FDR-Setup/src/MSFS24-FDR-Setup.dproj`; jego osobne formularze pozostają w DFM. Prywatny zaszyfrowany `private.pem` przechowuj poza repozytorium i nie umieszczaj hasła w argumentach ani logach. Publiczny `public.pem` jest wyłącznie wejściem kompilacji do `UpdatePublicKey.inc`; weryfikacja w EXE nie może odczytywać klucza z pliku. Po rotacji przebuduj Setup i PackageRelease.

- Wspólny host autoupdate: `../setup-common/src` (MIT). Kreator i instalacja: `../setup-core/src` (osobna licencja). Nie dodawaj zależności setup-common od setup-core ani kodu MSFS do wspólnych modułów. Formularz produktu dziedziczy DFM formularza bazowego.

- `VersionU` pochodzi wyłącznie z submodułu `src/Common/VersionU.pas`; nie odtwarzaj kopii w `src/Core`. Przy klonowaniu inicjalizuj submoduły.

- W repozytoriach obok (`setup-core`, `setup-common`, `MSFS2024-FDR-Setup`, `Common`) każdą zakończoną logiczną zmianę commituj lokalnie; bez push bez osobnego polecenia. Nie twórz pustych commitów w niezmienionych repozytoriach.

- ZipPasswordU.pas, ZipPassword-ExampleU.pas i congratulations.mfz należą do setup-core i jego własnej licencji. Prywatna implementacja i congratulations.mfz pozostają ignorowane przez Git.

- Changelog FDR opisuje wyłącznie aplikację i portable/stub; historia osobno rozwijanego instalatora należy do jego repozytorium. Nie dodawaj informacji o terminach upublicznienia zależności. Wersjonuj źródła RC, nigdy RES.

- Ikonę, VersionInfo i standardowy manifest generuje MSBuild Delphi z DPROJ. Nie dubluj ich we własnych RC ani nie nadpisuj wygenerowanego RES. RC służą dodatkowym zasobom (np. flagom i18n), budowanym przez tools/build_resources.py --vendor. Aplikację i stuba buduj przez DPROJ. Szczegóły: docs/resource-build.en.md.

## Formatowanie przed kompilacją

- Przed każdą kompilacją aplikacji, stuba, testów lub projektów należących do grup uruchom z katalogu głównego repozytorium:

  ```powershell
  & .\Tools\Formatter\Format_MSFS24-FDR.exe /nogui
  ```

- To samodzielny formatter autora, korzystający z jego silnika i wbudowanego zaszyfrowanego profilu. Formatuje całą grupę `MSFS24 Flight Data Recorder.groupproj` oraz `tests/Tests.groupproj`; nie zastępuj go innym formatterem ani własnymi regułami formatowania.
- Parametr `/nogui` wyłącza końcowy raport w MsgBox. Obsługa przekazywania statusu przez stdout jest rozwijana w osobnej instancji; dopóki nie zostanie dostarczona, brak stdout nie oznacza błędu ani potwierdzenia sukcesu. Poczekaj na zakończenie procesu; zgłoszony błąd formatowania popraw przed kompilacją.
- Po zmianach kodu lub regeneracji katalogów najpierw zadbaj o znaczniki poniżej, następnie uruchom formatter, przejrzyj jego zmiany i dopiero kompiluj. Pamiętaj, że formatter obejmuje obie całe grupy, a nie wyłącznie edytowany unit.

## Tablice i katalogi — znaczniki FLD

- Wszystkie inicjalizowane deklaracje tablic, zwłaszcza katalogi rekordów i tablice stringów, muszą być otoczone dokładnie znacznikami `{ FLD+ }` oraz `{ FLD- }`, każdy w osobnym wierszu.
- `{ FLD+ }` umieszczaj w wierszu bezpośrednio przed `Const` rozpoczynającym taki blok; `{ FLD- }` bezpośrednio po zakończeniu deklaracji, za końcowym średnikiem. Obejmuj cały inicjalizator, wszystkie rekordy/elementy i zamykające nawiasy. Jeżeli blok zawiera kilka powiązanych tablic lub stałe rozmiaru/hash katalogu, można otoczyć całą tę grupę jednym zestawem znaczników.
- Ta sama zasada dotyczy tablic inicjalizowanych poza `Const` oraz przypisań tablic w kodzie: otaczaj całe przypisanie od wiersza przed instrukcją aż do wiersza po jej końcowym średniku.
- Reguła obejmuje także generowane katalogi, pliki include i kod testów. Generatory mają emitować znaczniki, tak aby ponowna generacja ich nie usuwała. Nie zamieniaj `{ FLD+ }` / `{ FLD- }` na `{ F- }`, `{ F+ }` ani komentarze o innym zapisie.

Przykład katalogu rekordów:

```pascal
{ FLD+ }
Const
 Catalog : Array [0..1] Of TSomething =
  (
   (Name: 'First';  Kind: 'Kind'; Description: 'First description'),
   (Name: 'Second'; Kind: 'Kind'; Description: 'Second description')
  );
{ FLD- }
```

Przykład tablicy stringów:

```pascal
{ FLD+ }
Const
 Names : Array [0..1] Of String = ('str1', 'str2');
{ FLD- }
```

Przykład przypisania w kodzie:

```pascal
{ FLD+ }
Names := TArray<String>.Create('str1', 'str2');
{ FLD- }
```

- Konfiguracja produktu instalatora (FDRSetupProductU.pas) i jego klucz (FDRUpdatePublicKey.inc) należą wyłącznie do ../MSFS2024-FDR-Setup/src. Nie dodawaj ich do src/Core ani zależności nieaktywnego updatera do aplikacji portable. Mutex aplikacji utrzymuje AppPathsU.

- Testy regresyjne pisz w DPR na DUnitX; nie dodawaj testów *.py do tests. Narzędzia Python można testować przez CLI z natywnymi asercjami i izolowanymi danymi. Mocki/proby wymagające osobnego protokołu mogą pozostać samodzielne. Każdy DPR ma DPROJ oraz wpis w Tests.groupproj. Usuwaj testowe MAP/RSM po przebiegu.
- Nie wpisuj bezwzględnych ścieżek użytkownika ani dysku instalacji toolchainu w skryptach i projektach. Używaj parametrów, BDS/MSFS_SDK/PATH i wykrywania rejestru; repozytoria pomocnicze domyślnie szukaj względem repo. Stałe ścieżki w danych negatywnych testów bezpieczeństwa są wyłącznie wektorami testowymi.

- Pomoc: po zmianie UI odśwież lokalizowane zrzuty przez tools/capture_help.ps1; dokumentuj wszystkie opcje w help/manual.*.txt (PL/EN/DE/ES). Pilnuj HelpContext w DFM i aliasów w tools/generate_help.py. Zachowaj istniejące ID. CHM ma drzewo tematów bez globalnego paska linków i zrzuty zgodnego języka. Release zawiera wyłącznie CHM; package_flightsim.py wymusza przebudowę i sprawdza świeżość źródeł/obrazów.

