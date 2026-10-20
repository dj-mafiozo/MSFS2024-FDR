# CHM help and F1

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

F1 or Help → Help contents opens the active view topic. Topics cover getting started, map, charts, analysis, settings and About. PL/EN/DE/ES follow the interface language.

Build: `python tools/build_help.py --require-chm`. Requires HTML Help Workshop; set HHC_EXE to override the hhc.exe path. The full build.ps1 also builds help. Without the compiler, local HTML is available; F1 falls back to HTML when CHM is missing. Output: bin/help. Distribute the entire help directory beside the EXE.

Topic sources: pl/, en/, de/, es/. HHP/HHC and contexts.h define IDs 100–600. HHC contents use Windows-1250/1252 for the legacy compiler; HTML pages use UTF-8.
