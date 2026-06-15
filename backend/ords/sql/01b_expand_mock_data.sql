-- Sprint 1.5 - Expand mock data to match Jasper date range (2026-01-01 to 2026-06-15)
-- Generates ~150 records across the full range to match Jasper Excel export

BEGIN
  EXECUTE IMMEDIATE 'DELETE FROM mock_transacciones WHERE id_transaccion >= 900000';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

DECLARE
  v_id NUMBER := 900001;
  v_date DATE := DATE '2026-01-01';
  v_oficial NUMBER;
  v_gerente NUMBER;
  v_intermediario NUMBER;
  v_estado VARCHAR2(10);
  v_codigo_rechazo VARCHAR2(10);
  v_monto NUMBER;
BEGIN
  -- Generate records for each day from 2026-01-01 to 2026-06-15
  -- Approximately 166 days = 166 records (roughly matching Jasper volume)
  WHILE v_date <= DATE '2026-06-15' LOOP
    -- Rotate through officials, gerentes, intermediarios
    v_oficial := MOD(v_id, 5) + 101;  -- 101-105
    v_gerente := MOD(v_id, 3) + 201;  -- 201-203
    v_intermediario := MOD(v_id, 4) + 301;  -- 301-304
    
    -- Vary status and amounts
    CASE MOD(v_id, 5)
      WHEN 0 THEN
        v_estado := 'APR';
        v_codigo_rechazo := NULL;
        v_monto := 2450.75;
      WHEN 1 THEN
        v_estado := 'RECH';
        v_codigo_rechazo := 'R01';
        v_monto := 1800.00;
      WHEN 2 THEN
        v_estado := 'PEN';
        v_codigo_rechazo := NULL;
        v_monto := 3200.50;
      WHEN 3 THEN
        v_estado := 'RECH';
        v_codigo_rechazo := 'R00';
        v_monto := 2100.25;
      ELSE
        v_estado := 'APR';
        v_codigo_rechazo := NULL;
        v_monto := 1950.00;
    END CASE;
    
    INSERT INTO mock_transacciones (
      id_transaccion, fec_tra, cliente, compania, ramo, secuencial, monto,
      estado, codigo_rechazo, descripcion_rechazo, respuesta_banco,
      oficial, gerente, intermediario, nombre_oficial, nombre_gerente, nombre_intermediario,
      seleccion, user_crea, fecha_crea, user_actualiza, fecha_actualiza
    ) VALUES (
      v_id, v_date, 50001 + MOD(v_id, 100), 1, 10, 100000 + v_id, v_monto,
      v_estado, v_codigo_rechazo, 
      CASE v_codigo_rechazo 
        WHEN 'R01' THEN 'FONDOS INSUFICIENTES'
        WHEN 'R00' THEN 'RECHAZO BANCO LOCAL'
        ELSE NULL
      END,
      CASE v_estado 
        WHEN 'APR' THEN 'APROBADA'
        WHEN 'RECH' THEN 'DECLINADA POR BANCO'
        ELSE 'PENDIENTE'
      END,
      v_oficial, v_gerente, v_intermediario,
      'Oficial ' || (v_oficial - 100),
      'Gerente ' || (v_gerente - 200),
      'Intermediario ' || (v_intermediario - 300),
      'N', 'MIGRACION', v_date, 'MIGRACION', v_date
    );
    
    v_id := v_id + 1;
    v_date := v_date + 1;
  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Generated ' || (v_id - 900001) || ' mock transaction records.');
END;
/

-- Verify
SELECT COUNT(*) as total_records, 
       MIN(fec_tra) as earliest_date, 
       MAX(fec_tra) as latest_date,
       MIN(id_transaccion) as min_id,
       MAX(id_transaccion) as max_id
FROM mock_transacciones;
