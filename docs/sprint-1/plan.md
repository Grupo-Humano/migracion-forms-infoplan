# Sprint 1 — Migración real rep_aprobarechazo (build)

**Objetivo:** Entregar la pantalla rep_aprobarechazo completamente funcional sobre datos reales de producción (TRANSACCIONES_COBRO_RECURRENTE y tablas asociadas), con QA sign-off de todos los criterios críticos y el PR listo para merge a develop.

**Branch:** `feature/sprint-1-rep-aprobarechazo`  
**ORDS DEV:** `https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos`  
**Owner:** Remy (coord), Sage (ORDS SQL), Nova (React), Ivy (QA)  
**Duración estimada:** 5–7 días hábiles

---

## Contexto heredado de Sprint 0

- Frontend build limpio, conectado a ORDS DEV, validaciones de fecha implementadas.
- ORDS actualmente usa **tablas mock** (`mock_oficiales`, `pkg_rep_aprobarechazo_mock`).
- Tablas reales confirmadas via MCP:
  - `TRANSACCIONES_COBRO_RECURRENTE` (25 cols, ID_TRANSACCION NOT NULL)
  - `CLIENTE`, `MOFICIAL`, `ESTATUS`, `FRECUENCIA`
  - Vistas: `POLIZA01_V`, `INT_GER_DIR01_V`, `POL_INT01_V`

---

## Tareas prioritizadas

| # | Task | Owner | Est | Criterio de completitud |
|---|------|-------|-----|------------------------|
| 1 | Reemplazar SQL mock en ORDS `transacciones/search` con query real (TRANSACCIONES_COBRO_RECURRENTE + joins) | Sage | 2d | Smoke 200 con datos reales, payload snake_case |
| 2 | Reemplazar SQL mock en ORDS `oficiales/{codigo_oficial}` con CLIENTE+MOFICIAL reales (estatus=76) | Sage | 0.5d | GET /oficiales/X retorna nombre real |
| 3 | Agregar ORDS endpoints: `gerentes` y `intermediarios` (query INT_GER_DIR01_V) | Sage | 1d | GET /gerentes y /intermediarios devuelven listas reales |
| 4 | Adaptar frontend: LOV dropdowns para gerente e intermediario | Nova | 1d | Dropdowns poblados desde ORDS, valor pasa al search |
| 5 | Actualizar TransactionRow en types.ts (num_autoriza, lote_id y columnas reales) | Nova | 0.5d | TypeScript compila sin errores con schema real |
| 6 | Actualizar ResultsTable para mostrar columnas reales relevantes | Nova | 0.5d | Tabla muestra num_autoriza, lote_id, estado legible |
| 7 | Verificar endpoints exportaciones/jasper y exportaciones/ole con datos reales | Sage | 0.5d | 200 con payload coherente |
| 8 | Ejecutar checklist QA EQ-01 a EQ-10 con datos reales | Ivy | 1d | 10/10 PASS o defectos documentados como Issues GitHub |
| 9 | QA sign-off Sprint 1 | Ivy | — | docs/qa/sprint-1-signoff.md con recomendación GO |
| 10 | Commit final + push + PR a develop | Remy | — | PR con descripción completa y checklist |

---

## Contrato API objetivo (datos reales)

### POST /transacciones/search — columnas nuevas respecto al mock
`num_autoriza, lote_id` (adicionales al contrato actual)

### GET /gerentes (nuevo)
Source: `INT_GER_DIR01_V` — lista `[{codigo, nombre}]` filtrada por compañía

### GET /intermediarios (nuevo)
Source: `INT_GER_DIR01_V` — lista `[{codigo, nombre}]` filtrada por compañía

---

## Definition of Done

- [ ] ORDS endpoints usan tablas reales (no mock)
- [ ] Frontend muestra datos reales en ResultsTable
- [ ] LOVs gerente e intermediario son dropdowns poblados desde ORDS
- [ ] Checklist QA 10/10 PASS (o 0 defectos Sev1-2 abiertos)
- [ ] QA sign-off emitido en docs/qa/sprint-1-signoff.md
- [ ] Build limpio (tsc + vite, 0 errores)
- [ ] PR abierto con descripción completa

---

## Riesgos Sprint 1

| Riesgo | Mitigación |
|--------|------------|
| Query real de BUSCA_TRANSACCIONES con múltiples joins | Sage valida query via MCP antes de publicar en ORDS |
| Datos reales vacíos en rango de prueba | Usar rango amplio (2025-01-01 a 2026-12-31) para primer smoke |
| INT_GER_DIR01_V requiere filtro de compañía (:CG$CTRL.CODIGO_COMPANIA) | Confirmar si parámetro disponible en contexto ORDS o necesita hardcode DEV |

## Work Schedule

### Phase 1: Stabilization (tasks 1-3)
- Alinear documentos de estado y objetivos de sprint
- Arreglar scripts para ejecucion consistente en Windows
- Generar evidencias tecnicas en docs/analysis-results

### Phase 2: Product and Technical Gate (tasks 4, 7)
- Cerrar decision de stack frontend
- Cerrar decision de alcance piloto vs caso complejo

### Phase 3: QA and Enablement (tasks 5-6)
- Ejecutar smoke QA sobre baseline
- Publicar setup reproducible para ORDS/Oracle
- Preparar merge gate de Sprint 1

## Success Criteria

- [ ] `docs/analysis-results/` contiene salidas validas para program units, triggers y LOVs del formulario piloto
- [ ] Scripts de extraccion ejecutan en Windows sin errores de encoding
- [ ] Estado del proyecto queda consistente entre brief, readme y decision docs
- [ ] QA smoke report sin blockers criticos
- [ ] Existe guia reproducible de setup ORDS/Oracle para validacion
- [ ] Criterio de priorizacion Wave 1 vs Wave 2 documentado y aprobado
- [ ] Runbook de orquestacion PBI documentado y referenciado por brief
- [ ] GitFlow operativo documentado y aplicado para nuevos commits

## Orchestration Alignment (NEW)

The sprint plan now follows this lifecycle for each PBI:

1. Lectura PBI y criterios de aceptacion.
2. Extraccion de flujo funcional de video.
3. Analisis tecnico Oracle Form (bloques, items, LOVs, triggers, program units).
4. Evaluacion de ORDS existente con clasificacion REUTILIZABLE/ADAPTABLE/NUEVO.
5. Checkpoint humano obligatorio tras la evaluacion ORDS.
6. Diseno de endpoints ORDS faltantes.
7. Especificacion de migracion React/Next y desglose de tasks por sprint.

Referencia: `docs/governance/process/orquestacion-pbi-ords-react.md`

## What's NOT in This Sprint

| Feature | Reason |
|---------|--------|
| Migracion completa de la forma a produccion | Todavia faltan gates de arquitectura y QA equivalencia |
| Integracion Jasper/XLSX real | Alcance post-baseline, requiere definicion operativa |
| CI/CD completo multi-entorno | Se aborda despues de estabilizar baseline tecnico |

## Agent Prompt

> Read PROJECT_BRIEF.md, then read docs/sprint-1/plan.md. Execute Sprint 1.
>
> First: git pull origin main && git checkout -b feature/sprint-1
>
> Close GitHub Issues in commits: "fix: description (Fixes #NN)"
> Update docs/sprint-1/progress.md after each phase.
> When done, push and create PR: git push origin feature/sprint-1
> Follow Sections 12-14 of PROJECT_BRIEF.md.
