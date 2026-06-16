# DELETE - Eliminar Registro

Plantilla para implementar endpoint DELETE siguiendo los estándares del proyecto.

## Variables a Reemplazar

- `{entity}` → nombre de la entidad en minúsculas (ej: `cliente`, `producto`)
- `{ENTITY}` → nombre de la entidad en mayúsculas (ej: `CLIENTE`, `PRODUCTO`)
- `{dominio}` → dominio de la API (ej: `personas`, `productos`, `configuracion`)
- `{tabla}` → nombre de la tabla en base de datos (ej: `CLI_CLIENTE`, `PRO_PRODUCTO`)
- `{schema}` → esquema de base de datos (ej: `DBAPER`, `POLIZAS`, `FACTURACION`)
- `{codigo}` → nombre del campo código PK (ej: `codigo_cliente`, `codigo_producto`)
- `{CODIGO}` → nombre del campo código en tabla (ej: `COD_CLI`, `COD_PRO`)

---

## 1. Handler (`handlers/DELETE-{entity}s-detalle.sql`)

```sql
-- =====================================================
-- Handler: DELETE /{dominio}/api/v1/{entity}s/{{codigo}}
-- Descripción: Eliminar {entity} existente
-- Respuesta: 204 No Content
-- =====================================================

BEGIN
    ORDS_ADMIN.DEFINE_HANDLER(
        p_module_name    => '{dominio}.api.v1',
        p_pattern        => '{entity}s/:{codigo}',
        p_method         => 'DELETE',
        p_source_type    => 'plsql/block',
        p_mimes_allowed  => '',
        p_schema => 'DBAPER', 
        p_comments       => 'Eliminar {entity}',
        p_source         => 'DECLARE
    l_codigo           NUMBER;
    l_parametros          CLOB;
    l_body             CLOB;
    l_status_code      NUMBER;
    l_error_msg        VARCHAR2(4000);
    l_request_id       VARCHAR2(100) := nvl(:p_request,SYS_GUID());
    
    -- Variables para autenticación
    v_usuario          VARCHAR2(100);
        c_usuario_infoplan CONSTANT VARCHAR2(200) := F_BUSCA_LOW_VALUE_REF_CODES(30, ''OAUTHCORE'', ''Infoplan-core-web'');

    
    -- Excepciones
    e_auth_failed      EXCEPTION;
    e_invalid_codigo   EXCEPTION;

BEGIN
    -- Validar código en URL
    BEGIN
        l_codigo := TO_NUMBER(:{codigo});
        l_parametros := JSON_OBJECT(''codigo'' value l_codigo);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE e_invalid_codigo;
    END;

    -- Autenticación
    IF :current_user = c_usuario_infoplan THEN
        IF :p_token IS NULL THEN
            RAISE e_authentication_invalid;
        END IF;
        v_usuario := jwt_utils.get_username(:p_token);
    ELSE
        BEGIN
            v_usuario := jwt_utils.get_username_by_client_id(:current_user);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE e_authentication_invalid;
        END;
    END IF;

    -- Configurar sesión para auditoría
    DBMS_SESSION.SET_IDENTIFIER(v_usuario);
    
    -- Llamar procedimiento de eliminación
     {schema}.P_CONFIRMAR_{ENTITY}_ORDS(
        P_PARAMETROS  => l_parametros,
        P_OPERACION   => ''DELETE'',
        P_REQUEST_ID  => l_request_id,
        P_STATUS_CODE => l_status_code,
        P_BODY        => l_body,
        P_ERROR       => l_error_msg
    );

    -- Retornar respuesta
    :status_code := l_status_code;
    
    -- 204 No Content no debe enviar body
    IF l_status_code = 204 THEN
        RETURN NULL;
    END IF;
    OWA_UTIL.MIME_HEADER(''application/json'', TRUE);
    HTP.P(l_body);
  

EXCEPTION
    WHEN e_invalid_codigo THEN
        :status_code := 400;
        l_body := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => ''server-error'',
            p_error_detail   => ''El cuerpo de la petición JSON es obligatorio'',
            p_error_title    => ''Invalid Request'',
            p_status_code    => c_status_bad_request,
            p_request_id     => v_request_id
        );
        HTP.P(l_body);
        
    WHEN e_auth_failed THEN
        :status_code := 401;
        l_body := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => ''server_error'',
            p_error_detail   => ''Token inválido'',
            p_error_title    => ''Error de autenticación'',
            p_status_code    => 401,
            p_request_id     => l_request_id
        );
        HTP.P(l_body);
        
    WHEN OTHERS THEN
        :status_code := 500;
        DBAPER.P_LOG_ERROR(''DELETE /{dominio}/api/v1/{entity}s/:codigo'', SQLERRM);
        l_body := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => ''server_error'',
            p_error_detail   => SQLERRM,
            p_error_title    => ''Error interno'',
            p_status_code    => 500,
            p_request_id     => l_request_id
        );
        HTP.P(l_body);
END;'
    );
    
-- Definir parámetro x-ad-token
BEGIN
    ORDS_ADMIN.DEFINE_PARAMETER(
        p_module_name        => '{dominio}.api.v1',
        p_pattern            => '{entity}s/:{codigo}',
        p_method             => 'DELETE',
        p_name               => 'x-ad-token',
        p_bind_variable_name => 'P_TOKEN',
        p_source_type        => 'HEADER',
        p_param_type         => 'STRING',
        p_access_method      => 'IN',
        p_schema => 'DBAPER', 
        p_comments           => 'Token de autenticación AD'
    );
    
    ORDS_ADMIN.DEFINE_PARAMETER(
        p_module_name        => '{dominio}.api.v1',
        p_pattern            => '{entity}s/:{codigo}',
        p_method             => 'DELETE',
        p_name               => 'x-trace-id',
        p_bind_variable_name => 'request_id',
        p_source_type        => 'HEADER',
        p_param_type         => 'STRING',
        p_access_method      => 'IN',
        p_schema             => 'DBAPER',
        p_comments           => 'ID de request para trazabilidad (opcional)'
    );

    COMMIT;
END;
/
```

