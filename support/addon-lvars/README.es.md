# Otros aviones — L-vars de modelos XML

[Traducciones](../../Translation.es.md)

[Polski](README.md) | [English](README.en.md) | [Deutsch](README.de.md) | [Español](README.es.md)


PMDG DC-6: 904; CSS 737 Classic: 1221; Maddog X: 365; SkySim DC-9: 488; SkySim MD-11: 320; total 3298 nombres por proveedor. Se revisaron todos los XML indicados, exteriores y DC-6A/B/BP incluidos. `fields.json` registra hashes/unidades, 24 títulos aircraft.cfg y nombres dinámicos/inválidos excluidos; no se distribuyen XML originales.

La documentación DC-6 indicada no contiene un encabezado SDK público de datos; no se usa una estructura 737/777. Se leen `(L:...)` literales, nunca escrituras `(>L:...)` ni plantillas inventadas. Hay como máximo una solicitud ONCE pendiente por campo, errores aislados e intervalo/pump limitados, sin cola continua SIM_FRAME.

Son valores sin semántica confirmada. Una L-var inexistente puede devolver cero; recibir un número no prueba soporte/disponibilidad. Errores/NaN/ausencia quedan null. No se inventan unidades ni sustituciones SimVar. Historial, gráficos e IA reciben estas limitaciones. No se añaden pantallas FMS completas ni control de estos aviones.

Se reconocen títulos aircraft.cfg verificados y nombres explícitos. Una librea desconocida puede conservar SimConnect estándar; no se clasifica cualquier MD-11 como SkySim (p.ej. TFDi).

Generador: `tools/generate_addon_lvars.py --models-root <carpeta> --root <repo>`. Subcarpetas PMDGDC6/CSS737/MaddogX/SkySimDC9/SkySimMD11 con XML/CFG locales. `VerifyAddonLVars`: pruebas simuladas, no vuelo en vivo.
## 0.1.0.10 — Suscripciones por vuelo activo

En reposo solo se leen TITLE, ENGINE TYPE y NUMBER OF ENGINES una vez por segundo, junto con eventos de sistema/Flow. FlightLoaded, AircraftLoaded y SimStart renuevan la identificación. SimStart puede confirmar el vuelo consultando FlightLoaded actual. AircraftLoaded almacenado no inicia grabaciones en el menú. Carga/fin de sesión cierra telemetría y proveedores; SimStop suspende suscripciones. Pausa o SimStop transitorio no divide por sí solo la grabación. Se rechazan paquetes de generaciones anteriores. AIRLINER deja de consultarse para todas las aeronaves.

Ocho unidades por aeronave sustituyen al catálogo monolítico; AddonLVarCatalogU es un registro pequeño. Se revisaron 18 variantes de seis familias comerciales. Las cinco anteriores mantienen 3298 nombres; TFDi MD-11 GE/PW de pasajeros/carga añade 1446 L-vars explícitos de XML. No es una integración SDK binaria: no había encabezado SDK en esa ubicación. Cada catálogo es la unión de su familia; la disponibilidad depende de la variante. Modelos compartidos no implican ausencia de variables. Véase `support/addon-lvars/variant-audit.json`. Los locpak oficiales añaden 306 bindings Bell 407/EC135: 5050 campos en ocho perfiles. Un cero no demuestra que una L-var exista.

