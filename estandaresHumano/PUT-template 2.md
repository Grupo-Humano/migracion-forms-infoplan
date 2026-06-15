# PUT - Actualizar Registro

Plantillas para implementar endpoint PUT (actualizar) siguiendo los estándares del proyecto.

## Variables a Reemplazar

- `{entity}` → nombre de la entidad en minúsculas (ej: `cliente`, `producto`)
- `{ENTITY}` → nombre de la entidad en mayúsculas (ej: `CLIENTE`, `PRODUCTO`)
- `{dominio}` → dominio de la API (ej: `personas`, `productos`, `configuracion`)
- `{tabla}` → nombre de la tabla en base de datos (ej: `CLI_CLIENTE`, `PRO_PRODUCTO`)
- `{schema}` → esquema de base de datos (ej: `DBAPER`, `POLIZAS`, `FACTURACION`)
- `{codigo}` → nombre del campo código PK (ej: `codigo_cliente`, `codigo_producto`)
- `{CODIGO}` → nombre del campo código en tabla (ej: `COD_CLI`, `COD_PRO`)

---

## 1. Handler (`handlers/PUT-{entity}s-detalle.sql`)

```sql
-- =====================================================
-- Handler: PUT /{dominio}/api/v1/{entity}s/{{codigo}}
-- Descripción: Actualizar {entity} existente
-- Respuesta: 204 No Content
-- =====================================================

BEGIN
    ORDS_ADMIN.DEFINE_HANDLER(
        p_module_name    => '{dominio}.api.v1',
        p_schema         => 'DBAPER',
        p_pattern        => '{entity}s/:{codigo}',
        p_method         => 'PUT',
        p_source_type    => 'plsql/block',
        p_mimes_allowed  => 'application/json',
        p_schema => 'DBAPER', p_comments       => 'Actualizar {entity}',
        p_source         => 'DECLARE
    l_body             CLOB := :body_text;
    l_status_code      NUMBER;
    l_error_msg        VARCHAR2(4000);
    l_request_id       VARCHAR2(100);
    l_codigo           NUMBER;
    
    -- Variables para autenticación
    v_usuario          VARCHAR2(100);
    c_usuario_infoplan CONSTANT VARCHAR2(30) := F_BUSCA_LOW_VALUE_REF_CODES(30, ''OAUTHCORE'',''Infoplan-core-web'');
    
    -- Excepciones
    e_validations_invalid  EXCEPTION;
    e_auth_failed      EXCEPTION;

    v_validations JSON_ARRAY_T := JSON_ARRAY_T(); 
BEGIN
    -- Validar body
    IF l_body IS NULL OR LENGTH(TRIM(l_body)) = 0 THEN
       v_validations.append(JSON_OBJECT_T(JSON_OBJECT(
        ''field'' VALUE ''body'',
        ''code'' VALUE ''EMPTY_BODY'',
        ''severity'' VALUE ''error'',
        ''message'' VALUE ''El cuerpo de la petición no puede estar vacío''
        )));
    END IF;
    
    -- Autenticación
    v_request_id := NVL(:request_id, SYS_GUID());    --  Autenticación uniforme
    IF :current_user = c_usuario_infoplan THEN
        IF :P_TOKEN IS NULL THEN
           RAISE e_authentication_invalid;
        END IF;
        v_usuario := jwt_utils.get_username(:P_TOKEN);
    ELSE
        BEGIN
            v_usuario := jwt_utils.get_username_by_client_id(:current_user);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE e_authentication_invalid;
        END;
    END IF;
    
  DBMS_SESSION.SET_IDENTIFIER(v_usuario);
    
    -- Agregar código al JSON (para validaciones)
    DECLARE
        v_json_obj JSON_OBJECT_T;
    BEGIN
        v_json_obj := JSON_OBJECT_T.PARSE(l_body);
        v_json_obj.PUT(''{codigo}'', l_codigo);
        l_body := v_json_obj.TO_CLOB();
    END;

    
    IF V_validations.GET_SIZE > 0 THEN
        RAISE e_validations_invalid;
    END IF;
    
    -- Llamar procedimiento de actualización
    {schema}.P_CONFIRMAR_{ENTITY}_ORDS(
        P_PARAMETROS  => l_body,
        P_OPERACION   => ''UPDATE'',
        P_REQUEST_ID  => l_request_id,
        P_STATUS_CODE => l_status_code,
        P_BODY        => l_body,
        P_ERROR       => l_error_msg
    );
    
    -- Retornar respuesta
    :status_code := l_status_code;
    
    -- 204 No Content no debe enviar body
    IF l_status_code = 204 THEN
        RETURN;
    END IF;

    OWA_UTIL.MIME_HEADER(''application/json'', TRUE);
    HTP.P(l_body);

EXCEPTION
 
    WHEN e_validations_invalid THEN
         :status_code := 400;
        l_body := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => ''validation'',
            p_validations    => JSON_ARRAY_T(''[{"field":"body","code":"EMPTY_BODY","severity":"error","message":"El cuerpo de la petición no puede estar vacío"}]''),
            p_request_id     => l_request_id
        );
        HTP.P(l_body);
        
    WHEN e_auth_failed THEN
        :status_code := 401;
        l_body := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => ''error'',
            p_error_detail   => ''Token inválido'',
            p_error_title    => ''Error de autenticación'',
            p_status_code    => 401,
            p_request_id     => l_request_id
        );
        HTP.P(l_body);
        
    WHEN OTHERS THEN
        :status_code := 500;
        DBAPER.P_LOG_ERROR(''PUT /{dominio}/api/v1/{entity}s/:codigo'', SQLERRM);
        l_body := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => ''error'',
            p_error_detail   => SQLERRM,
            p_error_title    => ''Error interno'',
            p_status_code    => 500,
            p_request_id     => l_request_id
        );
        HTP.P(l_body);
END;'
    );
    

-- Definir parámetro x-ad-token

    ORDS_ADMIN.DEFINE_PARAMETER(
        p_module_name        => '{dominio}.api.v1',
        p_pattern            => '{entity}s/:{codigo}',
        p_method             => 'PUT',
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
        p_method             => 'PUT',
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

## 2. Procedure (`procedures/P_ACTUALIZAR_{ENTITY}_ORDS.prc`)

**Versión completa con Change Detection (optimizada)**:

```sql
-- =====================================================
-- Procedure: P_ACTUALIZAR_{ENTITY}_ORDS
-- Descripción: Actualiza un {entity} existente
-- PATCH-like: Solo actualiza campos enviados
-- Optimización: Change detection evita UPDATEs innecesarios
-- Autor: [Tu nombre]
-- Fecha: 2026-03-06
-- =====================================================

