# Sprint 3 Plan: Certificacion ORDS vs Jasper

**Sprint Goal:** Demostrar con evidencia reproducible que la data en pantalla (ORDS) es equivalente a Jasper para la misma ventana de negocio, y emitir acta GO/NO-GO.

**Owner:** Remy (Producer)  
**Branch:** `feature/sprint-3-certificacion-jasper`  
**Periodo:** 2026-06-16 a 2026-06-18 (3 dias)

| Rol | Nombre | Participacion |
|---|---|---|
| Producer | Remy | Coordinacion, gates de calidad, PR final |
| Backend | Sage | SQL de certificacion, filtro Jasper, query comparativa |
| Frontend | Nova | Visualizacion de diferencias en UI, lazy enrichment |
| QA | Ivy | Casos de prueba, ejecucion comparativa, sign-off |

---

## Contexto heredado de Sprint 2

| Dato | Valor |
|---|---|
| XLS Jasper de referencia | `data/jasper-reference/report6.xls` |
| Conteo Jasper (ventana completa) | **3913 filas** |
| Conteo ORDS base (estado R/C) | **39284 filas** |
| Brecha conocida | Jasper aplica filtros adicionales no replicados aun |
| Llave de comparacion | `id_transaccion` |
| Scripts disponibles | `scripts/inspect_report_xls.py`, `scripts/read_excel.py` |
| Bloqueador critico | Filtro Jasper exacto desconocido — necesita `.jrxml` o SQL |

---

## Principios mandatorios

- **Reuse-first**: explorar `metadata-catalog` y `open-api-catalog` antes de crear cualquier endpoint.
- **Cero duplicacion**: si el contrato ya existe en ORDS, reutilizar.
- **Evidencia reproducible**: toda comparacion debe poder re-ejecutarse con el mismo script.

---

## Tablero de Tareas

### T-01 · Baseline Jasper reproducible
**Owner:** Sage  
**Esfuerzo:** 0.5d  
**Dependencias:** ninguna (artefacto ya existe en `data/jasper-reference/`)  
**Prioridad:** CRITICA — bloquea T-02, T-03, T-04

**Descripcion:**  
Procesar `report6.xls` con `scripts/inspect_report_xls.py` para obtener un dataset normalizado (tipos, nullables, encoding) listo para comparacion.

**Acciones:**
1. Ejecutar `python scripts/inspect_report_xls.py` sobre `report6.xls`.
2. Exportar columnas disponibles, tipos inferidos y conteo final.
3. Mapear nombre de columna XLS → nombre de campo ORDS.
4. Guardar resultado normalizado en `data/jasper-reference/baseline_normalizado.csv`.

**Definition of Done:**
- [ ] Script ejecuta sin errores.
- [ ] `baseline_normalizado.csv` creado con 3913 filas.
- [ ] Mapeo de columnas XLS→ORDS publicado en `docs/sprint-3/mapeo-columnas-xls-ords.md`.
- [ ] Conteo verificado: `len(df) == 3913`.

---

### T-02 · Identificar y replicar filtro Jasper
**Owner:** Sage  
**Esfuerzo:** 1.0d  
**Dependencias:** T-01  
**Prioridad:** CRITICA — sin esto, la comparacion de conteo no es valida

**Descripcion:**  
Determinar por que Jasper muestra 3913 filas cuando ORDS base tiene 39284 para la misma ventana. El filtro adicional puede ser: compania especifica, ramo, tipo de cobro, estado secundario, o combinacion de ellos.

**Estrategia de investigacion (en orden):**
1. Inspeccionar columnas unicas del XLS para inferir filtros aplicados (compania, ramo, estado).
2. Cruzar valores de columna `compania` en XLS vs universo ORDS: ¿solo 1 compania?
3. Si hay `.jrxml` del reporte, extraer clausula `WHERE` del SQL interno.
4. Ejecutar variaciones de query SQL en DB real hasta que `COUNT(*)` converja a ~3913.

**Acciones:**
1. `SELECT compania, COUNT(*) FROM transacciones WHERE estado IN ('R','C') AND fec_tra BETWEEN ... GROUP BY compania` — identificar si Jasper filtra por 1 compania.
2. Aplicar filtros candidatos hasta convergencia de conteo.
3. Documentar query canonica de certificacion en `backend/ords/sql/certif_query_jasper_equiv.sql`.
4. Actualizar checklist `docs/sprint-2/checklist-equivalencia-ords-jasper.md` con hallazgo.

**Definition of Done:**
- [ ] Filtro identificado y documentado con evidencia SQL.
- [ ] `COUNT(*)` con filtro == conteo Jasper (tolerancia ±5 filas).
- [ ] `backend/ords/sql/certif_query_jasper_equiv.sql` creado y comentado.
- [ ] Checklist actualizado con resultado de T-02.

