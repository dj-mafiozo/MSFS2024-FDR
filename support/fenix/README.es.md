# Fenix A32X

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Los títulos con Fenix o FNX_32/FNX A32 seleccionan FenixA32X. Los demás aviones conservan SimConnect; iFly sigue utilizando su SDK. El catálogo contiene 1203 L-vars únicas extraídas de 2096 parámetros VAR_NAME* del Cockpit_Behavior.xml proporcionado. El manifiesto conserva contexto y SHA-256; no se distribuye el XML del fabricante.

TFenixReader abre una conexión SimConnect independiente de solo lectura: FLOAT64/number en lotes de 128, actualización SIM_FRAME y grabación al intervalo configurado en milisegundos. No requiere programas adicionales, WASM ni escrituras o comandos de cabina.

El primer estado es completo y los siguientes guardan cambios. Los gráficos usan `FenixLVar.<nombre>`. S_MIP_GEAR representa UP/DOWN; S_FC_FLAPS contiene posiciones de palanca 0–4, no ángulos reales ni una distinción fiable entre CONF 1 y 1+F. La animación de gases 0–5 no sustituye el porcentaje de empuje. Los pulsadores y luces AP/A-THR no demuestran un modo activo. Sin equivalencia verificada, posiciones del tren, contacto de ruedas, dinámica y meteorología siguen procediendo de SimConnect.

Los datos ausentes, erróneos o caducados producen null. Validez: max(1000, intervalo_ms)*3 ms; después de 30 s sin datos se intenta reconectar con esperas. Pausa, cambio de avión o desconexión invalidan la caché. Un cero recibido no demuestra que exista la L-var: SimConnect también puede devolverlo para nombres desconocidos. No se encontraron V1/VR/V2/VREF/VAPP numéricos directos en el catálogo. El texto completo del MCDU requiere un cliente FlightPadFMC actualizado y conectado: [protocolo](../flightpad/README.es.md).

Tras actualizar Fenix, regenere el catálogo y compile:

```text
python tools/import_fenix_catalog.py "ruta/Cockpit_Behavior.xml" support/fenix/variables.json
python tools/generate_fenix_catalog.py
```

VerifyFenix comprueba llamadas, detección, aislamiento de errores, valores nulos, historial, gráficos y análisis mediante una DLL simulada. Los valores reales requieren una sesión Fenix/MSFS activa; estas pruebas no validan todas las versiones reales.
