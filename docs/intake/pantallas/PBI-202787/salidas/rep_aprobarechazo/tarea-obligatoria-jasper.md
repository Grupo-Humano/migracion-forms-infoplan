# Tarea Obligatoria - Habilitar Jasper

Fecha: 2026-06-15
PBI: PBI-202787
Pantalla: rep_aprobarechazo
Owner propuesto: Sage (Backend)
Estado: ABIERTA
Prioridad: ALTA

## Contexto
En ejecucion real se obtuvo 404 en ambos endpoints Jasper evaluados:
- /exportaciones/jasper
- /export/jasper

La pantalla tiene regla Jasper-first, por lo que sin Jasper no se puede cerrar equivalencia completa.

## Alcance minimo
1. Publicar endpoint Jasper operativo en modulo canónico de la pantalla.
2. Definir contrato request/response estable para frontend.
3. Adjuntar evidencia HTTP 200 en QA (caso rango valido de fechas).
4. Confirmar archivo generado y metadatos de export.

## Criterios de aceptacion
- [ ] Endpoint Jasper responde 200 en ambiente real validado.
- [ ] Frontend ejecuta export Jasper sin 404.
- [ ] Se mantiene trazabilidad en docs/qa y done.md.

## Fecha objetivo
2026-06-18
