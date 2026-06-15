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
         p_source      => 'select id_transaccion, fecha, compania, ramo, secuencial, monto, cod_rechazo, respuesta_banco, num_autoriza, lote_id from transacciones_cobro_recurrente fetch first 500 rows only'); END;]'
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
