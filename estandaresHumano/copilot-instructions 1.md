# Oracle PL/SQL Development Guidelines for ORDS

## Overview

This document covers **PL/SQL procedure and function patterns** for Oracle ORDS APIs. For REST API standards, handler patterns, and endpoint design, see [instructions/rest-api-estandarizacion.instructions.md](instructions/rest-api-estandarizacion.instructions.md).

## Project Schemas

- **`DBAPER`** - Shared utilities (`F_GENERAR_RESPUESTA_ESTANDAR`, `F_USUARIO_ORDS_USER`, `P_LOG_ORDS`)
- **`POLIZAS`** - Policy and coverage business logic
- **`FACTURACION`** - Billing/invoicing procedures
- **`CONFIGURACION`** - Cross-cutting catalog procedures  
- **`SUSCRIPCION`** - Entry/subscription operations

## JSON Conventions

All JSON attributes use strict `snake_case`:
- PKs: `codigo_` prefix (`codigo_cliente`, `codigo_plan`)
- Sequences: `secuencial_<table>` (`secuencial_poliza`)
- Booleans: `es_`, `tiene_`, `debe_`, `aplica_` prefixes
- Dates: ISO 8601 `YYYY-MM-DD` or `YYYY-MM-DDTHH24:MI:SSZ`
- Audit fields: `creado_en`, `actualizado_en` suffixes

## PL/SQL Conventions

### Error Handling Hierarchy

Procedures use custom exceptions with HTTP status code mapping:

```sql
-- Exception declarations
EXC_VALIDACION  EXCEPTION;  -- 400 Bad Request
EXC_NEGOCIO     EXCEPTION;  -- 422 Unprocessable Entity
-- OTHERS                   -- 500 Internal Server Error

-- Standard status codes
c_status_ok            := 201;  -- Success (note: 201 not 200)
c_status_bad_request   := 400;  -- Validation errors
c_status_unprocessable := 422;  -- Business rule violations
c_status_error         := 500;  -- System errors
```

### Standardized Response Format

**Always** use `DBAPER.F_GENERAR_RESPUESTA_ESTANDAR()` for responses:

```sql
-- Success response
P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
    p_tipo_respuesta => 'success',
    p_data           => V_DATA_RESPONSE,
    p_request_id     => V_REQUEST_ID
);

-- Validation error
P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
    p_tipo_respuesta => 'validation',
    p_validations    => JSON_ARRAY_T('[{"field":"parametros","message":"..."}]'),
    p_request_id     => V_REQUEST_ID
);

-- Business error
P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
    p_tipo_respuesta => 'business',
    p_error_detail   => V_MSG_ERROR,
    p_error_title    => 'Error en proceso de facturación',
    p_status_code    => 422,
    p_request_id     => V_REQUEST_ID
);
```

### Request ID Traceability
Generate unique request IDs for all operations:
```sql
V_REQUEST_ID := SYS_GUID();
```

### JSON Parsing Pattern

Use Oracle's native JSON types (19c+):

**Method 1: JSON_OBJECT_T** (for simple parsing):
```sql
V_JSON_OBJ := JSON_OBJECT_T.PARSE(P_PARAMETROS);

-- Required fields
V_PARAMS.COMPANIA := V_JSON_OBJ.GET_NUMBER('codigo_compania');
V_PARAMS.RAMO := V_JSON_OBJ.GET_NUMBER('codigo_ramo');

-- Optional fields (check existence first)
IF V_JSON_OBJ.HAS('fecha_facturacion') THEN
    V_PARAMS.FEC_FAC := TO_DATE(V_JSON_OBJ.GET_STRING('fecha_facturacion'), 'YYYY-MM-DD');
END IF;
```

**Method 2: JSON_TABLE with CURSOR** (for complex/multiple record parsing):
```sql
CURSOR cur_parametros IS
    SELECT 
        compania, ramo, secuencial, plan, tipo_afi
    FROM JSON_TABLE(P_PARAMETROS, '$' COLUMNS (
        compania NUMBER PATH '$.codigo_compania',
        ramo NUMBER PATH '$.codigo_ramo',
        secuencial NUMBER PATH '$.secuencial_poliza',
        plan NUMBER PATH '$.codigo_plan',
        tipo_afi VARCHAR2(50) PATH '$.tipo_afiliado'
    ));
```

**Choose JSON_TABLE when**:
- Parsing multiple records
- Complex nested structures
- Using cursors for organized data flow

### Date Format Convention
Always use **ISO 8601** format (`YYYY-MM-DD`) for date fields in JSON

### Composite ID Parsing in Procedures

