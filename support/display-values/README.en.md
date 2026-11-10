# Display-value label audit

[Translation notice](../../Translation.en.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

5118 fields have mappings, including 2313 additions. The audit reads iFly, PMDG NG3 and PMDG 777 SDK headers and 335 XML files across available Fenix/FBW/iFly/DC-6/CSS/Maddog/SkySim/TFDi variants. Further boolean labels use previously inventoried explicit XML units, including Bell 407 and EC135.

`catalog.json` contains labels, extraction rules, source references and SHA-256 hashes. It does not redistribute aircraft XML or SDK headers. Re-auditing requires local source files; runtime only uses compiled Pascal catalogs. Generators preserve metadata through `apply_display_values.py`.

Evidence includes explicit enums, ANIMTIP, explicit press=1/release=0 writes and typed booleans. iFly comments are decoded as GB18030. Partial enums map only documented values. Continuous ranges, undocumented positions, reversed FO selectors and private WASM state are never guessed. Fourteen malformed XML files contribute only independently valid UseTemplate fragments. A display mapping does not prove live data availability.

Run `test.ps1 -Tests VerifyCatalogSources,VerifyParameterValues` and `python tools/apply_display_values.py --check`. Delphi VerifyParameterValues tests actual formatting. No new live validation.

## Standard SimConnect flap index

`FlapsHandleU.pas` has a separate ICAO case; the global SimFields DisplayValue for flaps_handle_index stays empty. Profiles/sources are in `flaps.json`; [flaps-coverage.csv](flaps-coverage.csv) lists coverage. Generate with `python tools/generate_flap_profiles.py` or validate with `--check`.

156 explicit codes: 66 profiles (some title-dependent), 30 types without wing flaps, 60 unverified. This is not full coverage of all default aircraft. Local MSFS 2024 default configurations were encrypted; evidence includes 26 available addon configurations, simulator manuals and manufacturer reference profiles. A reference_profile is not live-verified. Unknown or ambiguous layouts return an empty dictionary and keep numeric display.

Standard Airbus indices 0/1/2/3/4/5 mean UP/1/1+F/2/3/FULL, unlike SDK lever positions 0..4. TFDi and SkySim MD-11 layouts differ despite sharing ICAO; the recorded title disambiguates them. Recorded FLAPS NUM HANDLE POSITIONS overrides references: count mismatch disables a profile. A matching count does not establish identical angles in every third-party modification of that ICAO. Nominal detent labels are not measured surface deflections.
