# Pruebas — MSFS2024-FDR

[Polski](Testy.md) | [English](Testy.en.md) | [Deutsch](Testy.de.md) | [Español](Testy.es.md)

Tras la última corrección volvieron a pasar VerifyDetachedViews, VerifyChartsConfigure, VerifyLocalization y VerifyUI. Se añadió orden inverso de cierre, conservación de etiqueta de intervalo al cambiar idioma, aislamiento de rueda separada respecto a la principal y comparación PNG independiente de los 43 iconos.


## Estado actual: vistas independientes y acciones

Han pasado 35 programas Delphi. También pasan cuatro controles de metadatos: check_project.py, check_translations.py, check_airliner_catalog.py y check_documentation.py. El control documental se ejecuta adicionalmente después de crear traducciones. Debug y Release Win64 se comprueban con DPROJ/MSBuild; script de compilación y paquetes forman parte de la validación de entrega. Informes antiguos de 33/34 programas, generador JSON o DE/ES desactivados describen versiones históricas.

Se utilizan bases aisladas y simulaciones HTTP/SimConnect/IPC locales, no la base privada del usuario. PORT_TEST evita grabación real del simulador. Compartir memoria Windows real con un emisor simulado no equivale a probar el avión. Un contrato HTTP correcto tampoco valida la calidad del análisis IA.

## Reproducción

```powershell
python tools/check_project.py
python tools/check_translations.py
python tools/check_airliner_catalog.py
python tools/check_documentation.py
powershell -ExecutionPolicy Bypass -File test.ps1
```

Se necesita Delphi 10.2. La ejecución completa recompila; MockFlightPad32 Win32 comunica con el grabador Win64. i18n y WebView4Delphi se resuelven desde proyecto vecino o vendor. DCU de prueba separadas en .build/Win32/Tests y .build/Win64/Tests. Ejemplo de subconjunto:

```powershell
& ./test.ps1 -Tests @('VerifyDetachedViews','VerifyChartsConfigure','VerifyLocalization','VerifyUI')
```

## Cobertura por programa

