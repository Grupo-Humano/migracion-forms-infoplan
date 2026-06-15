-- ============================================================================
-- ORDS HANDLER DEPLOYMENT SCRIPT #2: transacciones/search Handler
-- ============================================================================
-- Purpose: Deploy POST /transacciones/search handler with parameterized query
-- Method: POST (search with filters)
-- Handler Type: json/collection (ORDS feed)
-- Pagination: explicit offset/limit support with stable ORDER BY
-- ============================================================================

BEGIN
  -- Create POST handler for /transacciones/search
  ORDS.create_handler(
    p_module_name    => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern        => 'transacciones/search',
    p_method         => 'POST',
    p_source_type    => 'json/collection',
    p_source         => q'[
      SELECT
        q.id_transaccion,
        TO_CHAR(q.fecha, 'YYYY-MM-DD') AS fec_tra,
        q.cliente,
        q.compania,
        q.ramo,
        q.secuencial,
        q.monto,
        q.estado,
        q.cod_rechazo AS codigo_rechazo,
        q.respuesta_banco,
        q.num_autoriza,
        q.lote_id,
        q.oficial,
        q.gerente,
        q.intermediario,
        q.seleccionado AS seleccion
      FROM (
        SELECT
          t.id_transaccion,
          t.fecha,
          t.cliente,
          t.compania,
          t.ramo,
          t.secuencial,
          t.monto,
          t.estado,
          t.cod_rechazo,
          t.respuesta_banco,
          t.num_autoriza,
          t.lote_id,
          t.oficial,
          t.gerente,
          t.intermediario,
          NVL(t.seleccionado, 0) AS seleccionado,
          ROW_NUMBER() OVER (
            ORDER BY t.fecha DESC, t.id_transaccion DESC
          ) AS rn
        FROM transacciones_cobro_recurrente t
        WHERE (:fec_ini IS NULL OR t.fecha >= TO_DATE(:fec_ini, 'YYYY-MM-DD'))
          AND (:fec_fin IS NULL OR t.fecha < TO_DATE(:fec_fin, 'YYYY-MM-DD') + 1)
          AND (:cliente IS NULL OR t.cliente = TO_NUMBER(:cliente))
          AND (:oficial IS NULL OR t.oficial = TO_NUMBER(:oficial))
          AND (:gerente IS NULL OR t.gerente = TO_NUMBER(:gerente))
          AND (:intermediario IS NULL OR t.intermediario = TO_NUMBER(:intermediario))
      ) q
      WHERE q.rn > NVL(TO_NUMBER(:offset), 0)
        AND q.rn <= NVL(TO_NUMBER(:offset), 0) + NVL(TO_NUMBER(:limit), 25)
      ORDER BY q.rn
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
