# Offizielle Flugzeuge — Parameterauswahl

[Interface translations](../../Translation.de.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

120 Pakete und 2046 locpak-Dateien aus Official2020/OneStore und Official2024/OneStore wurden geprüft. Verschlüsselte fsarchive-Dateien wurden nicht geöffnet. `locpak-audit.json` enthält Quelldateien, SHA-256 und explizite Bindings. Tooltip-Schlüssel sind keine SimVar-Namen. Manche Übersetzungen verändern sogar Variablennamen im Code; diese werden ausgeschlossen.

Die Standardauswahl folgt ENGINE TYPE und NUMBER OF ENGINES: Kolbenmotor → RECIP/PROP, Jet → TURB ohne RECIP/PROP, Turboprop → TURB/PROP, elektrisch → PROP und gemeinsame Felder. Nicht vorhandene Motorindizes werden ausgelassen. Andere gemeinsame Felder des bestehenden Katalogs bleiben erhalten. Übersetzungen liefern keinen vollständigen SimVar-Katalog.

Bell 407: 72 zusätzliche Bindings; EC135: 234. Nur unveränderte numerische Ausdrücke aus mindestens der Hälfte der installierten Sprachdateien, mindestens drei, werden übernommen. `A:` kennzeichnet Standard-SimVars mit deklarierter Einheit; andere Namen sind L-vars. Speicherung als Rohdaten des ausgewählten Profils ohne spekulative Überschreibungen. Fehlende Einträge beweisen nicht das Fehlen einer Flugzeugvariable.

Erneut prüfen: `python tools/audit_official_locpaks.py --packages-root <Packages>`, danach den Generator in `support/addon-lvars` verwenden. Dateiprüfung und Mock-Tests durchgeführt; kein Live-Test dieser Flugzeuge.
