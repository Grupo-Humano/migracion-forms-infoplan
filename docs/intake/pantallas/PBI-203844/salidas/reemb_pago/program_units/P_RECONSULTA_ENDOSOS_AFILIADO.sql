-- PROGRAM UNIT: P_RECONSULTA_ENDOSOS_AFILIADO
-- Tipo: Procedure
-- ====================================================================

PROCEDURE p_reconsulta_endosos_afiliado IS
	P_ROWS_UPDATED_BEL	NUMBER;
	P_ROWS_UPDATED_BEI	NUMBER;	  
	vAse								NUMBER;
	vDep								NUMBER;
begin
	vAse:= to_number(SUBSTR(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,1,7));
	vDep:= to_number(SUBSTR( :SOLICITUD_SERVICIO.CODIGO_AFILIADO,8,3));

		PKG_BUSCA_INFO_ASE.P_BUSCA_ENDOSO_LOCAL(vAse, vDep, P_ROWS_UPDATED_BEL);--LLENA_ENDOSO_LOCAL;
		go_block('ENDOSOS_LOC');
		execute_query;
		
		PKG_BUSCA_INFO_ASE.P_BUSCA_ENDOSO_INT(vAse, P_ROWS_UPDATED_BEI);  --LLENA_ENDOSO_INT;
		go_block('ENDOSOS_INT');
		execute_query;
end;
