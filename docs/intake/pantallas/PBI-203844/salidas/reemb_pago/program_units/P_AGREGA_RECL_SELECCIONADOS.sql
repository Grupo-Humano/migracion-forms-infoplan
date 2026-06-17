-- PROGRAM UNIT: P_AGREGA_RECL_SELECCIONADOS
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_AGREGA_RECL_SELECCIONADOS IS			
  V_MSGID5 NUMBER(10) := F_OBTEN_PARAMETRO_SEUS('SPOOL_EXGRATIA.MSG5', :GLOBAL.COD_COMPANIA);
  v_est_sl_pend   NUMBER(5)  := F_OBTEN_PARAMETRO_SEUS('SOL_SER_REEMB.EST_PE', :GLOBAL.COD_COMPANIA);
  v_est_sol_pac  NUMBER(5)   := F_OBTEN_PARAMETRO_SEUS('SOL_SER_REEM.EST_PAC', :GLOBAL.COD_COMPANIA); -- Pendiente spool Autoriz Cobros 
BEGIN
	IF :RESUMEN_RECLAMOS.ESTATUS IN(v_est_sl_pend,v_est_sol_pac) THEN
     p_imprime_mensaje(V_MSGID5, null);
     RAISE FORM_TRIGGER_FAILURE;
	END IF;
	--
	REEMBOLSO.P_AGREGA_RECL_SELECCIONADOS(:radicacion.NUMERO_SOLICITUD, :radicacion.medio_pago);
END;
