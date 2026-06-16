# GET BY ID - Obtener Detalle

Plantillas para implementar endpoint GET by ID (obtener detalle) siguiendo los estándares del proyecto.

## Variables a Reemplazar

- `{entity}` → nombre de la entidad en minúsculas (ej: `cliente`, `producto`)
- `{ENTITY}` → nombre de la entidad en mayúsculas (ej: `CLIENTE`, `PRODUCTO`)
- `{dominio}` → dominio de la API (ej: `personas`, `productos`, `configuracion`)
- `{tabla}` → nombre de la tabla en base de datos (ej: `CLI_CLIENTE`, `PRO_PRODUCTO`)
- `{schema}` → esquema de base de datos (ej: `DBAPER`, `POLIZAS`, `FACTURACION`)
- `{codigo}` → nombre del campo código PK (ej: `codigo_cliente`, `codigo_producto`)
- `{CODIGO}` → nombre del campo código en tabla (ej: `COD_CLI`, `COD_PRO`)

---

## 1. Template (`templates/template-{entity}s-detalle.sql`)

```sql
-- =====================================================
-- Template: /{dominio}/api/v1/{entity}s/{{codigo}}
-- Descripción: Detalle de un {entity} por código
-- =====================================================

BEGIN
    ORDS_ADMIN.DEFINE_TEMPLATE(
        p_module_name => '{dominio}.api.v1',
        p_schema      => 'DBAPER',
        p_pattern     => '{entity}s/:{codigo}',
        p_priority    => 0,
        p_etag_type   => 'HASH',
        p_etag_query  => NULL,
        p_schema => 'DBAPER', p_comments    => 'Detalle de {entity} por código'
    );
    COMMIT;
END;
/
```

---

## 2. Handler (`handlers/GET-{entity}s-detalle.sql`)

```sql
-- =====================================================
-- Handler: GET /{dominio}/api/v1/{entity}s/{{codigo}}
-- Descripción: Obtener detalle de un {entity}
-- Tipo: plsql/block (para manejar 404)
-- =====================================================

BEGIN
     ORDS_ADMIN.DEFINE_HANDLER(
        p_module_name    => '{dominio}.api.v1',
        p_pattern        => '{entity}s/:{codigo}',
        p_method         => 'GET',
        p_source_type    => 'json/item',
        p_mimes_allowed  => 'application/json',
        p_schema => 'DBAPER', p_comments       => 'Listar {entity}s (colección)',
        p_source         => '
    SELECT
      t.{CODIGO} AS {codigo},
      t.DESCRIPCION AS descripcion,
      t.TIPO AS tipo,
      t.ACTIVO AS es_activo,
      TO_CHAR(t.FEC_CREACION, ''YYYY-MM-DD"T"HH24:MI:SS"Z"'') AS creado_en
      USUARIO AS creado_por,
      JSON_OBJECT(''codigo'' value d.codigo
                  ''descripcion'' value descripcion,
                  ''tipo'' value tipo) as "{}detalle"
FROM {schema}.{tabla} t
JOIN {schema}.{detail} d
  on t.codigo = d.codigo_tabla
WHERE t.codigo = :codigo -- Solo activos por defecto
GROUP BY t.{CODIGO},
      t.DESCRIPCION,
      t.TIPO,
      t.ACTIVO,
      TO_CHAR(t.FEC_CREACION, ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')
      USUARIO'
    );
    COMMIT;
END;
/
```

---


## Ejemplo de Request

```bash
GET /{dominio}/api/v1/{entity}s/:codigo
Authorization: Bearer {token}

# Response: 200 OK - Retorna UN objeto directo (sin array, sin paginación)
{
  "{codigo}": 1234,
  "descripcion": "Tablet 10 pulgadas",
  "tipo": "ELECTRONICA",
  "es_activo": "S",
  "creado_en": "2026-03-06T10:30:00Z",
  "detalle": {
    "codigo": "...",
    "descripcion": "...",
    "tipo": "..."
  }
}

```

---

## Características

✅ **Tipo `json/item`**: ORDS retorna automáticamente el primer registro como objeto JSON
✅ **404 automático**: ORDS retorna 404 si el SELECT no devuelve filas (sin código adicional)
✅ **Todos los campos**: Incluye campos completos del recurso (no solo esenciales)
✅ **Campos de auditoría**: creado_en, creado_por, actualizado_en, actualizado_por
✅ **snake_case obligatorio**: En todos los alias del SELECT
✅ **JSON_OBJECT para sub-objetos**: Permite anidar estructuras en el SELECT
❌ **Sin validación de formato**: No puedes retornar 400 por código inválido
❌ **Sin F_GENERAR_RESPUESTA_ESTANDAR**: La respuesta la controla ORDS directamente
❌ **Sin manejo de errores personalizados**: No puedes interceptar excepciones

## Notas Importantes

- **Incluir TODOS los campos**: A diferencia del GET collection
- **Validar formato**: Código debe ser numérico (o según tipo)
- **Verificar existencia**: Antes de buscar datos completos
- **snake_case obligatorio**: En todos los atributos JSON
- **Manejo de NULL**: Para actualizado_en/actualizado_por si nunca se actualizó
- **Ajustar JSON_OBJECT**: Según campos reales de tu tabla
