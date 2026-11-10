# Official aircraft — parameter selection

[Interface translations](../../Translation.en.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Audited 120 packages and 2046 locpak files in Official2020/OneStore and Official2024/OneStore. Encrypted fsarchive files were not opened. `locpak-audit.json` records packages, source names, SHA-256 and literal bindings. Tooltip translation identifiers are not SimVar names. Some translations even translate calculator identifiers; those names must not be subscribed.

Standard selection uses the actual ENGINE TYPE and NUMBER OF ENGINES, independently of livery/vendor: piston → RECIP/PROP; jet → TURB without RECIP/PROP; turboprop → TURB/PROP; electric → PROP and common fields without piston/turbine fields. Engine indices above the actual count are omitted. Other common fields in the existing catalog are retained. Translation files do not automatically enumerate every possible SimVar.

Bell 407 has 72 additional bindings; EC135 has 234. Only numeric literal expressions unchanged across at least half of installed locales (minimum three) are selected. `A:` denotes a standard SimVar with its declared unit; other names denote L-vars. Values are recorded under the selected raw profile without speculative common-field overrides. Other packages did not expose a reliable complete additional catalog. Absence from locpak is not proof that an aircraft lacks a variable.

Regenerate with `python tools/audit_official_locpaks.py --packages-root <Packages>`, then the catalog generator documented in `support/addon-lvars`. Files and mock transport were checked locally; live-aircraft reception remains untested.
