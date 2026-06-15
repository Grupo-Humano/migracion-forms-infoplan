# Plan de Accion Anti-Ahogo (Ejecucion Inmediata)

Estado: ACTIVO  
Inicio: 2026-06-15  
Coordinacion: Remy

## Objetivo

Reducir sobrecarga operativa y retrabajo para escalar de forma sostenible a 100+ pantallas.

## Regla base

No se inicia una pantalla nueva si la pantalla actual no cumple gate de avance.

## Acciones implementadas (inmediatas)

| ID | Accion | Owner | Fecha limite | Resultado esperado |
|---|---|---|---|---|
| A1 | Activar intake inicial/delta-only como gate obligatorio | Remy | 2026-06-15 | Menos reproceso por requerimientos incompletos |
| A2 | Usar tarjeta estandar por pantalla (`docs/templates/tarjeta-pantalla.md`) | Nova + Sage + Ivy | 2026-06-16 | Trazabilidad unica por pantalla |
| A3 | Aplicar limites WIP por rol | Remy | 2026-06-15 | Menor multitarea y mayor throughput |
| A4 | Cerrar matriz endpoint+QA antes de abrir nueva pantalla | Sage + Ivy | 2026-06-17 | Menos deuda de cierre |
| A5 | Publicar sign-off final y done por sprint | Ivy + Remy | 2026-06-17 | Cierre formal sin ambiguedades |
| A6 | Reporte semanal de metricas (lead time, retrabajo, severidad) | Dash + Remy | 2026-06-21 | Control de eficiencia continuo |
| A7 | Forzar estructura PBI madre (`entradas/`, `salidas/`, `orquestacion/`) y prohibir artefactos fuera del arbol del PBI | Remy | 2026-06-15 | Orden operativo y trazabilidad por PBI sin dispersion |

## Limites WIP (obligatorios)

- Nova: maximo 2 pantallas activas en frontend.
- Sage: maximo 2 pantallas activas con cambios ORDS/SQL.
- Ivy: maximo 3 pantallas en validacion simultanea.
- Dash: maximo 2 frentes operativos abiertos (entorno/seguridad/despliegue).
- Remy: no aprobar arranque de pantalla si cualquier owner supera su WIP.

## Gates de avance por pantalla

1. Gate 1 (Inicio): `GO_INTAKE_COMPLETO` o `GO_CONTINUIDAD_DELTA`.
2. Gate 2 (Construccion): contratos ORDS definidos + UI mapeada.
3. Gate 3 (Validacion): smoke endpoint + QA equivalencia ejecutados.
4. Gate 4 (Cierre): sign-off + done publicados.

## Criterios de exito (2 semanas)

- >= 80% pantallas activas con tarjeta completa.
- <= 20% tareas reabiertas por falta de insumos.
- 100% de pantallas cerradas con evidencia endpoint+QA.
- 100% de sprints cerrados con `done.md` y sign-off.

## Bloqueo automatico

Se bloquea arranque de nueva pantalla si falta alguno:
1. Tarjeta de pantalla actualizada.
2. Owner y fecha por bloqueo.
3. Estado de gate explicitado.
4. Folder madre del PBI creado con `entradas/`, `salidas/`, `orquestacion/`.
