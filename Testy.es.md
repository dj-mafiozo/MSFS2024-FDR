# Pruebas — MSFS2024-FDR

[Polski](Testy.md) | [English](Testy.en.md) | [Deutsch](Testy.de.md) | [Español](Testy.es.md)

## Compatibilidad del simulador y valores de interruptores

VerifyFlapsHandle, VerifyParameterValues, VerifyUI y VerifyChartView — PASS: selección ICAO, seis estados A320 estándar frente a cinco posiciones SDK, 1+F, perfiles GA y Stemme negativos, variantes MD-11, discrepancias en posiciones y respaldo vacío. Cinco pruebas Python con verificación del generador superadas. Pruebas sintéticas, sin vuelos con todos los modelos; 60 códigos siguen sin confirmar.

Auditoría DisplayValue — PASS: cuatro pruebas Python del analizador, procedencia y generadores; VerifyParameterValues, VerifyAircraftSDK, VerifyFenix, VerifyFBW, VerifyAddonLVars, VerifyPMDG y VerifyPMDG777. Se verificaron separadores, rangos de dígitos, huecos de enums, etiquetas XML, caracteres RTP y valores numéricos de respaldo. Se analizaron 335 archivos XML; de 14 archivos mal formados solo se usaron fragmentos UseTemplate válidos. Análisis estático y simulaciones; sin vuelo en vivo.

VerifyUI y VerifyGSX — PASS: barras en DFM desde Requested, estados activos/completados, retroceso temporal, datos ausentes, progreso de pasajeros/equipaje y contador de cisterna con reinicio. Pruebas sintéticas y simulación SDK; sin prueba GSX en vivo.

VerifySimulatorVersion, VerifySubscriptions, VerifyRecorderWorker, VerifySession, VerifySimBacklog, VerifyFlightPlan y VerifyRecordingWorker: PASS con simulaciones/datos sintéticos. MSFS24 se acepta tras OPEN; MSFS20/FSX/P3D y respuestas desconocidas o truncadas no reciben suscripciones. VerifyParameterValues, VerifyParameterNames y VerifyGSX: PASS para etiquetas de interruptores, posiciones de flaps según aeronave, valores desconocidos, NaN y estados/progreso traducidos de GSX. El progreso del equipaje se muestra en porcentaje. Sin nuevas pruebas en vivo con simulador o GSX.

## A320 PFD y ECAM — Fenix / FBW

VerifyAirbusDisplays — PASS: 13 páginas/PNG, índice real frente a selector, 11/12, avance/retroceso, selección manual, ARINC SSM/cero/inválido, CPC activo, prioridad N1 FBW, deltas SQLite, limpieza, separación/iconos, RTL/LTR/resize. VerifyInstrumentFrames: PASS Fenix/FBW ↔ B38M, dos ventanas, geometría y tres displays sincronizados. VerifyFBW tras reconstruir MockFenixSim, VerifySixPack y VerifyViewState: PASS. PNG PFD/EWD/HYD inspeccionados; sin vuelo ni comparación con Fenix/FBW en marcha ni diseñador IDE.

Recorded/Grabada sigue el índice real de pantalla FBW, no el selector: 11=CRUISE, 12=STS. La selección manual se conserva al desplazar el tiempo. Añadidos 47 campos FBW; ARINC429 exige SSM válido de operación normal, de lo contrario `--`. Reconstrucción inicial, sin emulación completa DMC/FWC: no inventa FMA, órdenes FD, textos de avisos/STS, válvulas ni estado funcional. El XML Fenix disponible no confirma la página automática real; Recorded queda desconocido allí, pero funcionan las páginas manuales. Aceite en porcentaje, sin suponer capacidad en cuartos. ECAM: kg, kg/h, psi, C; cintas PFD según unidades configuradas.