---

## 2. Procedure (`procedures/P_ELIMINAR_{ENTITY}_ORDS.prc`)

**Opción A: Eliminación Lógica (Recomendada)**

```sql
-- =====================================================
-- Procedure: P_ELIMINAR_{ENTITY}_ORDS
-- Descripción: Elimina lógicamente un {entity}
-- Método: Actualiza ACTIVO='N' y campos de auditoría
-- Autor: [Tu nombre]
-- Fecha: 2026-03-06
-- =====================================================

CREATE OR REPLACE PROCEDURE {schema}.P_ELIMINAR_{ENTITY}_ORDS (
    P_CODIGO      IN  NUMBER,
    P_REQUEST_ID  IN  VARCHAR2,
    P_STATUS_CODE OUT NUMBER,
    P_BODY        OUT CLOB,
    P_ERROR       OUT VARCHAR2
) IS
    -- Constantes
    c_status_no_content    CONSTANT NUMBER := 204;
    c_status_not_found     CONSTANT NUMBER := 404;
    c_status_unprocessable CONSTANT NUMBER := 422;
    c_status_error         CONSTANT NUMBER := 500;
    
    -- Variables
    v_usuario         VARCHAR2(100);
    v_existe          NUMBER;
    v_msg_error       VARCHAR2(4000);
    
    -- Excepciones
    exc_not_found     EXCEPTION;
    exc_negocio       EXCEPTION;

BEGIN
    -- Log
    DBAPER.P_LOG_ORDS('P_ELIMINAR_{ENTITY}_ORDS', 
        JSON_OBJECT('{codigo}' VALUE P_CODIGO).TO_CLOB());
    
    -- Obtener usuario
    v_usuario := SUBSTR(DBAPER.F_USUARIO_ORDS_USER, 1, 30);
    
    -- 1. VERIFICAR EXISTENCIA
    BEGIN
        SELECT COUNT(*)
          INTO v_existe
          FROM {schema}.{tabla}
         WHERE {CODIGO} = P_CODIGO;
         
        IF v_existe = 0 THEN
            RAISE exc_not_found;
        END IF;
    END;
    
    -- 2. ELIMINACIÓN LÓGICA
    UPDATE {schema}.{tabla}
       SET ACTIVO = 'N',
           FEC_ELIMINACION = SYSDATE,
           USR_ELIMINACION = v_usuario
     WHERE {CODIGO} = P_CODIGO;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE exc_not_found;
    END IF;
    
    COMMIT;
    
    -- 3. RESPUESTA EXITOSA (204 No Content)
    P_STATUS_CODE := c_status_no_content;
    P_BODY := NULL;
    P_ERROR := NULL;

EXCEPTION
    WHEN exc_not_found THEN
        ROLLBACK;
        P_STATUS_CODE := c_status_not_found;
        P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => 'error',
            p_error_detail   => 'No se encontró {entity} con código ' || P_CODIGO,
            p_error_title    => 'Recurso no encontrado',
            p_status_code    => c_status_not_found,
            p_request_id     => P_REQUEST_ID
        );
        P_ERROR := v_msg_error;
        
    WHEN exc_negocio THEN
        ROLLBACK;
        P_STATUS_CODE := c_status_unprocessable;
        P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => 'business',
            p_error_detail   => v_msg_error,
            p_error_title    => 'Error de negocio',
            p_status_code    => c_status_unprocessable,
            p_request_id     => P_REQUEST_ID
        );
        P_ERROR := v_msg_error;
        
    WHEN OTHERS THEN
        ROLLBACK;
        DBAPER.P_LOG_ERROR('P_ELIMINAR_{ENTITY}_ORDS', SQLERRM);
        P_STATUS_CODE := c_status_error;
        P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => 'error',
            p_error_detail   => SQLERRM,
            p_error_title    => 'Error inesperado',
            p_status_code    => c_status_error,
            p_request_id     => P_REQUEST_ID
        );
        P_ERROR := SQLERRM;
END P_ELIMINAR_{ENTITY}_ORDS;
/
```

