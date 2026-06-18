-- PROGRAM UNIT: P_VALIDARCOBERTURASAUTOMATICAS
-- Tipo: Procedure
-- ====================================================================

PROCEDURE p_ValidarCoberturasAutomaticas IS
	
   	 V_CODIGO_COBERTURA  VARCHAR2(100);
     V_montoReclamado  VARCHAR2(100);
     V_montoCubierto  VARCHAR2(100);
     V_COBERTURA_TIPO  VARCHAR2(100);
     V_MONTO_DIFERENCIA VARCHAR2(100);
     V_COASEGURO  VARCHAR2(100);
     V_MONTO_COASEGURO  VARCHAR2(100);
     V_MONTO_DEDUCIBLE  VARCHAR2(100);
     V_MONTO_CONTRATADO  VARCHAR2(100);
     V_NO_REEMBOLSADO  VARCHAR2(100);
		 V_GRUPOCOBERTURA varchar2(100):=null;
		 V_ESPAQUETE NUMBER:=null;
		 V_ID_RECHAZO   VARCHAR2(200);
     V_CODIGO_RECHAZO   VARCHAR2(200);
     V_NOMBRE_RECHAZO  VARCHAR2(2000);
		 
		 V_LIMITE  NUMBER;
		 V_TASA NUMBER;
		 V_POR_COA NUMBER;
		 V_PLAN_MASTER NUMBER;
		 V_POR_PAGAR NUMBER;
		 V_TIPO_PLAN NUMBER; 
     C_TIPO_TASA CONSTANT VARCHAR2(10):='C';
     C_TASA_DOLLAR CONSTANT VARCHAR2(10):='002';
     V_TIPO_COBERTURA NUMBER;
     V_FRECUENCIA_ACUMULADA NUMBER;
     V_EMPRESA NUMBER;
     c_id_rechazo constant number:=230;
	
	v_compania number;
	V_VAL_PARM3 varchar2(100);	
	v_disponible number;
	V_TIP_ACUMULADO NUMBER;
	v_monto_restante number;
	V_MONTO_PAGAR_INT NUMBER;

  V_ASEGURADO   NUMBER;
  V_DEPENDIENTE NUMBER;
  V_MONTO_TOTAL NUMBER:=0;
  c_mensaje_1 constant varchar2(2000):='Se ha agotado el Limite por servicio para ';
  c_mensaje_2 constant varchar2(2000):='. El monto total para este reembolso solicitado es ';
  v_descripcion_servicio varchar2(2000);
  v_montocoberturatmp number;
  V_LIMITE_SERVICIO NUMBER;
  V_TIPO_AFILIADO VARCHAR2(100);
   C_PENDIENTE CONSTANT NUMBER:=942; --//"Pendiente"
   C_GESTION_INTERNA CONSTANT NUMBER:=944; --//"GESTION INTERNA"
   C_PENDIENTE_DE_DOCUMENTACION CONSTANT NUMBER:= 949; --// "Pendiente de Documentación"
   V_FECHA_INICIO DATE:=:CG$CTRL.fecha_renovacion;
   V_FECHA_FIN DATE:=add_months(V_fecha_inicio,12);
   v_consumo_pendientes number;
   V_NUMERO_CARNET NUMBER;
   V_ASEGURADO1 NUMBER;
   V_SECUENCIA1 NUMBER;
   V_GRUP_PLA NUMBER:=0;  -- VARIABLE PARA BUSQUEDA DEL GRUPO_PLAN LTAVERAS 02/09/2025
  

  cursor CUR_MONTO_DISP_MEDICAMENTOS is
  	select cobertura_disponible + disponible2
  	 from REEMBOLSO.TEM_LIMITE_MEDICAMENTO
  	where plastico = :SOLICITUD_SERVICIO.NUMERO_CARNET
  	 and plan_arsh = :SOLICITUD_SERVICIO.CODIGO_PLAN
  	order by 1 desc;
  	
  	cursor CUR_LIMITE_SERVICIO(p_com_pol NUMBER,p_ramo_pol NUMBER,p_sec_pol NUMBER,p_plan NUMBER,p_tip_rec VARCHAR2,p_servicio NUMBER,p_tip_a_uso VARCHAR2) IS 
  	 SELECT pol_p_ser.LIMITE
           FROM poliza_plan_servicio pol_p_ser
          WHERE     pol_p_ser.compania = p_com_pol
                AND pol_p_ser.ramo = p_ramo_pol
                AND pol_p_ser.secuencial = p_sec_pol
                AND pol_p_ser.PLAN = p_plan
                AND pol_p_ser.tip_rec = p_tip_rec
                AND pol_p_ser.servicio = p_servicio
                AND pol_p_ser.tip_a_uso = p_tip_a_uso;
                
      cursor CUR_DESC_SERVICIO IS 
      SELECT DESCRIPCION
      FROM SERVICIO_SALUD 
      WHERE CODIGO= :SOLICITUD_SERVICIO.TIPO_SERVICIO;
      
      
      cursor cur_ejemplo is 
     select cobertura_disponible, disponible2,plastico,plan_arsh
  	 from REEMBOLSO.TEM_LIMITE_MEDICAMENTO;
  	 
  	 --of09012023
  	  cursor cur_buscarcobnorepliplanpol is 
  	   select sum(nvl(cse.MONTO_COBERTURA,0)) 
       FROM Cobertura_Solicitada cse, solicitud_servicio ss,solicitud_pago re
       where ss.id=CSE.SOLICITUD_SERVICIO_ID
       and re.id=SS.SOLICITUD_PAGO_ID
       and cse.solicitud_servicio_id !=nvl(:SOLICITUD_SERVICIO.ID,0)
       and trunc(ss.fecha_servicio)>=trunc(V_FECHA_INICIO)
       and trunc(ss.fecha_servicio)<=trunc(V_fecha_fin)
       and ss.afiliado_numero=:SOLICITUD_SERVICIO.CODIGO_AFILIADO
       and not exists(select 1 from reclamo r where r.SOLICITUD_SERVICIO_ID=ss.id)
       and ss.estatus in (C_PENDIENTE,C_GESTION_INTERNA,C_PENDIENTE_DE_DOCUMENTACION) --estatus 944-gestion interna,949-pendiente documentacion,942-pendiente 
       and ss.SERVICIO_TIPO_ID=nvl(:SOLICITUD_SERVICIO.TIPO_SERVICIO,ss.SERVICIO_TIPO_ID)--of06092023 servicio se cambio solicitud_servicio --and cse.tipo_serv_salud_id =nvl(v_tipo_servicio,cse.tipo_serv_salud_id)
       and CSE.COBERTURA_TIPO IN (76,77,336,556,756);
       
       
        	 
  	 --of16012024 se creo este cursor para buscar el consumido pendiente para alto_costo y renal por servicio,tipo_cobertura
  	  cursor cur_buscarconsumporservicio is 
  	   select sum(nvl(cse.MONTO_COBERTURA,0)) 
       FROM Cobertura_Solicitada cse, solicitud_servicio ss,solicitud_pago re
       where ss.id=CSE.SOLICITUD_SERVICIO_ID
       and re.id=SS.SOLICITUD_PAGO_ID
       and cse.solicitud_servicio_id !=nvl(:SOLICITUD_SERVICIO.ID,0)
       and trunc(ss.fecha_servicio)>=trunc(V_FECHA_INICIO)
       and trunc(ss.fecha_servicio)<=trunc(V_fecha_fin)
       and ss.afiliado_numero=:SOLICITUD_SERVICIO.CODIGO_AFILIADO
       and not exists(select 1 from reclamo r where r.SOLICITUD_SERVICIO_ID=ss.id)
       and ss.estatus in (C_PENDIENTE,C_GESTION_INTERNA,C_PENDIENTE_DE_DOCUMENTACION) --estatus 944-gestion interna,949-pendiente documentacion,942-pendiente 
       and ss.SERVICIO_TIPO_ID=:SOLICITUD_SERVICIO.TIPO_SERVICIO
       and CSE.COBERTURA_TIPO=:SOLICITUD_SERVICIO_DETALLE.COBERTURA_TIPO;
       
       	 --of16012024 se creo este cursor para buscar el consumido pendiente por servicio gmm
  	  cursor cur_busconsumporserviciogmmren is 
  	   select sum(nvl(cse.MONTO_COBERTURA,0)) 
       FROM Cobertura_Solicitada cse, solicitud_servicio ss,solicitud_pago re
       where ss.id=CSE.SOLICITUD_SERVICIO_ID
       and re.id=SS.SOLICITUD_PAGO_ID
       and cse.solicitud_servicio_id !=nvl(:SOLICITUD_SERVICIO.ID,0)
       and trunc(ss.fecha_servicio)>=trunc(V_FECHA_INICIO)
       and trunc(ss.fecha_servicio)<=trunc(V_fecha_fin)
       and ss.afiliado_numero=:SOLICITUD_SERVICIO.CODIGO_AFILIADO
       and not exists(select 1 from reclamo r where r.SOLICITUD_SERVICIO_ID=ss.id)
       and ss.estatus in (C_PENDIENTE,C_GESTION_INTERNA,C_PENDIENTE_DE_DOCUMENTACION) --estatus 944-gestion interna,949-pendiente documentacion,942-pendiente 
       and ss.SERVICIO_TIPO_ID=:SOLICITUD_SERVICIO.TIPO_SERVICIO;
       
       CURSOR CUR_LIMITE_INT IS 
       	SELECT DISTINCT MON_MAX FROM GRUPO_PLAN_BENEFICIOS
				WHERE PLAN = :SOLICITUD_SERVICIO.CODIGO_PLAN
				AND GRUPO = :BUSCA_SERVICIO.GRUPO_COBERTURA
				ORDER BY DECODE(GRUPO,'GEN',' ','GRU', '  ',GRUPO);
       
       CURSOR CUR_TIPO_PLAN IS
       	SELECT TIPO, TIP_PLA FROM PLAN
					WHERE CODIGO = :SOLICITUD_SERVICIO.CODIGO_PLAN;
					
		   CURSOR CUR_POR_COA IS
		   	SELECT DISTINCT POR_COA FROM POL_LCR
					WHERE compania = TO_NUMBER(REGEXP_SUBSTR(:PLANES.POLIZA, '[^-]+', 1, 1))
					and ramo = TO_NUMBER(REGEXP_SUBSTR(:PLANES.POLIZA, '[^-]+', 1, 2))
					and secuencial = TO_NUMBER(REGEXP_SUBSTR(:PLANES.POLIZA, '[^-]+', 1, 3))
					and servicio =:SOLICITUD_SERVICIO.TIPO_SERVICIO
					and tip_cob in (76,77, 556);
					
	CURSOR CUR_POR_COA_S IS  --BUSCA EL PORCIENTO DE COASEGURDO DE SIGNO DE PESO
		   	SELECT DISTINCT POR_COA FROM DBAPER.POLIZA_PLAN_SERVICIO
					WHERE compania = TO_NUMBER(REGEXP_SUBSTR(:PLANES.POLIZA, '[^-]+', 1, 1))
					and ramo = TO_NUMBER(REGEXP_SUBSTR(:PLANES.POLIZA, '[^-]+', 1, 2))
					and secuencial = TO_NUMBER(REGEXP_SUBSTR(:PLANES.POLIZA, '[^-]+', 1, 3))
					and servicio =:SOLICITUD_SERVICIO.TIPO_SERVICIO
					and TIP_REC = 'FARMACIA';