CREATE OR REPLACE PROCEDURE {schema}.P_ACTUALIZAR_{ENTITY}_ORDS (
    P_PARAMETROS  IN  CLOB,
    P_REQUEST_ID  IN  VARCHAR2,
    P_STATUS_CODE OUT NUMBER,
    P_BODY        OUT CLOB,
    P_ERROR       OUT VARCHAR2
) IS
    -- Constantes
    c_status_no_content    CONSTANT NUMBER := 204;
    c_status_bad_request   CONSTANT NUMBER := 400;
    c_status_not_found     CONSTANT NUMBER := 404;
    c_status_unprocessable CONSTANT NUMBER := 422;
    c_status_error         CONSTANT NUMBER := 500;
    
    -- Variables
    v_json_obj        JSON_OBJECT_T;
    v_validations     JSON_ARRAY_T := JSON_ARRAY_T();
    v_ok              BOOLEAN;
    v_msg_error       VARCHAR2(4000);
    v_usuario         VARCHAR2(100);
    v_codigo          NUMBER;
    v_existe          NUMBER;
    v_contador        NUMBER := 0;
    
    -- Record para parámetros
    TYPE t_parametros IS RECORD (
        {codigo}          NUMBER,
        descripcion       VARCHAR2(200),
        tipo              VARCHAR2(50),
        es_activo         VARCHAR2(1),
        comentario        VARCHAR2(4000)
    );
    v_params t_parametros;
    
    -- Record para valores actuales (change detection)
    TYPE t_valores_actuales IS RECORD (
        descripcion       VARCHAR2(200),
        tipo              VARCHAR2(50),
        es_activo         VARCHAR2(1),
        comentario        VARCHAR2(4000)
    );
    v_valores_actuales t_valores_actuales;
    v_hay_cambios      BOOLEAN := FALSE;
    
    -- Excepciones
    exc_validacion    EXCEPTION;
    exc_negocio       EXCEPTION;
    exc_not_found     EXCEPTION;

