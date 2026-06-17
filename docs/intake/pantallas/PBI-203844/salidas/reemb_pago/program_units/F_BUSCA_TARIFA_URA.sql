-- PROGRAM UNIT: F_BUSCA_TARIFA_URA
-- Tipo: Function
-- ====================================================================

FUNCTION f_busca_tarifa_ura( p_compania            poliza.compania%type    ,
                             p_ramo								 poliza.ramo%type				 ,
                             p_plan                reclamacion.plan%type   ,
                             p_servicio            rec_c_sal.servicio%type ,
                             p_tipo_cobertura      rec_c_sal.tip_cob%type  ,
                             p_grupo_cobertura     grupo_cobertura.codigo%type,
                             p_cobertura           rec_c_sal.cobertura%type   ,
                             p_fec_ser             date) return number is
   
   -- variables
   v_monto     number :=0;

-- cuerpo
begin
  	-- Call the function
  	v_monto := PKG_TARIFAS_URA.F_BUSCA_TARIFA_URA(p_compania 			 ,
	                                                p_ramo					 ,
	                                                p_plan 					 ,
	                                                p_servicio 			 ,
	                                                p_tipo_cobertura ,
	                                                p_grupo_cobertura,
	                                                p_cobertura 		 ,
	                                                p_fec_ser );
   	--
   	return (v_monto);
   	--
exception
	when others then  	 	
       pkg_general.p_inserta_error(:CG$CTRL.programa||'f_busca_tarifa_ura', 
       															sqlcode, substr(sqlerrm ,1, 1000), 'Error proceso buscar Tarifa URA.');  
       --                           
end f_busca_tarifa_ura;
