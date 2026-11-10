# Dependencias de compilación y ejecución

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)
[Traducciones de la interfaz](../Translation.es.md)


## Datos de usuario y reproducción FMC nativa — 0.1.0.8

Los ajustes, `flight_data.db`, registros, volcado de errores, caché del mapa y archivos de trabajo del análisis están en `%LocalAppData%\MSFS24-FDR\`, creado antes de inicializar la aplicación. DLL, traducciones, fuentes, ayuda y `Assets` permanecen junto al EXE. No se necesitan permisos de escritura en Program Files. El instalador se añadirá después.

Cierre la versión anterior antes del primer inicio. Se trasladan los ajustes, la base predeterminada con WAL/SHM y los registros del directorio del EXE antes de abrir la base. Los archivos existentes en AppData tienen prioridad; los conflictos permanecen en origen sin fusionarse. Si no hay permiso para borrar el origen, se conserva la copia antigua. La publicación interrumpida continúa desde `migration.pending`; un escritor antiguo activo provoca un error de inicio. Haga una copia de la base cerrada antes de actualizar.

WebView2 ya no se usa ni se requiere. El OFP utiliza `TMemo` nativo de solo lectura, con Consolas, sin bordes ni barras propias, con altura según las líneas; se desplaza el contenedor exterior. Los informes de IA usan `TRichEdit` nativo con títulos, negrita y listas, sin ejecutar HTML ni scripts.

**FMC/MCDU** muestra la última pantalla guardada hasta la hora del cursor, por dispositivo. **Ventana separada** mueve el mismo frame a una ventana `bsDialog`; cerrar o pulsar de nuevo lo devuelve. Se mantienen sincronizados el registro y el tiempo. Los fondos B737/A320/B777 conservan sus proporciones; `style_json` y `annunciators_json` guardados controlan colores, letras pequeñas e indicadores. Los estados apagado/no disponible ocultan texto antiguo. Los registros anteriores y la exportación actual de solo texto FlightPad para Fenix/FBW carecen de formato/indicadores completos; no se inventan datos. El fondo B777 no añade un grabador SDK PMDG 777.




Git excluye DLLs, EXEs, bases privadas, ajustes y logs. build.ps1 copia DLLs desde SDK/fuentes locales. Use bin/settings.example.ini como plantilla segura sin reemplazar la settings.ini privada en actualizaciones. Los intermedios se guardan en .build/<Platform>/<Config> y las DCU de pruebas se separan por arquitectura. tools/package.py crea paquetes de fuentes/ejecutable con licencias y valores seguros, sin grabaciones ni credenciales.
