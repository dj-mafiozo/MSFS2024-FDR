# PMDG 777 — read-only SDK

[Interface translations](../../Translation.en.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


Source: official PMDG_777X_SDK.h, SHA-256 `3d0ecfb39fe7524a5017b63c7cb52f4d850b97f738ed5d4d8f1637afc1a676f7`. Catalog: 522 fields, 684-byte data block and 1009-byte CDU screen. ctypes and clang-cl /Zp8 static_asserts against the original header independently verified every offset/size. The proprietary header is a local reference, not a distributed payload.

Enable `[SDK] EnableDataBroadcast=1` and `EnableCDUBroadcast.0=1`, `.1=1`, `.2=1` in PMDG `777_Options.ini`. FDR does not modify it. It reads `PMDG_777X_Data` and `PMDG_777X_CDU_0/1/2` via SimConnect Client Data, initial ONCE plus ON_SET. No control/event writes.

Capture includes typed fields/performance references, three raw/styled CDUs, RGB/small/reverse/dim, power and EXEC/DSPY/FAIL/MSG/OFST lamps. Verified AP/FD/AT ARM, gear, MCP selections and fuel override generic values using SDK semantics. AT ARM/button lamps are not treated as active autothrottle servos. Unset zero V-speeds, unavailable negative distances and landing-altitude -32767 become null references. HDG/TRK and VS/FPA modes avoid overriding the wrong parameter. Changes are timestamped; identical packets are suppressed.

Regenerate with `tools/generate_pmdg777_catalog.py <local-header> --root <repo>`; compile generated `.build/VerifyPMDG777Layout.cpp` against that header. `VerifyPMDG777` uses a mock DLL/SQLite. Live-aircraft reception remains untested.
