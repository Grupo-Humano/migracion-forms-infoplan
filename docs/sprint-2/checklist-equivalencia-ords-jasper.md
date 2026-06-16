# Checklist de Equivalencia ORDS vs Jasper (rep_aprobarechazo)

Fecha: 2026-06-15
Owner: Ivy + Sage
Estado: EN EJECUCION

## Objetivo

Validar campo por campo que el payload de ORDS real se alinea con la data observada en Jasper (XLS) para la misma ventana de fechas.

## Ventana de control

- Desde: 2026-01-01
- Hasta: 2026-02-17
- Fuente Jasper analizada: report6.xls
- Conteo Jasper observado: 3913

## Reglas de comparacion

1. Comparar por llave principal `id_transaccion`.
2. Verificar igualdad exacta en campos core (no solo existencia).
3. En campos extendidos, aceptar `NULL` solo cuando el origen real no tenga dato.
4. Registrar diferencias por tipo: `faltante_ords`, `faltante_jasper`, `valor_distinto`, `formato_distinto`.

## Matriz de campos

| Campo | Prioridad | Fuente ORDS | Fuente Jasper | Estado | Evidencia |
|---|---|---|---|---|---|
| id_transaccion | Critica | transacciones/search | XLS | EN CURSO | IDs muestreados ya coinciden |
| fec_tra | Critica | transacciones/search | XLS | EN CURSO | Pendiente corrida comparativa final |
| cliente | Critica | transacciones/search | XLS | EN CURSO | Pendiente corrida comparativa final |
| compania | Alta | transacciones/search | XLS | EN CURSO | Pendiente corrida comparativa final |
| ramo | Alta | transacciones/search | XLS | EN CURSO | Pendiente corrida comparativa final |
| secuencial | Alta | transacciones/search | XLS | EN CURSO | Pendiente corrida comparativa final |
| monto | Critica | transacciones/search | XLS | EN CURSO | Pendiente corrida comparativa final |
| estado | Critica | transacciones/search | XLS | EN CURSO | Jasper reporta R/C en ventana |
| codigo_rechazo | Alta | transacciones/search | XLS | EN CURSO | Pendiente corrida comparativa final |
| descripcion_rechazo | Alta | transacciones/search | XLS | EN CURSO | Pendiente corrida comparativa final |
| num_autoriza | Alta | transacciones/search | XLS | EN CURSO | Pendiente corrida comparativa final |
| cliente_poliza | Alta | transacciones/search | XLS | EN CURSO | Pendiente corrida comparativa final |
| estatus_poliza | Alta | transacciones/search | XLS | EN CURSO | Pendiente corrida comparativa final |
| frecuencia_pago | Alta | transacciones/search | XLS | EN CURSO | Pendiente corrida comparativa final |
| tipo_documento | Extendida | transacciones/search | Jasper/DB | EN CURSO | Mapeo real aplicado (CEDULA/RNC) |
| num_documento | Extendida | transacciones/search | Jasper/DB | EN CURSO | Mapeo real aplicado (ced_act/rnc) |
| nombre_director | Extendida | transacciones/search | Jasper/DB | EN CURSO | Mapeo real aplicado desde int_ger_dir01_v |
| grupo | Extendida | transacciones/search | Jasper/DB | EN CURSO | Mapeo real aplicado desde cliente.sec_eco |
| telefono_1 | Extendida | transacciones/search | Jasper/DB | EN CURSO | Estrategia por cliente.codigo confirmada |
| telefono_2 | Extendida | transacciones/search | Jasper/DB | EN CURSO | Estrategia por cliente.codigo confirmada |
| telefono_3 | Extendida | transacciones/search | Jasper/DB | EN CURSO | Estrategia por cliente.codigo confirmada |

## Evidencia SQL ya confirmada

- `phones_by_codigo_match`: 44726
- `phones_by_proprietario_match`: 208
- Distribucion `sec_eco` (clientes en ventana):
  - P: 15674
  - N: 2172
  - M: 1999
  - C: 460
  - vacio: 299

### Cobertura de campos extendidos (DB real, ventana 2026-01-01..2026-02-17)

- `total_rows`: 39284
- `con_num_documento`: 34508
- `con_grupo`: 38825
- `con_telefono_1`: 32424
- `con_telefono_2`: 12302
- `con_telefono_3`: 0

### Hallazgo de volumen (a resolver antes de GO total)

- Conteo XLS analizado: 3913
- Conteo DB base (estado R/C): 39283
- Diferencia significativa: sugiere que Jasper aplica filtros adicionales no replicados aun en ORDS.
- Accion requerida: extraer y aplicar criterio exacto Jasper para reducir el universo a la misma regla del reporte.

## Criterio de cierre

- GO parcial (flujo principal): cuando campos core coincidan >= 99% en muestra acordada.
- GO total (equivalencia): cuando campos core coincidan >= 99.5% y campos extendidos tengan mapeo validado con evidencia reproducible.

## Proxima ejecucion (orden recomendado)

1. Republicar handlers ORDS con los SQL actualizados.
2. Ejecutar `POST /transacciones/search` en la ventana 2026-01-01 a 2026-02-17.
3. Exportar muestra de ORDS y comparar contra XLS por `id_transaccion`.
4. Registrar tabla de diferencias y decision GO/NO-GO en este mismo archivo.
