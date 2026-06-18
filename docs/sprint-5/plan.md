# Sprint 5 Plan: PBI-203844 reemb_pago - Discovery + Contrato ORDS

Estado: CERRADO (equivale a Sprint 1 del ciclo PBI-203844)
Owner: Remy
Fecha de inicio: 2026-06-16
Fecha de cierre: 2026-06-16
Branch objetivo: feature/sprint-5-pbi-203844

## Objetivo del sprint

Cerrar discovery funcional-tecnico, publicar matriz ORDS reutilizable/adaptable/nuevo y aprobar contrato de datos para habilitar construccion en Sprint 6.

## Nota de numeracion

Para este PBI, este sprint corresponde al Sprint 1 del ciclo operativo, manteniendo la numeracion global del proyecto (Sprint 5).

## Alcance Sprint 5

1. Consolidar reglas criticas desde XML, levantamiento, transcript e imagenes.
2. Publicar salida de extraccion en `docs/intake/pantallas/PBI-203844/salidas/reemb_pago/`.
3. Ejecutar checkpoint ORDS 2.5 y emitir matriz REUTILIZABLE | ADAPTABLE | NUEVO.
4. Definir contrato de datos (request/response) para flujo MVP.
5. Dejar backlog de construccion Sprint 6 priorizado.

## Tareas del sprint

### T-01 Extraccion funcional consolidada
Owner: Kira + Sage

- [x] Inventario de secciones, campos y validaciones.
- [x] Reglas de negocio criticas y dependencias.
- [x] Lista de ambiguedades para decision.

DoD:
- [x] Documento de extraccion publicado en `salidas/reemb_pago`.

### T-02 Matriz ORDS y checkpoint 2.5
Owner: Sage + Remy

- [x] Levantar endpoints y modulos candidatos.
- [x] Clasificar: REUTILIZABLE | ADAPTABLE | NUEVO.
- [x] Definir riesgos de seguridad/performance/versionado.

DoD:
- [x] Matriz publicada con recomendacion tecnica por item.

### T-03 Contrato de datos MVP
Owner: Sage + Nova + Ivy

- [x] Definir payload de busqueda/carga principal.
- [x] Definir respuesta canonica y nullability.
- [x] Alinear criterios de testabilidad.

DoD:
- [x] Contrato aprobado por Nova e Ivy.

### T-04 Plan de QA temprano
Owner: Ivy

- [x] Casos criticos de smoke funcional.
- [x] Criterios GO/NO-GO para Sprint 6.
- [x] Evidencia minima requerida por fase.

DoD:
- [x] Plan QA de arranque registrado en progress.

### T-05 Cierre de sprint y handoff
Owner: Remy

- [x] Actualizar progress con evidencia y estado final.
- [x] Completar `docs/sprint-5/done.md`.
- [x] Actualizar `PROJECT_BRIEF.md` (secciones 7 y 8).

DoD:
- [x] Sprint 5 cerrado con GO para construccion de Sprint 6.

## Riesgos

1. Regla funcional ambigua en legacy.
- Mitigacion: bloqueo temprano y decision explicita.

2. Endpoint no reutilizable detectado.
- Mitigacion: solicitud formal de aprobacion al CEO antes de crear nuevo endpoint.

3. Diferencias entre comportamiento esperado y datos reales.
- Mitigacion: pruebas de muestra con evidencia desde sprint 5.

## Criterios de aceptacion Sprint 5

- [x] Salida de extraccion publicada y revisada.
- [x] Matriz ORDS publicada y validada.
- [x] Contrato de datos MVP aprobado.
- [x] Plan QA temprano definido.
- [x] GO documentado para iniciar Sprint 6.