For procedures receiving composite IDs with compound primary keys:

**Format**: `{numero_poliza}_{plan}_{tipo_afi}_{afiliado}_{servicio}_{fecha_version}`

**Parsing**:
```sql
l_parts := APEX_STRING.SPLIT(l_id_compuesto, '_');
IF l_parts.COUNT <> 6 THEN
    RAISE e_formato_invalido;
END IF;
l_numero_poliza := l_parts(1);  -- "1-3-12345"
l_plan := TO_NUMBER(l_parts(2)); -- 101
```

### Orchestrator Pattern: Smart UPDATE vs INSERT

For entities with versioned fields, use `P_ORQUESTAR_*` procedures to intelligently route operations:

**Pattern**: Orchestrator determines action based on which fields changed
```sql
PROCEDURE P_ORQUESTAR_<ENTITY>_ORDS (
    P_PARAMETROS  IN  CLOB,
    P_REQUEST_ID  IN  VARCHAR2,
    P_STATUS_CODE OUT NUMBER,
    P_BODY        OUT CLOB,
    P_ERROR       OUT VARCHAR2
)
```

**Logic Flow**:
1. Fetch current version
2. Detect which fields changed (versioned vs non-versioned)
3. Route appropriately:
   - Only non-versioned fields changed → Call `P_ACTUALIZAR_*` (UPDATE in place)
   - Any versioned field changed → Call `P_CREAR_*` (INSERT new version)
   - No changes → Return 422 error

**Example** (see [../poliza-planes/mantenimiento-provedor/procedures/P_ORQUESTAR_POLIZA_PROVEDOR.prc](../poliza-planes/mantenimiento-provedor/procedures/P_ORQUESTAR_POLIZA_PROVEDOR.prc)):

**Versioned fields** (require new version):
- `codigo_categoria_proveedor`, `monto_contractual`, `prima`, `formula_aplicacion`, `estatus`

**Non-versioned fields** (update in place):
- `impresion_carnet`, `comentario`

**Special handling**: Prima changes trigger audit in `APROB_PRIMA_POL_PRO` table before versioning.

### Bitácora (Audit Trail) Pattern (if applicable)

For UPDATE operations that change critical fields, record before/after snapshots:

```sql
PROCEDURE P_REGISTRAR_BITACORA(
    p_parametros    IN t_parametros,
    p_version_act   IN t_version_actual,
    p_nueva_fec_ver IN DATE DEFAULT NULL
) IS
    v_json_valores_anteriores CLOB;
    v_json_valores_nuevos CLOB;
BEGIN
    -- Build before/after JSON
    v_json_valores_anteriores := JSON_OBJECT(
        'codigo_categoria_proveedor' VALUE p_version_act.cat_pro,
        'prima' VALUE p_version_act.prima,
        ...
    );
    
    -- Insert into bitacora table
    POLIZAS.P_INSERTAR_BITACORA_<TABLE>(
        P_VALORES_ANTERIORES => json_object_t.parse(v_json_valores_anteriores),
        P_VALORES_NUEVOS     => json_object_t.parse(v_json_valores_nuevos)
    );
END;
```

**Call bitácora BEFORE update/insert** to ensure audit trail even if operation fails.

### Procedure Signature Pattern

ORDS-exposed procedures must follow this signature:

```sql
PROCEDURE P_<NAME>_ORDS (
    P_PARAMETROS  IN  CLOB,          -- JSON request body
    P_STATUS_CODE OUT NUMBER,        -- HTTP status code
    P_BODY        OUT CLOB,          -- JSON response body
    P_ERROR       OUT VARCHAR2       -- Error message summary
)
```

**Advanced pattern for orchestrators**:
```sql
PROCEDURE P_ORQUESTAR_<ENTITY>_ORDS (
    P_PARAMETROS  IN  CLOB,
    P_REQUEST_ID  IN  VARCHAR2,      -- Explicit request ID
    P_STATUS_CODE OUT NUMBER,
    P_BODY        OUT CLOB,
    P_ERROR       OUT VARCHAR2
)
```

**Use TYPE for structured data**:
```sql
-- Record types for clean parameter handling
TYPE t_parametros IS RECORD (
    compania   NUMBER,
    ramo       NUMBER,
    secuencial NUMBER,
    ...
);

TYPE t_version_actual IS RECORD (
    cat_pro    NUMBER,
    mon_con    NUMBER,
    prima      NUMBER,
    ...
);

v_registro       t_parametros;
v_version_actual t_version_actual;
```

### Nested Functions Pattern

Use local functions within procedures for better organization:

