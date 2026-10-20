# Leser des lokalen FSHud-Panels

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Die optionale Integration verwendet das inoffizielle Panelprotokoll `http://localhost:19786/`; Verbindung zuvor mit Version 2.1.200 geprüft. Der Leser holt Seite und referenziertes lokales Skript, erkennt Version/Protokollschlüssel, verbindet /ws und sendet nur die Clientvalidierung. Keine ATC-Antwortwahl, Einstellungsänderung oder Flugzeugsteuerung. Herstelleränderungen können eine Anpassung erfordern.

Gespeicherte Typen: ApplicationStateMessage, RadioMessagesData, MenuStateMessageData, FlightStepsMessage, RadioPanelData, RadioComChannelsMessageData, FlightPlanningMessageData, FlightSelectionDetailsMessage und UserAircraftDetailsMessage. Einstellungen, Audio und anderer Verkehr fehlen absichtlich. ApplicationState entfernt NetworkUrls, MicrophoneRecordingStatus, CloudTrafficSettingsState und MsfsPanelZoomFactor; FlightPlanning entfernt CurrentSimBriefResponse.

trip_fshud_messages speichert trip, Typ, gefiltertes JSON, Empfangs-UTC und Simulatorzeit. Identische Meldungen je Typ entfallen; neue Flüge erhalten den letzten Basiszustand. Simulator- und Echtzeit können voneinander abweichen. Diagramme enthalten FSHud.COM1_selected_MHz, FSHud.COM2_selected_MHz und FSHud.squawk_display. Squawk sind angezeigte Ziffern, keine Oktalumrechnung; führende Nullen beachten. Fehlendes bleibt null. Vollständige Meldungen werden nicht in jede Telemetrieprobe kopiert.

fshud_last_observed wählt pro Typ den letzten Zustand vor der realen Erfassungszeit des Ereignisses, bis 65536 Zeichen mit ausdrücklicher Kürzungsangabe. Ältere Kontakte ohne Erfassungszeit erhalten keinen zufälligen aktuellen Kontext. ATC-Anweisungen beweisen nicht ihre Befolgung und sind keine Anweisungen an das KI-Modell.

Aufzeichnung vom Laden bis zum Flugende, auch ohne laufende Motoren. Wenn verfügbar, werden Flow-Ereignisse verwendet; die untersuchte DLL nutzt ersatzweise FlightLoaded und Zustandsabfragen alle zehn Sekunden. Pause oder SimStop allein beendet keinen Flug. Kein aktiver Benutzerflug wurde zur Grenzprüfung beendet.

VerifyFSHud prüft synthetisches Protokoll und Speicherung. ProbeFSHud ist optional und nur lesend. Der frühere Liveprobe empfing neun Typen und EPLL/ADOX2W/ADOXO/SOXER/SOXE2T/LL501/LL531. Dies war kein vollständiger Flug oder Ausfalltest. Herstellerskripte und private Mitschnitte werden nicht verteilt.
