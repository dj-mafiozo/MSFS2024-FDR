# Traducciones de la interfaz

[Traducciones de la interfaz](../Translation.es.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

La única fuente es MSFS2024-FDR.i18n en este directorio: catálogo XML UTF-8 sin compresión del paquete i18n instalado. Edítelo con su editor o un editor UTF-8. Ya no existen catálogo JSON paralelo ni generador de textos Pascal.

Cada definición contiene las 25 configuraciones regionales de LocalizationU. El idioma fuente es polaco; la selección inicial es automática. Herramientas → Idioma o Ajustes → General guarda [ui] language=...; Cancelar no aplica cambios. Los nombres de idiomas permanecen en su propia lengua.

Application contiene literales Tr(...). Conserve los ID y añada textos mediante editor/GetStringIdentifier: la biblioteca usa una variante antigua de MD5 que no siempre equivale al MD5 estándar. Los dominios de formularios/frames son nombres de clase sin T, por ejemplo frmMain, fraMap y fraGraph. Propiedades: .Caption, aSettings.Caption o cbProvider.Items[0]. Las acciones comparten textos entre menús y botones. Los títulos dinámicos se actualizan al cambiar idioma.

`python tools/check_translations.py` comprueba todos los idiomas registrados, marcadores Format, Unicode y referencias DFM. Script/MSBuild copia el catálogo a bin/MSFS2024-FDR.i18n junto al EXE. Inclúyalo al distribuir. Cambiar textos requiere reinicio, no recompilación. Los ejecutables de desarrollo/prueba pueden usar ../translations/MSFS2024-FDR.i18n como alternativa; si faltan ambos, la instalación está incompleta.

No traduzca FMC/METAR/OFP brutos, datos del usuario, nombres SimVar/L-var ni claves SQL/API/JSON. Las consultas e informes IA siguen en polaco según lo solicitado. README y Testy están en polaco sin sufijo y con .en.md, .de.md y .es.md. Los documentos del fabricante y licencias permanecen originales. Biblioteca/licencia: vendor/i18n y support/i18n/LICENSE.

## Nombres de parámetros legibles

Gráficos, listas de selección/orden e inspector muestran descripciones con unidades, como `Altitud del avión [ft]` y `Velocidad N1 — motor 2 [%]`. Siguen el idioma de la interfaz. La búsqueda acepta nombres e identificadores originales y las ayudas muestran ambos.

Las etiquetas están en los dominios `Parameters` y `ParameterWords` de MSFS2024-FDR.i18n. Edita Translation; Value e ID conservan las claves estables.


La opción inicial es auto. Se detecta el idioma de interfaz de Windows sin alterar los formatos numéricos/de fecha. Las variantes regionales se asignan a PL/EN/DE/ES/FR/RU/TR/IT/PT; los idiomas no admitidos usan inglés. Auto se conserva al reiniciar y las elecciones explícitas existentes se respetan. Menú y ajustes incluyen diez opciones. Se traducen las nuevas etiquetas GUI. La ayuda sigue en cuatro idiomas, con inglés para los nuevos. Los textos nuevos son una primera traducción local Qwen3 con correcciones terminológicas, sin revisión nativa. VersionU lee VersionInfo fijo/textual y tablas de idiomas; Acerca de muestra versión real, ProductName y copyright. Build común: 2 (0.1.0.2); se conservan los demás números y datos del autor. bump_build.py incrementa solo Build por cambio lógico; check_version.py valida la herencia. La compilación CLI usa MSBuild para generar los recursos de versión.


Ampliación: la interfaz admite 25 configuraciones regionales. Nuevas: en-GB, fr-CA, pt-BR, de-AT, de-CH, be-BY, el-GR, uk-UA, hr-HR, cs-CZ, da-DK, nl-NL, fi-FI, nb-NO, sk-SK y sv-SE. Las variantes regionales se guardan por separado. be significa bielorruso; no/nb/nn usan la traducción noruega Bokmål disponible, sin una versión Nynorsk independiente. El alemán suizo usa ss en lugar de ß. La detección automática sigue el idioma de Windows sin cambiar formatos numéricos. La ayuda sigue en PL/EN/DE/ES, con idioma base o inglés como alternativa. Las traducciones nuevas son una primera versión con correcciones terminológicas y validación estructural, sin revisión por hablantes nativos. Build: 0.1.0.3; los demás datos de versión y autor no cambian.


La interfaz contiene 32 configuraciones regionales ordenadas por código. Nuevas: ar-SA, he-IL, hi-IN, id-ID, ja-JP, vi-VN y zh-CN. ar/he seleccionan sus variantes; los alias antiguos iw/in corresponden a he/id. Árabe y hebreo usan RTL; gráficos, mapas y texto original FMC/METAR/OFP mantienen LTR. Las fuentes Noto de assets/fonts se copian a bin/fonts y a los archivos, con licencias OFL y sumas de procedencia; se cargan de forma privada sin instalación en Windows. La ayuda y documentación mantienen cuatro idiomas. Avisos sobre traducciones: Translation.es.md. Build 0.1.0.4.
