# POST - Crear Nuevo Registro

Plantillas para implementar endpoint POST siguiendo los estándares del proyecto.

## Variables a Reemplazar

- `{entity}` → nombre de la entidad en minúsculas (ej: `cliente`, `producto`)
- `{ENTITY}` → nombre de la entidad en mayúsculas (ej: `CLIENTE`, `PRODUCTO`)
- `{dominio}` → dominio de la API (ej: `personas`, `productos`, `configuracion`)
- `{tabla}` → nombre de la tabla en base de datos (ej: `CLI_CLIENTE`, `PRO_PRODUCTO`)
- `{schema}` → esquema de base de datos (ej: `DBAPER`, `POLIZAS`, `FACTURACION`)
- `{codigo}` → nombre del campo código PK (ej: `codigo_cliente`, `codigo_producto`)
- `{CODIGO}` → nombre del campo código en tabla (ej: `COD_CLI`, `COD_PRO`)

---

## 1. Template (`templates/template-{entity}s.sql`)

```sql
-- =====================================================
-- Template: /{dominio}/api/v1/{entity}s
-- Descripción: Colección de {entity}s
-- =====================================================

BEGIN
    ORDS_ADMIN.DEFINE_TEMPLATE(
        p_module_name => '{dominio}.api.v1',
        p_pattern     => '{entity}s',
        p_priority    => 0,
        p_etag_type   => 'HASH',
        p_etag_query  => NULL,
        p_schema => 'DBAPER', p_comments    => 'Colección de {entity}s'
    );
    COMMIT;
END;
/
```

---

## 2. Handler (`handlers/POST-{entity}s.sql`)

```sql
-- =====================================================
-- Handler: POST /{dominio}/api/v1/{entity}s
-- Descripción: Crear nuevo {entity}
-- Respuesta: 201 Created con objeto creado
-- =====================================================

BEGIN
    ORDS_ADMIN.DEFINE_HANDLER(
        p_module_name    => '{dominio}.api.v1',
        p_pattern        => '{entity}s',
        p_method         => 'POST',
        p_source_type    => 'plsql/block',
        p_mimes_allowed  => 'application/json',
        p_schema => 'DBAPER', p_comments       => 'Crear nuevo {entity}',
        p_source         => 'DECLARE
    -- Variables para manejo de errores y respuesta
    l_body             CLOB := :body_text;
    l_status_code      NUMBER;
    l_error_msg        VARCHAR2(4000);
    l_request_id       VARCHAR2(100);
    
    -- Variables para autenticación
    v_usuario          VARCHAR2(100);
       c_usuario_infoplan CONSTANT VARCHAR2(30):=F_BUSCA_LOW_VALUE_REF_CODES(30, ''OAUTHCORE'',''Infoplan-core-web'');
    
    -- Excepciones personalizadas
    e_validations_invalid  EXCEPTION;
    e_auth_failed      EXCEPTION;
    
    v_validations JSON_ARRAY_T := JSON_ARRAY_T(); 
BEGIN
    -- 1. Validar body no vacío
    IF l_body IS NULL OR LENGTH(TRIM(l_body)) = 0 THEN
    v_validations.append(JSON_OBJECT_T(JSON_OBJECT(
      ''field'' VALUE ''body'',
      ''code'' VALUE ''EMPTY_BODY'',
      ''severity'' VALUE ''error'',
      ''message'' VALUE ''El cuerpo de la petición no puede estar vacío''
    )));
    END IF;
    
    -- 3. Autenticación (dual-token)
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

    IF V_validations.GET_SIZE > 0 THEN
        RAISE e_bad_request;
    END IF;

    -- 4. Llamar al procedimiento de negocio
     {schema}.P_CONFIRMAR_{ENTITY}_ORDS(
        P_PARAMETROS  => l_body,
        P_OPERACION   => ''ADD'',
        P_REQUEST_ID  => l_request_id,
        P_STATUS_CODE => l_status_code,
        P_BODY        => l_body,
        P_ERROR       => l_error_msg
    );
    
    -- 5. Retornar respuesta
    :status_code := l_status_code;
    :forward_location := ''./'' || :{codigo}

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
            p_error_detail   => ''Token inválido o no autorizado'',
            p_error_title    => ''Error de autenticación'',
            p_status_code    => 401,
            p_request_id     => l_request_id
        );
        HTP.P(l_body);
        
    WHEN OTHERS THEN
        :status_code := 500;
        DBAPER.P_LOG_ERROR(
            ''POST /{dominio}/api/v1/{entity}s'',
            ''Error inesperado: '' || SQLERRM
        );
        l_body := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => ''error'',
            p_error_detail   => SQLERRM,
            p_error_title    => ''Error interno del servidor'',
            p_status_code    => 500,
            p_request_id     => l_request_id
        );
        HTP.P(l_body);
END;'
    );


-- Definir parámetro para x-ad-token

    ORDS_ADMIN.DEFINE_PARAMETER(
        p_module_name        => '{dominio}.api.v1',
        p_pattern            => '{entity}s',
        p_method             => 'POST',
        p_name               => 'x-ad-token',
        p_bind_variable_name => 'P_TOKEN',
        p_source_type        => 'HEADER',
        p_param_type         => 'STRING',
        p_access_method      => 'IN',
        p_schema => 'DBAPER', p_comments           => 'Token de autenticación AD'
    );

    ORDS_ADMIN.DEFINE_PARAMETER(
        p_module_name        => '{dominio}.api.v1',
        p_pattern            => '{entity}s',
        p_method             => 'POST',
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

## 3. Procedure (`procedures/P_CREAR_{ENTITY}_ORDS.prc`)

```sql
-- =====================================================
-- Procedure: P_CREAR_{ENTITY}_ORDS
-- Descripción: Crea un nuevo {entity}
-- Autor: [Tu nombre]
-- Fecha: 2026-03-06
-- =====================================================

