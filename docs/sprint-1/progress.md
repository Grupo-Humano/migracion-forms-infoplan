# Sprint 1 - Progress Tracker

> If context overflows, start a new chat:
> "Read PROJECT_BRIEF.md and docs/sprint-1/progress.md. Continue from where it left off."

## Task Status

| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Alinear narrativa oficial | ✅ Done | PROJECT_BRIEF actualizado, Sprint 1 como baseline hardening oficial |
| 2 | Hardening scripts Windows | 🔨 In progress | MCP server configurado; Sage ejecutará fixes de Unicode + refactor XML_PATHS |
| 3 | Ejecutar extraccion completa | ⏳ Waiting on 2 | Scripts arreglados → rerun generará outputs completos |
| 4 | Frontend stack decision | ⬜ Not started | Falta decision de adopcion stack objetivo o ajuste documental |
| 5 | QA smoke baseline | ⬜ Not started | Pendiente matriz minima de pruebas de equivalencia funcional |
| 6 | ORDS setup reproducible | ✅ Done | backend/ORDS-SETUP-LOCAL.md + run_sprint1_with_mcp.ps1 listo; MCP activado |
| 7 | Risk gate Wave 1/Wave 2 | ⬜ Not started | Debe resolverse conflicto entre decision doc y baseline actual |
| 8 | Integrar runbook de orquestacion PBI | ✅ Done | Modelo por fases incorporado en brief + nuevo runbook documental |
| 9 | Estandarizar GitFlow operativo | ✅ Done | Estandar documentado y listo para adopcion en ramas activas |

## Bugs Found

| # | Description | Severity | Status | Fix |
|---|-------------|----------|--------|-----|
| 1 | UnicodeEncodeError al imprimir emojis en consola Windows CP1252 | major | open | Pendiente hardening scripts |
| 2 | scripts/xml trace.py usa ruta hardcodeada no portable | major | open | Pendiente parametrizar CLI |
| 3 | Salida program_units/triggers vacia por aborto temprano del script | major | open | Pendiente rerun tras fix |

## Notes

- Build frontend validado exitosamente.
- Baseline mock funcional en modo demo.
- Artefacto de analisis consolidado disponible en docs/analysis-results/orquestacion-analisis-equipo-2026-06-15.md.
- **MCP Integration (2026-06-15):** Oracle SQLcl MCP server activado. Conexión HUMANO_DESA disponible.
- **Script Execution Path:** Sage ejecutará backend/SAGE-EXECUTION-PLAN.md para:
  1. Validar MCP + SQLcl
  2. Ejecutar run_sprint1_with_mcp.ps1 para setup ORDS mock en BD real
  3. Arreglar encoding en scripts Python (replace emojis con ASCII)
  4. Re-ejecutar extractores XML con salida limpia
- **Next Gate:** Sage completa → Remy valida outputs → Ivy comienza QA smoke → Dash verifica ORDS puerto 8080
- **Process Upgrade (2026-06-15):** Adopted orchestration lifecycle from PBI/video/form/ORDS analysis with mandatory human checkpoint after ORDS classification.
- **Repo Hygiene Upgrade (2026-06-15):** GitFlow model defined (develop/feature/release/hotfix) to prevent oversized mixed commits.