[ECAM](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/ecam/), [E/WD](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/ecam/ecam-e-wd/), [SD](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/ecam/sd/), [PFD](https://docs.flybywiresim.com/pilots-corner/a32nx/a32nx-briefing/pfd/), [FBW SD source](https://github.com/flybywiresim/aircraft/tree/master/fbw-a32nx/src/systems/instruments/src/SD).

## Importar bases Qt

`VerifyLegacyExport` — PASS: importación Qt y reproducción de 3 muestras/6 filas de motores, precisión N1, extensiones ausentes como NaN y +02:00 conservado. Fixture Qt de varios vuelos dividido en dos `.mfzr` con 3 muestras cada uno, sin mezcla; reimportación sin duplicados y SHA-256 de ambos orígenes intactos. VerifyInstrumentFrames comprueba diálogo/menú DFM; VerifyRecordingImport regresiones antiguas de importación/vista previa. Pruebas sintéticas SQLite/VCL, sin vuelo.

## Exportar un vuelo para la aplicación Qt original

`VerifyLegacyExport` — PASS: dos vuelos fuente, solo el elegido con 3 muestras, 6 filas de motores relacionadas, contactos/evento/grupo. Unicode y precisión N1 conservados; siete tablas, 130/35 columnas, sin extensiones/informes. SHA-256 del origen de solo lectura sin cambios; sobrescritura del origen, vuelo inexistente y error NOT NULL durante copia conservan el destino anterior y eliminan temporales. Python sqlite3 compara columnas con cabecera Qt. VerifyInstrumentFrames comprueba menú/diálogo DFM. Sin prueba manual de GUI Qt; esquema/SQLite verificados.

## Distribución estable de instrumentos y línea temporal

Los deslizadores permanecen directamente en CenterPanel; mapa, gráficos, instrumentos y separadores están en un ViewsPanel independiente declarado en DFM. El separador de instrumentos ya no puede redimensionar el panel temporal por error. Al devolver vistas se restablece el orden de instrumentos y separadores.

VerifyInstrumentFrames: PASS — contenedores separados, sin solapamiento, separador justo encima de instrumentos tras alturas 650/750/850 y separación/retorno PFD/EICAS. VerifyDetachedViews y VerifyViewState verifican separación, sincronización y configuración guardada. Pruebas sintéticas VCL/SQLite/INI; sin vuelo ni prueba manual del diseñador IDE.

## Escalado de motores y EICAS

Eliminados ScrollBox de ambos frames y entradas heredadas de frmMain DFM. Las vistas ocupan el área bajo la barra. EICAS mantiene proporción; los indicadores genéricos dibujan el diseño completo en un búfer, eligen columnas según espacio y escalan todo. Las muestras no redimensionan el control. Separador: alLeft, ancho 6, MinSize 100, AutoSnap=False, rsUpdate y persistencia del ancho al mover.

`VerifyInstrumentFrames`, `VerifyEngineGauges`, `VerifyB38MEICAS`, `VerifyViewState` — PASS. Aserciones nuevas: ausencia de ScrollBox, alClient y altura restante, orden panel–separador–panel, AutoSnap desactivado y separación/retorno sincronizados. Pruebas sintéticas VCL/SQLite/INI, sin vuelo ni prueba manual del diseñador IDE.

## Selección de frames por ICAO y escalas PFD compartidas

- `VerifyInstrumentFrames` — PASS: solo ICAO B38M elige `ikB38MPFD`; el título MAX 8 no basta. B736–B739 permanecen genéricos. Dos frames DFM sustituyen six-pack y motores. Cambiar B38M → B738 → B38M con dos ventanas separadas conserva geometría, padres, sincronización e iconos 0/1. Retorno por botón/X, GA y píxeles de cinta IAS verificados.
- `VerifySixPack`, `VerifyPFD737`, `VerifyB38MEICAS`, `VerifyEngineGauges`, `VerifyDetachedViews`, `VerifyViewState` — PASS. Píxeles ILS adaptados al nuevo diseño manteniendo dirección, validez independiente, exclusión GPS y extremos huecos. 1000 cambios de cursor con 3003 etiquetas sin búsquedas de índices; cambiar ICAO invalida caché del perfil. Seis espacios de ventana en lugar de siete, sin `view.pfd737` independiente.
- Generador reparado: falta de `DelphiCompile` podía dar éxito MSBuild sin compilar EXE. Nuevo test y regresiones compilados/ejecutados después; registro en Tests.groupproj y DPR/DPROJ actualizado.
- Debug/Release Win64 y Setup compilados; comprobaciones de proyecto, versión, documentación y traducciones aprobadas. Pruebas sintéticas VCL/SQLite/INI y render; sin vuelo real ni diseñador IDE. Secciones anteriores describen etapas previas; selección actual según esta sección.

## EICAS B38M y parámetros adicionales

- `VerifyB38MEICAS` — PASS: selección por título MAX 8 o ICAO B38M grabado independientemente de livery, indicadores genéricos para otros aviones; N1/N2/EGT/FF/aceite/vibración independientes, psf originales frente a 53 psi, detentes/aguja de flaps, masa de combustible solo con densidad y NaN en vez de cero inventado.
- Mismo test — PASS: píxeles de luz SDK de filtro y ENG FAIL independiente, eliminación de mensajes anteriores, ningún aviso de motor por luz APU o presión cero sola. Starter se identifica como STARTER ACTIVE, no START VALVE OPEN. Se inspeccionó `tests/b38m-eicas-preview.png`. Proporciones, RTL/LTR, avance/retroceso temporal, separar/retornar e iconos 0/1 correctos.
- SQLite — PASS: cantidad de aceite 0,813, TAT 24,37 y combustible central 1250,75 precisos. Se reconstruyó un esquema antiguo conservando filas: vista previa/contexto IA toleran columnas ausentes como NaN/NULL y mantienen N1=84,7. SHA-256 idéntico antes/después; migración con escritura conserva valores históricos ausentes como NULL.
- `VerifySubscriptions` — PASS: aceite solo de motores existentes, TAT/depósito central en vuelo activo y tres campos identificadores en reposo; orden de eventos, cancelación y paquetes antiguos correctos con DLL simulada. También pasaron `VerifyPort`, `VerifyRecordingImport`, `VerifyDetachedViews`, `VerifyViewState`, `VerifyPFD737`, `VerifyEngineGauges`, `VerifyContext`.
- Campos añadidos al final sin cambiar índices anteriores, almacenamiento REAL y nombres en 32 idiomas; unidad/test registrados en DPR/DPROJ/Tests.groupproj. Sin vuelo real ni comparación completa de avisos. SDK 1.5 no ofrece aquí flags confirmados START VALVE OPEN, THRUST o FUEL FLOW. Proporción de aceite y unidades según [SDK oficial](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-engine-variables/), no litros ni límites de motor.

## Escalado del PFD y PFD 737 independiente

- `VerifySixPack` — PASS: panel 900×200 con horizonte adaptado a la altura y V/S con aguja y lectura −677 ft/min. Regresiones de altímetro, VSI fijo, caché, ILS, datos ausentes, unidades y acoplamiento correctas. La escala no varía por muestra. Se inspeccionó `tests/pfd-wide-preview.png`.
- `VerifyPFD737` — PASS: frame DFM y renderizador nativos; IAS/ALT originales y signo de pitch, píxeles LOC/GS, VSI fijo no lineal (1000 → 0,5; 2000 → 0,75; 6000 → 1), signo/límites, NaN, proporciones normal/ancha/estrecha/mínima, avance/retroceso temporal, misma instancia separada, iconos 0/1 y LTR con hebreo. Se inspeccionó `tests/pfd737-preview.png`.
- `VerifyDetachedViews` — PASS: PFD 737 en DFM principal, sincronización al separar y restauración al cerrar. `VerifyViewState` — PASS: siete vistas con `view.pfd737`, geometría independiente y restauración al reiniciar.
- Test nuevo registrado en `tests/Tests.groupproj`; ambas unidades y metadatos del frame en DPR/DPROJ. Solo pruebas sintéticas; sin vuelo real, comparación con aviónica activa de 737 ni diseñador IDE. El área FMA indica estados AP/FD/A/T disponibles, sin inventar modos ni barras de mando FD.

## frmMain reconstruido, iconos y presentación de datos

- La inspección visual de `native-preview.png` detectó motores duplicados que ocultaban SixPack en el panel bajo. frmMain utiliza EnginePanel separado y conserva altura para los instrumentos; `VerifyDetachedViews` lo comprueba. También pasaron `VerifyFMCReplay`, `VerifySimBriefUI`, `VerifySixPack` y `VerifyUI` tras los cambios de barras.
- `VerifyDetachedViews` — PASS: nuevos paneles, desacoplamiento/acoplamiento de la misma instancia, ocultación del contenedor y divisores cuando ambos instrumentos están separados y restauración al cerrar. Los iconos cambian 0/1 también al cerrar con X. Ambos iconos de los seis frames se probaron sobre fondos blanco/negro para comprobar esquinas transparentes.
- `VerifyRecordingTree` — PASS: claves ATCCOM completas/truncadas con título iFly MAX 8 producen B38M, A32NX produce A20N; ICAO válido permanece, claves desconocidas producen UNKNOWN y se rechazan nombres de dispositivos Windows. Filtros, orden, idiomas y archivos ausentes correctos. Se conservan metadatos originales y rutas existentes.
- `VerifyEngineGauges` — PASS: 7632 psf originales se muestran como 53 psi, manteniendo 7632 en el modelo; NaN permanece no disponible. Regresiones de tipos de motor, sincronización, acoplamiento y NULL correctas.
- `VerifyRecorderWorker` — PASS: E_FAIL simulado al abrir SimConnect mantiene el worker listo, sin Failed/Error y con estado de espera traducido; reintentos limitados. Regresiones SQLite, errores de comandos y VCL correctas. Sin simulador real ni prueba de desconexión real.
- `VerifyRecordingImport` — PASS: jerarquía DFM nueva, migración/importación y vista previa sin worker/SimConnect. `VerifyViewState` comprueba seis ventanas y tamaños guardados de paneles inferiores. Solo archivos aislados y simulaciones; no se abrió el diseñador IDE.

## SixPack e ILS del PFD simplificado

- `VerifySixPack` — PASS: renderizado real VCL en bitmap. Se comprueban píxeles de rombos LOC/GS a ambos lados, escalas fijas al variar pitch/bank, pérdida independiente de señal, exclusión de GPS, NaN, límites y rombos huecos en los extremos. Varias imágenes consecutivas comprueban también la eliminación de indicaciones anteriores. Se inspeccionó visualmente `tests/pfd-ils-preview.png`.
- También PASS: herencia directa de TFrame, rango VSI fijo, caché de índices, mecánica del altímetro, baro, valores métricos, acoplamiento, sincronización y migración de campos ausentes.
- `VerifyDetachedViews` — PASS: DFM principal, SixPack y otros frames presentes, desacoplamiento/acoplamiento y sincronización. `check_project.py` verifica la herencia directa de TFrame para todas las clases inline del DFM.
- Solo pruebas sintéticas; no se realizó vuelo ILS real ni reapertura en el diseñador Delphi. El DFM de SixPack permanece intacto; no se reconstruyeron cambios guardados después de Ignore.
- HSI CDI ±127, GSI ±119 y señales válidas según el [SDK oficial de MSFS 2024](https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/SimVars/Aircraft_SimVars/Aircraft_RadioNavigation_Variables.htm): son desviaciones de aguja, no ángulos en grados.

## Mutex del grabador y frames compatibles con el diseñador

- `VerifySetup`: objeto real de Windows `MSFS24-FDR-Run_Once`; la primera adquisición funciona, la segunda se rechaza y liberar el identificador permite reiniciar. Se comprobó su detección por el instalador.
- `VerifySetupUI`: formulario modal DFM real `frmSetupRunning`, `bsDialog`, `mrRetry` y `mrCancel`. Un temporizador reintenta tres veces; solo liberar el mutex permite continuar. Cancelar interrumpe la operación sin liberar el mutex del grabador. También pasó la regresión del actualizador pequeño y del fallo de API.
- `VerifyUI`: carga del DFM frmMain, creación/presentación, mapa, gráficos y sincronización correctos tras derivar directamente de TFrame los frames de instrumentos y motores. No se reabrió el formulario en el diseñador Delphi; falta confirmarlo en el IDE.
- No se terminó ningún grabador real ni se instaló en Program Files ni se modificó el registro de producción. El fallback de proceso para EXE antiguos sin mutex no se probó por separado con un proceso real.

## 0.1.1 — Estructura Setup, i18n, mantenimiento y PEM

Verificado con Delphi 10.2 Win64, archivos aislados y formularios DFM reales, sin instalar en producción ni cambiar datos personales.

- VerifySetupMaintenance comprueba Auto y los mismos 32 códigos regionales, detección de Windows, persistencia INI, controles traducidos, RTL árabe/hebreo y retorno a LTR. El modo SETUP_RESOURCE_TEST se ejecutó sin fuentes ni catálogo externos y registró cinco fuentes incrustadas desde memoria.
- Mantenimiento: opciones de instalación existente, reparación y vuelta, metadatos de versión cuando falta el EXE, restauración de archivos ausentes/dañados sin cambiar las fechas de los correctos. Si falta la versión requerida, no se sustituye silenciosamente por otra más reciente.
- Las cuatro combinaciones de ajustes/vuelos abarcan Recordings, índice, registros y WAL de una grabación suelta, solo en TestPathsU.
- tests/VerifyReleasePEM.dpr genera una clave RSA-3072 efímera en PKCS#8 cifrado AES-256 fuera del repositorio. Un PackageRelease nativo de prueba recoge binarios reales, cifra el ZIP, firma ZIP/manifiesto con OpenSSL y contraseña de prueba solo por stdin y verifica con CNG. Coinciden SHA-256 y los bytes del EXE; se excluyen archivos privados y nunca se extrae el señuelo.
- Sustituir public.pem tras compilar no altera la verificación válida: se usa la clave incrustada. Una firma de manifiesto modificada se rechaza antes de extraer. Una contraseña incorrecta cancela el empaquetado y elimina archivos incompletos.
- Pasaron VerifySetup, VerifySetupUI, VerifySetupSignature, VerifySetupMaintenance, VerifyGlobalLocales, VerifyLocaleExpansion, VerifyVersionLanguage, VerifyRTLReturn, VerifyReport, VerifyFMCReplay, VerifyUI, VerifyAppStorage y VerifyRecordingImport. Se compilaron Debug/Release, Setup 0.1.1.19 y el proyecto IDE independiente PackageRelease; pasaron las comprobaciones de proyecto, dependencias, versión, traducciones y documentación.

Registro, accesos directos y procesos de instalación usan dobles. No se probaron UAC real, asociaciones, instalación/reparación/desinstalación completa, Authenticode ni vuelo. El PEM de producción requiere contraseña local: no se generó ni publicó una clave o paquete de producción. Las pruebas de firma usan un par efímero. Las secciones anteriores describen la antigua clave CNG.

## 0.1.1 - Menu Start

La carpeta DJ M@fi0z0™ del men? Inicio contiene accesos a la aplicaci?n y a Setup.exe /uninstall. Ambos respetan la opci?n del men? Inicio. VerifySetup comprob? migraci?n, destinos, argumentos, desactivaci?n y conservaci?n de otros productos al desinstalar. Se usaron dobles aislados, sin modificar el men? Inicio real.

## 0.1.1 ? OmniXML

La edici?n de exe.xml usa IXMLDocument/IXMLNode y el backend nativo OmniXML, sin automatizaci?n OLE ni MSXML. VerifySetup comprueba XML antes de CoInitialize: inserci?n/eliminaci?n, idempotencia, conservaci?n de entradas ajenas y comentarios, creaci?n del documento vac?o, Unicode y rutas con caracteres especiales, UTF-8 y rechazo de DTD/XML inv?lido. Las pruebas de instalaci?n usan archivos aislados y dobles; no se modific? el exe.xml de producci?n.

## 0.1.1 — Firmas de versiones

Se compilaron Delphi 10.2 Win64 Debug/Release y el proyecto Setup separado. VerifySetup comprueba el orden de versiones, los archivos GitHub, el cifrado y descifrado ZIP, contrase?as incorrectas, corrupci?n, rutas inseguras y la exclusi?n del archivo se?uelo. Tambi?n prueba la combinaci?n XML y el rechazo de DTD, instalaci?n, actualizaci?n y desinstalaci?n con archivos reales aislados, recuperaci?n de copias fallidas, sustituci?n de Setup, DFM del historial y ajustes. VerifySetupUI comprueba navegaci?n, opciones, progreso compacto y tres escenarios HTTP locales, manteniendo activa la interfaz VCL.

VerifySetupSignature utiliza Windows CNG y una clave RSA-3072 ef?mera. Comprueba firmas v?lidas SHA-256/PSS con sal de 32 bytes y rechaza firmas o hashes modificados, sal de 20 bytes y claves ausentes. El l?mite de versi?n guardado de forma aislada no puede disminuir. La verificaci?n del paquete firma con .NET RSACng y comprueba con Delphi/CNG antes de comparar CRC y bytes. Python zipfile descifr? de forma independiente un archivo con contrase?a p?blica de prueba. Regresi?n: VerifyReport, VerifyFMCReplay, VerifyUI, VerifyRecordingImport, VerifyAppStorage y VerifyRTLReturn.

Las operaciones de registro, accesos directos y procesos utilizan dobles de prueba. No se realizaron una instalaci?n real en Program Files, una solicitud UAC, cambios del exe.xml de producci?n, firma Authenticode, publicaci?n ni vuelo en el simulador. La recuperaci?n de copias no garantiza una transacci?n completa del registro, XML y accesos directos ante un corte el?ctrico. La firma de producci?n usa la clave del editor, nunca la clave ef?mera de prueba.

La verificaci?n final en el repositorio de destino pas?: Debug/Release Win64 y Setup 0.1.1.16, las nueve pruebas indicadas y las comprobaciones de proyecto, dependencias, versi?n, traducciones y documentaci?n. El paquete firmado contiene 80 entradas cifradas. Se rechazaron modificaciones del ZIP, su firma, el manifiesto, su firma y la falta de esta ?ltima antes de crear el directorio de extracci?n. Se movieron seis grupos de opciones del compilador generados por el IDE antes de importar los targets Delphi y se eliminaron propiedades exclusivas de formularios de tres DFM de frames, conservando sus dimensiones.

## 0.1.2.15 — Importación, vista previa y recursos DFM

Las pruebas utilizaron datos SQLite sintéticos y formularios VCL reales, sin abrir grabaciones privadas con el EXE de producción ni conectar con MSFS.

- `VerifyRecordingImport`: migración inicial, vuelo añadido a una base antigua ya procesada, importación repetida sin duplicados y comparación SHA-256 del original; detección de un `.mfzr` añadido, escaneo repetible y aislamiento de archivos no válidos. Un archivo ya indexado no se importa por duplicado.
- Un proceso hijo recibe exactamente una ruta existente de un `.mfzr` sintético. Comprueba telemetría, tres pestañas de instrumentos desde DFM, LeftPanel y separador ocultos, acciones de grabación y gestión deshabilitadas, llamadas directas seguras a manejadores bloqueados y ausencia del índice predeterminado y del bloqueo del grabador. SQLite rechaza una escritura mediante una conexión de solo lectura; el SHA-256 permanece idéntico. Ambos iconos de importación muestran esquinas transparentes sobre fondo claro.
- Regresiones superadas: `VerifyUI`, `VerifyDetachedViews`, `VerifyHelpAbout`, `VerifyGroups`, `VerifyPort`, `VerifyLegacy`, `VerifyRecorderWorker`, `VerifySession`, `VerifyViewState`, `VerifyFMCReplay`, `VerifyMetar`, `VerifyRecordingFiles`, `VerifyRecordingTree`, `VerifyRecordingUI`, `VerifyRecordingWorker`, `VerifyTripInfo`.

No se realizó un vuelo real ni se utilizó manualmente el selector de archivos. Se usaron SQLite real y procesos hijos; no se certifica cualquier posible corrupción física. La nueva prueba figura en Tests.groupproj y en test.ps1 por defecto.

Verificación final en el repositorio de destino: compilaciones Debug y Release Win64 con Delphi 10.2 correctas, VersionInfo 0.1.2.15. VerifyRecordingImport, VerifyRecordingUI y VerifyViewState superadas de nuevo, además de controles del proyecto, versión, documentación y catálogo (1044 definiciones, 32 idiomas). El catálogo desplegado coincide con el original. Se corrigió el orden de MSBuild y del despliegue de traducciones; los archivos auxiliares del instalador independiente se excluyen de la validación de unidades del grabador.

## 0.1.0.14 — índice y archivos individuales de vuelos

Pruebas ejecutadas con SQLite/VCL sintéticos en directorios aislados `TestPathsU`:

- `VerifyRecordingFiles`: archivos independientes, índice solo de metadatos, estados, rutas ICAO/fecha, muestras/eventos aislados, metadatos conservados sin archivo y rechazo de rutas externas. Migración de tres vuelos: grupos, colisiones, texto/formato/indicadores FMC, tabla adicional con trip, versión de esquema, reapertura sin repetir actualización, idempotencia y original idéntico byte a byte.
- Finalización forzada de un proceso hijo con `TerminateProcess`: WAL confirmado, muestra recuperada, estado interrumpido, recuperación entre renombrado y publicación del índice y conservación de archivo dañado/metadatos tras fallo de integridad.
- `VerifyRecordingTree`: orden de todos los niveles y hermanos, meses completos PL/DE, identificadores de traducción, fechas con ceros, iconos, prefijo activo, selección, filtros combinados de grupo/búsqueda, filtros vacíos y archivos ausentes ocultos.
- `VerifyRecordingUI`: formulario real, archivo migrado, selección/doble clic, inspector e instrumentos, nodo activo deshabilitado, búsqueda y selección de carpeta. Diálogos automatizados: rechazo conserva datos, nueva oferta en el siguiente inicio y apertura tras aceptar recuperación.
- `VerifyRecordingWorker`: hilo real y SimConnect sintético, contención SQLite en archivo individual, heartbeat VCL y órdenes sin bloqueo, varias muestras, ruta/estado final y cierre correcto.

Proyectos nuevos registrados en `tests/Tests.groupproj` y `test.ps1`. Pruebas antiguas adaptadas al árbol. `VerifyFMCReplay` usa almacenamiento aislado en lugar de TEMP global. No se abrió la aplicación de producción contra datos privados, no hubo vuelo real de MSFS ni validación de recuperación universal de bases físicamente dañadas. A continuación figura el historial de pruebas de versiones anteriores.

Validación final: 15 pruebas de regresión superadas (interfaz, ventanas separadas, ayuda, grupos, base/migración, hilo/sesión, estado de ventanas, FMC, METAR y cuatro pruebas nuevas). Los meses árabes/hebreos usan fechas gregorianas. Se comprueba borrar solo el archivo confirmado y rechazar un archivo ocupado conservando metadatos y limpiando el inspector. Compilaciones Delphi 10.2 Debug/Release Win64 correctas, VersionInfo 0.1.0.14. Controles de proyecto, versión, traducciones y documentación superados.


La lista utiliza `vstRecordings: TVirtualStringTree` con el diseño actualizado, nodos deshabilitados nativos y conservación de selección, carpetas expandidas y desplazamiento. La compilación requiere fuentes Virtual TreeView V8 en `..\Virtual-TreeView\Source` o `vendor\Virtual-TreeView\Source`. Se puede indicar `-VirtualTreeRoot` en `build.ps1`/`test.ps1` o `/p:VirtualTreeRoot=...` en MSBuild. El proyecto IDE y el grupo de pruebas comparten la configuración. El ejecutable no requiere otra biblioteca de ejecución para este componente.


Se repitieron las 16 pruebas tras cambiar a TVirtualStringTree, incluida VerifyTripInfo. En el repositorio final también pasaron VerifyRTLReturn y VerifyGlobalLocales: 32 idiomas, fuentes y RTL/LTR. Total: 18 pruebas de regresión. Se inspeccionó visualmente native-preview.png de VerifyUI: texto, mes, iconos y selección del árbol. Compilaciones Debug/Release Win64 y cinco pruebas aisladas de almacenamiento/información en el repositorio final: PASS.


## 0.1.0.13 — rangos, índices y altímetro (2026-10-21)

Ampliado `VerifySixPack`, ya en `Tests.groupproj`. Grabación sintética con VSI 100/-5600 ft/min, NaN, Infinity y matriz corta. Rango 6000 ft/min desde la primera muestra, constante al recorrer ambos sentidos; sin VSI mínimo 2000. IAS también fija. ft/min→m/s conserva proporción valor/rango. Sin validación en vuelo MSFS.

Subclase contadora: 3003 etiquetas y 1000 SetPoint posteriores sin más búsquedas IndexOf. Comprueba reordenar con igual cantidad, nombre desconocido, cambiar grabación, Clear y conservar OnChange con Revision. Controla el acceso TSixPackDisplay, no mide rendimiento de toda la aplicación ni motores. Editar valores sin cambiar esquema requiere Clear para recalcular; replay considera inmutables las muestras vinculadas.

12500 ft producen ángulos 180°/90°/45°, iguales tras ft→m con lectura 3810 m. También se comprueba un píxel de la aguja larga realmente renderizada antes/después, no solo la función auxiliar. Más cobertura: -500 ft, NaN, ILS/baro, separación, tamaño pequeño, RTL y NULL migrados. Inspeccionado `tests/six-pack-metric-preview.bmp`: leyenda FT, lectura métrica y mecánica en pies.

Pasan VerifySixPack, VerifyDetachedViews, VerifyViewState, VerifyDisplayUnits, VerifyEngineGauges, VerifyPort, VerifyUI. No se repiten todos los 53 Verify. TPlotLabels modifica solo el modelo en memoria; SQL/almacenamiento sin cambios. Build incrementado una vez a 0.1.0.13; controles de proyectos/grupo siguen requeridos.


Ejecución final en el repositorio destino: pasan otra vez las siete pruebas indicadas. Debug y Release Win64 compilados con VersionInfo 0.1.0.13. Sin cambiar configuración/base personal ni ejecutar el EXE de producción.


## 0.1.0.12 — persistencia de vistas (2026-10-21)

Nuevo `VerifyViewState` en `tests/Tests.groupproj` y lista predeterminada `test.ps1`. Pruebas sintéticas VCL/INI/SQLite sin vuelo ni configuración privada. Crear/destruir frmMain repetidamente comprueba seis frames incluido SimBrief, posiciones/tamaños independientes, conservar el estado separado al salir, restauración automática, retorno mediante botón/X, independencia de otras ventanas y geometría retenida tras integrar. Un frame adicional `future_hud` confirma extensibilidad sin rutinas propias de guardado.

Otras aserciones: dimensiones normales al maximizar, minimizar no guarda dimensiones del icono ni fuerza inicio minimizado, restaurar solo una vez, reset integra/elimina secciones, IDs inválidos/duplicados, conversión DPI emulada y recuperación de coordenadas fuera de pantalla/MaxInt y tamaño/PPI inválidos. No se desconectaron monitores ni se cambió DPI Windows; se usan valores INI simulados.

Regresión superada: VerifyViewState, VerifyDetachedViews, VerifyUI, VerifySimBriefUI, VerifyRTLReturn, VerifySixPack, VerifyEngineGauges. No se repitió toda la suite de 53 Verify; la entrada anterior de 52 pruebas corresponde a la versión previa. Pasan controles de proyectos/grupo, i18n, versión, fuentes y documentación. Eliminadas de nuevo propiedades TForm guardadas por IDE en el DFM six-pack conservando tamaño/aspecto manuales. Build incrementado una vez a 0.1.0.12.


Verificación final en el repositorio destino: las siete pruebas anteriores pasan de nuevo; compilaciones Debug y Release Win64 correctas con VersionInfo 0.1.0.12. También se compiló el nuevo test mediante su target `Tests.groupproj` en la copia de trabajo y se ejecutó el EXE resultante. Sin ejecutar el EXE de producción ni migrar datos privados.


## 0.1.0.11 — bases aisladas e instrumentos (2026-10-21)

Los **52 programas Verify** de la suite completa `test.ps1` terminaron con código 0/PASS. Son pruebas sintéticas SQLite/VCL y simulaciones SimConnect/IPC/HTTP/CLI; no se realizó un vuelo real en MSFS. Se conserva la cobertura de grabación, aviones, FMC, FSHud, GSX, análisis, SimBrief, gráficos, unidades, idiomas/RTL, migraciones y versión.

- `TestPathsU` crea `.build/test-data/<nombre>/<PID>-<tick>` para cada proceso Verify, redirige bases/configuración PORT_TEST y copia dependencias/fixtures. Las migraciones conservan sus árboles temporales privados. VerifyPort, VerifyLegacy y VCL pasan con las rutas nuevas; no se abren las bases personales de bin/LocalAppData.
- `VerifySixPack`: normalización LOC/GS ±127/±119, señales válidas, exclusión de CDI GPS, pérdida de GS manteniendo LOC, flags ausentes/NaN, baro seleccionado 1026 hPa, alternativa desde 29.92 inHg y STD. Se mantienen pitch, rumbo, turn/ball medidos, unidades, tamaño, separación y migración. Falta comparar la dirección de agujas en el simulador.
- Nuevo `VerifyEngineGauges`: cuatro clases, pistón/turbohélice/reactor, 0/1/2/4/16 motores y número inválido, N1 independientes, RPM/CHT/ITT/condition, grupos incompatibles excluidos, combustible cero válido frente a datos ausentes, amperios, separar/devolver el mismo frame, actualización temporal, RTL/LTR y tamaños pequeños. La base conserva título, ITT preciso y NULL→NaN. Se inspeccionó `tests/engine-gauges-preview.bmp`.
- `VerifyDetachedViews` añade frame de motores, botón de retorno, Close y etiqueta temporal. `VerifySubscriptions` mantiene las pruebas de tipo/número y desuscripción al finalizar la sesión.
- FireDAC ahora recibe el tipo antes de Clear/NULL para un parámetro de motor ausente. El error inicial «Parameter V32 data type is unknown» quedó corregido. No se fabrican ceros.

Los 123 campos añadidos mantienen los offsets anteriores: 11 comunes y 7 familias ×16 motores. Las columnas nuevas admiten NULL; los registros antiguos no recuperan datos inexistentes. Catálogo: 834 campos/7080 bytes, 123 columnas numéricas y 39 familias de motores. Validaciones: 88 unidades DPR/DPROJ, 1034 definiciones i18n ×32 locales, fuentes/licencias, documentación, add-on/AIRLINER y versión 0.1.0.11. La validación lingüística es estructural, no de un hablante nativo; las nuevas descripciones incluyen fallback técnico inglés.

Escalas genéricas sin límites específicos; Glass/PFD es una vista común simplificada sin FMA/FD/PFD/ND completo. Los títulos personalizados pueden requerir reglas adicionales. Referencias: [motores](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-engine-variables/), [navegación](https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simvars/aircraft-simvars/aircraft-radio-navigation-variables/).


Validación final: los 63 proyectos de `tests/Tests.groupproj` compilados con MSBuild Delphi 10.2 (Debug/Win64; publicador IPC Win32). Se comprobaron valores predeterminados sin argumento Platform y los EXE VerifyEngineGauges/VerifySixPack resultantes. Corregidas rutas de recursos VCL y flags de plataformas IDE. Tras integrar el formato manual pasan otra vez VerifyEngineGauges, VerifySixPack, VerifyDetachedViews, VerifyPort, VerifyLegacy y VerifyDisplayUnits. Se comprueba NULL→valor→NULL en consulta preparada, baro fraccionario 1026.35 y nuevas traducciones. Escalas comunes entre motores; baro REAL sin truncar decimales.


La validación en el repositorio destino encontró además registros Name sensibles a espacios, hashes OFL sensibles a CRLF y propiedades TForm ClientHeight/ClientWidth/OldCreateOrder/PixelsPerInch/TextHeight en el DFM six-pack. Se toleran formato y finales de línea manteniendo la validación del contenido/fuentes. El TFrame conserva dimensiones/apariencia manuales; las licencias ZIP toleran solo LF/CRLF. Se repitieron siete pruebas, incluida VerifyAddonLVars. Debug/Release Win64 0.1.0.11 recompilados; no se ejecutó el EXE de producción ni se migraron datos privados.


## 0.1.0.10 — Suscripciones de vuelo y six-pack nativo (21-10-2026)

`test.ps1` completo: **51 programas PASS**, Delphi 10.2 Win64, datos aislados. Proyecto (85 unidades), 1014 definiciones en 32 idiomas, fuentes, versión y documentación PASS. No se ejecutaron el EXE de producción ni la migración de datos privados.

- `VerifySubscriptions`/DLL simulada: tres campos en reposo; AircraftLoaded/SimStart sin FlightLoaded, orden de eventos; reactores/pistón/turbohélice y cantidad de motores; recarga del mismo modelo y cambio de título en paquetes; cancelación, limpieza y rechazo de paquetes antiguos; AircraftLoaded almacenado no activa en el menú. SimStart confirma el estado actual del vuelo.
- `VerifyAddonLVars`: ocho perfiles/5050 campos; solo proveedor TFDi coincidente; cierre al finalizar; cola ONCE limitada, errores aislados, NULL, cambios SQLite y gráficos. Tras fusionar formato, prueba adicional de transporte de `A:LIGHT NAV` y unidad bool.
- `VerifySixPack`: renderizado VCL nativo; muestra/tiempo, signo de cabeceo, 361° → 1°, altitud indicada, viraje/bola medidos; mismo frame al separar/cerrar; RTL, unidades, datos ausentes, redimensionado; migración sin dos columnas y NULL conservado como NaN. Captura revisada; `docs/screenshots/six-pack.png` muestra datos sintéticos.
- `VerifyDetachedViews` ampliado: integración en ventana principal, retorno por botón/Close y sincronización. Se conservaron las aserciones en una rutina separada tras errores del generador de código Delphi 10.2 en la prueba ampliada.
- Auditoría local: **120 paquetes/2046 locpak**, fuentes y hashes, sin archivos cifrados. Se excluyeron nombres traducidos dentro del código. Bell 407: 72 bindings; EC135: 234. **18 variantes/39 XML**: cinco familias anteriores mantienen 3298 L-vars; TFDi MD-11 GE/PW/pasajeros/carga añade 1446. Una unión por familia no confirma todos los campos en cada variante.

Semántica contrastada con [plantillas oficiales SDK](https://docs.flightsimulator.com/msfs2024/html/5_Content_Configuration/Models/ModelBehaviors/TemplateExplorer/Asobo_EX1/Common/Interior/Templates/ParametersFn/Instrument_ParametersFn.html). **Sin verificación en vivo**. TFDi usa L-vars explícitos de modelos, no un SDK binario inexistente en esa ubicación. Cero no confirma disponibilidad. Six-pack no emula fallos ni dinámica de instrumentos.

Compilación final **Debug y Release Win64 PASS**, FileVersion **0.1.0.10**, traducciones y símbolos PDB coincidentes. Se conservó el formato manual concurrente de cuatro archivos. VerifyAddonLVars (incluido binding estándar/unidad), VerifyDetachedViews y VerifySixPack nuevamente PASS tras fusionar. No se modificaron aeronaves instaladas ni grabaciones/configuración privadas.

## 0.1.0.9 — Exportación A320 e integraciones de aeronaves

`test.ps1` completo: **49 programas PASS**, Delphi 10.2 con datos aislados. Las pruebas nuevas cubren 522 campos SDK, tres CDU, 3298 L-vars de cinco familias, aislamiento de errores, consultas limitadas y almacenamiento solo de cambios. IPC real Win32 → Win64 verifica RGB, letra pequeña, indicadores, cambios únicamente de formato y pantallas no disponibles; replay comprueba detección automática y pestañas CDU.

Verificación independiente clang-cl de todos los offsetof/sizeof contra el encabezado original PMDG 777: PASS. FlightPad `ExportTests` y `ExportAppearanceTests` Win32: PASS; compilados los cuatro clientes Fenix/FBW MCDU/Screen. Proyecto (73 unidades), versión, traducciones y catálogos: PASS. Sin prueba en vivo en el simulador: las DLL son simuladas; cero no demuestra que exista una L-var. No se modificaron archivos de aeronaves ni datos privados.

Compilación Debug y Release Win64 del repositorio de destino: PASS, FileVersion 0.1.0.9; traducciones y símbolos PDB: PASS. Comprobación final: 73 unidades PASS. En el DFM actual de SimBrief se sustituyeron ClientHeight/ClientWidth por Height/Width y se eliminaron tres propiedades exclusivas de TForm, conservando el diseño actual. No se ejecutó el EXE de producción.

## 0.1.0.8 — vistas nativas, AppData y FMC/MCDU (21-10-2026)

**`test.ps1` completo: 46 programas Delphi — PASS**, copia de trabajo aislada, Delphi 10.2 Win64. Validaciones de 32 idiomas/1011 entradas, 68 unidades DPR/DPROJ, fuentes, versión y documentación: PASS. Las secciones anteriores describen versiones históricas.

Compilaciones Debug/Release Win64 de las fuentes instaladas: PASS, FileVersion 0.1.0.8 y catálogo/PDB correspondientes. Importaciones PE y ausencia del loader WebView2: PASS. ZIP en `dist/native-storage-fmc-0.1.0.8/`: 72 archivos, CRC/lectura, x64 y carga de ambas DLL tras extraer (SQLite 3.45.3), tres fondos FMC/cuatro CHM; sin WebView2, Community ni ajustes/base privados. No se ejecutó el EXE de producción para evitar migrar datos privados durante la verificación.

`VerifyAppStorage`: datos reales SQLite confirmados en WAL (registro 12345), familia DB/WAL/SHM congelada, traslado de ajustes/registros, escritor activo bloqueando la migración sin destino parcial, conflictos sin sobrescribir, repetición, recuperación de `migration.pending` y origen de solo lectura con copia de usuario escribible. Solo directorios de prueba; no se migraron datos privados ni Program Files real. Producción usa LocalAppData; `PORT_TEST` aísla datos junto al EXE de prueba.

`VerifyFMCReplay`: dos dispositivos, última pantalla hasta el cursor, offsets UTC/sufijo del día, orden por ID con horas iguales, apagado/no disponible, aislamiento, limpieza y misma instancia al separar/devolver. El CDU físico sigue LTR después de hebreo/polaco. Se revisó visualmente `tests/fmc-replay-preview.bmp`: fondo B737, colores, letra pequeña y EXEC/MSG. `VerifyDetachedViews` también comprueba la línea temporal principal, cambio de registro con FMC separado, regreso por botón/Close y cierre principal.

Las pruebas de informes/SimBrief comprueban TMemo Consolas de solo lectura, sin bordes/barras internas, espacios/entidades HTML, altura para más de 100 líneas, desplazamiento exterior, formato nativo de títulos/negrita/listas/cursiva/código, títulos y cierre. La expectativa antigua ssHorizontal cambió a ssNone. `VerifyHelpAbout` crea sus propios datos. También pasan las pruebas existentes de grabador/WAL, SDK simulados, FMC, SimBrief, tiempo, unidades, iconos e idiomas.

Sin vuelo en vivo ni prueba de instalador; todavía no se incluye instalador. Los registros antiguos/de solo texto Fenix/FBW carecen de estilos/indicadores completos. El fondo B777 no es una nueva integración SDK. Las pruebas simuladas no certifican todas las versiones de complementos comerciales.


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

Se decodifican los modos FMA y textos E/WD de FBW grabados, con formato, parpadeo según la grabación e identificadores desconocidos visibles. Los ajustes Debug permiten forzar los instrumentos. El mapa muestra restricciones PLN y recupera nombres desde SimBrief por coordenadas. STS completo, FMA de iFly y procedimientos expandidos siguen pendientes; véase `support/fbw/display-protocol.md`.

Synthetic coverage: VerifyAirbusDisplays (FMA words, EWD codes, missing/unknown data, debug override), VerifyFlightPlan (PLN constraints and OFP coordinates). Live simulator validation not performed.

Los procedimientos SID/STAR/APP seleccionados se amplían mediante SimConnect Facilities, con transiciones, restricciones, arcos RF/AF y aproximación frustrada. La instantánea de navegación se guarda junto al plan original para reproducción sin conexión. Las esperas tienen símbolos esquemáticos y la frustrada aparece en gris oscuro. El FMA de iFly/B38M se reconstruye a partir de luces MCP y SimVars, identificado como FMA RECONSTRUCTED; VNAV, THR HLD y FLARE son aproximaciones.

VerifyProcedureRoute: mock Facilities API exports and headers, out-of-order parents, ItemIndex ordering, wrong runway exclusion, RF geometry, holding/missed constraints, repeated expansion, SQLite and offline replay. VerifyIFlyFMA: lamp encoding, mode priorities, AP/FD, ILS/armed GS, altitude capture and missing data. VerifyPFD737, VerifyFlightPlan, VerifySimBrief, VerifySubscriptions: regression checks. No live simulator or IDE designer validation. VerifyProcedureRoute disables the Delphi 10.2 Win64 optimizer to avoid compiler internal error URW1237; application builds retain their normal settings. DLL mock projects now explicitly set GenDll, preventing stale .dll use when the compiler otherwise writes a library to .exe.

Añadida reproducción del Flight Director de cabeceo/alabeo para A320 y B38M, captura FD/EX1 estándar en radianes y opción para desactivarlo en B38M. Los datos históricos ausentes siguen sin estar disponibles; cero sigue siendo válido. Fuentes y límites: `support/fbw/flight-director.md`.
VerifyFlightDirector, ProbeFlightDirector, VerifyAirbusDisplays, VerifyPFD737: synthetic replay tests; live simulator channels not verified.

PFD B38M con FD de barras cruzadas, fondo de actitud completo, escalas alineadas, semirrosa y GS/TAS/viento. AoA opcional en Debug mediante INCIDENCE ALPHA registrado. Los dígitos MCP de iFly recuperan objetivos; ARM y luces de modo complementan la bandera A/T estándar falsa. El FMA sigue siendo estimado.
VerifyPFD737: synthetic AoA/radians/ground/missing/optional/render checks. VerifyIFlyFMA: 22 recorded AFDS configurations plus synthetic cases; no authoritative recorded FMA text, no live comparison.

Panel MAX opcional junto al PFD: número de vuelo, código de transpondedor SDK con ceros iniciales, matrícula, SELCAL si está disponible, UTC/fecha grabadas y tiempo desde el inicio de grabación. Se oculta en Debug. Datos ausentes: --; no usa el reloj del ordenador.
VerifyPFD737: synthetic panel rendering/hide, recorded midnight crossing, reverse seek, invalid time, missing SELCAL and squawk leading zero. VerifyFlightDirector: SQLite flight metadata roundtrip. No live test.

Mínimos FBW A320 BARO, RADIO y NO DH desde palabras ARINC válidas, lectura y marcador dentro de la cinta de altitud. RADIO usa la radioaltura actual, no una altitud MSL absoluta. Información B38M a izquierda/derecha (CPT/FO). Mínimos iFly/Fenix sin confirmar; DECISION HEIGHT de diseño no se usa como selección del piloto.
VerifyPFDMinima: synthetic ARINC BARO/RADIO/NO DH, zero/missing, relative RA, off-scale/amber marker. VerifyPFD737: CPT/FO panel position and return. VerifyAirbusDisplays: BARO visual fixture. No live comparison.

PFD B38M: flecha del flujo de viento relativa al rumbo TRUE y bloques VOR/ADF 1/2 con frecuencia y DME disponible. Nuevos canales NAV/ADF como REAL nullable; sin valores inventados en grabaciones antiguas. Ambos PFD admiten IAS/Mach seleccionado y STD sin presión numérica; FBW usa STD/QNH/QFE nativo. Pulsadores momentáneos no se interpretan como modos persistentes.
VerifyPFDReadouts: synthetic native/standard mode priority, STD vs QNH 1013, QFE/invalid ARINC, IAS/Mach/blank MCP, VOR/ADF/OFF/zero/missing DME, TRUE-relative wind and SQLite NULL/frequency roundtrip. VerifyPFD737/VerifyAirbusDisplays snapshots; VerifySubscriptions checks NAV/ADF only during flight. No live test.

Reproducción con inicio/pausa, parada al inicio y 1x, principio/final, saltos ±30 s y velocidades de 0.125 a 16x. Mapa, gráficos e instrumentos separados comparten la línea temporal. Nuevas grabaciones guardan el intervalo inicial de muestreo; las antiguas usan la mediana de intervalos válidos o 500 ms. Alfa reparada en ambas listas, conservando imágenes e índices.
VerifyPlayback: deterministic playback clock/rates/pause/seek/gaps/end/stop, stored and inferred cadence, SQLite and read-only legacy schema. VerifyInstrumentFrames: DFM actions, timer/glyph switching and transparent icon drawing in both sizes. Synthetic only, no simulator required.


Acoplamiento nativo VCL: VerifyNativeDocking comprueba pestañas flotantes, acoplamiento lateral, persistencia del destino y del árbol DockManager, retorno al cerrar y conservación de controles con datos sintéticos. VerifyDetachedViews y VerifyViewState comprueban la compatibilidad de las seis vistas independientes existentes. No se probó el arrastre manual durante un vuelo en el simulador.


VerifyPlayback comprueba la interpolación entre muestras sin cambiar el índice, rumbo 359→1°, cruce del meridiano 180°, conservación de estados booleanos/SDK y NaN, datos originales intactos y pausas de grabación. Datos sintéticos; no se ha evaluado manualmente la fluidez de una grabación real.


VerifyInstrumentRender comprueba píxeles de bordes, recorte y restauración del DC a 25/50/75/100/125/150/200/300%, además de vistas PNG de PFD B38M/A320, six-pack y EICAS con inspección visual. Prueba sintética WinAPI/VCL; no es una prueba de cambio entre monitores físicos con distintos DPI.


VerifyPanelProportions comprueba cambios repetidos de tamaño sin deriva de redondeo, nuevas proporciones del separador, paneles ocultos y espacio mínimo. Ventanas VCL reales comprueban acoplamiento horizontal/vertical PFD/EICAS y cierre seguro del anfitrión. Pruebas sintéticas; sin arrastre manual durante un vuelo.


Pruebas sin conexión: VerifySimWeather (fuentes separadas, HTTP, METAR y DFM), test_weather_bridge.js (Coherent simulado), VerifyReplayExtras (FLIGHT_START y 30 segundos de ATC), VerifyUI, VerifySimBriefUI y VerifyRecordingFiles. Sin prueba de meteorología ni procedimientos en MSFS real: simulador cerrado. No se analizó un volcado CTD completo.


VerifySimBriefMaps comprueba HTTP simulado, GIF/BLOB, identidad del plan, vista sin conexión y borrado. SimBriefUI prueba WM_MOUSEWHEEL en la cola de Windows y Loaded sin OnMessage en DFM. Docking/UI verifican alClient y tamaño estable. Tick18 solo no genera delta. Un GIF real de SimBrief se descargó con Python (HTTP 200, 32904 bytes); no es una prueba completa de GUI real. Sin automatización del diseñador IDE.


Fenix 3.0.0.7454: auditoría estática de 176 XML, 1748 candidatos actuales y 300 nombres históricos. Las pruebas Python verifican variantes y versiones; VerifyFenix utiliza una DLL simulada reconstruida y conserva campos antiguos. Sin prueba del Fenix actualizado en vivo; disponibilidad, unidades y salidas FMA/FD completas no confirmadas.

Ghost/ATC: VerifyGhostReplay y MockGhostSim comprueban SQLite en memoria, hilo propietario, creación/freeze/animación/eliminación, pausa y ±10 s. VerifyNativeATC comprueba almacenamiento y reproducción; VerifyATCBridge.js analiza textos. VerifyIDEProjectSave guarda una copia DPROJ con TXmlIniFile. Solo pruebas sintéticas; falta validar FSLTL/ATC en vivo y guardar desde el IDE abierto.

Grupos IDE: check_project_groups.py — PASS para 2 grupos y 101 proyectos. VerifyIDEProjectSave — PASS para 103 copias XML aisladas con TXmlIniFile. Grupo principal Release Win64 — PASS (aplicación y Setup). Falta confirmar el guardado en el IDE abierto después de recargar el grupo.

Bridge/FSLTL: VerifyBridgeInstall, VerifyBridgeSignature, VerifyAIModelMatching y VerifyGhostReplay — PASS: detección de Community, instalación/actualización/reparación/eliminación, dos ZIP cifrados y firmados por separado, tipo/librea y fallback FSLTL/AIG. VerifySetupUI, VerifySetupMaintenance, VerifySetupSignature, VerifyUI y VerifySubscriptions — PASS. 75 familias y 134 hashes XML; no se distribuyen modelos ni texturas. Solo pruebas aisladas con clave CNG temporal; sin instalación real en Community ni prueba de animaciones en vivo.


## Installer source split

`VerifySetupArchitecture` creates the base DFM wizard for two unrelated synthetic
products, checks independent Program Files/release identities and navigation,
and links no FDR units. `VerifySetupUI` exercises the inherited MSFS page, back
navigation, default Community checkbox, modal retry/cancel and asynchronous
update fallback. `VerifySetupMaintenance` covers all 32 locales, RTL/LTR,
retention choices and exact-version repair. Signature, bridge ownership and
IDE XML-save probes remain isolated tests. The signed/encrypted full packager
interop test generates an encrypted ephemeral RSA key outside all repositories;
production private keys are not used. Windows installation and registry writes
are test doubles; no live installation, MSFS or Community directory is changed.

Shared sources live beside the recorder repository in `setup-common`,
`setup-core` and `MSFS24-FDR-Setup`. Version information comes directly from the
Common submodule (`src/Common/VersionU.pas`), without modifying that submodule.
The core's final license text will be supplied by the author. No new Git
repositories were created.


Release update gate: VerifySetup now checks disabled controls, forced false on save, legacy/manual INI opt-in rejection and a blocked programmatic check request. The distributed Setup is a native message-only stub, built without installer/private inputs. The real installer remains development code and requires explicit `tools/build_setup.ps1 -RealInstaller`.


Compiled resources: *.res are ignored and absent from the Git index. Main, stub
and i18n resources rebuild from checked-in *.rc (and original bitmap/icon inputs)
using tools/build_resources.py and the Windows SDK Resource Compiler. Independent
MSBuild test projects rebuild these resources through Tests.Shared.props.


Installer separation: recorder Core no longer contains the product/key unit and the
recorder DPR has no installer/common updater imports. VerifySetup uses the recorder
mutex and confirms the independent installer detects it; disabled update settings
and programmatic requests remain covered by the same isolated regression.


Las regresiones Verify*.dpr usan DUnitX (91 proyectos, incluido VerifyCatalogSources). Los tests Python de tests se trasladaron a DPR: las aserciones nativas verifican las herramientas de producción mediante su CLI con datos aislados. Los simuladores y las sondas siguen siendo programas independientes. Cada DPR dispone de DPROJ y una entrada en Tests.groupproj, sincronizados por tools/sync_test_projects.py. test.ps1 formatea antes de compilar y elimina MAP/RSM en finally. Resultados: docs/releases/0.1.1-review.md. Las pruebas de idioma cubren las 32 configuraciones sin llamar al modelo; las pruebas de píxeles comprueban CPT a la izquierda y FO a la derecha.
