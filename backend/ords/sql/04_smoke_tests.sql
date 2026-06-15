-- Sprint 1 smoke tests for pkg_rep_aprobarechazo_mock
-- Run this after 01, 02 and 03 scripts.

SET SERVEROUTPUT ON;

DECLARE
  v_nombre VARCHAR2(100);
BEGIN
  pkg_rep_aprobarechazo_mock.get_oficial_nombre(101, v_nombre);
  DBMS_OUTPUT.PUT_LINE('GET_OFICIAL_NOMBRE(101): ' || NVL(v_nombre, 'NULL'));

  pkg_rep_aprobarechazo_mock.get_gerente_nombre('1', 201, v_nombre);
  DBMS_OUTPUT.PUT_LINE('GET_GERENTE_NOMBRE(1,201): ' || NVL(v_nombre, 'NULL'));

  pkg_rep_aprobarechazo_mock.get_intermediario_nombre('1', 301, v_nombre);
  DBMS_OUTPUT.PUT_LINE('GET_INTERMEDIARIO_NOMBRE(1,301): ' || NVL(v_nombre, 'NULL'));
END;
/

DECLARE
  v_rows NUMBER;
BEGIN
  pkg_rep_aprobarechazo_mock.do_seleccionar('M', v_rows);
  DBMS_OUTPUT.PUT_LINE('DO_SELECCIONAR(M) rows: ' || v_rows);

  pkg_rep_aprobarechazo_mock.do_seleccionar('D', v_rows);
  DBMS_OUTPUT.PUT_LINE('DO_SELECCIONAR(D) rows: ' || v_rows);
END;
/

DECLARE
  c pkg_rep_aprobarechazo_mock.t_cursor;
  v_count NUMBER := 0;
  v_id NUMBER;
  v_fec DATE;
  v_cliente NUMBER;
  v_compania NUMBER;
  v_ramo NUMBER;
  v_secuencial NUMBER;
  v_monto NUMBER;
  v_estado VARCHAR2(10);
  v_cod_rech VARCHAR2(20);
  v_desc_rech VARCHAR2(500);
  v_resp_banco VARCHAR2(500);
  v_oficial NUMBER;
  v_gerente NUMBER;
  v_intermediario NUMBER;
  v_nom_of VARCHAR2(100);
  v_nom_ge VARCHAR2(100);
  v_nom_in VARCHAR2(100);
  v_sel CHAR(1);
  v_user_crea VARCHAR2(30);
  v_fecha_crea DATE;
  v_user_act VARCHAR2(30);
  v_fecha_act DATE;
BEGIN
  pkg_rep_aprobarechazo_mock.busca_transacciones(
    p_fec_ini => TRUNC(SYSDATE) - 10,
    p_fec_fin => TRUNC(SYSDATE),
    p_cliente => NULL,
    p_oficial => NULL,
    p_gerente => NULL,
    p_intermediario => NULL,
    p_result => c
  );

  LOOP
    FETCH c INTO
      v_id, v_fec, v_cliente, v_compania, v_ramo, v_secuencial, v_monto,
      v_estado, v_cod_rech, v_desc_rech, v_resp_banco,
      v_oficial, v_gerente, v_intermediario, v_nom_of, v_nom_ge, v_nom_in,
      v_sel, v_user_crea, v_fecha_crea, v_user_act, v_fecha_act;
    EXIT WHEN c%NOTFOUND;
    v_count := v_count + 1;
  END LOOP;

  CLOSE c;
  DBMS_OUTPUT.PUT_LINE('BUSCA_TRANSACCIONES rows: ' || v_count);
END;
/

DECLARE
  v_payload CLOB;
BEGIN
  pkg_rep_aprobarechazo_mock.genera_reporte(v_payload);
  DBMS_OUTPUT.PUT_LINE('GENERA_REPORTE payload: ' || DBMS_LOB.SUBSTR(v_payload, 4000, 1));

  pkg_rep_aprobarechazo_mock.p_jasper_a_excel(TRUNC(SYSDATE) - 10, TRUNC(SYSDATE), v_payload);
  DBMS_OUTPUT.PUT_LINE('P_JASPER_A_EXCEL payload: ' || DBMS_LOB.SUBSTR(v_payload, 4000, 1));
END;
/
