# Orquestacion de Analisis de Equipo (Remy + Sage + Nova + Kira + Ivy + Dash)

Fecha: 2026-06-15
Scope: evaluacion integral de estado real del proyecto con foco en scripts nuevos y consistencia Sprint 1.

## 1) Resumen Ejecutivo

- El proyecto tiene una base tecnica valida para demo local en frontend.
- El backend ORDS esta en modo mock y depende de infraestructura Oracle/ORDS no levantada en este workspace.
- El folder `scripts/` aporta valor, pero dos scripts fallan en Windows por salida con emojis en consola CP1252.
- Hay inconsistencia de roadmap: `PROJECT_BRIEF.md` mantiene estado de Sprint 0, mientras `README.md` habla de baseline Sprint 1 mock.
- El plan de Sprint 1 y resultados de analisis no estaban materializados en `docs/sprint-1/`; se creo `docs/analysis-results/` durante esta revision con evidencia ejecutada.

## 2) Evidencia Tecnica Verificada

### Frontend (Nova)

- Build exitoso:
  - comando: `npm run build`
  - resultado: compilacion TypeScript + Vite OK
- Cliente API y mock client implementados para busqueda, seleccion y exportes.
- Demo mode funcional con datos mock.

Observacion:
- `PROJECT_BRIEF.md` define stack objetivo con React Hook Form + Tailwind + Headless UI, pero `frontend/package.json` actual no los incluye.

### Backend ORDS mock (Sage)

- SQL de schema/package/publicacion ORDS presente y coherente para piloto mock.
- Endpoints mock definidos para:
  - `GET /oficial/{codigo}`
  - `POST /search`
  - `POST /seleccion/{accion}`
  - `POST /export/ole`
  - `POST /export/jasper`

Observacion:
- Sin Oracle/ORDS local levantado no se puede validar end-to-end real, solo contrato mock.

### Scripts nuevos (Sage + Remy)

Scripts revisados:
- `scripts/extract_program_units.py`
- `scripts/extract_block_triggers.py`
- `scripts/extract_lovs_records.py`
- `scripts/xml trace.py`

Ejecucion real en `forms/rep_aprobarechazo_fmb.xml`:
- `extract_program_units.py`: fallo en Windows (UnicodeEncodeError por emoji en consola).
- `extract_block_triggers.py`: fallo en Windows (UnicodeEncodeError por emoji en consola).
- `extract_lovs_records.py`: ejecuto y genero JSONs.

Artefactos generados:
- `docs/analysis-results/rep_aprobarechazo_lovs.json/rep_aprobarechazo_fmb_lovs.json`
- `docs/analysis-results/rep_aprobarechazo_lovs.json/rep_aprobarechazo_fmb_record_groups.json`
- `docs/analysis-results/rep_aprobarechazo_lovs.json/rep_aprobarechazo_fmb_lovs_and_records.json`

Observaciones de calidad:
- `scripts/xml trace.py` tiene `XML_PATHS` hardcodeado a una ruta externa, no portable.
- Los extractores deben soportar consola cp1252 (sin emojis o con UTF-8 forzado).

### Producto / Planificacion (Remy)

- Existe decision previa: `docs/DECISION-rep-aprobarechazo-piloto.md` recomienda no usar esta forma como piloto principal.
- En paralelo, `README.md` ya presenta baseline Sprint 1 mock para esa forma.

Riesgo de producto:
- Confusion de narrativa: "caso de alto riesgo para Wave 2" vs "baseline Sprint 1 mock".

## 3) Hallazgos Priorizados

1. Critico: scripts de extraccion clave fallan en Windows por encoding (`extract_program_units.py`, `extract_block_triggers.py`).
2. Alto: mismatch de estado de proyecto entre `PROJECT_BRIEF.md` (Sprint 0) y `README.md` (Sprint 1 mock).
3. Alto: stack objetivo documentado no alineado al `frontend/package.json` actual.
4. Alto: `scripts/xml trace.py` no portable por rutas hardcodeadas.
5. Medio: faltan entregables de sprint formal (`docs/sprint-1/plan.md`) aunque ya hay implementacion parcial mock.

## 4) Plan de Correccion Orquestado por Equipo

### Remy (Productor)

- Unificar narrativa oficial en un documento de estado unico:
  - "Sprint 0 decision + Sprint 1 mock technical baseline".
- Crear `docs/sprint-1/plan.md` con alcance realista (mock -> hardening -> validacion).

### Sage (Backend)

- Hardening scripts Python para Windows:
  - quitar emojis en `print()` o usar salida ASCII-safe.
  - agregar bandera `--quiet-json` para salida limpia sin logs.
- Refactor `scripts/xml trace.py` para aceptar XML por CLI en lugar de `XML_PATHS` fijo.

### Nova (Frontend)

- Decidir si se implementa stack objetivo completo ahora:
  - opcion A: agregar React Hook Form + Tailwind + Headless UI.
  - opcion B: actualizar brief para reflejar estado real incremental.
- Mantener API adapter unico para alternar mock/real sin tocar componentes.

### Ivy (QA)

- Crear smoke suite minima (API contrato + validaciones de fechas + export actions).
- Definir matriz de equivalencia legacy vs mock para evitar drift funcional.

### Dash (DevOps)

- Documentar setup reproducible de Oracle + ORDS para QA local (o entorno compartido).
- Agregar pipeline minimo CI para `frontend` build y lint de scripts.

### Kira + Milo (UX/Visual)

- Definir si el piloto exige solo desktop.
- Resolver decision UX de doble export (OLE/Jasper) para evitar confusion operativa.

## 5) Proxima Secuencia Recomendada (7 dias)

Dia 1-2:
- Fix de scripts y ejecucion estable de extracciones.

Dia 3:
- Publicar `docs/sprint-1/plan.md` con objetivos medibles.

Dia 4-5:
- QA smoke de frontend + contrato API mock.

Dia 6-7:
- Definir decision final de stack frontend (adoptar o ajustar documentacion).

---

Estado final de esta orquestacion: analisis completado con evidencia de ejecucion y backlog de correccion priorizado.