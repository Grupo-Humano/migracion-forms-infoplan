-- PROGRAM UNIT: MANEJO_MENSAJES_ERRORES
-- Tipo: Procedure
-- ====================================================================

/* -------------------------------------------------------------------- */
/* PROCEDURE MANEJO_MENSAJE_ERRORES					*/
/* Trigger para capturar los mensajes y errores para desplegar		*/
/* los mensajes en espaqol.						*/
/* -------------------------------------------------------------------- */
/* Company:	CONASIN							*/
/* Author:	A.Flavia						*/
/* Date:	June 1996						*/
/* -------------------------------------------------------------------- */
PROCEDURE MANEJO_MENSAJES_ERRORES(
   mesnum IN NUMBER,
   error  IN BOOLEAN) IS

   txt_msj_long NUMBER := LENGTH(MESSAGE_TEXT);
   texto_mensaje VARCHAR2(25); 
   alert_button	NUMBER;   

  BEGIN
	 
	 IF mesnum = 40100 THEN
	    MSG_ALERT('             Primer Registro.', 'I',error);
	 ELSIF (mesnum = 40102) THEN
	    MSG_ALERT('Debe Digitar o Eliminar el Registro.', 'E',FALSE);
	 ELSIF (mesnum = 40200 or mesnum = 40602 or mesnum = 41050) THEN
	    MSG_ALERT('Este Campo no puede ser Modificado.', 'I',error); 
	 ELSIF mesnum = 40202 THEN
	    MSG_ALERT('Valor del Campo No Puede ser Nulo.', 'E',error);
	 ELSIF mesnum = 40207 THEN
	    texto_mensaje := SUBSTR(MESSAGE_TEXT, 18, txt_msj_long);
	    MSG_ALERT('Valor del Campo debe estar en el Rango de: ' ||texto_mensaje, 'I',error);
	 ELSIF mesnum = 40208 THEN
	    --MSG_ALERT('Forma solo en Modalidad de Consulta. No Puede Realizar Cambios.', 'W',error);
	    NULL; -- Htorres
	 ELSIF mesnum = 40209 THEN
	    texto_mensaje := SUBSTR(MESSAGE_TEXT, 22, txt_msj_long);
	    MSG_ALERT('Formato Invalido. Formato del campo es: '||texto_mensaje, 'E',error);
	 ELSIF mesnum = 40212 THEN
	    texto_mensaje := SUBSTR(MESSAGE_TEXT, 25, txt_msj_long);
	    MSG_ALERT('Valor Invalido en el Campo: ' ||texto_mensaje, 'I',error); 
	 ELSIF mesnum = 40301 THEN
	    MSG_ALERT('No Se Encontro Ningun Registro.', 'I',error); 
	 ELSIF mesnum = 40302 THEN
	    MSG_ALERT('En Este Bloque No Puede Realizar Consultas(QUERY).', 'I',error); 
	 ELSIF mesnum = 40350 THEN
	    NULL;
	 ELSIF mesnum = 40352 THEN
	    MSG_ALERT('              Ultimo Registro.', 'I', error);
	 ELSIF mesnum = 40353 THEN 
	    Null;                 /* Para evitar el mensaje de 'QUERY Cancel'. */
	 ELSIF mesnum = 40356 THEN
	    MSG_ALERT('              Dato Invalido.', 'E',error);
	 ELSIF (mesnum = 40400 or mesnum = 40404) THEN
	   -- MSG_ALERT('Modificaciones Han Sido Grabadas.', 'I',error);
	   message('Modificaciones Han Sido Grabadas.');
	   
	 ELSIF (mesnum = 40401 or mesnum = 40405) THEN
	    MSG_ALERT('No Existen Datos a Grabar.', 'I',error);
	 ELSIF mesnum = 40502 THEN 
	    MSG_ALERT('Registro ya Existe', 'E',error);
	 ELSIF mesnum = 40654 THEN 
	    MSG_ALERT('Registro ha sido actualizado, favor consultar de nuevo.', 'E',error);
	 ELSIF mesnum = 41000 THEN
	    MSG_ALERT('Funcion No Esta Disponible.', 'E',error);
	 ELSIF mesnum = 41047 THEN
	    MSG_ALERT('En Modalidad de Consulta(ENTER-QUERY) No Puede Salir del Bloque.', 'I',error);
	 ELSIF mesnum = 41049 THEN
	    MSG_ALERT('Registro no puede ser Borrado.', 'E',error);
	 ELSIF mesnum = 41051 THEN 
	    Null; /* Para evitar el mensaje de "Insert Not Allowed" */
	 ELSIF mesnum = 41830 THEN 
	    MSG_ALERT('Lista de Valores No Tiene Registros.', 'I',error);
	 ELSIF (mesnum = 50006 OR mesnum = 50016) THEN
	    MSG_ALERT('Valor del Campo Debe Ser Numerico.', 'E',error);
	 ELSIF mesnum = 50024 THEN
	    MSG_ALERT('Los Espacios solo son permitidos en la primera posicion.', 'E',error);
	 ELSIF mesnum = 47109 THEN
	    MSG_ALERT('No existe ninguna Informacion Relacionada', 'E',error);
 	 ELSE
	    MSG_ALERT(MESSAGE_TYPE || '-' ||TO_CHAR(MESSAGE_CODE) || ': '||MESSAGE_TEXT, 'E',error);
	    /* MESSAGE(MESSAGE_TYPE ||'-'||TO_CHAR(MESSAGE_CODE) || ': ' ||MESSAGE_TEXT); 
	    RAISE FORM_TRIGGER_FAILURE; */
	 END IF;
  END;
