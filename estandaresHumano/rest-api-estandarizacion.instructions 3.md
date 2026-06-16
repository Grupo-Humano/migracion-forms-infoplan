---
applyTo: '**'
---

# REST API Design and Development Rules with ORDS

## Project Context
This project implements REST services using Oracle REST Data Services (ORDS) following strict enterprise standards. All APIs must comply with naming conventions, response patterns, and separation of concerns as defined.

## Fundamental Rules

### 1. JSON Naming Conventions

**CRITICAL**: All JSON attributes must strictly use `snake_case`.

✅ **Correct**:
```json
{
  "codigo_cliente": "CLI001",
  "fecha_nacimiento": "1990-05-15",
  "es_activo": "S",
  "secuencial_poliza": 12345
}
```

❌ **Incorrect**:
```json
{
  "codigoCliente": "CLI001",
  "fechaNacimiento": "1990-05-15",
  "isActive": "S",
  "polizaId": 12345
}
```

**Specific rules**:
- **PKs and references**: Always use prefix `codigo_`
  - Examples: `codigo_cliente`, `codigo_plan`, `codigo_compania`
- **Sequences**: Use format `secuencial_<table>`
  - Examples: `secuencial_poliza`, `secuencial_autorizacion`
- **Booleans**: Semantic prefixes `es_`, `tiene_`, `debe_`, `aplica_`
  - Examples: `es_activo`, `tiene_permiso`, `aplica_recargo`
- **Dates**: ISO 8601
  - Date: `YYYY-MM-DD`
  - Timestamp: `YYYY-MM-DDTHH24:MI:SSZ`
- **Audit timestamps**: Suffix `_en` or `_at`
  - Examples: `creado_en`, `actualizado_en`, `eliminado_at`

### 2. REST URI Design

**Resource-First Principle**: Design around resources (nouns), NOT actions.

**Standard structure**:
```
/{dominio}/api/v1/{recursos}
/{dominio}/api/v1/{recursos}/{codigo}
/{dominio}/api/v1/{recursos_padre}/{id}/recursos_hijo
```

**Established domains**:
- `/personas/api/v1/...` → clients, doctors, affiliates, contacts
- `/productos/api/v1/...` → plans, catalogs, limitations, rates
- `/configuracion/api/v1/...` → cross-cutting catalogs (countries, provinces)
- `/polizas/api/v1/...` → policies and coverages
- `/polizas/api/v2/...` → policies, insured and coverages
- `/facturacion/api/v1/...` → billing, issuance, collection
- `/reclamos/api/v1/...` → medical authorizations and validations
- `/suscripcion/api/v1/...` → subscriptions, bussiness rules, operations, radicacion 


**Correct examples**:
✅ `POST /facturacion/api/v1/facturas` (create invoice)
✅ `GET /personas/api/v1/clientes/{codigo}` (get client)
✅ `GET /polizas/api/v1/polizas/{numero_poliza}/coberturas` (subresource)

❌ `POST /facturacion/api/v1/generarFactura`
❌ `GET /personas/api/v1/obtenerCliente/{codigo}`

### 3. Standard Response Structure

**Success response**:
```json
{
  "data": { ... },
  "meta": {
    "requestId": "ABC123",
    "timestamp": "2026-01-28T10:00:00.000Z",
    "version": "v1",
    "pagination": null
  }
}
```

**Error response**:
```json
{
  "meta": { ... },
  "error": {
    "type": "about:blank",
    "title": "Parametro invalido",
    "status": 400,
    "detail": "Código o formato inválido",
    "instance": "/ords/infoplan/personas/api/v1/clientes/abc"
  }
}
```

**Always use**: `DBAPER.F_GENERAR_RESPUESTA_ESTANDAR` with `p_request_id`.

### 4. Standardized HTTP Codes

- **200 OK**: Successful query (GET)
- **201 Created**: Successful creation (POST) - return created object
- **204 No Content**: Successful update/deletion (PUT/DELETE)
- **400 Bad Request**: Payload validation or invalid code
- **404 Not Found**: Resource does not exist
- **409 Conflict**: Duplication or uniqueness violation
- **422 Unprocessable Entity**: Business rule violation (e.g.: ORA-02292)
- **500 Internal Server Error**: Unexpected error

### 5. ORDS Handler Patterns
 
#### Three-File Pattern (MANDATORY)
Every endpoint requires three files:

