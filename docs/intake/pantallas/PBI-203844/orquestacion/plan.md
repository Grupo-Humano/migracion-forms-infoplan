# Sprint Planning Final - PBI-203844 (reemb_pago)

## Metadatos

- Owner: Remy
- Estado: FINAL LISTO PARA INICIAR
- Fecha de cierre de planning: 2026-06-16
- Ventana objetivo de ejecucion: 2026-06-17 a 2026-07-03

## Objetivo del sprint

Ejecutar la pantalla `reemb_pago` con enfoque de reingenieria controlada (no migracion literal 1:1), con evidencia funcional reproducible, contrato de datos estable y gobierno estricto ORDS.

## Insumos validados para inicio

- `descripcion-criterios.md`
- `reemb_pago_fmb.xml`
- `Levantamiento de Logica  -  reemb_pago.txt`
- `Registro de Reembolso reemb_pago-es-ES.vtt`
- `foto_pantalla_1.png`
- `foto_pantalla_2.png`

## Equipo y responsabilidad principal

- Remy (Producer): gobernanza, gates, handoff, riesgos
- Kira (Product): alcance funcional por etapas y criterios
- Nova (Frontend): flujo UI principal y estados
- Sage (Backend): contrato ORDS y matriz de reutilizacion
- Ivy (QA): plan de prueba por fases y sign-off
- Milo (Visual): consistencia visual y accesibilidad
- Dash (DevOps): estabilidad de entorno y checks minimos

## Alcance final de fase 1 (MVP operativo)

1. Busqueda y seleccion de afiliado con datos base.
2. Seccion Datos Reembolso (estado inicial, fechas, via entrada, medio de pago).
3. Seccion Solicitud de Servicios con cobertura minima operativa.
4. Guardado inicial y recarga consistente del caso.
5. Trazabilidad de validaciones criticas visibles para usuario.

## No alcance fase 1

1. Exgratia end-to-end.
2. Automatizaciones avanzadas de cartas/notificaciones.
3. Integraciones externas no disponibles en ambiente de prueba.

## Estimacion consensuada final

- Discovery + extraccion de reglas: 3 a 4 dias
- Contrato ORDS + checkpoint 2.5: 2 a 3 dias
- Implementacion UI principal: 4 a 5 dias
- QA por fases + recertificacion: 2 a 3 dias
- Ajustes y cierre documental: 1 a 2 dias

Rango total: 12 a 17 dias efectivos.

## Plan por fases y gates

### Fase A - Discovery consolidado (Gate 1)

- Responsables: Kira + Sage + Remy
- Entrada: insumos validados
- Salida requerida:
  - inventario de reglas funcionales priorizadas,
  - mapa de secciones UI (tabs y bloques),
  - supuestos y dudas abiertas.
- Criterio de paso: 100% reglas criticas documentadas sin ambiguedad alta.

### Fase B - Contrato de datos y ORDS (Gate 2 + 2.5)

- Responsables: Sage + Nova + Ivy
- Entrada: salida de Fase A
- Salida requerida:
  - payload/response versionado para flujo principal,
  - matriz ORDS REUTILIZABLE | ADAPTABLE | NUEVO,
  - resultado de checkpoint humano 2.5.
- Criterio de paso: Nova e Ivy aprueban contrato y testabilidad.

### Fase C - Construccion UI MVP (Gate 3 parcial)

- Responsables: Nova + Milo
- Entrada: contrato ORDS aprobado
- Salida requerida:
  - flujo completo de afiliado -> datos reembolso -> solicitud,
  - estados de carga/error/vacio,
  - consistencia visual minima y accesibilidad base.
- Criterio de paso: flujo principal usable en localhost:3000 sin bloqueantes P0/P1.

### Fase D - QA y cierre (Gate 4)

- Responsables: Ivy + Remy + equipo
- Entrada: MVP funcional desplegable local
- Salida requerida:
  - evidencia funcional y tecnica reproducible,
  - acta `docs/qa/sprint-4-signoff.md`,
  - cierre en `orquestacion/done.md` y sincronizacion de `PROJECT_BRIEF.md`.
- Criterio de cierre: GO formal o NO_GO documentado con plan de remediacion.

## Gobierno ORDS (obligatorio)

1. No se crea endpoint nuevo sin aprobacion explicita del CEO.
2. Antes de proponer endpoint nuevo, se debe demostrar por que no aplica reutilizacion/adaptacion.
3. Toda propuesta nueva usa este formato:
   - Endpoint nuevo propuesto: XXX
   - Modulo sugerido: YYY
   - Justificacion tecnica: ZZZ
   - Impacto: seguridad/versionado/performance
   - Decision requerida: APROBAR o RECHAZAR

## Definicion de listo para iniciar (Start Checklist)

- [x] Pantalla objetivo definida: PBI-203844 `reemb_pago`
- [x] Insumos funcionales y visuales en scope
- [x] Equipo y responsabilidades confirmadas
- [x] Estimacion final acordada (12-17 dias)
- [x] Regla ORDS de aprobacion explicita establecida
- [ ] Branch de ejecucion abierta (`feature/sprint-4-pbi-203844`)
- [ ] Primer update operativo en `orquestacion/progress.md` (Dia 1)
