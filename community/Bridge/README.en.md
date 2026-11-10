OPTIONAL MSFS24-FDR-BRIDGE

The Setup wizard installs MSFS24-FDR-Bridge in the selected MSFS 2024 Community.
Its checkbox is enabled by default; updates/repair preserve that choice.
Uninstall removes only the recorded bridge files, leaving other addons untouched.
MSFS24-FDR-Bridge.zip and its detached signatures remain beside the application;
it is encrypted with the same password as the release and verified independently.
Restart the simulator, open MSFS24-FDR-Bridge in the simulator toolbar,
and keep that panel open or minimized while recording. Do not copy the
recorder application itself to Community. No iFly EFB package is included.

The panel polls http://127.0.0.1:19787/weather/requests and returns read-only
METAR/TAF replies. The recorder route bridge must be enabled. For a custom
port, edit html_ui/InGamePanels/FDRBridge/weather-config.js to match it.
No simulator controls are sent. If the bridge is absent, recordings continue
and simulator weather is marked unavailable.

At takeoff/touchdown the recorder requests simulator weather and independently
fetches real METAR from aviationweather.gov. Both are saved in the recording.
Nearest-station fallback is identified by its actual ICAO. Different stations,
observation times and decoded weather fields are reported separately. A preset
or historical simulator weather report need not match real-world weather.

Open METAR / TAF in the recorder to view raw and decoded reports. Requests for
historical real METAR never substitute today's simulator weather for old flights.
TAF availability depends on the simulator. METAR decoding retains unknown groups.
New weather terminology uses English fallback outside Polish where not translated.

Build: python tools/build_bridge_addon.py stages the ready package in bin.
The supplied SPB was generated with the MSFS 2024 SDK. Rebuild its XML definition
with --compiler <path-to-fspackagetool.exe> when changing the panel definition.
HTTP/Coherent responses were tested with mocks. In-simulator operation and panel
lifetime still require live validation; opening the toolbar panel is required.

Native ATC: the same panel now registers JS_LISTENER_ATC and posts ATCDialogLine
events to /atc/messages. Known string/object text fields are extracted; the raw
payload is retained when the undocumented event shape cannot be decoded. A bounded
queue retries network failures; IDs suppress retries and capture timestamps reject
messages queued before the current recording. No ATC options are selected.
Default ATC and FSHud share replay history, retaining their source identifiers.
ATC/COM states are polled through the recorder SimConnect connection once per second
only while recording an active MSFS24 flight. Optional unavailable fields are disabled
for that connection. The native listener payload still needs in-simulator validation.
