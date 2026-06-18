-- PROGRAM UNIT: P_VALIDA_MONTO_PAGAR
-- Tipo: Procedure
-- ====================================================================

PROCEDURE p_valida_monto_pagar is
	 -- *****************************************************************
	 -- Creado por: Citser./Proyecto. Tarifas URA	 
	 -- Fecha.  26-Nov.-2024
	 -- *****************************************************************	 
	 
	 -- variables
	 v_tarifa_configurada			number(14,2) := 0;	 

-- cuerpo
begin
	 --
	 if (nvl(:solicitud_servicio_detalle.monto_pagar,0) > 0) then
	 	   
	 	   -- buscar el valor de la tarifa URA configurada 
	 	   v_tarifa_configurada  := F_BUSCA_TARIFA_URA(:CG$CTRL.codigo_compania         ,
											                             :solicitud_servicio.ramo				  ,
											                             :solicitud_servicio.codigo_plan  ,
											                             :solicitud_servicio.tipo_servicio,
											                             :solicitud_servicio_detalle.cobertura_tipo,
											                             :busca_servicio.grupo_cobertura  ,
											                             :solicitud_servicio_detalle.cobertura,
											                             :solicitud_servicio.fecha_servicio );
	 	   
	 	   --
	 	   if (nvl(v_tarifa_configurada,0) > 0) then
			 	   --
			 	   if (nvl(:solicitud_servicio_detalle.monto_pagar,0) > nvl(v_tarifa_configurada,0)) then
			 	   	  p_alerta_mensaje('Para este plan, el monto a pagar excede la tarifa URA máxima establecida, la cual es (RD$ '||to_char(v_tarifa_configurada,'9,999,999.99')||'., debe ir a Revision Medica', 'N');
		      		:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR  		 := v_tarifa_configurada;
		      		:SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA := :SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL - :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR;  -- Citser. 26.02.2025 / Tarifas URA
		      		:SOLICITUD_SERVICIO_DETALLE.MONTO_COASEGURO  := 0;
		      		--	 
			 	   	  if not F_USUARIO_AUTORIZADO() then
			 	   	     -- habilita item para permitirle enviar solicitud a Revision y colocar Service Desk
			 	   	     set_block_property('BK_SOLICITUD_REV_MEDICA' , update_allowed, property_true);
							   set_block_property('BK_SOLICITUD_REV_MEDICA' , insert_allowed, property_true);
							   --
							   set_item_property('BK_SOLICITUD_REV_MEDICA.IND_REVISION_MEDICA'   , enabled, property_true);
							   set_item_property('BK_SOLICITUD_REV_MEDICA.NO_SERVICE_DESK'   	 	 , enabled, property_true);
							   set_item_property('BK_SOLICITUD_REV_MEDICA.COMENTARIO'   				 , enabled, property_true);
				  			 --
			 	   	  end if;	 	   	
			 	   		--
			 	   end if;	 	   
			 	   --
	 	   end if;
	 	   --
	 	
	 end if;  -- (nvl(:solicitud_servicio_detalle.monto_pagar,0) > 0)
	 --

end;