```sql
PROCEDURE P_ORQUESTAR_ENTITY_ORDS(...) IS
    -- Variables and types
    ...
    
    -- Local function: Business logic encapsulation
    FUNCTION F_REQUIERE_VERSIONAMIENTO(
        p_parametros  IN t_parametros,
        p_version_act IN t_version_actual
    ) RETURN BOOLEAN IS
        v_requiere BOOLEAN := FALSE;
    BEGIN
        IF p_parametros.prima IS NOT NULL AND 
           NVL(p_parametros.prima, -999) != NVL(p_version_act.prima, -999) THEN
            v_requiere := TRUE;
        END IF;
        RETURN v_requiere;
    END F_REQUIERE_VERSIONAMIENTO;
    
    -- Local procedure: Audit trail handling
    PROCEDURE P_REGISTRAR_BITACORA(...) IS
    BEGIN
        -- Build audit JSON and insert
        ...
    END P_REGISTRAR_BITACORA;
    
BEGIN
    -- Main procedure logic uses local functions
    IF F_REQUIERE_VERSIONAMIENTO(v_registro, v_version_actual) THEN
        P_REGISTRAR_BITACORA(...);
        -- Route to CREATE
    END IF;
END P_ORQUESTAR_ENTITY_ORDS;
```

**Benefits**:
- Encapsulates complex logic
- Improves readability
- Avoids polluting schema with utility procedures
- Keeps related code together

## SQL Security: Preventing SQL Injection

### Critical Rule: NEVER Use String Concatenation for SQL

**VULNERABLE PATTERN** ❌ (DO NOT USE):
```sql
-- Building SQL via string concatenation
v_set_clause := v_set_clause || 'PRIMA = ' || v_parametros.prima || ', ';
v_set_clause := v_set_clause || 'FOR_APL = ''' || v_parametros.formula || ''', ';
v_sql_update := 'UPDATE TABLE SET ' || v_set_clause || ' WHERE ...';
EXECUTE IMMEDIATE v_sql_update USING ...;
```

**Why this is dangerous**:
- User input is concatenated directly into SQL string
- SQL structure can be modified by malicious payloads
- `REPLACE()` for quotes is insufficient protection
- Examples of attacks:
  - `"prima": "100; DELETE FROM POLIZA WHERE '1'='1"`
  - `"formula": "x' || (SELECT password FROM usuarios) || 'y"`
  - `"comentario": "test''; DROP TABLE poliza; --"`

### SECURE PATTERN ✅ (ALWAYS USE THIS):

**Static UPDATE with CASE WHEN**:
```sql
-- Extract values (NO concatenation)
IF v_json_obj.has('prima') THEN
    v_parametros.prima := v_json_obj.get_number('prima');
    v_contador := v_contador + 1;
END IF;

IF v_json_obj.has('formula_aplicacion') THEN
    v_parametros.formula_aplicacion := v_json_obj.get_string('formula_aplicacion');
    v_contador := v_contador + 1;
END IF;

-- Static UPDATE (compiled SQL structure)
UPDATE DBAPER.TABLE_NAME
   SET PRIMA = CASE WHEN v_json_obj.has('prima') 
                    THEN v_parametros.prima        -- ✅ Implicit bind variable
                    ELSE PRIMA END,
       FOR_APL = CASE WHEN v_json_obj.has('formula_aplicacion') 
                      THEN v_parametros.formula_aplicacion  -- ✅ Safe string
                      ELSE FOR_APL END,
       COMENT = CASE WHEN v_json_obj.has('comentario') 
                     THEN v_parametros.comentario          -- ✅ No REPLACE needed
                     ELSE COMENT END,
       FEC_ACTUALIZO = SYSDATE,
       USR_ACTUALIZO = v_usuario
 WHERE COMPANIA = v_parametros.codigo_compania
   AND RAMO = v_parametros.codigo_ramo
   AND SECUENCIAL = v_parametros.secuencial;
```

**Why this is secure**:
- SQL structure is **hardcoded** at compile time
- PL/SQL variables are treated as **implicit bind variables**
- User input can ONLY affect data values, NEVER SQL structure
- Oracle validates types automatically (NUMBER must be NUMBER, etc.)
- No special escaping needed - Oracle handles it

### Security Advantages

| Aspect | Concatenation (Vulnerable) | Static with CASE WHEN (Secure) |
|--------|---------------------------|--------------------------------|
| SQL Structure | Dynamic (runtime) | Fixed (compile time) |
| User Input | Can modify structure | Can only modify data |
| Type Validation | Weak | Strong (compile time) |
| Escape Handling | Manual (error-prone) | Automatic (Oracle) |
| Attack Surface | High | Zero |
| Performance | Equal | Equal |
| Maintainability | Low | High |

