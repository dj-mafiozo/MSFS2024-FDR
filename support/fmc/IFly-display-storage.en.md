# iFly SDK 1.5 display storage

The complete SDK is still read. Only the copy destined for trip_aircraft_data is assembled/compacted; original data remains available for FMC parsing and verified SimConnect overrides. Catalog/layout is unchanged.

aircraft/ifly/IFlyDisplaysU.pas assembles 26 groups: flight/landing altitude, two courses, heading/altitude/speed/VS, transponder, two ADF, four NAV, three fuel quantity displays, two IRS windows and six RTP windows. Array indexes are retained, e.g. Fuel_Quantity_Indicator_Value[0], ADF_num_Value[1], NAV_num_Value[0][1]. Individual digits of these groups are omitted from new general SDK snapshots; other switches/lamps remain.

Each group has _Value, _Text and _DisplayStatus. Invalid/unknown/blank/test numeric values are null; text retains leading zeros, spaces, signs and letters. _Codes preserves packed digit codes when numeric interpretation is impossible; _Points preserves decimal-point flags. IRS retains directional text such as N51436 without guessed coordinates. An unspecified Mach decimal position yields decimal_unspecified and null.

ADF uses its indicated decimal point; NAV places are 100/10/1/0.1/0.01. RTP has three positions before/after a flagged decimal and SDK letter symbols. Fuel assembles positions 0–4 but is a display reading, not an independent mass measurement: tank names and KG/LB are not guessed. Special IRS/RTP modes and fuel units/layout still require live verification.

FMC cells LSKChar, LSK_Color, LSK_SmallFont and five CDU annunciators are omitted from general snapshots. trip_fmc_screens stores raw_text (14x24), style_json (color-font-nibbles-v1; 14 strings of 48 hex digits, colour/font nibble per cell, F unknown), annunciators_json (FAIL/MSG/EXEC/CALL/OFST: 0 OFF, 1 DIM, 2 BRI; invalid null), safe formatted_html and parsed_json. HTML is escaped and contains no scripts/external resources.

Style-only/lamp-only changes create timestamped screen records; identical rereads do not. Preflight retains appearance/lamps. Analysis receives annunciators and definitions, without duplicating large HTML. Existing databases gain nullable columns without deleting records. Old SDK deltas are reconstructed before display assembly; numeric results become chart parameters. Old screen metadata is not invented. VerifyIFlyDisplays is synthetic. Mapping source: user-supplied official SDK_Defines.h; mode-dependent display semantics are not all specified by that header.
