# PFD radio, wind, barometer and speed replay

B38M uses the recorded captain VORADF_L/R_Status[0]: 0 VOR, 1 OFF, 2 ADF. NAV1/2 active frequencies (MHz), DME (NM), HAS DME and signal, and ADF1/2 active frequencies (kHz) and signal are appended to the standard telemetry catalog. Every new field is a nullable REAL, including flags; absent old columns remain NaN. Tuned frequency does not claim reception or station identification. DME is shown only with HAS DME true; a genuine distance zero remains valid. Unknown/off selectors do not invent a VOR source. ADF has no fabricated DME. Data are captured only in the full active-flight subscription.

The wind arrow points in the direction of airflow: recorded AMBIENT WIND DIRECTION (true FROM) minus recorded true aircraft heading plus 180 degrees. Calm/missing wind or missing true heading hides the arrow. Magnetic heading is never silently substituted for TRUE. This is a heading-up arrow, not a north-up map vector.

B38M selected speed uses complete SDK MCP digits and SPD_Point_Status, including explicit blank windows. Standard fallback uses AUTOPILOT MANAGED SPEED IN MACH and the corresponding target; historical fallback can use MACH HOLD only if the mode channel is absent. FBW uses the native FCU display speed/Mach value and mode. These are selected target readouts; IAS tapes stay IAS, while actual Mach can be displayed separately. Native/standard transport availability on proprietary aircraft still requires live verification.

FBW barometer uses normal ARINC left EIS word 2: bit 28 STD, bit 29 QNH (otherwise QFE), and the native hPa/inHg word. Invalid native ARINC is unavailable, not a reason to use a stale unrelated standard value. Standard fallback, used by B38M/Fenix, reads the recorded KOHLSMAN SETTING STD flag. A true STD flag is sufficient even without a numeric pressure. QNH 1013.25 by itself does not mean STD. iFly BARO_STD_Status and Fenix/FCU interaction buttons are momentary controls and are not latched mode feedback; they are not used to invent transitions. Numeric pressure follows configured display units.

Sources checked 2026-10-25:
- [Microsoft radio SimVars](https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/SimVars/Aircraft_SimVars/Aircraft_RadioNavigation_Variables.htm)
- [Microsoft NavCom publisher: ADF in kHz](https://github.com/microsoft/msfs-avionics-mirror/blob/main/src/sdk/instruments/NavCom.ts)
- [Microsoft wind direction reference](https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/SimVars/Miscellaneous_Variables.htm)
- [Microsoft autopilot SimVars](https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/SimVars/Aircraft_SimVars/Aircraft_AutopilotAssistant_Variables.htm)
- [FBW barometer renderer](https://github.com/flybywiresim/aircraft/blob/master/fbw-a32nx/src/systems/instruments/src/PFD/AltitudeIndicator.tsx)
- Installed iFly SDK generated descriptions in iFlySDKCatalogU.

VerifyPFDReadouts is synthetic, including SQLite roundtrip. Renderer snapshots are synthetic. No live simulator verification was performed.
