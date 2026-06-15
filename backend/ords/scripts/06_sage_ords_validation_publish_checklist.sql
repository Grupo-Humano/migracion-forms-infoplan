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
           SELECT
             q.id_transaccion,
             TO_CHAR(q.fecha, ''YYYY-MM-DD'') AS fec_tra,
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
             WHERE (:fec_ini IS NULL OR t.fecha >= TO_DATE(:fec_ini, ''YYYY-MM-DD''))
               AND (:fec_fin IS NULL OR t.fecha < TO_DATE(:fec_fin, ''YYYY-MM-DD'') + 1)
               AND (:cliente IS NULL OR t.cliente = TO_NUMBER(:cliente))
               AND (:oficial IS NULL OR t.oficial = TO_NUMBER(:oficial))
               AND (:gerente IS NULL OR t.gerente = TO_NUMBER(:gerente))
               AND (:intermediario IS NULL OR t.intermediario = TO_NUMBER(:intermediario))
           ) q
           WHERE q.rn > NVL(TO_NUMBER(:offset), 0)
             AND q.rn <= NVL(TO_NUMBER(:offset), 0) + NVL(TO_NUMBER(:limit), 25)
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
             v_rows NUMBER;
           BEGIN
             pkg_rep_aprobarechazo_mock.do_seleccionar(
               p_action => :accion,
               p_rows_affected => v_rows
             );

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
             pkg_rep_aprobarechazo_mock.genera_reporte(v_payload);
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
                            ''fecha'' VALUE TO_CHAR(t.fecha, ''YYYY-MM-DD''),
                            ''cliente'' VALUE t.cliente,
                            ''compania'' VALUE t.compania,
                            ''ramo'' VALUE t.ramo,
                            ''secuencial'' VALUE t.secuencial,
                            ''monto'' VALUE t.monto,
                            ''cod_rechazo'' VALUE t.cod_rechazo,
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
              WHERE t.fecha >= TO_DATE(:fec_ini, ''YYYY-MM-DD'')
                AND t.fecha < TO_DATE(:fec_fin, ''YYYY-MM-DD'') + 1;

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
