-- PROGRAM UNIT: P_INSERTA_NUMERO_CUENTA
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_INSERTA_NUMERO_CUENTA IS
	V_RESULT	NUMBER;
	V_SQL_ERROR	VARCHAR2(2000);
	V_TIPO_CUENTA	VARCHAR2(1);
BEGIN
  
  
  SELECT DECODE(:RADICACION.TIPO_CUENTA,'AHOR','A','C') INTO V_TIPO_CUENTA
   FROM DUAL;
   
	INNOVACORE.INSERTA_NUMERO_CUENTA( P_TIPCTA     => V_TIPO_CUENTA,
                                   P_NUMCTA      => :RADICACION.NUMERO_CUENTA,
                                   P_BANCO       => :RADICACION.BANCO,
                                   P_TIPPRO      => 'ASEGURADO',-- :RADICACION.TIPO_PROPIETARIO,
                                   P_FECTRA      => SYSDATE,
                                   P_PRINCIPAL   => 'N',
                                   P_PROPETARIO  => :CG$CTRL.ASEGURADO,
                                   P_COMENTARIO  => 'INSERTADO CON SOLICITUD DE RADICACION '||:RADICACION.NUMERO_SOLICITUD,
                                   P_ESTATUS		 => 363,
                                   P_CODIGO			 => 0,
                                   --
                                   P_PROPIETARIO_NOMBRE   => :RADICACION.NOMBRE_PROPIETARIO,
                                   P_PROPIETARIO_TIPO_ID  => :RADICACION.TIPO_DOCUMENTO,
                                   P_PROPIETARIO_NUM_ID   => :RADICACION.NUMERO_DOCUMENTO,
                                   P_TIPO_CUENTA          => NULL,
                                   P_PROPIETARIO_NACI     => :RADICACION.NACIONALIDAD,
                                   P_PROPIETARIO_TIPO     => :RADICACION.TIPO_PROPIETARIO,
                                   P_PROPIETARIO_SEXO     => :RADICACION.SEXO,
                                   P_EMAIL_NOTIFICA_PAGO  => :RADICACION.CORREO_PROPIETARIO,
                                   P_PROPIETARIO_TELE     => NULL,
                                   P_CANAL                => NULL,
                                   P_USU_CANAL            => USER,
                                   P_USU_MOD_CANAL        => USER,
                                   --
                                   P_RESULT              => V_RESULT,
                                   P_SQL_ERROR           => V_SQL_ERROR
                                   ) ;
	
	IF V_SQL_ERROR IS NOT NULL THEN
		MSG_ALERT(V_SQL_ERROR,'E',TRUE);
		RAISE FORM_TRIGGER_FAILURE;	
	END IF;
	
	:CG$CTRL.IND_NUEVA_CUENTA := 'N';
	
	SET_ITEM_PROPERTY('RADICACION.NUMERO_CUENTA',ENABLED,PROPERTY_FALSE);
	SET_ITEM_PROPERTY('RADICACION.TIPO_CUENTA',ENABLED,PROPERTY_FALSE);
	SET_ITEM_PROPERTY('RADICACION.NOMBRE_PROPIETARIO',ENABLED,PROPERTY_FALSE);
	SET_ITEM_PROPERTY('RADICACION.TIPO_PROPIETARIO',ENABLED,PROPERTY_FALSE);
	SET_ITEM_PROPERTY('RADICACION.NUMERO_DOCUMENTO',ENABLED,PROPERTY_FALSE);
	SET_ITEM_PROPERTY('RADICACION.TIPO_DOCUMENTO',ENABLED,PROPERTY_FALSE);
	SET_ITEM_PROPERTY('RADICACION.BANCO',ENABLED,PROPERTY_FALSE);
	SET_ITEM_PROPERTY('RADICACION.BTN_LOV_BANCO',ENABLED,PROPERTY_FALSE);
	SET_ITEM_PROPERTY('RADICACION.NOMBRE_BANCO',ENABLED,PROPERTY_FALSE);
	SET_ITEM_PROPERTY('RADICACION.SEXO',ENABLED,PROPERTY_FALSE);
	SET_ITEM_PROPERTY('RADICACION.NACIONALIDAD',ENABLED,PROPERTY_FALSE);
	SET_ITEM_PROPERTY('RADICACION.CORREO_PROPIETARIO',ENABLED,PROPERTY_FALSE);

END;