1. **Template** (`templates/template-{resource}.sql`):
```sql
ORDS_ADMIN.DEFINE_TEMPLATE(
    p_module_name => '{modulo-name}',
    p_pattern     => '{uri_template}', -- e.g.: clientes/{codigo}
    p_schema      => 'DBAPER'
);
```

2. **Handler** (`handlers/{METHOD}-{resource}.sql`):
```sql
ORDS_ADMIN.DEFINE_HANDLER(
    p_module_name => '{modulo-name}', --
    p_pattern     => '{uri_template}', -- e.g.: clientes/{codigo}
    p_method      => 'GET',
    p_source_type => 'json/collection' | 'plsql/block'
);
```

3. **Business Procedure** (`procedures/P_{ACTION}_{ENTITY}_ORDS.prc`):
```plsql
PROCEDURE P_CREAR_RADICACION_ORDS(
    P_PARAMETROS  IN  CLOB,
    P_REQUEST_ID  IN  VARCHAR2,
    P_STATUS_CODE OUT NUMBER,
    P_BODY        OUT CLOB,
    P_ERROR       OUT VARCHAR2
)
```

#### GET Collection (Lists/LOVs)
- **Type**: `json/collection` (automatic ORDS)
- **Pagination**: Automatic by ORDS (`items`, `hasMore`, `limit`, `offset`)
- **Rule**: DO NOT validate parameters, DO NOT return 400
- **Fields**: Only essentials (6-12 maximum for UI)

```sql
-- Real example from radicaciones/handlers/GET-radicaciones-collection.sql
SELECT
  r.RADICACION AS radicacion,
  TO_CHAR(r.FECHA_RECIBIDA, 'YYYY-MM-DD') AS fecha_recibida,
  r.COD_OFICINA AS codigo_oficina,
  r.COD_REMITENTE AS codigo_remitente,
  r.COD_ESTATUS AS codigo_estatus
FROM DBAPER.RADICACION_OPER_ENC r
ORDER BY r.FECHA_RECIBIDA DESC
```

#### GET by Code (Detail)
- **Type**: `json/collection` (simple) OR `plsql/block` (with validations)
- **Validations**: Use `plsql/block` if need 400/404/500 responses
- **Structure**: Complete with all necessary fields
- **Headers**: `Authorization`, `x-ad-token`, `request-id` (optional)

**Simple approach** (`json/collection`):
```sql
-- entrada_radicacion/handlers/GET-radicaciones-detalle.sql
SELECT r.RADICACION, r.COD_OFICINA, ...
FROM DBAPER.RADICACION_OPER_ENC r
WHERE r.RADICACION = :radicacion
```

**Enterprise approach** (`plsql/block` with validations):
```plsql
-- Validate ID format
IF v_radicacion IS NULL OR v_radicacion <= 0 THEN
  :status_code := 400;
  :body := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
    p_tipo_respuesta => 'validation',
    p_validations => JSON_ARRAY_T('[{"path":"afiliado.documento","code":"IFP_DOC_INVALID","severity":"error
","message":"Documento invalido"} ]')
  );
  RETURN;
END IF;
```

#### POST/PUT/DELETE
- **Separation**: Minimal handler + Business procedures
- **Handler**: Handles HTTP, token, request-id, orchestration
- **Procedures**: Validation (`P_VALIDAR_*`), persistence (`P_CREAR_*`, `P_ACTUALIZAR_*`, `P_ELIMINAR_*`)
- **Audit**: MANDATORY on UPDATE and DELETE

**POST Rules**:
- DO NOT send `codigo` (auto-generated)
- DO NOT send `estatus` (assigned by default)
- Return **201** with created object in `data`

**PUT Rules**:
- Only update sent fields (PATCH-like behavior)
- `codigo` is NEVER updated
- Return **204 No Content**

**DELETE Rules**:
- Validate existence (404 if not exists)
- Catch ORA-02292 → 422 (reference violation)
- Return **204 No Content**

### 6. Business Procedures

**Business procedures** implement validation and persistence logic, separated from ORDS handlers.

**Standard signature**:
```plsql
PROCEDURE P_<ACTION>_<ENTITY>_ORDS(
    P_PARAMETROS  IN  CLOB,          -- JSON request body
    P_REQUEST_ID  IN  VARCHAR2,      -- Request ID for tracing
    P_STATUS_CODE OUT NUMBER,        -- HTTP status code
    P_BODY        OUT CLOB,          -- JSON response body
    P_ERROR       OUT VARCHAR2       -- Error message
)
```

