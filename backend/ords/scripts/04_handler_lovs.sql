-- ============================================================================
-- ORDS HANDLER DEPLOYMENT SCRIPT #4: LOV Handlers (gerentes & intermediarios)
-- ============================================================================
-- Purpose: Deploy GET /gerentes and GET /intermediarios LOV handlers
-- Method: GET (read-only, for dropdown population)
-- Handler Type: json/collection (returns array of { codigo, nombre })
-- Source: INT_GER_DIR01_V view (DISTINCT to avoid duplicates)
-- ============================================================================

-- Handler 1: GET /gerentes
BEGIN
  ORDS.create_handler(
    p_module_name    => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern        => 'gerentes',
    p_method         => 'GET',
    p_source_type    => 'plsql/block',
    p_source         => q'[
      DECLARE
        TYPE t_lov IS RECORD (
          codigo NUMBER,
          nombre VARCHAR2(200)
        );
        TYPE t_lovs IS TABLE OF t_lov;
        v_lovs t_lovs;
      BEGIN
        SELECT DISTINCT
          codigo,
          nombre
        BULK COLLECT INTO v_lovs
        FROM INT_GER_DIR01_V
        WHERE codigo IS NOT NULL
          AND nombre IS NOT NULL
        ORDER BY nombre;
        
        -- Output JSON array
        htp.p('[');
        FOR i IN 1..v_lovs.COUNT LOOP
          htp.p('{');
          htp.p('"codigo":'||v_lovs(i).codigo||',');
          htp.p('"nombre":"'||REPLACE(v_lovs(i).nombre, '"', '\"')||'"');
          htp.p('}');
          IF i < v_lovs.COUNT THEN htp.p(','); END IF;
        END LOOP;
        htp.p(']');
        
      EXCEPTION
        WHEN OTHERS THEN
          htp.p('{"error":"'||SQLERRM||'"}');
      END;
    ]',
    p_comments       => 'GET gerentes LOV for dropdown (58 entries expected from INT_GER_DIR01_V DISTINCT)'
  );
  
  DBMS_OUTPUT.put_line('✅ Handler created: GET /gerentes');
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('❌ Error creating /gerentes: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END;
/

-- Handler 2: GET /intermediarios
BEGIN
  ORDS.create_handler(
    p_module_name    => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern        => 'intermediarios',
    p_method         => 'GET',
    p_source_type    => 'plsql/block',
    p_source         => q'[
      DECLARE
        TYPE t_lov IS RECORD (
          codigo NUMBER,
          nombre VARCHAR2(200)
        );
        TYPE t_lovs IS TABLE OF t_lov;
        v_lovs t_lovs;
      BEGIN
        SELECT DISTINCT
          codigo,
          nombre
        BULK COLLECT INTO v_lovs
        FROM INT_GER_DIR01_V
        WHERE codigo IS NOT NULL
          AND nombre IS NOT NULL
        ORDER BY nombre;
        
        -- Output JSON array
        htp.p('[');
        FOR i IN 1..v_lovs.COUNT LOOP
          htp.p('{');
          htp.p('"codigo":'||v_lovs(i).codigo||',');
          htp.p('"nombre":"'||REPLACE(v_lovs(i).nombre, '"', '\"')||'"');
          htp.p('}');
          IF i < v_lovs.COUNT THEN htp.p(','); END IF;
        END LOOP;
        htp.p(']');
        
      EXCEPTION
        WHEN OTHERS THEN
          htp.p('{"error":"'||SQLERRM||'"}');
      END;
    ]',
    p_comments       => 'GET intermediarios LOV for dropdown (500+ entries expected from INT_GER_DIR01_V DISTINCT)'
  );
  
  DBMS_OUTPUT.put_line('✅ Handler created: GET /intermediarios');
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('❌ Error creating /intermediarios: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END;
/

-- ============================================================================
-- END: LOV Handlers
-- ============================================================================
