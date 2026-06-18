-- PROGRAM UNIT: P_VALIDA_SOLICITUD_DUPLI_COB
-- Tipo: Procedure
-- ====================================================================

PROCEDURE p_valida_solicitud_dupli_cob(P_COBERTURA_ID_ADD	VARCHAR2 DEFAULT NULL) IS
  -- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (27/01/2024). INTEGRACION
	v_existe_n	number;
	v_existe	boolean := false;
	v_existe_diagnostico	boolean := false;
	v_existe_cobertura	boolean := false;
  V_RECORD                    NUMBER := :SYSTEM.CURSOR_RECORD;
  v_est_anul_ss		number := PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('P_EST_ANU_948',:global.cod_compania);
  v_est_rech_ss		number := PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('P_EST_REC_945',:global.cod_compania);
  V_EXISTE_RECLAMACION NUMBER;
	
	cursor c_existe_Solicitud_base is
		select ss.id
			from solicitud_servicio ss
		where ss.fecha_servicio = :solicitud_servicio.fecha_Servicio
	--OF23012024	 and ss.SERVICIO_TIPO_ID = :solicitud_servicio.tipo_servicio
		 and ss.id <> nvl(:solicitud_servicio.id,0)
		 and ss.AFILIADO_NUMERO=:solicitud_servicio.CODIGO_AFILIADO
		 and ss.estatus not in (v_est_anul_ss, v_est_rech_ss) --lcalcano forebra 10-jul-23 para que no tome en cuenta las sol rechazadas o anuladas al momento de trabajar con una sol duplicada
		 ;
			
	cursor c_existe_diagnostico(l_solicitudservid	number, l_diagnostico	varchar2) is
		select 1
			from SOLICITUD_SERVICIO_DIAGNOSTICO d;
				--OF23012024
	/*	where SOLICITUD_SERVICIO_ID = l_solicitudservid
		 and d.CODIGO_DIAGNOSTICO = l_diagnostico;*/
		 
	cursor c_existe_cobertura(l_solicitudservid	number, l_cobertura	varchar2) is
		select 1
			from COBERTURA_SOLICITADA d
		where SOLICITUD_SERVICIO_ID = l_solicitudservid
		 and d.COBERTURA_ID = l_cobertura;
		        
       	cursor c_existe is
        SELECT 1 FROM RECLAMACION Y 
        WHERE Y.ASE_USO=TO_NUMBER(SUBSTR(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,1,7)) 
        AND NVL(Y.DEP_USO,0)=to_number(SUBSTR(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,8,3))
        AND Y.FEC_SER =:SOLICITUD_SERVICIO.FECHA_SERVICIO
        AND Y.ESTATUS NOT IN (183,600,801,523,300,180) -- DAGUZMAN #205510 07-MAYO-2024 COLOCAMOS EL ESTATUS 180 PARA QUE NO TOME EN CUENTA LOS RECLAMOS QUE ESTAN DECLINADO
        AND EXISTS ( SELECT 1 FROM REC_C_SAL X 
                     WHERE X.ANO=Y.ANO 
                     AND X.COMPANIA=Y.COMPANIA 
                     AND X.RAMO=Y.RAMO
                     AND X.SECUENCIAL=Y.SECUENCIAL
                     AND X.COBERTURA= :SOLICITUD_SERVICIO_DETALLE.COBERTURA);
		 
		 
begin	
	V_RECORD  := :SYSTEM.CURSOR_RECORD;
		
		for i in c_existe_Solicitud_base loop
		
				v_existe := false;
				v_existe_diagnostico := true;
				v_existe_cobertura := false;
				
				/*go_block('SOLICITUD_SERV_DIAG');
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
				end if;*/
				
			--	go_block('SOLICITUD_SERVICIO_DETALLE');
			--	first_record;
		--	GO_RECORD(V_RECORD);
				if NVL(P_COBERTURA_ID_ADD,:SOLICITUD_SERVICIO_DETALLE.COBERTURA) IS NOT NULL then
				--	loop
						open c_existe_cobertura(i.id, NVL(P_COBERTURA_ID_ADD,:SOLICITUD_SERVICIO_DETALLE.COBERTURA));
						fetch c_existe_cobertura into v_existe_n;
						if c_existe_cobertura%found then
							v_existe_cobertura := true;
						end if;
						close c_existe_cobertura;
				--		exit when :system.last_Record = 'TRUE' or v_existe_cobertura = true;
				--		next_record;
				--	end loop;
				--	first_record;
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
		
		
		OPEN c_existe;
		FETCH c_existe INTO v_existe_reclamacion;
		CLOSE c_existe;
		
	if (v_existe or v_existe_reclamacion=1) then
--		p_imprime_mensaje(404, NULL);
		 	:SOLICITUD_SERVICIO_DETALLE.COBERTURA := NULL;
			:SOLICITUD_SERVICIO_DETALLE.DSP_COBERTURA := NULL;
	MSG_ALERT('Cobertura Inválida: Ha solicitado esta cobertura para este día.','E',TRUE);
		
	else 
		:CG$CTRL.IND_VALIDATE_COB_RECORD := 'S';
	--	go_item('SOLICITUD_SERVICIO_DETALLE.cobertura');
		
	end if;
end;