BEGIN
    -- Log
    DBAPER.P_LOG_ORDS('P_ACTUALIZAR_{ENTITY}_ORDS', P_PARAMETROS);
    
    -- Obtener usuario
    v_usuario := SUBSTR(DBAPER.F_USUARIO_ORDS_USER, 1, 30);
    
    -- 1. PARSEAR JSON
    BEGIN
        v_json_obj := JSON_OBJECT_T.PARSE(P_PARAMETROS);
    EXCEPTION
        WHEN OTHERS THEN
            v_msg_error := 'JSON mal formado: ' || SQLERRM;
            RAISE exc_validacion;
    END;
    
    -- 2. EXTRAER CÓDIGO (obligatorio)
    IF NOT v_json_obj.HAS('{codigo}') THEN
        v_msg_error := 'Campo {codigo} es obligatorio';
        RAISE exc_validacion;
    END IF;
    v_params.{codigo} := v_json_obj.GET_NUMBER('{codigo}');
    v_codigo := v_params.{codigo};
    
    -- 3. VERIFICAR EXISTENCIA Y OBTENER VALORES ACTUALES
    BEGIN
        SELECT DESCRIPCION,
               TIPO,
               ACTIVO,
               COMENTARIO
          INTO v_valores_actuales.descripcion,
               v_valores_actuales.tipo,
               v_valores_actuales.es_activo,
               v_valores_actuales.comentario
          FROM {schema}.{tabla}
         WHERE {CODIGO} = v_codigo;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE exc_not_found;
    END;
    
    -- 4. EXTRAER CAMPOS OPCIONALES Y DETECTAR CAMBIOS
    IF v_json_obj.HAS('descripcion') THEN
        v_params.descripcion := v_json_obj.GET_STRING('descripcion');
        v_contador := v_contador + 1;
        
        IF NVL(v_params.descripcion, 'NULL') != NVL(v_valores_actuales.descripcion, 'NULL') THEN
            v_hay_cambios := TRUE;
        END IF;
    END IF;
    
    IF v_json_obj.HAS('tipo') THEN
        v_params.tipo := v_json_obj.GET_STRING('tipo');
        v_contador := v_contador + 1;
        
        IF NVL(v_params.tipo, 'NULL') != NVL(v_valores_actuales.tipo, 'NULL') THEN
            v_hay_cambios := TRUE;
        END IF;
    END IF;
    
    IF v_json_obj.HAS('es_activo') THEN
        v_params.es_activo := v_json_obj.GET_STRING('es_activo');
        v_contador := v_contador + 1;
        
        IF NVL(v_params.es_activo, 'NULL') != NVL(v_valores_actuales.es_activo, 'NULL') THEN
            v_hay_cambios := TRUE;
        END IF;
    END IF;
    
    IF v_json_obj.HAS('comentario') THEN
        v_params.comentario := v_json_obj.GET_STRING('comentario');
        v_contador := v_contador + 1;
        
        IF NVL(v_params.comentario, 'NULL') != NVL(v_valores_actuales.comentario, 'NULL') THEN
            v_hay_cambios := TRUE;
        END IF;
    END IF;
    
    -- Validar que al menos envíe un campo
    IF v_contador = 0 THEN
        v_msg_error := 'Debe especificar al menos un campo para actualizar';
        RAISE exc_negocio;
    END IF;
    
    -- 5. VALIDACIONES
    {schema}.P_VALIDAR_{ENTITY}(
        P_OPERACION   => 'UPDATE',
        P_PARAMETROS  => P_PARAMETROS,
        P_VALIDATIONS => v_validations,
        P_OK          => v_ok,
        P_ALCANCE     => 'ALL'
    );
    
    IF NOT v_ok THEN
        v_msg_error := 'Errores de validación';
        RAISE exc_validacion;
    END IF;
    
    -- 6. EARLY RETURN si no hay cambios reales
    IF NOT v_hay_cambios THEN
        P_STATUS_CODE := c_status_no_content;
        P_BODY := NULL;
        P_ERROR := NULL;
        RETURN;
    END IF;
    
    -- 7. UPDATE (solo si hay cambios reales)
    -- Patrón seguro: CASE WHEN previene SQL injection
    UPDATE {schema}.{tabla}
       SET DESCRIPCION = CASE WHEN v_json_obj.HAS('descripcion')
                              THEN v_params.descripcion
                              ELSE DESCRIPCION END,
           TIPO = CASE WHEN v_json_obj.HAS('tipo')
                       THEN v_params.tipo
                       ELSE TIPO END,
           ACTIVO = CASE WHEN v_json_obj.HAS('es_activo')
                         THEN v_params.es_activo
                         ELSE ACTIVO END,
           COMENTARIO = CASE WHEN v_json_obj.HAS('comentario')
                             THEN v_params.comentario
                             ELSE COMENTARIO END,
           FEC_ACTUALIZO = SYSDATE,
           USR_ACTUALIZO = v_usuario
     WHERE {CODIGO} = v_codigo;
    
    COMMIT;
    
    -- 8. RESPUESTA EXITOSA (204 No Content)
    P_STATUS_CODE := c_status_no_content;
    P_BODY := NULL;
    P_ERROR := NULL;

