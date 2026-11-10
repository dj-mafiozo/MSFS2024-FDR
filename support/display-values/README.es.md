# Auditoría de etiquetas de valores

[Aviso sobre traducciones](../../Translation.es.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

5118 campos tienen diccionarios, con 2313 incorporaciones. Se revisaron los encabezados SDK iFly, PMDG NG3 y PMDG 777 y 335 archivos XML de las variantes disponibles. Otros booleanos proceden de unidades XML explícitas ya inventariadas, incluidos Bell 407 y EC135.

`catalog.json` guarda etiquetas, reglas de extracción, referencias y SHA-256. No redistribuye XML ni encabezados SDK de los fabricantes. En ejecución solo se usan catálogos Pascal compilados. Los generadores conservan los metadatos mediante `apply_display_values.py`.

Se usan enums explícitos, ANIMTIP, asignaciones inequívocas de pulsación/liberación y booleanos tipados. Los comentarios iFly se leen como GB18030. No se adivinan posiciones intermedias, secuencias FO invertidas ni estados privados WASM. De 14 XML mal formados solo se recuperan fragmentos UseTemplate válidos. Las etiquetas no prueban la disponibilidad de datos en vivo.

Verificación: `test.ps1 -Tests VerifyCatalogSources,VerifyParameterValues`, `python tools/apply_display_values.py --check` y Delphi VerifyParameterValues. Sin nuevas pruebas en vivo.

## Índice de flaps estándar SimConnect

`FlapsHandleU.pas` tiene una selección ICAO separada con diccionario vacío por defecto. Fuentes: `flaps.json`; cobertura: [flaps-coverage.csv](flaps-coverage.csv). Generador: `python tools/generate_flap_profiles.py`, validación con `--check`.

156 códigos: 66 perfiles, 30 tipos sin flaps y 60 sin confirmar. No es una cobertura completa de todos los aviones predeterminados: sus configuraciones locales MSFS 2024 están cifradas. Se usaron 26 configuraciones de complementos, manuales del simulador y referencias de fabricantes. Los casos desconocidos mantienen números; no se han volado todos los perfiles.

A320 SimConnect tiene seis estados, incluido 1+F, y la palanca SDK cinco. Las variantes MD-11 TFDi/SkySim se distinguen por el título grabado. Una discrepancia en el número de posiciones desactiva el perfil; la coincidencia no garantiza ángulos idénticos en otras modificaciones. Las etiquetas representan posiciones nominales, no deflexiones medidas.
