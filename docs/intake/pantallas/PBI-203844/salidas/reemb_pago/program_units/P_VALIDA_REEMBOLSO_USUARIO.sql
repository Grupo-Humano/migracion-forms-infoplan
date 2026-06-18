-- PROGRAM UNIT: P_VALIDA_REEMBOLSO_USUARIO
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_VALIDA_REEMBOLSO_USUARIO IS
  v_compania    NUMBER := :GLOBAL.COD_COMPANIA; -- Aquí asigna el valor correspondiente de la compañía
  v_usuario     VARCHAR2(50) := USER; --'OHEREDIA'; -- Aquí asigna el usuario correspondiente
  v_asegurado   NUMBER(10) := to_number(SUBSTR(NVL(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,:CG$CTRL.NO_AFI),1,7));
  v_encontrado  NUMBER;
  v_mensaje     VARCHAR2(300);
  v_msg_id      NUMBER(10) := 0;
BEGIN
  -- Llamada al procedimiento P_VALIDAR_NUCLEO_REEMBOLSO
  REEMBOLSO.P_VALIDAR_NUCLEO_REEMBOLSO(P_COMPANIA   => v_compania,
                                       P_USUARIO    => v_usuario,
                                       P_ASEGURADO  => v_asegurado,
                                       P_ENCONTRADO => v_encontrado,
                                       P_MENSAJE    => v_mensaje
                                       );
  -- Mostrar resultados
  IF v_encontrado != F_OBTEN_PARAMETRO_SEUS('P_RESPUESTA_OK', v_compania) THEN
     p_imprime_mensaje(v_msg_id, v_mensaje);
     RAISE FORM_TRIGGER_FAILURE;
  END IF;
END;
