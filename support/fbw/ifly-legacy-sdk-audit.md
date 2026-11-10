# Additional legacy iFly SDK recording audit

Audited 2026-10-25 using SQLite mode=ro and query_only. Source supplied by the project owner: `legacy flight_data.db`. No database import, repair or modification was performed. SQLite quick_check: ok. Raw recordings are not copied into the repository.

## Recorded coverage

All four trip entries identify iFly 737 MAX8 LOT SP-LVA. Trip 1 has 4568 standard samples and no SDK entries; trip 2 has no standard samples. Trip 3 has one standard sample and one SDK entry. Trip 4 has 5256 standard samples (2026-10-17 11:28:04.711 to 12:02:00.844 UTC) and 5251 SDK entries, including two reset markers. Only one of the SDK-associated standard rows exceeds 100 knots: sample count must not be mistaken for coverage of an entire airborne flight.

Replaying SDK field deltas in memory across trip 4 finds 2411 distinct field names. After reset handling, 5249 rows contain the following AFDS fields:

| Field | Observed raw values and row counts |
| --- | --- |
| FD_1_Switch_Status | 0: 2387; 1: 2862 |
| FD_2_Switch_Status | 0: 2385; 1: 2864 |
| CMD_A_Switch_Status | 0: 3430; 2: 1816; 5: 3 |
| CMD_B_Switch_Status | 0: 5249 |
| AT_Switch_Status | 0: 2565; 1: 2684 |
| LNAV_Switch_Status | 0: 4271; 2: 968; 3: 8; 5: 2 |
| VNAV_Switch_Status | 0: 3328; 2: 1917; 5: 4 |
| APP_Switch_Status | 0: 4983; 2: 264; 5: 2 |
| HDG_SEL_Switch_Status | 0: 5121; 2: 128 |
| LVL_CHG_Switch_Status | 0: 5086; 2: 161; 3: 1; 5: 1 |
| N1_Switch_Status | 0: 4853; 2: 396 |
| SPEED_Switch_Status | 0: 4648; 2: 601 |

These are counts after carrying deltas forward, not counts of independent SDK broadcasts or distinct state transitions. Transient values 3 and 5 are actually present; they must not be treated as generic boolean on/off without the documented button/lamp encoding. CWS A/B, ALT HLD and VS remain zero in this recording; this does not exercise their active behavior.

## Conclusions and limits

This provides real historical SDK observations for FD selection, CMD A and MCP lamp reconstruction, including button press transients. It is useful regression evidence for IFlyFMAU, but not a recorded authoritative FMA text feed: no field name containing FMA, pitch, roll, FlightDirector or FD command was found. No standard FD angular columns exist either. It cannot verify Flight Director command geometry, standard SimConnect FD population by iFly, or all airborne FMA transitions. It does not alter the conclusions of [the Flight Director audit](flight-director.md) for the older 4568-sample recording.

## Renderer regression follow-up

22 distinct AFDS configurations were extracted into `tests/fixtures/ifly-sdk-afds.json`, containing only selected numeric AFDS/MCP fields and sample identity, not the full flight database. VerifyIFlyFMA now tests CMD/FD selection and reconstructed SDK N1/MCP SPD with standard AP/A/T false. Expectations verify decoding and reconstruction consistency; they are not authoritative FMA ground truth. The recorded MCP displays include altitude 13000, heading 244 and speed 137, fully blank speed windows, and altitude 3000 with a blank leading digit. Decimal Mach and blanks are decoded without substituting zero.

The B38M renderer follows the user-supplied reference images: crossbar FD, black/white aircraft symbol, extended horizon background, aligned IAS/ALT/VSI, half compass rose and GS/TAS/wind. The optional AoA is disabled by default, uses new nullable `INCIDENCE ALPHA` samples (radians converted to degrees), and does not synthesize a red shaker threshold without a recorded source. Old recordings show unavailable AoA.

References: [Microsoft INCIDENCE ALPHA](https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/SimVars/Aircraft_SimVars/Aircraft_FlightModel_Variables.htm), [Boeing optional AoA description](https://www.boeing.com/commercial/737max/737-max-update/737-max-software-updates). No live simulator validation was performed.
