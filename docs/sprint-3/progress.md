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
