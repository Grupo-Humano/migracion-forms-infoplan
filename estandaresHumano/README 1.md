# Plantillas CRUD para ORDS

Este directorio contiene plantillas reutilizables para implementar operaciones CRUD siguiendo los estándares del proyecto.

## 📁 Archivos Disponibles

| Archivo | Operación | Descripción |
|---------|-----------|-------------|
| [POST-template.md](POST-template.md) | **CREATE** | Crear nuevo registro (201 Created) |
| [GET-collection-template.md](GET-collection-template.md) | **READ ALL** | Listar colección con paginación automática |
| [GET-detail-template.md](GET-detail-template.md) | **READ ONE** | Obtener detalle por ID (con 404) |
| [PUT-template.md](PUT-template.md) | **UPDATE** | Actualizar registro existente (204 No Content) |
| [DELETE-template.md](DELETE-template.md) | **DELETE** | Eliminar registro (lógico o físico) |
| [CRUD-PLANTILLAS.md](CRUD-PLANTILLAS.md) | **COMPLETO** | Todas las plantillas en un solo archivo |

---

## 🚀 Uso Rápido

### 1. Define tus variables

```bash
entity → cliente
ENTITY → CLIENTE
Entity → Cliente
dominio → personas
tabla → CLI_CLIENTE
schema → DBAPER
codigo → codigo_cliente
CODIGO → COD_CLI
```

### 2. Copia la plantilla necesaria

Por ejemplo, para implementar POST (crear cliente):

```bash
# Archivo: POST-template.md
# Contiene: Template + Handler + Procedure
```

### 3. Reemplaza las variables

Usa la función de buscar/reemplazar de tu editor:

- `{entity}` → `cliente`
- `{ENTITY}` → `CLIENTE`
- `{dominio}` → `personas`
- `{tabla}` → `CLI_CLIENTE`
- `{schema}` → `DBAPER`
- `{codigo}` → `codigo_cliente`
- `{CODIGO}` → `COD_CLI`

### 4. Ajusta campos específicos

Modifica según tu entidad:

**En el Procedure POST**:
```sql
TYPE t_parametros IS RECORD (
    nombre             VARCHAR2(100),  -- Ajustar
    apellido           VARCHAR2(100),  -- Ajustar
    email              VARCHAR2(100),  -- Ajustar
    telefono           VARCHAR2(20),   -- Ajustar
    es_activo          VARCHAR2(1)
);
```

**En el INSERT**:
```sql
INSERT INTO DBAPER.CLI_CLIENTE (
    COD_CLI,
    NOMBRE,          -- Ajustar
    APELLIDO,        -- Ajustar
    EMAIL,           -- Ajustar
    TELEFONO,        -- Ajustar
    ACTIVO,
    FEC_CREACION,
    USR_CREACION
)
```

### 5. Ejecuta los scripts

```sql
-- 1. Template
@templates/template-clientes.sql

-- 2. Handler POST
@handlers/POST-clientes.sql

-- 3. Procedure
@procedures/P_CREAR_CLIENTE_ORDS.prc

-- 4. Verificar
SELECT * FROM ORDS_ADMIN.ORDS_MODULES WHERE name = 'personas.api.v1';
```

---

## 📋 Estructura de Archivos Resultante

Después de usar las plantillas, tu proyecto debe verse así:

```
{dominio}/
├── templates/
│   ├── template-{entity}s.sql           ← GET collection, POST
│   └── template-{entity}s-detalle.sql   ← GET by ID, PUT, DELETE
├── handlers/
│   ├── POST-{entity}s.sql
│   ├── GET-{entity}s-collection.sql
│   ├── GET-{entity}s-detalle.sql
│   ├── PUT-{entity}s-detalle.sql
│   └── DELETE-{entity}s-detalle.sql
└── procedures/
    ├── P_CREAR_{ENTITY}_ORDS.prc
    ├── P_ACTUALIZAR_{ENTITY}_ORDS.prc
    ├── P_ELIMINAR_{ENTITY}_ORDS.prc
    └── P_VALIDAR_{ENTITY}.prc
```