BEGIN
DEBUG.SUSPEND;
--manejo de monedas,calculo forebra01092023
  if :BUSCA_SERVICIO.MONEDA_ADD = PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('COD_MONEDA_DOLAR',:GLOBAL.COD_COMPANIA) THEN    
     V_TASA:= F_TASA(C_TASA_DOLLAR, TRUNC (SYSDATE), C_TIPO_TASA);
     
     :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO:= :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO * V_TASA;

  END IF;
	
	

  

IF NVL(:SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO,0) > 0 AND :SOLICITUD_SERVICIO_DETALLE.FRECUENCIA IS NOT NULL  THEN
	
	
			--OF01092023
			
			 V_TIPO_COBERTURA:=INNOVACORE.PKG_INNOVA.FDP_DET_TIPO_COB(:SOLICITUD_SERVICIO.TIPO_SERVICIO,:SOLICITUD_SERVICIO_DETALLE.COBERTURA);
			
			
			 :SOLICITUD_SERVICIO_DETALLE.ID_FRECUENCIA:=	F_FREC_CONS_TEMP_IN_UP(V_TIPO_COBERTURA,
																																					:SOLICITUD_SERVICIO_DETALLE.FRECUENCIA,
																																					:SOLICITUD_SERVICIO_DETALLE.ID_FRECUENCIA);		
																																					
																																					
			V_FRECUENCIA_ACUMULADA:=	F_FREC_CONS_TEMP_SUMA(V_TIPO_COBERTURA,
																											:SOLICITUD_SERVICIO_DETALLE.FRECUENCIA,
																											:SOLICITUD_SERVICIO_DETALLE.ID_FRECUENCIA);	
																											
	
																											
			--OF11122023
			IF  :SOLICITUD_SERVICIO.CODIGO_PLAN=230 THEN 
			  V_EMPRESA:=96;
			ELSE 
				V_EMPRESA:=30;
			END IF;
			
			
				V_ASEGURADO1:= to_number(SUBSTR(NVL(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,:CG$CTRL.NO_AFI),1,7)); 
				V_SECUENCIA1:= to_number(SUBSTR(NVL(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,:CG$CTRL.NO_AFI),8,3)); 
			
				P_LLENA_CARNET_AFI(V_ASEGURADO1, V_SECUENCIA1);
			
