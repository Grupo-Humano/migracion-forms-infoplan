# Orquestacion PBI -> ORDS -> React

## Objetivo
Estandarizar la ejecucion de migraciones Oracle Forms a partir de un PBI de Azure DevOps, con trazabilidad tecnica y funcional.

## Modo Reinicio (obligatorio)
Cuando se reinicia el proyecto o inicia una nueva migracion por plantilla, el equipo debe detenerse y pedir primero el paquete de intake. No se ejecuta analisis tecnico ni diseno ORDS hasta completar este gate.

Fuente central de insumos (obligatoria):
- `docs/intake/solicitudes-pantallas.md`
- `docs/templates/plantilla-intake-migracion.md`

Solicitud obligatoria al CEO para "migrar plantilla X":
1. La plantilla objetivo (nombre funcional y artefacto esperado).
2. Los insumos de descripcion y criterios de aceptacion (PBI, historia, documento funcional).
3. Recursos de apoyo (pruebas, transcripcion funcional, videos, evidencias).
4. Estimacion de esfuerzo y estimacion de sprint por formulario.
5. Estimacion de pantallas nuevas o cambios de pantalla.
6. Cualquier contexto adicional relevante (dependencias, restricciones, riesgos, fechas).

## Modo Continuidad (incremental)
Si la plantilla ya fue iniciada y existe un intake base aprobado, el equipo NO debe pedir todo de nuevo.

En continuidad se solicita solo:
1. Cambios respecto al baseline (descripcion/criterios).
2. Nuevas evidencias (pruebas, transcripcion, videos).
3. Cambios de estimacion (esfuerzo, sprint, pantallas).
4. Nuevos riesgos o restricciones.

Salida en continuidad:
- `GO_CONTINUIDAD_DELTA` o
- `NO_GO_FALTAN_DELTAS_CRITICOS`.

## Entradas Minimas
- PBI_URL
- REPO_BASE_PATH
- GUIDELINES_PATH
- VIDEO_FOLDER

## Gate de Intake por Plantilla (GO/NO-GO)
No iniciar Fase 1 si falta algun item del paquete obligatorio.

Checklist:
- [ ] Plantilla objetivo confirmada.
- [ ] Descripcion y criterios de aceptacion recibidos.
- [ ] Recursos funcionales y de prueba disponibles.
- [ ] Estimacion de esfuerzo y sprint por formulario acordada.
- [ ] Estimacion de pantallas nuevas/cambios recibida.
- [ ] Contexto adicional relevante documentado.

Salida del gate:
- `GO_INTAKE_COMPLETO` o
- `NO_GO_FALTAN_INSUMOS` + lista de faltantes.

Regla anti-friccion:
- El gate completo aplica la primera vez por plantilla.
- En iteraciones siguientes, usar modo continuidad y pedir unicamente deltas.

## Fases Operativas

### Fase 1: Lectura del PBI
1. Leer descripcion completa.
2. Leer criterios de aceptacion.
3. Leer adjuntos y enlaces relacionados.
4. Extraer nombre de la forma desde el ultimo segmento del titulo separado por '|'.
5. Confirmar que la plantilla solicitada por CEO coincide con el PBI analizado.

Salida:
- contexto_pbi
- nombre_forma
- url_video

### Fase 2: Analisis del video funcional
1. Intentar usar transcripcion nativa.
2. Si no existe, extraer flujo por analisis de frames.
3. Documentar flujo funcional, reglas y excepciones.

Salida:
- flujo_funcional
- reglas_negocio

### Fase 3: Analisis de Oracle Form
1. Localizar .fmb/.fmx/.xml de la forma.
2. Extraer bloques, items, canvas, LOVs, queries, triggers y program units.
3. Identificar llamadas a paquetes PL/SQL externos.
4. Calificar complejidad: BAJA, MEDIA, ALTA, MUY_ALTA.

Salida:
- analisis_forma
- operaciones_datos
- complejidad

### Fase 4: Evaluacion de ORDS existente (con checkpoint)
1. Listar modulos ORDS existentes.
2. Comparar operaciones del formulario con endpoints actuales.
3. Clasificar cada operacion:
   - REUTILIZABLE
   - ADAPTABLE
   - NUEVO
4. Publicar tabla resumen y detener.

Tabla obligatoria:
| Operacion | Tabla | Metodo | ORDS existente | Clasificacion | Observaciones |

Checkpoint humano obligatorio:
- Se requiere aprobacion explicita antes de pasar a Fase 5.

### Fase 5: Diseno ORDS
1. Diseñar solo operaciones NUEVO/ADAPTABLE.
2. Definir ruta, metodo, parametros, payload y respuesta.
3. Documentar SQL o PL/SQL asociado.

### Fase 6: Planificacion en Azure DevOps
1. Definir cantidad de sprints por complejidad.
2. Inferir tasks desde la logica real de la forma.
3. Crear sprints/tasks vinculados al PBI.

### Fase 7: Especificacion React/Next
1. Mapear bloques Oracle a componentes React.
2. Mapear triggers de validacion a hooks/reglas frontend.
3. Definir estructura de paginas/componentes/servicios.
4. Publicar especificacion y vincular al PBI.

### Fase 8: Validacion de Equivalencia de Pantalla
1. Ejecutar matriz QA en docs/qa/screen-migration-equivalence-checklist.md.
2. Validar endpoints ORDS reales (no localhost) y registrar evidencia HTTP.
3. Comparar resultado esperado vs actual por caso.
4. Emitir recomendacion GO/NO-GO para la pantalla.

Salida:
- evidencia_equivalencia
- decision_go_no_go

### Fase 9: Retroalimentacion y Mejora de Reglas
1. Registrar lecciones aprendidas al cierre de cada sprint.
2. Actualizar este flujo solo con mejoras comprobadas por evidencia.
3. Versionar cambios de regla en commit dedicado con motivo.
4. Propagar cambios al PROJECT_BRIEF (secciones 7, 8, 12, 13, 14) y al progress del sprint.

## Reglas
- Artefactos en espanol.
- No inventar reglas no presentes en codigo/video.
- Si hay contradiccion entre video y forma, documentar ambas y marcar pendiente funcional.
- Confirmar disponibilidad de MCP antes de cada fase.
- No cerrar migracion de pantalla sin evidencia en matriz de equivalencia.
- Toda mejora de proceso debe dejar traza en docs/sprint-N/progress.md.
- Reuse-first en ORDS: reutilizar modulo existente con sentido funcional y de dominio; crear nuevo solo con justificacion escrita.
- Sin intake completo no se ejecuta migracion de plantilla.

## Fuentes
- prompts/awsome_prompt.md
- prompts/agent_orchestration_prompt.html
