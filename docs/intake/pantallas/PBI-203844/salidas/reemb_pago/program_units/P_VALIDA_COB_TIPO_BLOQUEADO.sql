-- PROGRAM UNIT: P_VALIDA_COB_TIPO_BLOQUEADO
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_VALIDA_COB_TIPO_BLOQUEADO IS
	-- Enfoco 23/11/2024.- Proyecto Lista Negra
  v_estatus      NUMBER(2);
	v_tip_cob      NUMBER(5);
	v_tip_ser_alto_costo  NUMBER := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('ALTO_COSTO',:GLOBAL.COD_COMPANIA);
	v_tip_ser_alto_renal  NUMBER := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('SERVICIO_RENAL',:GLOBAL.COD_COMPANIA);
	v_usuario_bloq  VARCHAR2(30); 
  v_fec_tra_bloq  DATE;
	--
	Cursor cur_baneado_tc is
    Select P.baneado, P.usuario, P.fec_tra
      from REEMBOLSO.BLACKLIST_ASE_PERTINENCIA P
     where P.codigo_asegurado = :SOLICITUD_SERVICIO.CODIGO_AFILIADO
       and P.Tipo_bloqueo     = :FRMVAR.STR_TIP_COB
       and P.tip_cob          = v_tip_cob--:SOLICITUD_SERVICIO_DETALLE.COBERTURA_TIPO
       and P.servicio is null;
	--
	Cursor cur_baneado_cob is
    Select P.baneado, P.usuario, P.fec_tra
      from REEMBOLSO.BLACKLIST_ASE_PERTINENCIA P
     where P.codigo_asegurado = :SOLICITUD_SERVICIO.CODIGO_AFILIADO
       and P.Tipo_bloqueo     = :FRMVAR.STR_COBERTURA
       and P.servicio         = :SOLICITUD_SERVICIO.TIPO_SERVICIO
       and P.tip_cob          = v_tip_cob --:SOLICITUD_SERVICIO_DETALLE.COBERTURA_TIPO
       and P.cobertura        = :SOLICITUD_SERVICIO_DETALLE.COBERTURA;
BEGIN
  -- Se utiliza la misma funcionalidad que esta en el proceso REEMBOLSO.P_VALIDARCOBERTURASAUT_FORMA
  If :SOLICITUD_SERVICIO.TIPO_SERVICIO IN (v_tip_ser_alto_costo, v_tip_ser_alto_renal) THEN
     v_tip_cob := :SOLICITUD_SERVICIO.SUB_GRUPO_SERVICIO;
  Else
     v_tip_cob := INNOVACORE.PKG_INNOVA.FDP_DET_TIPO_COB(:SOLICITUD_SERVICIO.TIPO_SERVICIO,
                                                         :SOLICITUD_SERVICIO_DETALLE.COBERTURA);
  End if;
  --v_tip_cob := :SOLICITUD_SERVICIO_DETALLE.COBERTURA_TIPO;
  --
	v_estatus := 0;
	Open cur_baneado_tc;
  Fetch cur_baneado_tc into v_estatus, v_usuario_bloq, v_fec_tra_bloq;
  Close cur_baneado_tc;
  --
  If v_estatus = :FRMVAR.BANEADO then
     :SOLICITUD_SERVICIO_DETALLE.FRECUENCIA    := 1;
     :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO := 0.1;
     --
     P_BUSCA_MOTIVO_BLOQUEO_PERTIN(:FRMVAR.STR_TIP_COB,
                                   :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                   NULL, --P_DIAGNOSTICO 
                                   NULL, --P_SERVICIO
                                   v_tip_cob, --P_TIP_COB
                                   NULL); --P_COBERTURA
     --
     PKG_MOT_BLOQUEO.SET_VARIABLE(:SOLICITUD_SERVICIO.COMPANIA,
     	                            :SOLICITUD_SERVICIO.RAMO, 
     	                            :SOLICITUD_SERVICIO.SECUENCIAL);
     -- Enfoco 03/02/2025.- Mejoras Notificacion
     PKG_MOT_BLOQUEO.P_ENVIA_NOTIFICACION_BLOQUEO(:GLOBAL.COD_COMPANIA, 
                                                  :FRMVAR.STR_TIP_COB,
                                                  :RADICACION.NUMERO_SOLICITUD,
                                                  :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                                  :SOLICITUD_SERVICIO.CODIGO_PLAN,
                                                  v_usuario_bloq, 
                                                  v_fec_tra_bloq, 
                                                  :BUSCA_SERVICIO.TIPO_PRESTADOR_ADD,
                                                  :SOLICITUD_SERVICIO.PROVEEDOR_ID,
                                                  NULL, --P_DIAGNOSTICO
                                                  NULL, --P_SERVICIO
                                                  v_tip_cob, --P_TIP_COB
                                                  NULL);-- P_COBERTURA
     RAISE FORM_TRIGGER_FAILURE;
  Else
     Open cur_baneado_cob;
     Fetch cur_baneado_cob into v_estatus, v_usuario_bloq, v_fec_tra_bloq;
     Close cur_baneado_cob;
     --
     If v_estatus = :FRMVAR.BANEADO then
     	  :SOLICITUD_SERVICIO_DETALLE.FRECUENCIA    := 1;
     	  :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO := 0.1;
     	  --
        P_BUSCA_MOTIVO_BLOQUEO_PERTIN(:FRMVAR.STR_COBERTURA,
                                      :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                      NULL,      --P_DIAGNOSTICO 
                                      :SOLICITUD_SERVICIO.TIPO_SERVICIO,
                                      v_tip_cob, --P_TIP_COB
                                      :SOLICITUD_SERVICIO_DETALLE.COBERTURA);
        -- Envia notificacion de email.
        PKG_MOT_BLOQUEO.SET_VARIABLE(:SOLICITUD_SERVICIO.COMPANIA,
     	                               :SOLICITUD_SERVICIO.RAMO, 
     	                               :SOLICITUD_SERVICIO.SECUENCIAL);
        -- Enfoco 03/02/2025.- Mejoras Notificacion
        PKG_MOT_BLOQUEO.P_ENVIA_NOTIFICACION_BLOQUEO(:GLOBAL.COD_COMPANIA, 
                                                     :FRMVAR.STR_COBERTURA,
                                                     :RADICACION.NUMERO_SOLICITUD,
                                                     :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                                     :SOLICITUD_SERVICIO.CODIGO_PLAN,
                                                     v_usuario_bloq, 
                                                     v_fec_tra_bloq, 
                                                     :BUSCA_SERVICIO.TIPO_PRESTADOR_ADD,
                                                     :SOLICITUD_SERVICIO.PROVEEDOR_ID,
                                                     NULL, --P_DIAGNOSTICO
                                                     :SOLICITUD_SERVICIO.TIPO_SERVICIO,
                                                     v_tip_cob, --P_TIP_COB
                                                     :SOLICITUD_SERVICIO_DETALLE.COBERTURA);
        RAISE FORM_TRIGGER_FAILURE;
     End if;
  End if;
END;
