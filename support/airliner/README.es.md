# Variables comunes de instrumentos AIRLINER

[Traducciones de la interfaz](../../Translation.es.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Los 31 nombres *AIRLINER* catalogados son L-vars de instrumentos, leídas como `L:<nombre>` mediante SimConnect_AddToDataDefinition, no SimVars estándar A:. Proceden de 149 archivos de instrumentos instalados (Asobo A320/737 MAX/747/787/CJ4 y FBW/FSS/LVFR). AIRLINER puede aparecer como prefijo o en medio. Esto no valida todos los valores Carenado ni los nombres generados dinámicamente.

| Nombre | Significado |
|---|---|
| AIRLINER_V1_SPEED | V1, kt |
| AIRLINER_VR_SPEED | VR, kt |
| AIRLINER_V2_SPEED | V2, kt |
| AIRLINER_MINIMUM_DESCENT_ALTITUDE | MDA, ft |
| AIRLINER_DECISION_HEIGHT | DH, ft |

Otros campos incluyen VREF/VX/velocidad de aproximación y green-dot, fase, altitudes de crucero/reducción/aceleración/transición, FLEX, flaps, modos de empuje y TOC/TOD. catalog.json conserva nombres, variantes de unidades, fuentes y SHA-256. Las equivalencias están en Telemetry/AirlinerCatalogU.pas.

La conexión SimConnect independiente de lectura usa una definición/petición por variable. Un error no bloquea otros campos ni la grabación principal. Respuesta ausente, NaN, error o dato caducado produce null. Cambio de avión, pausa y parada de simulación reinician el lector. Un cero recibido no prueba existencia: el estado sigue siendo received_not_verified. Velocidades positivas menores de 400 kt pueden ser candidatos de referencia expresamente no verificados; cero/negativos no se convierten en V-speeds. Las referencias SDK/FMS verificadas del avión tienen prioridad.

`TFlightSample.AirlinerData` se guarda como `airliner_lvars` en trip_aircraft_data con muestra/hora: base completa y después cambios. Los gráficos usan `AirlinerLVar.` y huecos para null; el análisis recibe datos reconstruidos y airliner_lvar_definitions. No se envían comandos de cabina.

Para regenerar, pase los archivos encontrados con `rg -l -i airliner <paquetes> -g '*.js' -g '*.xml' -g '*.html'` a tools/import_airliner_catalog.py y compile. El importador extrae nombres numéricos literales de Get/SetSimVarValue/XML, no nombres dinámicos ni programas del fabricante. tools/check_airliner_catalog.py compara manifiesto y Pascal. VerifyAirliner prueba 31 peticiones, errores, sentinelas, historial delta, gráficos y análisis con una DLL simulada; sigue pendiente validar los valores reales.