CREATE OR REPLACE PROCEDURE {schema}.P_CREAR_{ENTITY}_ORDS (
    P_PARAMETROS  IN  CLOB,
    P_REQUEST_ID  IN  VARCHAR2,
    P_STATUS_CODE OUT NUMBER,
    P_BODY        OUT CLOB,
    P_ERROR       OUT VARCHAR2
) IS
    -- Constantes
    c_status_created       CONSTANT NUMBER := 201;
    c_status_bad_request   CONSTANT NUMBER := 400;
    c_status_unprocessable CONSTANT NUMBER := 422;
    c_status_error         CONSTANT NUMBER := 500;
    
    -- Variables
    v_json_obj        JSON_OBJECT_T;
    v_validations     JSON_ARRAY_T := JSON_ARRAY_T();
    v_ok              BOOLEAN;
    v_msg_error       VARCHAR2(4000);
    v_usuario         VARCHAR2(100);
    v_nuevo_codigo    NUMBER;
    
    -- Record para parámetros
    TYPE t_parametros IS RECORD (
        descripcion       VARCHAR2(200),
        tipo              VARCHAR2(50),
        es_activo         VARCHAR2(1),
        -- Agregar campos según tu entidad
        comentario        VARCHAR2(4000)
    );
    v_params t_parametros;
    
    -- Excepciones
    exc_validacion    EXCEPTION;
    exc_negocio       EXCEPTION;

