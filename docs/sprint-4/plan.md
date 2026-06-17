# Sprint 4 Plan: PBI-203844 reemb_pago + Retro-Driven Delivery

Estado: LISTO PARA INICIAR
Owner: Remy
Fecha de preparacion: 2026-06-16
Branch objetivo: feature/sprint-4-pbi-203844

## Objetivo del sprint

Ejecutar la siguiente pantalla aplicando todas las lecciones de Sprint 3 desde el dia 1:

- contrato ORDS claro antes de UI,
- certificacion de datos con evidencia reproducible,
- QA por fases con gates,
- cierre sin deuda operativa.

## Decision de arranque cerrada

- Decision D-01: cerrada.
- Pantalla objetivo confirmada: `reemb_pago` (PBI-203844).
- Se autoriza inicio tecnico bajo gates y regla ORDS de aprobacion explicita para endpoints nuevos.

## Equipo y enfoque

| Rol | Nombre | Foco Sprint 4 |
|---|---|---|
| Producer | Remy | scope, gates, coordinacion, cierre |
| Product | Kira | claridad funcional y criterios de aceptacion |
| Visual | Milo | consistencia visual y accesibilidad |
| Frontend | Nova | componentes, estado, UX de datos |
| Backend | Sage | SQL/ORDS canonico y performance |
| QA | Ivy | evidencia reproducible + sign-off |
| DevOps | Dash | automatizacion minima y pipeline de validacion |

## Principios de ejecucion (mandatorios)

1. Reuse-first (sin duplicar endpoints existentes).
2. Contrato de datos antes de render UI.
3. Evidencia en cada fase en progress.
4. Bugs alta/critica obligan gate NO_GO.
5. Cierre requiere sign-off QA formal.

## Tablero de tareas

### T-01 Seleccion de pantalla objetivo (D-01)
Owner: Remy + Kira

- [x] Seleccionar pantalla siguiente (nombre + objetivo de negocio)
- [x] Definir alcance de primera entrega (MVP funcional)
- [x] Registrar decisiones en retro

DoD:
- [x] D-01 cerrada y publicada en docs/sprint-4/progress.md

### T-02 Descubrimiento tecnico funcional
Owner: Sage + Nova + Kira

- [ ] Inventario de campos y reglas de negocio
- [ ] Parametros de filtros y comportamiento esperado
- [ ] Fuentes de datos reales y nullability por campo

DoD:
- [ ] Mapa funcional-tecnico publicado

### T-03 Contrato ORDS y baseline de datos
Owner: Sage

- [ ] Definir query canonica para pantalla
- [ ] Documentar endpoint(s) y payload de respuesta
- [ ] Ejecutar smoke SQL de cobertura de campos

DoD:
- [ ] Contrato ORDS aprobado por Nova + Ivy

### T-04 Implementacion frontend incremental
Owner: Nova + Milo

- [ ] Filtros y tabla base
- [ ] Enriquecimiento controlado por pagina/bloque
- [ ] Estados de carga, error y vacio claros

DoD:
- [ ] Flujo principal usable en localhost:3000

### T-05 QA por fases
Owner: Ivy

- [ ] Casos criticos definidos antes de test
- [ ] Validacion UI vs DB en muestra reproducible
- [ ] Registro de hallazgos por severidad

DoD:
- [ ] Acta QA preliminar en progress

### T-06 Sign-off y cierre
Owner: Remy + Ivy

- [ ] docs/qa/sprint-4-signoff.md
- [ ] docs/sprint-4/done.md en CERRADO
- [ ] Update de PROJECT_BRIEF secciones 7 y 8

DoD:
- [ ] GO o NO-GO formal con evidencia

## Criterios de aceptacion del sprint

- [ ] Pantalla objetivo definida y trazable.
- [ ] Flujo principal funcional con datos reales.
- [ ] Sin mapeos cruzados ni N/D incorrecto masivo.
- [ ] Paginacion o carga incremental validada.
- [ ] QA sign-off emitido.

## Riesgos iniciales y mitigacion

1. Filtro de negocio incompleto.
- Mitigacion: validar SQL canonico antes de UI.

2. Entorno de prueba no canonico.
- Mitigacion: certificar en localhost:3000 con proxy ORDS.

3. Cierre documental tardio.
- Mitigacion: actualizar progress por fase y done al finalizar.
