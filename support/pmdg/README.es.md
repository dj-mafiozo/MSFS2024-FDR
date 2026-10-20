# SDK PMDG 737 NG3

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

PMDG 737 NG (-600/-700/-800/-900, BBJ/carga) selecciona PMDGNG3. No incluye PMDG 777, MAX ni otros fabricantes. El PMDG_NG3_SDK.h oficial proporcionado define 916 bytes de datos con 494 campos tras expandir arrays y 1009 bytes por CDU. Los bytes reservados no son telemetría. Se comprobaron pack(8), alineación máxima 4, tamaño y offsets con ctypes y de forma independiente con clang-cl. No se distribuye el encabezado propietario.

La conexión SimConnect independiente lee únicamente PMDG_NG3_Data y PMDG_NG3_CDU_0/1: ON_SET y un ONCE inicial. No mapea controles, escribe Client Data ni envía eventos de cabina. Un fallo del CDU no detiene los datos principales.

El archivo de opciones activo debe contener:

```ini
[SDK]
EnableDataBroadcast=1
EnableCDUBroadcast.0=1
EnableCDUBroadcast.1=1
```

El encabezado cita 737NG3_Options.ini; la instalación MSFS24 737-600 examinada usa `LocalState/WASM/MSFS2024/pmdg-aircraft-736/work/737_Options.ini`. Las opciones ya estaban activas y no se modificaron. Tras cambiarlas, recargue el avión.

V-speeds en kt: cero significa referencia sin seleccionar, aunque se conserva el valor bruto. Landing altitude -32767 indica ausencia; otras altitudes negativas pueden ser válidas. Distancias negativas TOD/destino no están disponibles; TOD=0 es válido. MCP respeta alimentación, guiones e IAS/Mach. Gear OFF se conserva como estado bruto 1 sin sustituir UP/DOWN. A/THR usa conexión real del servo y AP control pitch/roll, incluido CWS, sin afirmar CMD/LNAV/VNAV. El combustible SDK está en lb independientemente de WeightInKg. Los indicadores de flaps no se convierten en ángulos inventados; el FMC indica configuración prevista.

ON_SET no tiene heartbeat. El estado estable se conserva hasta el siguiente mensaje; data_update_age_ms es la edad del paquete, no prueba de una medición nueva. Pausa, cambio de avión y desconexión limpian cachés. La falta de datos principales provoca reconexión con esperas. Se guarda una base completa y después cambios; gráficos `PMDGNG3.<campo>`.

CDU: 24 columnas × 14 filas × símbolo/color/flags más powered; las columnas son la dimensión exterior. Se conservan texto, flechas y bytes originales. Una pantalla apagada no es referencia actual. Las páginas Boeing comparten provisionalmente el parser iFly/PMDG; falta la comparación real.

```text
python tools/generate_pmdg_catalog.py "ruta/PMDG_NG3_SDK.h"
```

Compile después; también se genera `.build/VerifyPMDGLayout.cpp`. VerifyPMDG prueba API, disposición, sentinelas, CDU, estado, historial y análisis con una DLL simulada. ProbePMDG permite lectura real opcional. En la inspección anterior el usuario volaba iFly y no se cambió su avión; los valores reales PMDG siguen pendientes.
