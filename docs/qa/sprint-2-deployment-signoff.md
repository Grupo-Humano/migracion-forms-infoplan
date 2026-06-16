# Sprint 2 Deployment Sign-off (Draft)

**Sprint:** Sprint 2 - ORDS Handlers Real Deployment  
**Date:** 2026-06-15  
**QA Owner:** Ivy  
**Coordination:** Remy

---

## 1. Scope Evaluated

- Frontend integration against ORDS real endpoints for report flow.
- OAuth protected access via token endpoint + Bearer on frontend client.
- Runtime validations from browser and direct endpoint calls for deployed handlers.

---

## 2. Environment and Build Evidence

- Frontend build: PASS (`npm --prefix frontend run build`).
- Frontend runtime validated in browser session on `http://localhost:3003`.
- ORDS base path active for flow: `/ords/infoplan/aprobaciones-rechazos`.

---

## 3. Functional QA Evidence (Current)

### 3.1 Frontend Smoke

- Page loads without runtime crash: PASS
- Gerente LOV loads real values: PASS
- Intermediario LOV loads real values: PASS
- Search (date range) returns records: PASS
- Results table displays expected 19 columns: PASS
- Forbidden/CORS in current flow: PASS (not present)

### 3.2 Endpoint/Handler Notes

- `GET /gerentes`: validated in integrated flow.
- `GET /intermediarios`: validated in integrated flow.
- `POST /transacciones/search`: validated in integrated flow and direct tests.

### 3.3 Endpoint Matrix (Sprint 2)

| Handler | Endpoint | Estado QA | Evidencia actual | Brecha pendiente |
|---|---|---|---|---|
| gerentes | GET /gerentes | PASS (flujo integrado) | Carga LOV en UI | Consolidar request/response final en tabla unica |
| intermediarios | GET /intermediarios | PASS (flujo integrado) | Carga LOV en UI | Consolidar request/response final en tabla unica |
| transacciones/search | POST /transacciones/search | PASS PARCIAL | Busqueda y tabla UI operativa; SQL real extendido actualizado | Revalidar endpoint publicado post-redeploy |
| oficiales/{codigo} | GET /oficiales/{codigo} | PENDIENTE | Sin evidencia consolidada en este sign-off | Ejecutar prueba directa y registrar resultado |
| transacciones/seleccion/{M\|D} | POST /transacciones/seleccion/{M\|D} | PENDIENTE | Sin evidencia consolidada en este sign-off | Ejecutar prueba directa y registrar resultado |
| exportaciones/{ole\|jasper} | POST /exportaciones/{ole\|jasper} | FUERA DE CIERRE ESTRICTO | Alcance historico con comportamiento mixto | Documentar politica Jasper-first por pantalla |

---

## 4. Defects and Risks

### Confirmed Resolved Defects

- 404 route mismatch: resolved by ORDS publish/base path correction.
- 403 Forbidden due to SQL/object mismatch: resolved by handler SQL corrections.
- 403 on protected routes due to missing Bearer: resolved with OAuth flow in frontend client.

### Residual Risks

- Full 6/6 handler matrix is not yet documented in one consolidated QA table.
- Final go/no-go should include explicit status for each non-core handler.
- Rediseno reciente en SQL de `transacciones/search` requiere validacion final en runtime publicado.
- Diferencia de volumen entre XLS Jasper (3913) y universo DB base R/C (39283) en la misma ventana; falta replicar filtro Jasper exacto para equivalencia total.
- Bloqueador de fuente: el handler publicado `facturacion-aprobaciones-rechazos-v1/transacciones/search` apunta a `mock_transacciones` (no a tablas reales), por lo que nombres como `Intermediario 1` no representan catalogo productivo.

### Evidencia extendida (datos reales)

- Cobertura en DB de campos extendidos (ventana 2026-01-01..2026-02-17):
	- `con_num_documento`: 34508 / 39284
	- `con_grupo`: 38825 / 39284
	- `con_telefono_1`: 32424 / 39284
	- `con_telefono_2`: 12302 / 39284
	- `con_telefono_3`: 0 / 39284

---

## 5. Recommendation (Draft)

**Current recommendation:** Conditional GO for the report flow already integrated in frontend.  
**Condition to finalize GO:** complete endpoint matrix section with explicit evidence for all Sprint 2 handlers and attach handoff doc `docs/sprint-2/done.md`.

---

## 6. Pending Actions Before Final Sign-off

1. Complete endpoint matrix with evidence links/logs for all Sprint 2 handlers.
2. Confirm payload conformance for remaining handlers vs `frontend/src/types.ts`.
3. Convert this file from draft to final sign-off with definitive GO/NO-GO.
4. Adjuntar evidencia de campos extendidos (`tipo_documento`, `num_documento`, `nombre_director`, `grupo`, `telefono_1/2/3`) en una corrida real.
5. Definir y aplicar filtro Jasper faltante para alinear volumen y habilitar GO total de equivalencia.
6. Republicar `transacciones/search` con SQL real (sin `mock_transacciones`) y repetir validacion E2E.
