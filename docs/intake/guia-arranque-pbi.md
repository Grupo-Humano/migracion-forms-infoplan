# Guia de Arranque de Nuevo PBI (Remy)

Objetivo: iniciar cualquier PBI con estructura obligatoria y flujo controlado de principio a fin.

## Comando base (PowerShell)

Usa este comando desde la raiz del repo para crear la estructura minima:

$PBI="PBI-209999"; $SCREEN="nombre_pantalla"; New-Item -ItemType Directory -Force -Path "docs/intake/pantallas/$PBI/entradas/$SCREEN","docs/intake/pantallas/$PBI/salidas/$SCREEN","docs/intake/pantallas/$PBI/orquestacion" | Out-Null; Copy-Item "docs/intake/pantallas/_template/PBI-ID/README.md" "docs/intake/pantallas/$PBI/README.md" -Force; Copy-Item "docs/intake/pantallas/_template/PBI-ID/entradas/NOMBRE_PANTALLA/*" "docs/intake/pantallas/$PBI/entradas/$SCREEN/" -Force; Copy-Item "docs/intake/pantallas/_template/PBI-ID/salidas/NOMBRE_PANTALLA/README.md" "docs/intake/pantallas/$PBI/salidas/$SCREEN/README.md" -Force; Copy-Item "docs/intake/pantallas/_template/PBI-ID/orquestacion/*" "docs/intake/pantallas/$PBI/orquestacion/" -Force

Luego reemplaza en los archivos placeholders PBI-ID, NOMBRE_PANTALLA e INT-XXX.

## Paso a paso obligatorio

1. Crear folder madre del PBI
- Ruta: docs/intake/pantallas/PBI-<id_pbi>/
- Debe contener: entradas, salidas, orquestacion.

2. Crear pantalla dentro de entradas
- Ruta: docs/intake/pantallas/PBI-<id_pbi>/entradas/<nombre_pantalla>/
- Cargar solo:
  - descripcion-criterios.md
  - transcripcion-funcionales.md
  - XML de la forma legacy

3. Crear salida de pantalla
- Ruta: docs/intake/pantallas/PBI-<id_pbi>/salidas/<nombre_pantalla>/
- Escribir solo analisis/artefactos del equipo.

4. Inicializar orquestacion
- Ruta: docs/intake/pantallas/PBI-<id_pbi>/orquestacion/
- Archivos:
  - plan.md
  - progress.md
  - done.md

5. Registrar trazabilidad minima
- Actualizar docs/intake/solicitudes-pantallas.md con:
  - ID interno intake
  - PBI
  - pantalla
  - owner
  - ruta folder madre
  - ruta entradas
  - ruta salidas

6. Gate de inicio
- No iniciar analisis tecnico sin:
  - descripcion-criterios.md completo
  - transcripcion-funcionales.md cargada
  - XML presente

7. Analisis ORDS existente (obligatorio)
- Consultar SQL Developer MCP para listar modulos ORDS disponibles.
- Comparar la logica extraida con endpoints existentes (GET/POST/PUT/DELETE).
- Publicar tabla: reutilizable vs adaptable vs nuevo.
- Ejecutar checkpoint humano y detenerse.

Checks operativos obligatorios (anti-confusion mock vs real):
- Confirmar si el endpoint de busqueda apunta a fuente mock o real.
- Documentar endpoint canónico por operacion UI (buscar, marcar, desmarcar, exportar).
- Si hay endpoint mock y endpoint real para la misma operacion, bloquear mock para uso productivo.
- Registrar evidencia SQL minima del source del handler para evitar ambiguedad.
- Politica de exportes: si existe Jasper para la pantalla, OLE no se desarrolla ni se extiende.
- Si no existe Jasper, crear tarea obligatoria de implementacion Jasper con owner y fecha objetivo.

Checkpoint humano obligatorio:
- Presentar analisis de ORDS reutilizables vs nuevos.
- Esperar aprobacion explicita antes de crear endpoint/modulo nuevo.
- Si no hay aprobacion: estado `EN_ESPERA_APROBACION_HUMANA`.

8. Ejecucion y control
- Actualizar progress.md por fase.
- Escribir salidas tecnicas solo en salidas/<pantalla>/.
- Verificar paginacion ORDS en cada demo (items/hasMore/limit/offset) y reflejar el alcance real del conteo mostrado en UI.
- Registrar en progress.md si aplica Jasper-first (SI/NO) y la decision sobre OLE.

9. Cierre
- Completar done.md con evidencia QA, riesgos residuales y decision de cierre.

## Diagrama de flujo (end-to-end)

```mermaid
flowchart TD
    A[Inicio nuevo PBI] --> B[Crear folder madre PBI-<id>]
    B --> C[Crear entradas/<pantalla>]
    C --> D[Cargar descripcion-criterios, transcripcion, XML]
    D --> E{Gate de inicio completo?}
    E -- No --> D
    E -- Si --> F[Crear salidas/<pantalla>]
    F --> G[Crear orquestacion plan/progress/done]
    G --> H[Registrar en solicitudes-pantallas]
    H --> I[Analisis ORDS existente via SQL Developer MCP]
    I --> J{Checkpoint humano aprobado?}
    J -- No --> I
    J -- Si --> K[Analisis tecnico en salidas]
    K --> L[Validacion QA]
    L --> M{Cumple criterios?}
    M -- No --> K
    M -- Si --> N[Completar done.md]
    N --> O[Cierre del PBI]
  ```

## Reglas de oro

1. Nada operativo del PBI fuera del folder madre.
2. Entradas no se contamina con analisis.
3. Salidas no guarda insumos originales.
4. Si algo es global, va fuera del arbol PBI y no bloquea la trazabilidad local.
