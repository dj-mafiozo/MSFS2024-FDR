[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

[Translation notice](../../Translation.de.md)

# FSLTL- und AIG-Modellprofile

Der Katalog enthält nur Parameterfakten, ICAO-Codes, Commit-ID und Quellhashes. Modelle, Texturen und XML-Assets werden nicht mitgeliefert. Die Hintergrundprüfung liest installierte Community-Konfigurationen. ICAO und Bemalung bestimmen die Auswahl; bei Gleichstand folgen FSLTL, AIG und Standardmodelle. Ein exakt passendes AIG B38M schlägt ein Ersatzmodell FSLTL B738. STUB-Einträge haben geringere Priorität.

Die Animationsprofile enthalten auch negativen Schub und Bodenzustand für Umkehrschub. Nicht beschreibbare SimVars werden nach einem Fehler deaktiviert. Live-Tests sind noch nötig. Kontrolle: `python tools/import_fsltl.py --check`.
