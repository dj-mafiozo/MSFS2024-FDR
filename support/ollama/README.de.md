# Analyse mit Ollama

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

In Einstellungen → KI-Anbieter Ollama (HTTP / lokales Modell) wählen. Der Server ist standardmäßig `http://localhost:11434`. Er muss bereits laufen und ein Modell enthalten; FDR startet oder installiert nichts. Kein Gemini-Schlüssel und kein Codex-EXE sind nötig. Bei einem entfernten Server wird der Flugkontext dorthin übertragen.

Modelle werden im Hintergrund beim Öffnen der Ollama-Einstellungen, Anbieterwechsel oder Verlassen einer geänderten URL über GET /api/tags gesucht. „Modelle aktualisieren“ wiederholt die Abfrage. Die Liste ist sortiert, ohne Duplikate und weiterhin editierbar; ein gespeichertes, nicht vorhandenes Modell wird nicht still ersetzt. Die Liste hat fünf Sekunden Zeitlimit, unterscheidet leer von Fehler und verwirft Antworten einer inzwischen gewechselten URL. Schließen der Einstellungen bricht den Abruf ab.

```ini
[ai]
provider=ollama
ollama_url=http://localhost:11434
ollama_model=NAME_AUS_OLLAMA_LIST
ollama_context_tokens=32768
timeout_seconds=180
```

Der Modellname ist ein Platzhalter. Kontext: 2048–262144 Token, Standard 32768; das Modell und der Arbeitsspeicher müssen die gewählte Größe unterstützen. FDR zählt nicht mit dem Tokenizer des Modells und erkennt nicht jede serverseitige Kürzung. Das gemeinsame Zeitlimit mit Codex beträgt 1–1800 s einschließlich Modellladen. URL darf HTTP/HTTPS, einen Reverse-Proxy-Pfad oder /api/chat enthalten, aber keine Query, Fragmente oder Zugangsdaten.

Natives WinHTTP sendet POST /api/chat mit Modell, ausdrücklichem polnischem Analyseauftrag/Kontext, stream=false und options.num_ctx. Nur message.content wird zum Markdown-Bericht; separates thinking wird ausgelassen. Hintergrundanforderung, Zeitlimit und Abbruch einschließlich Warten auf das erste Byte werden unterstützt. Keine automatische Wiederholung oder anderer Anbieter als Ersatz. HTTP/API-Fehler, ungültiges/unvollständiges JSON, fehlendes done=true/message und leere Berichte werden gemeldet. Keine Authentifizierung, kein Systemproxy; Antwort maximal 16 MB.

Gespeicherte Berichte werden aus der Datenbank geöffnet. Nach Modell-/Anbieterwechsel mit Umschalt+Klick neu analysieren. VerifyOllama und VerifyOllamaModels verwenden einen lokalen HTTP-Testserver für UTF-8, Anfragevertrag, Kontext, Proxy-Pfad, Markdown, Fehler, Abbruch, Listen und Formularspeicherung. Sie testen weder ein echtes Modell noch die Qualität seiner Flugbewertung. API: https://docs.ollama.com/api/chat und https://docs.ollama.com/api/tags.