**Procedure types**:
- `P_VALIDAR_*` - Validation only (returns validations array)
- `P_CREAR_*` - INSERT operations
- `P_ACTUALIZAR_*` - UPDATE operations
- `P_ELIMINAR_*` - DELETE operations
- `P_ORQUESTAR_*` - Smart routing (UPDATE vs INSERT based on changes)

**See `.github/copilot-instructions.md` for PL/SQL implementation patterns**.

### 7. Validation in Handlers

**Handlers** should call validation procedures and handle responses:

```plsql
-- In ORDS handler
DECLARE
    v_validations JSON_ARRAY_T;
    v_ok BOOLEAN;
BEGIN
    -- Call validation procedure
    SCHEMA.P_VALIDAR_<ENTITY>(
        P_OPERACION   => 'CREATE',
        P_PARAMETROS  => :body_text,
        P_VALIDATIONS => v_validations,
        P_OK          => v_ok,
        P_ALCANCE     => 'ALL'
    );
    
    IF NOT v_ok THEN
        :status_code := 400;
        :body := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => 'validation',
            p_validations    => v_validations,
            p_request_id     => v_request_id
        );
        RETURN;
    END IF;
END;
```

**Validation response structure**:
```json
{
  "field": "codigo_plan",
  "code": "INVALID_REFERENCE",
  "severity": "error",
  "message": "El plan especificado no existe"
}
```

**For validation implementation details, see `.github/copilot-instructions.md`**.

### 8. Authentication and Security

**Dual-token authentication**:
```plsql
-- Real pattern from radicaciones/handlers/POST-radicaciones.sql
DECLARE
    v_usuario VARCHAR2(100);
    c_usuario_infoplan CONSTANT VARCHAR2(30) := 'INFOPLAN_ORDS';
BEGIN
    -- Support both header token and OAuth client_id
    IF :current_user = c_usuario_infoplan THEN
        v_usuario := jwt_utils.get_username(:P_TOKEN);
    ELSE
        v_usuario := jwt_utils.get_username_by_client_id(:current_user);
    END IF;
    
    -- Set session identifier for audit trails
    DBMS_SESSION.SET_IDENTIFIER(v_usuario);
    
    -- Alternative: Use DBAPER.F_USUARIO_ORDS_USER
    v_usuario := SUBSTR(DBAPER.F_USUARIO_ORDS_USER, 1, 30);
END;
```

**Required headers**:
- `Authorization: Bearer {{Token ORDS}}` (always)
- `x-ad-token` (mapped to `:P_TOKEN` in handler)
- `Content-Type: application/json` (POST/PUT)
- `request-id` (optional, auto-generated if missing)

**Define x-ad-token parameter**:
```sql
ORDS_ADMIN.DEFINE_PARAMETER(
    p_module_name        => 'suscripcion.api.v1',
    p_schema             => 'DBAPER',
    p_pattern            => 'radicaciones',
    p_method             => 'POST',
    p_name               => 'P_TOKEN',
    p_bind_variable_name => 'P_TOKEN',
    p_source_type        => 'HEADER',
    p_param_type         => 'STRING',
    p_access_method      => 'IN'
);
```

### 9. Handler Best Practices

#### Request/Response Handling
- Always validate request body is not empty
- Extract `request-id` from header (generate with `SYS_GUID()` if missing)
- Set session identifier with `DBMS_SESSION.SET_IDENTIFIER(v_usuario)`
- Use `OWA_UTIL.MIME_HEADER('application/json', TRUE)` for content type
- Use `HTP.P(l_json_output)` to output response

#### Arrays in GET Responses
**Issue**: Empty arrays may return `null` with `json/collection`, but `[]` with `plsql/block`.

**When consistency matters**, use `plsql/block` to ensure `[]` for empty arrays.

#### Bind Variables
Common bind variables in handlers:
- `:body_text` - Request body (CLOB)
- `:current_user` - OAuth client ID
- `:status_code` - Output HTTP status
- `:P_TOKEN` - Custom header parameter (x-ad-token)
- `:request_id` - Request tracing ID

### 10. Duplication Prevention

**MANDATORY: Verify OpenAPI Catalog FIRST**

Before creating any new endpoint, **ALWAYS** validate against the OpenAPI catalog:

**Endpoint**: `https://infoplan-web-dev.humano.local/ords/infoplan/open-api-catalog/{domain}`

**Examples**:
- `/open-api-catalog/configuracion/api/v1/`
- `/open-api-catalog/personas/api/v1/`
- `/open-api-catalog/polizas/api/v1/`
- `/open-api-catalog/facturacion/api/v1/`
- `/open-api-catalog/autorizaciones/api/v1/`

