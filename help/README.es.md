# Ayuda CHM y F1

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

F1 o Ayuda → Contenido de ayuda abre el tema de la vista activa. Incluye introducción, mapa, gráficos, análisis, configuración e información del programa. PL/EN/DE/ES siguen el idioma de la interfaz.

Compilar: `python tools/build_help.py --require-chm`. Requiere HTML Help Workshop; HHC_EXE permite indicar otra ruta de hhc.exe. build.ps1 también compila la ayuda. Sin compilador hay HTML local; F1 utiliza HTML si falta CHM. Salida: bin/help. Distribuye el directorio help completo junto al EXE.

Fuentes de temas: pl/, en/, de/, es/. HHP/HHC y contexts.h definen los ID 100–600. Los índices HHC utilizan Windows-1250/1252 para el compilador antiguo; las páginas HTML usan UTF-8.
