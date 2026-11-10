# Aeronaves oficiales — selección de parámetros

[Interface translations](../../Translation.es.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)

Se revisaron 120 paquetes y 2046 archivos locpak de Official2020/OneStore y Official2024/OneStore. No se abrieron archivos fsarchive cifrados. `locpak-audit.json` incluye fuentes, SHA-256 y bindings explícitos. Los identificadores de traducción no son nombres de SimVars. Algunas traducciones incluso alteran nombres dentro del código; se excluyen.

La selección estándar usa ENGINE TYPE y NUMBER OF ENGINES: pistón → RECIP/PROP; reactor → TURB sin RECIP/PROP; turbohélice → TURB/PROP; eléctrico → PROP y campos comunes. Se omiten índices superiores al número real de motores. Se conservan los otros campos comunes del catálogo existente. Los textos traducidos no enumeran todos los SimVars posibles.

Bell 407: 72 bindings adicionales; EC135: 234. Solo se incluyen expresiones numéricas idénticas en al menos la mitad de los idiomas instalados, con un mínimo de tres. `A:` identifica SimVars estándar con su unidad; otros nombres son L-vars. Se guardan datos sin interpretar del perfil seleccionado, sin sobrescribir parámetros comunes por conjetura. La ausencia en locpak no demuestra que una variable no exista.

Repetir: `python tools/audit_official_locpaks.py --packages-root <Packages>`, seguido del generador documentado en `support/addon-lvars`. Se revisaron archivos y transporte simulado; no se verificó la recepción durante un vuelo real.
