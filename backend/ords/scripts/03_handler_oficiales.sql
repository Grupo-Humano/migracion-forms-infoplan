-- ============================================================================
-- ORDS HANDLER DEPLOYMENT SCRIPT #3: oficiales/{codigo} Handler
-- ============================================================================
-- Purpose: Deploy GET /oficiales/{codigo_oficial} handler for looking up official by ID
-- Method: GET (read-only lookup)
-- Handler Type: json/query (returns single row or NULL)
-- Expected Response: { codigo, nombre } or 404 if not found
-- ============================================================================

BEGIN
  -- Create GET handler for /oficiales/{codigo_oficial}
  ORDS.create_handler(
    p_module_name    => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern        => 'oficiales/:codigo_oficial',
    p_method         => 'GET',
    p_source_type    => 'plsql/block',
    p_source         => q'[
      DECLARE
        v_codigo_oficial NUMBER;
        v_nombre         VARCHAR2(100);
        v_found          BOOLEAN := FALSE;
      BEGIN
        v_codigo_oficial := TO_NUMBER(:codigo_oficial);
        
        SELECT nombre
        INTO v_nombre
        FROM MOFICIAL
        WHERE codigo_oficial = v_codigo_oficial
          AND estatus = 76; -- vigente only
        
        v_found := TRUE;
        
        htp.p('{');
        htp.p('"codigo":'||v_codigo_oficial||',');
        htp.p('"nombre":"'||REPLACE(v_nombre, '"', '\"')||'"');
        htp.p('}');
        
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          owa_util.status_line(404, 'Not Found');
          htp.p('{"error":"Official not found"}');
        WHEN OTHERS THEN
          owa_util.status_line(500, 'Internal Server Error');
          htp.p('{"error":"'||SQLERRM||'"}');
      END;
    ]',
    p_comments       => 'GET lookup official by codigo_oficial, returns { codigo, nombre }'
  );
  
  COMMIT;
  
  DBMS_OUTPUT.put_line('✅ Handler created: GET /oficiales/:codigo_oficial');
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('❌ Error: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END;
/

-- ============================================================================
-- END: oficiales/{codigo} Handler
-- ============================================================================
