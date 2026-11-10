[Notas de traducción](Translation.es.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

# MSFS24-FDR

Grabador/reproductor nativo para **Microsoft Flight Simulator 2024**, Windows 10/11 Win64. No admite MSFS 2020, FSX ni Prepar3D. Versión preparada: **0.1.1**; versión EXE completa en título y Acerca de.

## Instalación portable

1. Extraiga el ZIP completo sin contraseña conservando carpetas.
2. Ejecute `MSFS2024-FDR.exe`; mantenga DLL, fuentes, gráficos y `help/*.chm`.
3. Opcionalmente copie `Optional-Community/MSFS24-FDR-Bridge` a Community según [la guía](community/Bridge/README.en.md). El grabador no es un addon Community.

`MSFS24-FDR-Setup.exe` solo muestra un aviso de desarrollo. No instala/desinstala/actualiza; ambas opciones de actualización están bloqueadas. Actualice manualmente con programa cerrado y preserve datos. No necesita Qt/WebView2.

## Grabaciones y almacenamiento

- Configuración, logs, caché e índice `flight_data.mfzi`: `%LocalAppData%\MSFS24-FDR`.
- Cada vuelo es un SQLite .mfzr bajo `Recordings\ICAO_avión\ICAO_salida\YYYY\MM\...`, nombrado por inicio de grabación. Mes traducido y recientes primero.
- Búsqueda/grupos; importar .mfzr, flight_data.db antigua y formato Qt original; exportar un vuelo legacy sin extensiones FDR.
- Migración conserva fuente, descubre archivos añadidos y ofrece recuperación parcial tras fallo. Archivo ausente conserva metadatos del índice.
- `MSFS2024-FDR.exe ".\Recordings\flight.mfzr"`: vista individual sin biblioteca, captura ni SimConnect.

Copie toda la carpeta con programa cerrado. No borre WAL/SHM activos ni reemplace INI personal con ejemplo.

## Funciones

| Área | Funciones |
|---|---|
| Grabar | Manual/automático después de Ready for flight; intervalo ms guardado, datos según avión/motor. |
| Replay | Tiempo compartido, interpolación continua, pausa/stop, ±30 s, inicio/final, 0.125–16x; interruptores discretos. |
| Acoplar | Pestañas/frames separables, hosts principales/flotantes, estado y geometría individual guardados, proporciones. |
| Instrumentos | Six-pack, pistón/turbohélice/jet, B38M PFD/EICAS, A320 PFD/ECAM; antialiasing y proporciones. |
| B38M | FD, FMA reconstruido, ILS/baro/STD/IAS-Mach/mínimas, viento/VOR/ADF disponibles; AoA e información opcionales, CPT izquierda/FO derecha. |
| A320 | Fenix/FBW PFD/E/WD, 13 páginas SD y Recorded, FD/FMA/avisos/STS/mínimas disponibles. |
| FMC/MCDU | Pantallas/indicadores, formato/fondo, tipo automático y ventana separable sincronizada. |
| Mapa/plan | Trayectoria, plan magenta, puntos/restricciones, SID/STAR/aproximación/esperas disponibles, frustrada gris oscuro; PNG/KML. |
| SimBrief | OFP monoespaciado, mapas guardados; no presenta planes históricos en redes. |
| ATC/GSX | FSHud y ATC nativo disponible por bridge, último mensaje; servicios/progreso GSX, incluido repostaje. |
| Tiempo | Simulador/aviationweather.gov separados, METAR/TAF disponibles, decodificación/comparación. |
| Ghost | Avión AI visual, AIG/FSLTL instalado o alternativa, animaciones compatibles, ±10 s y 5–60 Hz. |
| IA | Codex CLI/Gemini/Ollama, ventanas de eventos, Markdown solicitado en idioma de la aplicación. |

Depende de datos realmente capturados por cada addon; ausencia no es cero/OFF. FMA iFly y algunos avisos son reconstrucciones. MCDU Fenix/FBW requiere cliente FlightPadFMC compatible. Addons comerciales, modelos y servicios son aparte. IA puede errar; solo simulación.

## Idiomas y ayuda

32 configuraciones regionales con autodetección Windows y fallback inglés. Herramientas → Idioma/Ajustes → General. FMC/METAR/OFP crudos y términos del cockpit intactos; nuevas respuestas IA se solicitan en idioma actual. Informes guardados no se traducen automáticamente.

F1: CHM PL/EN/DE/ES con 62 temas, árbol, búsqueda y capturas del idioma correspondiente; otros UI usan inglés. Solo CHM en distribución. [Mantener ayuda](help/README.es.md).

## Compilar y probar

Delphi 10.2 Win64, Python 3.11+, Windows SDK rc.exe y HTML Help Workshop. `git submodule update --init --recursive`; VersionU en src/Common, dependencias VCL en vendor/rutas indicadas. [Runtime](runtime/README.es.md).

- `powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1`: aplicación, stub, RC y ayuda; Delphi por -DelphiRoot/BDS/registro/PATH, SDK por -SDKRoot/MSFS_SDK.
- `powershell -NoProfile -ExecutionPolicy Bypass -File test.ps1`: DUnitX registrado; integración de instalador necesita repos vecinos correspondientes. Cada DPR tiene DPROJ/grupo.
- `tools/capture_help.ps1` y `python tools/build_help.py --require-chm`: renovar capturas y ayuda.
- `python tools/package_flightsim.py`: ZIP completo sin contraseña, CHM recompilado, comprobaciones CRC/versión/manifiesto; no publica automáticamente.

Formatter Tools/Formatter/Format_MSFS24-FDR.exe /nogui antes de compilar; RES desde RC, MAP/RSM de pruebas se limpian. [Pruebas](Testy.es.md), [release](docs/releases/0.1.1.en.md), [historial](CHANGELOG.en.md).

## Créditos e incidencias

Basado inicialmente en [MichaelHsu170/MSFS-Flight-Data-Recorder](https://github.com/MichaelHsu170/MSFS-Flight-Data-Recorder), Qt, ampliamente reconstruido. Aplicación [AGPL-3.0](LICENSE), dependencias [NOTICE](NOTICE.en.md), mapas © OpenStreetMap contributors.

[Informar problemas](https://github.com/dj-mafiozo/MSFS2024-FDR/issues): versión completa, addon, pasos y logs; revise información personal y claves antes de compartir.
