# Historial de pantallas FMC/MCDU

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

TFMCScreen contiene TStringList Lines: 14 filas de 24 caracteres con espacios y CRLF. FireDAC desactiva StrsTrim. iFly proporciona texto/glifos, colores/fuentes compactados, HTML y luces CDU; PMDG usa Client Data CDU; Fenix/FBW necesitan el [cliente FlightPadFMC](../flightpad/README.es.md) actualizado. El brillo no demuestra alimentación y las L-vars numéricas no sustituyen al texto.

trip_fmc_screens guarda cada cambio de texto, disponibilidad, alimentación o presentación con trip/sample, hora de simulación y recepción UTC, provider/device, clave de página, raw_text y parsed_json. Omite estados idénticos. Power: -1 desconocido, 0 apagado, 1 encendido. Número de página y MOD/TMPY permanecen separados sin sustituir referencias ejecutadas.

El búfer previo conserva 4096 cambios y aparte el último estado de cada página. Se asocia al vuelo transaccionalmente con sus tiempos originales; sample=0 indica observación sin muestra de telemetría existente. La grabación de sesión actual también cubre el vuelo cargado antes del arranque. Cambio de avión, parada y desconexión limpian la caché; cerrar sin vuelo pierde el búfer en memoria.

El análisis selecciona la última pantalla, página y valores anteriores al evento en todo el historial, por dispositivo, incluso fuera del intervalo de análisis. Excluye observaciones futuras. Las páginas ocultas son últimas observaciones, no lecturas continuas de memoria FMC. Valores vacíos o ambiguos producen null. MOD/TMPY no se trata como referencia activa ejecutada. Las referencias SDK tipadas tienen prioridad.

Boeing: PERF INIT, N1 LIMIT, TAKEOFF REF y APPROACH REF; V1/VR/V2 seleccionados en lugar de QRH, FLAP/SPD en lugar de una fila VREF arbitraria y corrección de viento separada. iFly/PMDG comparten provisionalmente parser. Airbus: INIT/PERF, VAPP/VLS, FLEX, flaps/THS, altitudes y mínimos; VLS no es VREF y los pesos sin unidades confirmadas permanecen como texto. Las claves técnicas están en Boeing-performance.md, Airbus-MCDU.md e IFly-display-storage.md.

La aplicación no navega ni pulsa teclas. Muestre las páginas durante la preparación; transiciones inferiores al intervalo pueden omitirse. Se vuelven a interpretar pantallas antiguas para el contexto sin sobrescribir su registro. VerifyFMC/VerifyBoeingFMC/VerifyAirbusMCDU/VerifyIFlyDisplays son sintéticos. La prueba opcional anterior de iFly devolvió SDK state=0; no confirma recepción real completa.
