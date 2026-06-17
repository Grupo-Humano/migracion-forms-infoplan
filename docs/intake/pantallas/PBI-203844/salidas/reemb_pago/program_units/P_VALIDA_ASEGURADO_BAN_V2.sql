-- PROGRAM UNIT: P_VALIDA_ASEGURADO_BAN_V2
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_VALIDA_ASEGURADO_BAN_V2 IS  
-- Enfoco(GM) 18/11/2024.- Proyecto Lista Negra. se duplico el proceso para incluir modificaciones varias
  v_baneado            NUMBER;
  v_nombre_completo    VARCHAR2(2000);
  v_beneficiario_id    VARCHAR2(200);
  v_estado_blacklist   NUMBER;
  v_motivo_adj         VARCHAR2(3000);
  v_fec_tra_bloq       DATE; 
  v_usuario_bloq       VARCHAR2(30);
  --
  CURSOR CUR_BLACKLIST IS
    SELECT BANEADO, NOMBRE_COMPLETO, ESTADO, CODIGO_ASEGURADO, FEC_TRA, USUARIO
      FROM BLACKLIST_ASEGURADOS
     WHERE CODIGO_ASEGURADO = :CG$CTRL.NO_AFI;
  --
  CURSOR CUR_POL_VIG IS 
    SELECT COMPANIA, RAMO, SECUENCIAL, PLAN
      FROM ASE_POL01_V A, ESTATUS B
     WHERE B.CODIGO    = A.ESTATUS
       AND B.VAL_LOG   = 'T'
       AND A.ASEGURADO = :CG$CTRL.ASEGURADO
       AND A.COMPANIA  = :GLOBAL.COD_COMPANIA
     ORDER BY FEC_VER DESC;
  --
  ROW_POL_VIG  CUR_POL_VIG%ROWTYPE;
BEGIN
  OPEN CUR_BLACKLIST;
  FETCH CUR_BLACKLIST INTO v_baneado, v_nombre_completo, v_estado_blacklist, v_beneficiario_id, v_fec_tra_bloq, v_usuario_bloq;
  CLOSE CUR_BLACKLIST;
  --
  IF NVL(v_baneado,0) = :FRMVAR.BANEADO THEN     
     --
     P_BUSCA_MOTIVO_BLOQUEO_ASE(:FRMVAR.STR_ASEGURADO, --'ASEGURADO',
                                :CG$CTRL.ASEGURADO,
                                :CG$CTRL.SECUENCIA_AFI);
     --
     IF :MSG_BLOQUEO.MOTIVO IS NOT NULL THEN
     	  ROW_POL_VIG := NULL;
     	  OPEN CUR_POL_VIG;
     	  FETCH CUR_POL_VIG INTO ROW_POL_VIG;
     	  CLOSE CUR_POL_VIG;
        --
     	  PKG_MOT_BLOQUEO.SET_VARIABLE(ROW_POL_VIG.COMPANIA, 
     	                               ROW_POL_VIG.RAMO, 
     	                               ROW_POL_VIG.SECUENCIAL);
     	  -- Enfoco 03/02/2025.- Mejoras Notificacion
        PKG_MOT_BLOQUEO.P_ENVIA_NOTIFICACION_BLOQUEO(:GLOBAL.COD_COMPANIA, 
                                                     :FRMVAR.STR_ASEGURADO, --'ASEGURADO',
                                                     :RADICACION.NUMERO_SOLICITUD,
                                                     :CG$CTRL.NO_AFI,
                                                     ROW_POL_VIG.PLAN,
                                                     v_usuario_bloq, 
                                                     v_fec_tra_bloq, 
                                                     :BUSCA_SERVICIO.TIPO_PRESTADOR_ADD,
                                                     :SOLICITUD_SERVICIO.PROVEEDOR_ID,
                                                     NULL, --P_DIAGNOSTICO
                                                     NULL, --P_SERVICIO
                                                     NULL, --P_TIP_COB
                                                     NULL);-- P_COBERTURA
     END IF;
     --
     DECLARE
       V_DSP_ACT VARCHAR2(512) := 'El usuario '||user||' intenta registrarle un reembolso al afiliado bloqueado '||
                                  V_NOMBRE_COMPLETO||', '||'('||V_BENEFICIARIO_ID||')'||', '||'en la fecha '||SYSDATE;
     BEGIN
       -- SE INSERTA EN EL HISTORICO TAMBIEN 
       INSERT INTO REEMBOLSO.HISTORICO_FRAUDES
         (FECHA,  DESCRIPCION_ACTIVIDAD,  FEC_TRA, 
          USUARIO, ESTADO)
       VALUES
         (TRUNC(SYSDATE), V_DSP_ACT, SYSDATE,
          USER, V_ESTADO_BLACKLIST);
     EXCEPTION WHEN OTHERS THEN
       DBAPER.PKG_GENERAL.P_INSERTA_ERROR('REEMB_PAGO.FMB/PU/P_VALIDA_ASEGURADO_BAN',SQLCODE, SUBSTR(SQLERRM, 1, 500),
                                          'ERROR CREANDO HISTORICO_FRAUDES-EN-P_VALIDA_ASEGURADO_BAN: '||SQLERRM);
     END;
     --
     :SYSTEM.MESSAGE_LEVEL := '25';
     COMMIT;  
     :SYSTEM.MESSAGE_LEVEL := '0';
     --           
     RAISE FORM_TRIGGER_FAILURE;
  END IF;
END;
