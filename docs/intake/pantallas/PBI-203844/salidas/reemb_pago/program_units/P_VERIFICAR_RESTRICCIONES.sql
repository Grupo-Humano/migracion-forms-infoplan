-- PROGRAM UNIT: P_VERIFICAR_RESTRICCIONES
-- Tipo: Procedure
-- ====================================================================

--Tommy Pereyra Enfoco 17/11/2024
PROCEDURE p_verificar_restricciones IS

v_mensaje varchar2(1000); 
v_tipo_nivel varchar2(5);
v_accion number;
v_MONTO_PAGAR number; 
v_estatus_COBERTURA number;

begin

  pkg_restric_reembolso.p_restricciones(:GLOBAL.COD_COMPANIA, 
                                        :solicitud_servicio.codigo_plan, 
                                        :SOLICITUD_SERV_DIAG.cod_diagnostico, 
                                        :SOLICITUD_SERVICIO.TIPO_SERVICIO,
                                        :SOLICITUD_SERVICIO_DETALLE.COBERTURA,
                                        :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                        :SOLICITUD_SERVICIO.fecha_servicio, 
                                        :radicacion.numero_solicitud, 
                                        v_tipo_nivel,
                                        v_accion,
                                        v_mensaje, 
                                        v_MONTO_PAGAR, 
                                        v_estatus_COBERTURA);
  
  if v_accion = F_OBTEN_PARAMETRO_SEUS('APROBAR_REEMB') --1    
  	then         				   	 				   	 
    MSG_ALERT(v_mensaje, 'E',FALSE);
  	--:CG$CTRL.DESCRIPCION_MENSAJES := v_mensaje;				   	 				   	 
		--GO_ITEM('CG$CTRL.BTN_CERRAR');  
  elsif v_accion != F_OBTEN_PARAMETRO_SEUS('APROBAR_REEMB') --1 
  	and v_accion is not null
  	then         				   	 				   	 
	  :CG$CTRL.DESCRIPCION_MENSAJES := v_mensaje;				   	 				   	 
   	GO_ITEM('CG$CTRL.BTN_CERRAR');  
   	 
   	--antes de empezar este proceso verificar si los botones estan enable, para que se queden asi si aplica					   	  
	  SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EDITAR_MON', ENABLED, PROPERTY_FALSE);
	  SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_COBR_INDE', ENABLED, PROPERTY_FALSE);
	  SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EXCEPCION_NEGOCIO', ENABLED, PROPERTY_FALSE);
	  SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_TARIFA_INCORECTA', ENABLED, PROPERTY_FALSE);
	  SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_NEGOCIACION_PRESTADOR', ENABLED, PROPERTY_FALSE);
     
    :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR := v_MONTO_PAGAR;
    :SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID := v_estatus_COBERTURA;
  end if;


end;
