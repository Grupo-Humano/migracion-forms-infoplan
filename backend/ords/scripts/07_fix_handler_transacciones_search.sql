-- ============================================================================
-- FIX SCRIPT #7: transacciones/search handler - root cause correction
-- ============================================================================
-- Root cause of HTTP 403:
--   1. Handler pointed to "transacciones_cobro_recurrente" (real table) which
--      does NOT have columns fecha, cod_rechazo, respuesta_banco, oficial,
--      gerente, intermediario, seleccionado used in the SQL.
--   2. ":offset" and ":limit" bind variables in the SQL conflicted with ORDS
--      native pagination parameters for json/collection handlers.
--
-- Fix:
--   - Target mock_transacciones (has all required columns for mock phase)
--   - Use correct column names: fec_tra, codigo_rechazo, seleccion, etc.
--   - Use ROW_NUMBER() with :pg_offset/:pg_limit (NOT :offset/:limit which are
--     reserved by ORDS internals for json/collection native pagination).
--   - ORDS ignores ?offset=N&limit=N URL params for POST json/collection.
--     Custom params ?pg_offset=N&pg_limit=N bypass this limitation.
--
-- Frontend: ordsClient.ts sends ?pg_offset=N&pg_limit=N as URL params.
-- App.tsx: uses items.length >= limit heuristic for hasMore detection.
-- Verified: pagination across 62 seed rows confirmed via terminal + browser.
-- ============================================================================

BEGIN
  ORDS.define_handler(
    p_module_name => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern     => 'transacciones/search',
    p_method      => 'POST',
    p_source_type => 'json/collection',
    p_source      => q'[
      SELECT *
        FROM (
          SELECT
            t.id_transaccion,
            TO_CHAR(t.fec_tra, 'YYYY-MM-DD')  AS fec_tra,
            t.cliente,
            t.compania,
            t.ramo,
            t.secuencial,
            t.monto,
            t.estado,
            t.codigo_rechazo,
            t.descripcion_rechazo,
            t.respuesta_banco,
            NULL                               AS num_autoriza,
            NULL                               AS lote_id,
            t.oficial,
            t.nombre_oficial,
            t.gerente,
            t.nombre_gerente,
            t.intermediario,
            t.nombre_intermediario,
            t.seleccion,
            ROW_NUMBER() OVER (
              ORDER BY t.fec_tra DESC, t.id_transaccion DESC
            ) AS rn
          FROM mock_transacciones t
          WHERE (:fec_ini IS NULL OR t.fec_tra >= TO_DATE(:fec_ini, 'YYYY-MM-DD'))
            AND (:fec_fin IS NULL OR t.fec_tra < TO_DATE(:fec_fin, 'YYYY-MM-DD') + 1)
            AND (:cliente IS NULL OR t.cliente = TO_NUMBER(:cliente))
            AND (:oficial IS NULL OR t.oficial = TO_NUMBER(:oficial))
            AND (:gerente IS NULL OR t.gerente = TO_NUMBER(:gerente))
            AND (:intermediario IS NULL OR t.intermediario = TO_NUMBER(:intermediario))
        )
       WHERE rn > NVL(TO_NUMBER(:pg_offset), 0)
         AND rn <= NVL(TO_NUMBER(:pg_offset), 0) + NVL(TO_NUMBER(:pg_limit), 25)
       ORDER BY rn
    ]',
    p_comments    => 'POST search mock_transacciones - SQL pagination via :pg_offset/:pg_limit'
  );
  COMMIT;
  DBMS_OUTPUT.put_line('OK: handler fixed');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('ERR: ' || SQLERRM);
    ROLLBACK;
END;
/
