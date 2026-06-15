# Sprint 3 Progress Tracker

Sprint: Sprint 3 - Certificacion ORDS vs Jasper  
Periodo: 2026-06-16 a 2026-06-18  
Branch: `feature/sprint-3-certificacion-jasper`  
Owner: Remy

---

## Estado general

| # | Tarea | Owner | Esfuerzo | Estado | Bloqueo |
|---|---|---|---|---|---|
| T-01 | Baseline Jasper normalizado | Sage | 0.5d | ⏳ PENDIENTE | — |
| T-02 | Identificar filtro Jasper exacto | Sage | 1.0d | ⏳ PENDIENTE | Necesita .jrxml o inferir por XLS |
| T-03 | Matriz equivalencia campo a campo | Sage + Nova | 1.0d | ⏳ PENDIENTE | T-01, T-02 |
| T-04 | Correcciones de datos (si aplica) | Sage / Nova | 0.5d max | ⏳ PENDIENTE | T-03 |
| T-05 | Lazy enrichment frontend | Nova | 0.5d | ⏳ PENDIENTE | — (paralelo) |
| T-06 | QA sign-off final | Ivy | 0.5d | ⏳ PENDIENTE | T-03, T-04 |
| T-07 | Cierre y PR Sprint 3 | Remy | 0.25d | ⏳ PENDIENTE | T-06 |

**Riesgo principal:** Filtro Jasper desconocido (diferencia 3913 vs 39284).  
**Prerequisito inmediato:** Sage ejecuta T-01 primero para desbloquear toda la cadena.

---

## Daily Standup + Retro (2026-06-15, cierre Sprint 2 / arranque Sprint 3)

| Miembro | Hizo hoy | Hara manana | Bloqueador |
|---|---|---|---|
| Remy | Cierre doc Sprint 2, commit+push 36 archivos, PR abierto | Kickoff Sprint 3: asignar owners WS | Ninguno |
| Sage | SQL extendido, fix ORA-01722, validacion cobertura DB | WS2: filtro exacto Jasper para alinear conteo | Necesita `.jrxml` o SQL Jasper |
| Nova | Enrichment pipeline, token lock, batch limit | WS3: conectar query certificacion a UI | Enrichment all-at-once → migrar a lazy |
| Ivy | Validacion flujo en localhost:4177, sign-off borrador | Casos de prueba equivalencia por id_transaccion | Necesita id_transaccion de muestra Jasper |
| Milo | Benchmarking visual completado | Standby hasta siguiente pantalla | Ninguno |
| Dash | Sin tareas activas | Instalar GitHub CLI | CLI no instalado |
| Kira | Intake PBI-202787 definido | Priorizar Wave 1 post-certificacion | Ninguno |

---

## Detalle de tareas

### T-01 · Baseline Jasper normalizado
**Owner:** Sage | **ETA:** 2026-06-16 AM | **Estado:** ⏳ PENDIENTE

- [ ] `python scripts/inspect_report_xls.py` sobre `data/jasper-reference/report6.xls`
- [ ] `data/jasper-reference/baseline_normalizado.csv` generado (3913 filas)
- [ ] Mapeo columnas XLS→ORDS en `docs/sprint-3/mapeo-columnas-xls-ords.md`
- [ ] Conteo verificado: `len(df) == 3913`

---

### T-02 · Identificar filtro Jasper exacto
**Owner:** Sage | **ETA:** 2026-06-16 PM | **Estado:** ⏳ PENDIENTE

- [ ] Inspeccionar columnas XLS para inferir filtros (compania, ramo, tipo)
- [ ] Ejecutar variaciones SQL en DB hasta convergencia a ~3913
- [ ] `backend/ords/sql/certif_query_jasper_equiv.sql` creado
- [ ] Checklist `docs/sprint-2/checklist-equivalencia-ords-jasper.md` actualizado

---

### T-03 · Matriz equivalencia campo a campo
**Owner:** Sage + Nova | **ETA:** 2026-06-17 PM | **Estado:** ⏳ PENDIENTE (espera T-01, T-02)

