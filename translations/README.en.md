# Interface localization

[Interface translations](../Translation.en.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


`MSFS2024-FDR.i18n` is the sole translation source. It is an uncompressed UTF-8 XML catalog in the installed i18n package's format. Edit it using the package editor or a UTF-8 text editor. The duplicate JSON catalogs and Pascal text generator have been removed.

Every definition contains all 25 locales registered in LocalizationU. The first-run language preference is automatic; Polish remains the source language. Tools → Language or Settings → General changes `[ui] language=...`. Cancel does not apply a selection. Language names remain in their native languages.

`Application` contains `Tr(...)` literals. Preserve their IDs; use the package's editor/GetStringIdentifier when adding entries. Its legacy MD5 behavior is not always equivalent to standard MD5. Form domains are class names without T, such as `frmMain` or `fraSimBrief`. Property IDs include `.Caption`, `aSettings.Caption` and `cbProvider.Items[0]`. Actions own the localized text shared by buttons/menu items. Report titles distinguish takeoff and landing, including live language changes.

Run `python tools/check_translations.py` to check locale coverage, Format placeholders, Unicode and DFM component references. Both build.ps1 and MSBuild copy the source catalog beside the executable as `bin/MSFS2024-FDR.i18n`; include it when distributing the application. Translation edits require a restart but no recompilation. Development/test executables can read `../translations/MSFS2024-FDR.i18n` when no adjacent copy exists. Missing both files is a deployment error.

Raw FMC/METAR/OFP, user data, SimVar/L-var identifiers, SQL, API/JSON keys remain unchanged. AI prompts/reports intentionally remain Polish. Package source/license: `vendor/i18n`, `support/i18n/LICENSE`.

## Readable parameter names

Charts, selection/order lists and the value inspector show descriptions with units, e.g. `Aircraft altitude [ft]` and `N1 speed — engine 2 [%]`. Labels follow the interface language. Search accepts both labels and raw identifiers; tooltips show both.

Captions are in the `Parameters` and `ParameterWords` domains of MSFS2024-FDR.i18n. Edit Translation values; Value and ID retain stable identifiers.


Earlier nine-locale implementation (superseded by the expansion below): The first-run preference is auto. Windows UI language is detected independently of number/date formats. Regional variants map to PL/EN/DE/ES/FR/RU/TR/IT/PT, with English for unsupported languages. The auto preference survives restarts; existing explicit choices are retained. Menu/settings expose auto plus nine languages. New GUI labels are included. Help remains in the existing four languages, with English help for new locales. New translations are a local Qwen3 first pass with terminology corrections and structural checks, not a native-speaker review. VersionU reads fixed/string EXE VersionInfo using its translation tables. About displays the actual file version, ProductName and copyright. Shared Build is 2 (0.1.0.2); other version numbers and author metadata are preserved. tools/bump_build.py increments only Build once per logical change; check_version.py rejects configuration overrides. CLI builds use MSBuild to generate current version resources.


Localization expansion: the interface supports 25 locales. Added en-GB, fr-CA, pt-BR, de-AT, de-CH, be-BY, el-GR, uk-UA, hr-HR, cs-CZ, da-DK, nl-NL, fi-FI, nb-NO, sk-SK and sv-SE. Regional selections are persisted separately. be means Belarusian; no/nb/nn select the available Norwegian Bokmål translation, not a separate Nynorsk translation. Swiss German uses ss instead of ß. Automatic detection follows the Windows UI language without changing numeric formats. Help remains PL/EN/DE/ES, with base-language or English fallback. New translations are a first pass with terminology corrections and structural validation, without native-speaker review. Build: 0.1.0.3; other version and author metadata are unchanged.


The interface contains 32 locales sorted by code. New: ar-SA, he-IL, hi-IN, id-ID, ja-JP, vi-VN and zh-CN. ar/he resolve to their variants; legacy iw/in aliases resolve to he/id. Arabic and Hebrew use RTL layout; charts, maps and raw FMC/METAR/OFP text remain LTR. Noto fonts in assets/fonts are deployed to bin/fonts and archives, loaded privately without system installation, with OFL licenses and provenance hashes. Help and documentation remain in four languages. Translation issue-report instructions: Translation.en.md. Build 0.1.0.4.
