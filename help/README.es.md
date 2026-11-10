[Traducciones de la interfaz](../Translation.es.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

F1

[Traducciones de la interfaz](../Translation.es.md)


F1 abre el tema del panel mediante HelpContext DFM. PL/EN/DE/ES contienen 62 temas, árbol y búsqueda completa. Cada CHM incorpora capturas de su idioma con datos sintéticos.

Edite manual.pl.txt, manual.en.txt, manual.de.txt y manual.es.txt. generate_help.py genera HTML, HHC/HHP y alias estables. Sin barra global de enlaces; denominaciones de cockpit intactas.

Después de cambiar UI ejecute tools/capture_help.ps1 y python tools/build_help.py --require-chm. Requiere HTML Help Workshop (HHC_EXE). capture.json verifica hashes de fuentes/capturas. Empaquetado recompila y rechaza capturas obsoletas. Distribuya solo cuatro CHM de bin/help, sin HTML, imágenes sueltas ni manifiestos. Fuentes/capturas quedan en repositorio.

Codificación CHM: manual.*.txt sigue en UTF-8. HTML/HHC/HHP generados usan Windows-1250 para PL y Windows-1252 para EN/DE/ES, con TOC binario. No use UTF-8 ni referencias numéricas en etiquetas HHC. build_help.py verifica todos los títulos ANSI en #STRINGS y #TOCIDX. Requiere CLI 7-Zip (también incluido en PeaZip), detectado automáticamente o mediante SEVENZIP_EXE.

Informes de ejemplo: example-analysis.pl/en/de/es.txt. Escenario de vuelo/captura: tests/CaptureHelpScreenshots.dpr; instrumentos: tests/HelpDemoDataU.pas. HelpScreenshotU dibuja RichEdit con EM_FORMATRANGE y rechaza imágenes de texto vacías.