--			message(V_FRECUENCIA_ACUMULADA);
---			message(V_FRECUENCIA_ACUMULADA);
	
			reembolso.P_VALIDARCOBERTURASFRM_2(:SOLICITUD_SERVICIO.SOLICITUD_PAGO_ID,
		     :SOLICITUD_SERVICIO.ID,
		     :SOLICITUD_SERVICIO_DETALLE.COBERTURA,
		     :SOLICITUD_SERVICIO_DETALLE.DSP_COBERTURA,
		     :SOLICITUD_SERVICIO_DETALLE.FRECUENCIA,
		     :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO * :SOLICITUD_SERVICIO_DETALLE.FRECUENCIA, --OF6/12/2023
		     :SOLICITUD_SERV_DIAG.COD_DIAGNOSTICO,
		     :BUSCA_SERVICIO.TIPO_PRESTADOR_ADD,
		     :SOLICITUD_SERVICIO_DETALLE.PROVEEDOR_ID,--lo cambie por el id proveedor que se recibe26082023 --:SOLICITUD_SERVICIO_DETALLE.PROVEEDOR_ID,--:BUSCA_SERVICIO.ID_PRESTADOR,
		     :SOLICITUD_SERVICIO.FECHA_SERVICIO,
		     v_grupocobertura,
		     V_ESPAQUETE,
		     :SOLICITUD_SERVICIO.MEDICO,
		     :SOLICITUD_SERVICIO.ESPECIALIDAD,  
		     V_CODIGO_COBERTURA,
		     V_montoReclamado,
		     V_montoCubierto,
		     V_COBERTURA_TIPO,
		     V_MONTO_DIFERENCIA,
		     V_COASEGURO,
		     V_MONTO_COASEGURO,
		     V_MONTO_DEDUCIBLE,
		     V_MONTO_CONTRATADO,
		     V_NO_REEMBOLSADO,
		     V_ID_RECHAZO,
		     V_CODIGO_RECHAZO,
		     V_NOMBRE_RECHAZO,
		     --AGREGAR PARAMETROS DE FORMA
		    :RADICACION.CODIGO_EXTERNO,
		     :RADICACION.ESTADO, 
		     :RADICACION.NUMERO_CUENTA, 
		    :RADICACION.BANCO, 
		    :RADICACION.MEDIO_PAGO, 
		    :RADICACION.ESTATUS,  
		    TRUNC(:RADICACION.FECHA_APERTURA),  -- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (11/02/2024). SE MODIFICO LA HORA EN FEC_TRA 
		    :RADICACION.FECHA_RECEPCION,
		    V_EMPRESA, --OF11122023 SE HIZO ESTE AJUSTE PARA EL MANEJO DE COMPANIA CUANDO ES PLAN BASICO
		    :SOLICITUD_SERVICIO.NUMERO_CARNET, 
		    :SOLICITUD_SERVICIO.FECHA_SERVICIO, 
		    :SOLICITUD_SERVICIO.TIPO_SERVICIO, 
		    :SOLICITUD_SERVICIO.ESTATUS, 
		    :SOLICITUD_SERVICIO.PROVEEDOR_ID, 
		    :SOLICITUD_SERVICIO.ESTADO_SERVICIO, 
		    :SOLICITUD_SERVICIO.CODIGO_AFILIADO, 
		    :SOLICITUD_SERVICIO.FECHA_SOLICITUD,
		    :CG$CTRL.MOTIVOS_RECORD, --OF02072023,
		    :SOLICITUD_SERVICIO.CODIGO_PLAN, --OF08122023,
		    V_FRECUENCIA_ACUMULADA,----OF01092023
		    :SOLICITUD_SERVICIO.SUB_GRUPO_SERVICIO,
		    	    --<Edelcarmen-Forebra> 27nov2023 
		    :SOLICITUD_SERVICIO_DETALLE.DIAS_TERAPIA,
		    :SOLICITUD_SERVICIO_DETALLE.DOSIS_DIARIA,
		    1
		    --</Edelcarmen-Forebra>
		    );  
		    



				:SOLICITUD_SERVICIO_DETALLE.COBERTURA_TIPO := nvl(V_COBERTURA_TIPO,0);
				:SOLICITUD_SERVICIO_DETALLE.PROVEEDOR_ID := :SOLICITUD_SERVICIO_DETALLE.PROVEEDOR_ID; --:BUSCA_SERVICIO.ID_PRESTADOR;
				:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL := V_montoReclamado; --OF6/12/2023
				:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR := V_montoCubierto; --of6/20/2023
			  :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=   V_MONTO_DIFERENCIA;
				:SOLICITUD_SERVICIO_DETALLE.MONTO_UNITARIO := :SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL;
				:SOLICITUD_SERVICIO_DETALLE.COASEGURO := V_COASEGURO; -- 100 - V_PORCENTAJE;
				:SOLICITUD_SERVICIO_DETALLE.MONTO_COASEGURO :=V_MONTO_COASEGURO;   --:BUSCA_SERVICIO.MON_RECLAMO_ADD - V_MONTO_PAGAR;
				:SOLICITUD_SERVICIO_DETALLE.ESTATUS := 1;
				
---------   CONDICION DEL MONTO A PAGAR EVALUANDO EL MONTO TIOPE DE ASIGNA_TOPE_COBERTURA  LTAVERAS 01/09/25
					
-------------- BLOQUE PARA LA BUSQUEDA DEL GRUPO_PLAN
					 BEGIN
            SELECT TIP_PLA
            INTO V_GRUP_PLA
            FROM PLAN
            WHERE CODIGO = TO_NUMBER(:SOLICITUD_SERVICIO.CODIGO_PLAN);
        	END; 
--------------------------------------------------------------------------------------------------