| Programa | Comprobación |
|---|---|
| VerifyPort | Esquema SQLite, campos/flags/motores, eventos, contactos, KML y grupos. |
| VerifyLegacy | Migración transaccional de snapshots antiguos, copia, motores y corrección horaria única. |
| VerifyUI | DFM, acciones/diálogos reales, más de ocho gráficos, orden/cancelación, tiempo, grids de lectura y distribución. |
| VerifyDiagnostics | Log persistente de errores y cabecera de minidump Windows legible. |
| VerifyFlightPlan | PLN EPMO/EPLL, DMS, JSON GET_EFB_ROUTE, puente local, revisiones y deduplicación. |
| VerifyAnalysis | Tarea en polaco, selección de proveedor y contrato sin modelo de producción. |
| VerifyContext | Intervalos antes/después, cronología, deltas, AP/AT/tren/meteorología y exclusión del futuro. |
| VerifyReport | Markdown/escape HTML, cierre real, títulos despegue/aterrizaje, cambio de idioma y título OFP. |
| VerifyMetar | Hora de evento, estación/UTC, respuestas/errores y guardado con fixtures locales. |
| VerifyChartView | Viewport con origen temporal, cursor, arrastre/desplazamiento, selección inversa, Ctrl+rueda y reset. |
| VerifyAircraftSDK | Memoria compartida iFly, 2411 campos, detección, unidades/prioridad, deltas y reconexión. |
| VerifyFenix | 1203 L-vars con SimConnect simulado, lotes 128, valores inválidos/nulos/caducados y aislamiento. |
| VerifyFBW | 223 L-vars, disponibilidad, flaps, A/THR, IAS/Mach/guiones y VAPP. |
| VerifyPMDG | ID/disposición Client Data, decodificación, sentinelas, Gear OFF, MCP y CDU por columnas. |
| VerifyFMC | Texto 14×24, Unicode/glifos/CRLF, string DB exacto, páginas/MOD, preflight y límites temporales. |
| VerifyFlightPad | IPC real Win32/Win64 con MockFlightPad32, perfiles/PID, heartbeat, UTF-16 y fallos. |
| VerifyAirbusMCDU | Parser INIT/PERF Fenix/FBW: VAPP/VLS, FLEX, THS, altitudes, meteorología y mínimos sin adivinar unidades. |
| VerifyOllama | Chat HTTP local, tarea UTF-8, contexto, Markdown, respuestas incompletas, límite y cancelación. |
| VerifyOllamaModels | GET tags, orden/duplicados, listas vacías/erróneas, cambio URL y cierre asíncrono. |
| VerifyTripInfo | Avión seleccionado, recuentos, duración abierta/finalizada, METAR/FMC, actualizar y solo lectura. |
| VerifyPrecision | Tres decimales, banda ±0,0015 frente al último estado emitido, null y ruido de redondeo. |
| VerifyAirliner | 31 peticiones L-var separadas, aislamiento, sentinelas nulos, historial, gráficos y análisis. |
| VerifyGroundWeather | Última muestra en tierra de despegue/primera de aterrizaje, exclusión de rebotes, vuelo completo y sin sustitución silenciosa. |
| VerifySimBrief | Coincidencia offline vuelo/ruta/fecha, planes antiguos opcionales con evidencias, OFP y rechazos. |
| VerifySimBriefUI | 15 grupos VCL, vista EPLL–EGLL, plegado, scroll global, altura memo, vista estrecha y ventana independiente. |
| VerifyGSX | 16 variables de lectura, null/error/caducidad, deltas, huecos de reproducción y definiciones. |
| VerifySession | Vuelo cargado hasta fin, motores apagados, pausa/stop/menú/cambio de avión y sin inicios duplicados. |
| VerifyFSHud | Handshake de panel sintético, tramas/filtros, nueve tipos, tiempos/deduplicación y límites de análisis. |
| VerifyRecorderWorker | DB/lectores del worker, cola de comandos, copias de estado y cierre sin bloqueo VCL por grabación. |
| VerifySimBacklog | 1000 paquetes se reducen a cinco callbacks conservando última hora y tres transiciones en tierra. |
| VerifyBoeingFMC | V1/VR/V2/VREF seleccionadas, FLAP/SPD, ACT/SEL, derate/bump, N1, CG/trim y PERF INIT. |
| VerifyIFlyDisplays | Indicadores numéricos ensamblados, vacío/signo/IRS, colores/fuentes/HTML FMC y luces CDU. |
| VerifyLocalization | PL/EN/DE/ES, acciones de menú reales, formularios/frames, guardar/cancelar ajustes, hilos y formato numérico. |
| VerifyChartsConfigure | ActionList/ImageList propios, copia de selección, filtro/orden/ocultar, aceptar/cancelar e iconos alfa. |
| VerifyDetachedViews | Mismos frames mapa/gráficos, separación simultánea, retorno por acción/cierre, intervalo/cursor/vuelo, rueda, idioma y cierre principal. |


## Detalles de la revisión actual de interfaz

VerifyDetachedViews abre dos vuelos sintéticos con tiempos distintos, separa ambas vistas y compara identidad de objetos y zoom. Un clic del gráfico mueve la línea temporal principal; cambiar esta actualiza el estado sincronizado. Rueda/desplazamiento/zoom y cambio de vuelo se prueban con el frame separado. El botón real de configuración abre el diálogo modal; un temporizador verifica sus iconos propios y ejecuta aCancel. Cambiar idioma actualiza títulos independientes. Se prueban distintos órdenes de cierre, repeticiones y destrucción de la principal con ambas ventanas abiertas. Se conservan altura y splitter sin crear vistas sustitutas.

