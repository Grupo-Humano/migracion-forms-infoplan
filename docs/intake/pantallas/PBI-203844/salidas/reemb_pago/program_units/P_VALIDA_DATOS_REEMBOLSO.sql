-- PROGRAM UNIT: P_VALIDA_DATOS_REEMBOLSO
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_VALIDA_DATOS_REEMBOLSO IS
BEGIN
	  if :radicacion.fecha_recepcion is null
		or :SOLICITUD_PAGO_DETALLE.monto is null
		or :SOLICITUD_PAGO_DETALLE.cantidad is null
		or :radicacion.via_entrada is null
		or :radicacion.medio_pago is null 
		
	then
	  
	  IF :RADICACION.USUARIO='INNOVACORE' AND :SOLICITUD_PAGO_DETALLE.monto is null AND :SOLICITUD_PAGO_DETALLE.cantidad is null  THEN 
				NULL;
	  ELSE 
	    p_imprime_mensaje(214, NULL);
			go_block('radicacion');
			raise form_trigger_failure;
	  END IF;
	end if;
	
	IF :RADICACION.VIA_ENTRADA IN ('APP', 'WEB') THEN
		if :radicacion.numero_via_entrada is null then
			p_imprime_mensaje(214, NULL);
			go_block('radicacion');
			raise form_trigger_failure;
		end if;
	END IF;
	
	IF :RADICACION.MEDIO_PAGO IN ('CHEQ') THEN
		if :radicacion.SUCURSAL_CHEQUE is null or :radicacion.ENTREGAR_CHEQUE is null then
			p_imprime_mensaje(214, NULL);
			go_block('radicacion');
			raise form_trigger_failure;
		end if;
	end if;
	
	IF :RADICACION.MEDIO_PAGO IN ('TR') THEN
		
	/*	IF :RADICACION.BANCO IS NULL 
			 OR :RADICACION.SEXO IS NULL 
			 OR :RADICACION.CORREO_PROPIETARIO IS NULL 
			 OR :RADICACION.NUMERO_CUENTA IS NULL
			 OR :RADICACION.TIPO_CUENTA IS NULL
			 OR :RADICACION.NOMBRE_PROPIETARIO IS NULL
			 OR :RADICACION.TIPO_PROPIETARIO IS NULL
			 OR :RADICACION.NUMERO_DOCUMENTO IS NULL
			 OR :RADICACION.TIPO_DOCUMENTO IS NULL THEN
			p_imprime_mensaje(333, NULL);  --OF18012024 ANTES ERA 76						
			go_block('radicacion');
			raise form_TRIGGER_FAILURE;
		END IF;
		*/
		
		
		
		if :RADICACION.NUMERO_DOCUMENTO is not null 
			  AND :RADICACION.TIPO_DOCUMENTO IS NOT NULL  
			  and :RADICACION.TIPO_DOCUMENTO in ('C','R') then
			  
			if f_valida_regular_expression(:RADICACION.NUMERO_DOCUMENTO, '^[0-9]+$') = 'N' THEN
				p_imprime_mensaje(331, NULL); --OF18012024 ANTES ERA 74
				go_block('radicacion');
				raise form_TRIGGER_FAILURE;	
			end if;
			
			if :RADICACION.TIPO_DOCUMENTO in ('C') and length(:RADICACION.NUMERO_DOCUMENTO) <> 11 then
				p_imprime_mensaje(332, NULL); --OF18012024 ANTES ERA 75
				go_block('radicacion');
				raise form_TRIGGER_FAILURE;
			end if;
		end if;
		
	END IF;
END;
