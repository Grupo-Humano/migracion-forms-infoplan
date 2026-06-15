# Sprint 0 - Done (Cierre de Reinicio Estrategico)

**Fecha cierre:** 2026-06-15  
**Branch:** feature/sprint-0-restart  
**Owner:** Remy

---

## Que se entrego

| Task | Resultado |
|---|---|
| 1 - Reinicio proyecto | PROJECT_BRIEF actualizado a modo reinicio |
| 2 - Inventario activos | docs/sprint-0/inventory-assets.md |
| 3 - Hardening extractores | scripts/ todos ASCII-safe, xml_trace.py usa CLI |
| 4 - Validacion ORDS real | Smoke exitoso contra https://infoplan-web-dev.humano.local/ords/infoplan/... |
| 5 - Forma piloto Wave 1 | rep_aprobarechazo seleccionada como piloto (ORDS ya publicado) |
| 6 - Criterios QA equivalencia | docs/qa/screen-migration-equivalence-checklist.md |
| 7 - Mapa componentes React | App.tsx + FiltersPanel.tsx + ResultsTable.tsx cubriendo bloque CONSULTA y TRANS |
| 8 - Plan Sprint 1 real | Ver docs/sprint-1/ (a crear al iniciar Sprint 1) |

---

## Estado de la pantalla piloto

- Frontend: build limpio (tsc + vite, 0 errores), usando URL ORDS DEV real.
- ORDS DEV: endpoints publicados y validados (6/6 endpoints 200 OK).
- QA Sign-off: GO (6/6 criticos PASS, 2 pendientes no bloqueantes: rendimiento manual y teclado).
- Entorno DEV URL: `https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos`

---

## Archivos clave modificados en este sprint

- `frontend/src/App.tsx` — titulo correcto, validacion cruzada fechas, UX mejorada
- `frontend/src/components/FiltersPanel.tsx` — aria-invalid, required visual, boton desactivado con error
- `frontend/src/styles.css` — estilos field-error, required, loading, disabled
- `frontend/.env.local` — URL ORDS DEV real
- `backend/ords/run/test_api_mock.ps1` — alineado a rutas resource-first
- `scripts/extract_*.py` y `scripts/xml_trace.py` — ASCII-safe, CLI configurable
- `docs/governance/process/orquestacion-pbi-ords-react.md` — Fase 8 y 9 agregadas
- `docs/qa/screen-migration-equivalence-checklist.md` — creado y completado
- `docs/sprint-0/progress.md` — todas las tasks completadas

---

## Condiciones de salida (Go/No-Go para Sprint 1)

- [x] ORDS real validado con evidencia de conectividad
- [x] Extractor scripts estables en Windows
- [x] Wave 1 piloto definida (rep_aprobarechazo)
- [x] Matriz QA base definida y completada al 80%
- [ ] Sprint 1 plan tecnico creado — PENDIENTE (primer acto de Sprint 1)

---

## Prompt de cold start para Sprint 1

```
Read PROJECT_BRIEF.md and docs/sprint-0/done.md.
You are starting Sprint 1 real (post-reset) for the migration of rep_aprobarechazo.
ORDS DEV is available at: https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos
Frontend is in frontend/. Build passes. URL is set in frontend/.env.local.
Execute Sprint 1 following docs/governance/process/orquestacion-pbi-ords-react.md phases 5-9.
```
