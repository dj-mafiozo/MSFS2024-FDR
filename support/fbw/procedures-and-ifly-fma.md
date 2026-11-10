# SimConnect procedure capture and iFly FMA reconstruction

ProcedureRouteU uses SimConnect_AddToFacilityDefinition and SimConnect_RequestFacilityData on the existing connection. Definition 600 contains airport MAGVAR, DEPARTURE/ARRIVAL with common, RUNWAY_TRANSITION and ENROUTE_TRANSITION legs, and APPROACH with IAF, final and missed legs. It captures named fix coordinates, ARINC leg type, turn/course, true/magnetic flag, distance/time, altitude descriptors, altitude values, speed limit, arc center and origin fields. Definitions match the installed MSFS 2024 SimConnect.h and official Facilities reference. No EFB/Community bridge is needed for the facility requests themselves; the selected route still comes from the existing PLN/EFB sources.

Selections are read from PLN header/details and per-waypoint procedure fields, or EFB route identifiers. Procedure names, runway number/designator, approach type/suffix and named transitions must match. Unknown/ambiguous selection is not expanded by picking the first procedure. The API response uses request generation, airport, parent IDs and ItemIndex. A list-size mismatch or orphan response is not published. Disconnects and session end cancel pending requests. Airport responses time out after 30 seconds. Raw requested nodes, including legs which cannot be geometrically resolved, are retained in a versioned snapshot.

The existing trip_flight_plans table stores an FDR ROUTE envelope containing original format/raw data and the navdata snapshot. Original raw plan is unchanged in memory, so periodic capture remains deduplicated. SimBrief matching unwraps the original plan. Recording import/export already carries trip_flight_plans and therefore retains the snapshot without a new table. Replay does not request simulator navdata.

Selected route order is SID runway/common/enroute, original enroute points, STAR enroute/common/runway, approach transition/final/missed. RF and AF arcs use published centers when endpoints form a consistent circle and turn direction is known; invalid arc geometry creates a discontinuity. Vector/manual/altitude terminated legs retain metadata and create gaps; no artificial straight track is drawn for them. Procedure turns are not predicted. HA/HF/HM parameters are retained; their fixed-size map symbol is schematic, not an aircraft performance prediction. The symbol course is the recorded course reference. Missed approach is dark gray; planned route magenta lies beneath the wider actual trajectory and waypoint labels remain visible.

iFly FMA uses recorded six-state MCP switch/lamp data (0/3 unlit, 1/2/4/5 lit), FD switches, A/T arm, standard autopilot active/captured/armed flags and flight state. Reconstructed families include N1, MCP/FMC SPD, ARM, RETARD, THR HLD, LNAV/HDG SEL/VOR LOC/TO GA, VNAV SPD/PTH/ALT, MCP SPD, ALT ACQ/HOLD, V/S, G/S, TO GA, dual-channel FLARE/ROLLOUT and armed ILS indications. AP/FD engagement and A/T remain independent. The screen is explicitly labelled FMA RECONSTRUCTED.

These are heuristic rules, not a certified reconstruction of proprietary FCC software. VNAV PTH is inferred from descending with a small selected-speed error; ALT ACQ from closing the MCP altitude inside about seven seconds; THR HLD from takeoff power above 84 kt below 800 ft; dual-channel FLARE below 50 ft. Missing SDK produces unavailable indications. No new telemetry channels are required and old recordings with sufficient data can be replayed. Not all proprietary protections/reversions can be distinguished from this data. Direct FMA output should supersede reconstruction if iFly exposes it later.

Tests are synthetic/mocked. No live flight validation has been performed.

References:
- https://docs.flightsimulator.com/html/Programming_Tools/SimConnect/API_Reference/Facilities/SimConnect_AddToFacilityDefinition.htm
- https://docs.flightsimulator.com/html/Programming_Tools/SimConnect/API_Reference/Structures_And_Enumerations/SIMCONNECT_RECV_FACILITY_DATA.htm
- %MSFS_SDK%/SimConnect SDK/include/SimConnect.h
- src/Aircraft/iFly/iFlySDKCatalogU.pas (installed SDK field descriptions)


Flight Director capture/rendering is now implemented for standard pitch/roll and native FBW commands; see [current FD audit](flight-director.md) for source priority, historical gaps and remaining limitations. This supersedes earlier statements that FD bars are pending.
