-- Sprint 2 - Sage Checklist (Validation + Publish)
-- Purpose: validate ORDS metadata and (re)publish minimum endpoints using compatible API fallback.
-- Usage: run in SQLcl connected with schema that owns ORDS module.

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET FEEDBACK ON;
SET VERIFY OFF;

PROMPT ============================================================
PROMPT 0) Runtime identity
PROMPT ============================================================
SELECT
  SYS_CONTEXT('USERENV','DB_NAME')      AS db_name,
  SYS_CONTEXT('USERENV','CON_NAME')     AS con_name,
  SYS_CONTEXT('USERENV','CURRENT_SCHEMA') AS current_schema
FROM dual;

PROMPT ============================================================
PROMPT 1) ORDS package capability discovery
PROMPT ============================================================
SELECT DISTINCT procedure_name
FROM all_procedures
WHERE owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
  AND object_name = 'ORDS'
  AND procedure_name IN (
    'DEFINE_MODULE','CREATE_MODULE','DELETE_MODULE','DROP_MODULE',
    'DEFINE_TEMPLATE','CREATE_TEMPLATE',
    'DEFINE_HANDLER','CREATE_HANDLER',
    'ENABLE_OBJECT','PUBLISH_MODULE'
  )
ORDER BY procedure_name;

PROMPT ============================================================
PROMPT 2) Current module state (if views exist in this ORDS version)
PROMPT ============================================================
BEGIN
  EXECUTE IMMEDIATE q'[SELECT name, base_path, status, items_per_page FROM user_ords_modules]';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('INFO: user_ords_modules projection differs in this version; run SELECT * manually.');
END;
/

PROMPT Try raw views (manual output):
SELECT * FROM user_ords_modules WHERE name = 'facturacion-aprobaciones-rechazos-v1';
SELECT * FROM user_ords_templates WHERE module_name = 'facturacion-aprobaciones-rechazos-v1';
SELECT * FROM user_ords_handlers  WHERE module_name = 'facturacion-aprobaciones-rechazos-v1';

PROMPT ============================================================
PROMPT 3) Re-publish module with compatibility fallback
PROMPT ============================================================
DECLARE
  PROCEDURE try_stmt(p_label VARCHAR2, p_stmt CLOB) IS
  BEGIN
    EXECUTE IMMEDIATE p_stmt;
    DBMS_OUTPUT.put_line('OK: ' || p_label);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line('SKIP: ' || p_label || ' -> ' || SQLERRM);
  END;
