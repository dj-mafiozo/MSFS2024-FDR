# Niezależna weryfikacja layoutu SDK

[English](layout-verification.en.md)

Layout wygenerowanego katalogu porównano z ctypes oraz kompilacją oryginalnego nagłówka przez clang-cl z MSFS2024 SDK, opcja /Zp8. Wszystkie static_assert przeszły: sizeof(PMDG_NG3_Data)=916, sizeof(PMDG_NG3_CDU_Screen)=1009 oraz offset każdego oryginalnego pola.

SHA-256 nagłówka: 2ccc93f1d04bd52185a4bd04ed3e7eebf183059207ad4a27f481d1ea298e2609. To test binarnego layoutu, nie odbioru danych na żywo.
