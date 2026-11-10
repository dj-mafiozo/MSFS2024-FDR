# PMDG 777 — SDK im Nur-Lese-Modus

[Übersetzungen](../../Translation.de.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


Original: PMDG_777X_SDK.h, SHA-256 `3d0ecfb39fe7524a5017b63c7cb52f4d850b97f738ed5d4d8f1637afc1a676f7`. 522 Felder, Datenblock 684 Byte, CDU 1009 Byte. Alle Offsets/Größen wurden mit ctypes und unabhängigen clang-cl-/Zp8-static_asserts geprüft. Der Originalheader wird nicht verteilt.

In `777_Options.ini`, `[SDK]`, `EnableDataBroadcast=1` sowie `EnableCDUBroadcast.0=1`, `.1=1`, `.2=1` einschalten. FDR verändert diese Datei nicht. Gelesen werden `PMDG_777X_Data` und drei CDU-Kanäle mit ONCE/ON_SET, ohne Steuerbefehle.

Erfasst werden SDK-Werte/Leistungsreferenzen, drei rohe/formatierte CDUs, RGB/kleine Schrift/Reverse/Dim, Stromstatus und EXEC/DSPY/FAIL/MSG/OFST. Verifizierte AP/FD/AT-ARM-, Fahrwerks-, MCP- und Treibstoffwerte ersetzen Standardwerte. AT ARM/Lampen sind kein Nachweis aktiver A/T-Servos. Nicht gesetzte V-speeds (0), negative ungültige Entfernungen und Landehöhe -32767 werden als fehlende Referenz behandelt. HDG/TRK und VS/FPA bleiben semantisch getrennt. Nur Änderungen mit Zeitstempel werden gespeichert.

Generator: `tools/generate_pmdg777_catalog.py <Header> --root <Repo>`. Generierte C++-Prüfung: `.build/VerifyPMDG777Layout.cpp`. `VerifyPMDG777` verwendet DLL-Attrappe/SQLite; kein Live-Test.
