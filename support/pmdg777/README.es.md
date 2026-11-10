# PMDG 777 — SDK de solo lectura

[Traducciones](../../Translation.es.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


Origen: PMDG_777X_SDK.h, SHA-256 `3d0ecfb39fe7524a5017b63c7cb52f4d850b97f738ed5d4d8f1637afc1a676f7`. 522 campos, bloque de 684 bytes y CDU de 1009 bytes. Todos los offsets/tamaños se verificaron con ctypes y static_assert independientes clang-cl /Zp8. No se distribuye el encabezado original.

Active `[SDK] EnableDataBroadcast=1` y `EnableCDUBroadcast.0=1`, `.1=1`, `.2=1` en `777_Options.ini`. FDR no modifica el archivo. Lee `PMDG_777X_Data` y los tres canales CDU mediante ONCE/ON_SET, sin enviar controles.

Se guardan campos/referencias SDK, tres CDU sin procesar y con formato RGB/letra pequeña/reverse/dim, alimentación e indicadores EXEC/DSPY/FAIL/MSG/OFST. AP/FD/AT ARM, tren, MCP y combustible verificados sustituyen los valores genéricos. AT ARM/luces no equivalen a servos A/T activos. V-speeds cero no definidos, distancias negativas no disponibles y altitud de aterrizaje -32767 se consideran referencias ausentes. Se respetan HDG/TRK y VS/FPA. Solo se almacenan cambios con timestamps.

Generador: `tools/generate_pmdg777_catalog.py <encabezado> --root <repo>`. C++ generado: `.build/VerifyPMDG777Layout.cpp`. `VerifyPMDG777` usa DLL simulada/SQLite; no hay prueba en vivo.