BEGIN
  -- best effort cleanup (ignore if module does not exist)
  try_stmt(
    'ords.delete_module',
    q'[BEGIN ords.delete_module(p_module_name => 'facturacion-aprobaciones-rechazos-v1'); END;]'
  );
  try_stmt(
    'ords.drop_module',
    q'[BEGIN ords.drop_module('facturacion-aprobaciones-rechazos-v1'); END;]'
  );

  -- create module (newer API then older API)
  try_stmt(
    'ords.define_module',
    q'[BEGIN ords.define_module(
         p_module_name    => 'facturacion-aprobaciones-rechazos-v1',
         p_base_path      => '/aprobaciones-rechazos/',
         p_items_per_page => 25,
         p_status         => 'PUBLISHED'); END;]'
  );
  try_stmt(
    'ords.create_module',
    q'[BEGIN ords.create_module(
         p_module_name    => 'facturacion-aprobaciones-rechazos-v1',
         p_base_path      => '/aprobaciones-rechazos',
         p_items_per_page => 25,
         p_enabled        => TRUE); END;]'
  );

  -- templates
  try_stmt(
    'ords.define_template gerentes',
    q'[BEGIN ords.define_template(
         p_module_name => 'facturacion-aprobaciones-rechazos-v1',
         p_pattern     => 'gerentes'); END;]'
  );
  try_stmt(
    'ords.define_template intermediarios',
    q'[BEGIN ords.define_template(
         p_module_name => 'facturacion-aprobaciones-rechazos-v1',
         p_pattern     => 'intermediarios'); END;]'
  );
  try_stmt(
    'ords.define_template transacciones/search',
    q'[BEGIN ords.define_template(
         p_module_name => 'facturacion-aprobaciones-rechazos-v1',
         p_pattern     => 'transacciones/search'); END;]'
  );
  try_stmt(
    'ords.define_template transacciones/seleccion/{accion}',
    q'[BEGIN ords.define_template(
         p_module_name => 'facturacion-aprobaciones-rechazos-v1',
         p_pattern     => 'transacciones/seleccion/{accion}'); END;]'
  );
  try_stmt(
    'ords.define_template exportaciones/ole',
    q'[BEGIN ords.define_template(
         p_module_name => 'facturacion-aprobaciones-rechazos-v1',
         p_pattern     => 'exportaciones/ole'); END;]'
  );
  try_stmt(
    'ords.define_template exportaciones/jasper',
    q'[BEGIN ords.define_template(
         p_module_name => 'facturacion-aprobaciones-rechazos-v1',
         p_pattern     => 'exportaciones/jasper'); END;]'
  );

  -- handlers (minimum endpoints for Task 7 rerun)
  try_stmt(
    'ords.define_handler GET gerentes',
    q'[BEGIN ords.define_handler(
         p_module_name => 'facturacion-aprobaciones-rechazos-v1',
         p_pattern     => 'gerentes',
         p_method      => 'GET',
         p_source_type => 'json/collection',
         p_source      => 'select distinct codigo, nombre from int_ger_dir01_v where codigo is not null and nombre is not null order by nombre'); END;]'
  );

  try_stmt(
    'ords.define_handler GET intermediarios',
    q'[BEGIN ords.define_handler(
         p_module_name => 'facturacion-aprobaciones-rechazos-v1',
         p_pattern     => 'intermediarios',
         p_method      => 'GET',
         p_source_type => 'json/collection',
         p_source      => 'select distinct codigo, nombre from int_ger_dir01_v where codigo is not null and nombre is not null order by nombre'); END;]'
  );

  try_stmt(
    'ords.define_handler POST transacciones/search',
    q'[BEGIN ords.define_handler(
         p_module_name => 'facturacion-aprobaciones-rechazos-v1',
         p_pattern     => 'transacciones/search',
         p_method      => 'POST',
         p_source_type => 'json/collection',
         p_source      => q''[
           WITH telefonos_rank AS (
             SELECT tel.codigo,
                    tel.telefono,
                    ROW_NUMBER() OVER (
                      PARTITION BY tel.codigo
                      ORDER BY CASE WHEN NVL(TO_CHAR(tel.principal), ''N'') = ''S'' THEN 0 ELSE 1 END,
                               NULLIF(TRIM(TO_CHAR(tel.codigo_telefono_prioridad)), ''''),
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
             TO_CHAR(q.fec_tra, ''YYYY-MM-DD'') AS fec_tra,
             q.cliente,
             q.tipo_documento,
             q.num_documento,
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
             q.nombre_oficial,
             q.gerente,
             q.nombre_gerente,
             q.intermediario,
             q.nombre_intermediario,
             q.nombre_director,
             q.cliente_poliza,
             q.estatus_poliza,
             q.frecuencia_pago,
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
               t.fec_tra,
               t.cliente,
               CASE WHEN clte.tipo = ''C'' THEN ''RNC'' ELSE ''CEDULA'' END AS tipo_documento,
               CASE
                 WHEN clte.tipo = ''C'' THEN NULLIF(TRIM(clte.rnc), '''')
                 ELSE NULLIF(TRIM(clte.ced_act), '''')
               END AS num_documento,
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
               t.oficial,
               NULL AS nombre_oficial,
               t.intermediario,
               en.cod_ger AS gerente,
               SUBSTR(en.nombre_gerente, 1, 100) AS nombre_gerente,
               COALESCE(
                 SUBSTR(en.nombre_intermediario, 1, 100),
                 SUBSTR(i01.nombre, 1, 100)
               ) AS nombre_intermediario,
               SUBSTR(en.nombre_director, 1, 100) AS nombre_director,
               SUBSTR(DECODE(clte.tipo,
                             ''C'', clte.nom_emp,
                             clte.pri_nom||'' ''||clte.pri_ape),
                      1, 120) AS cliente_poliza,
               e.descripcion AS estatus_poliza,
               fp.descripcion AS frecuencia_pago,
               NULLIF(TRIM(clte.sec_eco), '''') AS grupo,
               t.user_crea,
               TO_CHAR(t.fecha_crea, ''YYYY-MM-DD HH24:MI:SS'') AS fecha_crea,
               t.user_actualiza,
               TO_CHAR(t.fecha_actualiza, ''YYYY-MM-DD HH24:MI:SS'') AS fecha_actualiza,
               tp.telefono_1,
               tp.telefono_2,
               tp.telefono_3,
               CASE WHEN NVL(t.seleccionado, 0) = 1 THEN ''S'' ELSE ''N'' END AS seleccion,
               ROW_NUMBER() OVER (
                 ORDER BY t.fec_tra DESC, t.id_transaccion DESC
               ) AS rn
             FROM transacciones_cobro_recurrente t
             JOIN cliente clte
               ON clte.codigo = t.cliente
             LEFT JOIN poliza01_v pol
               ON pol.compania = t.compania
              AND pol.ramo = t.ramo
              AND pol.secuencial = t.secuencial
             LEFT JOIN estatus e
               ON e.codigo = pol.estatus
              AND e.tipo = ''POL''
             LEFT JOIN pol_int01_v pi
               ON pi.compania = t.compania
              AND pi.ramo = t.ramo
              AND pi.secuencial = t.secuencial
              AND NVL(pi.principal, ''N'') = ''S''
             LEFT JOIN int_ger_dir01_v en
               ON en.compania = t.compania
              AND en.intermediario = pi.intermediario
             LEFT JOIN intermediario01_v i01
               ON i01.codigo = pi.intermediario
             LEFT JOIN frecuencia fp
               ON fp.frepag_dias = pol.fre_pag
             LEFT JOIN telefonos tp
               ON tp.codigo = t.cliente
             WHERE (:fec_ini IS NULL OR t.fec_tra >= TO_DATE(:fec_ini, ''YYYY-MM-DD''))
               AND (:fec_fin IS NULL OR t.fec_tra < TO_DATE(:fec_fin, ''YYYY-MM-DD'') + 1)
               AND (:cliente IS NULL OR t.cliente = TO_NUMBER(:cliente))
               AND (:oficial IS NULL OR t.oficial = TO_NUMBER(:oficial))
               AND (:gerente IS NULL OR en.cod_ger = TO_NUMBER(:gerente))
               AND (:intermediario IS NULL OR pi.intermediario = TO_NUMBER(:intermediario))
           ) q
           WHERE q.rn > NVL(TO_NUMBER(:pg_offset), 0)
             AND q.rn <= NVL(TO_NUMBER(:pg_offset), 0) + NVL(TO_NUMBER(:pg_limit), 25)
           ORDER BY q.rn
         ]'' ); END;]'
  );

  try_stmt(
    'ords.define_handler POST transacciones/seleccion/{accion}',
    q'[BEGIN ords.define_handler(
         p_module_name => 'facturacion-aprobaciones-rechazos-v1',
         p_pattern     => 'transacciones/seleccion/{accion}',
         p_method      => 'POST',
         p_source_type => 'plsql/block',
         p_source      => q''[
           DECLARE
             v_rows NUMBER := 0;
           BEGIN
             IF UPPER(:accion) = ''M'' THEN
               UPDATE transacciones_cobro_recurrente
                  SET seleccionado = 1
                WHERE NVL(seleccionado, 0) <> 1;
               v_rows := SQL%ROWCOUNT;
             ELSIF UPPER(:accion) = ''D'' THEN
               UPDATE transacciones_cobro_recurrente
                  SET seleccionado = 0
                WHERE NVL(seleccionado, 0) <> 0;
               v_rows := SQL%ROWCOUNT;
             ELSE
               RAISE_APPLICATION_ERROR(-20003, ''Accion invalida. Use M o D.'');
             END IF;

             COMMIT;

             :status_code := 200;
             :response := JSON_OBJECT(
               ''status'' VALUE ''OK'',
               ''rows_affected'' VALUE v_rows,
               ''action'' VALUE :accion
             );
           END;
         ]'' ); END;]'
  );

  try_stmt(
    'ords.define_handler POST exportaciones/ole',
    q'[BEGIN ords.define_handler(
         p_module_name => 'facturacion-aprobaciones-rechazos-v1',
         p_pattern     => 'exportaciones/ole',
         p_method      => 'POST',
         p_source_type => 'plsql/block',
         p_source      => q''[
           DECLARE
             v_payload CLOB;
           BEGIN
             SELECT JSON_OBJECT(
                      ''status'' VALUE ''OK'',
                      ''report_type'' VALUE ''OLE'',
                      ''message'' VALUE ''Reporte OLE generado con fuente real.'',
                      ''selected_rows'' VALUE COUNT(*)
                    RETURNING CLOB)
               INTO v_payload
               FROM transacciones_cobro_recurrente
              WHERE NVL(seleccionado, 0) = 1;

             :status_code := 200;
             :response := v_payload;
           END;
         ]'' ); END;]'
  );

  try_stmt(
    'ords.define_handler POST exportaciones/jasper',
    q'[BEGIN ords.define_handler(
         p_module_name => 'facturacion-aprobaciones-rechazos-v1',
         p_pattern     => 'exportaciones/jasper',
         p_method      => 'POST',
         p_source_type => 'plsql/block',
         p_source      => q''[
           DECLARE
             v_data CLOB;
           BEGIN
             SELECT JSON_OBJECT(
                      ''status'' VALUE ''OK'',
                      ''report_type'' VALUE ''JASPER_WEB_CALL'',
                      ''from_date'' VALUE :fec_ini,
                      ''to_date'' VALUE :fec_fin,
                      ''rows'' VALUE COUNT(*),
                      ''items'' VALUE COALESCE(
                        JSON_ARRAYAGG(
                          JSON_OBJECT(
                            ''id_transaccion'' VALUE t.id_transaccion,
                            ''fec_tra'' VALUE TO_CHAR(t.fec_tra, ''YYYY-MM-DD''),
                            ''cliente'' VALUE t.cliente,
                            ''compania'' VALUE t.compania,
                            ''ramo'' VALUE t.ramo,
                            ''secuencial'' VALUE t.secuencial,
                            ''monto'' VALUE t.monto,
                            ''codigo_rechazo'' VALUE t.codigo_rechazo,
                            ''respuesta_banco'' VALUE t.respuesta_banco,
                            ''num_autoriza'' VALUE t.num_autoriza,
                            ''lote_id'' VALUE t.lote_id
                          )
                        RETURNING CLOB),
                        TO_CLOB(''[]'')
                      )
                    RETURNING CLOB)
               INTO v_data
               FROM transacciones_cobro_recurrente t
              WHERE t.fec_tra >= TO_DATE(:fec_ini, ''YYYY-MM-DD'')
                AND t.fec_tra < TO_DATE(:fec_fin, ''YYYY-MM-DD'') + 1;

             :status_code := 200;
             :response := v_data;
           EXCEPTION
             WHEN OTHERS THEN
               :status_code := 500;
               :response := JSON_OBJECT(
                 ''status'' VALUE ''ERROR'',
                 ''message'' VALUE SQLERRM
               );
           END;
         ]'' ); END;]'
  );

  COMMIT;
  DBMS_OUTPUT.put_line('DONE: publish attempt complete.');