---

**Opción B: Eliminación Física (con manejo de referencias)**

```sql
-- =====================================================
-- Procedure: P_ELIMINAR_{ENTITY}_ORDS
-- Descripción: Elimina físicamente un {entity}
-- Método: DELETE de la tabla con validación de referencias
-- Autor: [Tu nombre]
-- Fecha: 2026-03-06
-- =====================================================

CREATE OR REPLACE PROCEDURE {schema}.P_ELIMINAR_{ENTITY}_ORDS (
    P_CODIGO      IN  NUMBER,
    P_REQUEST_ID  IN  VARCHAR2,
    P_STATUS_CODE OUT NUMBER,
    P_BODY        OUT CLOB,
    P_ERROR       OUT VARCHAR2
) IS
    -- Constantes
    c_status_no_content    CONSTANT NUMBER := 204;
    c_status_not_found     CONSTANT NUMBER := 404;
    c_status_unprocessable CONSTANT NUMBER := 422;
    c_status_error         CONSTANT NUMBER := 500;
    
    -- Variables
    v_usuario         VARCHAR2(100);
    v_existe          NUMBER;
    v_msg_error       VARCHAR2(4000);
    
    -- Excepciones
    exc_not_found     EXCEPTION;
    exc_negocio       EXCEPTION;
    exc_referencia    EXCEPTION;
    PRAGMA EXCEPTION_INIT(exc_referencia, -2292); -- ORA-02292

BEGIN
    -- Log
    DBAPER.P_LOG_ORDS('P_ELIMINAR_{ENTITY}_ORDS', 
        JSON_OBJECT('{codigo}' VALUE P_CODIGO).TO_CLOB());
    
    -- Obtener usuario
    v_usuario := SUBSTR(DBAPER.F_USUARIO_ORDS_USER, 1, 30);
    
    -- 1. VERIFICAR EXISTENCIA
    BEGIN
        SELECT COUNT(*)
          INTO v_existe
          FROM {schema}.{tabla}
         WHERE {CODIGO} = P_CODIGO;
         
        IF v_existe = 0 THEN
            RAISE exc_not_found;
        END IF;
    END;
    
    -- 2. ELIMINACIÓN FÍSICA
    DELETE FROM {schema}.{tabla}
     WHERE {CODIGO} = P_CODIGO;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE exc_not_found;
    END IF;
    
    COMMIT;
    
    -- 3. RESPUESTA EXITOSA (204 No Content)
    P_STATUS_CODE := c_status_no_content;
    P_BODY := NULL;
    P_ERROR := NULL;

EXCEPTION
    WHEN exc_not_found THEN
        ROLLBACK;
        P_STATUS_CODE := c_status_not_found;
        P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => 'error',
            p_error_detail   => 'No se encontró {entity} con código ' || P_CODIGO,
            p_error_title    => 'Recurso no encontrado',
            p_status_code    => c_status_not_found,
            p_request_id     => P_REQUEST_ID
        );
        P_ERROR := v_msg_error;
        
    WHEN exc_referencia THEN
        ROLLBACK;
        P_STATUS_CODE := c_status_unprocessable;
        P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => 'business',
            p_error_detail   => 'No se puede eliminar porque tiene registros relacionados',
            p_error_title    => 'Violación de integridad referencial',
            p_status_code    => c_status_unprocessable,
            p_request_id     => P_REQUEST_ID
        );
        P_ERROR := 'ORA-02292: Integridad referencial violada';
        
    WHEN OTHERS THEN
        ROLLBACK;
        DBAPER.P_LOG_ERROR('P_ELIMINAR_{ENTITY}_ORDS', SQLERRM);
        P_STATUS_CODE := c_status_error;
        P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => 'error',
            p_error_detail   => SQLERRM,
            p_error_title    => 'Error inesperado',
            p_status_code    => c_status_error,
            p_request_id     => P_REQUEST_ID
        );
        P_ERROR := SQLERRM;
END P_ELIMINAR_{ENTITY}_ORDS;
/
```

