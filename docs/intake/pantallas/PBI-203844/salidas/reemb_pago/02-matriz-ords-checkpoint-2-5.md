# Salida Sprint 5 - Matriz ORDS Checkpoint 2.5

PBI: 203844
Pantalla: reemb_pago
Owner: Sage
Revisor: Remy
Estado: VALIDADO PARA ARRANQUE SPRINT 6
Fecha: 2026-06-16

## Criterio de clasificacion

- REUTILIZABLE: procedimiento/endpoint cubre la necesidad principal sin cambio estructural.
- ADAPTABLE: cubre parcialmente y requiere ajuste compatible.
- NUEVO: no hay cobertura suficiente; requiere propuesta formal y aprobacion CEO.

## Matriz funcional-tecnica

| Necesidad | Procedimiento candidato | Clasificacion | Nota |
|---|---|---|---|
| Datos afiliado base | P_GET_DATOS_ASEGURADO | REUTILIZABLE | Cubre busqueda por documento/carnet |
| Telefonos afiliado | P_GET_TELEFONOS_ASEGURADO | REUTILIZABLE | Incluye preferencia |
| Correos afiliado | P_GET_CORREOS_ASEGURADO | REUTILIZABLE | Incluye preferencia |
| Planes afiliado | P_GET_PLANES_ASEGURADO | REUTILIZABLE | Base para selector de plan |
| Plan dental | P_GET_PLANES_DENTALES | ADAPTABLE | Validar payload simplificado para UI nueva |
| Dependientes | P_GET_DEPENDIENTES | REUTILIZABLE | Requiere mapping de campos UI |
| Endosos locales | P_GET_ENDOSOS_LOCAL | REUTILIZABLE | Tabla informativa |
| Endosos internacionales | P_GET_ENDOSOS_INT | REUTILIZABLE | Tabla informativa |
| Limites y deducibles | P_GET_LIMITES_ASEGURADO, P_GET_LIMITE_MEDICAMENTO | ADAPTABLE | Unificar respuesta para widget de limites |
| Cuentas bancarias | P_GET_CUENTAS_BANCARIAS, P_GET_CUENTA_BANCARIA | REUTILIZABLE | Para transferencia |
| Crear cuenta bancaria | P_CREA_CUENTA_BANCARIA | ADAPTABLE | Validar reglas de propietario dependiente |
| Alta prestador medico/centro | P_CREA_MEDICO, P_CREA_PSS | ADAPTABLE | Mantener solo campos MVP |
| Detalle cobertura | P_GET_DETALLE_COBERTURA | REUTILIZABLE | Modal de detalle |
| CRUD solicitud servicio | P_CRUD_SOLICITUD_SERVICIO | ADAPTABLE | Definir contrato JSON versionado |
| CRUD cobertura solicitada | P_CRUD_COBERTURA_SOLICITADA | ADAPTABLE | Validar reglas de rechazo y auditoria |
| Excepciones de negocio | P_CREA_EXCEPCION_NEGOCIO, P_CREA_COBRO_INDEBIDO, P_CREA_NEGOCIACION_PRESTADOR | ADAPTABLE | Mantener acciones por permisos |
| Resumen reclamos | P_GET_RESUMEN_RECLAMOS | REUTILIZABLE | Tabla resumen y montos |
| Solicitud de pago | P_GET_SOLICITUD_PAGO, P_CRUD_SOLICITUD_PAGO | ADAPTABLE | Integrar para fase posterior |

## Resultado checkpoint 2.5

- REUTILIZABLE: 10 capacidades
- ADAPTABLE: 8 capacidades
- NUEVO: 0 confirmado en Sprint 5

## Validacion XML y evidencia con scripts

Lectura validada del XML base:

- Archivo leido: `docs/intake/pantallas/PBI-203844/entradas/reemb_pago/reemb_pago_fmb.xml`
- Evidencia de bloques: `evidencia_xml_blocks.txt`
- Evidencia de Program Units: `evidencia_xml_program_units.txt`

Extraccion automatizada ejecutada desde `scripts/`:

1. `extract_program_units.py`
	- Resultado: `program_units_all.json`, `program_units_all.sql`
	- Conteo confirmado: 86 Program Units.
2. `extract_lovs_records.py`
	- Resultado: `reemb_pago_fmb_lovs_and_records.json`, CSV/JSON auxiliares.
	- Conteo confirmado: 22 LOVs y 22 Record Groups.
3. `extract_block_triggers.py`
	- Bloque analizado: `SOLICITUD_SERVICIO`
	- Resultado: `triggers_SOLICITUD_SERVICIO.txt`

Conclusion de validacion:

- Si, se leyo y se proceso tecnicamente el XML de la forma.
- La matriz ORDS de este documento esta sustentada por evidencia del XML y no solo por transcripcion funcional.

## Riesgos tecnicos

1. Operaciones CRUD con JSON heterogeneo requieren contrato estricto para evitar regresiones.
2. Procedimientos con logica historica de auditoria pueden producir efectos secundarios si no se encapsulan.
3. Varios procedimientos dependen de paquetes y tablas temporales con comportamiento no obvio.

## Gobierno ORDS aplicado

1. Se prioriza reuse-first.
2. No se autoriza endpoint nuevo en Sprint 5.
3. Si en Sprint 6 aparece hueco real, se usa solicitud formal al CEO.

## Formato de solicitud en caso de endpoint nuevo

- Endpoint nuevo propuesto: <ruta>
- Modulo sugerido: <modulo>
- Justificacion tecnica: <motivo>
- Impacto: <seguridad/versionado/performance>
- Decision requerida: APROBAR o RECHAZAR

## Decision

GO para Sprint 6 con estrategia reuse-first y adaptaciones controladas.