### Reference Implementations

**Secure examples in project**:
- ✅ `polizas/procedures/P_ACTUALIZAR_POLIZA_ORDS.prc` - 8 fields, zero vulnerabilities
- ✅ `poliza-planes/mantenimiento-provedor/procedures/P_ACTUALIZAR_POLIZA_PROVEDOR.prc` - Refactored 2026-02-26

**Security analysis documents**:
- `polizas/ANALISIS-SEGURIDAD-SQL.md` - Complete vulnerability analysis
- `poliza-planes/mantenimiento-provedor/REFACTORIZACION-SEGURIDAD-SQL.md` - Before/after comparison

### Finding Vulnerable Code

Search project for these patterns:
```bash
# Find EXECUTE IMMEDIATE with concatenation
grep -r "EXECUTE IMMEDIATE.*||" *.prc

# Find SQL building with concatenation
grep -r "v_sql.*||.*v_" *.prc

# Find SET clause concatenation
grep -r "v_set_clause.*||" *.prc
```

**If found**: Refactor using static UPDATE with CASE WHEN pattern immediately.

## Dynamic UPDATE Optimization: Avoiding Unnecessary Triggers

### Problem Statement

Standard PATCH operations using `CASE WHEN` pattern execute UPDATE statement even when submitted values are identical to current database values. This causes:

- ❌ Unnecessary trigger execution (PRE/POST UPDATE)
- ❌ Audit log pollution with "non-changes"
- ❌ External system notifications for unchanged data
- ❌ Database write operations with no actual modifications
- ❌ Lock contention on frequently accessed records

### Solution: Real Change Detection

**Pattern**: Fetch current values BEFORE executing UPDATE, compare with submitted values, and skip UPDATE if no real changes detected.

### Implementation Pattern

**Step 1: Define TYPE for Current Values**
```sql
TYPE t_valores_actuales IS RECORD (
    numero_cuenta           VARCHAR2(30),
    imprime_factura         VARCHAR2(1),
    mail_cliente            VARCHAR2(1),
    -- ... all updatable fields
);

v_valores_actuales  t_valores_actuales;
v_hay_cambios       BOOLEAN := FALSE;
```

**Step 2: Fetch Current Values After Validation**
```sql
-- After validating existence, fetch all updatable fields
BEGIN
    SELECT NUM_CTA,
           IMPRIME_FACTURA,
           MAIL_CLI,
           -- ... all updatable fields
      INTO v_valores_actuales.numero_cuenta,
           v_valores_actuales.imprime_factura,
           v_valores_actuales.mail_cliente,
           -- ...
      FROM DBAPER.TABLE
     WHERE <PK conditions>;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE exc_negocio;
END;
```

**Step 3: Extract Fields with Real Change Detection**
```sql
v_contador := 0;
v_hay_cambios := FALSE;

IF v_json_obj.HAS('numero_cuenta') THEN
    v_parametros.numero_cuenta := v_json_obj.GET_STRING('numero_cuenta');
    v_contador := v_contador + 1;
    
    -- Compare with current value
    IF NVL(v_parametros.numero_cuenta, 'NULL') != 
       NVL(v_valores_actuales.numero_cuenta, 'NULL') THEN
        v_hay_cambios := TRUE;
    END IF;
END IF;

-- Repeat for all updatable fields...

IF v_contador = 0 THEN
    v_msg_error := 'Debe especificar al menos un campo para actualizar';
    RAISE exc_negocio;
END IF;
```

**Step 4: Early Return if No Real Changes**
```sql
-- CRITICAL: Skip UPDATE if no actual changes detected
IF NOT v_hay_cambios THEN
    P_STATUS_CODE := 204;
    
    IF v_validations.GET_SIZE() > 0 THEN
        P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            P_TIPO_RESPUESTA => 'success',
            P_DATA           => JSON_OBJECT_T('{
                "message": "Registro actualizado exitosamente",
                "info": "No se detectaron cambios en los valores proporcionados"
            }'),
            P_VALIDATIONS    => v_validations,
            P_REQUEST_ID     => P_REQUEST_ID
        );
    ELSE
        P_BODY := NULL;
    END IF;
    
    P_ERROR := NULL;
    RETURN;  -- Exit without executing UPDATE or triggering any side effects
END IF;

-- UPDATE only executes if v_hay_cambios = TRUE
UPDATE TABLE SET ... ;
```