BEGIN
    -- Log de entrada
    DBAPER.P_LOG_ORDS('P_CREAR_{ENTITY}_ORDS', P_PARAMETROS);
    
    -- Obtener usuario autenticado
    v_usuario := SUBSTR(DBAPER.F_USUARIO_ORDS_USER, 1, 30);
    
    -- 1. PARSEAR JSON
    BEGIN
        v_json_obj := JSON_OBJECT_T.PARSE(P_PARAMETROS);
    EXCEPTION
        WHEN OTHERS THEN
            v_msg_error := 'JSON mal formado: ' || SQLERRM;
            RAISE exc_validacion;
    END;
    
    -- 2. EXTRAER CAMPOS (no enviar codigo, se genera automáticamente)
    IF v_json_obj.HAS('descripcion') THEN
        v_params.descripcion := v_json_obj.GET_STRING('descripcion');
    END IF;
    
    IF v_json_obj.HAS('tipo') THEN
        v_params.tipo := v_json_obj.GET_STRING('tipo');
    END IF;
    
    -- es_activo: default 'S' si no se envía
    IF v_json_obj.HAS('es_activo') THEN
        v_params.es_activo := v_json_obj.GET_STRING('es_activo');
    ELSE
        v_params.es_activo := 'S';
    END IF;
    
    IF v_json_obj.HAS('comentario') THEN
        v_params.comentario := v_json_obj.GET_STRING('comentario');
    END IF;
    
    -- 3. VALIDACIONES
    {schema}.P_VALIDAR_{ENTITY}(
        P_OPERACION   => 'CREATE',
        P_PARAMETROS  => P_PARAMETROS,
        P_VALIDATIONS => v_validations,
        P_OK          => v_ok,
        P_ALCANCE     => 'ALL'
    );
    
    IF NOT v_ok THEN
        v_msg_error := 'Errores de validación detectados';
        RAISE exc_validacion;
    END IF;
    
    -- 4. GENERAR CÓDIGO (usando secuencia)
    SELECT {schema}.SEQ_{TABLA}.NEXTVAL
      INTO v_nuevo_codigo
      FROM DUAL;
    
    -- 5. INSERTAR
    INSERT INTO {schema}.{tabla} (
        {CODIGO},
        DESCRIPCION,
        TIPO,
        ACTIVO,
        COMENTARIO,
        FEC_CREACION,
        USR_CREACION
    ) VALUES (
        v_nuevo_codigo,
        v_params.descripcion,
        v_params.tipo,
        v_params.es_activo,
        v_params.comentario,
        SYSDATE,
        v_usuario
    );
    
    COMMIT;
    
    -- 6. RESPUESTA EXITOSA (201 Created con objeto creado)
    P_STATUS_CODE := c_status_created;
    P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
        p_tipo_respuesta => 'success',
        p_data           => JSON_OBJECT_T(JSON_OBJECT(
            '{codigo}' VALUE v_nuevo_codigo,
            'descripcion' VALUE v_params.descripcion,
            'tipo' VALUE v_params.tipo,
            'es_activo' VALUE v_params.es_activo,
            'comentario' VALUE v_params.comentario,
            'creado_en' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
        )),
        p_validations    => v_validations,
        p_request_id     => P_REQUEST_ID
    );
    P_ERROR := NULL;

EXCEPTION
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
        DBAPER.P_LOG_ERROR('P_CREAR_{ENTITY}_ORDS', SQLERRM);
        P_STATUS_CODE := c_status_error;
        P_BODY := DBAPER.F_GENERAR_RESPUESTA_ESTANDAR(
            p_tipo_respuesta => 'error',
            p_error_detail   => SQLERRM,
            p_error_title    => 'Error inesperado',
            p_status_code    => c_status_error,
            p_request_id     => P_REQUEST_ID
        );
        P_ERROR := SQLERRM;
END P_CREAR_{ENTITY}_ORDS;
/
```

---

## Ejemplo de Request

```bash
POST /{dominio}/api/v1/{entity}s
Content-Type: application/json
Authorization: Bearer {token}
x-ad-token: {ad-token}

{
  "descripcion": "Tablet 10 pulgadas",
  "tipo": "ELECTRONICA",
  "es_activo": "S",
  "comentario": "Producto de alta rotación"
}

Response: 201 Created
{
  "data": {
    "{codigo}": 1234,
    "descripcion": "Tablet 10 pulgadas",
    "tipo": "ELECTRONICA",
    "es_activo": "S",
    "comentario": "Producto de alta rotación",
    "creado_en": "2026-03-06T10:30:00Z"
  },
  "meta": {
    "requestId": "ABC-123-XYZ",
    "timestamp": "2026-03-06T10:30:00.000Z",
    "version": "v1"
  }
}
```

## Características

✅ **Respuesta 201 Created** con objeto creado  
✅ **Código auto-generado** con secuencia  
✅ **Validación con P_ALCANCE**: FIELD → FORM → BUSINESS → ALL  
✅ **Autenticación dual-token** JWT  
✅ **Manejo completo de errores**: 400, 401, 422, 500  
✅ **Logs automáticos** con P_LOG_ORDS

## Notas Importantes

- **NO enviar** `{codigo}` en el request (se genera automáticamente)
- **NO enviar** `estatus` (se asigna por defecto)
- **snake_case obligatorio** en todos los atributos JSON
- Ajustar campos del TYPE `t_parametros` según tu entidad
- Ajustar campos del INSERT según tu tabla