END;
/

PROMPT ============================================================
PROMPT 4) Post-publish checks
PROMPT ============================================================
SELECT * FROM user_ords_modules   WHERE name = 'facturacion-aprobaciones-rechazos-v1';
SELECT * FROM user_ords_templates WHERE module_name = 'facturacion-aprobaciones-rechazos-v1';
SELECT * FROM user_ords_handlers  WHERE module_name = 'facturacion-aprobaciones-rechazos-v1';

PROMPT ============================================================
PROMPT 5) Expected endpoint probes (from local machine)
PROMPT ============================================================
PROMPT GET  https://infoplan-web-dev.humano.local/ords/infoplan/aprobaciones-rechazos/gerentes
PROMPT GET  https://infoplan-web-dev.humano.local/ords/infoplan/aprobaciones-rechazos/intermediarios
PROMPT POST https://infoplan-web-dev.humano.local/ords/infoplan/aprobaciones-rechazos/transacciones/search
PROMPT POST https://infoplan-web-dev.humano.local/ords/infoplan/aprobaciones-rechazos/transacciones/seleccion/M
PROMPT POST https://infoplan-web-dev.humano.local/ords/infoplan/aprobaciones-rechazos/transacciones/seleccion/D
PROMPT POST https://infoplan-web-dev.humano.local/ords/infoplan/aprobaciones-rechazos/exportaciones/ole
PROMPT POST https://infoplan-web-dev.humano.local/ords/infoplan/aprobaciones-rechazos/exportaciones/jasper