**Step 5: Standard Secure UPDATE**
```sql
-- Execute secure static UPDATE (only if real changes exist)
UPDATE DBAPER.TABLE
   SET CAMPO1 = CASE WHEN v_json_obj.HAS('campo1')
                     THEN v_parametros.campo1  -- Bind variable
                     ELSE CAMPO1 END,
       -- ... all fields with CASE WHEN
       FEC_ACTUALIZO = SYSDATE,
       USR_ACTUALIZO = v_usuario
 WHERE <PK conditions>;
```

### Benefits

| Aspect | Standard PATCH | Optimized with Change Detection |
|--------|----------------|--------------------------------|
| SELECT queries | 1 (existence check) | 2 (existence + current values) |
| UPDATE execution | Always | Only if changes detected |
| Trigger execution | Always | Only if changes detected |
| Audit field updates | Always | Only if changes detected |
| Network latency | Normal | Slightly higher (+1 SELECT) |
| Database writes | Always | Only when necessary |
| Audit log accuracy | Low (includes non-changes) | High (only real changes) |
| External notifications | Always | Only when necessary |
| **Overall performance** | Good | **Better** (when no changes) |

### When to Use This Pattern

**Use optimization when**:
- ✅ Table has expensive triggers (audit logging, external notifications)
- ✅ Autosave scenarios (frequent saves without changes)
- ✅ UI sends requests even when user doesn't modify values
- ✅ Precise audit trail required for compliance
- ✅ Integration with external systems on UPDATE
- ✅ High-traffic endpoints with concurrent updates

**Skip optimization when**:
- ❌ Table has no triggers
- ❌ Simplicity is more important than performance
- ❌ All requests genuinely modify data
- ❌ Small tables with minimal impact
- ❌ Extra SELECT overhead is concern

### NULL Value Handling

**Robust comparison using NVL**:
```sql
IF NVL(v_parametros.campo, 'NULL') != NVL(v_valores_actuales.campo, 'NULL') THEN
    v_hay_cambios := TRUE;
END IF;
```

**Covers all cases**:
- ✅ `NULL` → `NULL`: Not a change
- ✅ `NULL` → `'value'`: Is a change
- ✅ `'value'` → `NULL`: Is a change  
- ✅ `'value'` → `'value'`: Not a change
- ✅ `'value'` → `'other'`: Is a change

### Reference Implementation

**Optimized example**:
- ✅ `polizas/procedures/P_ACTUALIZAR_POLIZA_ORDS.prc` - Full optimization with change detection

**Standard example** (without optimization):
- ✅ `poliza-planes/mantenimiento-provedor/procedures/P_ACTUALIZAR_POLIZA_PROVEDOR.prc` - Secure but executes UPDATE always

**Comparison document**:
- `polizas/COMPARACION-PROVEDOR-VS-ORDS.md` - Detailed analysis of both patterns

### Trade-offs

**Added complexity**:
- +1 TYPE definition
- +2 variables (`v_valores_actuales`, `v_hay_cambios`)
- +1 SELECT query
- +N comparison blocks (one per field)
- +1 early return block
- ~30-40% more code

**Performance gains**:
- ⚡ 50-100ms saved per "no-change" UPDATE
- ⚡ Zero trigger execution when no changes
- ⚡ Reduced database write load
- ⚡ More accurate audit trails
- ⚡ 80-90% reduction in unnecessary UPDATEs (typical UI autosave scenario)

**Decision guideline**: If >20% of UPDATE requests have no real changes, optimization is worthwhile.

## Versioned Table Update Pattern

### Overview

For tables that maintain historical versions (temporal tables), implement a **smart orchestrator** that determines whether to UPDATE the current record or INSERT a new version based on which fields changed.

### Field Classification

**Critical step**: Classify all table fields into two categories:

**Versioned Fields** - Changes require new version (INSERT):
- Business-critical data that must be tracked historically
- Fields that impact contracts, pricing, or legal obligations
- Examples: `prima`, `monto_contractual`, `codigo_categoria_proveedor`, `formula_aplicacion`, `estatus`

**Non-Versioned Fields** - Changes update current record (UPDATE):
- Administrative or UI-related fields
- Comments, flags, or display preferences
- Examples: `impresion_carnet`, `comentario`, `incluir_proceso_aumento`

### Implementation Pattern

**Step 1: Define Record Types**
```sql
TYPE t_version_actual IS RECORD (
    -- All current version fields
    cat_pro                    NUMBER,
    mon_con                    NUMBER,
    prima                      NUMBER,
    for_apl                    VARCHAR2(4000),
    estatus                    NUMBER,
    fec_ver                    DATE,
    impresion_carnet           VARCHAR2(5),
    comentario                 VARCHAR2(4000)
);

TYPE t_parametros IS RECORD (
    -- All input parameters from JSON
    compania                   NUMBER,
    -- ... other PK fields
    codigo_categoria_proveedor NUMBER,
    monto_contractual          NUMBER,
    prima                      NUMBER,
    -- ... etc
);
```