---

## Ejemplo de Request

```bash
DELETE /{dominio}/api/v1/{entity}s/1234
Authorization: Bearer {token}
x-ad-token: {ad-token}

Response: 204 No Content
(Sin body)
```

### Error 404 - No encontrado:

```bash
DELETE /{dominio}/api/v1/{entity}s/99999

Response: 404 Not Found
{
  "meta": {
    "requestId": "ABC-999",
    "timestamp": "2026-03-06T15:00:00.000Z",
    "version": "v1"
  },
  "error": {
    "type": "about:blank",
    "title": "Recurso no encontrado",
    "status": 404,
    "detail": "No se encontró {entity} con código 99999",
    "instance": "/{dominio}/api/v1/{entity}s/99999"
  }
}
```

### Error 422 - Violación referencial (Opción B):

```bash
DELETE /{dominio}/api/v1/{entity}s/1234

Response: 422 Unprocessable Entity
{
  "meta": {
    "requestId": "DEF-456",
    "timestamp": "2026-03-06T15:01:00.000Z",
    "version": "v1"
  },
  "error": {
    "type": "about:blank",
    "title": "Violación de integridad referencial",
    "status": 422,
    "detail": "No se puede eliminar porque tiene registros relacionados",
    "instance": "/{dominio}/api/v1/{entity}s/1234"
  }
}
```

---

## Características

✅ **Respuesta 204 No Content**: Sin body cuando exitoso  
✅ **Dos opciones**: Lógica (recomendada) o física  
✅ **Manejo 404**: Si recurso no existe  
✅ **Manejo 422**: Para violación de referencias (ORA-02292)  
✅ **Auditoría**: FEC_ELIMINACION, USR_ELIMINACION (opción A)  
✅ **Autenticación dual-token** JWT

## Cuándo Usar Cada Opción

| Opción | Usar cuando... | Ventajas | Desventajas |
|--------|---------------|----------|-------------|
| **A (Lógica)** | - Datos históricos importantes<br>- Auditoría requerida<br>- Compliance regulations<br>- Posibilidad de "restaurar" | - Preserva historia<br>- Auditable<br>- Reversible<br>- Sin problemas de referencias | - Tabla crece<br>- Queries más complejos<br>- Necesita filtrar ACTIVO |
| **B (Física)** | - Datos temporales/test<br>- Espacio limitado<br>- No hay referencias<br>- GDPR/"derecho al olvido" | - Espacio de BD<br>- Queries simples<br>- Datos realmente eliminados | - Irreversible<br>- Pérdida de historia<br>- Problemas con FKs |

## Recomendación

🎯 **Usar Opción A (Lógica)** para la mayoría de los casos empresariales.

## Notas Adicionales

- Si usas eliminación lógica, agregar estos campos a la tabla:
  - `FEC_ELIMINACION DATE`
  - `USR_ELIMINACION VARCHAR2(30)`
- Modificar GET collection para filtrar: `WHERE ACTIVO = 'S'`
- Considerar procedimiento de "restaurar": `P_RESTAURAR_{ENTITY}_ORDS`