---

### T-03 · Matriz de equivalencia campo a campo
**Owner:** Sage + Nova  
**Esfuerzo:** 1.0d  
**Dependencias:** T-01, T-02  
**Prioridad:** ALTA

**Descripcion:**  
Comparar muestra ORDS vs Jasper por `id_transaccion`. Calcular % match por campo y clasificar diferencias.

**Campos por prioridad:**

| Prioridad | Campos | Umbral requerido |
|---|---|---|
| Critica | `id_transaccion`, `fec_tra`, `cliente`, `monto`, `estado` | >= 99.5% match |
| Alta | `codigo_rechazo`, `descripcion_rechazo`, `num_autoriza`, `estatus_poliza`, `frecuencia_pago`, `oficial`, `gerente`, `intermediario`, `compania`, `ramo`, `secuencial` | >= 99.0% match |
| Extendida | `tipo_documento`, `num_documento`, `grupo`, `telefono_1`, `telefono_2`, `nombre_director` | Documentar cobertura real |
| Excluida | `telefono_3` | N/D permanente — campo sin datos en DB |

**Tipos de diferencia a registrar:**

| Tipo | Descripcion |
|---|---|
| `faltante_ords` | ID existe en Jasper pero no en ORDS |
| `faltante_jasper` | ID existe en ORDS pero no en Jasper |
| `valor_distinto` | ID coincide, valor de campo diferente |
| `formato_distinto` | ID coincide, valor igual pero formato diferente (fecha, decimal) |

**Acciones:**
1. JOIN `baseline_normalizado.csv` (Jasper) con payload ORDS por `id_transaccion`.
2. Para cada campo: calcular `match_pct = matches / total * 100`.
3. Exportar diferencias a `data/sprint-3/matriz-diff-ords-jasper.csv`.
4. Resumir en tabla markdown en `docs/sprint-3/resultado-equivalencia.md`.
5. Para diferencias de formato: proponer fix en ORDS SQL o frontend.

**Definition of Done:**
- [ ] `matriz-diff-ords-jasper.csv` generado y versionado.
- [ ] `resultado-equivalencia.md` con tabla de % match por campo.
- [ ] Campos criticos >= 99.5% o discrepancia explicada con owner/fecha.
- [ ] Campos Alta >= 99.0% o discrepancia explicada con owner/fecha.

---

### T-04 · Correcciones de datos (si aplica)
**Owner:** Sage (SQL) / Nova (frontend)  
**Esfuerzo:** 0.5d max (timebox estricto)  
**Dependencias:** T-03  
**Prioridad:** MEDIA — solo ejecutar si T-03 revela fallas en umbrales

**Descripcion:**  
Corregir diferencias detectadas en T-03 que esten por debajo del umbral de aceptacion.

**Regla de scope:**
- Solo corregir campos que fallen el umbral Y tengan causa raiz identificada.
- Si la causa es datos faltantes en DB: documentar como limitacion funcional, no corregir en codigo.
- Prohibido crear nuevos endpoints para resolver diferencias de formato.

**Acciones (condicionales):**
- Si `fec_tra` tiene formato distinto: normalizar en SQL `TO_CHAR(fec_tra, 'YYYY-MM-DD')`.
- Si `monto` tiene precision distinta: revisar `ROUND()` en query ORDS.
- Si `codigo_rechazo` falta en ORDS: verificar JOIN con tabla de rechazos.
- Cada correccion: commit individual con referencia al campo corregido.

**Definition of Done:**
- [ ] Correcciones aplicadas con commit por campo.
- [ ] Re-ejecutar T-03 post-correcciones: umbrales cumplidos.
- [ ] Sin nuevos endpoints creados (reuse-first respetado).

---

### T-05 · Lazy enrichment frontend
**Owner:** Nova  
**Esfuerzo:** 0.5d  
**Dependencias:** ninguna (paralelo a T-01..T-03)  
**Prioridad:** MEDIA — mejora rendimiento, no bloquea certificacion

**Descripcion:**  
Migrar el enrichment de `App.tsx` de all-at-once (batch fijo de 5) a on-demand: solo enriquecer filas visibles en viewport o al hacer scroll.

**Acciones:**
1. Implementar `IntersectionObserver` o enrichment por pagina cargada.
2. Eliminar `MAX_ENRICHMENT_BATCH` hardcoded.
3. Verificar que el token lock sigue funcionando bajo carga reducida.
4. Probar en `localhost:4177` con 100+ filas: sin cuelgue.

**Definition of Done:**
- [ ] Busqueda carga sin delay perceptible con 100+ filas.
- [ ] Enrichment ocurre al cargar cada pagina, no al recibir todos los resultados.
- [ ] `MAX_ENRICHMENT_BATCH` eliminado o comentado con razon.

---