**Step 2: Create Local Detection Function**
```sql
FUNCTION F_REQUIERE_VERSIONAMIENTO(
    p_parametros  IN t_parametros,
    p_version_act IN t_version_actual
) RETURN BOOLEAN IS
    v_requiere BOOLEAN := FALSE;
BEGIN
    -- Check each VERSIONED field
    IF p_parametros.prima IS NOT NULL AND 
       NVL(p_parametros.prima, -999) != NVL(p_version_act.prima, -999) THEN
        v_requiere := TRUE;
    END IF;
    
    IF p_parametros.monto_contractual IS NOT NULL AND 
       NVL(p_parametros.monto_contractual, -999) != NVL(p_version_act.mon_con, -999) THEN
        v_requiere := TRUE;
    END IF;
    
    -- Add checks for all versioned fields
    
    RETURN v_requiere;
END F_REQUIERE_VERSIONAMIENTO;
```

**Step 3: Detect Non-Versioned Changes**
```sql
v_cambios_no_versionados := FALSE;

IF v_registro.impresion_carnet IS NOT NULL AND 
   NVL(v_registro.impresion_carnet, 'NULL') != NVL(v_version_actual.impresion_carnet, 'NULL') THEN
    v_cambios_no_versionados := TRUE;
END IF;

IF v_registro.comentario IS NOT NULL AND 
   NVL(v_registro.comentario, 'NULL') != NVL(v_version_actual.comentario, 'NULL') THEN
    v_cambios_no_versionados := TRUE;
END IF;
```

**Step 4: Route Based on Detection**
```sql
v_cambios_versionados := F_REQUIERE_VERSIONAMIENTO(v_registro, v_version_actual);

-- Scenario 1: No changes
IF NOT v_cambios_versionados AND NOT v_cambios_no_versionados THEN
    v_msg_error := 'No se detectaron cambios en los campos proporcionados';
    RAISE exc_negocio;  -- 422
END IF;

-- Scenario 2: Only non-versioned fields changed → UPDATE
IF v_cambios_no_versionados AND NOT v_cambios_versionados THEN
    P_REGISTRAR_BITACORA(v_registro, v_version_actual);
    POLIZAS.P_ACTUALIZAR_<ENTITY>(
        P_PARAMETROS  => P_PARAMETROS,
        P_REQUEST_ID  => P_REQUEST_ID,
        P_STATUS_CODE => P_STATUS_CODE,
        P_BODY        => P_BODY,
        P_ERROR       => P_ERROR
    );
    IF P_STATUS_CODE != 204 THEN
        RETURN;
    END IF;
END IF;

-- Scenario 3: Versioned fields changed → INSERT new version
IF v_cambios_versionados THEN
    -- Determine version date (must be first day of month)
    v_nueva_fecha_version := CASE 
        WHEN v_registro.fecha_version IS NOT NULL 
        THEN v_registro.fecha_version
        ELSE TRUNC(SYSDATE, 'MM')
    END;
    
    -- Validate first day of month
    IF TO_CHAR(v_nueva_fecha_version, 'DD') != '01' THEN
        RAISE exc_negocio;
    END IF;
    
    -- Special handling: Prima audit (if applicable)
    IF v_registro.prima != v_version_actual.prima THEN
        INSERT INTO DBAPER.APROB_PRIMA_<TABLE> (...)
        VALUES (...);
    END IF;
    
    -- Create new version
    POLIZAS.P_CREAR_<ENTITY>_ORDS(
        P_PARAMETROS  => P_PARAMETROS,
        P_REQUEST_ID  => P_REQUEST_ID,
        P_STATUS_CODE => P_STATUS_CODE,
        P_BODY        => P_BODY,
        P_ERROR       => P_ERROR
    );
END IF;
```

### Version Date Rules

**MANDATORY**: Version dates must be the **first day of the month** (YYYY-MM-01)

```sql
-- If client provides fecha_version
IF v_registro.fecha_version IS NOT NULL THEN
    v_nueva_fecha_version := v_registro.fecha_version;
    
    -- Validate first day
    IF TO_CHAR(v_nueva_fecha_version, 'DD') != '01' THEN
        v_msg_error := 'La fecha de versión debe ser el primer día del mes (formato: YYYY-MM-01)';
        RAISE exc_negocio;  -- 422
    END IF;
ELSE
    -- Default: First day of current month
    v_nueva_fecha_version := TRUNC(SYSDATE, 'MM');
END IF;
```

