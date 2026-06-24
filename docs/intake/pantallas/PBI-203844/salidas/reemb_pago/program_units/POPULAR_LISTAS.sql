-- PROGRAM UNIT: POPULAR_LISTAS
-- Tipo: Procedure
-- ====================================================================

PROCEDURE Popular_Listas IS
  nDummy NUMBER;  
  rg_id  RecordGroup; 
  
Begin
	--
  rg_id := create_group_from_query('RGRP_ESTATUS',
  	'SELECT DESCRIPCION, TO_CHAR(CODIGO) CODIGO FROM ESTATUS WHERE TIPO = ''SOLICITUD_PAGO_RADICACION'' ORDER BY CODIGO');
  nDummy := populate_group(rg_id);
  populate_list('RADICACION.ESTATUS', rg_id);
  delete_group(rg_id);

  rg_id := create_group_from_query('RGRP_VIA_ENTRADA',
  	'SELECT DESCRIPCION, CLAVE FROM PARAMETRO_GENERAL_OPCION '||
  	'WHERE ID_PARAMETRO_GENERAL = (SELECT ID FROM PARAMETRO_GENERAL '||
  																'WHERE CLAVE = ''VIA_ENTRADA'') ORDER BY CLAVE');
  nDummy := populate_group(rg_id);
  populate_list('RADICACION.VIA_ENTRADA', rg_id);
  delete_group(rg_id);

  rg_id := create_group_from_query('RGRP_MEDIO_PAGO',
  	'SELECT DESCRIPCION, CLAVE FROM PARAMETRO_GENERAL_OPCION '||
  	'WHERE ID_PARAMETRO_GENERAL = (SELECT ID FROM PARAMETRO_GENERAL '||
  																'WHERE CLAVE = ''MEDIO_PAGO'') ORDER BY CLAVE');
  nDummy := populate_group(rg_id);
  populate_list('RADICACION.MEDIO_PAGO', rg_id);
  delete_group(rg_id);

  rg_id := create_group_from_query('RGRP_ENTREGAR_CHEQUE',
  	'SELECT DESCRIPCION, CLAVE FROM PARAMETRO_GENERAL_OPCION '||
  	'WHERE ID_PARAMETRO_GENERAL = (SELECT ID FROM PARAMETRO_GENERAL '||
  																'WHERE CLAVE = ''ENTREGA_REEMBOLSO'') ORDER BY CLAVE');
  nDummy := populate_group(rg_id);
  populate_list('RADICACION.ENTREGAR_CHEQUE', rg_id);
  delete_group(rg_id);

  rg_id := create_group_from_query('RGRP_TIPO_CUENTA',
  	'SELECT DESCRIPCION, CLAVE FROM PARAMETRO_GENERAL_OPCION '||
  	'WHERE ID_PARAMETRO_GENERAL = (SELECT ID FROM PARAMETRO_GENERAL '||
  																'WHERE CLAVE = ''TIPO_CUENTA'') ORDER BY CLAVE');
  nDummy := populate_group(rg_id);
  populate_list('RADICACION.TIPO_CUENTA', rg_id);
  delete_group(rg_id);

  rg_id := create_group_from_query('RGRP_TIPO_PROPIETARIO',
    'SELECT RV_ABBREVIATION DESCRIPCION, RV_LOW_VALUE CODIGO '||
    'FROM   CG_REF_CODES '||
    'WHERE RV_DOMAIN = ''RADICACION.TIPO_PROPIETARIO'' ' ||
    'AND COMPANIA = ' || :GLOBAL.COD_COMPANIA||' '||
    'ORDER BY RV_LOW_VALUE');
  nDummy := populate_group(rg_id);
  populate_list('RADICACION.TIPO_PROPIETARIO', rg_id);
  delete_group(rg_id);

  rg_id := create_group_from_query('RGRP_TIPO_DOCUMENTO',
    'SELECT RV_ABBREVIATION DESCRIPCION, RV_LOW_VALUE CODIGO '||
    'FROM   CG_REF_CODES '||
    'WHERE RV_DOMAIN = ''RADICACION.TIPO_DOCUMENTO'' ' ||
    'AND COMPANIA = ' || :GLOBAL.COD_COMPANIA||' '||
    'ORDER BY RV_LOW_VALUE');
  nDummy := populate_group(rg_id);
  populate_list('RADICACION.TIPO_DOCUMENTO', rg_id);
  delete_group(rg_id);

  rg_id := create_group_from_query('RGRP_SEXO',
    'SELECT RV_MEANING DESCRIPCION, RV_LOW_VALUE CODIGO '||
    'FROM   CG_REF_CODES '||
    'WHERE RV_DOMAIN = ''SEXO'' ' ||
    'AND COMPANIA = ' || :GLOBAL.COD_COMPANIA||' '||
    'ORDER BY RV_LOW_VALUE');
  nDummy := populate_group(rg_id);
  populate_list('RADICACION.SEXO', rg_id);
  delete_group(rg_id);

  rg_id := create_group_from_query('RGRP_NACIONALIDAD',
  	'select descripcion,to_char(codigo) from nacionalidad ORDER BY CODIGO');
  nDummy := populate_group(rg_id);
  populate_list('RADICACION.NACIONALIDAD', rg_id);
  delete_group(rg_id);
  
  rg_id := create_group_from_query('RGRP_MOTIVO_APROBACION',
  	'SELECT MOTIVO, TO_CHAR(ID) ID FROM MOTIVO_APROBACION UNION ALL SELECT '''' MOTIVO,''0'' ID FROM DUAL ORDER BY ID');
  nDummy := populate_group(rg_id);
  populate_list('SOLICITUD_SERV_MOT.MOTIVO', rg_id);
  delete_group(rg_id);   

  rg_id := create_group_from_query('RGRP_TIPO_SERVICIO',
  	'SELECT DESCRIPCION, CLAVE FROM ( SELECT DESCRIPCION, CLAVE FROM PARAMETRO_GENERAL_OPCION WHERE ID_PARAMETRO_GENERAL = '||
  	'(SELECT ID FROM PARAMETRO_GENERAL WHERE CLAVE = ''SERVICIOS_REEMBOLSO'')UNION ALL SELECT '''' DESCRIPCION, ''0'' CLAVE FROM DUAL) ORDER BY TO_NUMBER(CLAVE)');
  nDummy := populate_group(rg_id);
  populate_list('SOLICITUD_SERVICIO.TIPO_SERVICIO', rg_id);
  delete_group(rg_id);
  
  rg_id := create_group_from_query('RGRP_TIPO_PRESTADOR',
    'SELECT RV_ABBREVIATION DESCRIPCION, RV_LOW_VALUE CODIGO '||
    'FROM   CG_REF_CODES '||
    'WHERE RV_DOMAIN = ''REEMB_PAGO.TIPO_PRESTADOR'' ' ||
    'AND COMPANIA = ' || :GLOBAL.COD_COMPANIA||' '||
    'ORDER BY RV_LOW_VALUE');
  nDummy := populate_group(rg_id);
  populate_list('BUSCA_SERVICIO.TIPO_PRESTADOR_ADD', rg_id);
  delete_group(rg_id);

  rg_id := create_group_from_query('RGRP_MONEDA',
    'SELECT RV_ABBREVIATION DESCRIPCION, RV_LOW_VALUE CODIGO '||
    'FROM   CG_REF_CODES '||
    'WHERE RV_DOMAIN = ''REEMB_PAGO.MONEDA'' ' ||
    'AND COMPANIA = ' || :GLOBAL.COD_COMPANIA||' '||
    'ORDER BY RV_LOW_VALUE');
  nDummy := populate_group(rg_id);
  populate_list('BUSCA_SERVICIO.MONEDA_ADD', rg_id);
  delete_group(rg_id);
  
  rg_id := create_group_from_query('RGRP_ESTATUS',
  	'SELECT DESCRIPCION, TO_CHAR(CODIGO) CODIGO FROM ESTATUS WHERE TIPO = ''COB_SOLICITADA.CS_ESTATUS_ID'' ORDER BY CODIGO');
  nDummy := populate_group(rg_id);
  populate_list('SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID', rg_id);
  delete_group(rg_id);

  rg_id := create_group_from_query('RGRP_LOCALIDAD',
    'SELECT RV_ABBREVIATION DESCRIPCION, RV_LOW_VALUE CODIGO '||
    'FROM   CG_REF_CODES '||
    'WHERE RV_DOMAIN = ''REEMB_PAGO.LOCALIDAD_MEDICO'' ' ||
    'AND COMPANIA = ' || :GLOBAL.COD_COMPANIA||' '||
    'ORDER BY RV_LOW_VALUE');
  nDummy := populate_group(rg_id);
  populate_list('CREA_MEDICO.LOCALIDAD', rg_id);
  delete_group(rg_id);
  
  rg_id := create_group_from_query('RGRP_ESPECIALIDAD',
  	'SELECT NOMBRE, TO_CHAR(ID) FROM ESPECIALIDAD ORDER BY 1');
  nDummy := populate_group(rg_id);
  populate_list('CREA_MEDICO.ESPECIALIDAD', rg_id);
  delete_group(rg_id);
  
  --OF17012024
    rg_id := create_group_from_query('RGRP_ESPECIALIDAD',
  	'SELECT NOMBRE, TO_CHAR(ID) FROM ESPECIALIDAD ORDER BY 1');
  nDummy := populate_group(rg_id);
  populate_list('CREA_MEDICO.ESPECIALIDAD_2', rg_id);
  delete_group(rg_id);
  
     rg_id := create_group_from_query('RGRP_ESPECIALIDAD',
  	'SELECT NOMBRE, TO_CHAR(ID) FROM ESPECIALIDAD ORDER BY 1');
  nDummy := populate_group(rg_id);
  populate_list('CREA_MEDICO.ESPECIALIDAD_3', rg_id);
  delete_group(rg_id);
  
      rg_id := create_group_from_query('RGRP_ESPECIALIDAD',
  	'SELECT NOMBRE, TO_CHAR(ID) FROM ESPECIALIDAD ORDER BY 1');
  nDummy := populate_group(rg_id);
  populate_list('CREA_MEDICO.ESPECIALIDAD_4', rg_id);
  delete_group(rg_id);
  
  
  
  --OF17012024
  
  rg_id := create_group_from_query('RGRP_TIPO_CENTRO_MEDICO',
  	'SELECT NOMBRE, TO_CHAR(ID) FROM INSTITUCION I WHERE EXISTS (SELECT 1 FROM PROVEEDOR P WHERE P.INSTITUCION_ID = I.ID) ORDER BY 1');
  nDummy := populate_group(rg_id);
  populate_list('CREA_MEDICO.CENTRO', rg_id);
  delete_group(rg_id);
  
  /*
  rg_id := create_group_from_query('RGRP_TIPO_CENTRO_MEDICO',
  	'SELECT NOMBRE, TO_CHAR(ID) FROM TIPO_CENTRO_MEDICO ORDER BY 1');
  nDummy := populate_group(rg_id);
  populate_list('CREA_MEDICO.CENTRO', rg_id);
  delete_group(rg_id);
  */
  
  rg_id := create_group_from_query('RGRP_TIPO_PRESTADOR',
    'SELECT RV_ABBREVIATION DESCRIPCION, RV_LOW_VALUE CODIGO '||
    'FROM   CG_REF_CODES '||
    'WHERE RV_DOMAIN = ''REEMB_PAGO.TIPO_PRESTADOR'' ' ||
    'AND COMPANIA = ' || :GLOBAL.COD_COMPANIA||' '||
    'ORDER BY RV_LOW_VALUE');
  nDummy := populate_group(rg_id);
  populate_list('CREA_PSS.TIPO_PRESTADOR', rg_id);
  delete_group(rg_id);  
  
  rg_id := create_group_from_query('RGRP_LOCALIDAD',
    'SELECT RV_ABBREVIATION DESCRIPCION, RV_LOW_VALUE CODIGO '||
    'FROM   CG_REF_CODES '||
    'WHERE RV_DOMAIN = ''REEMB_PAGO.LOCALIDAD_MEDICO'' ' ||
    'AND COMPANIA = ' || :GLOBAL.COD_COMPANIA||' '||
    'ORDER BY RV_LOW_VALUE');
  nDummy := populate_group(rg_id);
  populate_list('CREA_PSS.LOCALIDAD', rg_id);
  delete_group(rg_id);
  
  rg_id := create_group_from_query('RGRP_ESPECIALIDAD',
  	'SELECT NOMBRE, TO_CHAR(ID) FROM ESPECIALIDAD ORDER BY 1');
  nDummy := populate_group(rg_id);
  populate_list('CREA_PSS.ESPECIALIDAD', rg_id);
  delete_group(rg_id);  
    
  rg_id := create_group_from_query('RGRP_TIPO_CENTRO_MEDICO',
  	'SELECT NOMBRE, TO_CHAR(ID) FROM TIPO_CENTRO_MEDICO ORDER BY 1');
  nDummy := populate_group(rg_id);
  populate_list('CREA_PSS.TIPO_CENTRO', rg_id);
  delete_group(rg_id);  
  
  rg_id := create_group_from_query('RGRP_TPA_PSS',
  	'SELECT I.NOMBRE, TO_CHAR(P.ID) FROM PROVEEDOR P, INSTITUCION I WHERE P.TPA = 1 AND P.INSTITUCION_ID = I.ID ORDER BY 1');
  nDummy := populate_group(rg_id);
  populate_list('CREA_PSS.TPA', rg_id);
  delete_group(rg_id);   
  
  rg_id := create_group_from_query('RGRP_TIPO_DIRECCION',
  	'SELECT RV_MEANING, RV_LOW_VALUE FROM CG_REF_CODES WHERE UPPER(RV_DOMAIN) = ''TIPO_DIRECCION'' AND COMPANIA = '||:GLOBAL.COD_COMPANIA||' ORDER BY 1');
  nDummy := populate_group(rg_id);
  populate_list('CREA_PSS.TIPO_DIRECCION', rg_id);
  delete_group(rg_id);  
  
  rg_id := create_group_from_query('RGRP_TIPO_TELEFONO',
  	'SELECT DESCRIPCION, CLAVE FROM PARAMETRO_GENERAL_OPCION '||
  	'WHERE ID_PARAMETRO_GENERAL = (SELECT ID FROM PARAMETRO_GENERAL '||
  																'WHERE CLAVE = ''TIPO_TELEFONO'') ORDER BY CLAVE');
  nDummy := populate_group(rg_id);
  populate_list('TELEFONOS_PSS.TIPO_TELEFONO', rg_id);
  delete_group(rg_id);       
  
  rg_id := create_group_from_query('RGRP_TIPO_TELEFONO',
  	'SELECT DESCRIPCION, CLAVE FROM PARAMETRO_GENERAL_OPCION '||
  	'WHERE ID_PARAMETRO_GENERAL = (SELECT ID FROM PARAMETRO_GENERAL '||
  																'WHERE CLAVE = ''TIPO_TELEFONO'') ORDER BY CLAVE');
  nDummy := populate_group(rg_id);
  populate_list('CREA_PSS.TIPO_TEL_CONTACTO', rg_id);
  delete_group(rg_id);     

  --Tommy Pereyra Enfoco 20/09/2024
  rg_id := create_group_from_query('RGRP_MOT_CAMB_MEDIO_PAGO',
    'SELECT DESCRIPCION, TO_CHAR(CODIGO) CODIGO '||
    'FROM REEMBOLSO.MOT_CAMB_MEDIO_PAGO '||
    'ORDER BY CODIGO');
  nDummy := populate_group(rg_id);
  populate_list('MOT_CAM_MED_PAG.CODIGO', rg_id);
  delete_group(rg_id);
  --Tommy Pereyra Enfoco 20/09/2024

End;
