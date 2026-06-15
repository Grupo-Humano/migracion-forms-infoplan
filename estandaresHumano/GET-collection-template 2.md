# GET ALL - Listar Colección

Plantilla para implementar endpoint GET collection (listar todos) siguiendo los estándares del proyecto.

## Variables a Reemplazar

- `{entity}` → nombre de la entidad en minúsculas (ej: `cliente`, `producto`)
- `{ENTITY}` → nombre de la entidad en mayúsculas (ej: `CLIENTE`, `PRODUCTO`)
- `{dominio}` → dominio de la API (ej: `personas`, `productos`, `configuracion`)
- `{tabla}` → nombre de la tabla en base de datos (ej: `CLI_CLIENTE`, `PRO_PRODUCTO`)
- `{schema}` → esquema de base de datos (ej: `DBAPER`, `POLIZAS`, `FACTURACION`)
- `{codigo}` → nombre del campo código PK (ej: `codigo_cliente`, `codigo_producto`)
- `{CODIGO}` → nombre del campo código en tabla (ej: `COD_CLI`, `COD_PRO`)

---

## Handler (`handlers/GET-{entity}s-collection.sql`)

```sql
-- =====================================================
-- Handler: GET /{dominio}/api/v1/{entity}s
-- Descripción: Listar todos los {entity}s (paginado automático)
-- Tipo: json/collection (ORDS automático)
-- NO valida parámetros, NO retorna 400
-- =====================================================

BEGIN
    ORDS_ADMIN.DEFINE_HANDLER(
        p_module_name    => '{dominio}.api.v1',
        p_pattern        => '{entity}s',
        p_method         => 'GET',
        p_source_type    => 'json/collection',
        p_mimes_allowed  => 'application/json',
        p_schema => 'DBAPER', p_comments       => 'Listar {entity}s (colección)',
        p_source         => 'SELECT
    t.{CODIGO} AS {codigo},
    t.DESCRIPCION AS descripcion,
    t.TIPO AS tipo,
    t.ACTIVO AS es_activo,
    TO_CHAR(t.FEC_CREACION, ''YYYY-MM-DD"T"HH24:MI:SS"Z"'') AS creado_en
FROM {schema}.{tabla} t
WHERE t.ACTIVO = ''S''  -- Solo activos por defecto
ORDER BY t.DESCRIPCION ASC'
    );
    
    COMMIT;
END;
/
```

---

## Filtros Opcionales

Si necesitas agregar parámetros de filtro:

```sql
-- Opcional: Agregar parámetros de filtro
BEGIN
    -- Filtro por tipo (query string)
    ORDS_ADMIN.DEFINE_PARAMETER(
        p_module_name        => '{dominio}.api.v1',
        p_pattern            => '{entity}s',
        p_method             => 'GET',
        p_name               => 'tipo',
        p_bind_variable_name => 'tipo',
        p_source_type        => 'URI',
        p_param_type         => 'STRING',
        p_access_method      => 'IN',
        p_schema => 'DBAPER', p_comments           => 'Filtrar por tipo'
    );
    
    -- Filtro incluir inactivos
    ORDS_ADMIN.DEFINE_PARAMETER(
        p_module_name        => '{dominio}.api.v1',
        p_pattern            => '{entity}s',
        p_method             => 'GET',
        p_name               => 'incluir_inactivos',
        p_bind_variable_name => 'incluir_inactivos',
        p_source_type        => 'URI',
        p_param_type         => 'STRING',
        p_access_method      => 'IN',
        p_schema => 'DBAPER', p_comments           => 'S para incluir inactivos'
    );
    
    COMMIT;
END;
/
```

### Query con filtros (reemplazar el p_source anterior):

```sql
p_source => 'SELECT
    t.{CODIGO} AS {codigo},
    t.DESCRIPCION AS descripcion,
    t.TIPO AS tipo,
    t.ACTIVO AS es_activo,
    TO_CHAR(t.FEC_CREACION, ''YYYY-MM-DD"T"HH24:MI:SS"Z"'') AS creado_en
FROM {schema}.{tabla} t
WHERE (:tipo IS NULL OR t.TIPO = :tipo)
  AND (NVL(:incluir_inactivos, ''N'') = ''S'' OR t.ACTIVO = ''S'')
ORDER BY t.DESCRIPCION ASC'
```

---

## Ejemplo de Request

```bash
GET /{dominio}/api/v1/{entity}s?tipo=ELECTRONICA&limit=20&offset=0
Authorization: Bearer {token}

Response: 200 OK
{
  "items": [
    {
      "{codigo}": 1234,
      "descripcion": "Tablet 10 pulgadas",
      "tipo": "ELECTRONICA",
      "es_activo": "S",
      "creado_en": "2026-03-06T10:30:00Z"
    },
    {
      "{codigo}": 1235,
      "descripcion": "Laptop 15 pulgadas",
      "tipo": "ELECTRONICA",
      "es_activo": "S",
      "creado_en": "2026-03-06T11:00:00Z"
    }
  ],
  "hasMore": false,
  "limit": 20,
  "offset": 0,
  "count": 2
}
```

---

## Características

✅ **Tipo `json/collection`**: Paginación automática de ORDS  
✅ **NO valida parámetros**: No retorna 400 por parámetros inválidos  
✅ **Campos esenciales**: 6-12 campos máximo (para UI)  
✅ **Paginación automática**: `limit`, `offset`, `hasMore`, `count`  
✅ **Filtros opcionales**: Agregar según necesidad  
✅ **Sin autenticación en handler**: ORDS la maneja automáticamente

## Notas Importantes

- **Solo campos necesarios**: No incluir todos los campos (usar GET by ID para detalle)
- **Ordenamiento**: Siempre incluir ORDER BY
- **Filtro por defecto**: Considerar filtrar solo activos (`ACTIVO = 'S'`)
- **snake_case obligatorio**: En todos los alias de columnas
- **Parámetros opcionales**: Usar `IS NULL OR` para filtros opcionales
- **No usar procedimientos**: `json/collection` para máximo performance

## Paginación ORDS

ORDS agrega automáticamente estos parámetros:
- `?limit=25` - Número de registros por página (default: 25)
- `?offset=0` - Registro inicial (default: 0)

Respuesta incluye:
- `items[]` - Array de resultados
- `hasMore` - Booleano si hay más páginas
- `limit` - Límite aplicado
- `offset` - Offset aplicado
- `count` - Total de items en la página actual
