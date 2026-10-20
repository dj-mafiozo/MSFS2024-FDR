# Polish / English / German / Spanish localization

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


`MSFS2024-FDR.i18n` is the sole translation source. It is an uncompressed UTF-8 XML catalog in the installed i18n package's format. Edit it using the package editor or a UTF-8 text editor. The duplicate JSON catalogs and Pascal text generator have been removed.

Every definition contains `pl-PL`, `en-US`, `de-DE` and `es-ES`. Polish is the default. Tools → Language or Settings → General changes `[ui] language=...`. Cancel does not apply a selection. Language names remain in their native languages.

`Application` contains `Tr(...)` literals. Preserve their IDs; use the package's editor/GetStringIdentifier when adding entries. Its legacy MD5 behavior is not always equivalent to standard MD5. Form domains are class names without T, such as `frmMain` or `fraSimBrief`. Property IDs include `.Caption`, `aSettings.Caption` and `cbProvider.Items[0]`. Actions own the localized text shared by buttons/menu items. Report titles distinguish takeoff and landing, including live language changes.

Run `python tools/check_translations.py` to check locale coverage, Format placeholders, Unicode and DFM component references. Both build.ps1 and MSBuild copy the source catalog beside the executable as `bin/MSFS2024-FDR.i18n`; include it when distributing the application. Translation edits require a restart but no recompilation. Development/test executables can read `../translations/MSFS2024-FDR.i18n` when no adjacent copy exists. Missing both files is a deployment error.

Raw FMC/METAR/OFP, user data, SimVar/L-var identifiers, SQL, API/JSON keys remain unchanged. AI prompts/reports intentionally remain Polish. Package source/license: `vendor/i18n`, `support/i18n/LICENSE`.

## Readable parameter names

Charts, selection/order lists and the value inspector show descriptions with units, e.g. `Aircraft altitude [ft]` and `N1 speed — engine 2 [%]`. Labels follow the interface language. Search accepts both labels and raw identifiers; tooltips show both.

Captions are in the `Parameters` and `ParameterWords` domains of MSFS2024-FDR.i18n. Edit Translation values; Value and ID retain stable identifiers.
