-- Sprint 1 - Mock package simulating Oracle Forms logic for rep_aprobarechazo.

CREATE OR REPLACE PACKAGE pkg_rep_aprobarechazo_mock AS
  TYPE t_cursor IS REF CURSOR;

  PROCEDURE get_oficial_nombre(
    p_oficial IN NUMBER,
    p_nombre OUT VARCHAR2
  );

  PROCEDURE get_gerente_nombre(
    p_compania IN VARCHAR2,
    p_gerente IN NUMBER,
    p_nombre OUT VARCHAR2
  );

  PROCEDURE get_intermediario_nombre(
    p_compania IN VARCHAR2,
    p_intermediario IN NUMBER,
    p_nombre OUT VARCHAR2
  );

  PROCEDURE busca_transacciones(
    p_fec_ini IN DATE,
    p_fec_fin IN DATE,
    p_cliente IN NUMBER DEFAULT NULL,
    p_oficial IN NUMBER DEFAULT NULL,
    p_gerente IN NUMBER DEFAULT NULL,
    p_intermediario IN NUMBER DEFAULT NULL,
    p_result OUT t_cursor
  );

  PROCEDURE do_seleccionar(
    p_action IN VARCHAR2,
    p_rows_affected OUT NUMBER
  );

  PROCEDURE genera_reporte(
    p_payload OUT CLOB
  );

  PROCEDURE p_jasper_a_excel(
    p_fec_ini IN DATE,
    p_fec_fin IN DATE,
    p_payload OUT CLOB
  );
END pkg_rep_aprobarechazo_mock;
/

CREATE OR REPLACE PACKAGE BODY pkg_rep_aprobarechazo_mock AS
  PROCEDURE assert_fechas(
    p_fec_ini IN DATE,
    p_fec_fin IN DATE
  ) IS
  BEGIN
    IF p_fec_ini IS NULL OR p_fec_fin IS NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'Dato Fecha es requerido para poder ejecutar la busqueda, favor verificar..!');
    END IF;

    IF p_fec_ini > p_fec_fin THEN
      RAISE_APPLICATION_ERROR(-20002, 'Fecha Desde no puede ser mayor que Fecha Hasta, favor verificar..!');
    END IF;
  END assert_fechas;

  PROCEDURE get_oficial_nombre(
    p_oficial IN NUMBER,
    p_nombre OUT VARCHAR2
  ) IS
  BEGIN
    IF p_oficial IS NULL THEN
      p_nombre := NULL;
      RETURN;
    END IF;

    SELECT o.nombre
      INTO p_nombre
      FROM mock_oficiales o
     WHERE o.codigo = p_oficial;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_nombre := NULL;
  END get_oficial_nombre;

  PROCEDURE get_gerente_nombre(
    p_compania IN VARCHAR2,
    p_gerente IN NUMBER,
    p_nombre OUT VARCHAR2
  ) IS
  BEGIN
    IF p_gerente IS NULL THEN
      p_nombre := NULL;
      RETURN;
    END IF;

    SELECT g.nombre
      INTO p_nombre
      FROM mock_gerentes g
     WHERE g.codigo_compania = p_compania
       AND g.codigo = p_gerente;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_nombre := NULL;
  END get_gerente_nombre;

  PROCEDURE get_intermediario_nombre(
    p_compania IN VARCHAR2,
    p_intermediario IN NUMBER,
    p_nombre OUT VARCHAR2
  ) IS
  BEGIN
    IF p_intermediario IS NULL THEN
      p_nombre := NULL;
      RETURN;
    END IF;

    SELECT i.nombre
      INTO p_nombre
      FROM mock_intermediarios i
     WHERE i.codigo_compania = p_compania
       AND i.codigo = p_intermediario;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_nombre := NULL;
  END get_intermediario_nombre;

  PROCEDURE busca_transacciones(
    p_fec_ini IN DATE,
    p_fec_fin IN DATE,
    p_cliente IN NUMBER DEFAULT NULL,
    p_oficial IN NUMBER DEFAULT NULL,
    p_gerente IN NUMBER DEFAULT NULL,
    p_intermediario IN NUMBER DEFAULT NULL,
    p_result OUT t_cursor
  ) IS
  BEGIN
    assert_fechas(p_fec_ini, p_fec_fin);

    OPEN p_result FOR
      SELECT t.id_transaccion,
             t.fec_tra,
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
             t.seleccion,
             t.user_crea,
             t.fecha_crea,
             t.user_actualiza,
             t.fecha_actualiza
        FROM mock_transacciones t
       WHERE t.fec_tra >= TRUNC(p_fec_ini)
         AND t.fec_tra < TRUNC(p_fec_fin) + 1
         AND (p_cliente IS NULL OR t.cliente = p_cliente)
         AND (p_oficial IS NULL OR t.oficial = p_oficial)
         AND (p_gerente IS NULL OR t.gerente = p_gerente)
         AND (p_intermediario IS NULL OR t.intermediario = p_intermediario)
       ORDER BY t.fec_tra, t.id_transaccion;
  END busca_transacciones;

  PROCEDURE do_seleccionar(
    p_action IN VARCHAR2,
    p_rows_affected OUT NUMBER
  ) IS
  BEGIN
    IF p_action = 'M' THEN
      UPDATE mock_transacciones SET seleccion = 'S';
    ELSIF p_action = 'D' THEN
      UPDATE mock_transacciones SET seleccion = 'N';
    ELSE
      RAISE_APPLICATION_ERROR(-20003, 'Accion invalida para seleccionar registros. Use M o D.');
    END IF;

    p_rows_affected := SQL%ROWCOUNT;
    COMMIT;
  END do_seleccionar;

  PROCEDURE genera_reporte(
    p_payload OUT CLOB
  ) IS
    v_total NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_total
      FROM mock_transacciones
     WHERE seleccion = 'S';

    p_payload := JSON_OBJECT(
      'status' VALUE 'OK',
      'report_type' VALUE 'MOCK_OLE_EXCEL',
      'selected_rows' VALUE v_total,
      'message' VALUE 'Mock de genera_reporte ejecutado. Sustituir por XLSX real en Sprint 2.'
    );
  END genera_reporte;

  PROCEDURE p_jasper_a_excel(
    p_fec_ini IN DATE,
    p_fec_fin IN DATE,
    p_payload OUT CLOB
  ) IS
    v_total NUMBER;
  BEGIN
    assert_fechas(p_fec_ini, p_fec_fin);

    SELECT COUNT(*)
      INTO v_total
      FROM mock_transacciones t
     WHERE t.fec_tra >= TRUNC(p_fec_ini)
       AND t.fec_tra < TRUNC(p_fec_fin) + 1;

    p_payload := JSON_OBJECT(
      'status' VALUE 'OK',
      'report_type' VALUE 'MOCK_JASPER_EXCEL',
      'rows_in_range' VALUE v_total,
      'from_date' VALUE TO_CHAR(p_fec_ini, 'YYYY-MM-DD'),
      'to_date' VALUE TO_CHAR(p_fec_fin, 'YYYY-MM-DD'),
      'message' VALUE 'Mock de P_JASPER_A_EXCEL ejecutado. Sustituir por integración Jasper real en Sprint 2.'
    );
  END p_jasper_a_excel;
END pkg_rep_aprobarechazo_mock;
/

SHOW ERRORS PACKAGE pkg_rep_aprobarechazo_mock;
SHOW ERRORS PACKAGE BODY pkg_rep_aprobarechazo_mock;
