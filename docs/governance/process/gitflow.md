# GitFlow Operativo del Repositorio

## Objetivo
Reducir riesgo por commits grandes y mixtos, mejorar trazabilidad y control de release.

## Ramas
- main: estado productivo y estable.
- develop: integracion continua de trabajo aprobado.
- feature/<scope>-<short-name>: nuevas capacidades.
- bugfix/<scope>-<short-name>: correcciones no criticas de produccion.
- release/<version>: estabilizacion previa a pasar a main.
- hotfix/<version>: correcciones urgentes sobre main.
- docs/<short-name>: cambios documentales aislados.

## Flujo Diario
1. Crear rama desde develop.
2. Commits pequenos y semanticos.
3. Abrir PR a develop.
4. Validar build/test/checklist.
5. Merge con squash o merge commit (sin mezclar cambios no relacionados).

## Flujo de Release
1. Crear release/<version> desde develop.
2. Solo fixes de estabilizacion dentro de release.
3. QA sign-off.
4. Merge release a main.
5. Merge release de vuelta a develop.
6. Crear tag de version.

## Flujo de Hotfix
1. Crear hotfix/<version> desde main.
2. Corregir, validar, PR rapido.
3. Merge a main.
4. Merge tambien a develop.
5. Tag de hotfix.

## Convenciones de Commit
Formatos recomendados:
- feat: nueva funcionalidad
- fix: correccion
- docs: documentacion
- refactor: mejora interna sin cambio funcional
- test: pruebas
- chore: mantenimiento

Ejemplo:
- feat: alinear endpoints ORDS a facturacion api v1 (Fixes #123)

## Politicas Minimas
- No commits gigantes con backend+frontend+docs sin separacion.
- No mezclar cambios de entorno local con codigo de producto.
- Un PR = un objetivo funcional claro.
- Toda historia de usuario relevante debe referenciar issue/PBI.

## Plan de Adopcion Inmediata
1. Crear develop.
2. Mover trabajo activo a feature/sprint-1-ords-real.
3. Separar PRs por objetivo:
   - docs/orquestacion-pbi
   - feature/ords-real-frontend
   - bugfix/scripts-windows
4. Cerrar sprint con release/sprint-1.