VerifyChartsConfigure comprueba tres iconos/cinco acciones propios, activación en límites de lista, filtro sin perder marcas, preferencias de parámetros ausentes, orden, ocultación, copia hasta aceptar y cancelación sin aplicar. La comparación PNG usa dibujo VCL independiente sobre RGB(123,151,179), tolerancia 3 por canal; las franjas oscuras BMP siguen opacas. No se eliminan todos los píxeles negros. Los recursos alfa son reproducibles en DFM.

El control de proyecto exige cada unidad en DPR/DPROJ, recursos de formulario/frame y salidas .build. El catálogo exige cuatro idiomas, argumentos Format, Unicode, unicidad y componentes DFM existentes. El control documental exige las cuatro versiones de cada README propio y Testy con navegación válida. No reescribe fuentes ajenas, documentos SDK, licencias ni carpetas de compilación.

## Artefactos y límites

Log: tests/verification.log; las capturas generadas se revisan localmente y no son datos de producción. Los paquetes incluyen fuentes, DFM, catálogo externo, dependencias/licencias y configuración segura sin DB privada, credenciales ni estado local del IDE. La inspección Win64 confirma ausencia de dependencias Qt. WebView2 se carga dinámicamente para informes HTML.

Observaciones reales anteriores: FSHud 2.1.200 entregó nueve tipos y la ruta de prueba EPLL, pero no fue un vuelo completo ni prueba de fallos. La consulta iFly mostró SDK state=0, sin recepción real de pantalla confirmada. PMDG no se probó en vivo porque el usuario volaba iFly; no se cambió su avión. GSX y valores Fenix/FBW requieren validación real adicional. Se analizaron archivos PLN EPMO/EPLL proporcionados, pero el EFB no guarda PLN automáticamente. Las pruebas no terminan vuelos activos del usuario.

No se realizó una sesión de vuelo real nueva ni consulta IA de producción para este cambio. Siguen pendientes diferencias de versión de avión, límites completos de fin de sesión, pistas complejas/viento cruzado, existencia individual de L-vars y calidad de modelo. Un cero recibido puede indicar variable ausente; los valores faltantes/caducados permanecen explícitamente null o no verificados.

## VerifyGroups — 2026-10-18

`VerifyGroups` comprueba filtros de grupos, entrada vacía y ausencia de selección sin filtro, conservación al actualizar, grupo actual en bsDialog, Aceptar/Cancelar, asignación y eliminación de asignación y grupos vacíos. Utiliza SQLite sintético y formularios VCL reales, sin simulador. El formulario figura en DPR/DPROJ (60 unidades) con cuatro traducciones. La suite completa incluye ahora 36 programas Delphi y cuatro comprobaciones de metadatos.

## Toolbar frames — 2026-10-18

Las acciones e ImageLists de las barras pertenecen ahora a fraMap/fraGraph y se guardan en sus DFM. El menú principal utiliza las mismas acciones; main conserva referencias y el cambio de ventanas. El frame de gráficos controla el zoom. En ventanas separadas, btnGraphWindow y btnMapWindow devuelven el mismo frame a frmMain. Los índices de iconos siguen siendo compatibles con el menú principal. También se corrigieron propiedades DFM de TFrame y entradas uses inválidas de la configuración de gráficos.

VerifyDetachedViews comprueba además la propiedad de ActionList/ImageList, acciones compartidas entre menú y frames, zoom local y clics reales en ambos botones de retorno. Se repitieron VerifyUI, VerifyLocalization, VerifyChartsConfigure, VerifyGroups y cuatro verificaciones de metadatos. Son pruebas sintéticas VCL/SQLite sin simulador. Referencias locales evitan un fallo de generación de código de Delphi 10.2 Win64 con propiedades anidadas repetidas en los argumentos de llamadas.

## MSBuild / Delphi 10.2 — 2026-10-19