-------------- Lógica de tope de monto a nivel de forma para evaluar el monto registrado en asigna_tope			
					DECLARE
					    v_monto_tope NUMBER;					    
					    v_fecha_prima DATE;  -- Fecha de la Poliza para seleccionar la fecha de version que corresponde segun HU 174636. 22/10/2025
					BEGIN
						  -- Traigo el MONTO TOPE para el plan/cobertura
              BEGIN
						    SELECT a.MONTO_TOPE_REEMBOLSO
						      INTO v_monto_tope
						      FROM REEMBOLSO.ASIGNA_TOPE_COBERTURA a
						     WHERE a.CODIGO_COBERTURA = :SOLICITUD_SERVICIO_DETALLE.COBERTURA
						     AND a.Codigo_plan = V_GRUP_PLA; -- Monto_tope llega vacio porque no lee el tipo_plan. !!!
						  EXCEPTION WHEN TOO_MANY_ROWS THEN v_monto_tope := NULL;
                        WHEN NO_DATA_FOUND THEN v_monto_tope := NULL;
              END;
						  -- Si hay mas de un tope busco la fecha de la prima para volver a buscar el monto tope
              IF v_monto_tope IS NULL THEN
								  SELECT MAX(FEC_VER) INTO v_fecha_prima
								    FROM PRIMA_POLIZA_SALUD
								    WHERE COMPANIA = :GLOBAL.COD_COMPANIA
								      AND RAMO     = :SOLICITUD_SERVICIO.RAMO
								      AND SECUENCIAL = :SOLICITUD_SERVICIO.SECUENCIAL
								      AND PLAN     = TO_NUMBER(:SOLICITUD_SERVICIO.CODIGO_PLAN);
								  -- Busco el MONTO TOPE para la fecha mayor fecha que sea menor a la fecha de la prima
							    SELECT a.MONTO_TOPE_REEMBOLSO
							      INTO v_monto_tope
							      FROM REEMBOLSO.ASIGNA_TOPE_COBERTURA a
							     WHERE a.CODIGO_COBERTURA = :SOLICITUD_SERVICIO_DETALLE.COBERTURA
							     AND a.Codigo_plan = V_GRUP_PLA -- Monto_tope llega vacio porque no lee el tipo_plan. !!!
							     AND a.FEC_VER in ( SELECT MAX(b.FEC_VER) FROM REEMBOLSO.ASIGNA_TOPE_COBERTURA b
							                          WHERE b.CODIGO_COBERTURA = a.CODIGO_COBERTURA
							                            AND b.Codigo_plan = a.Codigo_plan
							                            AND TRUNC(b.FEC_VER)     <= v_fecha_prima);
								  -- Si no encuentra datos para esa condicion busco el MONTO TOPE para la fecha menor fecha que sea mayor a la fecha de la prima
                 IF v_monto_tope IS NULL THEN
							    SELECT a.MONTO_TOPE_REEMBOLSO
							      INTO v_monto_tope
							      FROM REEMBOLSO.ASIGNA_TOPE_COBERTURA a
							     WHERE a.CODIGO_COBERTURA = :SOLICITUD_SERVICIO_DETALLE.COBERTURA
							     AND a.Codigo_plan = V_GRUP_PLA -- Monto_tope llega vacio porque no lee el tipo_plan. !!!
							     AND a.FEC_VER in ( SELECT MIN(b.FEC_VER) FROM REEMBOLSO.ASIGNA_TOPE_COBERTURA b
							                          WHERE b.CODIGO_COBERTURA = a.CODIGO_COBERTURA
							                            AND b.Codigo_plan = a.Codigo_plan
							                            AND TRUNC(b.FEC_VER)     >= v_fecha_prima);

                 END IF;
             END IF;

					    -- Si el monto a pagar es mayor al tope, se asigna el tope y se calcula la diferencia
					    IF :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR >= v_monto_tope THEN
					    		:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR := v_monto_tope;
					        :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA := ABS(TO_NUMBER(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR)- V_montoReclamado);
					        :SOLICITUD_SERVICIO_DETALLE.MONTO_DEDUCIBLE := 0;
					        :SOLICITUD_SERVICIO_DETALLE.MONTO_COASEGURO:=0;
					        
					        MSG_ALERT('La cobertura que intenta autorizar no puede exceder el tope configurado de RD$ ' || TO_CHAR(v_monto_tope), 'I', FALSE);

					   /* ELSE
					    	:SOLICITUD_SERVICIO_DETALLE.MONTO_NO_REEMB :=nvl(:SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA,0) + nvl(:SOLICITUD_SERVICIO_DETALLE.MONTO_COASEGURO,0) + nvl(:SOLICITUD_SERVICIO_DETALLE.MONTO_DEDUCIBLE,0);
					   */
					    END IF;
					EXCEPTION
					    WHEN NO_DATA_FOUND THEN
					        NULL;
					END;	
					
	--OF 13122023 SE HIZO ESTE MANEJO PARA ACUMULAR EL MONTO TOTAL A PAGAR Y COMPARARLO CON EL DISPONIBLE QUE TIENE PARA ESTOS SERVICIOS EL AFILIADO 

 IF V_ID_RECHAZO IS NULL THEN 
  	
				V_ASEGURADO   := to_number(SUBSTR(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,1,7));
			  V_DEPENDIENTE := to_number(SUBSTR(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,8,3));
			  
			  
			  	if :solicitud_servicio.CODIGO_PLAN=230 then 
							v_compania:=96;
					else
								v_compania:=30;
				  end if;
					
					if :SOLICITUD_SERVICIO.TIPO_SERVICIO = DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('ALTO_COSTO',30) then 
                 v_descripcion_servicio:='Alto Costo';
          elsif :SOLICITUD_SERVICIO.TIPO_SERVICIO = DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('SERVICIO_RENAL',30) then
                 v_descripcion_servicio:='Servicio Renal';
          elsif :SOLICITUD_SERVICIO.TIPO_SERVICIO = DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('GMM',30) then
                 v_descripcion_servicio:='Gastos Medicos Mayores';
          end if;
						

		      if NVL(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,0) > 0  then 
			
								 IF (:SOLICITUD_SERVICIO.TIPO_SERVICIO = DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('ALTO_COSTO',:GLOBAL.COD_COMPANIA) AND :SOLICITUD_SERVICIO.SUB_GRUPO_SERVICIO IS NOT NULL) OR 
							  	 (:SOLICITUD_SERVICIO.TIPO_SERVICIO = DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('SERVICIO_RENAL',:GLOBAL.COD_COMPANIA) AND :SOLICITUD_SERVICIO.SUB_GRUPO_SERVICIO IS NOT NULL) THEN
								 
																						 
											    PKG_INNOVA.P_VALIDA_DISPONIBLE_SERVICIO(V_ASEGURADO,                         V_DEPENDIENTE,                  :SOLICITUD_SERVICIO.SUB_GRUPO_SERVICIO,   
											                                         :SOLICITUD_SERVICIO.FECHA_SERVICIO
											                                          , v_compania, :SOLICITUD_SERVICIO.TIPO_SERVICIO, 
											                                          v_disponible,      V_VAL_PARM3);   
			
									             
									             --of16012024 se comento porque se usara la misma logica usada anteriormente para los disponibley limite de servicio
									          /*   V_MONTO_TOTAL:=:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR;
									             
											        if trunc(V_MONTO_TOTAL) > trunc(v_disponible) then 
											 	      
											        V_ID_RECHAZO:=c_id_rechazo;
										          V_NOMBRE_RECHAZO:=c_mensaje_1||v_descripcion_servicio||' Monto Disponible:'||to_char(v_disponible,'999,999,999')||
										          c_mensaje_2||to_char(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR,'999,999,999');
										           
										              :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=0;
										              :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL;
											        end if;   */
											        
											        --of16012024 inicio	
											     v_montocoberturatmp:=:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR;	
											    if :SOLICITUD_SERVICIO.TIPO_SERVICIO = DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('SERVICIO_RENAL',:GLOBAL.COD_COMPANIA) then 
		
												 			open cur_busconsumporserviciogmmren;
												 			fetch cur_busconsumporserviciogmmren into v_consumo_pendientes;
												 			close cur_busconsumporserviciogmmren;
											    else 
											    		open cur_buscarconsumporservicio;
										 			    fetch cur_buscarconsumporservicio into v_consumo_pendientes;
										 			    close cur_buscarconsumporservicio;
										 			end if;

										 		  PKG_GENERAL.P_INSERTA_ERROR('reemb_pago_alto_renal', sqlcode, sqlerrm, 'v_consumo_pendientes:'||nvl(v_consumo_pendientes,0));
										 		  
                          v_disponible:=nvl(v_disponible,0) - nvl(v_consumo_pendientes,0); 
                          
                          if v_disponible < 0 then 
                          	 v_disponible:=0;
                          end if;
			
										 			if v_disponible <= 0 then 
										 				
										         V_ID_RECHAZO:=c_id_rechazo;
										          V_NOMBRE_RECHAZO:=c_mensaje_1||v_descripcion_servicio||','||' Monto Disponible:'||to_char(v_disponible,'999,999,999')
										          								||'. El monto consumido pendiente de aprobacion es '||to_char(nvl(v_consumo_pendientes,0),'999,999,999')
										                          ||'. El monto solicitado para esta cobertura es '||to_char(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,'999,999,999');
										                          
										          :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=0;
										          :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL;  --monto_reclamado
										          
										 			elsif v_disponible > 0 then 
										 				
										 				    if (nvl(v_disponible,0)- nvl(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR,0)) < 0 then 
										 				    	 v_monto_restante:= nvl(v_disponible,0)-(nvl(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR,0) - nvl(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,0));
										 				    	   :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=v_monto_restante;
										                 :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL - v_monto_restante;
										                 
										                 PKG_GENERAL.P_INSERTA_ERROR('reemb_pago_alto_renal', sqlcode, sqlerrm, 'v_monto_restante:'||v_monto_restante);
										 				    end if;
										 				    
										 				    if nvl(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,0) <= 0 then 
										                    V_ID_RECHAZO:=c_id_rechazo;
										                    V_NOMBRE_RECHAZO:=c_mensaje_1||v_descripcion_servicio||','||' Monto Disponible:'||to_char(v_disponible-(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR-:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR),'999,999,999')
										                                    ||'. El monto consumido pendiente de aprobacion es '||to_char(nvl(v_consumo_pendientes,0),'999,999,999')
										                                    ||'. El monto solicitado para esta cobertura es '||to_char(v_montocoberturatmp,'999,999,999');
										                    :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=0;
										                    :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL;  --monto_reclamado
										 				    	
										 				    end if;
										 				
										 				end if;
											        
											        --of16012024 fin                                                                          	
							   END IF;
				 
						     IF :SOLICITUD_SERVICIO.TIPO_SERVICIO = PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('GMM',:GLOBAL.COD_COMPANIA) THEN
										 		
										 			PKG_INNOVA.P_VALIDA_DISPONIBLE_GMM(V_ASEGURADO,                    V_DEPENDIENTE,                  :SOLICITUD_SERVICIO.FECHA_SERVICIO,  
								                                      v_compania,v_disponible, V_VAL_PARM3);
								                    

								           /*  V_MONTO_TOTAL:=:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR;
										 	   	 if trunc(V_MONTO_TOTAL) > trunc(v_disponible)  then 
										 	      
										         V_ID_RECHAZO:=c_id_rechazo;
										          V_NOMBRE_RECHAZO:=c_mensaje_1||v_descripcion_servicio||' Monto Disponible:'||to_char(v_disponible,'999,999,999')||c_mensaje_2||to_char(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR,'999,999,999');
										          :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=0;
										          :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL;
										       end if;*/
										       
										              --of16012024 inicio			
										       v_montocoberturatmp:=:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR;	
										 			open cur_busconsumporserviciogmmren;
										 			fetch cur_busconsumporserviciogmmren into v_consumo_pendientes;
										 			close cur_busconsumporserviciogmmren;
										 			
										 		  PKG_GENERAL.P_INSERTA_ERROR('reemb_pago_gmm', sqlcode, sqlerrm, 'v_consumo_pendientes:'||nvl(v_consumo_pendientes,0));
										 		  
                          v_disponible:=nvl(v_disponible,0) - nvl(v_consumo_pendientes,0); 
                          
                          if v_disponible < 0 then 
                          	 v_disponible:=0;
                          end if;
			
										 			if v_disponible <= 0 then 
										 				
										         V_ID_RECHAZO:=c_id_rechazo;
										          V_NOMBRE_RECHAZO:=c_mensaje_1||v_descripcion_servicio||','||' Monto Disponible:'||to_char(v_disponible,'999,999,999')
										          								||'. El monto consumido pendiente de aprobacion es '||to_char(nvl(v_consumo_pendientes,0),'999,999,999')
										                          ||'. El monto solicitado para esta cobertura es '||to_char(nvl(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,0),'999,999,999');
										                          
										          :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=0;
										          :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL;  --monto_reclamado
										          
										 			elsif v_disponible > 0 then 
										 				
										 				    if (nvl(v_disponible,0)- nvl(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR,0)) < 0 then 
										 				    	 v_monto_restante:= nvl(v_disponible,0)-(nvl(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR,0) - nvl(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,0));
										 				    	   :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:= v_monto_restante;
										                 :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL - v_monto_restante;
										                 
										                 PKG_GENERAL.P_INSERTA_ERROR('reemb_pago_gmm', sqlcode, sqlerrm, 'v_monto_restante:'||v_monto_restante);
										 				    end if;
										 				    
										 				    if nvl(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,0) <= 0 then 
										                    V_ID_RECHAZO:=c_id_rechazo;
										                    V_NOMBRE_RECHAZO:=c_mensaje_1||v_descripcion_servicio||','||' Monto Disponible:'||to_char(v_disponible-(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR-:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR),'999,999,999')
										                                    ||'. El monto consumido pendiente de aprobacion es '||to_char(nvl(v_consumo_pendientes,0),'999,999,999')
										                                    ||'. El monto solicitado para esta cobertura es '||to_char(nvl(v_montocoberturatmp,0),'999,999,999');
										                    :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=0;
										                    :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL;  --monto_reclamado
										 				    	
										 				    end if;
										 				
										 				end if;
											        
											        --of16012024 fin 
								 END IF;
			 
			        
		
								 IF :BUSCA_SERVICIO.TIPO_CENTRO_MEDICO_ID = 8 and V_ID_RECHAZO IS NULL and NVL(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,0) > 0 THEN
								 	
								 				v_montocoberturatmp:=:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR;
								 					PKG_GENERAL.P_INSERTA_ERROR('reemb_pago', sqlcode, sqlerrm, 'monto_cobertura_temp:'||v_montocoberturatmp);
										 		
										 			-- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (31/01/2024). START
										 			IF NVL(V_DEPENDIENTE,0) = 0 THEN  -- TITULAR/ASEGURADO
										 				
										 				OPEN CUR_MONTO_DISP_MEDICAMENTOS;
											 			FETCH CUR_MONTO_DISP_MEDICAMENTOS INTO v_disponible;
											 			CLOSE CUR_MONTO_DISP_MEDICAMENTOS;		

										 			ELSE -- DEPENDIENTE

														V_NUMERO_CARNET := 	TO_NUMBER(:SOLICITUD_SERVICIO.NUMERO_CARNET);						 													 														 			 
														
												    IF v_compania = 96 THEN					
													      P_PROCESA_AFILIADO_ARS(V_NUMERO_CARNET, 1, 9999, 96, V_DISPONIBLE);    													      
												    END IF;
														
														IF v_compania = 30 THEN
													      P_PROCESA_AFILIADO_SEG(V_NUMERO_CARNET, 1, 9999, 30, V_DISPONIBLE);    
												  	END IF;
													  
												  END IF;
										 			-- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (31/01/2024). END
										 		  
										 		  PKG_GENERAL.P_INSERTA_ERROR('reemb_pago', sqlcode, sqlerrm, 'plastico =:SOLICITUD_SERVICIO.NUMERO_CARNET:'||:SOLICITUD_SERVICIO.NUMERO_CARNET);
									  	 		PKG_GENERAL.P_INSERTA_ERROR('reemb_pago', sqlcode, sqlerrm, 'plan_arsh=:SOLICITUD_SERVICIO.CODIGO_PLAN:'||:SOLICITUD_SERVICIO.CODIGO_PLAN);
										 			PKG_GENERAL.P_INSERTA_ERROR('reemb_pago', sqlcode, sqlerrm, 'princv_disponible:'||v_disponible);
										 			PKG_GENERAL.P_INSERTA_ERROR('reemb_pago', sqlcode, sqlerrm, 'V_TIPO_COBERTURA:'||V_TIPO_COBERTURA);
										 			
										 			--of09012023
										 			open cur_buscarcobnorepliplanpol;
										 			fetch cur_buscarcobnorepliplanpol into v_consumo_pendientes;
										 			close cur_buscarcobnorepliplanpol;
										 			
										 		  PKG_GENERAL.P_INSERTA_ERROR('reemb_pago', sqlcode, sqlerrm, 'v_consumo_pendientes:'||nvl(v_consumo_pendientes,0));
										 		  
							
                          --of09012023 inicio
                          v_disponible:=nvl(v_disponible,0) - nvl(v_consumo_pendientes,0); --of11012023 se agrego nvl
                          
                          if v_disponible < 0 then 
                          	 v_disponible:=0;
                          end if;
                          --of09012023 fin
				
										 			
										 			for x in cur_ejemplo loop
										 				
										 				PKG_GENERAL.P_INSERTA_ERROR('reemb_pago', sqlcode, sqlerrm,'datos tabla temporary:REEMBOLSO.TEM_LIMITE_MEDICAMENTO '||'cobertura_disponible: '||X.cobertura_disponible||'disponible2: '|| X.disponible2||'plastico: '||X.plastico||'plan_arsh: '||X.plan_arsh);
										 				
										 			end loop;
										 	
										 			
										 			if v_disponible <= 0 then 
										 				
						
										 			   v_descripcion_servicio := 'Medicamentos';
										         V_ID_RECHAZO:=c_id_rechazo;
										          V_NOMBRE_RECHAZO:=c_mensaje_1||v_descripcion_servicio||' Monto Disponible:'||to_char(v_disponible,'999,999,999')
										          								||'. El monto consumido pendiente de aprobacion es '||to_char(nvl(v_consumo_pendientes,0),'999,999,999')
										                          ||'. El monto solicitado para esta cobertura es '||to_char(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,'999,999,999');
										                          
										          :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=0;
										          :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL;  --monto_reclamado
										          
										 			elsif v_disponible > 0 then 
										 				--of26122023 V_MONTO_TOTAL:=:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR;
										 				--of26122023 if trunc(V_MONTO_TOTAL) > trunc(v_disponible)  then 
										 				
										 				    if (nvl(v_disponible,0)- nvl(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR,0)) < 0 then 
										 				    	 -- v_monto_restante:=nvl(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR,0) - nvl(v_disponible,0);
	                                                          	  -- 40000-50000-
										 				    	 v_monto_restante:= nvl(v_disponible,0)-(nvl(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR,0) - nvl(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,0));
										 				    	   :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=v_monto_restante;
										                 :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL - v_monto_restante;
										                 
										                 PKG_GENERAL.P_INSERTA_ERROR('reemb_pago', sqlcode, sqlerrm, 'v_monto_restante:'||v_monto_restante);
										 				    end if;
										 				    
										 				    if nvl(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,0) <= 0 then 
										 				    				v_descripcion_servicio := 'Medicamentos';
										                    V_ID_RECHAZO:=c_id_rechazo;
										                    V_NOMBRE_RECHAZO:=c_mensaje_1||v_descripcion_servicio||' Monto Disponible:'||to_char(v_disponible-(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR-:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR),'999,999,999')
										                                    ||'. El monto consumido pendiente de aprobacion es '||to_char(nvl(v_consumo_pendientes,0),'999,999,999')
										                                    ||'. El monto solicitado para esta cobertura es '||to_char(v_montocoberturatmp,'999,999,999');
										                    :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=0;
										                    :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL;  --monto_reclamado
										 				    	
										 				    end if;
										 				
										 				end if;
										 			
								 END IF;
			 
		
		   
	--OF 13122023 SE HIZO ESTE MANEJO PARA ACUMULAR EL MONTO TOTAL A PAGAR Y COMPARARLO CON EL DISPONIBLE QUE TIENE PARA ESTOS SERVICIOS EL AFILIADO 
