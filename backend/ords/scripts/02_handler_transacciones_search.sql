-- ============================================================================
-- ORDS HANDLER DEPLOYMENT SCRIPT #2: transacciones/search Handler (REAL ONLY)
-- ============================================================================
-- Purpose: Deploy POST /transacciones/search using real transactional sources
-- Method: POST (search with filters)
-- Handler Type: json/collection (ORDS feed)
-- Pagination: explicit pg_offset/pg_limit support with stable ORDER BY
-- Note: This script is intentionally mock-free.
-- ============================================================================

BEGIN
  -- Create POST handler for /transacciones/search
  ORDS.create_handler(
    p_module_name    => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern        => 'transacciones/search',
    p_method         => 'POST',
    p_source_type    => 'json/collection',
    p_source         => q'[
      WITH poliza_info AS (
        SELECT pol.compania, pol.ramo, pol.secuencial,
               pol.estatus, pol.fre_pag
          FROM poliza01_v pol
      ),
      pol_intermediario AS (
        SELECT pi.compania, pi.ramo, pi.secuencial, pi.intermediario
          FROM pol_int01_v pi
         WHERE NVL(pi.principal, 'N') = 'S'
      ),
      telefonos_rank AS (
        SELECT tel.codigo,
               tel.telefono,
               ROW_NUMBER() OVER (
                 PARTITION BY tel.codigo
                 ORDER BY CASE WHEN NVL(TO_CHAR(tel.principal), 'N') = 'S' THEN 0 ELSE 1 END,
                          NULLIF(TRIM(TO_CHAR(tel.codigo_telefono_prioridad)), ''),
                          tel.codigo
               ) AS rn
          FROM telefono tel
         WHERE tel.telefono IS NOT NULL
           AND TRIM(tel.telefono) IS NOT NULL
      ),
      telefonos AS (
        SELECT codigo,
               MAX(CASE WHEN rn = 1 THEN telefono END) AS telefono_1,
               MAX(CASE WHEN rn = 2 THEN telefono END) AS telefono_2,
               MAX(CASE WHEN rn = 3 THEN telefono END) AS telefono_3
          FROM telefonos_rank
         WHERE rn <= 3
         GROUP BY codigo
      )
      SELECT
        q.id_transaccion,
        q.fec_tra,
        q.cliente,
        q.compania,
        q.ramo,
        q.secuencial,
        q.monto,
        q.estado,
        q.codigo_rechazo,
        q.descripcion_rechazo,
        q.respuesta_banco,
        q.num_autoriza,
        q.lote_id,
        q.oficial,
        q.gerente,
        q.intermediario,
        q.nombre_oficial,
        q.nombre_gerente,
        q.nombre_intermediario,
        q.cliente_poliza,
        q.estatus_poliza,
        q.frecuencia_pago,
        q.tipo_documento,
        q.num_documento,
        q.nombre_director,
        q.grupo,
        q.user_crea,
        q.fecha_crea,
        q.user_actualiza,
        q.fecha_actualiza,
        q.telefono_1,
        q.telefono_2,
        q.telefono_3,
        q.seleccion
      FROM (
        SELECT
          t.id_transaccion,
          TO_CHAR(t.fec_tra, 'YYYY-MM-DD')                          AS fec_tra,
          t.cliente,
          t.compania,
          t.ramo,
          t.secuencial,
          t.monto,
          t.estado,
          t.codigo_rechazo,
          t.descripcion_rechazo,
          t.respuesta_banco,
          t.num_autoriza,
          t.lote_id,
          d.cdofic                                                   AS oficial,
          en.cod_ger                                                 AS gerente,
          pi.intermediario,
          SUBSTR(DECODE(clte2.tipo,
                        'C', clte2.nom_emp,
                        clte2.pri_nom || ' ' || clte2.pri_ape),
                 1, 100)                                             AS nombre_oficial,
          SUBSTR(en.nombre_gerente, 1, 100)                         AS nombre_gerente,
          COALESCE(
            SUBSTR(en.nombre_intermediario, 1, 100),
            SUBSTR(i01.nombre, 1, 100)
          )                                                          AS nombre_intermediario,
          SUBSTR(DECODE(clte.tipo,
                        'C', clte.nom_emp,
                        clte.pri_nom || ' ' || clte.pri_ape),
                 1, 120)                                             AS cliente_poliza,
          e.descripcion                                              AS estatus_poliza,
          fp.descripcion                                             AS frecuencia_pago,
          CASE WHEN clte.tipo = 'C' THEN 'RNC' ELSE 'CEDULA' END    AS tipo_documento,
          CASE
            WHEN clte.tipo = 'C' THEN NULLIF(TRIM(clte.rnc), '')
            ELSE NULLIF(TRIM(clte.ced_act), '')
          END                                                        AS num_documento,
          SUBSTR(en.nombre_director, 1, 100)                        AS nombre_director,
          NULLIF(TRIM(clte.sec_eco), '')                            AS grupo,
          t.user_crea,
          TO_CHAR(t.fecha_crea, 'YYYY-MM-DD HH24:MI:SS')            AS fecha_crea,
          t.user_actualiza,
          TO_CHAR(t.fecha_actualiza, 'YYYY-MM-DD HH24:MI:SS')       AS fecha_actualiza,
          tp.telefono_1                                              AS telefono_1,
          tp.telefono_2                                              AS telefono_2,
          tp.telefono_3                                              AS telefono_3,
          CASE WHEN NVL(t.seleccionado, 0) = 1 THEN 'S' ELSE 'N' END AS seleccion,
          ROW_NUMBER() OVER (
            ORDER BY t.fec_tra DESC, t.id_transaccion DESC
          )                                                          AS rn
        FROM transacciones_cobro_recurrente t
        JOIN cliente clte
          ON clte.codigo = t.cliente
        LEFT JOIN poliza_info pol
          ON pol.compania = t.compania
         AND pol.ramo = t.ramo
         AND pol.secuencial = t.secuencial
        LEFT JOIN estatus e
          ON e.codigo = pol.estatus
         AND e.tipo = 'POL'
        LEFT JOIN pol_intermediario pi
          ON pi.compania = t.compania
         AND pi.ramo = t.ramo
         AND pi.secuencial = t.secuencial
        LEFT JOIN int_ger_dir01_v en
          ON en.intermediario = pi.intermediario
         AND en.compania = t.compania
        LEFT JOIN intermediario01_v i01
          ON i01.codigo = pi.intermediario
        LEFT JOIN frecuencia fp
          ON fp.frepag_dias = pol.fre_pag
        LEFT JOIN moficial d
          ON d.cdofic = pi.intermediario
        LEFT JOIN cliente clte2
          ON clte2.codigo = d.cdperson
        LEFT JOIN telefonos tp
          ON tp.codigo = t.cliente
        WHERE (:fec_ini IS NULL OR t.fec_tra >= TO_DATE(:fec_ini, 'YYYY-MM-DD'))
          AND (:fec_fin IS NULL OR t.fec_tra < TO_DATE(:fec_fin, 'YYYY-MM-DD') + 1)
          AND (:cliente IS NULL OR t.cliente = TO_NUMBER(:cliente))
          AND (:oficial IS NULL OR d.cdofic = TO_NUMBER(:oficial))
          AND (:gerente IS NULL OR en.cod_ger = TO_NUMBER(:gerente))
          AND (:intermediario IS NULL OR pi.intermediario = TO_NUMBER(:intermediario))
      ) q
      WHERE q.rn > NVL(TO_NUMBER(:pg_offset), 0)
        AND q.rn <= NVL(TO_NUMBER(:pg_offset), 0) + NVL(TO_NUMBER(:pg_limit), 25)
      ORDER BY q.rn
    ]',
    p_comments       => 'POST search real transactions with Jasper-aligned columns and pg_offset/pg_limit pagination'
  );
  
  COMMIT;
  
  DBMS_OUTPUT.put_line('Handler created: POST /transacciones/search (REAL ONLY)');
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Error: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END;
/

-- ============================================================================
-- END: transacciones/search Handler
-- ============================================================================
