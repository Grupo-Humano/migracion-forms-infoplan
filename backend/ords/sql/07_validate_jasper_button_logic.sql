-- Validacion de logica Jasper basada en el boton PUSH_BUTTON331 del Form
-- Fuente: rep_aprobarechazo_fmb.xml (ProgramUnit P_JASPER_A_EXCEL)
--
-- Parametros originales del Form:
--   name=rep_aprobaciones_rechazos
--   documentType=XLS
--   PCODIGO_COMPANIA
--   PDESDE (dd-MON-yyyy, NLS American)
--   PHAS   (dd-MON-yyyy, NLS American)
--   POFICIAL
--   PGERENTE
--   PINTERMEDIARIO

SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE PROCEDURE validate_rep_aprob_jasper_call(
  p_base_url       IN VARCHAR2,
  p_cod_compania   IN VARCHAR2,
  p_fecha_desde    IN DATE,
  p_fecha_hasta    IN DATE,
  p_oficial        IN VARCHAR2 DEFAULT NULL,
  p_gerente        IN VARCHAR2 DEFAULT NULL,
  p_intermediario  IN VARCHAR2 DEFAULT NULL,
  p_report_name    IN VARCHAR2 DEFAULT 'rep_aprobaciones_rechazos',
  p_document_type  IN VARCHAR2 DEFAULT 'XLS'
) IS
  v_desde VARCHAR2(20);
  v_hasta VARCHAR2(20);
  v_url   VARCHAR2(4000);
  v_curl  VARCHAR2(4000);
