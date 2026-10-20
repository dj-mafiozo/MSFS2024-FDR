# Gemeinsame AIRLINER-Instrumentvariablen

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Die 31 katalogisierten *AIRLINER*-Namen sind Instrument-L-Vars, als `L:<Name>` durch SimConnect_AddToDataDefinition gelesen, keine Standard-A:-SimVars. Sie stammen aus 149 installierten Instrumentdateien (Asobo A320/737 MAX/747/787/CJ4 sowie FBW/FSS/LVFR). AIRLINER kann am Anfang oder innerhalb des Namens stehen. Carenado-Livewerte und dynamisch erzeugte Namen sind damit nicht vollständig bestätigt.

| Name | Bedeutung |
|---|---|
| AIRLINER_V1_SPEED | V1, kt |
| AIRLINER_VR_SPEED | VR, kt |
| AIRLINER_V2_SPEED | V2, kt |
| AIRLINER_MINIMUM_DESCENT_ALTITUDE | MDA, ft |
| AIRLINER_DECISION_HEIGHT | DH, ft |

Weitere Felder betreffen VREF/VX/Anflug- und Green-Dot-Geschwindigkeiten, Phase, Reiseflug-/Schubreduktions-/Beschleunigungs-/Übergangshöhen, FLEX, Startklappen, Schubmodi und TOC/TOD. catalog.json enthält Namen, Einheitvarianten, Quellen und SHA-256. Die Zuordnungen stehen in Telemetry/AirlinerCatalogU.pas.

Ein getrenntes lesendes SimConnect transportiert jede Variable als eigene Definition/Anforderung. Fehler eines Feldes stoppen keine anderen Felder oder die Hauptaufzeichnung. Fehlende Antworten, NaN, Fehler und veraltete Werte sind null. Flugzeugwechsel, Pause und Simulationsstopp setzen den Leser zurück. Empfangenes Null beweist keine Existenz: Status bleibt received_not_verified. Positive Geschwindigkeiten unter 400 kt können ausdrücklich unbestätigte Referenzkandidaten sein; null/negative Werte werden nicht V-Speeds. Verifizierte Flugzeug-SDK/FMS-Referenzen behalten Vorrang.

`TFlightSample.AirlinerData` wird als `airliner_lvars` in trip_aircraft_data mit Sample-/Zeitbezug gespeichert: vollständige Basis, danach nur Änderungen. Diagramme verwenden `AirlinerLVar.` mit Lücken bei null; Analyse erhält rekonstruierte Daten und airliner_lvar_definitions. Es werden keine Cockpitbefehle gesendet.

Zur Neuerzeugung die mit `rg -l -i airliner <Pakete> -g '*.js' -g '*.xml' -g '*.html'` gefundenen Dateien an tools/import_airliner_catalog.py übergeben und neu kompilieren. Der Import extrahiert feste numerische Get/SetSimVarValue-/XML-Namen, keine dynamischen Namen oder Herstellerprogramme. tools/check_airliner_catalog.py vergleicht Manifest und Pascal. VerifyAirliner prüft 31 Anforderungen, Fehler, Sentinels, Delta-Historie, Diagramme und Analyse mit einer DLL-Attrappe; reale Laufzeitwerte bleiben gesondert zu prüfen.
