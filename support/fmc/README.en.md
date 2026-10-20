FMC/MCDU screen history
======================

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

FMCScreens.TFMCScreen owns a TStringList named Lines. It holds 14 fixed-width
rows of 24 display characters and exposes Lines.Text as raw multiline text,
with Windows CRLF separators and trailing blank rows/columns preserved.
FireDAC queries explicitly disable StrsTrim for this data.

Sources currently providing text:
- iFly: LSKChar[device][row] plus LSK_Color glyph codes (arrows, degree, boxes).
  Packed colors/fonts, formatted HTML and CDU lamps are stored with each screen;
  new general SDK snapshots omit duplicated FMC cells. See IFly-display-storage.md.
  Brightness is not treated as proof that the screen is powered.
- PMDG NG3: decoded Client Data CDU rows, power state and original cell bytes.
- Fenix A32X / FBW A32NX: the running, connected FlightPadFMC Windows client
  exports its rendered 14x24 MCDU text through local shared memory. Both full
  MCDU and Screen clients are supported. See ../flightpad/README.md.
- Any future provider can supply the same cdu/<device>/rows JSON contract.
The Fenix/FBW numeric L-var catalogs do not expose screen text themselves;
their text source is the updated FlightPadFMC client, when available.
No MCDU text is invented from button events or numeric indicator states.

SQLite table trip_fmc_screens stores one row for each observed change in text,
availability or power. It stores trip/sample, simulation UTC, wall capture UTC,
provider/device, page key/title, power state, raw_text and conservative parsed
values. Unavailable text is SQL NULL. Identical text with unchanged status does
not create another row. Unknown power is -1, off is 0, on is 1.

Pages are classified as PERF INIT, N1 LIMIT, TAKEOFF REF and APPROACH REF;
other titles are retained too. Page numbers such as 1/2 remain in the cache key,
as do pending MOD variants, so page 2 does not erase the text from page 1.

Preflight:
The recorder observes supported screens at the configured interval while the
simulator is running and recording is enabled, even before engines start.
FMCPreflight buffers the most recent 4096 changed snapshots and separately
retains the last observation of every page. When a flight starts, it attaches
these preparation observations to the new trip in a transaction, preserving
both original timestamps. Preflight rows use sample=0 because no flight-data
snapshot existed then. History trimming does not erase the last PERF INIT or
N1 LIMIT page. Aircraft changes, explicit stop and simulator disconnect/running
state changes clear the preparation cache. Closing the app before a flight
starts discards the in-memory preparation cache.

Analysis:
fmc_last_observed contains the last screen per device, last observed page
versions and last parsed values per provider/device at or before the event.
It reads the complete trip history, including preparation and pages outside
the selected analysis window. Later observations are excluded. Last known
pages remain available after navigating away; they are not a continuous read
of hidden FMC memory. Observation timestamps are the first observation of a
changed screen, not proof of the exact internal edit time. Repeated identical
reads are omitted. Power/off/unavailable state and pending MOD pages remain
explicit. Different devices are not silently merged.

Initial parsing handles explicit V1, VR, V2, VAPP, VREF and wind-correction
labels, including right-aligned Boeing value rows. A shown but blank/invalid
label gives null rather than carrying a previously parsed number forward.
Multi-row VREF tables are not reduced to a guessed selected speed. MOD values
are retained as raw pages but not promoted to executed active references.
Typed SDK references have priority. All remaining page text stays available
for further parsing. Boeing PERF INIT, N1 LIMIT and TAKEOFF REF performance
fields are now extracted too: see [Boeing-performance.md](Boeing-performance.md).

Fenix/FBW now use a separate Airbus label/data-row parser for TAKE OFF,
APPR, INIT A/B and supported PERF labels. It includes VLS, FLEX, THS,
altitude references, entered approach weather and minima. See Airbus-MCDU.md
for keys, units and limits. Existing Airbus raw screens are reparsed when
building analysis context; original database records are preserved.

The app reads displayed pages only; it does not navigate the FMC, press keys
or request hidden pages. Open PERF INIT, N1 LIMIT, TAKEOFF REF and APPROACH REF
in the simulator to make their text observable. Recording uses the configured
millisecond interval, so briefer transient screens may not be observed.
Existing recordings are not automatically backfilled into the new table.

VerifyFMC checks fixed-width TStringList text, iFly glyphs, exact SQLite string
round trip, status changes, timestamps, page numbering, preflight retention
under history pruning, future exclusion, out-of-window page context, MOD
isolation, cleared/ambiguous values and trip deletion. ProbeFMCScreens.dpr is
an optional read-only iFly live probe. The live attempt during this change
found SDK state=0 (not running), so live screen reception remains unverified.
