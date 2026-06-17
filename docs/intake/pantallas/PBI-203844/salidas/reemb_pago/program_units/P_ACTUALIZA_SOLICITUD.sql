-- PROGRAM UNIT: P_ACTUALIZA_SOLICITUD
-- Tipo: Procedure
-- ====================================================================

--Tommy Pereyra Enfoco 11/11/2024
PROCEDURE p_actualiza_solicitud IS

  vAse number := to_number(SUBSTR(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,1,7));
  vDep number := to_number(SUBSTR( :SOLICITUD_SERVICIO.CODIGO_AFILIADO,8,3));
  v_tip_cob number;

begin	
  v_tip_cob := INNOVACORE.PKG_INNOVA.FDP_DET_TIPO_COB(:SOLICITUD_SERVICIO.TIPO_SERVICIO,:SOLICITUD_SERVICIO_DETALLE.COBERTURA);

  reembolso.pkg_restric_reembolso.p_act_solicitud(:GLOBAL.COD_COMPANIA, 
                                                  :solicitud_servicio.codigo_plan, 
                                                  :SOLICITUD_SERV_DIAG.cod_diagnostico, 
                                                  :SOLICITUD_SERVICIO.tipo_servicio,
                          										    v_tip_cob, 
                          										    :SOLICITUD_SERVICIO_DETALLE.cobertura, 
                          										    vAse, 
                          											  vDep, 
                          											  :radicacion.numero_solicitud);

END;
