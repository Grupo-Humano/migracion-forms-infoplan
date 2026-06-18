# Sprint 6 Plan: PBI-203844 reemb_pago - Construccion MVP

Estado: ACTIVO
Owner: Remy
Fecha de inicio: 2026-06-17
Branch objetivo: feature/sprint-6-pbi-203844-mvp

## Objetivo del sprint

Construir el MVP operativo de reemb_pago sobre contrato v1 y matriz ORDS validada, con entregas incrementales y evidencia QA desde el primer bloque funcional.

## Alcance Sprint 6

1. Flujo UI principal por pasos (afiliado -> datos reembolso -> solicitud servicio -> coberturas -> guardado).
2. Integracion de endpoints REUTILIZABLE y ADAPTABLE priorizados en matriz ORDS.
3. Validaciones criticas del negocio en frontend + backend.
4. Evidencia de pruebas por incremento y control de defectos.
5. Handoff tecnico a Sprint 7 (QA integral y estabilizacion).

## No alcance Sprint 6

1. Exgratia end-to-end completo.
2. Cartas con funcionalidades no confirmadas en legacy.
3. Automatizaciones no criticas fuera del flujo MVP.

## Consilium de inicio (equipo)

### Remy (Producer)

- Foco: cero ambiguedad de alcance, prioridad por valor y riesgo.
- Decision: cualquier desviacion de contrato v1 requiere aprobacion explicita.

### Kira (Product)

- Foco: claridad de reglas por estatus y consistencia funcional.
- Decision: cerrar tabla de decisiones de estatus antes del segundo incremento.

### Nova (Frontend)

- Foco: flujo guiado por pasos y estados UX completos (cargando/error/vacio).
- Decision: no cerrar componente sin contrato validado por caso.

### Sage (Backend)

- Foco: adaptacion controlada de CRUD legacy con trazabilidad.
- Decision: reuse-first obligatorio; endpoint nuevo solo con aprobacion CEO.

### Ivy (QA)

- Foco: pruebas tempranas, evidencia reproducible y severidad clara.
- Decision: gate NO_GO si hay Sev 1 o Sev 2 sin plan de mitigacion aprobado.

### Milo (Visual)

- Foco: consistencia visual y accesibilidad base en MVP.
- Decision: revisar estados visuales en cada incremento, no al final.

### Dash (DevOps)

- Foco: estabilidad de entorno y comando de verificacion minimo por fase.
- Decision: checklist tecnico por incremento en progress.

## Tareas del sprint

### T-01 Implementar flujo UI paso 1 y 2
Owner: Nova + Milo

- [ ] Paso 1: busqueda y seleccion de afiliado.
- [ ] Paso 2: captura datos de reembolso y medio de pago.
- [ ] Estados UX completos para ambos pasos.

DoD:
- [ ] Flujo usable en local con datos reales para pasos 1 y 2.

### T-02 Integracion backend para solicitud servicio y coberturas
Owner: Sage + Nova

- [ ] Integrar contrato v1 para solicitud servicio.
- [ ] Integrar cobertura y validaciones minimas.
- [ ] Adaptar respuestas legacy a modelo canonico.

DoD:
- [ ] Operacion crear/actualizar solicitud con respuesta consistente.

### T-03 Reglas criticas y validaciones
Owner: Kira + Sage + Nova

- [ ] Fecha servicio no futura.
- [ ] Al menos 1 diagnostico obligatorio.
- [ ] Motivo obligatorio ante cambio de medio de pago.
- [ ] Reglas fuera de cobertura (monto y descripcion).

DoD:
- [ ] Reglas ejecutadas y validadas con evidencia.

### T-04 QA incremental por bloques
Owner: Ivy

- [ ] Ejecutar casos QA-01 a QA-08 por incremento.
- [ ] Registrar evidencia request/response + capturas.
- [ ] Reporte diario de defectos por severidad.

DoD:
- [ ] Sin Sev 1 abiertos y Sev 2 bajo plan aprobado.

### T-05 Cierre tecnico de sprint
Owner: Remy + equipo

- [ ] Actualizar progress por cada fase.
- [ ] Consolidar riesgos residuales.
- [ ] Preparar handoff a Sprint 7.

DoD:
- [ ] Sprint 6 en estado CERRADO o NO_GO documentado.

## Riesgos y mitigaciones

1. Riesgo: variabilidad de payload legacy.
- Mitigacion: adaptador unico y validaciones de contrato en cada endpoint integrado.

2. Riesgo: regresion en montos de coberturas.
- Mitigacion: dataset de prueba fijo y recertificacion por bloque.

3. Riesgo: deuda documental durante construccion.
- Mitigacion: update obligatorio de progress al cierre de cada incremento.

## Criterios de aceptacion Sprint 6

- [ ] Flujo MVP funcional de punta a punta en local.
- [ ] Integracion de componentes criticos con contrato v1.
- [ ] Evidencia QA incremental publicada.
- [ ] Riesgos residuales y decisiones documentadas.
- [ ] GO formal para iniciar Sprint 7.
