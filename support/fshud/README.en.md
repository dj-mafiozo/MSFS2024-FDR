# FSHud local panel reader

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

The optional integration uses the unofficial http://localhost:19786/ panel protocol; connectivity was checked with version 2.1.200. It fetches the local page and referenced script, identifies version/protocol key, connects to /ws and sends only client validation. It does not select ATC responses, change settings or control the aircraft. A manufacturer protocol change may require updating the reader.

Recorded types: ApplicationStateMessage, RadioMessagesData, MenuStateMessageData, FlightStepsMessage, RadioPanelData, RadioComChannelsMessageData, FlightPlanningMessageData, FlightSelectionDetailsMessage and UserAircraftDetailsMessage. Settings, audio and other aircraft traffic are excluded. ApplicationState omits NetworkUrls, MicrophoneRecordingStatus, CloudTrafficSettingsState and MsfsPanelZoomFactor; FlightPlanning omits CurrentSimBriefResponse.

trip_fshud_messages stores trip, type, filtered JSON, wall reception UTC and simulator time. Identical messages of a type are omitted; a new trip receives the last known baseline. The simulator clock may differ from wall time. Charts expose COM1/COM2 selected MHz and displayed squawk digits (not octal conversion; leading zeros matter). Missing data is null. Full messages are not copied into every telemetry sample.

fshud_last_observed in analysis selects the last of each type before the event's real capture time, with a 65,536-character content limit and explicit truncation. Older contacts without capture time do not receive unrelated current context. ATC instructions are evidence of instructions, not compliance and not instructions to the model.

Recording covers load-to-end, including engines-off periods. Flow events are optional; the supplied DLL uses FlightLoaded plus ten-second state polling. Pause or SimStop alone does not close a trip. No user's active flight was ended to test this boundary.

VerifyFSHud tests synthetic protocol/storage. ProbeFSHud is an optional read-only live probe. The prior live probe received all nine types and EPLL/ADOX2W/ADOXO/SOXER/SOXE2T/LL501/LL531 route points. It was not a full-flight or failure test. Manufacturer scripts and private panel captures are not distributed.