Corrección de compatibilidad con el IDE de Delphi 10.2: se eliminó AfterTargets de DeployTranslations y se añadió el destino a BuildDependsOn y MakeDependsOn después de los imports. Las verificaciones anteriores con MSBuild 4 no cubrían el parser antiguo del IDE. check_project.py rechaza BeforeTargets/AfterTargets y comprueba ambas cadenas. Verificados Build y Make Win64 y los catálogos bin/translations idénticos. Sin prueba manual en el IDE.

El esquema MSBuild 2.0 aceptó el destino corregido y rechazó AfterTargets, reproduciendo el error del IDE. Se restauró `OllamaAnalysisU` en frmSettingsU. Build Debug, Make Debug y Build Release Win64 pasaron; los registros confirman DeployTranslations.

## Unit scope names — 2026-10-19

Scopes de Delphi 10.2: Winapi ya figuraba en Base, pero el IDE no resolvió Windows en i18nLocalizer. Se añadieron listas completas explícitas a ambos grupos Windows y Debug/Release Win32/Win64, sin depender solo de Base. No se modificaron las fuentes instaladas de i18n. check_project.py comprueba Winapi/System/Vcl/Xml/Data. Verificados Build Debug/Release y Make Debug Win64 y los argumentos -NS de dcc64. Sin compilación manual en el IDE.

## TFrame DFM — 2026-10-19

Corregidos los DFM de fraMap/fraGraph: ClientHeight/ClientWidth sustituidos por Height/Width; eliminados OldCreateOrder, PixelsPerInch y TextHeight. Ambas vistas heredan directamente de TFrame; la localización se inicia tras asignar Parent y Translator mantiene los cambios de idioma. Se conservan dimensiones, diseño y nombres actuales (btnChartsConfigure). Las verificaciones rechazan propiedades de formulario en DFM de frames y comprueban anotaciones TFrame en DPR; aceptan namespaces heredados del IDE. Una prueba negativa detectó los DFM originales inválidos. Repetidos VerifyDetachedViews, VerifyLocalization y VerifyUI con VCL/SQLite sintético sin MSFS, incluyendo creación, separación/retorno e idiomas. Compilados Debug/Release Win64. Sin prueba manual del diseñador IDE.

También se reprodujo Windows not found: los ajustes DCC estaban después de CodeGear.Delphi.Targets. Se movieron los grupos antes del import sin cambiar valores; BuildDependsOn/MakeDependsOn permanecen después. Añadida comprobación del orden en check_project.py.

## Linear charts — 2026-10-19

Los gráficos unen las muestras adyacentes mediante segmentos rectos. Eliminados el tramo horizontal antes de cada cambio y la prolongación del último valor hasta el borde derecho. Repetidas VerifyChartView y VerifyUI: zoom, desplazamiento, selección, cursor y creación VCL. Pruebas sintéticas sin MSFS; compilaciones Debug/Release Win64.

## About / menu / CHM — 2026-10-19

Añadida VerifyHelpAbout: esquina transparente de icono de 16px sobre fondo de color, 34 índices estables, seis entradas ocultas con Action=nil y restauradas al enlazarlas, About modal mediante aAboutExecute, cierre e idiomas PL/EN/DE/ES, contextos de mapa/gráficos y cuatro CHM. WM_HELP abrió el visor HTML Help real y la prueba lo cerró. Capturadas e inspeccionadas pantallas VCL con datos sintéticos. Compilados cuatro CHM con seis temas cada uno; HHC requiere índices en codificación Windows y un entorno temporal aislado. Repetidas VerifyDetachedViews, VerifyLocalization, VerifyChartsConfigure, VerifyUI y cuatro verificaciones de metadatos. Suite predeterminada: 37 programas Delphi; ejecutados cinco en este cambio, sin MSFS. Verificadas compilaciones Debug/Release Win64 y paquetes.

## Parameter names — 2026-10-19