### Special Audit Handling

For critical field changes (like `prima`), register in approval audit table **before** creating new version:

```sql
IF v_registro.prima != v_version_actual.prima THEN
    BEGIN
        INSERT INTO DBAPER.APROB_PRIMA_<TABLE> (
            COMPANIA, RAMO, SECUENCIAL, ...,
            FEC_VER, PRIMA, PRIMA_ANT, COMENTARIO_APROBACION,
            FEC_TRA, USUARIO
        ) VALUES (
            v_registro.compania, ...,
            v_nueva_fecha_version,
            v_registro.prima,  -- New value
            v_version_actual.prima,  -- Old value
            v_registro.comentario_aprobacion,
            SYSDATE,
            v_usuario
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            -- If exists, update instead
            UPDATE DBAPER.APROB_PRIMA_<TABLE>
               SET PRIMA = v_registro.prima,
                   PRIMA_ANT = v_version_actual.prima,
                   ...
             WHERE <PK_CONDITIONS>;
    END;
END IF;
```

### Query Current Version Pattern

Always fetch the **latest version** using MAX(FEC_VER):

```sql
CURSOR cur_ultima_version(p_compania NUMBER, p_ramo NUMBER, ...) IS
    SELECT cat_pro, mon_con, prima, for_apl, estatus, fec_ver,
           impresion_en_carnet, coment, incluir_proceso_aumento
      FROM DBAPER.<TABLE> a
     WHERE COMPANIA = p_compania
       AND RAMO = p_ramo
       -- ... other PK conditions
       AND FEC_VER = (
            SELECT MAX(FEC_VER)
              FROM DBAPER.<TABLE> b
             WHERE b.COMPANIA = a.COMPANIA
               AND b.RAMO = a.RAMO
               -- ... match all PK fields except FEC_VER
       );
```

### Complete Orchestrator Structure

```sql
PROCEDURE P_ORQUESTAR_<ENTITY>_ORDS (
    P_PARAMETROS  IN  CLOB,
    P_REQUEST_ID  IN  VARCHAR2,
    P_STATUS_CODE OUT NUMBER,
    P_BODY        OUT CLOB,
    P_ERROR       OUT VARCHAR2
) IS
    -- Type definitions
    TYPE t_version_actual IS RECORD (...);
    TYPE t_parametros IS RECORD (...);
    
    -- Variables
    v_registro t_parametros;
    v_version_actual t_version_actual;
    v_cambios_versionados BOOLEAN := FALSE;
    v_cambios_no_versionados BOOLEAN := FALSE;
    
    -- Cursors
    CURSOR cur_parametros IS
        SELECT ... FROM JSON_TABLE(P_PARAMETROS ...);
    
    CURSOR cur_ultima_version(...) IS
        SELECT ... WHERE ... AND FEC_VER = (SELECT MAX(FEC_VER) ...);
    
    -- Local functions
    FUNCTION F_REQUIERE_VERSIONAMIENTO(...) RETURN BOOLEAN IS
    BEGIN
        -- Check versioned fields
    END;
    
    PROCEDURE P_REGISTRAR_BITACORA(...) IS
    BEGIN
        -- Create audit trail
    END;
    
BEGIN
    -- 1. Parse JSON
    OPEN cur_parametros;
    FETCH cur_parametros INTO v_registro;
    CLOSE cur_parametros;
    
    -- 2. Get current version
    OPEN cur_ultima_version(...);
    FETCH cur_ultima_version INTO v_version_actual;
    IF cur_ultima_version%NOTFOUND THEN
        RAISE NO_DATA_FOUND;  -- 404
    END IF;
    CLOSE cur_ultima_version;
    
    -- 3. Detect changes
    v_cambios_versionados := F_REQUIERE_VERSIONAMIENTO(...);
    -- Check non-versioned fields...
    
    -- 4. Route based on changes
    IF NOT v_cambios_versionados AND NOT v_cambios_no_versionados THEN
        RAISE exc_negocio;  -- No changes
    ELSIF v_cambios_no_versionados AND NOT v_cambios_versionados THEN
        -- Call P_ACTUALIZAR_*
    ELSIF v_cambios_versionados THEN
        -- Call P_CREAR_* with special handling
    END IF;
    
EXCEPTION
    WHEN exc_negocio THEN
        P_STATUS_CODE := 422;
        -- Generate error response
    WHEN NO_DATA_FOUND THEN
        P_STATUS_CODE := 404;
        -- Generate not found response
END;
```

