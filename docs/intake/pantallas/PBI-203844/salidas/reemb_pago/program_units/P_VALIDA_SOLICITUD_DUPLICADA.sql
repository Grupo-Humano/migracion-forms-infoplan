-- PROGRAM UNIT: P_VALIDA_SOLICITUD_DUPLICADA
-- Tipo: Procedure
-- ====================================================================

PROCEDURE p_valida_solicitud_duplicada(P_COBERTURA_ID_ADD	VARCHAR2 DEFAULT NULL) IS
	v_existe_n	number;
	v_existe	boolean := false;
	v_existe_diagnostico	boolean := false;
	v_existe_cobertura	boolean := false;
  v_est_anul_ss		number := PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('P_EST_ANU_948',:global.cod_compania);
  v_est_rech_ss		number := PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('P_EST_REC_945',:global.cod_compania);	
	
	cursor c_existe_Solicitud_base is
		select ss.id
			from solicitud_servicio ss
		where ss.fecha_servicio = :solicitud_servicio.fecha_Servicio
		 and ss.SERVICIO_TIPO_ID = :solicitud_servicio.tipo_servicio
		 and ss.id <> nvl(:solicitud_servicio.id,0)
		 and ss.AFILIADO_NUMERO=:solicitud_servicio.CODIGO_AFILIADO
		 and ss.estatus not in (v_est_anul_ss, v_est_rech_ss) --lcalcano forebra 10-jul-23 para que no tome en cuenta las sol rechazadas o anuladas al momento de trabajar con una sol duplicada
		 ;
			
	cursor c_existe_diagnostico(l_solicitudservid	number, l_diagnostico	varchar2) is
		select 1
			from SOLICITUD_SERVICIO_DIAGNOSTICO d
		where SOLICITUD_SERVICIO_ID = l_solicitudservid
		 and d.CODIGO_DIAGNOSTICO = l_diagnostico;
		 
	cursor c_existe_cobertura(l_solicitudservid	number, l_cobertura	varchar2) is
		select 1
			from COBERTURA_SOLICITADA d
		where SOLICITUD_SERVICIO_ID = l_solicitudservid
		 and d.COBERTURA_ID = l_cobertura;
		 
begin	
		
		for i in c_existe_Solicitud_base loop
				v_existe := false;
				v_existe_diagnostico := false;
				v_existe_cobertura := false;
				
				go_block('SOLICITUD_SERV_DIAG');
				first_record;
				if :SOLICITUD_SERV_DIAG.COD_DIAGNOSTICO is not null then
					loop
						open c_existe_diagnostico(i.id, :SOLICITUD_SERV_DIAG.COD_DIAGNOSTICO);
						fetch c_existe_diagnostico into v_existe_n;
						if c_existe_diagnostico%found then
							v_existe_diagnostico := true;
						end if;
						close c_existe_diagnostico;
						exit when :system.last_Record = 'TRUE' or v_existe_diagnostico = true;
						next_record;
					end loop;
					first_record;
				else
					v_existe_diagnostico := false;		
				end if;
				
				go_block('SOLICITUD_SERVICIO_DETALLE');
				first_record;
				if NVL(P_COBERTURA_ID_ADD,:SOLICITUD_SERVICIO_DETALLE.COBERTURA) IS NOT NULL then
					loop
						open c_existe_cobertura(i.id, NVL(P_COBERTURA_ID_ADD,:SOLICITUD_SERVICIO_DETALLE.COBERTURA));
						fetch c_existe_cobertura into v_existe_n;
						if c_existe_cobertura%found then
							v_existe_cobertura := true;
						end if;
						close c_existe_cobertura;
						exit when :system.last_Record = 'TRUE' or v_existe_cobertura = true;
						next_record;
					end loop;
					first_record;
				else
					v_existe_cobertura := false;
				end if;
				
				if v_existe_cobertura and v_existe_diagnostico then
					v_existe := true;
				end if;
				
				if v_existe then
					exit;
				end if;
		end loop;
		
	if v_existe then
		p_imprime_mensaje(404, NULL);
		RAISE FORM_TRIGGER_FAILURE;	
	end if;
	
end;
