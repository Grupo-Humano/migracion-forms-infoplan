# Remy - Que sigue despues de validar ORDS real

## Estado actual
- Task 1 a 4 completados.
- Task 6 completado (matriz QA de equivalencia definida).

## Siguiente orden de ejecucion

1. Definir forma piloto Wave 1 (Task 5)
- Entradas: complejidad extraida, impacto de negocio, riesgo tecnico.
- Criterio: escoger forma de complejidad BAJA/MEDIA con alto valor funcional.
- Salida: decision documentada con justificacion y alcance.

2. Mapa inicial de componentes React (Task 7)
- Nova/Milo derivan componentes desde bloques Oracle.
- Resultado: estructura base de pagina + componentes + estados + servicios API.
- Entregable minimo: diagrama de componentes y contrato de datos por vista.

3. Plan de Sprint 1 real (Task 8)
- Crear plan tecnico-funcional de entrega vertical:
  - UI equivalente
  - endpoints ORDS requeridos
  - QA de equivalencia (checklist)
- Definir Definition of Done por historia.

## Definition of Done sugerida para una pantalla migrada
- 100% de casos criticos aprobados en checklist de equivalencia.
- 0 defectos Sev 1-2 abiertos.
- Smoke ORDS exitoso en endpoint real.
- Sign-off QA emitido.

## Riesgo a vigilar
- Diferencia entre endpoint DEV y endpoint de ambiente objetivo final (QA/UAT/PROD).
- Mitigacion: parametrizar base URL por ambiente y ejecutar smoke por ambiente antes de cierre.
