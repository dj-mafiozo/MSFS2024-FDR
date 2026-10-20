# FlyByWire A32NX

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Los títulos con A32NX o FlyByWire/FBW y A320 seleccionan FBWA32NX. Un A320 genérico o FBW A380 no coincide. El catálogo incluye 223 L-vars legibles de la documentación Flight Deck API proporcionada. Expande índices explícitos y excluye 26 entradas obsoletas o de solo escritura. Las referencias oficiales completan disponibilidad y unidades de velocidad. Se conserva el SHA-256 de origen; no se distribuye el HTML completo.

TAircraftLVarReader lee FLOAT64/number en grupos de 128 mediante una conexión independiente sin escrituras. SIM_FRAME proporciona actualizaciones y la base de datos sigue el intervalo FDR. Los fallos auxiliares no detienen la grabación principal. Los valores ausentes/caducados son null; recibir cero no demuestra que exista la variable. IS_READY=1 permite sustituciones de valores estándar y VAPP, pero no garantiza cada campo.

AUTOTHRUST_STATUS 0/1/2 indica desactivado/armado/activo. Los detentes 0/1/2/3/4 se convierten a MSFS 0/2/3/4/5; no son ángulos de superficie. La velocidad FCU respeta guiones e IAS/Mach. VAPP puede incluir una selección manual y no es VREF. Cero, datos antiguos o falta de disponibilidad no producen una referencia válida. Las luces de pulsadores AP no sustituyen al estado real del piloto automático.

Historial: estado inicial completo y cambios recursivos; gráficos `FBWLVar.<nombre>`. Cambio de avión, pausa y desconexión limpian la caché. Las referencias SDK verificadas tienen prioridad; las grabaciones antiguas no adquieren valores que nunca se registraron. El MCDU completo procede del [cliente FlightPadFMC](../flightpad/README.es.md) actualizado y conectado.

```text
python tools/import_fbw_catalog.py "A32NX Flight Deck API - FlyByWire Simulations Documentation.htm" support/fbw/variables.json
python tools/generate_fbw_catalog.py
```

Después hay que compilar. VerifyFBW usa una DLL simulada para detección, transporte, disponibilidad, flaps/A-THR, IAS/Mach, VAPP, errores, historial y análisis. Los valores reales requieren validación en el simulador. Referencia: https://github.com/flybywiresim/aircraft/blob/master/fbw-a32nx/docs/a320-simvars.md.
