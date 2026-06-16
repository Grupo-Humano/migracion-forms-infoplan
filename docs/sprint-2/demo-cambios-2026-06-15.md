# Demo de Cambios - Sprint 2 (ORDS real + campos extendidos)

Fecha: 2026-06-15
Duracion sugerida: 5 a 7 minutos
Audiencia: CEO + Dev + QA
Objetivo: Mostrar que el flujo principal esta estable en real data y que los campos extendidos ya quedaron mapeados en ORDS.

## 1) Mensaje de apertura (30s)

"En esta demo mostramos 3 cosas: 
1) frontend funcionando contra ORDS real,
2) contrato extendido aplicado en backend,
3) evidencia de datos reales y brecha remanente para equivalencia total con Jasper."

## 2) Lo que cambio (60s)

- Backend ORDS `transacciones/search` ahora expone:
  - `tipo_documento`, `num_documento`, `nombre_director`, `grupo`, `telefono_1`, `telefono_2`, `telefono_3`.
- Frontend tabla ya renderiza esos campos extendidos.
- Se corrigio riesgo de `ORA-01722` en ranking de telefonos por conversion implicita.
- Se consolidaron artefactos de cierre Sprint 2 (progress, done, signoff y checklist de equivalencia).

## 3) Demo tecnica en vivo (3-4 min)

### Paso A - Mostrar SQL del handler ORDS

Abrir y resaltar CTE de telefonos + aliases extendidos:
- backend/ords/scripts/02_handler_transacciones_search.sql

Puntos a narrar:
- Ranking de telefonos por cliente.
- Mapeo documento: CEDULA/RNC segun tipo de cliente.
- Grupo desde `cliente.sec_eco`.

### Paso B - Mostrar frontend consumiendo contrato extendido

Abrir y resaltar columnas:
- frontend/src/components/ResultsTable.tsx

Puntos a narrar:
- Nuevas columnas visibles (documento, director, grupo, telefonos).
- Fallback visual a `-` cuando no hay dato.

### Paso C - Evidencia de datos reales (query corta)

Query recomendada para mostrar registros recientes R/C:

```sql
SELECT id_transaccion,
       TO_CHAR(fec_tra, 'YYYY-MM-DD') AS fec_tra,
       cliente,
       estado,
       codigo_rechazo,
       num_autoriza,
       monto
  FROM transacciones_cobro_recurrente
 WHERE fec_tra >= DATE '2026-01-01'
   AND fec_tra < DATE '2026-02-18'
   AND compania = 30
   AND ramo = 95
   AND estado IN ('R', 'C')
 ORDER BY fec_tra DESC, id_transaccion DESC
 FETCH FIRST 8 ROWS ONLY;
```

Resultado de referencia ya obtenido:
- IDs: 1781808..1781801
- Fecha tope: 2026-02-17
- Estados mixtos R/C

## 4) Evidencia de cobertura extendida (60s)

En ventana 2026-01-01..2026-02-17:
- total_rows: 39284
- con_num_documento: 34508
- con_grupo: 38825
- con_telefono_1: 32424
- con_telefono_2: 12302
- con_telefono_3: 0

Interpretacion para negocio:
- El contrato extendido esta poblado con datos reales.
- `telefono_3` no aparece poblado en esta ventana con la regla actual (esperable segun fuente).

## 5) Riesgo abierto y cierre esperado (60s)

Riesgo pendiente para GO total:
- XLS Jasper analizado: 3913 filas
- Universo DB base R/C: 39283 filas
- Conclusión: Jasper aplica un filtro adicional aun no replicado en ORDS.

Decision recomendada de cierre:
- GO parcial: flujo principal en produccion controlada.
- GO total: despues de replicar filtro Jasper exacto y validar equivalencia por `id_transaccion`.

## 6) Artefactos de soporte para mostrar en pantalla

- docs/sprint-2/progress.md
- docs/sprint-2/done.md
- docs/qa/sprint-2-deployment-signoff.md
- docs/sprint-2/checklist-equivalencia-ords-jasper.md
- docs/sprint-2/coordination/ADELANTE-2026-06-15.md

## 7) Cierre de demo (20s)

"El sistema ya opera en datos reales para el flujo principal y los campos extendidos ya viajan end-to-end. El unico gap para equivalencia total con Jasper es replicar su criterio de seleccion exacto."