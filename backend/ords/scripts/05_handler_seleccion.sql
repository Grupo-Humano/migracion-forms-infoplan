-- ============================================================================
-- ORDS HANDLER DEPLOYMENT SCRIPT #5: seleccion/{M|D} Handler
-- ============================================================================
-- Purpose: Deploy POST /transacciones/seleccion/{M|D} handler for marking/unmarking transactions
-- Method: POST (write operation)
-- Handler Type: plsql/block (handles both M = mark and D = unmark)
-- Expected Response: { message: "success", updated: N } or error
-- ============================================================================

BEGIN
  -- Create POST handler for /transacciones/seleccion/{action}
  ORDS.create_handler(
    p_module_name    => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern        => 'transacciones/seleccion/:action',
    p_method         => 'POST',
    p_source_type    => 'plsql/block',
    p_source         => q'[
      DECLARE
        v_action  VARCHAR2(1);
        v_ids     VARCHAR2(4000);
        v_updated INTEGER := 0;
        
        TYPE t_id_array IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
        t_ids t_id_array;
      BEGIN
        -- Parse input parameters
        v_action := UPPER(:action); -- M or D
        v_ids    := COALESCE(:ids, '');
        
        -- Validate action
        IF v_action NOT IN ('M', 'D') THEN
          owa_util.status_line(400, 'Bad Request');
          htp.p('{"error":"Action must be M (mark) or D (unmark)"}');
          RETURN;
        END IF;
        
        -- Parse comma-separated IDs
        -- Example input: "1,2,3"
        -- Note: In production, consider using JSON_TABLE for cleaner parsing
        BEGIN
          DECLARE
            i PLS_INTEGER := 1;
            start_pos PLS_INTEGER := 1;
            comma_pos PLS_INTEGER;
            id_str VARCHAR2(20);
          BEGIN
            IF v_ids IS NOT NULL AND v_ids != '' THEN
              LOOP
                comma_pos := INSTR(v_ids, ',', start_pos);
                IF comma_pos = 0 THEN
                  id_str := SUBSTR(v_ids, start_pos);
                  IF TRIM(id_str) IS NOT NULL THEN
                    t_ids(i) := TO_NUMBER(TRIM(id_str));
                    i := i + 1;
                  END IF;
                  EXIT;
                ELSE
                  id_str := SUBSTR(v_ids, start_pos, comma_pos - start_pos);
                  IF TRIM(id_str) IS NOT NULL THEN
                    t_ids(i) := TO_NUMBER(TRIM(id_str));
                    i := i + 1;
                  END IF;
                  start_pos := comma_pos + 1;
                END IF;
              END LOOP;
            END IF;
          END;
        EXCEPTION
          WHEN OTHERS THEN
            owa_util.status_line(400, 'Bad Request');
            htp.p('{"error":"Invalid ID format"}');
            RETURN;
        END;
        
        -- Execute action (M = mark, D = unmark)
        IF v_action = 'M' THEN
          -- Mark: SET seleccionado = 1
          FORALL j IN 1..t_ids.COUNT
            UPDATE TRANSACCIONES_COBRO_RECURRENTE
            SET seleccionado = 1
            WHERE id_transaccion = t_ids(j);
          v_updated := SQL%ROWCOUNT;
          
        ELSIF v_action = 'D' THEN
          -- Unmark: SET seleccionado = 0
          FORALL j IN 1..t_ids.COUNT
            UPDATE TRANSACCIONES_COBRO_RECURRENTE
            SET seleccionado = 0
            WHERE id_transaccion = t_ids(j);
          v_updated := SQL%ROWCOUNT;
        END IF;
        
        COMMIT;
        
        -- Return success response
        htp.p('{');
        htp.p('"message":"success",');
        htp.p('"action":"'||v_action||'",');
        htp.p('"updated":'||v_updated);
        htp.p('}');
        
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          owa_util.status_line(500, 'Internal Server Error');
          htp.p('{"error":"'||SQLERRM||'"}');
      END;
    ]',
    p_comments       => 'POST mark/unmark transactions: /transacciones/seleccion/M (mark) or /D (unmark)'
  );
  
  COMMIT;
  
  DBMS_OUTPUT.put_line('✅ Handler created: POST /transacciones/seleccion/:action (M|D)');
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('❌ Error: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END;
/

-- ============================================================================
-- END: seleccion/{M|D} Handler
-- ============================================================================
