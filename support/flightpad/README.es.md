# Pantallas MCDU de FlightPadFMC

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

FDR obtiene el texto completo de un cliente Windows actualizado, activo y conectado: FenixA320MCDU, FenixA320Screen, FBWA320MCDU o FBWA320Screen. Un EXE antiguo sin exportador no entrega texto. FDR no inicia el cliente/servidor ni pulsa teclas.

TScreenModel.ExportText, en Windows/Common/ScreenModel.pas, monta las celdas visibles en TStringList y devuelve Lines.Text: 14 filas × 24 caracteres UTF-16 con CRLF, 364 unidades UTF-16 en total. Conserva alineación, espacios, filas vacías, símbolos y scratchpad. HasScreen distingue una pantalla recibida del modelo inicial vacío; reset invalida la pantalla. El string no incluye colores ni tamaños de letra.

FMCMain publica en su temporizador existente solo si el transporte está conectado, hay pantalla recibida y no aparece una capa de estado. Funcionan clientes completos y Screen minimizados mientras siga su bucle de mensajes. No cambia páginas automáticamente.

## Protocolo local

FlightPadScreenIPCU coincide con la implementación FlightPadFMC salvo el nombre de unidad. v1 es un packed record de 776 bytes, sin punteros ni tipos dependientes de arquitectura: exportador Win32 y FDR Win64 son compatibles.

- Mapping `Local\FlightPadFMC.Screen.v1.<perfil>.<PID>`; mutex con sufijo `.Lock`.
- Perfiles FenixA320 y FBWA320; cabecera con versión, tamaño, PID, heartbeat, tick/UTC FILETIME de cambio, disponibilidad, longitud y texto.
- Mutex sin espera bloqueante; el lector enumera procesos de la sesión Windows actual y abre solo para lectura.
- Proceso/mapping ausente, formato/CRLF/longitud incorrectos o heartbeat mayor de cinco segundos significan pantalla no disponible.
- Con varias instancias gana la pantalla disponible con cambio más reciente. El modelo Airbus actual exporta solo la izquierda; no se inventa un segundo MCDU.

Ambas aplicaciones requieren la misma sesión y permisos compatibles sobre los objetos. No se necesita ruta de instalación ni puerto de red en ajustes.

## Grabación y pruebas

Al detectar el avión, cdu/0 entra en el historial FMC aunque falten L-vars numéricas. La fuente es FlightPadFMC/<perfil>; la alimentación queda desconocida porque conexión no implica MCDU encendido. Se guardan cambios con hora de simulación y observación; observed_filetime_utc conserva la hora original del exportador. El heartbeat no la modifica. Cierre, desconexión o heartbeat antiguo invalidan la pantalla actual. Las páginas vistas anteriormente son historia; transiciones más breves que el intervalo pueden perderse.

VerifyFlightPad inicia MockFlightPad32 y prueba IPC real Win32/Win64, selección de perfil/PID, Unicode, tiempos, paquetes erróneos, disponibilidad, historial y análisis. No es un vuelo Fenix/FBW real. Windows/tests/ExportTests.dpr en FlightPadFMC prueba modelos de producción, scratchpad y reset; los cuatro clientes Windows se compilaron en la etapa anterior.

FlightPadFMC-export.patch contiene exportador, metadatos de proyecto y prueba del modelo. Desde FlightPadFMC ejecute primero `git apply --check <patch>` y luego `git apply <patch>` sobre la base sin modificar. No vuelva a aplicarlo sobre archivos actualizados. tools/verify_flightpad.ps1 compara implementaciones compartidas y compila clientes locales. La licencia MIT está adjunta.
