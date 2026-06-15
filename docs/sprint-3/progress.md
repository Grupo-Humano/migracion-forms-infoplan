# Sprint 3 Progress Tracker

Sprint: Sprint 3 - Certificacion ORDS vs Jasper  
Periodo: 2026-06-16 a 2026-06-18  
Owner: Remy

---

## Estado general

- Inicio: PENDIENTE
- Estado actual: EN PREPARACION
- Riesgo principal: diferencia de conteo entre Jasper y ORDS base sin filtro equivalente final.

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
