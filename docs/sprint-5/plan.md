# Sprint 5 Plan: PBI-203844 reemb_pago - Discovery + Contrato ORDS

Estado: ACTIVO
Owner: Remy
Fecha de inicio: 2026-06-16
Branch objetivo: feature/sprint-5-pbi-203844

## Objetivo del sprint

Cerrar discovery funcional-tecnico, publicar matriz ORDS reutilizable/adaptable/nuevo y aprobar contrato de datos para habilitar construccion en Sprint 6.

## Alcance Sprint 5

1. Consolidar reglas criticas desde XML, levantamiento, transcript e imagenes.
2. Publicar salida de extraccion en `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/`.
3. Ejecutar checkpoint ORDS 2.5 y emitir matriz REUTILIZABLE | ADAPTABLE | NUEVO.
4. Definir contrato de datos (request/response) para flujo MVP.
5. Dejar backlog de construccion Sprint 6 priorizado.

## Tareas del sprint

### T-01 Extraccion funcional consolidada
Owner: Kira + Sage

- [ ] Inventario de secciones, campos y validaciones.
- [ ] Reglas de negocio criticas y dependencias.
- [ ] Lista de ambiguedades para decision.

DoD:
- [ ] Documento de extraccion publicado en `salidas/reemb_pago`.

### T-02 Matriz ORDS y checkpoint 2.5
Owner: Sage + Remy

- [ ] Levantar endpoints y modulos candidatos.
- [ ] Clasificar: REUTILIZABLE | ADAPTABLE | NUEVO.
- [ ] Definir riesgos de seguridad/performance/versionado.

DoD:
- [ ] Matriz publicada con recomendacion tecnica por item.

### T-03 Contrato de datos MVP
Owner: Sage + Nova + Ivy

- [ ] Definir payload de busqueda/carga principal.
- [ ] Definir respuesta canonica y nullability.
- [ ] Alinear criterios de testabilidad.

DoD:
- [ ] Contrato aprobado por Nova e Ivy.

### T-04 Plan de QA temprano
Owner: Ivy

- [ ] Casos criticos de smoke funcional.
- [ ] Criterios GO/NO-GO para Sprint 6.
- [ ] Evidencia minima requerida por fase.

DoD:
- [ ] Plan QA de arranque registrado en progress.

### T-05 Cierre de sprint y handoff
Owner: Remy

- [ ] Actualizar progress con evidencia y estado final.
- [ ] Completar `docs/sprint-5/done.md`.
- [ ] Actualizar `PROJECT_BRIEF.md` (secciones 7 y 8).

DoD:
- [ ] Sprint 5 cerrado con GO para construccion de Sprint 6.

## Riesgos

1. Regla funcional ambigua en legacy.
- Mitigacion: bloqueo temprano y decision explicita.

2. Endpoint no reutilizable detectado.
- Mitigacion: solicitud formal de aprobacion al CEO antes de crear nuevo endpoint.

3. Diferencias entre comportamiento esperado y datos reales.
- Mitigacion: pruebas de muestra con evidencia desde sprint 5.

## Criterios de aceptacion Sprint 5

- [ ] Salida de extraccion publicada y revisada.
- [ ] Matriz ORDS publicada y validada.
- [ ] Contrato de datos MVP aprobado.
- [ ] Plan QA temprano definido.
- [ ] GO documentado para iniciar Sprint 6.
