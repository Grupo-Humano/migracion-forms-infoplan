-- PROGRAM UNIT: P_RESTRICCIONES_SERV
-- Tipo: Procedure
-- ====================================================================

--Tommy Pereyra Enfoco 11/11/2024
PROCEDURE p_restricciones_serv(p_mensaje out varchar2) IS
  cursor cur_tip_pla is
  select tip_pla 
  from plan
  where codigo = :resumen_reclamos.plan;

  cursor cur_spool is --(vtipplan number, vplan number, vaseg number, vdepe number, vser number, vtipcob number, vcob number, vcia number) is
	select estatus_spool, accion, c.descripcion accion_des, tipo_nivel, a.causa_accion, comentario
	from REEMBOLSO.REEMB_RESTRIC_NIV_SPOOL a, accion_a_tomar c
  where numero_solicitud = :radicacion.numero_solicitud
  and a.accion = c.codigo
  and estatus_spool != F_OBTEN_PARAMETRO_SEUS('ST_APROB_SPOOL_REEMB'); --1-Aprobado
	/*where (tipo_plan = vtipplan or tipo_plan = 0)
	and plan = vplan
	and asegurado = vaseg
	and dependiente = vdepe
	and servicio = vser
	and tipo_cobertura = vtipcob
	and cobertura = vcob
	and compania = vcia
	and a.accion = c.codigo
  and a.fecha_spool = (select max(b.fecha_spool) from REEMB_RESTRIC_NIV_SPOOL b
                        where a.tipo_nivel = b.tipo_nivel
                        and a.tipo_plan = b.tipo_plan
                        and a.plan = b.plan
                        and a.asegurado = b.asegurado
                        and a.dependiente = b.dependiente
                        and a.servicio = b.servicio
                        and a.diagnostico = b.diagnostico
                        and a.tipo_cobertura = b.tipo_cobertura
                        and a.cobertura = b.cobertura
                        and a.compania = b.compania);	*/

  cursor cur_cob is
  select cobertura_id
  from cobertura_solicitada
  where solicitud_servicio_id = :resumen_reclamos.id;

  vspool cur_spool%ROWTYPE;
  v_tip_pla number;	
  vAse number := to_number(SUBSTR(:resumen_reclamos.CODIGO_AFILIADO,1,7));
  vDep number := to_number(SUBSTR( :resumen_reclamos.CODIGO_AFILIADO,8,3));
  v_tip_cob number;
  v_cob number;
  v_mensaje varchar2(1000);

begin	
  open cur_tip_pla;
  fetch cur_tip_pla into v_tip_pla;
  close cur_tip_pla;

  open cur_cob;
  fetch cur_cob into v_cob;
  close cur_cob;
  		  
  v_tip_cob := INNOVACORE.PKG_INNOVA.FDP_DET_TIPO_COB(:resumen_reclamos.TIPO_SERVICIO, v_cob);

   open cur_spool;--(v_tip_pla, :resumen_reclamos.plan, vAse, vDep, :resumen_reclamos.tipo_servicio, v_tip_cob, v_cob, :GLOBAL.COD_COMPANIA);
   fetch cur_spool into vspool;
     if cur_spool%found then
   	   	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EDITAR_MON', ENABLED, PROPERTY_FALSE);
   	   	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_COBR_INDE', ENABLED, PROPERTY_FALSE);
   	   	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EXCEPCION_NEGOCIO', ENABLED, PROPERTY_FALSE);
   	   	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_TARIFA_INCORECTA', ENABLED, PROPERTY_FALSE);
   	   	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_NEGOCIACION_PRESTADOR', ENABLED, PROPERTY_FALSE);             

        if vspool.accion != F_OBTEN_PARAMETRO_SEUS('APROBAR_REEMB') --1    
           then         				   	 				   	 
			     if vspool.tipo_nivel = F_OBTEN_PARAMETRO_SEUS('AS_RESTRINCIONES') then
		 			    p_mensaje := F_OBTEN_PARAMETRO_SEUS('MSG_REST_REEMB_ASE')||' '||F_OBTEN_PARAMETRO_SEUS('ACCION')||' '||vspool.accion_des
		 					                                  ||' '||F_OBTEN_PARAMETRO_SEUS('CAUSA_ACCION')||' '||vspool.causa_accion
		 					                                  ||' '||F_OBTEN_PARAMETRO_SEUS('COMEN_ACCION')||' '||vspool.comentario;				   	 				   	 
			     elsif vspool.tipo_nivel = F_OBTEN_PARAMETRO_SEUS('GE_RESTRINCIONES') then
		 			    p_mensaje := F_OBTEN_PARAMETRO_SEUS('MSG_REST_REEMB_COB')||' '||F_OBTEN_PARAMETRO_SEUS('ACCION')||' '||vspool.accion_des
		 					                                  ||' '||F_OBTEN_PARAMETRO_SEUS('CAUSA_ACCION')||' '||vspool.causa_accion
		 					                                  ||' '||F_OBTEN_PARAMETRO_SEUS('COMEN_ACCION')||' '||vspool.comentario;				   	 				   	 
			     elsif vspool.tipo_nivel = F_OBTEN_PARAMETRO_SEUS('PL_RESTRINCIONES') then
		 			    p_mensaje := F_OBTEN_PARAMETRO_SEUS('MSG_REST_REEMB_PLA')||' '||F_OBTEN_PARAMETRO_SEUS('ACCION')||' '||vspool.accion_des
		 					                                  ||' '||F_OBTEN_PARAMETRO_SEUS('CAUSA_ACCION')||' '||vspool.causa_accion
		 					                                  ||' '||F_OBTEN_PARAMETRO_SEUS('COMEN_ACCION')||' '||vspool.comentario;				   	 				   	 
		       end if; --p_tipo_nivel
        end if; --vspool.accion
     end if;  --cur_spool%found 
   close cur_spool;                
END;
