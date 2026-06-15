# Analisis Inicial del PBI - rep_aprobarechazo

Base de analisis:
- `pbi.md`
- `insumos.md`

## 1. Objetivo funcional

Permitir consulta de polizas aprobadas/rechazadas por rango de fechas y filtros opcionales, con exportacion a Excel para analisis operativo.

## 2. Mapeo PBI -> capacidad actual

### CA-01 Consulta por fechas y cliente
- Cubierto en forma legacy: SI.
- Cubierto en implementacion actual React/ORDS: SI (busqueda por `fec_ini`, `fec_fin`, `cliente`, `oficial`, `gerente`, `intermediario`).
- Validaciones clave:
  - Fechas obligatorias.
  - `fec_ini <= fec_fin`.

### CA-02 Filtro por intermediario
- Cubierto en forma legacy: SI.
- Cubierto en implementacion actual React/ORDS: SI (`intermediario` opcional).

### CA-03 Exportacion a Excel
- Legacy:
  - Ruta OLE (`GENERA_REPORTE`).
  - Ruta Jasper (`P_JASPER_A_EXCEL`).
- Estado actual:
  - Endpoints y cliente existen en modo mock.
  - Falta confirmar equivalencia final del archivo Excel productivo (estructura y formato final).

### CA-04 Filtrado y limpieza de informacion
- Interpretacion funcional:
  - El usuario limpia columnas en Excel despues de exportar.
- Gap actual:
  - No hay definicion cerrada de columnas obligatorias del archivo final y su orden oficial.

## 3. Gaps abiertos para cierre funcional

1. Definir especificacion final de Excel objetivo:
   - Columnas exactas.
   - Orden.
   - Nombres de cabecera.
   - Formatos (fecha, monto, texto).
2. Confirmar comportamiento esperado de seleccion/marcado para exportar.
3. Definir si se mantiene doble ruta de exportacion (OLE y Jasper) o se unifica.

## 4. Decision de trabajo

El analisis del PBI de esta pantalla se considera valido solo si se actualiza este archivo junto con `pbi.md` e `insumos.md`.

## 5. Checkpoint ORDS (SQL Developer MCP)

Fecha de consulta: 2026-06-15
Conexion: HUMANO_DESA

Evidencia de modulo existente:
- Modulo ORDS encontrado: `rep-aprobarechazo`
- URI prefix: `/rep-aprobarechazo/`
- Estado: `PUBLISHED`

Endpoints detectados en el modulo:
- `GET oficial/{codigo}`
- `POST search`
- `POST seleccion/{accion}`
- `POST export/ole`
- `POST export/jasper`

Clasificacion reutilizable vs nuevo:

| Operacion funcional | Metodo esperado | Endpoint ORDS actual | Clasificacion | Observacion |
|---|---|---|---|---|
| Consulta principal con filtros | POST | `search` | REUTILIZABLE | Ya cubre busqueda por rango y filtros opcionales. |
| Obtener oficial por codigo | GET | `oficial/{codigo}` | REUTILIZABLE | Endpoint existente para soporte de datos de oficial. |
| Seleccion para accion de exportacion | POST | `seleccion/{accion}` | ADAPTABLE | Revisar payload/respuesta vs comportamiento final requerido. |
| Exportacion Excel via OLE | POST | `export/ole` | REUTILIZABLE | Existe ruta dedicada para exportacion OLE. |
| Exportacion Excel via Jasper | POST | `export/jasper` | REUTILIZABLE | Existe ruta dedicada para exportacion Jasper. |
| Crear nuevo modulo ORDS | N/A | N/A | NUEVO (NO APROBADO) | Bloqueado hasta aprobacion humana explicita. |

Estado del checkpoint humano:
- `EN_ESPERA_APROBACION_HUMANA`

Regla aplicada:
- No se permite crear modulo ORDS nuevo ni avanzar a implementacion de nuevos endpoints hasta aprobacion explicita del checkpoint humano.
