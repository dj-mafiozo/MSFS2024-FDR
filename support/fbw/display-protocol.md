# Airbus display protocol and remaining coverage

The native replay decoder follows the official FlyByWire A32NX implementation:
- [FMA.tsx](https://github.com/flybywiresim/aircraft/blob/master/fbw-a32nx/src/systems/instruments/src/PFD/FMA.tsx)
- [FgBusProvider.ts](https://github.com/flybywiresim/aircraft/blob/master/fbw-a32nx/src/systems/instruments/src/PFD/shared/FgBusProvider.ts)
- [EwdMessages.ts](https://github.com/flybywiresim/aircraft/blob/master/fbw-a32nx/src/systems/shared/src/EwdMessages.ts)
- [FormattedFwcText.tsx](https://github.com/flybywiresim/aircraft/blob/master/fbw-a32nx/src/systems/instruments/src/MsfsAvionicsCommon/FormattedFwcText.tsx)

Accessed 2026-10-24. Upstream copyright FlyByWire Simulations, GPL-3.0. AirbusFMAU, AirbusMessagesU and AirbusMessageCatalog.inc retain this attribution. The generated catalog contains 530 upstream message entries. IDs are stored as numbers without losing leading-zero identity; unknown IDs remain visible as MSG plus ID. Repeated group titles are suppressed. Color, underline, frame and flashing escapes are interpreted. Flash phase and change boxes use recording time, not the replay computer clock. Old recordings cannot acquire new channels retrospectively.

FMA covers recorded active/armed thrust, vertical/lateral modes, common landing/final modes, CAT capability, AP1/AP2, FD source and A/THR status; additional lever/TCAS/speed advisories. This is not yet the entire Airbus FMA: minima, speed preselection, trim advisories and all reversion/attention effects still need integration. No unimplemented FBW `if(false)` modes are synthesized.

STS remains unavailable: both the current A32NX SDv2 StatusPage and the older SD page expose no full recorded status transport. SDv2 currently initializes a constant NORMAL. Replaying that constant as aircraft system health would be misleading. Full STS requires an actual status-text source or a complete FWC status implementation. Fenix actual FMA, EWD text and automatic SD page sources remain unconfirmed.

## Flight Director availability audit

| Integration | Confirmed command source | Result |
| --- | --- | --- |
| FBW A32NX | FMGC 1/2 ROLL_FD_COMMAND, PITCH_FD_COMMAND and YAW_FD_COMMAND ARINC words | Command channels now captured; rendering bars remains to be implemented. Engagement and selected source must also be respected. |
| iFly B38M | Installed SDK contains FD switch states, no FMA or FD command channels | Full FMA / bars cannot be reconstructed faithfully from MCP lamps. Additional documented transport needed. |
| PMDG NG3 / 777 | Current SDK catalog contains switches/annunciators, no pitch/roll FD command values | Not confirmed. |
| Fenix | Current behavior XML contains FCU FD lamps/buttons | Not confirmed; these are not command bars. |
| Other LVar add-ons | Current aircraft catalogs have no confirmed pitch/roll command pair | Not confirmed; no live claim. |

Audit covers local catalogs and inspected installed sources, not proof that proprietary software has no other interface. No live simulator verification was performed.

## Planned route / B38M update

Facilities procedure capture and explicitly labelled reconstructed iFly FMA are now implemented. See [procedures-and-ifly-fma.md](procedures-and-ifly-fma.md) for selection, geometry, persistence, heuristic rules and remaining limitations. This does not add proprietary iFly Flight Director pitch/roll commands.


Flight Director capture/rendering is now implemented for standard pitch/roll and native FBW commands; see [current FD audit](flight-director.md) for source priority, historical gaps and remaining limitations. This supersedes earlier statements that FD bars are pending.