**Ejemplo concreto** (clientes):
```
personas/
├── templates/
│   ├── template-clientes.sql
│   └── template-clientes-detalle.sql
├── handlers/
│   ├── POST-clientes.sql
│   ├── GET-clientes-collection.sql
│   ├── GET-clientes-detalle.sql
│   ├── PUT-clientes-detalle.sql
│   └── DELETE-clientes-detalle.sql
└── procedures/
    ├── P_CREAR_CLIENTE_ORDS.prc
    ├── P_ACTUALIZAR_CLIENTE_ORDS.prc
    ├── P_ELIMINAR_CLIENTE_ORDS.prc
    └── P_VALIDAR_CLIENTE.prc
```

---

## 🎯 Endpoints Resultantes

Siguiendo las plantillas, obtendrás estos endpoints RESTful:

```
POST   /{dominio}/api/v1/{entity}s              → Crear
GET    /{dominio}/api/v1/{entity}s              → Listar (paginado)
GET    /{dominio}/api/v1/{entity}s/{codigo}     → Obtener detalle
PUT    /{dominio}/api/v1/{entity}s/{codigo}     → Actualizar
DELETE /{dominio}/api/v1/{entity}s/{codigo}     → Eliminar
```

**Ejemplo** (clientes):
```
POST   /personas/api/v1/clientes
GET    /personas/api/v1/clientes
GET    /personas/api/v1/clientes/1234
PUT    /personas/api/v1/clientes/1234
DELETE /personas/api/v1/clientes/1234
```

---

## ✨ Características de las Plantillas

### Estándares del Proyecto

✅ **snake_case obligatorio** en JSON  
✅ **Respuestas estándar** con `F_GENERAR_RESPUESTA_ESTANDAR`  
✅ **HTTP codes correctos**: 200, 201, 204, 400, 404, 422, 500  
✅ **Autenticación dual-token** JWT  
✅ **Validación con P_ALCANCE**: FIELD → FORM → BUSINESS → ALL  
✅ **Change detection** en UPDATE (evita triggers innecesarios)  
✅ **SQL seguro** (CASE WHEN previene SQL injection)  
✅ **Auditoría automática** (creado_en, actualizado_en, usuarios)  
✅ **Logs automáticos** con P_LOG_ORDS

### Código Production-Ready

✅ Manejo completo de errores  
✅ Validación de formato  
✅ Verificación de existencia  
✅ COMMIT/ROLLBACK apropiados  
✅ Documentación inline  
✅ Patrones enterprise probados

---

## 📖 Guía por Operación

### POST (Crear)
- ❌ **NO enviar** `codigo` (auto-generado)
- ❌ **NO enviar** `estatus` (default: 'S')
- ✅ Retorna **201 Created** con objeto creado
- 📄 Ver: [POST-template.md](POST-template.md)

### GET Collection (Listar)
- ✅ Tipo `json/collection` (paginación automática ORDS)
- ✅ Solo campos esenciales (6-12 máximo)
- ✅ **NO valida** parámetros (no retorna 400)
- 📄 Ver: [GET-collection-template.md](GET-collection-template.md)

### GET by ID (Detalle)
- ✅ Tipo `plsql/block` (maneja 404)
- ✅ Todos los campos (completo)
- ✅ Valida formato de ID
- 📄 Ver: [GET-detail-template.md](GET-detail-template.md)

### PUT (Actualizar)
- ✅ PATCH-like (solo actualiza campos enviados)
- ✅ Change detection (evita UPDATEs innecesarios)
- ✅ Retorna **204 No Content**
- ❌ Código **NUNCA** se actualiza
- 📄 Ver: [PUT-template.md](PUT-template.md)

### DELETE (Eliminar)
- ✅ Dos opciones: Lógica (recomendada) o Física
- ✅ Maneja ORA-02292 (violación referencial) → 422
- ✅ Retorna **204 No Content**
- 📄 Ver: [DELETE-template.md](DELETE-template.md)

---

## 🔧 Personalización

### Campos Comunes que Ajustar

1. **TYPE t_parametros** (en procedures):
```sql
TYPE t_parametros IS RECORD (
    -- Ajustar según tu tabla
    descripcion       VARCHAR2(200),
    tipo              VARCHAR2(50),
    es_activo         VARCHAR2(1),
    comentario        VARCHAR2(4000)
);
```

2. **INSERT/UPDATE statements**:
```sql
INSERT INTO {schema}.{tabla} (
    -- Ajustar columnas según tu tabla
    {CODIGO},
    DESCRIPCION,
    TIPO,
    ACTIVO,
    FEC_CREACION,
    USR_CREACION
)
```

