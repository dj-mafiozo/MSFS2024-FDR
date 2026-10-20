The first implementation of MSFS2024-FDR was based on the user-supplied MSFS-Flight-Data-Recorder-master source tree, originally a Qt application.
Since that starting point, the architecture, recording pipeline, native interface, aircraft integrations, database handling and analysis workflow have been extensively rebuilt, corrected and expanded. The current Delphi VCL application is a substantially different implementation, while retaining attribution for the original project and the portions derived from it.
Original project license: GNU Affero General Public License version 3 (LICENSE).
The telemetry/event catalogs and SQLite database schema are derived from the original project's X-macros and database definitions.
Qt, QML, Qt Graphs, Qt WebEngine and Qt WebChannel are not used or distributed by this port.
The port uses Delphi VCL/FireDAC, the provided SQLite runtime, and Microsoft SimConnect.
Map tiles are provided by OpenStreetMap; attribution is displayed on the native map.

The iFly shared-memory field catalog (2411 fields, pack(8), 3240 bytes) and field descriptions are derived from the locally supplied official iFly 737 MAX SDK v1.5 SDK_Defines.h. Header SHA-256: 0de480c86c173b0e69a79a406bfe4d90671a5417e0d88a2a9779a36fc0de02d4. No iFly binaries or complete SDK are bundled.

The Fenix L-var catalog is derived from template parameter names in the locally supplied Fenix A320 Cockpit_Behavior.xml. It is not an official Fenix SDK. No Fenix binaries or complete cockpit XML files are distributed.

FlyByWire A32NX integration uses variable names and API metadata from the user-supplied Flight Deck API documentation, plus readiness and speed-unit facts from the official custom L-var reference: https://github.com/flybywiresim/aircraft/blob/master/fbw-a32nx/docs/a320-simvars.md . No complete FBW documentation, aircraft files or binaries are bundled.

PMDG NG3 integration derives field names, type layout, constants and descriptions from the user-supplied PMDG_NG3_SDK.h, Copyright (c) 2025 Precision Manuals Development Group. The complete proprietary header and aircraft binaries are not distributed. Only read-only data/CDU client areas are used.

Localization uses i18n, Copyright (C) 2010–2014 Kambiz Khojasteh, under MIT; see support/i18n/LICENSE. It is statically linked; source archives preserve its license. WebView4Delphi/Microsoft WebView2 retain their respective notices. FlightPadFMC has its separate MIT license in support/flightpad/LICENSE.md.

Original project: [MichaelHsu170/MSFS-Flight-Data-Recorder](https://github.com/MichaelHsu170/MSFS-Flight-Data-Recorder), by MichaelHsu170, AGPL-3.0. The supplied Qt5 version was the starting point; this does not describe the Qt version used by current upstream.
