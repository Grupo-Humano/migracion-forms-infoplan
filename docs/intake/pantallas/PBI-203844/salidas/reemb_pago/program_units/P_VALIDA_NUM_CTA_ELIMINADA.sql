-- PROGRAM UNIT: P_VALIDA_NUM_CTA_ELIMINADA
-- Tipo: Procedure
-- ====================================================================

-- Enfoco 20/12/2024.- Mejoras Reembolso.
PROCEDURE P_VALIDA_NUM_CTA_ELIMINADA(P_TIP_PRO     IN VARCHAR2,
                                     P_PROPETARIO  IN NUMBER, 
                                     P_TIPO_CTA    IN VARCHAR2,
                                     P_BANCO       IN NUMBER,
                                     P_NUMCTA      IN VARCHAR2,
                                     P_PROPIETARIO_TIPO_ID IN VARCHAR2,
                                     P_PROPIETARIO_NUM_ID  IN VARCHAR2) IS
  --
  v_msg_cuenta_elim VARCHAR2(500) := F_OBTEN_PARAMETRO_SEUS('MSG_CUENTA_ELIMI');
  v_existe          NUMBER(2);
  v_tipo_cuenta     VARCHAR2(2);
  --
  CURSOR CUR_CUENTA_ELIMINADA IS
    SELECT 1
      FROM NUMERO_CUENTA_ELIMINADA A, 
           NUMERO_CUENTA_INFO_ELI B
     WHERE A.TIP_PRO     = P_TIP_PRO
       AND A.PROPIETARIO = P_PROPETARIO
       AND A.TIP_CTA     = v_tipo_cuenta
       AND A.BANCO       = P_BANCO
       AND A.NUM_CTA     = P_NUMCTA
       AND B.CODIGO      = A.CODIGO 
       AND B.CONTRATANTE_TIPO_ID = P_PROPIETARIO_TIPO_ID
       AND B.CONTRATANTE_CED = P_PROPIETARIO_NUM_ID;
BEGIN
  SELECT DECODE(P_TIPO_CTA,'AHOR','A','C') INTO v_tipo_cuenta
    FROM DUAL;
  --     
  v_existe := 0;
  OPEN CUR_CUENTA_ELIMINADA;
  FETCH CUR_CUENTA_ELIMINADA INTO V_EXISTE;
  CLOSE CUR_CUENTA_ELIMINADA;
  --
  IF v_existe > 0 THEN
     MSG_ALERT(V_MSG_CUENTA_ELIM,'E', FALSE);
     RAISE FORM_TRIGGER_FAILURE;
  END IF;
END;
