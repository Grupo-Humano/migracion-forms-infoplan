-- PROGRAM UNIT: P_VALIDA_GRUPO_COB
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_VALIDA_GRUPO_COB (P_VALIDO OUT VARCHAR2, P_EXCEDE_LIM OUT VARCHAR2) IS
   VN_ERROR             NUMBER;
   VC_ERROR_DESC        VARCHAR2(2000);
   V_NOM_OBJETO         VARCHAR2(10)  := 'REEMB_PAGO';   
	 V_TOT_ACUM    NUMBER:=0;
	 V_TOT_DISP    NUMBER:=0;
	 V_MON_MAX     NUMBER:=0;
	 V_MON_RECLAMO NUMBER:=0;
	 V_MENSAJE     VARCHAR2(500);
	 V_DIF         NUMBER;
	 V_COD_MONEDA  VARCHAR2(3);
	 
  -- variables MENSAJE
  v_MENSAJE_TEXTO  varchar2(1000);
	v_TIPO           varchar2(1000);
	v_VALOR_LOGICO   varchar2(1000);
	v_TEXTO1         varchar2(1000);
	v_TEXTO2         varchar2(1000);
	v_TEXTO3         varchar2(1000);
	v_TEXTO4         varchar2(1000);
	v_VALOR_LOGICO2  boolean;	 
	 
	 CURSOR CUR_MONEDA IS
		SELECT CDMONEDA from POLIZA02_V ap
		    WHERE AP.COMPANIA = :PLANES.COMPANIA_P
		    AND AP.RAMO       = :PLANES.RAMO
		    AND AP.SECUENCIAL = :PLANES.SECUENCIAL;
