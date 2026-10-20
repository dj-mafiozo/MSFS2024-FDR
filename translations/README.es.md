# Traducciones PL / EN / DE / ES

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

La única fuente es MSFS2024-FDR.i18n en este directorio: catálogo XML UTF-8 sin compresión del paquete i18n instalado. Edítelo con su editor o un editor UTF-8. Ya no existen catálogo JSON paralelo ni generador de textos Pascal.

Cada definición contiene pl-PL, en-US, de-DE y es-ES. Polaco es el idioma predeterminado. Herramientas → Idioma o Ajustes → General guarda [ui] language=...; Cancelar no aplica cambios. Los nombres de idiomas permanecen en su propia lengua.

Application contiene literales Tr(...). Conserve los ID y añada textos mediante editor/GetStringIdentifier: la biblioteca usa una variante antigua de MD5 que no siempre equivale al MD5 estándar. Los dominios de formularios/frames son nombres de clase sin T, por ejemplo frmMain, fraMap y fraGraph. Propiedades: .Caption, aSettings.Caption o cbProvider.Items[0]. Las acciones comparten textos entre menús y botones. Los títulos dinámicos se actualizan al cambiar idioma.

`python tools/check_translations.py` comprueba cuatro idiomas, marcadores Format, Unicode y referencias DFM. Script/MSBuild copia el catálogo a bin/MSFS2024-FDR.i18n junto al EXE. Inclúyalo al distribuir. Cambiar textos requiere reinicio, no recompilación. Los ejecutables de desarrollo/prueba pueden usar ../translations/MSFS2024-FDR.i18n como alternativa; si faltan ambos, la instalación está incompleta.

No traduzca FMC/METAR/OFP brutos, datos del usuario, nombres SimVar/L-var ni claves SQL/API/JSON. Las consultas e informes IA siguen en polaco según lo solicitado. README y Testy están en polaco sin sufijo y con .en.md, .de.md y .es.md. Los documentos del fabricante y licencias permanecen originales. Biblioteca/licencia: vendor/i18n y support/i18n/LICENSE.

## Nombres de parámetros legibles

Gráficos, listas de selección/orden e inspector muestran descripciones con unidades, como `Altitud del avión [ft]` y `Velocidad N1 — motor 2 [%]`. Siguen el idioma de la interfaz. La búsqueda acepta nombres e identificadores originales y las ayudas muestran ambos.

Las etiquetas están en los dominios `Parameters` y `ParameterWords` de MSFS2024-FDR.i18n. Edita Translation; Value e ID conservan las claves estables.
