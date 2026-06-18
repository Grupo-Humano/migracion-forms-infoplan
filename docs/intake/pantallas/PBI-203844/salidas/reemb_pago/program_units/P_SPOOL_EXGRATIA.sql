-- PROGRAM UNIT: P_SPOOL_EXGRATIA
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_SPOOL_EXGRATIA IS
  -- Proyecto Exgratia.- Enfoco 01/09/2024.
  -- Proceso que valida si la cobertura es de Ex-Gracia para enviar al spool y asignar el estatus de Pendiete Spool a la solicitud
  v_cob_exgratia  VARCHAR2(256) := F_OBTEN_PARAMETRO_SEUS('COB_EXGRATIA', :GLOBAL.COD_COMPANIA);
  v_row_exg       SPOOL_EXGRATIA%ROWTYPE;
  v_error         NUMBER(2);
  v_msg_id        NUMBER(10) := F_OBTEN_PARAMETRO_SEUS('SPOOL_EXGRATIA.MSG2', :GLOBAL.COD_COMPANIA);
  v_est_sp_pend   NUMBER(5)  := F_OBTEN_PARAMETRO_SEUS('SPOOL_EXGRATIA.EST_P', :GLOBAL.COD_COMPANIA);
  v_est_sl_pend   NUMBER(5)  := F_OBTEN_PARAMETRO_SEUS('SOL_SER_REEMB.EST_PE', :GLOBAL.COD_COMPANIA);
BEGIN
  IF INSTR(v_cob_exgratia,'*'||:SOLICITUD_SERVICIO_DETALLE.COBERTURA||'*') > 0 THEN
     /*v_row_exg.No_solicitud   := :RADICACION.NUMERO_SOLICITUD;
     v_row_exg.NO_SOLICITUD_SERVICIO := :SOLICITUD_SERVICIO.ID;
     v_row_exg.Compania       := :GLOBAL.COD_COMPANIA;
     v_row_exg.Ramo           := :SOLICITUD_SERVICIO.RAMO;
     v_row_exg.Sec_pol        := :SOLICITUD_SERVICIO.SECUENCIAL;
     v_row_exg.Asegurado      := :CG$CTRL.ASEGURADO;
     v_row_exg.Dependiente    := :CG$CTRL.SECUENCIA_AFI;
     v_row_exg.Provedor       := :SOLICITUD_SERVICIO_DETALLE.PROVEEDOR_ID;
     v_row_exg.Usuario_aprob  := :SOLICITUD_SERVICIO_DETALLE.USU_APROB;
     v_row_exg.Comentario     := :SOLICITUD_SERVICIO_DETALLE.COMENT_SOL_SPOOL;
     v_row_exg.Cobertura      := :SOLICITUD_SERVICIO_DETALLE.COBERTURA;
     v_row_exg.Tip_cob        := :SOLICITUD_SERVICIO_DETALLE.COBERTURA_TIPO;
     v_row_exg.Mon_rec        := :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO;
     v_row_exg.Mon_pag        := :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR;
     v_row_exg.Estatus        := v_est_sp_pend; -- Estatus Spool Pendiente
     v_row_exg.Usuario        := USER;
     v_row_exg.Fec_tra        := SYSDATE;*/
     --
     P_INSERT_SPOOL_EXGRATIA(:RADICACION.NUMERO_SOLICITUD,
												     :SOLICITUD_SERVICIO.ID,
												     :GLOBAL.COD_COMPANIA,
												     :SOLICITUD_SERVICIO.RAMO,
												     :SOLICITUD_SERVICIO.SECUENCIAL,
												     :CG$CTRL.ASEGURADO,
												     :CG$CTRL.SECUENCIA_AFI,
												     :SOLICITUD_SERVICIO_DETALLE.PROVEEDOR_ID,
												     :SOLICITUD_SERVICIO_DETALLE.USU_APROB,
												     :SOLICITUD_SERVICIO_DETALLE.COMENT_SOL_SPOOL,
												     :SOLICITUD_SERVICIO_DETALLE.COBERTURA,
												     :SOLICITUD_SERVICIO_DETALLE.COBERTURA_TIPO,
												     :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO,
												     :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,
												     v_est_sl_pend, -- Estatus Spool Pendiente
                             v_error);
     --
     IF NVL(v_error, 0) > 0 THEN
        p_imprime_mensaje(v_msg_id, null);
     ELSE
     	  :SOLICITUD_SERVICIO.ESTATUS := v_est_sl_pend; -- Estatus Solicitud Pendiente Spool
     END IF;
  END IF;
END;
