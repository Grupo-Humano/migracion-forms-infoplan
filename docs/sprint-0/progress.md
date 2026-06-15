# Sprint 0 - Progress Tracker (Reinicio)

> Si el contexto se corta, iniciar nuevo chat con:
> Read PROJECT_BRIEF.md and docs/sprint-0/progress.md. Continue from where it left off.

## Estado de Tasks

| # | Task | Estado | Notas |
|---|------|--------|-------|
| 1 | Reinicio oficial del estado de proyecto | ✅ Done | Brief alineado al reinicio |
| 2 | Inventario de activos reutilizables | ✅ Done | Inventario publicado en docs/sprint-0/inventory-assets.md |
| 3 | Hardening de extractores | ✅ Done | Mensajes ASCII-safe y ruta configurable en scripts/xml trace.py; smoke tests ejecutados sobre forms/rep_aprobarechazo_fmb.xml |
| 4 | Validacion ORDS real end-to-end | ✅ Done | Smoke end-to-end exitoso contra gateway DEV: https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos (2026-06-15) |
| 5 | Definir forma piloto Wave 1 | ✅ Done | rep_aprobarechazo seleccionada: ORDS ya publicado, analisis completo, piloto de menor riesgo disponible |
| 6 | Criterios de QA equivalencia | ✅ Done | Matriz minima creada en docs/qa/screen-migration-equivalence-checklist.md |
| 7 | Mapa de componentes inicial React | ✅ Done | App.tsx + FiltersPanel.tsx + ResultsTable.tsx cubren bloques CONSULTA y TRANS del legado |
| 8 | Plan de Sprint 1 real (post-reinicio) | ✅ Done | Sprint 0 cerrado con GO. Cold start prompt en docs/sprint-0/done.md. Sprint 1 comienza desde ahi. |

## Riesgos Activos

| # | Riesgo | Severidad | Estado | Mitigacion |
|---|--------|-----------|--------|------------|
| 1 | ORDS real no accesible desde entorno local | Alta | Mitigado (DEV) | URL DEV validada y smoke API completo exitoso; pendiente confirmar endpoint de ambiente objetivo final |
| 2 | Scripts de analisis fallan en Windows | Alta | Mitigado en Task 3 | Refactor encoding/rutas aplicado y validado con smoke tests |
| 3 | Scope drift entre docs y ejecucion | Media | Open | Control semanal de brief/progress |

## Notas de Ejecucion

- Este tracker reemplaza el seguimiento operativo principal de Sprint 1 anterior.
- Sprint 1 previo queda como baseline historico, no como plan activo.
- A partir de este reinicio, los PBIs se ejecutan con runbook:
  docs/ORQUESTACION-PBI-ORDS-REACT.md
- Sprint iniciado en rama: feature/sprint-0-restart.
- Se detecto que origin no tiene rama develop publica; se trabajo desde la rama mas actual y se abrio sprint branch operativo.
- Task 4 ejecutado parcialmente: se alineo backend/ords/run/test_api_mock.ps1 al contrato resource-first y se ejecuto contra http://localhost:8080/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos con fallo de conectividad de red/servicio.
- Verificacion MCP SQL Developer (conexion HUMANO_DESA/DBAPER): modulos ORDS rep-aprobarechazo y facturacion-aprobaciones-rechazos-v1 existen en user_ords_modules, ambos en estado PUBLISHED (updated_on 15-JUN-26).
- Verificacion MCP SQL Developer: handlers del modulo facturacion-aprobaciones-rechazos-v1 presentes para rutas resource-first (oficiales/{codigo_oficial}, transacciones/search, transacciones/seleccion/{accion}, exportaciones/ole, exportaciones/jasper).
- Sonda de red desde entorno local contra host del .env (HUNDBHUCOREDESADB01.humano.local) en http:8080, https:443 y https:8443 para rutas /ords/...: todas fallan con "Unable to connect to the remote server".
- Descubrimiento de gateway ORDS accesible desde entorno local: infoplan-web-dev.humano.local (HTTP/HTTPS por puertos default).
- Evidencia Task 4: test_api_mock.ps1 ejecutado OK sobre endpoint resource-first; respuestas 200 en GET oficiales y POST transacciones/search, seleccion/M, exportaciones/ole, seleccion/D, exportaciones/jasper.
- Criterio para "migracion correcta de pantalla" formalizado en docs/qa/screen-migration-equivalence-checklist.md.
- Mejora de flujo aplicada: ORQUESTACION-PBI-ORDS-REACT.md ahora incluye Fase 8 (equivalencia) y Fase 9 (mejora continua de reglas).
- Pantalla rep_aprobarechazo ajustada: titulo, validacion cruzada fechas con texto del legado, aria-invalid, boton desactivado con error, loading visible.
- Build frontend limpio: tsc + vite, 0 errores, dist generado.
- QA Sign-off emitido: GO para Sprint 1 (6/6 criticos PASS, 0 defectos Sev 1-2).
- Sprint 0 cerrado formalmente en docs/sprint-0/done.md.
