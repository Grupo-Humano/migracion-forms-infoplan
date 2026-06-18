-- PROGRAM UNIT: P_VALIDA_ASEGURADO_BAN
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_VALIDA_ASEGURADO_BAN IS
	
	V_BANEADO	NUMBER;
	V_CONF_CORREO_ERROR VARCHAR2(1000);
	V_SENDER            VARCHAR2(1000):= PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('NOT_AUT_COB_INNOVA',30);
	V_SUBJECT 					VARCHAR2(1000):= PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('SUBJ_AUT_COB_INNOVA',30);
  V_BODY_PRE					VARCHAR2(1000):= PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('BODY_AUT_COB_INNOVA',30);
	V_BODY					    VARCHAR2(1000);  
  V_NOMBRE_COMPLETO   VARCHAR2(2000);
  V_BENEFICIARIO_ID   VARCHAR2(200);
  V_ESTADO_BLACKLIST  NUMBER;
	
	CURSOR CUR_BLACKLIST IS
		SELECT BANEADO, NOMBRE_COMPLETO, ESTADO, CODIGO_ASEGURADO
		FROM BLACKLIST_ASEGURADOS
		WHERE CODIGO_ASEGURADO = :CG$CTRL.NO_AFI;
	
	CURSOR CUR_OBTENER_CORREOS IS
  	SELECT C.*
   		FROM Correo_Usuario C
   	WHERE C.NOTIFICAR = 1;
   	
BEGIN
  OPEN CUR_BLACKLIST;
  FETCH CUR_BLACKLIST INTO V_BANEADO, V_NOMBRE_COMPLETO, V_ESTADO_BLACKLIST, V_BENEFICIARIO_ID;
  CLOSE CUR_BLACKLIST;
  
  IF NVL(V_BANEADO,0) = 1 THEN
  	
  	-- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (07/02/2024). START INTEGRACION DE ENVIO DE EMAIL
  	V_CONF_CORREO_ERROR := null;  
  	            
     V_BODY := V_BODY_PRE||' : '||'El usuario '|| user|| ' intenta registrarle un reembolso al afiliado bloqueado '||
     					 V_NOMBRE_COMPLETO||', '||'('||V_BENEFICIARIO_ID||')'||', '||'en la fecha '||SYSDATE;
     					 
     FOR I IN CUR_OBTENER_CORREOS LOOP
       
       V_CONF_CORREO_ERROR := I.EMAIL;  
       
      Email(V_SENDER,
            V_CONF_CORREO_ERROR,
            V_SUBJECT,
            V_BODY);
		END LOOP;              
     BEGIN
    --SE INSERTA EN EL HISTORICO TAMBIEN 
        Insert into REEMBOLSO.HISTORICO_FRAUDES( FECHA, DESCRIPCION_ACTIVIDAD, FEC_TRA, USUARIO, ESTADO)
        VALUES(TRUNC(SYSDATE),'El usuario '|| user|| ' intenta registrarle un reembolso al afiliado bloqueado '|| 
        V_NOMBRE_COMPLETO||', '||'('||V_BENEFICIARIO_ID||')'||', '||'en la fecha '||SYSDATE,TRUNC(SYSDATE),USER,V_ESTADO_BLACKLIST);
    		
     EXCEPTION WHEN OTHERS THEN
      DBAPER.PKG_GENERAL.P_INSERTA_ERROR
                             ('REEMB_PAGO.FMB/PU/P_VALIDA_ASEGURADO_BAN',
                               SQLCODE,
                               SUBSTR(SQLERRM, 1, 500),
                               'ERROR CREANDO HISTORICO_FRAUDES-EN-P_VALIDA_ASEGURADO_BAN: '||SQLERRM);
     END;
     
  	 :SYSTEM.MESSAGE_LEVEL := '25';
  	 COMMIT;	
   	 :SYSTEM.MESSAGE_LEVEL := '0';
  	 -- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (03/02/2024). END INTEGRACION DE ENVIO DE EMAIL
  	  	
  	MSG_ALERT('Las reclamaciones de reembolsos de este afiliado no pueden ser procesadas vía expreso, '||
  						'por favor depositar a backoffice dirigido al supervisor de reembolsos','E',TRUE);			  						
  END IF;
  
  
END;