--------------------------------------------------------------------------------------------------------------------------

--of03012023 manejo de limite por servicio 
--inicio
-------------------------------------------
						IF :SOLICITUD_SERVICIO.TIPO_SERVICIO not in(DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('ALTO_COSTO',:GLOBAL.COD_COMPANIA), 
						                                            DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('SERVICIO_RENAL',:GLOBAL.COD_COMPANIA),
						                                            PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('GMM',:GLOBAL.COD_COMPANIA))
						                                            and V_ID_RECHAZO IS NULL and NVL(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,0) > 0  then 
						
							         v_montocoberturatmp:=:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR;
							         		
							         		V_ASEGURADO   := to_number(SUBSTR(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,1,7));
                         	V_DEPENDIENTE := to_number(SUBSTR( :SOLICITUD_SERVICIO.CODIGO_AFILIADO,8,3));
                         	
							         	IF NVL(V_DEPENDIENTE,0) = 0 THEN
													V_TIPO_AFILIADO := 'ASEGURADO';
												ELSE
													V_TIPO_AFILIADO := 'DEPENDIENT';
												END IF;	
							

											  OPEN CUR_LIMITE_SERVICIO(V_COMPANIA,:SOLICITUD_SERVICIO.RAMO, :SOLICITUD_SERVICIO.SECUENCIAL,:SOLICITUD_SERVICIO.CODIGO_PLAN,'ASEGURADO',:SOLICITUD_SERVICIO.TIPO_SERVICIO,V_TIPO_AFILIADO) ;
											  FETCH CUR_LIMITE_SERVICIO INTO V_LIMITE_SERVICIO;
											  CLOSE CUR_LIMITE_SERVICIO;
											  

											  OPEN CUR_DESC_SERVICIO;
											  FETCH CUR_DESC_SERVICIO INTO v_descripcion_servicio;
											  CLOSE CUR_DESC_SERVICIO;
								    
								      	IF NVL(V_LIMITE_SERVICIO,0) > 0	THEN  
										 
										--	  PKG_GENERAL.P_INSERTA_ERROR('reemb_pago', sqlcode, sqlerrm, 'LIMTE_SERVICIO_PRINCI:'||V_LIMITE_SERVICIO);
												
												v_disponible:=V_LIMITE_SERVICIO - (nvl(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR,0) - nvl(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,0)) ;		
																 			
										--	 PKG_GENERAL.P_INSERTA_ERROR('reemb_pago', sqlcode, sqlerrm, 'princv_disponible:'||v_disponible);
																 			
															if v_disponible <= 0 then 
																		 				
														
													
																	V_ID_RECHAZO:=c_id_rechazo;
																	V_NOMBRE_RECHAZO:=c_mensaje_1||LOWER(v_descripcion_servicio)||'.'||' Monto Limite por servicio:'||to_char(V_LIMITE_SERVICIO,'999,999,999');
																	:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=0;
																	:SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL;  --monto_reclamado
																	:SOLICITUD_SERVICIO_DETALLE.MONTO_COASEGURO :=0;
																		          
															elsif v_disponible > 0 then
																
															 
																
																OPEN CUR_LIMITE_INT;
																FETCH CUR_LIMITE_INT INTO V_LIMITE;
																CLOSE CUR_LIMITE_INT;
																
																OPEN CUR_TIPO_PLAN;
																FETCH CUR_TIPO_PLAN INTO V_TIPO_PLAN, V_PLAN_MASTER;
																CLOSE CUR_TIPO_PLAN;
																
																OPEN CUR_POR_COA;
																FETCH CUR_POR_COA INTO V_POR_COA;
																CLOSE CUR_POR_COA;
																
																IF V_POR_COA IS NULL THEN
                                                                OPEN CUR_POR_COA_S;
																FETCH CUR_POR_COA_S INTO V_POR_COA;
																CLOSE CUR_POR_COA_S;
																END IF;			 		
																					
																					
															  IF V_TIPO_PLAN IN (15, 16) THEN					 				   
																	
																  IF NVL(V_POR_COA, 0) > 0 THEN
																    V_POR_PAGAR := (100 - V_POR_COA) / 100;  
																  ELSE
																    V_POR_PAGAR := 1;                        
																  END IF;
									 				    			
									 				    		IF UPPER(TRIM(NVL(:BUSCA_SERVICIO.GRUPO_COBERTURA,' '))) = 'MDA' AND V_POR_COA IS NOT NULL THEN
									 				    			:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR := ROUND(NVL(:SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO, 0) * V_POR_PAGAR, 2);
									 				    		
									 				    		ELSIF V_PLAN_MASTER = 19 THEN
									 				    			
									 				    			DECLARE
																      v_tasa NUMBER;
																    BEGIN
																      BEGIN
																        v_tasa := DBAPER.Tasa_Moneda('002', 'C');															   
																      END;
									 				    	 
									 				    	    V_MONTO_PAGAR_INT := V_TASA * NVL(V_LIMITE,0); 
																		 				    	 
																		 				    	 
										 				    	 IF NVL(:SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO, 0) <= V_MONTO_PAGAR_INT THEN
																    IF :SOLICITUD_SERVICIO_DETALLE.FRECUENCIA > 1 THEN
																        :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR :=
																            ROUND(NVL(:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL, 0) * (NVL(:PLANES.REEMBOLSO, 0) / 100), 2);
																
																        IF :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR > V_MONTO_PAGAR_INT THEN
																            :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR := V_MONTO_PAGAR_INT;  -- cap al limite
																        END IF;
																    ELSE  -- FRECUENCIA = 1
																        :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR :=
																            ROUND(NVL(:SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO, 0) * (NVL(:PLANES.REEMBOLSO, 0) / 100), 2);
																    END IF;
																ELSE  -- MONTO_RECLAMO > V_MONTO_PAGAR_INT
																    :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR := V_MONTO_PAGAR_INT;
																END IF;
									 				    		END;
									 				    		
										 				    	 ELSE 
										 				    	 	
										 				    	 DECLARE
																      v_tasa NUMBER;
																    BEGIN
																      BEGIN
																        v_tasa := DBAPER.Tasa_Moneda('002', 'C');															   
																    END;
										 				    	 
										 				    	 V_MONTO_PAGAR_INT := V_TASA * NVL(V_LIMITE,0);
										 				    	 
										 				    	 
										 				    	 IF NVL(:SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO,0) <= V_MONTO_PAGAR_INT THEN	
										 				    	 	   :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:= :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO;
										 				    	 ELSE 
										 				    	 :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:= V_MONTO_PAGAR_INT;	
										 				    	 END IF;
										 				    	 
										 				    	 IF :SOLICITUD_SERVICIO_DETALLE.FRECUENCIA > 1 THEN
										 				    	 		 :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:= :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO * :SOLICITUD_SERVICIO_DETALLE.FRECUENCIA;
										 				    	 	IF  :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR > V_MONTO_PAGAR_INT THEN 
										 				    	 			:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR := V_MONTO_PAGAR_INT;
										 				    	 	END IF;
										 				    	 END IF;	
										 				     END;
										 				   	END IF;
										 				    	 
										 				    	 :SOLICITUD_SERVICIO_DETALLE.MONTO_NO_REEMB := :SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL - :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR; 
										               :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA := :SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL - :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR; 
										               	:SOLICITUD_SERVICIO_DETALLE.MONTO_COASEGURO :=0;
										 				    	ELSE 
										 				      if (nvl(V_LIMITE_SERVICIO,0)- nvl(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR,0)) < 0 then 
										 				    	 v_monto_restante:= nvl(V_LIMITE_SERVICIO,0)-(nvl(:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_PAGAR,0) - nvl(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,0));
										 				    	 :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=v_monto_restante;
										               :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL - v_monto_restante;
										               	:SOLICITUD_SERVICIO_DETALLE.MONTO_COASEGURO :=0;
										              END IF;
																		                 
																		         --        PKG_GENERAL.P_INSERTA_ERROR('reemb_pago', sqlcode, sqlerrm, 'v_monto_restante:'||v_monto_restante);
										 				    	end if;								 				    
																		 				    	
																		 				    
																		 				    if nvl(:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,0) <= 0 then 
																		 			     
																		                V_ID_RECHAZO:=c_id_rechazo;
																		                V_NOMBRE_RECHAZO:=c_mensaje_1||LOWER(v_descripcion_servicio)||'.'||' Monto Limite por servicio:'||to_char(V_LIMITE_SERVICIO,'999,999,999');									                
																		                :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=0;
																		                :SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL;  --monto_reclamado
																		                :SOLICITUD_SERVICIO_DETALLE.MONTO_COASEGURO :=0;
																		 				    	
																		 				    end if;	 			
														  end if;
												 END IF;
									 
						
						end if;
      end if;
  end if;
