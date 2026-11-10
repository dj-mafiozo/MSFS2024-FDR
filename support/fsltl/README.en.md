[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

[Translation notice](../../Translation.en.md)

# FSLTL and AIG model profiles

This catalog contains animation input facts, ICAO codes, the source commit and hashes only. No FSLTL model, texture or XML assets are shipped.

At startup a background inventory reads installed Community aircraft configurations. Ghost intersects this inventory with spawnable SimConnect models. ICAO and livery matching rank first; equal matches prefer FSLTL, then AIG, then default AI models. Exact AIG B38M beats substitute FSLTL B738. STUB entries are penalized.

FSLTLU uses generated animation input profiles, including negative jet thrust and on-ground state for reversers. Non-writable variables are disabled after a SimConnect error; visual compatibility still needs live validation. Import with `python tools/import_fsltl.py --source <local Base clone>`; verify without installed addons using `python tools/import_fsltl.py --check`.
