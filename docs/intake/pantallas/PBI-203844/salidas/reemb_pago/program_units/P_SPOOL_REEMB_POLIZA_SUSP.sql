-- PROGRAM UNIT: P_SPOOL_REEMB_POLIZA_SUSP
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_SPOOL_REEMB_POLIZA_SUSP IS
  -- Proyecto Exgratia.- Enfoco 01/09/2024.
  -- Proceso que valida si la cobertura es de Ex-Gracia para enviar al spool y asignar el estatus de Pendiete Spool a la solicitud
  v_dummy         NUMBER(2) := 0;
  v_found         BOOLEAN;
  v_respuesta     NUMBER(2);
  v_row_exg       REEMBOLSO.SPOOL_REEMB_POLIZAS_SUSP%ROWTYPE;
  --
  v_msg_id        NUMBER(10)  := F_OBTEN_PARAMETRO_SEUS('REEMB_PAGO.MSG1', :GLOBAL.COD_COMPANIA);
  v_tip_ver_susp  VARCHAR2(2) := F_OBTEN_PARAMETRO_SEUS('P_TIP_VER_POL_S', :GLOBAL.COD_COMPANIA);
  v_est_sol_p     NUMBER(5)   := F_OBTEN_PARAMETRO_SEUS('SOL_SER_REEM.EST_PAC', :GLOBAL.COD_COMPANIA); -- Pendiente Autoriz Cobros
  --
  Cursor cur_spool_exgratia is 
    Select 1
      from Spool_exgratia 
     where no_solicitud = :RADICACION.NUMERO_SOLICITUD
       and no_solicitud_servicio =  :SOLICITUD_SERVICIO.ID;
  --
  Cursor cur_pol_susp is
    Select 1
      From Poliza P
     Where P.Compania   = :GLOBAL.COD_COMPANIA
       And P.Ramo       = :SOLICITUD_SERVICIO.RAMO
       And P.Secuencial = :SOLICITUD_SERVICIO.SECUENCIAL
       And P.Tip_ver    = v_tip_ver_susp
       And P.Fec_ver = (Select max(f.fec_ver)
                          from poliza f
                         where f.compania   = p.compania
                           and f.ramo       = p.ramo
                           and f.secuencial = p.secuencial
                           and f.fec_ver   <= trunc(:SOLICITUD_SERVICIO.FECHA_SERVICIO));
BEGIN
  OPEN cur_spool_exgratia;
  FETCH cur_spool_exgratia INTO v_dummy;
  v_found := cur_spool_exgratia%FOUND;
  CLOSE cur_spool_exgratia;
  --
  IF NOT(v_found) THEN 
     v_dummy := 0;
     OPEN cur_pol_susp;
     FETCH cur_pol_susp INTO v_dummy;
     CLOSE cur_pol_susp;
     --
     IF v_dummy > 0 THEN
        /*v_row_exg.No_solicitud := :RADICACION.NUMERO_SOLICITUD;
        v_row_exg.No_solicitud_servicio := :SOLICITUD_SERVICIO.ID;
        v_row_exg.Fec_ser      := :SOLICITUD_SERVICIO.FECHA_SERVICIO;
        v_row_exg.Compania     := :GLOBAL.COD_COMPANIA;
        v_row_exg.Ramo         := :SOLICITUD_SERVICIO.RAMO;
        v_row_exg.Sec_pol      := :SOLICITUD_SERVICIO.SECUENCIAL;
        v_row_exg.Asegurado    := :CG$CTRL.ASEGURADO;
        v_row_exg.Dependiente  := :CG$CTRL.SECUENCIA_AFI;
        v_row_exg.Usuario      := USER;
        v_row_exg.Fec_tra      := SYSDATE;*/
        --
        --REEMBOLSO.P_INSERT_SPOOL_POL_SUSP_REEMB(v_row_exg, v_respuesta);
        REEMBOLSO.P_INSERT_SPOOL_POL_SUSP_REEMB(:RADICACION.NUMERO_SOLICITUD,
        																				:SOLICITUD_SERVICIO.ID,
																				        :SOLICITUD_SERVICIO.FECHA_SERVICIO,
																				        :GLOBAL.COD_COMPANIA,
																				        :SOLICITUD_SERVICIO.RAMO,
																				        :SOLICITUD_SERVICIO.SECUENCIAL,
																				        :CG$CTRL.ASEGURADO,
																				        :CG$CTRL.SECUENCIA_AFI,
                                                v_respuesta);
        --
        IF NVL(v_respuesta,0) > 0 THEN
           p_imprime_mensaje(v_msg_id, null);
        ELSE
        	 :SOLICITUD_SERVICIO.ESTATUS := v_est_sol_p; -- Estatus Solicitud Pendiente autorizacion cobros
        END IF;
     END IF;
  END IF;
END;