BEGIN
  IF p_fecha_desde IS NULL OR p_fecha_hasta IS NULL THEN
    RAISE_APPLICATION_ERROR(
      -20001,
      'Debe seleccionar FEC_INI y FEC_FIN para generar Jasper.'
    );
  END IF;

  IF p_fecha_desde > p_fecha_hasta THEN
    RAISE_APPLICATION_ERROR(
      -20002,
      'FEC_INI no puede ser mayor que FEC_FIN.'
    );
  END IF;

  v_desde := TO_CHAR(p_fecha_desde, 'dd-MON-yyyy', 'nls_date_language = American');
  v_hasta := TO_CHAR(p_fecha_hasta, 'dd-MON-yyyy', 'nls_date_language = American');

  v_url := RTRIM(p_base_url, '?')
    || '?name=' || p_report_name
    || '&documentType=' || p_document_type
    || '&PCODIGO_COMPANIA=' || NVL(p_cod_compania, '')
    || '&PDESDE=' || v_desde
    || '&PHAS=' || v_hasta
    || '&POFICIAL=' || NVL(p_oficial, '')
    || '&PGERENTE=' || NVL(p_gerente, '')
    || '&PINTERMEDIARIO=' || NVL(p_intermediario, '');

  v_curl := 'curl --location ''' || v_url || '''';

  DBMS_OUTPUT.PUT_LINE('URL_GENERADA=' || v_url);
  DBMS_OUTPUT.PUT_LINE('CURL_GENERADO=' || v_curl);
END;
/

SHOW ERRORS PROCEDURE validate_rep_aprob_jasper_call;

-- Ejemplo de ejecucion:
-- BEGIN
--   validate_rep_aprob_jasper_call(
--     p_base_url      => 'http://172.24.208.208:31522/api/report',
--     p_cod_compania  => '30',
--     p_fecha_desde   => DATE '2026-05-01',
--     p_fecha_hasta   => DATE '2026-05-31',
--     p_oficial       => '95',
--     p_gerente       => '0',
--     p_intermediario => '0'
--   );
-- END;
-- /


-- ===============================================================
-- Probe HTTP real para validar endpoint Jasper desde Oracle
-- Requiere ACL/network access para UTL_HTTP.
-- ===============================================================
CREATE OR REPLACE PROCEDURE probe_jasper_http_get(
  p_url            IN VARCHAR2,
  p_timeout_secs   IN PLS_INTEGER DEFAULT 30,
  p_body_max_chars IN PLS_INTEGER DEFAULT 4000
) IS
  v_req            UTL_HTTP.req;
  v_resp           UTL_HTTP.resp;
  v_raw_chunk      RAW(32767);
  v_total_bytes    PLS_INTEGER := 0;
  v_preview_hex    VARCHAR2(4000) := NULL;
  v_limit_bytes    PLS_INTEGER;
BEGIN
  IF p_url IS NULL THEN
    RAISE_APPLICATION_ERROR(-20011, 'p_url es requerido.');
  END IF;

  UTL_HTTP.set_transfer_timeout(p_timeout_secs);
  v_req := UTL_HTTP.begin_request(p_url, 'GET', 'HTTP/1.1');
  v_resp := UTL_HTTP.get_response(v_req);

  DBMS_OUTPUT.put_line('HTTP_STATUS=' || v_resp.status_code || ' ' || v_resp.reason_phrase);

  v_limit_bytes := GREATEST(p_body_max_chars, 1);
  BEGIN
    LOOP
      UTL_HTTP.read_raw(v_resp, v_raw_chunk, 32767);
      v_total_bytes := v_total_bytes + NVL(UTL_RAW.length(v_raw_chunk), 0);

      IF v_preview_hex IS NULL AND UTL_RAW.length(v_raw_chunk) > 0 THEN
        v_preview_hex := RAWTOHEX(UTL_RAW.substr(v_raw_chunk, 1, LEAST(32, UTL_RAW.length(v_raw_chunk))));
      END IF;

      EXIT WHEN v_total_bytes >= v_limit_bytes;
    END LOOP;
  EXCEPTION
    WHEN UTL_HTTP.end_of_body THEN
      NULL;
  END;

  UTL_HTTP.end_response(v_resp);

  DBMS_OUTPUT.put_line('BODY_BYTES_READ=' || v_total_bytes);
  IF v_preview_hex IS NOT NULL THEN
    DBMS_OUTPUT.put_line('BODY_PREVIEW_HEX=' || v_preview_hex);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      UTL_HTTP.end_response(v_resp);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    DBMS_OUTPUT.put_line('HTTP_ERROR=' || SQLERRM);
    RAISE;
END;
/

SHOW ERRORS PROCEDURE probe_jasper_http_get;

-- Ejemplo usando el contrato full-data:
-- BEGIN
--   probe_jasper_http_get(
--     p_url => 'http://172.24.208.208:31522/api/report?null=null&name=fac_localg&documentType=PDF&PCOM=30&PRAM=95&PSEC=295444&PFEC=01-MAY-2026&PCLI=9024766&PUSUARIO=LURICHIEZ&PFACTURA=4938479',
--     p_timeout_secs => 60,
--     p_body_max_chars => 2000
--   );
-- END;
-- /


-- ===============================================================
-- Contrato alterno "full data" (no pertenece a rep_aprobarechazo)
-- Basado en curl provisto por usuario.
-- ===============================================================
CREATE OR REPLACE PROCEDURE validate_jasper_full_data_call(
  p_base_url    IN VARCHAR2,
  p_name        IN VARCHAR2 DEFAULT 'fac_localg',
  p_doc_type    IN VARCHAR2 DEFAULT 'PDF',
  p_pcom        IN VARCHAR2,
  p_pram        IN VARCHAR2,
  p_psec        IN VARCHAR2,
  p_pfec        IN VARCHAR2,
  p_pcli        IN VARCHAR2,
  p_pusuario    IN VARCHAR2,
  p_pfactura    IN VARCHAR2,
  p_include_null_param IN BOOLEAN DEFAULT TRUE
) IS
  v_url  VARCHAR2(4000);
  v_curl VARCHAR2(4000);
BEGIN
  v_url := RTRIM(p_base_url, '?') || '?';

  IF p_include_null_param THEN
    v_url := v_url || 'null=null&';
  END IF;

  v_url := v_url
    || 'name=' || NVL(p_name, '')
    || '&documentType=' || NVL(p_doc_type, '')
    || '&PCOM=' || NVL(p_pcom, '')
    || '&PRAM=' || NVL(p_pram, '')
    || '&PSEC=' || NVL(p_psec, '')
    || '&PFEC=' || NVL(p_pfec, '')
    || '&PCLI=' || NVL(p_pcli, '')
    || '&PUSUARIO=' || NVL(p_pusuario, '')
    || '&PFACTURA=' || NVL(p_pfactura, '');

  v_curl := 'curl --location ''' || v_url || '''';

  DBMS_OUTPUT.PUT_LINE('URL_GENERADA=' || v_url);
  DBMS_OUTPUT.PUT_LINE('CURL_GENERADO=' || v_curl);
END;
/

SHOW ERRORS PROCEDURE validate_jasper_full_data_call;

-- Ejemplo de ejecucion (igual al curl recibido):
-- BEGIN
--   validate_jasper_full_data_call(
--     p_base_url => 'http://172.24.208.208:31522/api/report',
--     p_name => 'fac_localg',
--     p_doc_type => 'PDF',
--     p_pcom => '30',
--     p_pram => '95',
--     p_psec => '295444',
--     p_pfec => '01-MAY-2026',
--     p_pcli => '9024766',
--     p_pusuario => 'LURICHIEZ',
--     p_pfactura => '4938479',
--     p_include_null_param => TRUE
--   );
-- END;
-- /
