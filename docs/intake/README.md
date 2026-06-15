# Hub Central de Insumos

Este es el punto unico de entrada para todos los insumos que solicita el equipo antes de migrar una pantalla.

## Regla de uso

1. Toda solicitud nueva de pantalla se registra primero en:
   - `docs/intake/solicitudes-pantallas.md`
2. Si la pantalla ya existe, se actualiza la misma fila con modo `CONTINUIDAD_DELTA`.
3. No iniciar trabajo tecnico sin estado `GO_INTAKE_COMPLETO` o `GO_CONTINUIDAD_DELTA`.

## Archivos del hub

- `docs/intake/solicitudes-pantallas.md` (registro operativo unico)
- `docs/templates/plantilla-intake-migracion.md` (formato global de referencia)
- `docs/intake/pantallas/` (folders unicos por pantalla)
- `docs/intake/guia-arranque-pbi.md` (comando + paso a paso + flujo completo)

## Pantallas con insumos ya organizados

- `docs/intake/pantallas/PBI-202787/`
- `docs/intake/pantallas/PBI-202787/entradas/rep_aprobarechazo/`
- `docs/intake/pantallas/PBI-202787/salidas/rep_aprobarechazo/`
- `docs/intake/pantallas/_template/`

## Campos minimos por solicitud

1. Plantilla objetivo.
2. Descripcion y criterios de aceptacion.
3. Recursos (pruebas/transcripcion/videos/evidencias).
4. Estimacion de esfuerzo y sprint por formulario.
5. Estimacion de pantallas nuevas o cambios.
6. Contexto adicional (riesgos, restricciones, dependencias).

## Estructura obligatoria por pantalla

Cada PBI debe tener un folder madre en `docs/intake/pantallas/PBI-<id_pbi>/` con:

1. `entradas/<nombre_pantalla>/`
2. `salidas/<nombre_pantalla>/`

La carpeta de entrada por pantalla debe estar en `docs/intake/pantallas/PBI-<id_pbi>/entradas/<nombre_pantalla>/` con:

1. `descripcion-criterios.md`
2. `transcripcion-funcionales.md`
3. `<nombre_forma>.xml`

El analisis se genera en:

- `docs/intake/pantallas/PBI-<id_pbi>/salidas/<nombre_pantalla>/`

Todo analisis inicia leyendo `entradas/` y se escribe en `salidas/` dentro del mismo folder madre del PBI.

## Regla de confinamiento

No se debe crear ni mantener trabajo operativo del PBI fuera de su folder madre `PBI-<id_pbi>`.
Si algo es global, no pertenece al flujo operativo del PBI y debe gestionarse fuera de este esquema.

## Regla del registro maestro

`docs/intake/solicitudes-pantallas.md` solo conserva trazabilidad minima (ID, estado, owner, rutas).
El detalle operativo vive dentro del folder madre del PBI.

## Checkpoint humano ORDS (obligatorio)

Antes de disenar o crear endpoints/modulos ORDS:

1. Consultar SQL Developer MCP para listar modulos ORDS disponibles.
2. Comparar logica extraida con endpoints existentes (GET/POST/PUT/DELETE).
3. Publicar matriz de clasificacion: `REUTILIZABLE`, `ADAPTABLE`, `NUEVO`.
4. Presentar analisis a checkpoint humano y esperar aprobacion explicita.

Estados de control:
- `REUSE_IN_EXISTING_MODULE`
- `CREATE_NEW_MODULE_WITH_JUSTIFICATION`
- `EN_ESPERA_APROBACION_HUMANA`

Regla:
- No crear modulo ORDS nuevo sin aprobacion explicita del checkpoint.
