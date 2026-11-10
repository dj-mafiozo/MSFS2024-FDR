# Local build/runtime dependencies

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)
[Interface translations](../Translation.en.md)


## User data and native FMC replay — 0.1.0.8

Settings, `flight_data.db`, logs, crash dump, map cache and analysis working files now live in `%LocalAppData%\MSFS24-FDR\`, created before application initialization. DLLs, translations, fonts, help and `Assets` stay beside the EXE. No write access to Program Files is needed. The installer will follow separately.

Close the previous recorder before the first launch. Existing settings, the default database with its WAL/SHM files, and logs are migrated from the EXE directory before opening the database. Existing AppData files take precedence; conflicting legacy files are retained without merging. If deleting a legacy file is forbidden, its original copy remains. Interrupted publication resumes from `migration.pending`; an active legacy writer produces a startup error rather than an inconsistent copy. Back up the closed database before updating.

WebView2 is neither used nor required. OFP uses a read-only native Consolas `TMemo`, without borders or internal scrollbars, sized to its line count; the outer container scrolls. AI reports use native `TRichEdit` headings, bold text and lists, without executing HTML/scripts.

The **FMC/MCDU** tab selects the latest recorded screen at or before the timeline cursor, independently for each device. **Separate window** reparents the same frame into a `bsDialog` window; closing or clicking again docks it back. Recording/time changes remain synchronized. B737/A320/B777 backgrounds retain their aspect ratio; recorded `style_json` and `annunciators_json` drive colors, small fonts and lamps. Off/unavailable states suppress stale text. Old recordings and the current text-only Fenix/FBW FlightPad export lack full formatting/lamp data; missing values are not invented. The B777 background does not itself add a PMDG 777 SDK recorder.




Runtime DLLs, generated EXEs, local databases/configuration/logs and vendor binaries are excluded from Git. build.ps1 copies DLLs from SDK/local runtime sources. Use bin/settings.example.ini for safe configuration; do not replace an existing private settings.ini during an update. tools/package.py builds release/source archives including dependency notices and safe defaults, without recordings or credentials.

Keep `MSFS2024-FDR.i18n` beside the executable. The build script and DPROJ/MSBuild deploy it from `translations/`; no compiled-in translation catalog is used.
