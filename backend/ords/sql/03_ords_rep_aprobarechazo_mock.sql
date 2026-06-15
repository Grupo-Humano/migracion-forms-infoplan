-- Sprint 1 - ORDS publication script for mock procedures.
-- Requires ORDS metadata user and privileges.

BEGIN
  ORDS.ENABLE_SCHEMA(
    p_enabled => TRUE,
    p_schema => USER,
    p_url_mapping_type => 'BASE_PATH',
    p_url_mapping_pattern => 'infoplan',
    p_auto_rest_auth => FALSE
  );
END;
/

BEGIN
  ORDS.DEFINE_MODULE(
    p_module_name => 'facturacion-aprobaciones-rechazos-v1',
    p_base_path   => '/facturacion/api/v1/aprobaciones-rechazos/',
    p_items_per_page => 50,
    p_status => 'PUBLISHED'
  );

  ORDS.DEFINE_TEMPLATE(
    p_module_name => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern => 'oficiales/{codigo_oficial}'
  );

  ORDS.DEFINE_HANDLER(
    p_module_name => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern => 'oficiales/{codigo_oficial}',
    p_method => 'GET',
    p_source_type => ORDS.source_type_query_one_row,
    p_source => q'[
      SELECT o.codigo, o.nombre
        FROM mock_oficiales o
       WHERE o.codigo = :codigo_oficial
    ]'
  );

  ORDS.DEFINE_TEMPLATE(
    p_module_name => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern => 'transacciones/search'
  );

  ORDS.DEFINE_HANDLER(
    p_module_name => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern => 'transacciones/search',
    p_method => 'POST',
    p_source_type => ORDS.source_type_collection_feed,
    p_source => q'[
      SELECT t.id_transaccion,
             TO_CHAR(t.fec_tra, 'YYYY-MM-DD') AS fec_tra,
             t.cliente,
             t.compania,
             t.ramo,
             t.secuencial,
             t.monto,
             t.estado,
             t.codigo_rechazo,
             t.descripcion_rechazo,
             t.respuesta_banco,
             t.oficial,
             t.gerente,
             t.intermediario,
             t.nombre_oficial,
             t.nombre_gerente,
             t.nombre_intermediario,
             t.seleccion
        FROM mock_transacciones t
       WHERE t.fec_tra >= TO_DATE(:fec_ini, 'YYYY-MM-DD')
         AND t.fec_tra < TO_DATE(:fec_fin, 'YYYY-MM-DD') + 1
         AND (:cliente IS NULL OR t.cliente = TO_NUMBER(:cliente))
         AND (:oficial IS NULL OR t.oficial = TO_NUMBER(:oficial))
         AND (:gerente IS NULL OR t.gerente = TO_NUMBER(:gerente))
         AND (:intermediario IS NULL OR t.intermediario = TO_NUMBER(:intermediario))
       ORDER BY t.fec_tra, t.id_transaccion
    ]'
  );

  ORDS.DEFINE_TEMPLATE(
    p_module_name => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern => 'transacciones/seleccion/{accion}'
  );

  ORDS.DEFINE_HANDLER(
    p_module_name => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern => 'transacciones/seleccion/{accion}',
    p_method => 'POST',
    p_source_type => ORDS.source_type_plsql,
    p_source => q'[
      DECLARE
        v_rows NUMBER;
      BEGIN
        pkg_rep_aprobarechazo_mock.do_seleccionar(
          p_action => :accion,
          p_rows_affected => v_rows
        );

        :status_code := 200;
        :response := JSON_OBJECT(
          'status' VALUE 'OK',
          'rows_affected' VALUE v_rows,
          'action' VALUE :accion
        );
      END;
    ]'
  );

  ORDS.DEFINE_TEMPLATE(
    p_module_name => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern => 'exportaciones/ole'
  );

  ORDS.DEFINE_HANDLER(
    p_module_name => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern => 'exportaciones/ole',
    p_method => 'POST',
    p_source_type => ORDS.source_type_plsql,
    p_source => q'[
      DECLARE
        v_payload CLOB;
      BEGIN
        pkg_rep_aprobarechazo_mock.genera_reporte(v_payload);
        :status_code := 200;
        :response := v_payload;
      END;
    ]'
  );

  ORDS.DEFINE_TEMPLATE(
    p_module_name => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern => 'exportaciones/jasper'
  );

  ORDS.DEFINE_HANDLER(
    p_module_name => 'facturacion-aprobaciones-rechazos-v1',
    p_pattern => 'exportaciones/jasper',
    p_method => 'POST',
    p_source_type => ORDS.source_type_plsql,
    p_source => q'[
      DECLARE
        v_payload CLOB;
      BEGIN
        pkg_rep_aprobarechazo_mock.p_jasper_a_excel(
          p_fec_ini => TO_DATE(:fec_ini, 'YYYY-MM-DD'),
          p_fec_fin => TO_DATE(:fec_fin, 'YYYY-MM-DD'),
          p_payload => v_payload
        );

        :status_code := 200;
        :response := v_payload;
      END;
    ]'
  );

  COMMIT;
END;
/