EXCEPTION
    WHEN exc_not_found THEN
        ROLLBACK;
        P_STATUS_CODE := c_status_not_found;
        P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => 'error',
            p_error_detail   => 'No se encontró {entity} con código ' || v_codigo,
            p_error_title    => 'Recurso no encontrado',
            p_status_code    => c_status_not_found,
            p_request_id     => P_REQUEST_ID
        );
        P_ERROR := v_msg_error;
        
    WHEN exc_validacion THEN
        ROLLBACK;
        P_STATUS_CODE := c_status_bad_request;
        P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => 'validation',
            p_validations    => v_validations,
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
        DBAPER.P_LOG_ERROR('P_ACTUALIZAR_{ENTITY}_ORDS', SQLERRM);
        P_STATUS_CODE := c_status_error;
        P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => 'error',
            p_error_detail   => SQLERRM,
            p_error_title    => 'Error inesperado',
            p_status_code    => c_status_error,
            p_request_id     => P_REQUEST_ID
        );
        P_ERROR := SQLERRM;
END P_ACTUALIZAR_{ENTITY}_ORDS;
/
```

---

## Ejemplo de Request

```bash
PUT /{dominio}/api/v1/{entity}s/1234
Content-Type: application/json
Authorization: Bearer {token}
x-ad-token: {ad-token}

{
  "descripcion": "Tablet 10 pulgadas HD",
  "es_activo": "N"
}

Response: 204 No Content
(Sin body)
```

---

## Características

✅ **Respuesta 204 No Content**: Sin body cuando exitoso  
✅ **PATCH-like**: Solo actualiza campos enviados  
✅ **Change detection**: Evita UPDATEs si no hay cambios reales  
✅ **SQL seguro**: CASE WHEN previene SQL injection  
✅ **Validación con P_ALCANCE**: FIELD → FORM → BUSINESS → ALL  
✅ **Manejo 404**: Si recurso no existe  
✅ **Auditoría**: FEC_ACTUALIZO, USR_ACTUALIZO automáticos

## Notas Importantes

- **Código NUNCA se actualiza**: Es inmutable
- **Solo campos enviados**: No es necesario enviar todos los campos
- **Change detection**: Evita triggers innecesarios si valores no cambian
- **204 No Content**: Respuesta exitosa sin body (estándar REST)
- **snake_case obligatorio**: En todos los atributos JSON
- Ajustar campos según tu entidad
