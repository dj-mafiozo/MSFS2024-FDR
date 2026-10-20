# MSFS 2024 EFB flight plans

The primary source for the current plan is the official GET_EFB_ROUTE
API, accessed using the updated mateusz-efb-ifly Community app. The app sends the complete
native route JSON to a loopback-only receiver at 127.0.0.1:19787/efb-route every
five seconds while the iFly EFB app is open. The iframe remains localhost:8084.
Neither the aircraft FMC nor the planner is modified.

1. Update the recorder executable and DLLs, preserving flight_data.db and settings.ini.
2. Copy Community/mateusz-efb-ifly from the release archive into the simulator's
   Community directory, replacing the previous version. Restart MSFS.
3. Prepare the plan in the default EFB planner, then open the iFly EFB app.
   Its status should say "FDR: EFB route sent" while the recorder is running.
4. The recorder retains the latest received plan for the current/next recording.
   During a recording, a changed plan adds a revision to trip_flight_plans;
   identical repeats are skipped. Select/refresh a recorded flight to view its
   latest saved plan in the "Plan lotu" tab. Original JSON/XML remains available.

Transmission stops when the iFly EFB app is closed/paused. Reopen it after editing
the default planner to refresh the recorder. The bridge needs live verification
inside MSFS; the automated tests mock the simulator API and exercise a real local
HTTP receiver. If the port is occupied, recording still works and a warning is logged.

## Optional exported PLN files

MSFS 2024 does not save the EFB plan to a PLN file by default. PLN files can be
exported explicitly for later reuse. Live route capture therefore uses
GET_EFB_ROUTE and does not depend on a PLN file existing on disk.

### SimConnect and manual import fallback

The recorder requests the active FlightPlan system state on connection and every
10 seconds, also refreshing after FlightPlanActivated/FlightPlanDeactivated.
If MSFS supplies an accessible PLN path, it is imported unless a live EFB plan has
already been received. No search for the newest unrelated PLN is performed.
A manually selected PLN can be assigned to the current/next recording using
"Plan lotu > Wczytaj PLN dla nagrania". A subsequent live EFB update takes precedence.

Optional settings.ini section (defaults shown):

```ini
[flightplan]
bridge_enabled=true
bridge_port=19787
fallback_pln=
```

fallback_pln can contain an explicit PLN path loaded at recorder startup.
Changing bridge_port also requires changing the endpoint in EFBRouteBridge.js
and rebuilding the EFB package. No firewall rule or public listener is installed.

## Your test routes

- EPMO.08 SOXE4C SOXER DCT KUXEN KUXEN ILS.08 EPMO.08
- EPLL.25 ADOX2W ADOXO DCT SOXER SOXE2T LL501 ILSZ.25 EPLL.25

The confirmed EPMO departure procedure is SOXE4C.
Both supplied PLN files contain procedure selections but no ATCWaypoint list or
coordinates, so they cannot reconstruct the full enroute path on their own.
The EPLL file contains ADOX2W, SOXE2T and ILS Z runway 25 via LL501.
The EFB JSON includes enroute legs, airports, runways and procedure identifiers.
Procedure identifiers alone are not expanded into SID/STAR/approach geometry.
The map shows only explicit valid coordinates (magenta), breaks lines across
missing positions, and retains the actual flown track separately. Facility-only
legs and procedures need navdata resolution before their full geometry can be drawn.

Official references:
- https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/JavaScript/Coherent_Calls/GET_EFB_ROUTE.htm
- https://docs.flightsimulator.com/msfs2024/html/6_Programming_APIs/JavaScript/Coherent_Listeners/JS_LISTENER_PLANNEDROUTE.htm
- https://docs.flightsimulator.com/msfs2024/retail/programming-apis/simconnect/api-reference/general/simconnect_requestsystemstate/
