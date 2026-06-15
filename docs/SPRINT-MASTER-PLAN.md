# Sprint Master Plan (Todos los Sprints Posibles)

## Objetivo
Definir la hoja de ruta completa de migracion Oracle Forms -> ORDS -> React, desde Sprint 0 hasta cierre de programa, con escenarios de alcance segun velocidad real del equipo.

## Supuestos Base
- Se trabaja por olas: Wave 1 (pilotos simples), Wave 2 (formas medianas), Wave 3 (formas complejas).
- Cada PBI ejecuta ciclo estandar: PBI -> video -> analisis forma -> analisis ORDS -> checkpoint humano -> diseno ORDS -> React -> QA.
- GitFlow activo: develop + feature/bugfix/release/hotfix.

## Cronograma Macro por Escenarios

| Escenario | Duracion | Sprints estimados | Uso recomendado |
|-----------|----------|-------------------|-----------------|
| Acelerado | 9-12 meses | 12-14 | Equipo estable, baja deuda tecnica inesperada |
| Base | 12-18 meses | 15-18 | Escenario esperado del proyecto |
| Conservador | 18-24 meses | 19-24 | Alta variabilidad funcional/tecnica |

## Plan Completo de Sprints (Base)

### Sprint 0 - Reinicio estrategico
- Objetivo: reset operativo y cierre de baseline anterior.
- Entregables:
  - docs/sprint-0/plan.md
  - docs/sprint-0/progress.md
  - Decision de forma piloto Wave 1
- Criterio de salida:
  - ORDS real accesible
  - scripts estables en Windows
  - Sprint 1 real planificado

### Sprint 1 - Piloto real (analisis + contratos)
- Objetivo: ejecutar primer PBI real end-to-end hasta contratos API listos.
- Entregables:
  - especificacion ORDS validada
  - mapeo de componentes React
  - matriz QA de equivalencia del piloto
- Criterio de salida:
  - checkpoint humano de ORDS aprobado
  - backlog tecnico cerrado para build

### Sprint 2 - Piloto real (build)
- Objetivo: implementar frontend + ORDS del piloto.
- Entregables:
  - endpoints ORDS operativos
  - UI React funcional
  - pruebas unitarias y e2e iniciales
- Criterio de salida:
  - demo funcional completa del piloto

### Sprint 3 - Piloto real (hardening)
- Objetivo: estabilizar, corregir y preparar release del piloto.
- Entregables:
  - bugfixes bloqueantes
  - performance baseline
  - QA sign-off
- Criterio de salida:
  - release candidata aprobada

### Sprint 4 - Wave 1 Batch A
- Objetivo: migrar 2-3 formas simples reutilizando plantilla del piloto.
- Entregables:
  - ORDS + React de lote A
  - automatizacion QA por plantilla
- Criterio de salida:
  - 2-3 formas listas con regression suite

### Sprint 5 - Wave 1 Batch B
- Objetivo: migrar siguiente lote de formas simples.
- Entregables:
  - lote B completado
  - reduccion de tiempo por forma
- Criterio de salida:
  - throughput estable por sprint

### Sprint 6 - Wave 1 Batch C + cierre de ola
- Objetivo: cerrar Wave 1 y consolidar estandares.
- Entregables:
  - lote C completado
  - handbook de patron reusable
- Criterio de salida:
  - Go para Wave 2

### Sprint 7 - Wave 2 Arranque
- Objetivo: iniciar formas medianas con mas reglas de negocio.
- Entregables:
  - analisis funcional profundo
  - endpoints con validaciones avanzadas
- Criterio de salida:
  - primera forma media en estado funcional

### Sprint 8 - Wave 2 Batch A
- Objetivo: migrar 2 formas medianas.
- Entregables:
  - forms medianas con QA automatizado
- Criterio de salida:
  - sin blockers criticos abiertos

### Sprint 9 - Wave 2 Batch B
- Objetivo: completar lote adicional de formas medianas.
- Entregables:
  - mejoras de performance y trazabilidad
- Criterio de salida:
  - readiness para casos complejos

### Sprint 10 - Wave 2 Cierre
- Objetivo: cerrar ola media y preparar casos complejos.
- Entregables:
  - decision de arquitectura para complejos
  - runbooks actualizados
- Criterio de salida:
  - Go para Wave 3

### Sprint 11 - Wave 3 Arranque (formas complejas)
- Objetivo: atacar primera forma compleja (ej. reportes con exportaciones especiales).
- Entregables:
  - descomposicion funcional completa
  - contrato ORDS para escenarios complejos
- Criterio de salida:
  - primera vertical compleja cerrada en dev

### Sprint 12 - Wave 3 Batch A
- Objetivo: expandir complejas con lecciones aprendidas.
- Entregables:
  - 1-2 complejas migradas
- Criterio de salida:
  - QA con tasa de defectos aceptable

### Sprint 13 - Wave 3 Batch B
- Objetivo: continuar migracion compleja y reducir deuda tecnica.
- Entregables:
  - refactor de componentes compartidos
  - observabilidad ampliada
- Criterio de salida:
  - estabilidad operativa sostenida

### Sprint 14 - Wave 3 Cierre
- Objetivo: finalizar backlog de formas complejas priorizadas.
- Entregables:
  - cierre de ola compleja
  - plan de transicion final
- Criterio de salida:
  - backlog critico en estado done

### Sprint 15 - Integracion total
- Objetivo: consolidar integracion transversal y UAT.
- Entregables:
  - pruebas integrales
  - reporte de equivalencia global
- Criterio de salida:
  - UAT aprobado

### Sprint 16 - Estabilizacion pre-corte
- Objetivo: hardening final pre-produccion.
- Entregables:
  - fixes finales
  - runbook operacional final
- Criterio de salida:
  - release final candidata

### Sprint 17 - Go-live faseada
- Objetivo: despliegue controlado por lotes.
- Entregables:
  - despliegue progresivo
  - monitoreo y soporte intensivo
- Criterio de salida:
  - operacion estable

### Sprint 18 - Hypercare y cierre
- Objetivo: soporte post go-live y cierre formal de programa.
- Entregables:
  - reporte final
  - backlog residual priorizado
  - transferencia operativa
- Criterio de salida:
  - programa cerrado

## Sprints Opcionales (Escenario conservador)

Si aparecen bloqueos mayores, se habilitan sprints 19-24 para:
- Remediacion de deuda tecnica critica.
- Integraciones tardias (reporting/export legacy).
- Re-trabajo de forms complejas no cubiertas.
- Hardening de seguridad/compliance.

## Regla para activar el siguiente sprint

Un sprint N solo abre si sprint N-1 cumple:
1. Done document publicado: docs/sprint-N/done.md.
2. Progress document actualizado y sin tareas ambiguas.
3. Issues bloqueantes con owner y fecha.
4. Gate de QA firmado cuando aplica.

## Handoff y Recuperacion de Contexto

Prompt de cold start:
Read PROJECT_BRIEF.md and docs/sprint-N/progress.md. Continue from where it left off.

## Referencias
- docs/ORQUESTACION-PBI-ORDS-REACT.md
- docs/GITFLOW.md
- .agents/skills/ai-team-orchestration/references/sprint-plan-template.md
