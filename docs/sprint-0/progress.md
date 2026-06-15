# Sprint 0 - Progress Tracker (Reinicio)

> Si el contexto se corta, iniciar nuevo chat con:
> Read PROJECT_BRIEF.md and docs/sprint-0/progress.md. Continue from where it left off.

## Estado de Tasks

| # | Task | Estado | Notas |
|---|------|--------|-------|
| 1 | Reinicio oficial del estado de proyecto | ✅ Done | Brief alineado al reinicio |
| 2 | Inventario de activos reutilizables | ⬜ Not started | Pendiente inventario backend/frontend |
| 3 | Hardening de extractores | ⬜ Not started | Pendiente correcciones CP1252 + rutas |
| 4 | Validacion ORDS real end-to-end | ⬜ Not started | Confirmar host/puerto ORDS real |
| 5 | Definir forma piloto Wave 1 | ⬜ Not started | Decision funcional pendiente |
| 6 | Criterios de QA equivalencia | ⬜ Not started | Ivy define matriz minima |
| 7 | Mapa de componentes inicial React | ⬜ Not started | Nova/Milo definen estructura base |
| 8 | Plan de Sprint 1 real (post-reinicio) | ⬜ Not started | Se crea al cierre de Sprint 0 |

## Riesgos Activos

| # | Riesgo | Severidad | Estado | Mitigacion |
|---|--------|-----------|--------|------------|
| 1 | ORDS real no accesible desde entorno local | Alta | Open | Validar URL real y runbook de conectividad |
| 2 | Scripts de analisis fallan en Windows | Alta | Open | Refactor encoding/rutas y smoke script |
| 3 | Scope drift entre docs y ejecucion | Media | Open | Control semanal de brief/progress |

## Notas de Ejecucion

- Este tracker reemplaza el seguimiento operativo principal de Sprint 1 anterior.
- Sprint 1 previo queda como baseline historico, no como plan activo.
- A partir de este reinicio, los PBIs se ejecutan con runbook:
  docs/ORQUESTACION-PBI-ORDS-REACT.md
