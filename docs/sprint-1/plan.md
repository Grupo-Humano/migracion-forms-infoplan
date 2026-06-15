# Sprint 1 - Hardening Baseline Mock

> Sprint Goal: convertir el baseline mock en una base reproducible y verificable para iniciar migracion con bajo riesgo.
> Branch: feature/sprint-1
> Estimated effort: 5 dias habiles

## Prioritized Task List

| # | Task | Owner | Est | Description |
|---|------|-------|-----|-------------|
| 1 | Alinear narrativa oficial | Remy | 2h | Unificar status entre PROJECT_BRIEF, README y decision docs para evitar scope drift |
| 2 | Hardening scripts Windows | Sage | 6h | Corregir Unicode/CP1252, salida JSON limpia y errores consistentes en extractores |
| 3 | Ejecutar extraccion completa | Sage | 4h | Generar artefactos confiables en docs/analysis-results para program units, triggers y LOVs |
| 4 | Frontend stack decision | Nova + Milo + Kira | 4h | Decidir: adoptar stack objetivo documentado o ajustar brief al estado incremental |
| 5 | QA smoke baseline | Ivy | 4h | Validar flujo funcional mock: filtros, busqueda, seleccion, exportes, mensajes de error |
| 6 | ORDS setup reproducible | Dash + Sage | 6h | Definir guia minima para correr ORDS/Oracle en entorno de validacion |
| 7 | Risk gate Wave 1/Wave 2 | Remy + Kira + Sage | 2h | Confirmar si rep_aprobarechazo sigue como caso de estudio Wave 2 o piloto tecnico Sprint 1 |
| 8 | Integrar runbook de orquestacion PBI | Remy + Sage | 3h | Incorporar fases PBI->video->forma->ORDS->React como proceso oficial del repo |
| 9 | Estandarizar GitFlow operativo | Remy + Dash | 2h | Activar develop/feature/release/hotfix y convenciones de PR/commit |

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

Referencia: `docs/ORQUESTACION-PBI-ORDS-REACT.md`

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
