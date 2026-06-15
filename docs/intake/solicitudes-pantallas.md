# Registro Unico de Solicitudes de Pantallas

Estado: ACTIVO
Owner: Remy

## Instruccion

Registrar aqui cada nueva pantalla o delta antes de abrir trabajo tecnico.

## Tabla operativa

| ID | Fecha | PBI | Pantalla | Modo | Estado intake | Estado checkpoint ORDS | Criterios recibidos | Recursos recibidos | Estimacion (esfuerzo/sprint/pantallas) | Owner | Folder madre | Entradas | Salidas | Proximo paso |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| INT-001 | 2026-06-15 | PBI-202787 | rep_aprobarechazo | INICIAL | GO_INTAKE_COMPLETO | EN_ESPERA_APROBACION_HUMANA | SI | SI | SI | Remy | docs/intake/pantallas/PBI-202787/ | docs/intake/pantallas/PBI-202787/entradas/rep_aprobarechazo/ | docs/intake/pantallas/PBI-202787/salidas/rep_aprobarechazo/ | Presentar analisis de reutilizacion ORDS y esperar aprobacion humana |

## Valores permitidos

- Modo: `INICIAL` | `CONTINUIDAD_DELTA`
- Estado intake: `GO_INTAKE_COMPLETO` | `NO_GO_FALTAN_INSUMOS` | `GO_CONTINUIDAD_DELTA` | `NO_GO_FALTAN_DELTAS_CRITICOS`
- Estado checkpoint ORDS: `REUSE_IN_EXISTING_MODULE` | `CREATE_NEW_MODULE_WITH_JUSTIFICATION` | `EN_ESPERA_APROBACION_HUMANA`

## Regla anti-desorden

No abrir branch/tarea de pantalla si no existe fila en este registro.
