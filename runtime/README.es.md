# Dependencias de compilación y ejecución

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Compile Win64 con Delphi 10.2 VCL/FireDAC. Junto a `MSFS2024-FDR.exe` deben estar SimConnect.dll Win64 del SDK/runtime MSFS2024, sqlite3.dll, WebView2Loader.dll de WebView4Delphi bin64 y MSFS2024-FDR.i18n. Los informes Markdown requieren Microsoft Edge WebView2 Runtime. Este grabador usa SQLite, separado del anterior iFly/Firebird.

Fuentes WebView4Delphi: vendor/WebView4Delphi-main o FSHudPanel/vendor vecino. i18n: ../i18n/Packages, -I18nRoot explícito o vendor/i18n/Packages; DPROJ aplica la misma selección I18nRoot. La biblioteca se enlaza estáticamente y no requiere BPL. Conserve la licencia MIT de support/i18n/LICENSE. Los textos sí son externos: MSFS2024-FDR.i18n se copia desde translations/ junto al EXE mediante el script y MSBuild.

Git excluye DLLs, EXEs, bases privadas, ajustes y logs. build.ps1 copia DLLs desde SDK/fuentes locales. Use bin/settings.example.ini como plantilla segura sin reemplazar la settings.ini privada en actualizaciones. Los intermedios se guardan en .build/<Platform>/<Config> y las DCU de pruebas se separan por arquitectura. tools/package.py crea paquetes de fuentes/ejecutable con licencias y valores seguros, sin grabaciones ni credenciales.
