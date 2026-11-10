[Interface translations](../Translation.en.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

F1

[Interface translations](../Translation.en.md)


F1 routes to the panel topic using DFM HelpContext. PL/EN/DE/ES manuals contain 62 topics, hierarchical contents and full-text search. Every CHM embeds screenshots captured in its own language using synthetic data.

Edit manual.pl.txt, manual.en.txt, manual.de.txt and manual.es.txt. generate_help.py creates HTML, HHC/HHP and stable context aliases. Do not add an all-topics link bar. Standard cockpit legends remain untranslated.

After UI changes run tools/capture_help.ps1, then python tools/build_help.py --require-chm. HTML Help Workshop is required (HHC_EXE). capture.json checks screenshots against UI-source hashes. Packaging recompiles CHM and rejects stale screenshots. Distribute only the four CHM files from bin/help, without HTML, loose images or build manifests. Sources and screenshots stay in the repository.

CHM encoding: manual.*.txt sources remain UTF-8. Generated HTML/HHC/HHP use Windows-1250 for PL and Windows-1252 for EN/DE/ES with a binary TOC. Do not restore UTF-8 or numeric character references in HHC labels. build_help.py verifies every ANSI navigation label in #STRINGS and checks #TOCIDX. A 7-Zip CLI (also bundled with PeaZip) is required, autodetected or selected using SEVENZIP_EXE.

Demonstration report text: example-analysis.pl/en/de/es.txt. Flight/capture scenario: tests/CaptureHelpScreenshots.dpr; instrument values: tests/HelpDemoDataU.pas. HelpScreenshotU renders RichEdit with EM_FORMATRANGE and rejects blank text images.
