# Local build/runtime dependencies

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Build the Win64 application with Delphi 10.2 VCL/FireDAC. Runtime files beside MSFS2024-FDR.exe: SimConnect.dll from MSFS2024 SDK/runtime, sqlite3.dll matching Win64, and WebView2Loader.dll from WebView4Delphi bin64. Microsoft Edge WebView2 Runtime is needed for rendered Markdown. The recorder uses SQLite, not the separate earlier Firebird recorder.

WebView4Delphi source is resolved from vendor/WebView4Delphi-main or the sibling FSHudPanel/vendor folder. The i18n package is resolved from ../i18n/Packages, an explicit -I18nRoot script parameter, or vendor/i18n/Packages. IDE uses I18nRoot with the same sibling/vendor fallback. i18n is linked into the EXE; no BPL is required. Preserve the package MIT license in support/i18n/LICENSE.

Runtime DLLs, generated EXEs, local databases/configuration/logs and vendor binaries are excluded from Git. build.ps1 copies DLLs from SDK/local runtime sources. Use bin/settings.example.ini for safe configuration; do not replace an existing private settings.ini during an update. tools/package.py builds release/source archives including dependency notices and safe defaults, without recordings or credentials.

Keep `MSFS2024-FDR.i18n` beside the executable. The build script and DPROJ/MSBuild deploy it from `translations/`; no compiled-in translation catalog is used.