Añadida VerifyParameterNames: 212 nombres SimConnect, unidades incluido 0–1, índices de motor y arrays desde 0, catálogos iFly/Fenix/FBW/PMDG/AIRLINER, cuatro idiomas y búsqueda por nombre/ID. Dos ID distintos con etiqueta idéntica verifican orden, ocultación y selección y conservación de preferencias de otros aviones. Las claves de modelo/base siguen originales tras obtener etiquetas. Repetidas VerifyChartsConfigure, VerifyChartView, VerifyLocalization, VerifyUI, VerifyHelpAbout y VerifyAircraftSDK; repetidas pruebas de nombres/UI tras AIRLINER/GSX/FSHud. Ocho programas Delphi y cuatro controles de metadatos, datos sintéticos/mock sin MSFS. Suite predeterminada: 38 programas; no se repitió toda la suite. Capturas README actualizadas. Verificados Debug/Release Win64 y paquetes.

Integrados el diseño actual de dos paneles y sus dimensiones guardadas durante el trabajo. Conectados Mover al principio/final y Mostrar gráfico y verificados sus ID originales. Eliminado un handler aMoveFirstExecute vacío duplicado. Conservados seis iconos de flechas con alfa reconstruido; se verifican 46 iconos. Herramientas/pruebas admiten Icons/16x16 e Icons/22x22. Repetidas cuatro pruebas tras integrar el IDE. Copia antigua conservada en src/Forms/__history/parameter-names-20261019-141233. Las configuraciones DPROJ preceden a fuentes e imports.

VerifyChartsConfigure: conservar la proporción del separador al ampliar/reducir la ventana; formato de bitmap compatible con TSpeedButton de Delphi 10.2. Prueba VCL sintética, sin MSFS.


### Unidades de visualización

Pruebas sintéticas: VerifyDisplayUnits verifica distancia, velocidad vertical, velocidad, masa, volumen estadounidense, temperatura con desplazamiento, presión, NaN/Infinity, unidades incompatibles, SDK desconocido, ajustes, traducciones y búfer con 64 gráficos. También pasaron VerifyParameterNames, VerifyChartView, VerifyUI, VerifyChartsConfigure y VerifyHelpAbout (35 iconos grandes/pequeños, transparencia del nuevo icono). Sin prueba MSFS en vivo ni medición con una grabación del usuario. El búfer sigue activo con más de 16 gráficos; repetir el mismo punto del cursor no actualiza todo el inspector.

2026-10-19 — paquete de revisión flightsim.to: Release Win64 actualizado, dependencias PE, 66 entradas ZIP, CRC/lectura, EXE/DLL x64, carga de tres DLL extraídas, cuatro CHM/HTML y tamaños del puente EFB verificados. Sin fuentes Pascal, grabaciones, registros, configuración privada ni caché de cuentas. El EXE extraído abrió una ventana principal que respondía y cerró normalmente (salida 0). Se revisaron visualmente cinco capturas en inglés de una copia de una grabación existente. Sin prueba MSFS en vivo ni publicación. La distribución pública requiere resolver el acceso al Corresponding Source según la AGPL vigente.



### Arrastrar gráficos

VerifyChartDrag verifica callbacks VCL sintéticos: añadir/quitar, inserción/lista vacía/final, duplicados, requisito Ctrl, etiquetas iguales con IDs distintos, filtros, cancelación, fuentes externas, temporizador, clic nativo en casillas y copia de trabajo. Marcador revisado visualmente. También pasaron VerifyChartsConfigure, VerifyParameterNames, VerifyDetachedViews y VerifyLocalization. Corregida la expectativa antigua de tres pestañas a cuatro. Sin prueba física del ratón ni medición del desplazamiento con cursor inmóvil. test.ps1 incluye ahora 40 programas.


### Idioma de Windows, nueve idiomas y VersionInfo

