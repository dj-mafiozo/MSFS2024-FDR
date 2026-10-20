# FlightPadFMC MCDU text

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

FDR reads full screen text from running connected updated FenixA320MCDU, FenixA320Screen, FBWA320MCDU or FBWA320Screen Windows clients. An old executable without the exporter provides no screen. FDR does not start the client or its server.

TScreenModel.ExportText in Windows/Common/ScreenModel.pas assembles rendered cells into TStringList and returns Lines.Text: 14 rows of 24 UTF-16 characters with CRLF, total 364 UTF-16 units. Alignment, spaces, blank rows, symbols and scratchpad are preserved. HasScreen distinguishes received text from an initial empty model; reset invalidates it. Colours/fonts are not part of this exporter.

FMCMain publishes on its existing timer only when transport is connected, a screen has arrived and no status overlay is present. It never presses keys or switches pages. Full and Screen clients work while minimized as long as their message loop runs.

The shared protocol implementation is identical apart from the recorder's renamed unit FlightPadScreenIPCU. v1 is a fixed 776-byte packed record without pointers/bitness-dependent types. A Win32 exporter works with Win64 FDR. Mapping: Local\FlightPadFMC.Screen.v1.<profile>.<PID>; mutex adds .Lock. Profiles: FenixA320 and FBWA320. Header includes version, size, PID, heartbeat, screen-change tick/UTC FILETIME, availability, length and text. A nonblocking mutex protects access.

The reader enumerates current-session processes and opens mappings read-only. Missing process/mapping, unavailable screen, bad format/CRLF/length or heartbeat older than five seconds means unavailable. With multiple instances, the available screen with newest change time wins. The current Airbus model exports one left screen; a second MCDU is not fabricated. Both programs need compatible object permissions in the same Windows session. No configured install path or network port is needed.

After aircraft detection the screen enters cdu/0, then the common FMC history/parser. Provider changes, disconnect/stale data and power/availability remain explicit. Data is recorded on changes; analysis uses last visible pages before the event, never future pages. Numeric catalogs alone do not provide screen text.

support/flightpad contains the exporter patch and its MIT license. tools/verify_flightpad.ps1 checks shared implementations allowing only unit-name/newline normalization and builds the local clients. VerifyFlightPad tests actual Win32/Win64 IPC, UTF-16 rows, glyphs, profile/PID selection, missing/stale data and history through a mock client. Those tests do not prove a real FlightPad server/aircraft connection.
