# Valores SDK de GSX Pro grabados

[Traducciones de la interfaz](../../Translation.es.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Telemetry/GSXVarsU.pas lee 16 L-vars numéricas mediante SimConnect MSFS24, independientemente del avión. Cada una tiene definición/petición propia; un campo ausente no bloquea otros. No utiliza puente WASM, comandos de control ni escrituras.

El catálogo incluye estados de embarque/desembarque/catering/repostaje/salida/deshielo, FSDT_VAR_Frozen para congelación GSX durante pushback (no pausa del simulador), contadores actuales/totales de pasajeros, actividad/progreso de carga en ambos sentidos y código bruto de líquido antihielo. Los contadores actuales pueden reiniciarse por autobús; el porcentaje de carga se promedia entre cargadores. El manual actual usa FSDT_GSX_DEICE_STATE, no el antiguo DEICING_STATE.

Estados: 1 invocable, 2 no disponible, 3 omitido, 4 solicitado, 5 activo, 6 completado. Cero no demuestra presencia de GSX ni un servicio válido: una L-var ausente también puede devolverlo. Estados de transporte: received_not_verified, partial o unavailable. Datos ausentes/erróneos son null; los de más de tres segundos dejan de ser actuales.

La base completa y sus cambios se guardan como gsx_lvars en trip_aircraft_data, asociados a muestra/hora. Los estados idénticos no se duplican. La reproducción expone GSX.* en gráficos/inspector manteniendo huecos; el análisis recibe definiciones y reconstrucción. La grabación cubre carga a fin del vuelo, embarque antes de motores y desembarque tras apagarlos. La pausa no termina el vuelo. Los contadores no sustituyen masa, carga útil ni combustible medidos del avión.

Es un catálogo inicial de servicios/contadores, no todas las variables ni estados de vehículos. Fuente: manual oficial GSX, DEVELOPERS — Interfacing with GSX, páginas 106–108 de 291; se encontraron los 16 nombres. SHA-256 PDF: ee4ae760168e7045d3598905d3e1b4a3ccb56337fdb50586e7456c3dc4feafc1. No se distribuye el manual propietario. VerifyGSX usa SimConnect simulado; los valores reales siguen sin validación en vivo.