- [ ] JOIN baseline_normalizado.csv vs payload ORDS por `id_transaccion`
- [ ] % match calculado por campo con clasificacion de diferencia
- [ ] `data/sprint-3/matriz-diff-ords-jasper.csv` generado
- [ ] `docs/sprint-3/resultado-equivalencia.md` con tabla resumen
- [ ] Criticos >= 99.5% | Alta >= 99.0%

---

### T-04 · Correcciones de datos (timebox 0.5d)
**Owner:** Sage / Nova | **ETA:** 2026-06-17 fin | **Estado:** ⏳ PENDIENTE (espera T-03)

- [ ] Aplicar solo correcciones con causa raiz identificada
- [ ] Commit individual por campo corregido
- [ ] Re-ejecutar T-03 post-correcciones

---

### T-05 · Lazy enrichment frontend
**Owner:** Nova | **ETA:** 2026-06-17 | **Estado:** ⏳ PENDIENTE (paralelo)

- [ ] IntersectionObserver o enrichment por pagina cargada
- [ ] Eliminar `MAX_ENRICHMENT_BATCH` hardcoded
- [ ] Prueba en `localhost:4177` con 100+ filas sin cuelgue

---

### T-06 · QA sign-off final
**Owner:** Ivy | **ETA:** 2026-06-18 PM | **Estado:** ⏳ PENDIENTE (espera T-03, T-04)

- [ ] Revisar `resultado-equivalencia.md`: umbrales cumplidos
- [ ] Validar UI con ventana 2026-01-01..2026-02-17
- [ ] `docs/qa/sprint-3-signoff.md` redactado con GO/NO-GO
- [ ] `telefono_3 = N/D` documentado como limitacion aceptada

---

### T-07 · Cierre y PR Sprint 3
**Owner:** Remy | **ETA:** 2026-06-18 fin | **Estado:** ⏳ PENDIENTE (espera T-06)

- [ ] `docs/sprint-3/done.md` → CERRADO
- [ ] `PROJECT_BRIEF.md` secciones 7+8 actualizadas para Sprint 4
- [ ] PR `feature/sprint-3-certificacion-jasper` → `develop` abierto

---

## Tareas activas

### T1. Baseline Jasper reproducible
Owner: Ivy + Sage  
Estado: PENDIENTE

Checklist:
- [ ] Congelar archivo Jasper de referencia y ventana.
- [ ] Normalizar dataset (tipos y nullables).
- [ ] Publicar metadatos de baseline.

### T2. Filtro Jasper equivalente en ORDS
Owner: Sage  
Estado: PENDIENTE

Checklist:
- [ ] Identificar regla exacta que reduce universo ORDS.
- [ ] Ejecutar conteo comparativo hasta convergencia.
- [ ] Documentar query/endpoint canónico de certificacion.

### T3. Matriz de equivalencia por campo
Owner: Nova + Sage  
Estado: PENDIENTE

Checklist:
- [ ] Generar join por `id_transaccion` ORDS vs Jasper.
- [ ] Calcular diferencias por campo y tipo.
- [ ] Proponer/fijar ajustes donde aplique.

### T4. QA sign-off final de data
Owner: Ivy  
Estado: PENDIENTE

Checklist:
- [ ] Validar evidencia numerica y visual.
- [ ] Confirmar umbrales de match por prioridad.
- [ ] Emitir GO/NO-GO en `docs/qa/sprint-3-signoff.md`.

---

## Gate de cierre

- [ ] Conteo equivalente validado.
- [ ] Match >=99.5% campos criticos.
- [ ] Match >=99.0% campos alta prioridad.
- [ ] Diferencias residuales con owner/fecha.
- [ ] QA sign-off final publicado.

---

## Notas

- Regla mandatoria: no duplicar servicios. Toda resolucion debe partir de exploracion ORDS (`metadata-catalog`, `open-api-catalog`).
