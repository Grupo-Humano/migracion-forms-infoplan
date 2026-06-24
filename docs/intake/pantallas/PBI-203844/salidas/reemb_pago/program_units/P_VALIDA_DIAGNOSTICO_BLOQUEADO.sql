-- PROGRAM UNIT: P_VALIDA_DIAGNOSTICO_BLOQUEADO
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_VALIDA_DIAGNOSTICO_BLOQUEADO IS
-- Enfoco 23/11/2024.- Proyecto Lista Negra
  v_baneado       NUMBER(2) := 0;
  v_fec_tra_bloq  DATE;
  v_usuario_bloq  VARCHAR2(30);
	--
	Cursor cur_baneado_diag is
    Select P.baneado, P.Fec_tra, P.Usuario
      from REEMBOLSO.BLACKLIST_ASE_PERTINENCIA P
     where P.codigo_asegurado = :SOLICITUD_SERVICIO.CODIGO_AFILIADO
       and P.Tipo_bloqueo     = :FRMVAR.STR_DIAGNOSTICO
       and P.Diagnostico      = UPPER(:SOLICITUD_SERV_DIAG.COD_DIAGNOSTICO);
  --
BEGIN
  Open cur_baneado_diag;
  Fetch cur_baneado_diag into v_baneado, v_fec_tra_bloq, v_usuario_bloq;
  Close cur_baneado_diag;
  --
  If v_baneado = :FRMVAR.BANEADO then
     P_BUSCA_MOTIVO_BLOQUEO_PERTIN(:FRMVAR.STR_DIAGNOSTICO, 
                                   :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                   UPPER(:SOLICITUD_SERV_DIAG.COD_DIAGNOSTICO),
                                   NULL, --P_SERVICIO
                                   NULL, --P_TIP_COB
                                   NULL); --P_COBERTURA
     --
     PKG_MOT_BLOQUEO.SET_VARIABLE(:SOLICITUD_SERVICIO.COMPANIA,
     	                            :SOLICITUD_SERVICIO.RAMO, 
     	                            :SOLICITUD_SERVICIO.SECUENCIAL);
     -- Enfoco 03/02/2025.- Mejoras Notificacion
     PKG_MOT_BLOQUEO.P_ENVIA_NOTIFICACION_BLOQUEO(:GLOBAL.COD_COMPANIA, 
                                                  :FRMVAR.STR_DIAGNOSTICO,
                                                  :RADICACION.NUMERO_SOLICITUD,
                                                  :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                                  :SOLICITUD_SERVICIO.CODIGO_PLAN,
                                                  v_usuario_bloq, 
                                                  v_fec_tra_bloq, 
                                                  :BUSCA_SERVICIO.TIPO_PRESTADOR_ADD,
                                                  :SOLICITUD_SERVICIO.PROVEEDOR_ID,
                                                  UPPER(:SOLICITUD_SERV_DIAG.COD_DIAGNOSTICO),
                                                  NULL, --P_SERVICIO
                                                  NULL, --P_TIP_COB
                                                  NULL);-- P_COBERTURA
     RAISE FORM_TRIGGER_FAILURE;
  End if;
END;