BEGIN
	P_VALIDO     := :CG$CTRL.VALOR_SI;
	P_EXCEDE_LIM := :CG$CTRL.VALOR_NO;
	--DCH/VACEVEDO 15/03/2025
	/*
	    MESSAGE('Parametros: '||' '||:PLANES.COMPANIA_P
	                          ||' '||:PLANES.RAMO
														||'-'||:PLANES.SECUENCIAL
														||'-'||:PLANES.PLAN
														||'-'||:PLANES.ASEGURADO
														||'-'||'ASEGURADO'
														||'-'||to_char(:SOLICITUD_SERVICIO.FECHA_SERVICIO,'dd-mm-yyyy')
														||'-'||:SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO  --COLOCAR MONTO TOTAL
														||'-'||:BUSCA_SERVICIO.GRUPO_COBERTURA);
	    MESSAGE('Parametros: '||' '||:PLANES.COMPANIA_P
	    											||' '||:PLANES.RAMO
														||'-'||:PLANES.SECUENCIAL
														||'-'||:PLANES.PLAN
														||'-'||:PLANES.ASEGURADO
														||'-'||'ASEGURADO'
														||'-'||to_char(:SOLICITUD_SERVICIO.FECHA_SERVICIO,'dd-mm-yyyy')
														||'-'||:SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO  --COLOCAR MONTO TOTAL
														||'-'||:BUSCA_SERVICIO.GRUPO_COBERTURA);														
														
    */
      V_MON_RECLAMO := :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO;  
    
	    PKG_VALIDAR_MON_MAX_GRUPO_SI.P_VALIDAR_MON_MAX_GRUPO(:PLANES.COMPANIA_P
                                                          ,:PLANES.RAMO
                                                          ,:PLANES.SECUENCIAL
                                                          ,:PLANES.PLAN
                                                          ,:PLANES.ASEGURADO
                                                          ,:CG$CTRL.DSP_ASEGURADO
                                                          ,:SOLICITUD_SERVICIO.FECHA_SERVICIO 
                                                          ,V_MON_RECLAMO  --:SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO  --:SOLICITUD_SERVICIO_DETALLE.TOTAL_MON_RECLAMO -- 
                                                          ,:BUSCA_SERVICIO.GRUPO_COBERTURA
                                                       		,V_TOT_ACUM
	                                                        ,V_TOT_DISP
	                                                        ,V_MON_MAX
                                                       );
                                                       
     -- MESSAGE('Valores: '||V_TOT_ACUM||'-'||V_TOT_DISP||'-'||V_MON_MAX);
     -- MESSAGE('Valores: '||V_TOT_ACUM||'-'||V_TOT_DISP||'-'||V_MON_MAX);
      
     -- MESSAGE('Moneda: '||:BUSCA_SERVICIO.MONEDA_ADD);
     -- MESSAGE('Moneda: '||:BUSCA_SERVICIO.MONEDA_ADD);
            
      --Si la moneda es dolares se convierte ya que el monto disponible y monto maximo se encuentra en dolares
      OPEN CUR_MONEDA;
      FETCH CUR_MONEDA INTO V_COD_MONEDA;
      CLOSE CUR_MONEDA;

      --Todos los reembolsos se realizan en pesos. Solo se aplica la tasa si la poliza es en $
      IF V_COD_MONEDA = :CG$CTRL.MONEDA_DOL THEN 
	        V_TOT_DISP := V_TOT_DISP * :CG$CTRL.TASA_CAMBIO;
	        V_MON_MAX  := V_MON_MAX * :CG$CTRL.TASA_CAMBIO;  	                                             
                                                       
		      --Verificar si el monto disponible supera el monto reclamado                                             
		      IF (NVL(v_TOT_ACUM,:CG$CTRL.VALOR_CERO) > NVL(V_TOT_DISP,:CG$CTRL.VALOR_CERO)) THEN 
		      	
		      	  --Si el usuario esta autorizado a Exceder el limite permitir continuar			          		      	    
		      	  IF (F_VERIFICA_USUARIO(:CG$CTRL.CG$US,:GLOBAL.COD_COMPANIA,'EXCEDER_LIMITE')) THEN
 		      	  	  P_VALIDO := :CG$CTRL.valor_si;
 		      	  	  P_EXCEDE_LIM := :CG$CTRL.VALOR_SI;
		      	  ELSE   
				         --:SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO := v_TOT_DISP;
				         P_VALIDO := :CG$CTRL.valor_no;		      	  	
		      	  END IF;
		      	  
		      	      --544 Asegurado Excede el Monto de Beneficio por Grupo disponible.
		      	  	  PKG_PARAMETRO_GENERAL_PROCESO.P_CONFIG_MENSAJE_ALERT_FORMA(:GLOBAL.COD_COMPANIA,-- P_COMPANIA  IN     NUMBER,	  	
																											            544,       -- P_CODIGO    IN     NUMBER,
																													        v_MENSAJE_TEXTO,    -- IN OUT VARCHAR2,
																													        v_TIPO,             -- IN OUT VARCHAR2,
																													        v_VALOR_LOGICO,     -- IN OUT VARCHAR2,
																													        v_TEXTO1,           -- IN OUT VARCHAR2,
																													        v_TEXTO2,           -- IN OUT VARCHAR2,
																													        v_TEXTO3,           -- IN OUT VARCHAR2,
																													        v_TEXTO4);          -- IN OUT VARCHAR2)
																													        
				      	  V_MENSAJE := v_MENSAJE_TEXTO;
				      	  v_VALOR_LOGICO2 := DBAPER.F_CONVIERTE_CHAR_BOOLEAN (V_VALOR_LOGICO);
				          MSG_ALERT(V_MENSAJE,v_TIPO,v_VALOR_LOGICO2); 		      	  
		      ELSE
		      	 -- MESSAGE('VALOR: '||NVL(v_TOT_ACUM,:CG$CTRL.VALOR_CERO)||'--'||(NVL(V_TOT_DISP,:CG$CTRL.VALOR_CERO)*(1+(:CG$CTRL.PO_LIMITE/100))));
		      	 -- MESSAGE('VALOR: '||NVL(v_TOT_ACUM,:CG$CTRL.VALOR_CERO)||'--'||(NVL(V_TOT_DISP,:CG$CTRL.VALOR_CERO)*(1+(:CG$CTRL.PO_LIMITE/100))));
		      	
		      	  --Verificar si el asegurado esta cerca de sobrepasar la cobertura maxima
		      	  IF ((NVL(V_TOT_DISP,:CG$CTRL.VALOR_CERO)-(NVL(v_TOT_ACUM,:CG$CTRL.VALOR_CERO)*(1+(:CG$CTRL.PO_LIMITE/100))))<=0) THEN
		      	  	
		      	      --545 Asegurado esta cerca de consumir el Monto de Beneficio por Grupo.
		      	  	  PKG_PARAMETRO_GENERAL_PROCESO.P_CONFIG_MENSAJE_ALERT_FORMA(:GLOBAL.COD_COMPANIA,-- P_COMPANIA  IN     NUMBER,	  	
																											            545,       -- P_CODIGO    IN     NUMBER,
																													        v_MENSAJE_TEXTO,    -- IN OUT VARCHAR2,
																													        v_TIPO,             -- IN OUT VARCHAR2,
																													        v_VALOR_LOGICO,     -- IN OUT VARCHAR2,
																													        v_TEXTO1,           -- IN OUT VARCHAR2,
																													        v_TEXTO2,           -- IN OUT VARCHAR2,
																													        v_TEXTO3,           -- IN OUT VARCHAR2,
																													        v_TEXTO4);          -- IN OUT VARCHAR2)
																													        
				      	  V_MENSAJE := v_MENSAJE_TEXTO;
				      	  v_VALOR_LOGICO2 := DBAPER.F_CONVIERTE_CHAR_BOOLEAN (V_VALOR_LOGICO);
				          MSG_ALERT(V_MENSAJE,v_TIPO,v_VALOR_LOGICO2); 
		      	  END IF;
		      END IF;
      END IF; 
     /*                                                
      MESSAGE('Valores: '||' '||to_char(V_TOT_ACUM)||'-'||to_char(V_TOT_DISP)||'-'||to_char(V_MON_MAX));
      MESSAGE('Valores: '||' '||to_char(V_TOT_ACUM)||'-'||to_char(V_TOT_DISP)||'-'||to_char(V_MON_MAX));
      */
EXCEPTION 
	WHEN OTHERS THEN 
              VN_ERROR      := SQLCODE;
              VC_ERROR_DESC := SUBSTR(SQLERRM,1,1000);
              PKG_GENERAL.P_INSERTA_ERROR (V_NOM_OBJETO||'.P_VALIDA_GRUPO_COB', VN_ERROR, VC_ERROR_DESC,
                                           'Error en procedimiento valida grupos');
END;
