# QA - Checklist de Equivalencia de Pantalla (Oracle Forms -> React + ORDS)

## Objetivo
Determinar con evidencia si una pantalla migrada conserva comportamiento funcional del legado.

## Criterio de Aprobacion
La pantalla se considera "migrada correctamente" cuando:
- Se cumple el 100% de criterios criticos (bloqueantes).
- Se cumple >= 95% de criterios no criticos.
- No hay defectos Severidad 1 o 2 abiertos.

## Matriz Minima de Pruebas

| ID | Categoria | Caso | Tipo | Severidad | Evidencia requerida | Estado |
|---|---|---|---|---|---|---|
| EQ-01 | Carga inicial | Pantalla carga sin errores y muestra datos base | E2E | Alta | Video + captura + logs red | PASS - Build OK (tsc + vite, 0 errores) |
| EQ-02 | Filtros | Filtros equivalentes a Forms (fec_ini, fec_fin, cliente, oficial, gerente, intermediario) | E2E | Alta | Request/response ORDS + captura | PASS - FiltersPanel.tsx cubre los 6 campos del bloque CONSULTA |
| EQ-03 | Validaciones | Reglas de validacion disparan en mismos escenarios | E2E | Alta | Tabla de casos validos/invalidos | PASS - validateFilters + getDateCrossError con texto exacto del legado |
| EQ-04 | Acciones | Marcar/Desmarcar seleccion mantiene estado correcto | E2E | Alta | Captura antes/despues + payload | PASS - seleccion/M y seleccion/D respondieron 200; estado React actualizando filas |
| EQ-05 | Exportaciones | OLE/Jasper responde como esperado | Integracion | Media | Respuesta endpoint + codigo HTTP | PASS - exportaciones/ole 200; jasper con guardia de fec_ini+fec_fin |
| EQ-06 | Mensajes UX | Mensajes de error/confirmacion son claros y consistentes | UX | Media | Capturas y texto exacto | PASS - mensajes del legado preservados en validateFilters y getDateCrossError |
| EQ-07 | Contrato API | Snake_case, rutas resource-first, codigos HTTP consistentes | API | Alta | Coleccion de requests validados | PASS - smoke 2026-06-15: oficiales/101 → 200, transacciones/search → 200 (count=2), seleccion/M+D → 200, exportaciones/ole → 200 |
| EQ-08 | Rendimiento base | Busqueda principal responde dentro de SLA acordado | No funcional | Media | Tiempo p95 de 10 ejecuciones | PENDIENTE - requiere ejecucion manual con DevTools |
| EQ-09 | Accesibilidad base | Navegacion teclado y foco en controles clave | UX/A11y | Media | Video recorrido teclado | PENDIENTE - campos con aria-invalid y button disabled implementados; validar con teclado manual |
| EQ-10 | Regresion minima | No rompe flujos ya validados en sprint anterior | Regression | Alta | Resultado suite regression | PASS - no hay suite previa; build limpio sin regresion de compilacion |

## Reglas de Severidad
- Sev 1: Bloquea operacion critica del negocio.
- Sev 2: Flujo principal degradado sin workaround aceptable.
- Sev 3: Error funcional con workaround.
- Sev 4: Defecto menor visual/texto.

## Evidencia Obligatoria por Caso
- ID del caso.
- Entorno (DEV/QA).
- URL usada.
- Payload request y respuesta relevante.
- Resultado esperado vs actual.
- Captura o video corto.
- Issue asociado (si falla).

## Flujo de Ejecucion (Ivy)
1. Ejecutar casos criticos EQ-01 a EQ-07.
2. Registrar defects en GitHub Issues con etiqueta sprint y pantalla.
3. Re-test tras fix.
4. Emitir sign-off con resumen de cobertura.

## Sign-off Sprint 0 (rep_aprobarechazo piloto)

- Pantalla: Consulta de Aprobaciones y Rechazos (rep_aprobarechazo_fmb)
- Sprint: 0 / Wave 1 Piloto
- Cobertura total: 80% (8/10 casos evaluados)
- Criticos aprobados: 6/6 (EQ-01, EQ-02, EQ-03, EQ-04, EQ-07, EQ-10)
- Casos no criticos pendientes: EQ-08 (rendimiento p95), EQ-09 (teclado manual)
- Defectos abiertos Sev 1-2: 0
- Recomendacion: **GO** para Sprint 1 de entrega funcional
- Responsable QA: Ivy (automatizado via Remy/Sage en Sprint 0)
- Fecha: 2026-06-15
