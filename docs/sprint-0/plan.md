# Sprint 0 - Reinicio Estrategico de Migracion

> Objetivo del sprint: reiniciar la migracion desde cero usando todo lo aprendido, con ORDS real como baseline y proceso formal de orquestacion PBI -> ORDS -> React.
> Branch objetivo: feature/sprint-0-restart
> Duracion sugerida: 5 dias habiles

## Alcance

1. Re-baselining documental y tecnico.
2. Definicion de priorizacion Wave 1 (piloto simple) y Wave 2 (casos complejos).
3. Endurecimiento de herramientas de analisis.
4. Cierre de criterio de salida para comenzar desarrollo funcional por PBI.

## Priorizacion de Trabajo

| # | Task | Owner | Est | Resultado Esperado |
|---|------|-------|-----|--------------------|
| 1 | Reinicio oficial del estado de proyecto | Remy | 2h | Brief y tracker alineados a "start from zero" |
| 2 | Inventario de activos reutilizables | Remy + Sage + Nova | 4h | Lista de assets de backend/frontend que se conservan |
| 3 | Hardening de extractores | Sage | 6h | Scripts estables en Windows (sin errores CP1252 y rutas hardcodeadas) |
| 4 | Validacion ORDS real end-to-end | Sage + Dash | 4h | Conectividad real y smoke API documentados |
| 5 | Definir forma piloto Wave 1 | Kira + Remy + Sage | 3h | Forma seleccionada con justificacion de bajo riesgo |
| 6 | Criterios de QA equivalencia | Ivy | 4h | Matriz de pruebas base para comparar legado vs migrado |
| 7 | Mapa de componentes inicial React | Nova + Milo | 4h | Esqueleto de componentes para forma piloto |
| 8 | Plan de Sprint 1 real (post-reinicio) | Remy | 3h | Nuevo sprint 1 orientado a entrega funcional |

## Fases

### Fase 1: Reset y alineamiento
- Cerrar formalmente ciclo previo de baseline mock.
- Confirmar arquitectura actual: ORDS real + React.
- Publicar alcance de reinicio y criterios de exito.

### Fase 2: Fundaciones tecnicas
- Arreglar scripts de analisis.
- Validar ORDS real accesible.
- Verificar contrato API y convenciones snake_case.

### Fase 3: Plan funcional
- Seleccionar forma piloto Wave 1.
- Definir matriz QA de equivalencia.
- Dejar Sprint 1 listo para construccion funcional real.

## Criterios de Exito

- [ ] PROJECT_BRIEF actualizado con estado de reinicio.
- [ ] ORDS real validado con evidencia de conectividad.
- [ ] Scripts de extraccion ejecutan sin fallas criticas en Windows.
- [ ] Forma piloto Wave 1 definida y aprobada.
- [ ] Matriz QA base definida para equivalencia funcional.
- [ ] Nuevo Sprint 1 planeado para desarrollo real (no mock).

## Fuera de Alcance

| Item | Razon |
|------|-------|
| Migracion completa de forma compleja | Este sprint es de reset y preparacion |
| Integracion productiva de Jasper/XLSX | Requiere definiciones operativas posteriores |
| CI/CD multi-entorno completo | Se toma despues del primer flujo funcional estable |

## Prompt de Ejecucion

Read PROJECT_BRIEF.md, then read docs/sprint-0/plan.md. Execute Sprint 0 reset.

First: git pull origin develop && git checkout -b feature/sprint-0-restart

Close GitHub Issues in commits: "fix: description (Fixes #NN)"
Update docs/sprint-0/progress.md after each phase.
When done, push and create PR: git push origin feature/sprint-0-restart
Follow Sections 12-14 of PROJECT_BRIEF.md.
