# Salida Sprint 5 - Plan QA temprano

PBI: 203844
Pantalla: reemb_pago
Owner QA: Ivy
Estado: ACTIVO
Fecha: 2026-06-16

## Objetivo QA de arranque

Asegurar que Sprint 6 inicie con casos criticos definidos, trazabilidad por evidencia y gate de calidad claro para evitar hallazgos tardios.

## Suite critica inicial

1. QA-01 Busqueda afiliado por documento/carnet/numero.
2. QA-02 Precarga de planes, dependientes, contactos y limites.
3. QA-03 Validacion de fecha servicio sin futuros.
4. QA-04 Validacion de fecha recepcion dentro de ventana permitida.
5. QA-05 Guardado con minimo valido (1 diagnostico, 1 cobertura).
6. QA-06 Cambio de medio de pago exige motivo.
7. QA-07 Fuera de cobertura exige descripcion y monto no cubierto.
8. QA-08 Resumen muestra numero solicitud, estado y montos.

## Evidencia minima por caso

1. Captura de pantalla antes y despues.
2. Payload request/response del endpoint relevante.
3. Resultado esperado vs resultado obtenido.
4. Severidad asignada en caso de falla.

## Politica de severidad

- Sev 1: impide operacion base del flujo.
- Sev 2: afecta regla critica de negocio o integridad de montos.
- Sev 3: afecta usabilidad sin bloquear operacion.
- Sev 4: cosmetico.

## Gate de salida Sprint 6

1. Sin Sev 1 abiertos.
2. Sin Sev 2 sin plan y fecha aprobados.
3. Trazabilidad completa de contratos v1.
4. Evidencia reproducible publicada en docs del sprint.

## Riesgos QA activos

1. Regla legacy ambigua para algunas acciones por estatus.
2. Dependencias ORDS con comportamiento distinto por ambiente.
3. Datos de prueba no representativos para casos de excepcion.

## Mitigaciones

1. Revisiones semanales con Product y Backend.
2. Casos de prueba por capas: happy path, bordes y regresion.
3. Registro de dudas y decisiones funcionales en progress del sprint.

## Decision

QA habilita inicio de construccion Sprint 6 con control por gates y evidencia temprana.