### T-06 · QA sign-off final
**Owner:** Ivy  
**Esfuerzo:** 0.5d  
**Dependencias:** T-03, T-04  
**Prioridad:** CRITICA — gate final del sprint

**Descripcion:**  
Revisar toda la evidencia de certificacion y emitir decision GO/NO-GO.

**Acciones:**
1. Revisar `resultado-equivalencia.md`: todos los umbrales cumplidos?
2. Validar UI en pantalla con muestra real (fecha 2026-01-01..2026-02-17).
3. Confirmar que `telefono_3 = N/D` esta documentado como limitacion funcional aceptada.
4. Redactar `docs/qa/sprint-3-signoff.md` con:
   - Resumen de evidencia por campo.
   - Lista de limitaciones aceptadas.
   - Decision: GO | NO-GO | GO con condiciones.
5. Si NO-GO: listar condiciones bloqueantes con owner y fecha limite.

**Definition of Done:**
- [ ] `docs/qa/sprint-3-signoff.md` creado y completado.
- [ ] Decision GO/NO-GO emitida con justificacion.
- [ ] Si GO: checklist `docs/sprint-2/checklist-equivalencia-ords-jasper.md` marcado CERRADO.

---

### T-07 · Cierre y PR Sprint 3
**Owner:** Remy  
**Esfuerzo:** 0.25d  
**Dependencias:** T-06  
**Prioridad:** CRITICA

**Acciones:**
1. Actualizar `docs/sprint-3/done.md` con decision final y resumen.
2. Actualizar `PROJECT_BRIEF.md` secciones 7+8 para Sprint 4.
3. Commit final: `docs(sprint-3): cierre + GO/NO-GO certificacion Jasper`.
4. Push + abrir PR `feature/sprint-3-certificacion-jasper` → `develop`.

**Definition of Done:**
- [ ] `done.md` estado = CERRADO.
- [ ] PR abierto y enlazado en este documento.
- [ ] Brief actualizado con Sprint 4 en estado PENDIENTE.

---

## Dependencias entre tareas

```
T-01 (Baseline) ──────────────────────────────┐
                                               ▼
T-02 (Filtro Jasper) ──────────────────────► T-03 (Matriz) ──► T-04 (Correcciones) ──┐
                                                                                       ▼
T-05 (Lazy enrichment) [paralelo]                                              T-06 (QA sign-off)
                                                                                       │
                                                                                       ▼
                                                                               T-07 (Cierre PR)
```

---

## Criterios de aceptacion del sprint

- [ ] T-01: Baseline Jasper normalizado y versionado (3913 filas).
- [ ] T-02: Filtro Jasper identificado; conteo ORDS converge a ±5 filas.
- [ ] T-03: Matriz publicada; campos criticos >= 99.5%, alta >= 99.0%.
- [ ] T-04: Correcciones aplicadas si aplica (o explicitamente no necesarias).
- [ ] T-05: Enrichment lazy operativo sin cuelgue en 100+ filas.
- [ ] T-06: QA sign-off emitido con decision GO/NO-GO.
- [ ] T-07: PR abierto, brief actualizado, done.md CERRADO.

---

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigacion |
|---|---|---|---|
| Filtro Jasper no visible sin `.jrxml` | ALTA | CRITICO | Inferir por inspeccion de columnas XLS + variaciones SQL |
| Diferencias de formato masivas | MEDIA | ALTO | Normalizar antes de comparar; no es bug de datos |
| T-04 excede timebox | MEDIA | MEDIO | Documentar limitacion funcional y continuar; no bloquear T-06 |
| Enrichment lazy rompe flujo existente | BAJA | MEDIO | Feature flag para revertir rapido |

---

## Entregables finales

| Artefacto | Ubicacion | Owner |
|---|---|---|
| Baseline Jasper normalizado | `data/jasper-reference/baseline_normalizado.csv` | Sage |
| Mapeo columnas XLS→ORDS | `docs/sprint-3/mapeo-columnas-xls-ords.md` | Sage |
| Query canonica de certificacion | `backend/ords/sql/certif_query_jasper_equiv.sql` | Sage |
| Matriz de diferencias | `data/sprint-3/matriz-diff-ords-jasper.csv` | Sage + Nova |
| Resultado equivalencia | `docs/sprint-3/resultado-equivalencia.md` | Sage + Nova |
| QA sign-off final | `docs/qa/sprint-3-signoff.md` | Ivy |
| Sprint 3 done | `docs/sprint-3/done.md` | Remy |

---

## Timeline

| Dia | Fecha | Tareas |
|---|---|---|
| Dia 1 | 2026-06-16 | T-01 + T-02 + inicio T-05 |
| Dia 2 | 2026-06-17 | T-03 + T-04 (si aplica) + cierre T-05 |
| Dia 3 | 2026-06-18 | T-06 + T-07 |