3. **JSON_OBJECT en GET detail**:
```sql
SELECT JSON_OBJECT(
    -- Ajustar campos según tu tabla
    'codigo' VALUE CODIGO,
    'descripcion' VALUE DESCRIPCION,
    'tipo' VALUE TIPO,
    'es_activo' VALUE ACTIVO
)
```

4. **Validaciones específicas**:
```sql
-- Implementar P_VALIDAR_{ENTITY}
-- Ver ejemplos en proyecto
```

---

## 📚 Referencias

- **Guía completa**: [CRUD-PLANTILLAS.md](CRUD-PLANTILLAS.md)
- **Estándares REST**: `../.github/instructions/rest-api-estandarizacion.instructions.md`
- **Patrones PL/SQL**: `../.github/copilot-instructions.md`
- **Ejemplos reales**: Carpetas `entrada_radicacion/`, `poliza-planes/`, `autorizaciones/`

---

## ⚡ Tips Rápidos

### 1. Buscar/Reemplazar Global

En VS Code o editor similar:
```
Ctrl+H (Find and Replace)
```

Reemplazos múltiples:
```
{entity}   →   cliente
{ENTITY}   →   CLIENTE
{dominio}  →   personas
{tabla}    →   CLI_CLIENTE
{schema}   →   DBAPER
{codigo}   →   codigo_cliente
{CODIGO}   →   COD_CLI
```

### 2. Validar URLs

```bash
# Formato correcto
/{dominio}/api/v1/{entity}s
/personas/api/v1/clientes        ✅ Correcto

# Formatos incorrectos
/api/v1/personas/clientes        ❌ Dominio debe ir primero
/personas/v1/api/clientes        ❌ Orden incorrecto
/personas/api/v1/cliente         ❌ Debe ser plural
```

### 3. Convenciones de Nombres

```bash
# Archivos SQL
POST-{entity}s.sql               ✅ POST-clientes.sql
GET-{entity}s-collection.sql     ✅ GET-clientes-collection.sql
GET-{entity}s-detalle.sql        ✅ GET-clientes-detalle.sql

# Procedures
P_CREAR_{ENTITY}_ORDS.prc        ✅ P_CREAR_CLIENTE_ORDS.prc
P_ACTUALIZAR_{ENTITY}_ORDS.prc   ✅ P_ACTUALIZAR_CLIENTE_ORDS.prc
```

### 4. Secuencias

No olvides crear la secuencia:
```sql
CREATE SEQUENCE {schema}.SEQ_{TABLA}
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;
```

---

## 🆘 Troubleshooting

### Error: "ORA-20000: Resource pattern conflict"
**Causa**: Ya existe un template con ese pattern  
**Solución**: Usar `p_priority` diferente o eliminar template existente

### Error: "ORA-00942: table or view does not exist"
**Causa**: Esquema o tabla incorrectos  
**Solución**: Verificar `{schema}.{tabla}` en base de datos

### Error: "Token inválido" (401)
**Causa**: x-ad-token no configurado  
**Solución**: Verificar `DEFINE_PARAMETER` para `P_TOKEN`

### No retorna 404 en GET by ID
**Causa**: Usando `json/collection` en lugar de `plsql/block`  
**Solución**: Cambiar `p_source_type` a `plsql/block`

---

## 📝 Checklist de Implementación

Antes de desplegar:

- [ ] ✅ Variables reemplazadas correctamente
- [ ] ✅ Campos ajustados según tabla real
- [ ] ✅ Secuencia creada
- [ ] ✅ Templates ejecutados sin errores
- [ ] ✅ Handlers ejecutados sin errores
- [ ] ✅ Procedures compiladas sin errores
- [ ] ✅ P_VALIDAR_{ENTITY} implementado
- [ ] ✅ Grants otorgados al usuario ORDS
- [ ] ✅ Probado en Postman (201, 200, 204, 400, 404)
- [ ] ✅ JSON usa snake_case estricto

---

**¿Preguntas?** Consulta la [guía completa](CRUD-PLANTILLAS.md) o los ejemplos en el proyecto.

---

_Última actualización: 2026-03-06_  
_Versión: 1.0_
