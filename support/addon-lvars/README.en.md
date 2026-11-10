# Additional aircraft — model XML L-vars

[Interface translations](../../Translation.en.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


PMDG DC-6: 904; CSS 737 Classic: 1221; Leonardo Maddog X: 365; SkySim DC-9 (DC93/DC91F): 488; SkySim MD-11: 320. Total: 3298 provider-scoped literal names. All XML in the specified model folders were inspected, including exterior files and DC-6A/B/BP. `fields.json` records source hashes/units, 24 aircraft.cfg titles and excluded dynamic/invalid names. Full proprietary XML is not redistributed.

No public data SDK header was found in the specified DC-6 documentation; it is not treated as a 737/777 structure. These five profiles read literal `(L:...)`, never `(>L:...)` writes; template names are not guessed. SimConnect access is read-only, isolates individual failures and keeps at most one outstanding ONCE request per field. Poll intervals and bounded pumping avoid a continuous SIM_FRAME backlog for thousands of fields.

These are semantically unverified raw channels. An absent L-var can return zero; a received number proves neither support nor readiness. Errors/NaN/missing data remain null. Names alone do not establish physical units or justify overriding standard SimVars. Change history, charts and AI receive these values with that limitation. This does not add complete FMS screens or aircraft control for these models.

Verified aircraft.cfg titles and explicit add-on names are matched. Unknown custom livery titles may retain standard SimConnect; arbitrary MD-11 titles are not claimed as SkySim (e.g. TFDi).

Regenerate using `tools/generate_addon_lvars.py --models-root <folder> --root <repo>`, with PMDGDC6/CSS737/MaddogX/SkySimDC9/SkySimMD11 subdirectories containing local XML/CFG. `VerifyAddonLVars` is mock-based, not a live-flight test.
## 0.1.0.10 — active-flight subscriptions

Idle monitoring reads only TITLE, ENGINE TYPE and NUMBER OF ENGINES once per second, plus system/Flow events. FlightLoaded, AircraftLoaded and SimStart refresh identification; SimStart can confirm a flight using current FlightLoaded state. Cached AircraftLoaded state cannot start recording in the menu. Loading/session end closes full telemetry and aircraft providers; SimStop suspends subscriptions. Pause or transient SimStop is not a substitute for an explicit session boundary when splitting recordings. Old-generation packets are rejected. Shared AIRLINER variables are no longer queried for every aircraft.

Eight aircraft units replace the monolithic catalog; AddonLVarCatalogU is a small registry. Eighteen variants from six commercial families were reviewed. The previous five retain 3298 names; TFDi MD-11 GE/PW passenger/freighter adds 1446 literal model-XML L-vars. This is not a binary SDK/header integration: none was supplied at that location. Each family catalog is a union; field availability still depends on the variant. Shared-model references are not evidence of absent variables. See `support/addon-lvars/variant-audit.json`. Official locpak auditing adds 306 Bell 407/EC135 bindings: 5050 fields across eight profiles. A zero does not prove an L-var exists.