VerifyVersionLanguage cubre 14 variantes/fallbacks, idioma de Windows, auto persistente, nueve acciones, guardar/cancelar, títulos traducidos exactos, Unicode y versión EXE/Acerca de. Revisadas capturas francesas y rusas. Pasaron VerifyLocalization, VerifyParameterNames, VerifyHelpAbout, VerifyChartsConfigure, VerifyDisplayUnits y VerifyChartDrag. Adaptados tests antiguos a GroupBox, 40 iconos y diez opciones. Probado bump_build en copia: 0.1.0.2 a 0.1.0.3. Catálogo: 987 entradas, nueve idiomas, marcadores/DFM válidos. Pruebas sintéticas, sin cambiar el idioma de Windows ni vuelo MSFS. Lista predeterminada: 41 programas; no se repitió toda la suite.


Ampliación de idiomas (0.1.0.3): VerifyLocaleExpansion comprueba 30 casos regionales/alias/alternativas, las 25 acciones de idioma, títulos de ajustes, índices y persistencia regional, modo automático, separador decimal sin cambios y ayuda alternativa. Capturas: be-BY, el-GR, pt-BR. Solo pruebas sintéticas, sin MSFS. Validación: 1003 definiciones, 25 idiomas, marcadores Format, Unicode y enlaces DFM. La lista predeterminada tiene 42 programas; no se ejecutó toda para este cambio. Regresión ejecutada: VerifyLocaleExpansion, VerifyVersionLanguage, VerifyLocalization, VerifyParameterNames, VerifyHelpAbout, VerifyChartsConfigure, VerifyDisplayUnits, VerifyChartDrag. Sin revisión de hablantes nativos; las pruebas no certifican la calidad lingüística.


VerifyGlobalLocales: prueba sintética de 32 opciones ordenadas por código, alias, cinco archivos de fuentes privados y glifos de siete muestras. Comprueba BiDiMode, cambios RTL/LTR, restauración de posiciones, LTR en datos/mapa/eje temporal, ajustes y siete capturas. check_fonts.py verifica origen, SHA-256, formatos y dos licencias OFL. check_documentation.py comprueba cuatro Translation.*.md y enlaces README. Lista predeterminada: 43 programas; no significa que se ejecutaran todos. Sin prueba en MSFS ni revisión de hablantes nativos.


Alcance ejecutado para este cambio: 11 pruebas superadas: VerifyGlobalLocales, VerifyLocaleExpansion, VerifyVersionLanguage, VerifyLocalization, VerifyChartsConfigure, VerifyDetachedViews, VerifyDisplayUnits, VerifyHelpAbout, VerifyParameterNames, VerifyChartDrag, VerifyReport.


También se comprobaron ventanas nuevas con árabe/hebreo ya activos: dirección RTL y etiquetas situadas a la derecha.


0.1.0.5 — VerifyRTLReturn inicia con ar-SA guardado, abre el menú mediante WM_INITMENUPOPUP, cambia a en-US y comprueba cuatro ciclos ar-SA/he-IL → pl-PL. Verifica dirección VCL, indicadores RTL nativos HWND en el árbol de controles, paneles, nombres sin & e ImageIndex intactos de las 32 acciones. Restaura los ajustes de prueba; no utiliza bin/settings.ini del usuario. Superadas: VerifyRTLReturn, VerifyGlobalLocales, VerifyDetachedViews, VerifyLocalization. Solo pruebas sintéticas, sin vuelo MSFS. Lista predeterminada: 44 programas, no ejecutada completa.


0.1.0.6: VerifyRTLReturn comprueba los indicadores MFT_RIGHTORDER/MFT_RIGHTJUSTIFY de todo el árbol HMENU, la apertura de submenús y hebreo → Automático. Error reproducido antes de la corrección; después PASS. También superadas: VerifyGlobalLocales, VerifyDetachedViews, VerifyHelpAbout. Sin vuelo real en MSFS. Conservados StackTrace/StackFrames; comprobada compilación Debug con generación PDB.


VerifyVersionLanguage — PASS (EXE VersionInfo 0.1.0.6).


0.1.0.7 — empaquetado: eliminados mateusz-efb-ifly, Community/Optional-Community, --addon e instrucciones de instalación. La validación ZIP comprueba su ausencia. Cambio de distribución; sin pruebas VCL adicionales.