### Key Advantages

1. **Automatic routing** - Developer doesn't choose UPDATE vs INSERT
2. **Historical integrity** - Never loses critical data history
3. **Performance** - UPDATE for non-critical changes avoids unnecessary versions
4. **Audit compliance** - All changes tracked appropriately
5. **Flexibility** - Easy to reclassify fields by moving between detection logic

### Reference Implementation

See [../poliza-planes/mantenimiento-provedor/procedures/P_ORQUESTAR_POLIZA_PROVEDOR.prc](../poliza-planes/mantenimiento-provedor/procedures/P_ORQUESTAR_POLIZA_PROVEDOR.prc) for complete working example.

## Database Utilities and Logging

### Available Utility Functions

The `DBAPER` schema provides the following core utilities for PL/SQL procedures:

- **`F_GENERAR_RESPUESTA_ESTANDAR`** - Standardized JSON response generator
- **`P_LOG_ORDS`** - Request logging for audit trails
- **`P_LOG_ERROR`** - Error logging with context information
- **`F_USUARIO_ORDS_USER`** - Retrieve current authenticated user

**Usage examples**:

```sql
-- Request logging
DBAPER.P_LOG_ORDS('P_FACTURAR_POLIZA_ORDS', P_PARAMETROS);

-- Error logging with context
DBAPER.P_LOG_ERROR(
    'FACTURACION.P_FACTURAR_POLIZA_ORDS',
    'Datos: P_COMPANIA ' || V_PARAMS.COMPANIA || ' | Error: ' || SQLERRM
);

-- Get authenticated user
v_usuario := SUBSTR(DBAPER.F_USUARIO_ORDS_USER, 1, 30);
```

## Advanced PL/SQL Patterns

### Business Logic Procedure Pattern

Business procedures return status via OUT parameters (not exceptions):

```sql
FACTURACION.P_VALIDAR_PARAMS_FACTURACION(
    P_PARAMETROS => P_PARAMETROS,
    P_OK         => V_OK,          -- BOOLEAN success flag
    P_MSG_ERROR  => V_MSG_ERROR    -- Error message if P_OK = FALSE
);

IF NOT V_OK THEN
    RAISE EXC_VALIDACION;
END IF;
```

### Validation Framework

Two validation approaches are available:

**1. Simple validation** (for billing processes):
```sql
FACTURACION.P_VALIDAR_PARAMS_FACTURACION(...)
```

**2. Three-level validation** (for complex CRUD operations):

Uses `P_VALIDAR_*` procedures with `P_ALCANCE` parameter supporting:

```sql
-- Validation scope levels
p_alcance => 'FIELD'     -- Individual field validation (format, type)
p_alcance => 'FORM'      -- Form-level validation (existence checks)
p_alcance => 'BUSINESS'  -- Business rule validation (permissions, state)
p_alcance => 'ALL'       -- All validations in sequence: FIELD → FORM → BUSINESS

-- Example usage
POLIZAS.P_VALIDAR_POLIZA_PLAN_PROVEDOR(
    P_OPERACION   => 'CREATE',  -- CREATE, UPDATE, DELETE
    P_PARAMETROS  => P_PARAMETROS,
    P_VALIDATIONS => v_validations,  -- OUT JSON_ARRAY_T
    P_OK          => v_ok,           -- OUT BOOLEAN
    P_ALCANCE     => 'ALL'           -- Optional, defaults to 'ALL'
);

IF NOT v_ok THEN
    RAISE exc_validacion;  -- Returns 400 with v_validations array
END IF;
```

**Validation response structure**:
```json
{
  "field": "codigo_plan",
  "code": "INVALID_REFERENCE",
  "severity": "error",  // "error" or "warning"
  "message": "El plan especificado no existe"
}
```

**Severity handling**:
- `error` → `P_OK = FALSE`, block operation (400)
- `warning` → `P_OK = TRUE`, include in response but allow operation

**CONFIGURACION.F_VALIDAR_ESTATUS()** alternative:
Comprehensive validation function for CRUD operations on status tables:

```sql
l_validation_result := CONFIGURACION.F_VALIDAR_ESTATUS(
    p_codigo             => p_id,
    p_json_data          => p_parametros,
    p_alcance            => 'ALL',
    p_operacion          => 'UPDATE',
    p_campos_modificados => SYS.ODCIVARCHAR2LIST('descripcion', 'tipo'),
    p_request_id         => v_request_id
);
```

- Returns standardized JSON response via `F_GENERAR_RESPUESTA_ESTANDAR`
- Automatically categorizes errors as 'validation' (400) or 'business' (422)
