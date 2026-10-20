# Lector del panel local FSHud

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

La integración opcional utiliza el protocolo no oficial de `http://localhost:19786/`, comprobado anteriormente con la versión 2.1.200. Obtiene página y script local referenciado, identifica versión/clave, conecta a /ws y solo envía validación del cliente. No selecciona respuestas ATC, cambia ajustes ni controla el avión. Cambios del fabricante pueden requerir adaptar el lector.

Tipos guardados: ApplicationStateMessage, RadioMessagesData, MenuStateMessageData, FlightStepsMessage, RadioPanelData, RadioComChannelsMessageData, FlightPlanningMessageData, FlightSelectionDetailsMessage y UserAircraftDetailsMessage. Se excluyen ajustes, audio y tráfico ajeno. ApplicationState elimina NetworkUrls, MicrophoneRecordingStatus, CloudTrafficSettingsState y MsfsPanelZoomFactor; FlightPlanning elimina CurrentSimBriefResponse.

trip_fshud_messages guarda trip, tipo, JSON filtrado, recepción UTC y tiempo del simulador. Omite mensajes idénticos por tipo; cada vuelo nuevo recibe la última base conocida. Las horas real y simulada pueden diferir. Gráficos: FSHud.COM1_selected_MHz, FSHud.COM2_selected_MHz y FSHud.squawk_display. Squawk contiene dígitos mostrados, no conversión octal; deben conservarse ceros iniciales. Ausencias son null. No se copia cada mensaje completo en todas las muestras.

fshud_last_observed selecciona por tipo el último estado anterior a la captura real del evento, hasta 65536 caracteres con recorte explícito. Los contactos antiguos sin hora de captura no reciben contexto actual ajeno. Una instrucción ATC no demuestra cumplimiento ni es una orden para el modelo de IA.

Se graba desde la carga hasta el fin del vuelo, incluso con motores parados. Se usan eventos Flow si están disponibles; la DLL examinada recurre a FlightLoaded y comprobaciones cada diez segundos. Pausa o SimStop aislado no terminan el vuelo. No se finalizó un vuelo activo del usuario para probar este límite.

VerifyFSHud prueba protocolo y almacenamiento sintéticos. ProbeFSHud permite lectura real opcional. La prueba anterior recibió nueve tipos y EPLL/ADOX2W/ADOXO/SOXER/SOXE2T/LL501/LL531. No fue un vuelo completo ni prueba de fallos. No se distribuyen scripts propietarios ni capturas privadas.