--fin
--------------------------------------------
  -- Citser/ Proyecto. Tarifas URA
  -- Fecha. 26.11.2024
  begin
  	  if (:CG$CTRL.codigo_compania = :CG$CTRL.CIA_ASEGURADORA and :solicitud_servicio.ramo = :CG$CTRL.ramo_salud_int) then
  	     P_VALIDA_MONTO_PAGAR;
  	  end if;
  	  --
  end;
  
-----------------------------------------------------
			--OF22122023 MANEJO DE ACUULADO DE MONTO A PAGAR POR TIPO COBERTURA
				BEGIN
			     P_MON_CONS_TEMP_IN_UP(:SOLICITUD_SERVICIO_DETALLE.COBERTURA_TIPO,:SOLICITUD_SERVICIO_DETALLE.COBERTURA,:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR); 
  			END;
-----------------------------------------------------

				
				
				IF V_ID_RECHAZO IS NULL THEN 
				  :SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID := PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('EST_APR_COB_SOL_REMB',:GLOBAL.COD_COMPANIA);
				  :SOLICITUD_SERVICIO_DETALLE.RECHAZO_AUTOMATICO := 'N';
					:SOLICITUD_SERVICIO_DETALLE.HUBO_EXCEPCION := 'N';
				  --P_MANEJA_HABILITA_COB_ESTATUS('S');
				ELSE
					:SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID := PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('EST_REC_COB_SOL_REMB',:GLOBAL.COD_COMPANIA);
					:SOLICITUD_SERVICIO_DETALLE.RECHAZO_AUTOMATICO := 'S';
					:SOLICITUD_SERVICIO_DETALLE.HUBO_EXCEPCION := 'N';
					--P_MANEJA_HABILITA_COB_ESTATUS('N');				
			  END IF;
				:SOLICITUD_SERVICIO_DETALLE.MONTO_DEDUCIBLE:=V_MONTO_DEDUCIBLE;
				:SOLICITUD_SERVICIO_DETALLE.INTRODUJO_MONTO_PAGAR:=0;
				:SOLICITUD_SERVICIO_DETALLE.MONTO_CONTRATADO:=V_MONTO_CONTRATADO;
				:SOLICITUD_SERVICIO_DETALLE.MOTIVO_RECHAZO_ID:=V_ID_RECHAZO;
				:SOLICITUD_SERVICIO_DETALLE.ESPECIALIDAD_ID := :BUSCA_SERVICIO.ESPECIALIDAD_MEDICO;
				
				
		--		commit_form;
		--forebra2023620 temporal
				IF V_ID_RECHAZO is null then 
					if V_montoCubierto is null then 
						:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=0;
						:SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL;
					end if;
				end if;
		-----------------------	
		
		
		    IF V_ID_RECHAZO IS NOT NULL THEN 
					 :CG$CTRL.CODIGO_RECHAZO := V_CODIGO_RECHAZO;
					 :CG$CTRL.ID_RECHAZO     := V_ID_RECHAZO;
					 P_BUSCA_MOTIVO_RECHAZO(V_ID_RECHAZO); 
		    END IF;
		    
				IF V_ID_RECHAZO IS NOT NULL THEN 
					:CG$CTRL.DESCRIPCION_MENSAJES:=V_NOMBRE_RECHAZO;
					set_window_property('W_BUSCA_SERVICIO', VISIBLE, PROPERTY_OFF);
					GO_ITEM('CG$CTRL.BTN_CERRAR');
				ELSE 
					P_VALIDA_COB_VACUNA; --LCALCANO 2-AGO-23 SI LA COBERTURA ES VACUNA INFLUENZA, VALIDA EDAD AFILIADO Y SEGUN CONDICION, PUEDE RECHAZAR LA LINEA
					GO_ITEM('SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR');
					
				END IF;
				
			END IF;	

END;
