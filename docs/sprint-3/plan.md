# Sprint 3 Plan: Certificacion ORDS vs Jasper

Sprint Goal: Certificar equivalencia de datos en pantalla vs Jasper (XLS) con evidencia campo a campo y decision final GO/NO-GO.

Owner: Remy (Producer)  
Backend: Sage  
Frontend: Nova  
QA: Ivy  
Duracion objetivo: 2026-06-16 a 2026-06-18

---

## 1. Scope

### Objetivo funcional

Asegurar que la data renderizada en pantalla desde ORDS representa la misma verdad de negocio que Jasper para la misma ventana y filtros.

### Objetivo tecnico

- Identificar y aplicar filtros Jasper faltantes.
- Obtener equivalencia de valores por `id_transaccion`.
- Cerrar diferencias de formato/nullable sin duplicar servicios.

### Principio mandatorio

- Reuse-first: primero explorar `metadata-catalog` y `open-api-catalog`.
- Prohibido duplicar endpoint/servicio si ya existe contrato en ORDS.

---

## 2. Entregables

1. `docs/sprint-3/progress.md` actualizado diariamente.
2. Actualizacion de `docs/sprint-2/checklist-equivalencia-ords-jasper.md` con resultados finales.
3. Matriz de diferencias ORDS vs Jasper por `id_transaccion` (CSV o tabla en markdown).
4. Acta QA en `docs/qa/sprint-3-signoff.md` con decision GO/NO-GO de equivalencia.
5. `docs/sprint-3/done.md` con resumen y handoff.

---

## 3. Workstreams

### WS1 - Baseline de comparacion (Sage + Ivy)

- Extraer muestra Jasper controlada (ventana 2026-01-01..2026-02-17).
- Normalizar tipos (fecha, numericos, nullables, texto).
- Definir llave de comparacion primaria: `id_transaccion`.

Criterio Done:
- Baseline Jasper versionado y reproducible.

### WS2 - Equivalencia de conteo (Sage)

- Reconstruir filtros Jasper exactos en ORDS/query de certificacion.
- Resolver diferencia de volumen (3913 vs universo ORDS base).

Criterio Done:
- Conteo ORDS = conteo Jasper para misma regla de negocio.

### WS3 - Equivalencia campo a campo (Nova + Sage + Ivy)

Campos criticos:
- `id_transaccion`, `fec_tra`, `cliente`, `compania`, `ramo`, `secuencial`, `monto`, `estado`.

Campos alta prioridad:
- `codigo_rechazo`, `descripcion_rechazo`, `num_autoriza`, `estatus_poliza`, `frecuencia_pago`, `oficial`, `gerente`, `intermediario`.

Campos extendidos:
- `tipo_documento`, `num_documento`, `grupo`, `telefono_1`, `telefono_2`, `telefono_3`, `nombre_director`.

Criterio Done:
- >= 99.5% match en campos criticos.
- >= 99.0% match en alta prioridad.
- Diferencias restantes documentadas con owner/fecha.

### WS4 - QA y decision final (Ivy + Remy)

- Ejecutar casos de validacion en UI con evidencia visual.
- Consolidar riesgos residuales.
- Emitir GO/NO-GO de certificacion.

Criterio Done:
- `docs/qa/sprint-3-signoff.md` finalizado y firmado.

---

## 4. Criterios de aceptacion Sprint 3

- [ ] Conteo ORDS/Jasper alineado para la ventana y filtros acordados.
- [ ] Matriz de diferencias publicada y reproducible.
- [ ] Cumplimiento de umbrales de equivalencia por prioridad.
- [ ] QA sign-off final emitido.
- [ ] Sin creacion de servicios duplicados (evidencia de exploracion ORDS adjunta).

---

## 5. Riesgos y mitigacion

1. Filtros Jasper no visibles en SQL actual.
- Mitigacion: trazabilidad desde XLS + scripts de inspeccion + validacion funcional.

2. Diferencias por formato (fechas/decimales/null).
- Mitigacion: normalizacion previa antes de comparar.

3. Timeouts por enrichment masivo.
- Mitigacion: lotes limitados + cache + control de token concurrente.

---

## 6. Timeline sugerido

Dia 1:
- Baseline Jasper + filtro exacto + conteo equivalente.

Dia 2:
- Comparacion campo a campo + correcciones.

Dia 3:
- QA sign-off + cierre de sprint.
