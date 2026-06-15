# Modelo Operativo para Escalar a 100+ Pantallas

Estado: ACTIVO  
Owner: Remy (coordinacion)  
Revisores: Kira, Milo, Nova, Sage, Dash, Ivy

## 1. Diagnostico (causas raiz de desorganizacion)

1. Multiples documentos con decisiones similares en lugares distintos.
2. Trazabilidad incompleta entre plan, evidencia tecnica, QA y cierre.
3. Cierre de sprint sin checklist de calidad documental ejecutado al 100%.
4. Entradas de trabajo no estandarizadas por plantilla (ruido de arranque).
5. Falta de metricas operativas comunes por equipo y por pantalla.

## 2. Riesgo de no corregir (100+ pantallas)

- Incremento de retrabajo por inconsistencias.
- Caida de velocidad por ambiguedad de alcance.
- Mayor tasa de defectos de integracion frontend-ORDS.
- QA tardio y bloqueos cerca de release.
- Poca previsibilidad de sprint y fecha de entrega.

## 3. Modelo de ejecucion (pipeline obligatorio)

Cada pantalla debe pasar por este flujo, sin saltos:

1. Intake inicial o delta-only (si ya existe baseline).
2. Analisis funcional + artefacto Oracle.
3. Evaluacion ORDS reuse-first y checkpoint humano.
4. Implementacion backend/frontend.
5. Evidencia tecnica (build, endpoints, smoke).
6. QA equivalencia + sign-off.
7. Handoff (`done.md`) y lecciones aprendidas.

## 4. Roles y responsabilidad por gate

- Kira: claridad de flujo funcional y criterios de aceptacion.
- Milo: consistencia visual y accesibilidad base.
- Nova: coherencia de contratos y estado UI.
- Sage: ORDS, SQL, payloads, performance base.
- Dash: entorno, seguridad operativa, despliegue, observabilidad.
- Ivy: validacion equivalencia y decision GO/NO-GO.
- Remy: secuencia de gates, owners, bloqueos y cierre.

## 5. Estructura documental minima por pantalla

## 5.1 Global (una sola vez)
- `PROJECT_BRIEF.md`
- `docs/governance/process/orquestacion-pbi-ords-react.md`
- `docs/governance/process/gitflow.md`
- `docs/templates/plantilla-intake-migracion.md`
- `docs/qa/screen-migration-equivalence-checklist.md`

## 5.2 Por sprint
- `docs/sprint-N/plan.md`
- `docs/sprint-N/progress.md`
- `docs/sprint-N/revision-multiroles-documentacion.md`
- `docs/qa/sprint-N-signoff.md` o equivalente
- `docs/sprint-N/done.md`

## 6. Politicas anti-caos (obligatorias)

1. Un tema, una fuente de verdad.
2. Ningun sprint cierra sin sign-off QA y done publicado.
3. Ninguna pantalla inicia sin intake (`GO_INTAKE_COMPLETO` o `GO_CONTINUIDAD_DELTA`).
4. Ningun endpoint nuevo sin evaluar reutilizacion de modulo ORDS existente.
5. Todo bloqueo debe tener owner + fecha + plan de salida.

## 7. Metricas de eficiencia para 100+ pantallas

1. Lead time por pantalla (inicio intake -> QA sign-off).
2. % pantallas con retrabajo post-QA.
3. % endpoints reusados vs nuevos.
4. % sprints cerrados con done + sign-off completos.
5. Defectos Sev1/Sev2 por sprint.

Objetivo inicial:
- >= 85% pantallas sin retrabajo mayor.
- >= 70% reuso ORDS donde aplique.
- 100% sprints con cierre documental completo.

## 8. Cadencia de revision multirol

- Lunes: plan y riesgos (Remy + todos los roles).
- Mitad de sprint: checkpoint de consistencia documental.
- Cierre de sprint: consilium de calidad y decision GO/NO-GO.

## 9. Definicion de listo para escalar

Se considera que el programa esta listo para 100+ pantallas cuando:

1. Tres sprints consecutivos cierran con gates completos.
2. No hay inconsistencias abiertas entre rutas runtime y docs.
3. Sign-off QA sale en fecha en al menos 90% de pantallas del sprint.
4. El backlog tiene intake estandarizado y estimaciones comparables.
