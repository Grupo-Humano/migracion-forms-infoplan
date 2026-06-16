# Documentacion del Proyecto

Este archivo define la estructura documental oficial para evitar dispersion y duplicidad.

## 1. Fuente de verdad por tipo

- Gobierno general: `PROJECT_BRIEF.md`
- Orquestacion PBI -> ORDS -> React: `docs/governance/process/orquestacion-pbi-ords-react.md`
- Flujo Git y ramas: `docs/governance/process/gitflow.md`
- Plan macro de sprints: `docs/governance/process/sprint-master-plan.md`
- Sprint activo: `docs/sprint-2/plan.md`, `docs/sprint-2/progress.md`, `docs/sprint-2/done.md`
- QA transversal: `docs/qa/screen-migration-equivalence-checklist.md`
- Sign-off de sprint: `docs/qa/sprint-2-deployment-signoff.md`
- Intake obligatorio por plantilla: `docs/templates/plantilla-intake-migracion.md`
- Hub central de insumos: `docs/intake/README.md`
- Registro unico de solicitudes: `docs/intake/solicitudes-pantallas.md`
- Tarjeta operativa por pantalla: `docs/templates/tarjeta-pantalla.md`
- Modelo operativo para escala 100+ pantallas: `docs/governance/modelo-operativo-100-pantallas.md`
- Plan de accion anti-ahogo: `docs/governance/plan-accion-anti-ahogo.md`
- Flujo visual integral para presentacion: `docs/governance/visual-flujo-proyecto.md`

## 1.1 Estructura recomendada por sprint

- Core del sprint (raiz de `docs/sprint-N/`):
   - `plan.md`
   - `progress.md`
   - `done.md`
   - `evaluacion-integral-proyecto.md` (si aplica)
   - `revision-multiroles-documentacion.md` (obligatorio en cierre)
- Coordinacion (subcarpeta):
   - `docs/sprint-N/coordination/*`
- Archivo historico (subcarpeta):
   - `docs/sprint-N/archive/*`

## 2. Reglas de organizacion documental

1. Una sola fuente de verdad por tema (evitar clones de contenido).
2. Todo documento nuevo debe declarar objetivo, owner y estado.
3. Si un documento queda obsoleto, moverlo a estado `ARCHIVADO` y referenciar reemplazo.
4. No cerrar sprint sin:
   - `progress.md` actualizado,
   - `done.md` publicado,
   - sign-off QA emitido o bloqueos explicitados.

## 3. Flujo recomendado por sprint

1. Inicio: actualizar `plan.md` + checklist de intake por plantilla.
2. Ejecucion: registrar evidencia en `progress.md`.
3. Cierre tecnico: publicar artefactos y evidencias.
4. Cierre QA: actualizar sign-off.
5. Handoff: publicar `done.md` y actualizar `PROJECT_BRIEF.md`.

## 4. Control de calidad documental

Requisito obligatorio: ejecutar revision multirol antes del cierre del sprint.

Documento de control:
- `docs/sprint-2/revision-multiroles-documentacion.md`

## 5. Criterio de completitud documental

La documentacion de un sprint se considera completa si:
- hay consistencia entre rutas/entornos reales y lo escrito,
- no hay tareas ambiguas sin owner/fecha,
- los riesgos abiertos tienen plan de mitigacion,
- QA deja recomendacion final GO/NO-GO.
