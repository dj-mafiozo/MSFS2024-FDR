# Utrzymanie projektu Delphi

- Przy dodawaniu lub usuwaniu jednostek aktualizuj równocześnie `src/MSFS2024-FDR.dpr` i wpisy `DCCReference` w `src/MSFS2024-FDR.dproj`. Formularze zachowują odpowiednie zasoby DFM i metadane formularza w DPROJ.
- Uruchamiaj `python tools/check_project.py`; kontrola jest również częścią `test.ps1`.
- Aktualizuj `Testy.md` po zmianie zakresu testów. Rozróżniaj testy na atrapach, próby na żywo, pominięte próby i ograniczenia. Nie opisuj niewykonanej próby jako zaliczonej.

- Po każdej zmianie kodu zwiększ tylko ostatnią składową Build we wspólnej konfiguracji Base (All Configurations) w DPROJ, raz na logiczny zestaw zmian. Użyj `python tools/bump_build.py`. Nie zmieniaj samodzielnie Major, Minor, Release ani ProductVersion i danych autora. Nie dodawaj nadpisań VerInfo w konfiguracjach/platformach. Sprawdzaj `python tools/check_version.py`.
