-- ============================================================================
-- ORDS HANDLER DEPLOYMENT SCRIPT #2: transacciones/search Handler
-- ============================================================================
-- Purpose: Deploy POST /transacciones/search handler with parameterized query
-- Method: POST (search with filters)
-- Handler Type: plsql/block (parameterized PL/SQL query)
-- Expected Response: json/collection (array of transaction rows)
-- ============================================================================

BEGIN
  -- Create POST handler for /transacciones/search
  ORDS.create_handler(
    p_module_name    => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern        => 'transacciones/search',
    p_method         => 'POST',
    p_source_type    => 'plsql/block',
    p_source         => q'[
      DECLARE
        v_fec_ini       DATE;
        v_fec_fin       DATE;
        v_cliente       VARCHAR2(100);
        v_oficial       NUMBER;
        v_gerente       NUMBER;
        v_intermediario NUMBER;
        
        TYPE t_result IS RECORD (
          id_transaccion      NUMBER,
          fecha               DATE,
          cliente             VARCHAR2(100),
          cliente_poliza      VARCHAR2(100),
          compania            VARCHAR2(100),
          ramo                VARCHAR2(100),
          secuencial          VARCHAR2(50),
          monto               NUMBER,
          estado              VARCHAR2(50),
          estatus_poliza      VARCHAR2(100),
          cod_rechazo         VARCHAR2(50),
          respuesta_banco     VARCHAR2(200),
          num_autoriza        VARCHAR2(50),
          lote_id             NUMBER,
          frecuencia_pago     VARCHAR2(50),
          oficial             VARCHAR2(100),
          gerente             VARCHAR2(100),
          intermediario       VARCHAR2(100),
          seleccionado        NUMBER
        );
        
        TYPE t_results IS TABLE OF t_result;
        v_results t_results;
      BEGIN
        -- Parse input parameters
        v_fec_ini       := TRUNC(TO_DATE(NVL(:fec_ini, SYSDATE), 'YYYY-MM-DD'));
        v_fec_fin       := TRUNC(TO_DATE(NVL(:fec_fin, SYSDATE), 'YYYY-MM-DD')) + 1;
        v_cliente       := NULLIF(:cliente, '');
        v_oficial       := TO_NUMBER(NULLIF(:oficial, ''));
        v_gerente       := TO_NUMBER(NULLIF(:gerente, ''));
        v_intermediario := TO_NUMBER(NULLIF(:intermediario, ''));
        
        -- Main query with CTEs (avoiding ORA-01799 outer join errors)
        WITH poliza_info AS (
          SELECT DISTINCT
            codigo,
            nombre,
            frecuencia
          FROM POLIZA01_V
          WHERE codigo IS NOT NULL
        ),
        pol_intermediario AS (
          SELECT DISTINCT
            codigo_poliza,
            codigo_intermediario,
            nombre_intermediario
          FROM POL_INT01_V
          WHERE codigo_poliza IS NOT NULL
        )
        SELECT 
          tcr.id_transaccion,
          tcr.fecha,
          c.nombre,
          pi.nombre,
          tcr.compania,
          tcr.ramo,
          tcr.secuencial,
          tcr.monto,
          e.nombre,
          pi2.nombre,
          tcr.cod_rechazo,
          tcr.respuesta_banco,
          tcr.num_autoriza,
          tcr.lote_id,
          pi3.frecuencia,
          m.nombre,
          igd.nombre,
          pol_int.nombre_intermediario,
          COALESCE(tcr.seleccionado, 0)
        BULK COLLECT INTO v_results
        FROM TRANSACCIONES_COBRO_RECURRENTE tcr
        LEFT JOIN CLIENTE c ON tcr.cliente = c.codigo
        LEFT JOIN poliza_info pi ON tcr.poliza_id = pi.codigo
        LEFT JOIN ESTATUS e ON tcr.estado = e.codigo
        LEFT JOIN poliza_info pi2 ON tcr.estatus_id = pi2.codigo
        LEFT JOIN poliza_info pi3 ON tcr.frecuencia_id = pi3.codigo
        LEFT JOIN MOFICIAL m ON tcr.oficial = m.codigo_oficial AND m.estatus = 76
        LEFT JOIN INT_GER_DIR01_V igd ON tcr.gerente = igd.codigo
        LEFT JOIN pol_intermediario pol_int ON tcr.poliza_id = pol_int.codigo_poliza AND tcr.intermediario = pol_int.codigo_intermediario
        WHERE tcr.fecha >= v_fec_ini
          AND tcr.fecha < v_fec_fin
          AND (v_cliente IS NULL OR c.codigo = v_cliente)
          AND (v_oficial IS NULL OR tcr.oficial = v_oficial)
          AND (v_gerente IS NULL OR tcr.gerente = v_gerente)
          AND (v_intermediario IS NULL OR tcr.intermediario = v_intermediario)
        FETCH FIRST 500 ROWS ONLY;
        
        -- Output JSON
        FOR i IN 1..v_results.COUNT LOOP
          htp.p('{');
          htp.p('"id_transaccion":'||v_results(i).id_transaccion||',');
          htp.p('"fecha":"'||TO_CHAR(v_results(i).fecha, 'YYYY-MM-DD')||'",');
          htp.p('"cliente":"'||REPLACE(v_results(i).cliente, '"', '\"')||'",');
          htp.p('"cliente_poliza":"'||REPLACE(COALESCE(v_results(i).cliente_poliza, ''), '"', '\"')||'",');
          htp.p('"compania":"'||REPLACE(v_results(i).compania, '"', '\"')||'",');
          htp.p('"ramo":"'||REPLACE(v_results(i).ramo, '"', '\"')||'",');
          htp.p('"secuencial":"'||REPLACE(v_results(i).secuencial, '"', '\"')||'",');
          htp.p('"monto":'||v_results(i).monto||',');
          htp.p('"estado":"'||REPLACE(v_results(i).estado, '"', '\"')||'",');
          htp.p('"estatus_poliza":"'||REPLACE(COALESCE(v_results(i).estatus_poliza, ''), '"', '\"')||'",');
          htp.p('"cod_rechazo":"'||REPLACE(COALESCE(v_results(i).cod_rechazo, ''), '"', '\"')||'",');
          htp.p('"respuesta_banco":"'||REPLACE(COALESCE(v_results(i).respuesta_banco, ''), '"', '\"')||'",');
          htp.p('"num_autoriza":"'||REPLACE(COALESCE(v_results(i).num_autoriza, ''), '"', '\"')||'",');
          htp.p('"lote_id":'||COALESCE(v_results(i).lote_id, 'null')||',');
          htp.p('"frecuencia_pago":"'||REPLACE(COALESCE(v_results(i).frecuencia_pago, ''), '"', '\"')||'",');
          htp.p('"oficial":"'||REPLACE(COALESCE(v_results(i).oficial, ''), '"', '\"')||'",');
          htp.p('"gerente":"'||REPLACE(COALESCE(v_results(i).gerente, ''), '"', '\"')||'",');
          htp.p('"intermediario":"'||REPLACE(COALESCE(v_results(i).intermediario, ''), '"', '\"')||'",');
          htp.p('"seleccionado":'||v_results(i).seleccionado||'}');
          IF i < v_results.COUNT THEN htp.p(','); END IF;
        END LOOP;
        
      EXCEPTION
        WHEN OTHERS THEN
          htp.p('{"error":"'||SQLERRM||'"}');
      END;
    ]',
    p_comments       => 'POST search for transactions with parameterized filters (fec_ini, fec_fin, cliente, oficial, gerente, intermediario)'
  );
  
  COMMIT;
  
  DBMS_OUTPUT.put_line('✅ Handler created: POST /transacciones/search');
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('❌ Error: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END;
/

-- ============================================================================
-- END: transacciones/search Handler
-- ============================================================================
