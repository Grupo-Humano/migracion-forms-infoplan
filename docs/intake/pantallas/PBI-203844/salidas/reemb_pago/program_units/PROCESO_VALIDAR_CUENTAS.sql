-- PROGRAM UNIT: PROCESO_VALIDAR_CUENTAS
-- Tipo: Procedure
-- ====================================================================

PROCEDURE PROCESO_VALIDAR_CUENTAS IS
--OF13092023 ESTE PROCESO SE CREO PARA VALIDAR LOS DATOS DE CUENTAS BANCARIAS 

      Cursor C_CONFIGURACION_BANCO is
      Select MIN_LONGITUD_CTA, MAX_LONGITUD_CTA
        from BANCO_NUM_CTA
       where CODIGO = :RADICACION.BANCO; 
       
       v_MIN_LONGITUD_CTA NUMBER;
      v_MAX_LONGITUD_CTA NUMBER;
      V_CUENTA_EXISTE_LOV	NUMBER;
      c_estatus constant number:=363;
      
      CURSOR Cur_CUENTA_EXISTE_LOV IS
		      	SELECT 1
				     FROM NUM_CTA A,
				          NUMERO_CUENTA_INFO B,
				          BANCO_NUM_CTA C,
				          ESTATUS D,
				          NACIONALIDAD E,
				          ASEGURADO F
				    WHERE A.CODIGO = B.CODIGO(+)           
				      AND A.TIP_CTA IN ('A','C')           
				      AND A.BANCO = C.CODIGO          
				      AND A.ESTATUS = D.CODIGO(+)          
				      AND B.COD_NACIONALIDAD = E.CODIGO(+)
				      AND A.TIP_PRO = 'ASEGURADO'
				      and f.codigo = :cg$ctrl.ASEGURADO
				      AND A.PROPIETARIO = F.CODIGO
		      		AND NVL(A.ESTATUS,c_estatus) = c_estatus
		      		AND A.NUM_CTA = :RADICACION.NUMERO_CUENTA
		      		AND A.BANCO = :RADICACION.BANCO
		      		;

BEGIN      
       If nvl(:RADICACION.BANCO,0) > 0 then
         
	         Open C_CONFIGURACION_BANCO;
	         Fetch C_CONFIGURACION_BANCO into v_MIN_LONGITUD_CTA, v_MAX_LONGITUD_CTA;
	         If C_CONFIGURACION_BANCO%NOTFOUND THEN
							MSG_ALERT('Banco no está definido.','E',TRUE);
	         End if;
	         Close C_CONFIGURACION_BANCO;
	          
	         If :RADICACION.NUMERO_CUENTA IS NOT NULL THEN 
					      If instr(:RADICACION.NUMERO_CUENTA,'-') > 0 then      
									  MSG_ALERT('Cuenta bancaria no debe contener guiones.','E',TRUE);
									  
					      ElsIf nvl(v_MIN_LONGITUD_CTA,0) > 0 and nvl(v_MAX_LONGITUD_CTA,0) > 0 then
					      	
					         If LENGTH(:RADICACION.NUMERO_CUENTA) NOT BETWEEN v_MIN_LONGITUD_CTA AND v_MAX_LONGITUD_CTA THEN
											MSG_ALERT( 'Longitud cuenta bancaria incorrecta, se requiere un mínimo de '||v_MIN_LONGITUD_CTA||' dígitos y máximo de '||v_MAX_LONGITUD_CTA,'E',TRUE);
					         
						       ELSE
						         if nvl(:cg$ctrl.ind_nueva_cuenta,'N') = 'S' then
							         OPEN Cur_CUENTA_EXISTE_LOV;
							         FETCH Cur_CUENTA_EXISTE_LOV INTO V_CUENTA_EXISTE_LOV;
							         CLOSE Cur_CUENTA_EXISTE_LOV;
							         
							         IF NVL(V_CUENTA_EXISTE_LOV,0) = 1 THEN
							         		MSG_ALERT('Cuenta Bancaria duplicada.','W',FALSE);
							         END IF;
							       end if;
					          End if;    
					      End if;
					  END IF;
      End if;
END;
