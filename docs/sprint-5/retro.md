# Sprint 5 Retro - Cierre y preparacion de Sprint 6

Fecha: 2026-06-16
Facilitador: Remy
Estado: CERRADA

## Objetivo

Repasar de forma completa la base funcional y tecnica para iniciar desarrollo (Sprint 6) sin dudas, lagunas ni zonas grises de decision.

## Alcance revisado en retro

1. Entradas funcionales del PBI 203844.
2. Levantamiento de logica y transcripcion operativa.
3. XML de la forma `reemb_pago_fmb.xml`.
4. Salidas de Sprint 5 (extraccion, matriz ORDS, contrato MVP, plan QA).
5. Evidencia automatizada generada con scripts del repositorio.

## Confirmacion explicita sobre XML

Confirmado: SI se leyo y proceso el XML de la forma.

Evidencia directa:

1. `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/evidencia_xml_blocks.txt`
2. `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/evidencia_xml_program_units.txt`
3. `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/program_units_all.json` (86 Program Units)
4. `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/reemb_pago_fmb_lovs_and_records.json` (22 LOVs, 22 Record Groups)
5. `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/triggers_SOLICITUD_SERVICIO.txt`

## Scripts usados (source of truth tecnico)

1. `scripts/extract_program_units.py`
2. `scripts/extract_lovs_records.py`
3. `scripts/extract_block_triggers.py`
4. `scripts/analyze_reemb_pago_db_mechanics.py`

## Cobertura exhaustiva adicional (cascada/anidamiento)

Se ejecuto analisis exhaustivo para rastrear llamadas en cascada y mecanicas SQL/DB detectadas en todo el XML.

Resultados globales confirmados:

1. Program Units: 86
2. LOVs: 22
3. Record Groups: 22
4. Triggers (form + bloque + item): 303
5. Aristas de llamadas detectadas: 951

Artefactos generados:

1. `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/00-resumen-analisis-db-mechanics.json`
2. `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/05-program-units-inventory.csv`
3. `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/06-lovs-recordgroups-inventory.csv`
4. `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/07-trigger-inventory.csv`
5. `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/08-call-edges.csv`
6. `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/09-cascadas-llamadas.md`
7. `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/10-sql-detectado-exhaustivo.md`

## Hallazgos de la retro

1. La forma legacy es de alta densidad funcional, con mezcla de capas UI, reglas y auditoria.
2. Hay volumen alto de Program Units y triggers con efectos colaterales posibles.
3. Reingenieria por flujo guiado es obligatoria para evitar replicar acoplamiento.
4. La estrategia reuse-first sigue vigente; no se justifico endpoint nuevo en Sprint 5.

## Dudas y lagunas que se cierran antes de codificar

1. Ambiguedad de acciones por estatus (anular/rechazar en escenarios limite).
- Accion: cerrar tabla de decisiones de estatus antes del primer merge de Sprint 6.

2. Carta enviar/descargar con comportamiento parcialmente activo.
- Accion: limitar MVP a comportamiento confirmado en legacy y documentar diferido.

3. JSON heterogeneo en CRUDs legacy.
- Accion: forzar contrato v1 como frontera anti-regresion.

## Acuerdos de arranque Sprint 6

1. No se inicia historia de desarrollo sin referencia al contrato v1.
2. Cada historia debe indicar endpoint objetivo y clasificacion de matriz ORDS.
3. QA valida desde primer incremento, no al final del sprint.
4. Cualquier necesidad de endpoint nuevo se eleva al CEO con formato formal.

## Riesgos residuales y control

1. Riesgo: variaciones de comportamiento por ambiente ORDS.
- Control: smoke tecnico por historia y evidencia en progress.

2. Riesgo: regresion de montos en coberturas.
- Control: casos QA criticos QA-05 a QA-08 en cada incremento.

3. Riesgo: deuda documental durante construccion.
- Control: update obligatorio de progress por fase.

## Decision final

GO para Sprint 6.

El equipo entra a desarrollo con retro cerrada, XML validado y evidencias tecnicas publicadas.
