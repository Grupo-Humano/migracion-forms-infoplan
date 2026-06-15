# Orquestacion PBI -> ORDS -> React

## Objetivo
Estandarizar la ejecucion de migraciones Oracle Forms a partir de un PBI de Azure DevOps, con trazabilidad tecnica y funcional.

## Entradas Minimas
- PBI_URL
- REPO_BASE_PATH
- GUIDELINES_PATH
- VIDEO_FOLDER

## Fases Operativas

### Fase 1: Lectura del PBI
1. Leer descripcion completa.
2. Leer criterios de aceptacion.
3. Leer adjuntos y enlaces relacionados.
4. Extraer nombre de la forma desde el ultimo segmento del titulo separado por '|'.

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

## Reglas
- Artefactos en espanol.
- No inventar reglas no presentes en codigo/video.
- Si hay contradiccion entre video y forma, documentar ambas y marcar pendiente funcional.
- Confirmar disponibilidad de MCP antes de cada fase.

## Fuentes
- prompts/awsome_prompt.md
- prompts/agent_orchestration_prompt.html
