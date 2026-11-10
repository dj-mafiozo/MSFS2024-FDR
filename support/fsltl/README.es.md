[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

[Translation notice](../../Translation.es.md)

# Perfiles de modelos FSLTL y AIG

El catálogo solo contiene datos de parámetros, códigos ICAO, commit y hashes. No se distribuyen modelos, texturas ni XML de FSLTL. Al iniciar, un inventario en segundo plano lee las configuraciones Community instaladas. El tipo y la librea tienen prioridad; los empates favorecen FSLTL, después AIG y los modelos predeterminados. Un AIG B38M exacto supera al sustituto FSLTL B738. Las entradas STUB tienen menor prioridad.

Los perfiles incluyen empuje negativo y estado en tierra para las reversas. Los SimVars no escribibles se desactivan tras un error. Falta validar la representación en vivo. Comprobación: `python tools/import_fsltl.py --check`.