**Required steps**:

1. ✅ **FIRST**: Query OpenAPI catalog for the target domain
2. ✅ **REVIEW**: Analyze existing endpoints in the response
3. ✅ **NOTIFY USER**: If any endpoint can be reused or already exists, **ALWAYS inform the user** with:
   - Existing endpoint URI
   - HTTP method
   - Purpose/functionality
   - Recommendation (reuse vs. create new)
4. ✅ If exists but "returns too much", create minimalist listing
5. ✅ Reuse existing business procedures
6. ❌ DO NOT duplicate logic
7. ❌ DO NOT create "similar" endpoints with different contracts

**User notification format** (when reusable endpoints found):
```
⚠️ ENDPOINTS EXISTENTES ENCONTRADOS:

1. GET /configuracion/api/v1/paises
   - Propósito: Listado de países
   - Recomendación: Reutilizar si necesita el mismo recurso
   
2. GET /configuracion/api/v1/paises/{codigo}
   - Propósito: Detalle de país por código
   - Recomendación: Reutilizar para consultas individuales

¿Desea proceder con la creación del nuevo endpoint o prefiere reutilizar alguno existente?
```

**Separate listing vs detail**:
- `GET /.../recursos` → minimalist (LOV)
- `GET /.../recursos/{codigo}` → complete (detail)

### 11. Legacy Procedures (*_ORDS)

For existing procedures that already return `p_status_code` and `p_body`:

```plsql
-- Handler only re-exposes
DECLARE
  v_body CLOB;
  v_status_code NUMBER;
BEGIN
  -- Read body
  v_body := :body;
  
  -- Call procedure
  SCHEMA.P_PROCESO_ORDS(
    p_json => v_body,
    p_status_code => v_status_code,
    p_body => v_body
  );
  
  -- Re-expose
  :status_code := v_status_code;
  htp.p(v_body);
END;
```

### 12. Pre-Delivery Checklist

Before creating a pull request, verify:

- [ ] **Validated against OpenAPI catalog** - Checked for existing endpoints that can be reused
- [ ] Correct URI: `/{dominio}/api/v1/{recursos_plural}`
- [ ] JSON in strict `snake_case`
- [ ] PKs with `codigo_`, sequences with `secuencial_<tabla>`
- [ ] GET collection: "Collection query", no 400
- [ ] GET by code: PL/SQL handler with validations
- [ ] POST/PUT/DELETE: handler + separate procedures
- [ ] Token: `:p_token` → `jwt_utils.get_username()`
- [ ] `request-id` supported and returned
- [ ] Audit on UPDATE/DELETE
- [ ] Response with `F_GENERAR_RESPUESTA_ESTANDAR`
- [ ] Correct HTTP codes (400/404/409/422/500)
- [ ] All attributes validated against `data_dictionary.md`

## Application Examples

### Example 1: GET Collection (Countries)
```
Route: GET /configuracion/api/v1/paises
Type: Collection query
Headers: Authorization (no x-ad-token)
Response: Automatic ORDS pagination
```

### Example 2: GET by Code (Client)
```
Route: GET /personas/api/v1/clientes/{codigo}
Type: PL/SQL Handler
Headers: Authorization, request-id, x-ad-token
Errors: 400 (invalid code), 404 (does not exist), 500
```

### Example 3: POST Create (Authorization)
```
Route: POST /autorizaciones/api/v1/autorizaciones
Headers: Authorization, x-ad-token, Content-Type, request-id
Payload: JSON snake_case (no codigo, no estatus)
Procedures: P_VALIDAR_AUTORIZACION, P_CREAR_AUTORIZACION
Response: 201 + created object
```

### Example 4: PUT Update (Coverage)
```
Route: PUT /productos/api/v1/coberturas/{codigo}
Rules: Only sent fields, codigo is not updated
Audit: Mandatory
Response: 204 No Content
```

## References

- Complete guide: `Infoplan-Web.wiki/Guía-de-Estándares-y-Diseño-de-Servicios-REST-(ORDS-–-Infoplan-Web).md`
- Data dictionary: `docs/data_dictionary.md`
- Naming rules: `.github/instructions/diccionario_rules.instructions.md`

## Commit Commands

All commits must be in Spanish, descriptive and clear:

✅ `feat: agregar endpoint GET para buscar coberturas por cliente`
✅ `fix: corregir validación de código en endpoint de autorizaciones`
✅ `refactor: estandarizar respuesta JSON a snake_case en proveedores`

❌ `update api`
❌ `fix bug`
