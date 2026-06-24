-- PROGRAM UNITS EXTRAÍDOS DE: reemb_pago_fmb.xml
-- Total: 86
-- ====================================================================

-- PROGRAM UNIT: BUTTON_HELP
-- Tipo: Procedure
-- --------------------------------------------------------------------
-- This trigger is part of the iconic button tool tips implementation 
PROCEDURE BUTTON_HELP (trigger_item varchar2)IS

  x     number;
  tm_id timer;
BEGIN
  del_timer('bubble_delay');
  If (get_item_property(trigger_item,ITEM_TYPE)= 'BUTTON') then
    :global.bubble_item := trigger_item;
    tm_id := create_timer('bubble_delay',1000,no_repeat);
  else
    set_item_property('TOOLBAR.BUTTON_HELP',displayed,property_off);
  end if;
END;

-- ====================================================================

-- PROGRAM UNIT: CAMBIA_COLOR_HEADER
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE CAMBIA_COLOR_HEADER IS

  v_color varchar2(20) := f_obten_parametro_color(nvl(:GLOBAL.COD_COMPANIA,30),'COLOR_FORMA');

BEGIN
	SET_CANVAS_PROPERTY('CG$STACKED_HEADER_1', background_color, v_color);
END;

-- ====================================================================

-- PROGRAM UNIT: CG$CHK_PACKAGE_FAILURE
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE CG$CHK_PACKAGE_FAILURE IS
/* If packaged procedure has failed then raise */
/* FORM_TRIGGER_FAILURE */
BEGIN
  IF NOT FORM_SUCCESS THEN
    RAISE FORM_TRIGGER_FAILURE;
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: CG$WHEN_NEW_FORM_INSTANCE
-- Tipo: Procedure
-- --------------------------------------------------------------------
/* CG$WHEN_NEW_FORM_INSTANCE */
PROCEDURE CG$WHEN_NEW_FORM_INSTANCE IS
BEGIN
/* CGGN$GET_DATE_AND_USER */
/* Get the current user and date; store in items for general use */
BEGIN
  DECLARE
    CURSOR C IS
      SELECT  SYSDATE, USER
      FROM    SYS.DUAL;
  BEGIN
    OPEN C;
    FETCH C
    INTO    :CG$CTRL.CGU$SYSDATE, :CG$CTRL.CGU$USER;
    IF C%NOTFOUND THEN
      message('Internal Error: No row in table SYS.DUAL');
      RAISE FORM_TRIGGER_FAILURE;
    END IF;
    CLOSE C;
  EXCEPTION
    WHEN OTHERS THEN
      CGTE$OTHER_EXCEPTIONS;
  END;
END;

/* CGLY$COPY_USER_DATE */
/* Values from USER and DATE items on page 0 in the control */
/* block will be "fired" to all other USER and DATE items   */
/* on other pages.                                          */
BEGIN
  :CG$CTRL.CG$DT := :CGU$SYSDATE;
  :CG$CTRL.CG$US := :CGU$USER;
END;

/* CGLY$INIT_CANVASES */
/* Call procedure to ensure correct canvases are visible */
	BEGIN
		CGLY$CANVAS_MANAGEMENT;
	END;

END;

-- ====================================================================

-- PROGRAM UNIT: CGHP$CALL_HELP_FORM
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE CGHP$CALL_HELP_FORM
(
  CG_HELP_FRM in varchar2,
  CG_HELP_MOD in varchar2,
  CG_HELP_APP in varchar2,
  CG_HELP_MTITLE_1 in varchar2,
  CG_HELP_MTITLE_2 in varchar2
) IS
hlp_param_list_id paramlist;
itype varchar2(30) := 'TEXT ITEM';
help_table varchar2(100);

/* CGHP$CALL_HELP_FORM */
/* Call the help form after setting globals with current block and */
/*   ITEM                                                         */
BEGIN

  default_value(NULL,'GLOBAL.CGHP$LAST_ITEM_ACCESSED');

  if (id_null(hlp_param_list_id))
  then
      hlp_param_list_id := Create_Parameter_list('hlp_param_list');
      Add_Parameter(hlp_param_list_id, 'CG_HELP_MODP', TEXT_PARAMETER, 
                    CG_HELP_MOD);
      Add_Parameter(hlp_param_list_id, 'CG_HELP_APPP', TEXT_PARAMETER,
                    CG_HELP_APP);
      Add_Parameter(hlp_param_list_id, 'CG_HELP_MTITLE_2P', TEXT_PARAMETER,
                    CG_HELP_MTITLE_2);
      Add_Parameter(hlp_param_list_id, 'CG_HELP_MTITLE_1P', TEXT_PARAMETER,
                    CG_HELP_MTITLE_1);
      Add_Parameter(hlp_param_list_id, 'CG_HELP_BLKP', TEXT_PARAMETER,
                    NAME_IN('SYSTEM.CURSOR_BLOCK'));
      Add_Parameter(hlp_param_list_id, 'CG_HELP_FLDP', TEXT_PARAMETER,
                    NAME_IN('SYSTEM.CURSOR_ITEM'));

      help_table := get_block_property(NAME_IN('SYSTEM.CURSOR_BLOCK'),BASE_TABLE);
      help_table := substr(help_table, instr(help_table,'.')+1, length(help_table));
      Add_Parameter(hlp_param_list_id, 'CG_HELP_TABP', TEXT_PARAMETER, help_table);

      itype := get_item_property(NAME_IN('SYSTEM.CURSOR_ITEM'),ITEM_TYPE);
      if (itype = 'TEXT ITEM')
      then
          Add_Parameter(hlp_param_list_id, 'CG_HELP_LOV_AVAILABLEP',
                        TEXT_PARAMETER, get_item_property(
                                        NAME_IN('SYSTEM.CURSOR_ITEM'),LIST));
      else
          Add_Parameter(hlp_param_list_id, 'CG_HELP_LOV_AVAILABLEP',
                        TEXT_PARAMETER, 'FALSE');
      end if;
      Add_Parameter(hlp_param_list_id, 'CG_HELP_EDIT_AVAILABLEP',
                    TEXT_PARAMETER, itype);
  end if;

  IF get_item_property(NAME_IN('SYSTEM.CURSOR_ITEM'),AUTO_HINT) = 'TRUE' 
  THEN
     COPY(NULL,'GLOBAL.CGHP$LAST_ITEM_ACCESSED');
     COPY('N','GLOBAL.CG_HELP_LOV_REQUESTED');
     COPY('N','GLOBAL.CG_HELP_EDIT_REQUESTED');

     call_form(CG_HELP_FRM,NO_HIDE,NO_REPLACE,QUERY_ONLY,hlp_param_list_id);

     IF NOT FORM_SUCCESS THEN
       message('Unable to call help form '||CG_HELP_FRM);
     END IF;

     Destroy_Parameter_list(hlp_param_list_id);

     IF (NAME_IN('GLOBAL.CG_HELP_LOV_REQUESTED') = 'Y')
     THEN LIST_VALUES;
     END IF;

     IF (NAME_IN('GLOBAL.CG_HELP_EDIT_REQUESTED') = 'Y')
     THEN EDIT_TEXTITEM;
     END IF;
  ELSE
    IF (NAME_IN('SYSTEM.CURSOR_ITEM') = 
        NAME_IN('GLOBAL.CGHP$LAST_ITEM_ACCESSED')) 
    THEN
      COPY(NULL,'GLOBAL.CGHP$LAST_ITEM_ACCESSED');
      COPY('N','GLOBAL.CG_HELP_LOV_REQUESTED');
      COPY('N','GLOBAL.CG_HELP_EDIT_REQUESTED');

      call_form(CG_HELP_FRM,NO_HIDE,NO_REPLACE,QUERY_ONLY,hlp_param_list_id);

      IF NOT FORM_SUCCESS THEN
        message('Unable to call help form'||CG_HELP_FRM);
      END IF;

      Destroy_Parameter_list(hlp_param_list_id);

      IF (NAME_IN('GLOBAL.CG_HELP_LOV_REQUESTED') = 'Y')
      THEN LIST_VALUES;
      END IF;
      
      IF (NAME_IN('GLOBAL.CG_HELP_EDIT_REQUESTED') = 'Y')
      THEN EDIT_TEXTITEM;
      END IF;
    ELSE
      COPY(NAME_IN('SYSTEM.CURSOR_ITEM'),'GLOBAL.CGHP$LAST_ITEM_ACCESSED');
      help;
      Destroy_Parameter_list(hlp_param_list_id);
    END IF;
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: CGIM$READ_IMAGE_FILE
-- Tipo: Procedure
-- --------------------------------------------------------------------
procedure CGIM$READ_IMAGE_FILE(iname IN varchar2, iitem in varchar2) is
mypic item;
itype char(4) := upper(substr(iname,greatest((length(iname)-3),1)));
begin

  mypic := find_item(iitem);
 
  if (get_item_property(mypic,UPDATEABLE) = 'FALSE'
      and 
      NAME_IN('system.record_status') in ('CHANGED','QUERY')
      and 
      NAME_IN('system.system.mode') = 'NORMAL')
  then
      message('ERROR: Image not updateable');
      raise FORM_TRIGGER_FAILURE;
  else
      if (itype not in ('TIFF','JFIF','PICT'))
      then itype := upper(substr(iname,greatest((length(iname)-2),1)));
      end if;

      if (itype = 'TIF')
      then itype := 'TIFF';
      end if;

      read_image_file(iname, itype, mypic);

  end if;
end;

-- ====================================================================

-- PROGRAM UNIT: CGLY$CANVAS_MANAGEMENT
-- Tipo: Procedure
-- --------------------------------------------------------------------
/* CGLY$CANVAS_MANAGEMENT */
PROCEDURE CGLY$CANVAS_MANAGEMENT IS
/* Top level canvas management procedure */
  current_canvas VARCHAR2(61) := get_item_property(:SYSTEM.CURSOR_ITEM,
      ITEM_CANVAS);
  base_canvas VARCHAR2(61);
  canvas_list VARCHAR2(255);
BEGIN
  IF ( (:CG$CTRL.CG$LAST_CANVAS IS NULL) OR (:CG$CTRL.CG$LAST_CANVAS !=
      current_canvas) ) THEN
    :CG$CTRL.CG$LAST_CANVAS := current_canvas;
    set_window_property( get_view_property( current_canvas, WINDOW_NAME
        ), VISIBLE, PROPERTY_ON);
    CGLY$GET_RELATED_CANVASES(current_canvas, base_canvas);
    IF ( base_canvas = 'SOLICITUD_SERVICIO') THEN
      canvas_list := :CG$CTRL.CG$PAGE_1_LIST;
    END IF;
    CGLY$DISPLAY_CANVASES(canvas_list, current_canvas, base_canvas);
    IF ( base_canvas = 'SOLICITUD_SERVICIO') THEN
      :CG$CTRL.CG$PAGE_1_LIST := canvas_list;
    END IF;
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: CGLY$DISPLAY_CANVASES
-- Tipo: Procedure
-- --------------------------------------------------------------------
/* CGLY$DISPLAY_CANVASES */
PROCEDURE CGLY$DISPLAY_CANVASES(
   P_CANVAS_LIST    IN OUT VARCHAR2      /* List of displayed canvases */
  ,P_CURRENT_CANVAS IN     VARCHAR2      /* Current canvas             */
  ,P_BASE_CANVAS    IN     VARCHAR2) IS  /* Base canvas                */
/* Display the current canvas plus any others in the canvas list */
  canvas_list VARCHAR2(255);  /* List of displayed canvases */
  canvas_to_raise VARCHAR2(255);  /* Canvas to raise to the top */
BEGIN
  IF ( P_CURRENT_CANVAS = P_BASE_CANVAS) THEN
    P_CANVAS_LIST := P_CURRENT_CANVAS || ',';
  ELSE
    P_CANVAS_LIST := replace(P_CANVAS_LIST, P_CURRENT_CANVAS || ',');
    IF ( get_view_property(P_BASE_CANVAS, VISIBLE) = 'FALSE') THEN
      canvas_list := P_CANVAS_LIST;
      WHILE (canvas_list IS NOT NULL) LOOP
        canvas_to_raise := substr(canvas_list, 1, instr(canvas_list,
            ','));
        canvas_list := replace(canvas_list, canvas_to_raise);
        CGLY$RAISE_CANVAS(rtrim(canvas_to_raise, ','));
      END LOOP;
    END IF;
    P_CANVAS_LIST := P_CANVAS_LIST || P_CURRENT_CANVAS || ',';
  END IF;
  CAMBIA_COLOR_HEADER; --jose a. jimenez 15072020
  CGLY$RAISE_CANVAS(P_CURRENT_CANVAS);
END;

-- ====================================================================

-- PROGRAM UNIT: CGLY$GET_RELATED_CANVASES
-- Tipo: Procedure
-- --------------------------------------------------------------------
/* CGLY$GET_RELATED_CANVASES */
PROCEDURE CGLY$GET_RELATED_CANVASES(
   P_CURRENT_CANVAS IN OUT VARCHAR2      /* Current canvas */
  ,P_BASE_CANVAS    IN OUT VARCHAR2) IS  /* Base canvas    */
/* Find the canvases associated with the current canvas and record whi */
/* base canvas is displayed in each window                             */
BEGIN
  P_BASE_CANVAS := P_CURRENT_CANVAS;
  IF (get_view_property(P_CURRENT_CANVAS, WINDOW_NAME) = 'DUMMY') THEN
    :CG$CTRL.DUMMY_PAGE := P_BASE_CANVAS;
  ELSIF (get_view_property(P_CURRENT_CANVAS, WINDOW_NAME) =
      'ROOT_WINDOW') THEN
    :CG$CTRL.ROOT_WINDOW_PAGE := P_BASE_CANVAS;
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: CGLY$RAISE_CANVAS
-- Tipo: Procedure
-- --------------------------------------------------------------------
/* CGLY$RAISE_CANVAS */
PROCEDURE CGLY$RAISE_CANVAS(
   P_CANVAS IN VARCHAR2) IS  /* Current canvas */
/* Raise the current canvas, plus any dependant canvases to the top */
BEGIN
  set_view_property(P_CANVAS, VISIBLE, PROPERTY_ON);
  IF ( P_CANVAS = 'SOLICITUD_SERVICIO') THEN
    set_view_property('CG$STACKED_HEADER_1', VISIBLE, PROPERTY_ON);
    set_view_property('CG$STACKED_FOOTER_1', DISPLAY_POSITION, 0, 8.499);
    set_view_property('CG$STACKED_FOOTER_1', VISIBLE, PROPERTY_ON);
    set_view_property('ASEGURADO', VISIBLE, PROPERTY_ON);
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: CGLY$SYNC_CANVAS
-- Tipo: Procedure
-- --------------------------------------------------------------------
procedure CGLY$SYNC_CANVAS(canvas_is in char,
                      scrollx in number,
                      block_is char) is
canvas_movement number(3);
view_id viewport;

begin

  view_id := find_view(canvas_is);

  canvas_movement := (scrollx *
      (to_number(get_block_property(block_is,CURRENT_RECORD)) -
       to_number(get_block_property(block_is,TOP_RECORD))));

  set_view_property(view_id,POSITION_ON_CANVAS,0,canvas_movement);

end;

-- ====================================================================

-- PROGRAM UNIT: CGTE$OTHER_EXCEPTIONS
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE CGTE$OTHER_EXCEPTIONS IS
/* General purpose reporting procedure for otherwise unhandled
   exceptions */
BEGIN
  IF (SQLCODE = 100) THEN
    RAISE NO_DATA_FOUND;
  ELSIF (SQLCODE = -100501) THEN
    RAISE FORM_TRIGGER_FAILURE;
  ELSE
    message(SQLERRM);
    RAISE FORM_TRIGGER_FAILURE;
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: CGTE$POP_ERROR_STACK
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE CGTE$POP_ERROR_STACK
(
  P_ERR_CODE  IN OUT NUMBER,
  P_ERR_MSG   IN OUT VARCHAR2
) IS

  start_pos  number := instr(P_ERR_MSG, 'ORA-', 5);

BEGIN

  if ( start_pos != 0 )
    then
      P_ERR_MSG  := substr(P_ERR_MSG, start_pos);
      P_ERR_CODE := to_number(
                      substr(P_ERR_MSG, 5, instr(P_ERR_MSG, ':', 5) - 5)
                             );
    else
      P_ERR_MSG  := null;
      P_ERR_CODE := 0;
  end if;

END CGTE$POP_ERROR_STACK;

-- ====================================================================

-- PROGRAM UNIT: CGTE$STRIP_CONSTRAINT
-- Tipo: Function
-- --------------------------------------------------------------------
FUNCTION CGTE$STRIP_CONSTRAINT
(
  P_MSG_TEXT  IN  VARCHAR2
) RETURN VARCHAR2 is

  start_pos   number := instr(P_MSG_TEXT, '.', instr(P_MSG_TEXT,'('));

BEGIN

  if ( start_pos != 0 )
    then
      return( substr(P_MSG_TEXT, start_pos +1,
                     instr(P_MSG_TEXT, ')', start_pos) - start_pos -1
                     )
            );
    else
      return( null );
  end if;

END CGTE$STRIP_CONSTRAINT;

-- ====================================================================

-- PROGRAM UNIT: CGTE$STRIP_FIRST_ERROR
-- Tipo: Function
-- --------------------------------------------------------------------
FUNCTION CGTE$STRIP_FIRST_ERROR
(
   P_MSG  IN  VARCHAR2
) RETURN VARCHAR2 IS

  end_pos  number := instr(P_MSG, 'ORA-', 5);

BEGIN

  if ( end_pos != 0 )
    then
      return( substr(substr(P_MSG,1, end_pos -2 ),12) );
    else
      return( substr(P_MSG,12) );
  end if;

END CGTE$STRIP_FIRST_ERROR;

-- ====================================================================

-- PROGRAM UNIT: CHECK_PACKAGE_FAILURE
-- Tipo: Procedure
-- --------------------------------------------------------------------
Procedure Check_Package_Failure IS
BEGIN
  IF NOT ( Form_Success ) THEN
    RAISE Form_Trigger_Failure;
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: CLEAR_ALL_MASTER_DETAILS
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE Clear_All_Master_Details IS
  mastblk  VARCHAR2(30);  -- Initial Master Block Causing Coord
  coordop  VARCHAR2(30);  -- Operation Causing the Coord
  trigblk  VARCHAR2(30);  -- Cur Block On-Clear-Details Fires On
  startitm VARCHAR2(61);  -- Item in which cursor started
  frmstat  VARCHAR2(15);  -- Form Status
  curblk   VARCHAR2(30);  -- Current Block
  currel   VARCHAR2(30);  -- Current Relation
  curdtl   VARCHAR2(30);  -- Current Detail Block

  FUNCTION First_Changed_Block_Below(Master VARCHAR2)
  RETURN VARCHAR2 IS
    curblk VARCHAR2(30);  -- Current Block
    currel VARCHAR2(30);  -- Current Relation
    retblk VARCHAR2(30);  -- Return Block
  BEGIN
    --
    -- Initialize Local Vars
    --
    curblk := Master;
    currel := Get_Block_Property(curblk,  FIRST_MASTER_RELATION);
    --
    -- While there exists another relation for this block
    --
    WHILE currel IS NOT NULL LOOP
      --
      -- Get the name of the detail block
      --
      curblk := Get_Relation_Property(currel, DETAIL_NAME);
      --
      -- If this block has changes, return its name
      --
      IF ( Get_Block_Property(curblk, STATUS) = 'CHANGED' ) THEN
        RETURN curblk;
      ELSE
        --
        -- No changes, recursively look for changed blocks below
        --
        retblk := First_Changed_Block_Below(curblk);
        --
        -- If some block below is changed, return its name
        --
        IF retblk IS NOT NULL THEN
          RETURN retblk;
        ELSE
          --
          -- Consider the next relation
          --
          currel := Get_Relation_Property(currel, NEXT_MASTER_RELATION);
        END IF;
      END IF;
    END LOOP;

    --
    -- No changed blocks were found
    --
    RETURN NULL;
  END First_Changed_Block_Below;

BEGIN
  --
  -- Init Local Vars
  --
  mastblk  := :System.Master_Block;
  coordop  := :System.Coordination_Operation;
  trigblk  := :System.Trigger_Block;
  startitm := :System.Cursor_Item;
  frmstat  := :System.Form_Status;

  --
  -- If the coordination operation is anything but CLEAR_RECORD or
  -- SYNCHRONIZE_BLOCKS, then continue checking.
  --
  IF coordop NOT IN ('CLEAR_RECORD', 'SYNCHRONIZE_BLOCKS') THEN
    --
    -- If we're processing the driving master block...
    --
    IF mastblk = trigblk THEN
      --
      -- If something in the form is changed, find the
      -- first changed block below the master
      --
      IF frmstat = 'CHANGED' THEN
        curblk := First_Changed_Block_Below(mastblk);
        --
        -- If we find a changed block below, go there
        -- and Ask to commit the changes.
        --
        IF curblk IS NOT NULL THEN
          Go_Block(curblk);
          Check_Package_Failure;
          Clear_Block(ASK_COMMIT);
          --
          -- If user cancels commit dialog, raise error
          --
          IF NOT ( :System.Form_Status = 'QUERY'
                   OR :System.Block_Status = 'NEW' ) THEN
            RAISE Form_Trigger_Failure;
          END IF;
        END IF;
      END IF;
    END IF;
  END IF;

  --
  -- Clear all the detail blocks for this master without
  -- any further asking to commit.
  --
  currel := Get_Block_Property(trigblk, FIRST_MASTER_RELATION);
  WHILE currel IS NOT NULL LOOP
    curdtl := Get_Relation_Property(currel, DETAIL_NAME);
    IF Get_Block_Property(curdtl, STATUS) <> 'NEW'  THEN
      Go_Block(curdtl);
      Check_Package_Failure;
      Clear_Block(NO_VALIDATE);
      IF :System.Block_Status <> 'NEW' THEN
        RAISE Form_Trigger_Failure;
      END IF;
    END IF;
    currel := Get_Relation_Property(currel, NEXT_MASTER_RELATION);
  END LOOP;

  --
  -- Put cursor back where it started
  --
  IF :System.Cursor_Item <> startitm THEN
    Go_Item(startitm);
    Check_Package_Failure;
  END IF;

EXCEPTION
  WHEN Form_Trigger_Failure THEN
    IF :System.Cursor_Item <> startitm THEN
      Go_Item(startitm);
    END IF;
    RAISE;

END Clear_All_Master_Details;

-- ====================================================================

-- PROGRAM UNIT: COMPARAISON
-- Tipo: Function
-- --------------------------------------------------------------------
Function COMPARAISON (val1 varchar2, val2 varchar2)

Return number

Is

   answer number := 0;

Begin

   if val1 = val2 then

      answer := 1;

   end if;

   return(answer);

End;

-- ====================================================================

-- PROGRAM UNIT: DEL_TIMER
-- Tipo: Procedure
-- --------------------------------------------------------------------
-- Standard delete timer procedure. Is part of iconic button tool tips.
PROCEDURE DEL_TIMER (tm_name Varchar2 )IS
  tm_id timer;
BEGIN
  tm_id := find_timer(tm_name);
  if not id_null(tm_id) then 
    delete_timer(tm_id);
  end if;
END;

-- ====================================================================

-- PROGRAM UNIT: F_BUSCA_TARIFA_URA
-- Tipo: Function
-- --------------------------------------------------------------------
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

-- ====================================================================

-- PROGRAM UNIT: F_FREC_CONS_TEMP_IN_UP
-- Tipo: Function
-- --------------------------------------------------------------------
FUNCTION F_FREC_CONS_TEMP_IN_UP(P_TIPO_COBERTURA NUMBER,P_FRECUENCIA NUMBER,P_ID NUMBER)  
RETURN NUMBER
IS

CURSOR C_BUSCA_SEC IS
SELECT SEQ_FRECUENCIA_CONSUMIDA_TEMP.NEXTVAL
FROM DUAL;

V_SECUENCIA NUMBER;

BEGIN
	
	IF P_ID IS NULL THEN 
		OPEN C_BUSCA_SEC;
		FETCH C_BUSCA_SEC INTO V_SECUENCIA;
		CLOSE C_BUSCA_SEC;	
		
		INSERT INTO REEMBOLSO.FRECUENCIA_CONSUMIDA_TEMP(TIPO_COBERTURA,FRECUENCIA,ID)  
		VALUES (P_TIPO_COBERTURA,P_FRECUENCIA ,V_SECUENCIA);
		
	ELSE 
			V_SECUENCIA:=P_ID;
		UPDATE REEMBOLSO.FRECUENCIA_CONSUMIDA_TEMP
		SET TIPO_COBERTURA=P_TIPO_COBERTURA,FRECUENCIA=P_FRECUENCIA
		WHERE ID=V_SECUENCIA;
		
	END IF;
	
	RETURN V_SECUENCIA;
	
	
  
END;

-- ====================================================================

-- PROGRAM UNIT: F_FREC_CONS_TEMP_SUMA
-- Tipo: Function
-- --------------------------------------------------------------------
FUNCTION F_FREC_CONS_TEMP_SUMA(P_TIPO_COBERTURA NUMBER,P_FRECUENCIA NUMBER,P_ID NUMBER)  
RETURN NUMBER
IS

CURSOR C_BUSCA_SEC IS
SELECT SUM(NVL(FRECUENCIA,0))
FROM REEMBOLSO.FRECUENCIA_CONSUMIDA_TEMP
WHERE TIPO_COBERTURA=P_TIPO_COBERTURA;

V_FRECUENCIA_ACUM NUMBER;

BEGIN
	
		V_FRECUENCIA_ACUM:=NULL;
		
		OPEN C_BUSCA_SEC;
		FETCH C_BUSCA_SEC INTO V_FRECUENCIA_ACUM;
		CLOSE C_BUSCA_SEC;	
		
	
	RETURN V_FRECUENCIA_ACUM;
	
	
  
END;

-- ====================================================================

-- PROGRAM UNIT: F_USUARIO_AUTORIZADO
-- Tipo: Function
-- --------------------------------------------------------------------
FUNCTION f_usuario_autorizado return boolean is
   -- variables
   v_resultado		boolean := false;
   
-- cuerpo   
begin
    v_resultado  := false;
    if (:CG$CTRL.usuario_autorizado = :CG$CTRL.valor_t) then
 	     v_resultado := true;
    end if;	
    return (v_resultado);
    --
    
end f_usuario_autorizado;

-- ====================================================================

-- PROGRAM UNIT: MANEJO_MENSAJES_ERRORES
-- Tipo: Procedure
-- --------------------------------------------------------------------
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

-- ====================================================================

-- PROGRAM UNIT: MSG_ALERT
-- Tipo: Procedure
-- --------------------------------------------------------------------
procedure MSG_ALERT(
errm in char,           /* message */
errt in char,           /* message type */
rftf in boolean         /* raise form_trigger_failure ? */
) is      /* message parameters */
/*
* ----------------------------------------------------------------
* CHANGE HISTORY:
* DATE   PERSON      CHANGE
* ------ ----------- ---------------------------------------------
*
*/

alert_is alert;
alert_button number;

BEGIN
        
     IF (errt = 'F')
     THEN alert_is := FIND_ALERT('CFG_SYSTEM_ERROR');
     ELSIF (errt = 'E')
        THEN alert_is := FIND_ALERT('CFG_ERROR');
        ELSIF (errt = 'W')
           THEN alert_is := FIND_ALERT('CFG_WARNING_A');
              ELSIF (errt = 'I')
                 THEN alert_is := FIND_ALERT('CFG_INFORMATION');
                 ELSE MESSAGE(errm);
     end if;
     
     IF (errt IN ('F','E','W','I'))
     THEN SET_ALERT_PROPERTY(alert_is,ALERT_MESSAGE_TEXT,errm);
          alert_button := SHOW_ALERT(alert_is);
     END IF;

     IF (rftf)
     THEN
       RAISE FORM_TRIGGER_FAILURE;
     END IF;


END;

-- ====================================================================

-- PROGRAM UNIT: PKG_REPORTE_SVC
-- Tipo: Package Body
-- --------------------------------------------------------------------
PACKAGE BODY PKG_REPORTE_SVC IS
  PROCEDURE GENERAR(P_REPORTE IN VARCHAR2, P_DESCARGAR IN BOOLEAN default false) IS 
   -- v_host varchar2(100) := 'http://172.24.205.118:8090';                               
    
    v_paramDescarga VARCHAR2(20) := 'download=true';
  	v_url varchar2(4000);
  	v_params varchar2(2000) := '';
  	INVALID_ARGUMENT_EXCEPTION EXCEPTION;
    V_COMPANIA_30 NUMBER:=DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('COMPANIA_ASEGURADORA', 30);
    V_COMPANIA_96 NUMBER:=DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('COMPANIA_ARS', 96);
    V_FORMA_PAG VARCHAR2(100):=DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('FORMA_PAGO', :GLOBAL.COD_COMPANIA);
    v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('DIR_REP_INNOVA', :GLOBAL.COD_COMPANIA);

    
    CURSOR CUR_DESC_BANCO IS 
    SELECT DESCRIPCION  
    FROM BANCO_NUM_CTA 
    WHERE to_char(CODIGO)= :RADICACION.BANCO;
    
    V_BANCO VARCHAR2(1000);
    
    -- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (21/01/2023). CAMBIO DE ESTRUCTURA Y CAMPOS
    CURSOR CUR_BUSCA_SUC IS 
   	SELECT  S.NOMBRE 
		 FROM USUARIO_SUCURSAL_REEMBOLSO M, SUCURSAL_REEMBOLSO S
		WHERE M.SUCURSAL_ID = S.ID
		AND M.USUARIO = USER
		AND ROWNUM = 1;
    
    V_SUC VARCHAR2(1000);
    
    CURSOR CUR_TIP_CUENTA IS 
    SELECT DECODE(:RADICACION.TIPO_CUENTA,'A','AHORRO','CORRIENTE') 
    FROM DUAL;
    
    
   V_TIPO_CUENTA VARCHAR2(200);
   
   cursor CUR_PLAN is 
    SELECT    DISTINCT pl.codigo,
               pl.descripcion
          FROM Ase_Pol              Ap,
               Poliza               P,
               Asegurado            A,
               Cliente              C,
               Maestro_Grupo_Planes Ma,
               Plan                 Pl,
               Sub_Ramo             Sb,
               Estatus              E
         WHERE ap.compania = p.compania
           AND ap.ramo = p.ramo
           AND ap.secuencial = p.secuencial
           and ap.compania =v_compania_30 --nvl(:GLOBAL.COD_COMPANIA,ap.compania)
          -- AND ap.compania = nvl(vCia_ARSH,ap.compania)
           AND p.sub_ram = SB.CODIGO
           AND ap.estatus = e.codigo
           AND e.tipo = 'ASE_POL'
           AND e.val_log = 'T'
           AND ap.fec_ver =
               (SELECT MAX(b.fec_ver)
                  FROM ase_pol b
                 WHERE b.asegurado = ap.asegurado
                   AND b.compania = ap.compania
                   AND b.ramo = ap.ramo
                   AND b.secuencial = ap.secuencial
                   AND b.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.fec_ver =
               (SELECT MAX(p1.fec_ver)
                  FROM poliza p1
                 WHERE p1.compania = p.compania
                   AND p1.ramo = p.ramo
                   AND p1.secuencial = p.secuencial
                   AND p1.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.estatus IN (SELECT e2.codigo
                               FROM estatus e2
                              WHERE e2.tipo = 'POLIZA'
                                AND e2.val_log = 'T')
                               
           AND p.cliente = c.codigo
           AND ap.plan = pl.codigo
           AND ma.codigo = pl.tip_pla
           AND ap.asegurado = a.codigo
           AND ap.asegurado = :CG$CTRL.asegurado
           union all
            SELECT    DISTINCT pl.codigo,
               pl.descripcion
          FROM Ase_Pol              Ap,
               Poliza               P,
               Asegurado            A,
               Cliente              C,
               Maestro_Grupo_Planes Ma,
               Plan                 Pl,
               Sub_Ramo             Sb,
               Estatus              E
         WHERE ap.compania = p.compania
           AND ap.ramo = p.ramo
           AND ap.secuencial = p.secuencial
          and ap.compania =v_compania_96
          -- AND ap.compania = nvl(vCia_ARSH,ap.compania)
           AND p.sub_ram = SB.CODIGO
           AND ap.estatus = e.codigo
           AND e.tipo = 'ASE_POL'
           AND e.val_log = 'T'
           AND ap.fec_ver =
               (SELECT MAX(b.fec_ver)
                  FROM ase_pol b
                 WHERE b.asegurado = ap.asegurado
                   AND b.compania = ap.compania
                   AND b.ramo = ap.ramo
                   AND b.secuencial = ap.secuencial
                   AND b.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.fec_ver =
               (SELECT MAX(p1.fec_ver)
                  FROM poliza p1
                 WHERE p1.compania = p.compania
                   AND p1.ramo = p.ramo
                   AND p1.secuencial = p.secuencial
                   AND p1.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.estatus IN (SELECT e2.codigo
                               FROM estatus e2
                              WHERE e2.tipo = 'POLIZA'
                                AND e2.val_log = 'T')
                               
           AND p.cliente = c.codigo
           AND ap.plan = pl.codigo
           AND ma.codigo = pl.tip_pla
           AND ap.asegurado = a.codigo
           AND ap.asegurado = :CG$CTRL.asegurado
    union all
        SELECT DISTINCT 
               pl.codigo,
               pl.descripcion             
          FROM Dep_Pol              Dp,
               Poliza               P,
               Dependiente          A,
               Cliente              C,
               Maestro_Grupo_Planes Ma,
               Plan                 Pl,
               Sub_Ramo             Sb,
               Estatus              E
         WHERE Dp.compania = p.compania
           AND Dp.ramo = p.ramo
           AND Dp.secuencial = p.secuencial
          and dp.compania = v_compania_30
         --  AND Dp.compania = nvl(vCia_ARSH,Dp.compania)
           AND p.sub_ram = sb.codigo
           AND Dp.estatus = e.codigo
           AND e.tipo = 'DEP_POL'
           AND e.val_log = 'T'
           AND Dp.fec_ver =
               (SELECT MAX(b.fec_ver)
                  FROM dep_pol b
                 WHERE b.compania = Dp.compania
                   AND b.ramo = Dp.ramo
                   AND b.secuencial = Dp.secuencial
                   AND b.asegurado = Dp.asegurado
                   AND b.dependiente = Dp.dependiente
                   AND b.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.fec_ver =
               (SELECT MAX(p1.fec_ver)
                  FROM poliza p1
                 WHERE p1.compania = p.compania
                   AND p1.ramo = p.ramo
                   AND p1.secuencial = p.secuencial
                   AND p1.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.estatus IN (SELECT e2.codigo
                               FROM estatus e2
                              WHERE e2.tipo = 'POLIZA'
                                AND e2.val_log = 'T')
           AND p.cliente = c.codigo
           AND Dp.plan = pl.codigo
           AND ma.codigo = pl.tip_pla
           AND Dp.asegurado = a.asegurado
           AND Dp.dependiente = a.secuencia
           AND Dp.asegurado = :CG$CTRL.asegurado
           AND Dp.dependiente = :CG$CTRL.SECUENCIA_AFI
           union all
           SELECT DISTINCT 
               pl.codigo,
               pl.descripcion             
          FROM Dep_Pol              Dp,
               Poliza               P,
               Dependiente          A,
               Cliente              C,
               Maestro_Grupo_Planes Ma,
               Plan                 Pl,
               Sub_Ramo             Sb,
               Estatus              E
         WHERE Dp.compania = p.compania
           AND Dp.ramo = p.ramo
           AND Dp.secuencial = p.secuencial
           and dp.compania = v_compania_96
         --  AND Dp.compania = nvl(vCia_ARSH,Dp.compania)
           AND p.sub_ram = sb.codigo
           AND Dp.estatus = e.codigo
           AND e.tipo = 'DEP_POL'
           AND e.val_log = 'T'
           AND Dp.fec_ver =
               (SELECT MAX(b.fec_ver)
                  FROM dep_pol b
                 WHERE b.compania = Dp.compania
                   AND b.ramo = Dp.ramo
                   AND b.secuencial = Dp.secuencial
                   AND b.asegurado = Dp.asegurado
                   AND b.dependiente = Dp.dependiente
                   AND b.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.fec_ver =
               (SELECT MAX(p1.fec_ver)
                  FROM poliza p1
                 WHERE p1.compania = p.compania
                   AND p1.ramo = p.ramo
                   AND p1.secuencial = p.secuencial
                   AND p1.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.estatus IN (SELECT e2.codigo
                               FROM estatus e2
                              WHERE e2.tipo = 'POLIZA'
                                AND e2.val_log = 'T')
           AND p.cliente = c.codigo
           AND Dp.plan = pl.codigo
           AND ma.codigo = pl.tip_pla
           AND Dp.asegurado = a.asegurado
           AND Dp.dependiente = a.secuencia
           AND Dp.asegurado = :CG$CTRL.asegurado
           AND Dp.dependiente = :CG$CTRL.SECUENCIA_AFI;
             
     V_PLAN VARCHAR2(5000);
     V_CODIGO_PLAN NUMBER;
    v_fecha_apertura DATE:=trunc(:RADICACION.FECHA_RECEPCION);    
		v_dias number;
		v_dias_sumado number:=0;
		v_dia_semana varchar(50);
		v_fecha_rec date;

  
     
     
     CURSOR C_CUR_USUARIO IS 
     SELECT PRI_NOM||' '||PRI_APE 
      FROM USU_S_PER 
      WHERE UPPER(DESCRIPCION)=UPPER(USER);
      
      V_USUARIO VARCHAR2(2000);
      
    -- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (21/01/2023). CAMBIO DE ESTRUCTURA Y CAMPOS  
    CURSOR CUR_BUSCA_CANAL_ENTREGA IS 
	    SELECT NOMBRE 
	      FROM SUCURSAL_REEMBOLSO 
	    WHERE CODIGO = :RADICACION.SUCURSAL_CHEQUE;
    
    V_CANAL_ENTREGA VARCHAR2(500);
    
    cursor c_busca_fecha_rec is
    select trunc(FECHA_RECEPCION)
    from solicitud_pago 
    where id=:RADICACION.NUMERO_SOLICITUD;
		
     
  
  	BEGIN
  		BREAK;

  		IF(P_REPORTE IS NULL) THEN
  			RAISE INVALID_ARGUMENT_EXCEPTION;
  		END IF;
  		
  		OPEN CUR_DESC_BANCO;
  		FETCH CUR_DESC_BANCO INTO V_BANCO;
  		CLOSE CUR_DESC_BANCO; 	
  		
  		OPEN CUR_BUSCA_SUC;
  		FETCH CUR_BUSCA_SUC INTO V_SUC;
  		CLOSE CUR_BUSCA_SUC;
  		
  		OPEN CUR_TIP_CUENTA;
  		FETCH CUR_TIP_CUENTA  INTO V_TIPO_CUENTA;
  		CLOSE CUR_TIP_CUENTA;	
  		
  		OPEN C_CUR_USUARIO;
  		FETCH C_CUR_USUARIO INTO V_USUARIO; 
  		CLOSE C_CUR_USUARIO;
  		
  		OPEN CUR_BUSCA_CANAL_ENTREGA;
  		FETCH CUR_BUSCA_CANAL_ENTREGA INTO V_CANAL_ENTREGA;
  		CLOSE CUR_BUSCA_CANAL_ENTREGA;

  		
      for x in CUR_PLAN LOOP
      if V_PLAN is null then 
      	V_PLAN:=X.descripcion;	
      ELSE
      	V_PLAN:=V_PLAN||' / '||X.descripcion;		
      END IF;	
      END LOOP;
      
      open c_busca_fecha_rec;
      fetch c_busca_fecha_rec into v_fecha_rec;
      close c_busca_fecha_rec;
      
     
    
          --FECHA ESTIMADA GTP
    v_fecha_apertura:=reembolso.F_CALCULAR_FECHA(v_fecha_rec);

IF :RADICACION.MEDIO_PAGO=V_FORMA_PAG THEN 

v_url :=v_host
||'&fechaApertura='||to_char(v_fecha_rec,'dd/mm/yyyy')
||'&requestId='||:RADICACION.NUMERO_SOLICITUD
||'&SolicitudOriginal='||:RADICACION.NO_SOLICITUD_ORIGINAL -- Enfoco(GM) 10/09/2024.- Proyecto Completivo Documentacion.
||'&affiliate='||REPLACE(:CG$CTRL.NOMBRE_AFILIADO,' ','%20')
||'&cardNumber='||:CG$CTRL.NO_AFI
||'&planDescripcion='||REPLACE(V_PLAN,' ','%20')
||'&refundQuantity='||:SOLICITUD_PAGO_DETALLE.CANTIDAD
||'&refundAmount='||LTRIM(TO_CHAR(:SOLICITUD_PAGO_DETALLE.MONTO,'999,999,999.00'))
||'&fechaEstimada='||to_char(v_fecha_apertura,'dd/mm/yyyy')
||'&paymentMethod='||'Cheque'
||'&branch='||REPLACE(V_SUC,' ','%20')
||'&esTransferencia='||'N'
||'&sucursal='||REPLACE(V_CANAL_ENTREGA,' ','%20')
||'&codigoBarrasUrl='||REPLACE(:RADICACION.NUMERO_SOLICITUD,' ','%20')
||'&observaciones='||REPLACE(:SOLICITUD_PAGO_DETALLE.OBSERVACION,' ','%20')
||'&name='||'voucher_refund_request_2'
||'&createdBy='||REPLACE(V_USUARIO,' ','%20');



ELSE 

v_url :=v_host
||'&fechaApertura='||to_char(:RADICACION.FECHA_APERTURA,'dd/mm/yyyy')
||'&requestId='||:RADICACION.NUMERO_SOLICITUD
||'&SolicitudOriginal='||:RADICACION.NO_SOLICITUD_ORIGINAL -- Enfoco(GM) 10/09/2024.- Proyecto Completivo Documentacion.
||'&affiliate='||REPLACE(:CG$CTRL.NOMBRE_AFILIADO,' ','%20')
||'&cardNumber='||:CG$CTRL.NO_AFI
||'&planDescripcion='||REPLACE(V_PLAN,' ','%20')
||'&refundQuantity='||:SOLICITUD_PAGO_DETALLE.CANTIDAD
||'&refundAmount='||LTRIM(TO_CHAR(:SOLICITUD_PAGO_DETALLE.MONTO,'999,999,999.00'))
||'&fechaEstimada='||to_char(v_fecha_apertura,'dd/mm/yyyy')
||'&paymentMethod='||REPLACE('Transferencia Bancaria',' ','%20')
||'&createdBy='||REPLACE(V_USUARIO,' ','%20')
||'&branch='||REPLACE(V_SUC,' ','%20')
||'&accountNumber='||:RADICACION.NUMERO_CUENTA
||'&esTransferencia='||'S'
||'&accountType='||REPLACE(V_TIPO_CUENTA,' ','%20')
||'&bankName='||REPLACE(v_banco,' ','%20')
||'&codigoBarrasUrl='||REPLACE(:RADICACION.NUMERO_SOLICITUD,' ','%20')
||'&observaciones='||REPLACE(:SOLICITUD_PAGO_DETALLE.OBSERVACION,' ','%20')
||'&name='||'voucher_refund_request_2';

END IF;
	


  	 	   	

  	 	ABRIR_NAVEGADOR(V_URL);

  EXCEPTION 
  WHEN INVALID_ARGUMENT_EXCEPTION THEN
  	NULL;
  	--Lanzar alerta
  	--Debe especificar el nombre del reporte
  END GENERAR;
  
-----------------------------------------------------------------------------------------------------------------
 PROCEDURE ReclamosSolProcesadaPagos_INF(P_USER IN VARCHAR2 default USER,P_DESCARGAR IN BOOLEAN default false) IS 
   -- v_host varchar2(100) := 'http://172.24.205.118:8090';  
   --v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('Repos_innova', :GLOBAL.COD_COMPANIA);                             
    
    v_paramDescarga VARCHAR2(20) := 'download=true';
  	v_url varchar2(4000);
  	v_params varchar2(2000) := '';
  	INVALID_ARGUMENT_EXCEPTION EXCEPTION;
    v_reporte varchar2(100):='ReclamosSolicitudProcesadaPagos_INF';
    v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('DIR_REP_INNOVA', 30);

    
    
    	    
  

  
  

BEGIN


	


v_url :=v_host
||'&name='||REPLACE(v_reporte,' ','%20')
||'&pUsuario='||P_USER
||'&P_LOGO='||'30.png';






  	 	   	
  	 	ABRIR_NAVEGADOR(V_URL);

  

  EXCEPTION 
  WHEN INVALID_ARGUMENT_EXCEPTION THEN
  	NULL;
  	--Lanzar alerta
  	--Debe especificar el nombre del reporte
  END ReclamosSolProcesadaPagos_INF;
  -------------------------------------------------------------
  PROCEDURE ReclamosSolProcesadaPagos_pri(P_USER IN VARCHAR2 default USER,P_DESCARGAR IN BOOLEAN default false) IS 
   -- v_host varchar2(100) := 'http://172.24.205.118:8090';  
   --v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('Repos_innova', :GLOBAL.COD_COMPANIA);                             
    
    v_paramDescarga VARCHAR2(20) := 'download=true';
  	v_url varchar2(4000);
  	v_params varchar2(2000) := '';
  	INVALID_ARGUMENT_EXCEPTION EXCEPTION;
    v_reporte varchar2(100):='ReclamosSolicitudProcesadaPagos_pri';
    v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('DIR_REP_INNOVA', 96);
    


BEGIN


v_url :=v_host
||'&name='||REPLACE(v_reporte,' ','%20')
||'&pUsuario='||P_USER
||'&P_LOGO='||'96.png';
	





  	 	   	
  	 	ABRIR_NAVEGADOR(V_URL);
  

  

  EXCEPTION 
  WHEN INVALID_ARGUMENT_EXCEPTION THEN
  	NULL;
  	--Lanzar alerta
  	--Debe especificar el nombre del reporte
  END ReclamosSolProcesadaPagos_pri;
  -----------------------------------------------------------------
  
-------------------------------------------CARTA DE informacion
  PROCEDURE carta_informacion_inf(P_USER IN VARCHAR2 default USER,p_trato varchar2,P_FECHA_TRA DATE,
  																p_trato_completo varchar2,p_nombre_afiliado varchar2,p_numero_afiliado varchar2,
  																p_nombre_poliza varchar2,p_direccion varchar2,p_fecha_servicio date,p_numero_contracto varchar2,p_via_entrega varchar2,
  																p_fecha_limite date,
  																p_observacion varchar2, P_CONCEPTOS VARCHAR2,P_DOCUMENTOS VARCHAR2,p_nombre_afiliado2 varchar2,	P_FECHA_RECEPCION DATE,	
  																	p_label_observaciones varchar2 default null,																
  																P_DESCARGAR IN BOOLEAN default false) IS 
   -- v_host varchar2(100) := 'http://172.24.205.118:8090';                               
    
    v_paramDescarga VARCHAR2(20) := 'download=true';
  	v_url varchar2(4000);
  	v_params varchar2(2000) := '';
  	INVALID_ARGUMENT_EXCEPTION EXCEPTION;
    v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('DIR_REP_INNOVA', :GLOBAL.COD_COMPANIA);
    v_reporte varchar2(100):='carta_solicitud_informacion_inf';
    v_logo_humano VARCHAR2(20) := '30.png';
    v_logo_primera VARCHAR2(20) := '96.png';
  V_FECHA_SERVICIO varchar2(100) :=TO_char(p_fecha_servicio,'dd/mm/yyyy');
  V_FECHA_LIMITE varchar2(100) := TO_char(p_fecha_limite,'dd/mm/yyyy');
  V_FECHA_RECEPCION varchar2(100) := TO_char(P_FECHA_RECEPCION,'dd/mm/yyyy');
  V_FECHA_TRA varchar2(100) := TO_char(P_FECHA_TRA,'dd/mm/yyyy');
  
  

  


 --of26062023
	v_asegurado varchar2(100);
	v_ramo number;
	v_compania number;
	v_secuencial number;
	
/*	cursor c_poliza is 
	SELECT X.COMPANIA,X.RAMO,X.SECUENCIAL
  FROM ASE_POL X
 WHERE X.ASEGURADO=SUBSTR(p_numero_afiliado,1,7)
 AND X.SECUENCIA=0
 UNION ALL
  SELECT X.COMPANIA,X.RAMO,X.SECUENCIAL
  FROM DEP_POL X
 WHERE X.ASEGURADO=SUBSTR(p_numero_afiliado,1,7)
 AND X.DEPENDIENTE=SUBSTR(p_numero_afiliado,8,3);*/
                                                 
begin
	/*open c_poliza;
	fetch c_poliza into v_compania,v_ramo,v_secuencial;
	close c_poliza;*/
  


v_asegurado:=substr(p_numero_afiliado,1,7);


v_url :=v_host||'&name='||REPLACE(v_reporte,' ','%20')
||'&logoUrl='||REPLACE(v_logo_humano,' ','%20')
||'&P_TRATO='||REPLACE(REPLACE(REPLACE(p_trato,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_trato,' ','%20')
||'&P_FECHA_TRA='||V_FECHA_TRA
||'&P_TRATO_COMPLETO='||REPLACE(REPLACE(REPLACE(p_trato_completo,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_trato_completo,' ','%20')
||'&P_NOMBRE_AFILIADO='||REPLACE(REPLACE(REPLACE(p_nombre_afiliado,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_nombre_afiliado,' ','%20')
||'&P_NUMERO_AFILIADO='||REPLACE(REPLACE(REPLACE(p_numero_afiliado,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_numero_afiliado,' ','%20')
||'&P_NOMBRE_POLIZA='||REPLACE(REPLACE(REPLACE(p_nombre_poliza,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_nombre_poliza,' ','%20')
||'&P_DIRECCION_AFILIADO='||REPLACE(REPLACE(REPLACE(p_direccion,'%','%25'),' ','%20'),'&','%26')--REPLACE(REPLACE(p_direccion,' ','%20'),'&','%26')
||'&P_NUMERO_CONTRACTO='||REPLACE(REPLACE(REPLACE(p_numero_contracto,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_numero_contracto,' ','%20')
||'&P_VIA_ENTREGA='||REPLACE(REPLACE(REPLACE(nvl(p_via_entrega,''),'%','%25'),' ','%20'),'&','%26')--REPLACE(REPLACE(nvl(p_via_entrega,''),' ','%20'),'&','%26')
||'&P_FECHA_SERVICIO='||V_FECHA_SERVICIO
||'&P_FECHA_LIMITE='||V_FECHA_LIMITE
||'&P_OBSERVACION='||REPLACE(REPLACE(REPLACE(p_observacion,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_observacion,' ','%20')
||'&P_CONCEPTOS='||REPLACE(REPLACE(REPLACE(P_CONCEPTOS,'%','%25'),' ','%20'),'&','%26')--REPLACE(P_CONCEPTOS,' ','%20')
||'&P_DOCUMENTOS='||REPLACE(REPLACE(REPLACE(P_DOCUMENTOS,'%','%25'),' ','%20'),'&','%26')--REPLACE(P_DOCUMENTOS,' ','%20')
||'&P_NOMBRE_AFILIADO2='||REPLACE(REPLACE(REPLACE(P_NOMBRE_AFILIADO2,'%','%25'),' ','%20'),'&','%26')--REPLACE(P_NOMBRE_AFILIADO2,' ','%20')
||'&P_FECHA_RECEPCION='||V_FECHA_RECEPCION
||'&P_LABEL_OBSERVACION='||p_label_observaciones;



  	 	   	
  	 	ABRIR_NAVEGADOR(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_URL,'#','%23'),'+','%2B'),'[','%5B'),'{','%7B'),']','%5D'),'}','%7D'),'`','%60'));
  
  

  EXCEPTION 
  WHEN INVALID_ARGUMENT_EXCEPTION THEN
  	NULL;
  	--Lanzar alerta
  	--Debe especificar el nombre del reporte
  END carta_informacion_inf;

-------------------------------------------CARTA DE DECLINACION
  PROCEDURE carta_declinacion_inf(P_USER IN VARCHAR2 default USER,p_trato varchar2,P_FECHA_TRA DATE,
  																p_trato_completo varchar2,p_nombre_afiliado varchar2,p_numero_afiliado varchar2,
  																p_nombre_poliza varchar2,p_direccion varchar2,p_numero_contracto varchar2,p_via_entrega varchar2,
  																p_fecha_servicio date,
  																p_observacion varchar2, P_CONCEPTOS VARCHAR2,	P_MOTIVOS VARCHAR2,p_nombre_afiliado2 varchar2,	P_FECHA_RECEPCION DATE,		
  																p_label_observaciones varchar2 default null,													
  																P_DESCARGAR IN BOOLEAN default false) IS 
   -- v_host varchar2(100) := 'http://172.24.205.118:8090';                               
    
    v_paramDescarga VARCHAR2(20) := 'download=true';
  	v_url varchar2(4000);
  	v_params varchar2(2000) := '';
  	INVALID_ARGUMENT_EXCEPTION EXCEPTION;
    v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('DIR_REP_INNOVA', :GLOBAL.COD_COMPANIA);
    v_reporte varchar2(100):='carta_declinacion_inf';
    v_logo_humano VARCHAR2(20) := '30.png';
    v_logo_primera VARCHAR2(20) := '96.png';
  	v_fecha varchar2(100):=to_char(p_fecha_servicio,'dd/mm/yyyy');
  	V_FECHA_RECEPCION varchar2(100) := TO_char(P_FECHA_RECEPCION,'dd/mm/yyyy');
  	V_FECHA_TRA varchar2(100) := TO_char(P_FECHA_TRA,'dd/mm/yyyy');


  --of26062023
	v_asegurado varchar2(100);
	v_ramo number;
	v_compania number;
	v_secuencial number;
	
/*	cursor c_poliza is 
	SELECT X.COMPANIA,X.RAMO,X.SECUENCIAL
  FROM ASE_POL X
 WHERE X.ASEGURADO=SUBSTR(p_numero_afiliado,1,7)
 AND X.SECUENCIA=0
 UNION ALL
  SELECT X.COMPANIA,X.RAMO,X.SECUENCIAL
  FROM DEP_POL X
 WHERE X.ASEGURADO=SUBSTR(p_numero_afiliado,1,7)
 AND X.DEPENDIENTE=SUBSTR(p_numero_afiliado,8,3);*/
                                                 
begin
/*	open c_poliza;
	fetch c_poliza into v_compania,v_ramo,v_secuencial;
	close c_poliza;*/

	


v_asegurado:=substr(p_numero_afiliado,1,7);

v_url :=v_host||'&name='||REPLACE(v_reporte,' ','%20')
||'&logoUrl='||REPLACE(v_logo_humano,' ','%20')
||'&P_TRATO='||REPLACE(REPLACE(REPLACE(p_trato,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_trato,' ','%20')
||'&P_FECHA_TRA='||V_FECHA_TRA
||'&P_TRATO_COMPLETO='||REPLACE(REPLACE(REPLACE(p_trato_completo,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_trato_completo,' ','%20')
||'&P_NOMBRE_AFILIADO='||REPLACE(REPLACE(REPLACE(p_nombre_afiliado,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_nombre_afiliado,' ','%20')
||'&P_NUMERO_AFILIADO='||REPLACE(REPLACE(REPLACE(p_numero_afiliado,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_numero_afiliado,' ','%20')
||'&P_NOMBRE_POLIZA='||REPLACE(REPLACE(REPLACE(p_nombre_poliza,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_nombre_poliza,' ','%20')
||'&P_DIRECCION='||REPLACE(REPLACE(REPLACE(p_direccion,'%','%25'),' ','%20'),'&','%26')--REPLACE(REPLACE(p_direccion,' ','%20'),'&','%26')
||'&P_NUMERO_CONTRACTO='||REPLACE(REPLACE(REPLACE(p_numero_contracto,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_numero_contracto,' ','%20')
||'&P_VIA_ENTREGA='||REPLACE(REPLACE(REPLACE(nvl(p_via_entrega,' '),'%','%25'),' ','%20'),'&','%26')--REPLACE(REPLACE(nvl(p_via_entrega,' '),' ','%20'),'&','%26')
||'&P_FECHA_SERVICIO='||v_fecha
||'&P_OBSERVACION='||REPLACE(REPLACE(REPLACE(p_observacion,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_observacion,' ','%20')
||'&P_conceptos='||REPLACE(REPLACE(REPLACE(P_CONCEPTOS,'%','%25'),' ','%20'),'&','%26')--REPLACE(P_CONCEPTOS,' ','%20')
||'&P_MOTIVOS='||REPLACE(REPLACE(REPLACE(P_MOTIVOS,'%','%25'),' ','%20'),'&','%26')--REPLACE(P_MOTIVOS,' ','%20')
||'&P_NOMBRE_AFILIADO2='||REPLACE(REPLACE(REPLACE(P_NOMBRE_AFILIADO2,'%','%25'),' ','%20'),'&','%26')--REPLACE(P_NOMBRE_AFILIADO2,' ','%20')
||'&P_FECHA_RECEPCION='||V_FECHA_RECEPCION
||'&P_LABEL_OBSERVACION='||p_label_observaciones;




 	   	
  	 --	ABRIR_NAVEGADOR(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_URL,'#','%23'),'+','%2B'),'[','%5B'),'{','%7B'),']','%5D'),'}','%7D'));
      ABRIR_NAVEGADOR(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_URL,'#','%23'),'+','%2B'),'[','%5B'),'{','%7B'),']','%5D'),'}','%7D'),'`','%60'));
  

  EXCEPTION 
  WHEN INVALID_ARGUMENT_EXCEPTION THEN
  	NULL;
  	--Lanzar alerta
  	--Debe especificar el nombre del reporte
  END carta_declinacion_inf;  
  
  PROCEDURE ABRIR_NAVEGADOR(P_URL IN VARCHAR2) IS
    V_TIPO VARCHAR2(1) := 'C'; --E (OLE2 Edge), C (Chrome HOST)
  BEGIN
  	
   IF V_TIPO = 'E' THEN
		declare
			v_url varchar2(2000);
			browser OLE2.OBJ_TYPE;
			args OLE2.LIST_TYPE;
		begin
		 	browser := OLE2.CREATE_OBJ('Shell.Application');
			args := OLE2.create_arglist;
			ole2.add_arg(args,'microsoft-edge:'||P_URL);
			ole2.invoke(browser,'ShellExecute',args);
			ole2.destroy_arglist(args);
			ole2.release_obj(browser);
		end;
   ELSIF V_TIPO = 'C' THEN
   	--	CLIENT_HOST ('"C:\Program Files\Google\Chrome\Application\chrome.exe" --force-app-mode --new-window '|| P_URL);
   	 	client_HOST('cmd /c start chrome "'||P_URL||'"');
   		
   END IF;
  	
  END ABRIR_NAVEGADOR;
  
END;

-- ====================================================================

-- PROGRAM UNIT: POPULAR_LISTAS
-- Tipo: Procedure
-- --------------------------------------------------------------------
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

-- ====================================================================

-- PROGRAM UNIT: PROCESO_VALIDAR_CUENTAS
-- Tipo: Procedure
-- --------------------------------------------------------------------
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

-- ====================================================================

-- PROGRAM UNIT: P_ACTUALIZA_SOLICITUD
-- Tipo: Procedure
-- --------------------------------------------------------------------
--Tommy Pereyra Enfoco 11/11/2024
PROCEDURE p_actualiza_solicitud IS

  vAse number := to_number(SUBSTR(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,1,7));
  vDep number := to_number(SUBSTR( :SOLICITUD_SERVICIO.CODIGO_AFILIADO,8,3));
  v_tip_cob number;

begin	
  v_tip_cob := INNOVACORE.PKG_INNOVA.FDP_DET_TIPO_COB(:SOLICITUD_SERVICIO.TIPO_SERVICIO,:SOLICITUD_SERVICIO_DETALLE.COBERTURA);

  reembolso.pkg_restric_reembolso.p_act_solicitud(:GLOBAL.COD_COMPANIA, 
                                                  :solicitud_servicio.codigo_plan, 
                                                  :SOLICITUD_SERV_DIAG.cod_diagnostico, 
                                                  :SOLICITUD_SERVICIO.tipo_servicio,
                          										    v_tip_cob, 
                          										    :SOLICITUD_SERVICIO_DETALLE.cobertura, 
                          										    vAse, 
                          											  vDep, 
                          											  :radicacion.numero_solicitud);

END;

-- ====================================================================

-- PROGRAM UNIT: P_AGREGA_RECL_SELECCIONADOS
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_AGREGA_RECL_SELECCIONADOS IS			
  V_MSGID5 NUMBER(10) := F_OBTEN_PARAMETRO_SEUS('SPOOL_EXGRATIA.MSG5', :GLOBAL.COD_COMPANIA);
  v_est_sl_pend   NUMBER(5)  := F_OBTEN_PARAMETRO_SEUS('SOL_SER_REEMB.EST_PE', :GLOBAL.COD_COMPANIA);
  v_est_sol_pac  NUMBER(5)   := F_OBTEN_PARAMETRO_SEUS('SOL_SER_REEM.EST_PAC', :GLOBAL.COD_COMPANIA); -- Pendiente spool Autoriz Cobros 
BEGIN
	IF :RESUMEN_RECLAMOS.ESTATUS IN(v_est_sl_pend,v_est_sol_pac) THEN
     p_imprime_mensaje(V_MSGID5, null);
     RAISE FORM_TRIGGER_FAILURE;
	END IF;
	--
	REEMBOLSO.P_AGREGA_RECL_SELECCIONADOS(:radicacion.NUMERO_SOLICITUD, :radicacion.medio_pago);
END;

-- ====================================================================

-- PROGRAM UNIT: P_AJUSTA_ESTATUS_SOL_PAG
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_AJUSTA_ESTATUS_SOL_PAG IS
	CURSOR CUR_SOL_PEND IS
		SELECT 1
		FROM SOLICITUD_SERVICIO
		WHERE SOLICITUD_PAGO_ID = :RADICACION.NUMERO_SOLICITUD
		AND ESTATUS IN (PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('EST_PEN_SOL_SER_REMB',:GLOBAL.COD_COMPANIA),
                         PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('EST_PEN_DOC_SOL_SER',:GLOBAL.COD_COMPANIA));
  V_EXISTE	NUMBER;
BEGIN
  IF :RADICACION.NUMERO_SOLICITUD IS NOT NULL THEN
	  OPEN CUR_SOL_PEND;
	  FETCH CUR_SOL_PEND INTO V_EXISTE;
	  IF CUR_SOL_PEND%NOTFOUND THEN
	  	UPDATE SOLICITUD_PAGO
	  	SET ESTATUS = PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('EST_COM_SOL_PAG_REMB',:GLOBAL.COD_COMPANIA)
	  	WHERE ID = :RADICACION.NUMERO_SOLICITUD;
	  	
			:SYSTEM.MESSAGE_LEVEL := '25';
  		COMMIT;	
   		:SYSTEM.MESSAGE_LEVEL := '0';
   		
	  END IF;
	  CLOSE CUR_SOL_PEND;
	END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_ALERTA_MENSAJE
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_ALERTA_MENSAJE
(
  mensaje        in   varchar2, 
  tipo_mensaje   in   varchar2 
) IS
  -- 
  resultado    number;
BEGIN
  if tipo_mensaje = 'E' then
    set_alert_property( 'ALERTA_ERROR', alert_message_text, mensaje );
    resultado := Show_Alert( 'ALERTA_ERROR' ); 
  elsif tipo_mensaje = 'N' then
    set_alert_property( 'ALERTA_NOTA', alert_message_text, mensaje );
    resultado := Show_Alert( 'ALERTA_NOTA' ); 
  elsif tipo_mensaje = 'M' then
    set_alert_property( 'ALERTA_PRECAUCION', alert_message_text, mensaje );
    resultado := Show_Alert( 'ALERTA_PRECAUCION' ); 
  end if;
EXCEPTION
	when others then  	 	
       pkg_general.p_inserta_error(:CG$CTRL.programa||'P_ALERTA_MENSAJE', 
       															sqlcode, substr(sqlerrm ,1, 1000), 'Error proceso generar mensaje de alerta.');  
       --       															      
END P_ALERTA_MENSAJE;

-- ====================================================================

-- PROGRAM UNIT: P_ANULA_RECLAMACION
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_ANULA_RECLAMACION(P_SOL_SER_ID	NUMBER) IS
	CURSOR CUR_EXISTE_RECLAMO IS
		SELECT ID
		FROM RECLAMO
		WHERE SOLICITUD_SERVICIO_ID = P_SOL_SER_ID;
		
	V_RECLAMO	RECLAMO.ID%TYPE;
	
BEGIN
  OPEN CUR_EXISTE_RECLAMO;
  FETCH CUR_EXISTE_RECLAMO INTO V_RECLAMO;
  CLOSE CUR_EXISTE_RECLAMO;
  
  IF V_RECLAMO IS NOT NULL THEN
  	UPDATE RECLAMO
  	SET ESTATUS = PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('EST_ANU_RECLAMO',:GLOBAL.COD_COMPANIA)
  	WHERE ID = V_RECLAMO;
  	
  	P_BUSCAR_RECLAMO(V_RECLAMO, :GLOBAL.COD_COMPANIA);
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_BUSCA_CORREO_AFILIADO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_BUSCA_CORREO_AFILIADO(P_NUMERO_AFILIADO	NUMBER, P_TIPO_AFILIADO	VARCHAR2) IS
	V_TIPO_CLIENTE VARCHAR2(100);
	V_NOMBRE_CLIENTE VARCHAR2(1000);
BEGIN
	
  :RADICACION.CORREO_NOTIFICA := F_buscar_cliente_correo (P_NUMERO_AFILIADO, P_TIPO_AFILIADO);
END;

-- ====================================================================

-- PROGRAM UNIT: P_BUSCA_DATOS_AFILIADO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_BUSCA_DATOS_AFILIADO IS
	
	
	
	vAse NUMBER;
	vDep NUMBER;
	vIdent VARCHAR2(11);
	V_NUMERO_ANO NUMBER:= PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('P_NUMERO_ANO',:GLOBAL.COD_COMPANIA);
	V_EXISTE number;

		
		CURSOR CUR_PLASTICO(vIdent VARCHAR2) is 
		SELECT ASEGURADO, SECUENCIA
        FROM AFILIADO_PLASTICOS
        where   NUM_PLA = vIdent
     union all
     SELECT COD_ASE_LOC ASEGURADO, SEC_DEP_LOC SECUENCIA
        FROM AFILIADO_PLASTICOS_int
        where   NUM_PLA = vIdent;
        
        		--OF14092023 SE CREO ESTE CURSOR PARA BUSCAR QUE EXISTA UN ASEGURADO EN POLIZA DE HUMANO
		CURSOR C_BUSCA_ASE(P_ASEGURADO NUMBER) IS 
		SELECT 1 FROM ASE_POL
		WHERE ASEGURADO=P_ASEGURADO
		AND COMPANIA IN (30,96);
		
	  CURSOR C_BUSCA_DEP(P_ASEGURADO NUMBER,P_SECUENCIA NUMBER) IS
		SELECT 1 FROM DEP_POL
		WHERE ASEGURADO=P_ASEGURADO
		AND DEPENDIENTE=P_SECUENCIA
		AND COMPANIA IN (30,96);
        
   CURSOR CUR_DATOS_AFI IS
	  SELECT *
		FROM ASE_DEP01_V A
		WHERE A.Asegurado=vAse
		AND  A.secuencia =vDep;
		
		CURSOR CUR_BUSCA_CEDULA IS 	
		SELECT ase_dep, 
					Asegurado, 
        	Dependiente,
        	codigo_estatus,
        	codEstatusPlastico  
       FROM (SELECT 'ASEGURADO' ASE_DEP,
                       A.Codigo ASEGURADO,
                       0 DEPENDIENTE,
                       e.codigo codigo_estatus,
                       INNOVACORE.PKG_INNOVA.f_valida_plastico_fec_ser(TRUNC(SYSDATE),afi_pla.num_pla) codEstatusPlastico,
                       TRUNC(afi_pla.fec_ver) FechaPlastico,
                       AP.FEC_TRA FEC_TRA_VIGENCIA
                  FROM ASEGURADO A,
                       ASE_POL            Ap,
                       estatus            e,
                       afiliado_plasticos afi_pla
                 WHERE a.ced_act = vIdent
                   AND e.codigo = ap.Estatus
                   AND e.tipo = 'ASE_POL'
                   AND afi_pla.asegurado = A.CODIGO
                   AND afi_pla.secuencia = 0
                   and ap.compania = Nvl(:GLOBAL.COD_COMPANIA,ap.compania )
                   AND afi_pla.fec_ver =
                       (SELECT MAX(z.fec_ver)
                          FROM afiliado_plasticos z
                         WHERE z.asegurado = afi_pla.asegurado
                           AND z.secuencia = afi_pla.secuencia
                           AND z.num_pla = afi_pla.num_pla
                           AND (TRUNC(z.fec_ver) <= TRUNC(SYSDATE) 
                           		/*OR
                               EXTRACT(YEAR FROM z.fec_Ver) = V_NUMERO_ANO */
                               )
                               ) --3000
                   AND afi_pla.fec_u_act =
                       (SELECT MAX(z.fec_u_act) d
                          FROM afiliado_plasticos z
                         WHERE z.asegurado = afi_pla.asegurado
                           AND z.secuencia = afi_pla.secuencia
                           AND z.num_pla = afi_pla.num_pla
                           AND z.fec_ver = afi_pla.fec_ver
                           AND (TRUNC(z.fec_ver) <= TRUNC(SYSDATE) 
                           /*OR
                               EXTRACT(YEAR FROM z.fec_Ver) = V_NUMERO_ANO*/
                                ))
                   AND A.Codigo = Ap.Asegurado
                   AND Ap.Fec_Ver =
                       (SELECT MAX(A1.Fec_Ver)
                          FROM Ase_Pol A1
                         WHERE A1.Compania = Ap.Compania
                           AND A1.Ramo = Ap.Ramo
                           AND A1.Secuencial = Ap.Secuencial
                           AND A1.Asegurado = Ap.Asegurado
                           AND TRUNC(a1.fec_ver) <= TRUNC(SYSDATE))
                UNION ALL               
                SELECT 'DEPENDIENT' ASE_DEP,
                       D.ASEGURADO,
                       D.Secuencia DEPENDIENTE,
                        e.codigo codigo_estatus,
                       INNOVACORE.PKG_INNOVA.f_valida_plastico_fec_ser(TRUNC(SYSDATE),afi_pla.num_pla) codEstatusPlastico,
                       TRUNC(afi_pla.fec_ver) FechaPlastico,
                            DP.FEC_TRA FEC_TRA_VIGENCIA
                  FROM DEPENDIENTE D,
                       PARENTEZCO  P,
                       Dep_Pol            Dp,
                       Asegurado          A,
                       estatus            e,
                       afiliado_plasticos afi_pla
                 WHERE D.PARENTEZCO = P.Codigo
                   AND d.ced_act = vIdent
                   AND afi_pla.asegurado = d.ASEGURADO
                   AND afi_pla.secuencia = D.SECUENCIA
                   and dp.compania = Nvl(:GLOBAL.COD_COMPANIA,dp.compania)
                   AND afi_pla.fec_ver =
                       (SELECT MAX(z.fec_ver)
                          FROM afiliado_plasticos z
                         WHERE z.asegurado = afi_pla.asegurado
                           AND z.secuencia = afi_pla.secuencia
                           AND z.num_pla = afi_pla.num_pla
                           AND (TRUNC(z.fec_ver) <= TRUNC(SYSDATE) 
                           /*OR
                               EXTRACT(YEAR FROM z.fec_Ver) = V_NUMERO_ANO */
                               )) --3000
                   AND afi_pla.fec_u_act =
                       (SELECT MAX(z.fec_u_act) d
                          FROM afiliado_plasticos z
                         WHERE z.asegurado = afi_pla.asegurado
                           AND z.secuencia = afi_pla.secuencia
                           AND z.num_pla = afi_pla.num_pla
                           AND z.fec_ver = afi_pla.fec_ver)
                   AND A.codigo = D.Asegurado
                   AND D.Asegurado = Dp.Asegurado
                   AND D.Secuencia = Dp.Dependiente
                   AND e.codigo = Dp.Estatus
                   AND e.tipo = 'DEP_POL'
                   AND Dp.Fec_Ver =
                       (SELECT MAX(Dp1.Fec_Ver)
                          FROM Dep_Pol Dp1
                         WHERE Dp1.Compania = Dp.Compania
                           AND Dp1.Ramo = Dp.Ramo
                           AND Dp1.Secuencial = Dp.Secuencial
                           AND Dp1.Asegurado = Dp.Asegurado
                           AND Dp1.Dependiente = Dp.Dependiente
                           AND TRUNC(Dp1.fec_ver) <= TRUNC(SYSDATE)
                           )
   UNION ALL 
               SELECT 'ASEGURADO' ASE_DEP,
                       A.Codigo ASEGURADO,
                       0 DEPENDIENTE,
                       e.codigo codigo_estatus,
                       INNOVACORE.PKG_INNOVA.F_VALIDA_PLASTICO_FEC_SER_INT(TRUNC(SYSDATE),afi_pla.num_pla) codEstatusPlastico,
                       TRUNC(afi_pla.fec_ver) FechaPlastico,
                       AP.FEC_TRA FEC_TRA_VIGENCIA
                  FROM ASEGURADO A,
                       ASE_POL            Ap,
                       estatus            e,
                       afiliado_plasticos_int afi_pla
                 WHERE a.ced_act = vIdent
                   AND e.codigo = ap.Estatus
                   AND e.tipo = 'ASE_POL'
                   AND afi_pla.COD_ASE_LOC = A.CODIGO
                   AND afi_pla.SEC_DEP_LOC = 0
                   and ap.compania = Nvl(:GLOBAL.COD_COMPANIA,ap.compania )
                   AND afi_pla.fec_ver =
                       (SELECT MAX(z.fec_ver)
                          FROM afiliado_plasticos_int z
                         WHERE Z.COD_ASE_LOC = afi_pla.COD_ASE_LOC
		                   AND nvl(z.SEC_DEP_LOC,0) = nvl(afi_pla.SEC_DEP_LOC,0)
                           AND z.num_pla = afi_pla.num_pla
                           AND (TRUNC(z.fec_ver) <= TRUNC(SYSDATE) 
                           		/*OR
                               EXTRACT(YEAR FROM z.fec_Ver) = V_NUMERO_ANO */
                               )
                               ) --3000
                   AND afi_pla.fec_u_act =
                       (SELECT MAX(z.fec_u_act) d
                          FROM afiliado_plasticos_int z
                         WHERE Z.COD_ASE_LOC = afi_pla.COD_ASE_LOC
		                   AND nvl(z.SEC_DEP_LOC,0) = nvl(afi_pla.SEC_DEP_LOC,0)
                           AND z.num_pla = afi_pla.num_pla
                           AND z.fec_ver = afi_pla.fec_ver
                           AND (TRUNC(z.fec_ver) <= TRUNC(SYSDATE) 
                           /*OR
                               EXTRACT(YEAR FROM z.fec_Ver) = V_NUMERO_ANO*/
                                ))
                   AND A.Codigo = Ap.Asegurado
                   AND Ap.Fec_Ver =
                       (SELECT MAX(A1.Fec_Ver)
                          FROM Ase_Pol A1
                         WHERE A1.Compania = Ap.Compania
                           AND A1.Ramo = Ap.Ramo
                           AND A1.Secuencial = Ap.Secuencial
                           AND A1.Asegurado = Ap.Asegurado
                           AND TRUNC(a1.fec_ver) <= TRUNC(SYSDATE))
            UNION ALL               
                SELECT 'DEPENDIENT' ASE_DEP,
                       D.ASEGURADO,
                       D.Secuencia DEPENDIENTE,
                        e.codigo codigo_estatus,
                       INNOVACORE.PKG_INNOVA.f_valida_plastico_fec_ser(TRUNC(SYSDATE),afi_pla.num_pla) codEstatusPlastico,
                       TRUNC(afi_pla.fec_ver) FechaPlastico,
                            DP.FEC_TRA FEC_TRA_VIGENCIA
                  FROM DEPENDIENTE D,
                       PARENTEZCO  P,
                       Dep_Pol            Dp,
                       Asegurado          A,
                       estatus            e,
                       afiliado_plasticos_int afi_pla
                 WHERE D.PARENTEZCO = P.Codigo
                   AND d.ced_act = vIdent
                   AND afi_pla.COD_ASE_LOC = d.ASEGURADO
                   AND afi_pla.SEC_DEP_LOC = D.SECUENCIA
                   and dp.compania = Nvl(:GLOBAL.COD_COMPANIA,dp.compania)
                   AND afi_pla.fec_ver =
                       (SELECT MAX(z.fec_ver)
                          FROM afiliado_plasticos_int z
                         WHERE Z.COD_ASE_LOC = afi_pla.COD_ASE_LOC
		                   AND nvl(z.SEC_DEP_LOC,0) = nvl(afi_pla.SEC_DEP_LOC,0)
                           AND z.num_pla = afi_pla.num_pla
                           AND (TRUNC(z.fec_ver) <= TRUNC(SYSDATE) 
                           /*OR
                               EXTRACT(YEAR FROM z.fec_Ver) = V_NUMERO_ANO */
                               )) --3000
                   AND afi_pla.fec_u_act =
                       (SELECT MAX(z.fec_u_act) d
                          FROM afiliado_plasticos_int z
                         WHERE Z.COD_ASE_LOC = afi_pla.COD_ASE_LOC
		                   AND nvl(z.SEC_DEP_LOC,0) = nvl(afi_pla.SEC_DEP_LOC,0)
                           AND z.num_pla = afi_pla.num_pla
                           AND z.fec_ver = afi_pla.fec_ver)
                   AND A.codigo = D.Asegurado
                   AND D.Asegurado = Dp.Asegurado
                   AND D.Secuencia = Dp.Dependiente
                   AND e.codigo = Dp.Estatus
                   AND e.tipo = 'DEP_POL'
                   AND Dp.Fec_Ver =
                       (SELECT MAX(Dp1.Fec_Ver)
                          FROM Dep_Pol Dp1
                         WHERE Dp1.Compania = Dp.Compania
                           AND Dp1.Ramo = Dp.Ramo
                           AND Dp1.Secuencial = Dp.Secuencial
                           AND Dp1.Asegurado = Dp.Asegurado
                           AND Dp1.Dependiente = Dp.Dependiente
                           AND TRUNC(Dp1.fec_ver) <= TRUNC(SYSDATE)
                           )
                  )
         ORDER BY ase_dep,codigo_estatus, codEstatusPlastico desc;         
                  
	
	R_DATOS_AFI	CUR_DATOS_AFI%ROWTYPE;
  R_DATOS_AFI_CED	CUR_BUSCA_CEDULA%ROWTYPE;
  V_valida_ase VARCHAR2(20);

BEGIN

IF 	LENGTH(:CG$CTRL.NO_AFI) <= 10 THEN --ES ASEGURADO O CARNET 

	vAse:= to_number(SUBSTR(:CG$CTRL.NO_AFI,1,7));
	vDep:= to_number(SUBSTR( :CG$CTRL.NO_AFI,8,3));
  
  OPEN CUR_DATOS_AFI;
  FETCH CUR_DATOS_AFI INTO R_DATOS_AFI;
  CLOSE CUR_DATOS_AFI;
  
  if R_DATOS_AFI.CODIGO IS NULL then 
  	
  	 OPEN CUR_PLASTICO(LPAD(:CG$CTRL.NO_AFI, 20, '0')); 
     FETCH CUR_PLASTICO INTO vAse, vDep;
     IF CUR_PLASTICO%FOUND THEN 
     	  OPEN CUR_DATOS_AFI;
  			FETCH CUR_DATOS_AFI INTO R_DATOS_AFI;
  				IF CUR_DATOS_AFI%FOUND THEN 
  				:CG$CTRL.NO_AFI:=lpad(vAse,7,'0')||'000'; 
  				END IF;
  			CLOSE CUR_DATOS_AFI;
     END IF;
     CLOSE CUR_PLASTICO;
      	
  end if;
  
    IF R_DATOS_AFI.CODIGO IS NOT NULL AND R_DATOS_AFI.TIP_ASE='DEPENDIENT'  THEN
				vDep:=0;
				OPEN CUR_DATOS_AFI;
  			FETCH CUR_DATOS_AFI INTO R_DATOS_AFI;
  			CLOSE CUR_DATOS_AFI;		
  		:CG$CTRL.NO_AFI:=lpad(vAse,7,'0')||'000';	
   END IF;
END IF;	  

IF 	LENGTH(:CG$CTRL.NO_AFI) = 11 THEN--ES CEDULA O CARNET

  vIdent:=:CG$CTRL.NO_AFI;
  
  OPEN CUR_BUSCA_CEDULA;
  FETCH CUR_BUSCA_CEDULA INTO R_DATOS_AFI_CED;
  IF CUR_BUSCA_CEDULA%FOUND THEN 
  		vAse:= R_DATOS_AFI_CED.ASEGURADO;
	    vDep:=  R_DATOS_AFI_CED.Dependiente; 
  ELSE 	
  	 OPEN CUR_PLASTICO(LPAD(:CG$CTRL.NO_AFI, 20, '0')); 
     FETCH CUR_PLASTICO INTO vAse, vDep;
     CLOSE CUR_PLASTICO;
  END IF;
  CLOSE CUR_BUSCA_CEDULA;
  
  IF vAse IS NOT NULL THEN 
    :CG$CTRL.NO_AFI:=lpad(vAse,7,'0')||'000'; 
  	vDep:=0;
		OPEN CUR_DATOS_AFI;
  	FETCH CUR_DATOS_AFI INTO R_DATOS_AFI;
  	CLOSE CUR_DATOS_AFI;
  END IF; 
  
END IF;

IF 	LENGTH(:CG$CTRL.NO_AFI) > 11 THEN  --ES CARNET
  
  

  	 OPEN CUR_PLASTICO(LPAD(:CG$CTRL.NO_AFI, 20, '0')); 
     FETCH CUR_PLASTICO INTO vAse, vDep;
     CLOSE CUR_PLASTICO;
	 
	  IF vAse IS NOT NULL THEN 
		    :CG$CTRL.NO_AFI:=lpad(vAse,7,'0')||'000'; 
		  	vDep:=0;
				OPEN CUR_DATOS_AFI;
		  	FETCH CUR_DATOS_AFI INTO R_DATOS_AFI;
		  	CLOSE CUR_DATOS_AFI;
		END IF;
END IF;


  
  IF :cg$ctrl.no_afi is not null and R_DATOS_AFI.CODIGO IS NULL THEN
		p_imprime_mensaje(213, NULL);
		RAISE FORM_TRIGGER_FAILURE;
  END IF;
  
  
  --OF14092023
   IF R_DATOS_AFI.ASEGURADO > 0 AND R_DATOS_AFI.SECUENCIA=0 THEN 
  	
	  OPEN C_BUSCA_ASE(R_DATOS_AFI.ASEGURADO);
	  FETCH C_BUSCA_ASE INTO V_EXISTE;
	   IF C_BUSCA_ASE%NOTFOUND THEN
	   		MSG_ALERT('Este asegurado no posee una poliza de Humano','E',TRUE);
	   END IF;
	  CLOSE C_BUSCA_ASE;
	  
	   ELSIF R_DATOS_AFI.ASEGURADO > 0 AND R_DATOS_AFI.SECUENCIA > 0 THEN 
	   	
	  OPEN C_BUSCA_DEP(R_DATOS_AFI.ASEGURADO,R_DATOS_AFI.SECUENCIA);
	  FETCH C_BUSCA_DEP INTO V_EXISTE;
	   IF C_BUSCA_DEP%NOTFOUND THEN
	   		MSG_ALERT('Este asegurado no posee una poliza de Humano','E',TRUE);
	   END IF;
	  CLOSE C_BUSCA_DEP;
	END IF;
  
  :CG$CTRL.NUMERO_AFILIADO := R_DATOS_AFI.CODIGO;
  :CG$CTRL.NOMBRE_AFILIADO := R_DATOS_AFI.NOMBRE;
  :CG$CTRL.COD_CLIENTE_AFILIADO := R_DATOS_AFI.CDPERSON;
  :CG$CTRL.TIPO_AFILIADO := R_DATOS_AFI.TIP_ASE;
  :CG$CTRL.ASEGURADO := R_DATOS_AFI.ASEGURADO;
  :CG$CTRL.SECUENCIA_AFI := R_DATOS_AFI.SECUENCIA;
  :CG$CTRL.CED_ACT := R_DATOS_AFI.CED_ACT;
  :CG$CTRL.PASAPORTE := R_DATOS_AFI.PASAPORTE;
  :CG$CTRL.PRI_NOM := R_DATOS_AFI.PRI_NOM;
  :CG$CTRL.SEG_NOM := R_DATOS_AFI.SEG_NOM;
  :CG$CTRL.PRI_APE := R_DATOS_AFI.PRI_APE;
  :CG$CTRL.SEG_APE := R_DATOS_AFI.SEG_APE;
  
  /*para sincronizar el usuario en SAP ecruzc*/
  V_valida_ase := PKG_SYNC_CLIENTE_SAP.CODIGO_SAP(R_DATOS_AFI.ASEGURADO,'ASEGURADO');
  
  IF NVL(V_valida_ase,0) = 0 THEN
  	
   --MSG_ALERT('Usuario no esta sincronizado en SAP.', 'I',FALSE);
    
   REEMBOLSO.SINCRONIZA_ASEGURADO_BP(R_DATOS_AFI.ASEGURADO,'ASEGURADO');
   
  END IF;
  --
  -- Enfoco (GM) 23/10/2024.- Proyecto Exgratia
  P_BUSCA_RAZON_FALLEC(:CG$CTRL.ASEGURADO,
                       :CG$CTRL.SECUENCIA_AFI, 
                       :CG$CTRL.FALLECIDO,
                       :FALLEC.RAZON_FALLECIDO,
                       :FALLEC.FEC_MODIF_FALLEC,
                       :FALLEC.USU_MODIF_FALLEC);
END;

-- ====================================================================

-- PROGRAM UNIT: P_BUSCA_DATOS_CUENTA_BANCARIA
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_BUSCA_DATOS_CUENTA_BANCARIA(P_NUMERO_AFILIADO	NUMBER, P_TIPO_AFILIADO VARCHAR2)  IS
	CURSOR C_DATOS_NUM_CTA IS
		SELECT N.CODIGO, N.TIP_CTA, DECODE(N.TIP_CTA,'A','AHOR','CORR') COD_TIPO_CUENTA, N.NUM_CTA, N.BANCO, N.TIP_PRO, N.FEC_TRA, N.PROPIETARIO, N.CODIGO_IDENTIFICADOR, N.CDPERSON, N.VALIDADA, N.TOKENIZADA, N.USER_TOKENIZA, N.FECHA_TOKENIZA, --N.CANAL,
		       I.CONTRATANTE_NOM, I.CONTRATANTE_CED, I.CONTRATANTE_TIPO_ID, I.COD_NACIONALIDAD, I.TIP_PROPIETARIO, I.SEXO, I.EMAIL_NOTIFICA_PAGO--, I.TELEFONO
		 FROM NUMERO_CUENTA N, NUMERO_CUENTA_INFO I
		WHERE I.CODIGO = N.CODIGO
		 AND N.NUM_CTA =:RADICACION.NUMERO_CUENTA
		 /*AND N.TIP_PRO = P_TIPO_AFILIADO
		 AND N.PROPIETARIO = P_NUMERO_AFILIADO*/ -- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (05/02/2024). COMENTADO DOS CONDICIONES
		 ORDER BY N.CODIGO DESC;
	
	R_DATOS_NUM_CTA		C_DATOS_NUM_CTA%ROWTYPE;
	
	V_EXISTE_IDENTIFICACION VARCHAR2(1) := 'N';
	
	-- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (05/02/2024). CURSOR PARA VALIDAR SI EXISTE LA CEDULA
	CURSOR CUR_BUSCA_CEDULA(P_CEDULA VARCHAR2) IS
		SELECT 'S'
		  FROM ASEGURADO
		WHERE CODIGO  = P_NUMERO_AFILIADO
		  AND CED_ACT = P_CEDULA
		  AND ESTATUS = 5
		UNION
		SELECT 'S'
		  FROM DEPENDIENTE
		WHERE ASEGURADO = P_NUMERO_AFILIADO
		  AND CED_ACT   = P_CEDULA
		  AND ESTATUS   = 23;
	
	-- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (05/02/2024). CURSOR PARA VALIDAR SI EXISTE EL PASAPORTE
	CURSOR CUR_BUSCA_PASAPORTE(P_PASAPORTE VARCHAR2) IS
		SELECT 'S'
		  FROM ASEGURADO
		WHERE CODIGO    = P_NUMERO_AFILIADO
		  AND PASAPORTE = P_PASAPORTE
		  AND ESTATUS   = 5
		UNION
		SELECT 'S'
		  FROM DEPENDIENTE
		WHERE ASEGURADO = P_NUMERO_AFILIADO
		  AND PASAPORTE = P_PASAPORTE
		  AND ESTATUS   = 23;	  

BEGIN

	-- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (05/02/2024). MODIFICACION DEL CODIGO 
  FOR R_DATOS_NUM_CTA IN  C_DATOS_NUM_CTA LOOP
  	
  /*	V_EXISTE_IDENTIFICACION := 'N';
  	  
		IF R_DATOS_NUM_CTA.CONTRATANTE_TIPO_ID = 'C' THEN
			OPEN  CUR_BUSCA_CEDULA(R_DATOS_NUM_CTA.CONTRATANTE_CED);
			FETCH CUR_BUSCA_CEDULA INTO V_EXISTE_IDENTIFICACION;
			CLOSE CUR_BUSCA_CEDULA;
		ELSIF R_DATOS_NUM_CTA.CONTRATANTE_TIPO_ID = 'P' THEN	
			OPEN  CUR_BUSCA_PASAPORTE(R_DATOS_NUM_CTA.CONTRATANTE_CED);
			FETCH CUR_BUSCA_PASAPORTE INTO V_EXISTE_IDENTIFICACION;
			CLOSE CUR_BUSCA_PASAPORTE;
		END IF;
		*/
	--	IF V_EXISTE_IDENTIFICACION = 'S' THEN
			--:RADICACION.TIPO_CUENTA        := R_DATOS_NUM_CTA.COD_TIPO_CUENTA; --Tommy Pereyra Enfoco 15/10/2024
		  :RADICACION.NOMBRE_PROPIETARIO := R_DATOS_NUM_CTA.CONTRATANTE_NOM;
		  :RADICACION.TIPO_PROPIETARIO   := R_DATOS_NUM_CTA.TIP_PROPIETARIO;
		  --:RADICACION.NUMERO_DOCUMENTO   := R_DATOS_NUM_CTA.CONTRATANTE_CED; --Tommy Pereyra Enfoco 15/10/2024
		  --:RADICACION.TIPO_DOCUMENTO     := R_DATOS_NUM_CTA.CONTRATANTE_TIPO_ID; --Tommy Pereyra Enfoco 15/10/2024
		  :RADICACION.SEXO               := R_DATOS_NUM_CTA.SEXO;
		  :RADICACION.NACIONALIDAD       := R_DATOS_NUM_CTA.COD_NACIONALIDAD;
		  :RADICACION.CORREO_PROPIETARIO := R_DATOS_NUM_CTA.EMAIL_NOTIFICA_PAGO;
		  
		  EXIT;
	--	END IF;	
	
  END LOOP;
  
END;

-- ====================================================================

-- PROGRAM UNIT: P_BUSCA_MOTIVO_BLOQUEO_ASE
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_BUSCA_MOTIVO_BLOQUEO_ASE(P_TIPO_BLOQUEO VARCHAR2, 
                                     P_ASEGURADO    IN NUMBER, 
                                     P_DEP_USO      IN NUMBER) IS
  v_respuesta  NUMBER(2);
  v_msg_bloq   VARCHAR2(512) := F_OBTEN_PARAMETRO_SEUS('BLACKLIST.MSG_BLOQ', :GLOBAL.COD_COMPANIA);
  v_row_mot    ASEGURADO_MOTIVO_BLOQUEO%ROWTYPE;
  --
  v_ok       NUMBER := F_OBTEN_PARAMETRO_SEUS('P_RESPUESTA_OK', :GLOBAL.COD_COMPANIA);
  v_fallido  NUMBER := F_OBTEN_PARAMETRO_SEUS('P_RESPUESTA_FALLIDA', :GLOBAL.COD_COMPANIA);
BEGIN
  IF P_TIPO_BLOQUEO = :FRMVAR.STR_ASEGURADO THEN
     :MSG_BLOQUEO.MENSAJE := v_msg_bloq;
     --
     PKG_MOT_BLOQUEO.P_BUSCA_MOT_BLOQ_ASEGURADO(:GLOBAL.COD_COMPANIA,
                                                P_ASEGURADO, 
                                                P_DEP_USO,
                                                v_row_mot.motivo,            --OUT
                                                v_row_mot.comentario,        --OUT
                                                v_row_mot.accion,            --OUT,
                                                v_row_mot.comentario_accion, --OUT
                                                v_respuesta                  --OUT
                                                );
     :MSG_BLOQUEO.MOTIVO     := PKG_MOT_BLOQUEO.F_BUSCA_DSP_MOTIVO(v_row_mot.motivo);
     :MSG_BLOQUEO.COMENTARIO := v_row_mot.comentario;
     :MSG_BLOQUEO.ACCION     := PKG_MOT_BLOQUEO.F_BUSCA_DSP_ACCION(v_row_mot.accion);
     --:MSG_BLOQUEO.COMENTARIO_ACCION := v_row_mot.comentario_accion;
     :MSG_BLOQUEO.TIPO_BLOQUEO := P_TIPO_BLOQUEO;
     --
     GO_ITEM('MSG_BLOQUEO.MOTIVO');
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_BUSCA_MOTIVO_BLOQUEO_PERTIN
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_BUSCA_MOTIVO_BLOQUEO_PERTIN(P_TIPO_BLOQUEO    IN VARCHAR2, 
                                        P_CODIGO_AFILIADO IN VARCHAR2,
                                        P_DIAGNOSTICO     IN VARCHAR2, 
                                        P_SERVICIO        IN NUMBER,
                                        P_TIP_COB         IN NUMBER, 
                                        P_COBERTURA       IN NUMBER) IS
  v_respuesta  NUMBER(2);
  v_cod_ase    NUMBER(10) := SUBSTR(P_CODIGO_AFILIADO, 1, LENGTH(P_CODIGO_AFILIADO)-3);
  v_sec_dep    NUMBER(3)  := SUBSTR(P_CODIGO_AFILIADO, -3);
  --
  TYPE lst_cur IS RECORD (Motivo            Number(10),
                          Comentario        Varchar2(512),
                          Accion            Number(10),
                          Comentario_accion Varchar2(512),
                          mensaje           Varchar2(512));
  v_row_mot  lst_cur;
  --
BEGIN
  PKG_MOT_BLOQUEO.P_BUSCA_MOT_BLOQ_PERTINENCIA (P_COMPANIA     => :GLOBAL.COD_COMPANIA,
                                                P_ASEGURADO    => v_cod_ase,
                                                P_DEP_USO      => v_sec_dep,
                                                P_TIPO_BLOQUEO => P_TIPO_BLOQUEO,
                                                P_DIAGNOSTICO  => P_DIAGNOSTICO,
                                                P_SERVICIO     => P_SERVICIO,
                                                P_TIP_COB      => P_TIP_COB,
                                                P_COBERTURA    => P_COBERTURA,
                                                P_MOTIVO       => v_row_mot.motivo, --OUT NUMBER,
                                                P_COMENTARIO   => v_row_mot.comentario, --OUT VARCHAR2,
                                                P_ACCION       => v_row_mot.ACCION, --OUT NUMBER,
                                                P_COMENTARIO_A => v_row_mot.comentario_accion, --OUT VARCHAR2,
                                                P_MENSAJE      => v_row_mot.mensaje, --OUT VARCHAR2,
                                                P_RESPUESTA    => v_respuesta); --OUT VARCHAR2) IS
   :MSG_BLOQUEO.TIPO_BLOQUEO := P_TIPO_BLOQUEO;
   :MSG_BLOQUEO.MOTIVO       := PKG_MOT_BLOQUEO.F_BUSCA_DSP_MOTIVO(v_row_mot.motivo);
   :MSG_BLOQUEO.COMENTARIO   := v_row_mot.comentario;
   :MSG_BLOQUEO.ACCION       := PKG_MOT_BLOQUEO.F_BUSCA_DSP_ACCION(v_row_mot.accion);
   :MSG_BLOQUEO.COMENTARIO_ACCION := v_row_mot.comentario_accion;
   :MSG_BLOQUEO.MENSAJE      :=  v_row_mot.mensaje;
   --
   IF P_DIAGNOSTICO IS NOT NULL THEN
      :MSG_BLOQUEO.COD_TIP_BLOQ := P_DIAGNOSTICO;
   END IF;
   --
   IF P_SERVICIO IS NOT NULL THEN
   	  :MSG_BLOQUEO.COD_TIP_BLOQ := P_SERVICIO;
   END IF;
   --
   IF P_TIP_COB IS NOT NULL THEN
   	  :MSG_BLOQUEO.COD_TIP_BLOQ := P_TIP_COB;
   END IF;
   --
   IF P_COBERTURA IS NOT NULL THEN
   	  :MSG_BLOQUEO.COD_TIP_BLOQ := P_COBERTURA;
   END IF;
   --
   IF P_TIPO_BLOQUEO = :FRMVAR.STR_ASEGURADO THEN
      SET_WINDOW_PROPERTY('CG$WIND_MENSAJE_BLOQ', POSITION, 2.5, 1.5); 
   ELSE
      SET_WINDOW_PROPERTY('CG$WIND_MENSAJE_BLOQ', POSITION, 2.5, 6);
      SET_ITEM_PROPERTY('MSG_BLOQUEO.COMENTARIO_ACCION', VISIBLE, PROPERTY_TRUE);
      SET_ITEM_PROPERTY('MSG_BLOQUEO.COMENTARIO_ACCION', ENABLED, PROPERTY_TRUE);
      SET_ITEM_PROPERTY('MSG_BLOQUEO.PB_VER_DETALLE', VISIBLE, PROPERTY_TRUE);
      SET_ITEM_PROPERTY('MSG_BLOQUEO.PB_VER_DETALLE', ENABLED, PROPERTY_TRUE);
   END IF;
   --
   GO_ITEM('MSG_BLOQUEO.MOTIVO');
END;

/*
IF :MSG_BLOQUEO.MOTIVO IS NOT NULL THEN
     	  ROW_POL_VIG := NULL;
     	  OPEN CUR_POL_VIG;
     	  FETCH CUR_POL_VIG INTO ROW_POL_VIG;
     	  CLOSE CUR_POL_VIG;
        --
     	  PKG_MOT_BLOQUEO.SET_VARIABLE(ROW_POL_VIG.COMPANIA, 
     	                               ROW_POL_VIG.RAMO, 
     	                               ROW_POL_VIG.SECUENCIAL);
     	  -- Enfoco 03/02/2025.- Mejoras Notificacion
        PKG_MOT_BLOQUEO.P_ENVIA_NOTIFICACION_BLOQUEO(:GLOBAL.COD_COMPANIA, 
                                                     'ASEGURADO',
                                                     :RADICACION.NUMERO_SOLICITUD,
                                                     :CG$CTRL.NO_AFI,
                                                     ROW_POL_VIG.PLAN,
                                                     v_usuario_bloq, 
                                                     v_fec_tra_bloq, 
                                                     :SOLICITUD_SERVICIO.PROVEEDOR_ID,
                                                     NULL, --P_DIAGNOSTICO
                                                     NULL, --P_SERVICIO
                                                     NULL, --P_TIP_COB
                                                     NULL);-- P_COBERTURA
     END IF;     */

-- ====================================================================

-- PROGRAM UNIT: P_BUSCA_MOTIVO_RECHAZO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_BUSCA_MOTIVO_RECHAZO(P_ID_RECHAZO VARCHAR2) IS
  TYPE typ_row_mot IS RECORD (motivo            Number(10),
                              Comentario        Varchar2(512),
                              Accion            Number(10),
                              Comentario_accion Varchar2(512));
  v_row_mot typ_row_mot := null;
  --
  v_cod_ase    NUMBER(10) := to_number(SUBSTR(NVL(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,:CG$CTRL.NO_AFI),1,7));
  v_sec_dep    NUMBER(3)  := to_number(SUBSTR(NVL(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,:CG$CTRL.NO_AFI),8,3));
  v_respuesta  NUMBER(2);
  v_id_aseg_bloq  VARCHAR2(100) := F_OBTEN_PARAMETRO_SEUS('BLACKLIST.IDASEBLOQ', :GLOBAL.COD_COMPANIA); -- '702'
  v_id_pres_bloq  VARCHAR2(100) := F_OBTEN_PARAMETRO_SEUS('BLACKLIST.IDPREBLOQ', :GLOBAL.COD_COMPANIA); -- '5093'
BEGIN
  IF P_ID_RECHAZO = v_id_aseg_bloq THEN
     PKG_MOT_BLOQUEO.P_BUSCA_MOT_BLOQ_ASEGURADO(:GLOBAL.COD_COMPANIA,
                                                v_cod_ase, 
                                                v_sec_dep,
                                                v_row_mot.motivo,            --OUT
                                                v_row_mot.comentario,        --OUT
                                                v_row_mot.accion,            --OUT,
                                                v_row_mot.comentario_accion, --OUT
                                                v_respuesta                  --OUT
                                                );
  END IF;
  --
  IF P_ID_RECHAZO = v_id_pres_bloq THEN
     PKG_MOT_BLOQUEO.P_BUSCA_MOT_BLOQ_PRESTADOR(:GLOBAL.COD_COMPANIA,
                                                0,--:SOLICITUD_SERVICIO_DETALLE.COD_PROV, 
                                                :SOLICITUD_SERVICIO_DETALLE.PROVEEDOR_ID,
                                                v_row_mot.motivo,            --OUT
                                                v_row_mot.comentario,        --OUT
                                                v_row_mot.accion,            --OUT,
                                                v_row_mot.comentario_accion, --OUT
                                                v_respuesta                  --OUT
                                                );
  END IF;
  --
  IF v_row_mot.motivo IS NOT NULL THEN
     :CG$CTRL.MOTIVO_RECHAZO     := PKG_MOT_BLOQUEO.F_BUSCA_DSP_MOTIVO(v_row_mot.motivo);
     :CG$CTRL.COMENTARIO_RECHAZO := v_row_mot.comentario;
     :CG$CTRL.ACCION_RECHAZO     := PKG_MOT_BLOQUEO.F_BUSCA_DSP_ACCION(v_row_mot.accion);
     --
     SET_ITEM_PROPERTY('CG$CTRL.MOTIVO_RECHAZO', VISIBLE, PROPERTY_TRUE);
     SET_ITEM_PROPERTY('CG$CTRL.MOTIVO_RECHAZO', ENABLED, PROPERTY_TRUE);
     SET_ITEM_PROPERTY('CG$CTRL.COMENTARIO_RECHAZO', VISIBLE, PROPERTY_TRUE);
     SET_ITEM_PROPERTY('CG$CTRL.COMENTARIO_RECHAZO', ENABLED, PROPERTY_TRUE);
     SET_ITEM_PROPERTY('CG$CTRL.ACCION_RECHAZO', VISIBLE, PROPERTY_TRUE);
     SET_ITEM_PROPERTY('CG$CTRL.ACCION_RECHAZO', ENABLED, PROPERTY_TRUE);
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_BUSCA_RAZON_FALLEC
-- Tipo: Procedure
-- --------------------------------------------------------------------
-- Encofo(GM) 23/10/2024.- Proyecto Exgratia 
PROCEDURE P_BUSCA_RAZON_FALLEC(P_COD_ASE    IN NUMBER,   
                               P_COD_DEP    IN NUMBER, 
                               P_FALLECIDO OUT VARCHAR2, 
                               P_RAZON     OUT VARCHAR2,
                               P_FEC_TRA   OUT DATE,
                               P_USUARIO   OUT VARCHAR2) IS
  ROW_F  FALLECIDO_RAZON%ROWTYPE;
  --
  CURSOR CUR_FALLEC IS
    SELECT A.FALLECIDO, A.RAZON, A.FEC_TRA, A.USUARIO
      FROM FALLECIDO_RAZON A
     WHERE A.ASEGURADO = P_COD_ASE
       AND A.DEPENDIENTE = P_COD_DEP
       AND A.FEC_TRA = (SELECT MAX(F.FEC_TRA)
                          FROM FALLECIDO_RAZON F
                         WHERE F.ASEGURADO  = A.ASEGURADO
                           AND F.DEPENDIENTE = A.DEPENDIENTE);
BEGIN
  OPEN CUR_FALLEC;
  FETCH CUR_FALLEC INTO P_FALLECIDO, P_RAZON, P_FEC_TRA, P_USUARIO;
  CLOSE CUR_FALLEC;
END;

-- ====================================================================

-- PROGRAM UNIT: P_CARGA_RESUMEN_RECLAMOS
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_CARGA_RESUMEN_RECLAMOS IS
	CURSOR CUR_MONTO_TOTALES IS
		SELECT SUM(CS.MONTO_RECLAMADO), SUM(CS.MONTO_COBERTURA)
		FROM COBERTURA_SOLICITADA CS, SOLICITUD_SERVICIO SS
		WHERE CS.SOLICITUD_SERVICIO_ID = SS.ID
		AND SS.SOLICITUD_PAGO_ID = :RADICACION.NUMERO_SOLICITUD;
		
	CURSOR CUR_CODIGO_PAGO IS
		SELECT SOLICITUD_PAGO_ID
		FROM SOLICITUD_PAGO
		WHERE ID = :RADICACION.NUMERO_SOLICITUD;
		
BEGIN

	  OPEN CUR_MONTO_TOTALES;
	  FETCH CUR_MONTO_TOTALES INTO :CG$CTRL.TOTAL_RECLAMO ,:CG$CTRL.TOTAL_PAGAR;
	  CLOSE CUR_MONTO_TOTALES;
	  
	  OPEN CUR_CODIGO_PAGO;
	  FETCH CUR_CODIGO_PAGO INTO :CG$CTRL.CODIGO_PAGO;
	  CLOSE CUR_CODIGO_PAGO;
	  
	  GO_BLOCK('RESUMEN_RECLAMOS');
	  EXECUTE_QUERY;
END;

-- ====================================================================

-- PROGRAM UNIT: P_CARGA_SOLICITUD_PAGO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_CARGA_SOLICITUD_PAGO IS

  CURSOR CUR_SOLICITUD_PAGO IS
      SELECT SP.BENEFICIARIO_ID
          FROM SOLICITUD_PAGO SP
         WHERE SP.ID = :PARAMETER.P_SOLICITUD_PAGO; 
  
BEGIN
		
	IF :PARAMETER.P_SOLICITUD_PAGO IS NOT NULL THEN
		Set_Block_Property('RADICACION',default_where, 'ID = '||:PARAMETER.P_SOLICITUD_PAGO);
		Set_Block_Property('SOLICITUD_SERVICIO',default_where, 'ID IS NULL');
				
		
		OPEN CUR_SOLICITUD_PAGO;
		FETCH CUR_SOLICITUD_PAGO INTO :CG$CTRL.NO_AFI;
		CLOSE CUR_SOLICITUD_PAGO;
				
		P_BUSCA_DATOS_AFILIADO;
		:CG$CTRL.SOLICITUD_EXISTENTE := :PARAMETER.P_SOLICITUD_PAGO;
		
		P_LLENA_TABLAS_TEMPORALES_TABS;
		
		GO_BLOCK('RADICACION');
		CLEAR_BLOCK(NO_VALIDATE);
		EXECUTE_QUERY;
		-- OMARLIS GOMEZ Y LUIS CALCAÑO, FOREBRA (31/01/2024). COMENTADO
		/*IF :RADICACION.ESTATUS = PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('EST_COM_SOL_PAG_REMB',:GLOBAL.COD_COMPANIA) THEN
			SET_ITEM_PROPERTY('RESUMEN_RECLAMOS.BTN_EDITAR', ENABLED, PROPERTY_FALSE);
		END IF;*/ 
		
		GO_BLOCK('RESUMEN_RECLAMOS');
		
	END IF;
	
END;

-- ====================================================================

-- PROGRAM UNIT: P_HABILITA_BLOCK_EXGRATIA
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_HABILITA_BLOCK_EXGRATIA(P_ESTATUS NUMBER, P_BLOQUE VARCHAR2) IS
  --
  v_pendient_spool  NUMBER(5) := F_OBTEN_PARAMETRO_SEUS('SOL_PAG_REEMB.EST_PS', :GLOBAL.COD_COMPANIA);
  --
BEGIN
  IF P_ESTATUS = v_pendient_spool THEN
     IF P_BLOQUE = 'RADICACION' THEN 
        SET_BLOCK_PROPERTY(P_BLOQUE, UPDATE_ALLOWED, PROPERTY_FALSE);
     ELSE
        SET_BLOCK_PROPERTY(P_BLOQUE, UPDATE_ALLOWED, PROPERTY_FALSE);
        SET_BLOCK_PROPERTY(P_BLOQUE, INSERT_ALLOWED, PROPERTY_FALSE);
     END IF;
  ELSE
     IF P_BLOQUE = 'RADICACION' THEN 
        SET_BLOCK_PROPERTY(P_BLOQUE, UPDATE_ALLOWED, PROPERTY_TRUE);
     ELSE
        SET_BLOCK_PROPERTY(P_BLOQUE, UPDATE_ALLOWED, PROPERTY_TRUE);
        SET_BLOCK_PROPERTY(P_BLOQUE, INSERT_ALLOWED, PROPERTY_TRUE);
     END IF;
  END IF;
  /*
  IF P_ESTATUS = v_pendient_spool THEN
     IF P_BLOQUE = 'RADICACION' THEN 
        SET_BLOCK_PROPERTY(P_BLOQUE, UPDATE_ALLOWED, PROPERTY_FALSE);
     ELSE
        SET_BLOCK_PROPERTY('SOLICITUD_PAGO_DETALLE', UPDATE_ALLOWED, PROPERTY_FALSE);
        SET_BLOCK_PROPERTY('SOLICITUD_SERV_MOT', UPDATE_ALLOWED, PROPERTY_FALSE);
        SET_BLOCK_PROPERTY('SOLICITUD_SERV_DIAG', UPDATE_ALLOWED, PROPERTY_FALSE);
        SET_BLOCK_PROPERTY('SOLICITUD_SERVICIO_DETALLE', UPDATE_ALLOWED, PROPERTY_FALSE);
        --
        SET_BLOCK_PROPERTY('SOLICITUD_PAGO_DETALLE', INSERT_ALLOWED, PROPERTY_FALSE);
        SET_BLOCK_PROPERTY('SOLICITUD_SERV_MOT', INSERT_ALLOWED, PROPERTY_FALSE);
        SET_BLOCK_PROPERTY('SOLICITUD_SERV_DIAG', INSERT_ALLOWED, PROPERTY_FALSE);
        SET_BLOCK_PROPERTY('SOLICITUD_SERVICIO_DETALLE', INSERT_ALLOWED, PROPERTY_FALSE);
     END IF;
  ELSE
     IF P_BLOQUE = 'RADICACION' THEN 
        SET_BLOCK_PROPERTY(P_BLOQUE, UPDATE_ALLOWED, PROPERTY_TRUE);
     ELSE
        SET_BLOCK_PROPERTY('SOLICITUD_PAGO_DETALLE', UPDATE_ALLOWED, PROPERTY_TRUE);
        SET_BLOCK_PROPERTY('SOLICITUD_SERV_MOT', UPDATE_ALLOWED, PROPERTY_TRUE);
        SET_BLOCK_PROPERTY('SOLICITUD_SERV_DIAG', UPDATE_ALLOWED, PROPERTY_TRUE);
        SET_BLOCK_PROPERTY('SOLICITUD_SERVICIO_DETALLE', UPDATE_ALLOWED, PROPERTY_TRUE);
        --
        SET_BLOCK_PROPERTY('SOLICITUD_PAGO_DETALLE', INSERT_ALLOWED, PROPERTY_TRUE);
        SET_BLOCK_PROPERTY('SOLICITUD_SERV_MOT', INSERT_ALLOWED, PROPERTY_TRUE);
        SET_BLOCK_PROPERTY('SOLICITUD_SERV_DIAG', INSERT_ALLOWED, PROPERTY_TRUE);
        SET_BLOCK_PROPERTY('SOLICITUD_SERVICIO_DETALLE', INSERT_ALLOWED, PROPERTY_TRUE);
     END IF;
  END IF;*/
END;

-- ====================================================================

-- PROGRAM UNIT: P_HABILITA_BLOQ_SERV
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_HABILITA_BLOQ_SERV(P_HABILITA BOOLEAN) IS
BEGIN
  IF P_HABILITA THEN
  	SET_BLOCK_PROPERTY('SOLICITUD_SERVICIO', INSERT_ALLOWED, PROPERTY_TRUE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERVICIO', UPDATE_ALLOWED, PROPERTY_TRUE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERV_MOT', INSERT_ALLOWED, PROPERTY_TRUE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERV_MOT', UPDATE_ALLOWED, PROPERTY_TRUE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERV_DIAG', INSERT_ALLOWED, PROPERTY_TRUE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERV_DIAG', UPDATE_ALLOWED, PROPERTY_TRUE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERVICIO_DETALLE', INSERT_ALLOWED, PROPERTY_TRUE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERVICIO_DETALLE', UPDATE_ALLOWED, PROPERTY_TRUE);
  	SET_BLOCK_PROPERTY('BUSCA_SERVICIO', INSERT_ALLOWED, PROPERTY_TRUE);
  	SET_BLOCK_PROPERTY('BUSCA_SERVICIO', UPDATE_ALLOWED, PROPERTY_TRUE);
  	--SET_ITEM_PROPERTY('CG$CTRL.BTN_AGREGAR_DATOS_SERV', ENABLED, PROPERTY_TRUE);
  --	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EDITAR_COB', ENABLED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EDITAR_MON', ENABLED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_BORRAR', ENABLED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_COBR_INDE', ENABLED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EXCEPCION_NEGOCIO', ENABLED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_TARIFA_INCORECTA', ENABLED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_NEGOCIACION_PRESTADOR', ENABLED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('CG$CTRL.CHK_FUERA_COB', ENABLED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('CG$CTRL.CHK_FUERA_COB', INSERT_ALLOWED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('CG$CTRL.CHK_FUERA_COB', UPDATE_ALLOWED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO.MONTO_NO_CUB', ENABLED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO.MONTO_NO_CUB', INSERT_ALLOWED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO.MONTO_NO_CUB', UPDATE_ALLOWED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO.DESCRIPCION_NO_CUB', ENABLED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO.DESCRIPCION_NO_CUB', INSERT_ALLOWED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO.DESCRIPCION_NO_CUB', UPDATE_ALLOWED, PROPERTY_TRUE);
  	SET_ITEM_PROPERTY('BUSCA_SERVICIO.LOV_PRESTADOR_ADD', ENABLED, PROPERTY_TRUE);
  ELSE
  	SET_BLOCK_PROPERTY('SOLICITUD_SERVICIO', INSERT_ALLOWED, PROPERTY_FALSE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERVICIO', UPDATE_ALLOWED, PROPERTY_FALSE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERV_MOT', INSERT_ALLOWED, PROPERTY_FALSE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERV_MOT', UPDATE_ALLOWED, PROPERTY_FALSE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERV_DIAG', INSERT_ALLOWED, PROPERTY_FALSE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERV_DIAG', UPDATE_ALLOWED, PROPERTY_FALSE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERVICIO_DETALLE', INSERT_ALLOWED, PROPERTY_FALSE);
  	SET_BLOCK_PROPERTY('SOLICITUD_SERVICIO_DETALLE', UPDATE_ALLOWED, PROPERTY_FALSE); 
  	SET_BLOCK_PROPERTY('BUSCA_SERVICIO', INSERT_ALLOWED, PROPERTY_FALSE);
  	SET_BLOCK_PROPERTY('BUSCA_SERVICIO', UPDATE_ALLOWED, PROPERTY_FALSE);
  	--SET_ITEM_PROPERTY('CG$CTRL.BTN_AGREGAR_DATOS_SERV', ENABLED, PROPERTY_FALSE); 
  ---	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EDITAR_COB', ENABLED, PROPERTY_FALSE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EDITAR_MON', ENABLED, PROPERTY_FALSE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_BORRAR', ENABLED, PROPERTY_FALSE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_COBR_INDE', ENABLED, PROPERTY_FALSE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EXCEPCION_NEGOCIO', ENABLED, PROPERTY_FALSE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_TARIFA_INCORECTA', ENABLED, PROPERTY_FALSE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_NEGOCIACION_PRESTADOR', ENABLED, PROPERTY_FALSE);
  	SET_ITEM_PROPERTY('CG$CTRL.CHK_FUERA_COB', ENABLED, PROPERTY_FALSE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO.MONTO_NO_CUB', ENABLED, PROPERTY_FALSE);
  	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO.DESCRIPCION_NO_CUB', ENABLED, PROPERTY_FALSE);  	
  	SET_ITEM_PROPERTY('BUSCA_SERVICIO.LOV_PRESTADOR_ADD', ENABLED, PROPERTY_FALSE);	
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_IMPRIME_MENSAJE
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE p_imprime_mensaje(p_codigo_mensaje  mensaje_alerta_forma.codigo%type, p_mensaje  varchar2) is

  -- variables    
    V_MENSAJE_TEXTO MENSAJE_ALERTA_FORMA.TEXTO_MENSAJE%TYPE;
    V_TIPO             MENSAJE_ALERTA_FORMA.TIPO%TYPE;
    V_VALOR_LOGICO  MENSAJE_ALERTA_FORMA.VALOR_LOGICO%TYPE;
    V_TEXTO1        MENSAJE_ALERTA_FORMA.TEXTO1%TYPE;
    V_TEXTO2        MENSAJE_ALERTA_FORMA.TEXTO2%TYPE;
    V_TEXTO3        MENSAJE_ALERTA_FORMA.TEXTO3%TYPE;
    V_TEXTO4        MENSAJE_ALERTA_FORMA.TEXTO4%TYPE;
    V_VAL_LOG         BOOLEAN := false; 
    VN_ERROR           number;
    VC_ERROR_DESC      varchar2(2000);

 -- cuerpo
begin
 -- proceso que busca el mensaje parametrizado
 if (nvl(p_codigo_mensaje,0) != 0) then
         PKG_PARAMETRO_GENERAL_PROCESO.P_CONFIG_MENSAJE_ALERT_FORMA ( :GLOBAL.COD_COMPANIA,
                                                                      p_codigo_mensaje,  -- codigo de mensaje en la tabla MENSAJE_ALERTA_FORMA
                                                                      V_MENSAJE_TEXTO ,  -- parametro salida
                                                                      V_TIPO                    ,     -- parametro salida
                                                                      V_VALOR_LOGICO    ,     -- parametro salida
                                                                      V_TEXTO1                ,     -- parametro salida
                                                                      V_TEXTO2                ,     -- parametro salida
                                                                      V_TEXTO3                ,     -- parametro salida
                                                                      V_TEXTO4,             -- parametro salida
                                                                      NULL); --Tommy Pereyra Enfoco 31/10/2024
 -- 
     V_VAL_LOG := DBAPER.F_CONVIERTE_CHAR_BOOLEAN (V_VALOR_LOGICO);
     MSG_ALERT( V_MENSAJE_TEXTO|| ' '||
                        V_TEXTO1             || ' '||
                        V_TEXTO2             || ' '||
                        V_TEXTO3             || ' '|| V_TEXTO4,
                        V_TIPO,
                        V_VAL_LOG);
 --
 else
         MSG_ALERT(p_mensaje, 'E', FALSE);
 end if;
 --
 
EXCEPTION
   WHEN OTHERS THEN
      VN_ERROR      := DBMS_ERROR_CODE;
         VC_ERROR_DESC := SUBSTR(DBMS_ERROR_TEXT,1,1000);
         pkg_general.p_inserta_error
                                     ('REEMB_PAGO.p_imprime_mensaje',
                                       sqlcode,
                                       substr(sqlerrm, 1, 500),
                                       'Error en proceso impresion mensaje'
                                     );
   --
end p_imprime_mensaje;

-- ====================================================================

-- PROGRAM UNIT: P_INSERTAR_CORREO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_INSERTAR_CORREO(P_NUMERO_AFILIADO	VARCHAR2, P_TIPO_AFILIADO VARCHAR2, P_CORREO	VARCHAR2) IS
	R_CORREO CORREO_ELECTRONICO%ROWTYPE;
	V_RESULT	NUMBER;
BEGIN

	R_CORREO.PROPIETARIO := substr(P_NUMERO_AFILIADO,1,7);
	R_CORREO.TIP_PRO := P_TIPO_AFILIADO;
	R_CORREO.TIP_COR := 'C';
	R_CORREO.CORREO := P_CORREO;--:RADICACION.CORREO_NOTIFICA;

	REGISTRAR_CORREO(R_CORREO,V_RESULT);

	IF V_RESULT = 0 THEN
		p_imprime_mensaje(73, NULL);
		RAISE FORM_TRIGGER_FAILURE;	
	END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_INSERTA_EN_RECLAMO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_INSERTA_EN_RECLAMO(P_SOL_SER_ID NUMBER) IS
		
	V_REC_SECUENCIAL RECLAMO.ID%TYPE;
	V_CODIGO_MENSAJE	VARCHAR2(15);
	V_TEXTO_MENSAJE		VARCHAR2(2000);
	
BEGIN
  P_INSERTA_RECLAMO_APROBADO(P_SOL_SER_ID,
  													 V_CODIGO_MENSAJE,
  													 V_TEXTO_MENSAJE,
  													 V_REC_SECUENCIAL);
  
  IF V_REC_SECUENCIAL IS NOT NULL THEN
  	P_BUSCAR_RECLAMO(V_REC_SECUENCIAL, :GLOBAL.COD_COMPANIA);
  	--:RESUMEN_RECLAMOS.ESTATUS := PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('EST_SER_APR_SOL_SER',:GLOBAL.COD_COMPANIA);
  END IF;
  /*
  :system.message_level := 25;
  COMMIT;
  :system.message_level := 0;
  */
  MSG_ALERT('Solicitud '||P_SOL_SER_ID||': '||V_TEXTO_MENSAJE, 'I', false);  -- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (29/01/2024). DESCOMENTADO
  
  
END;

-- ====================================================================

-- PROGRAM UNIT: P_INSERTA_EN_RECL_RECHAZO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_INSERTA_EN_RECL_RECHAZO(P_SOL_SER_ID	NUMBER) IS
		
	V_REC_SECUENCIAL RECLAMO.ID%TYPE;
	V_CODIGO_MENSAJE	VARCHAR2(15);
	V_TEXTO_MENSAJE		VARCHAR2(2000);
	
BEGIN
  P_INSERTA_RECLAMO_RECHAZADO(P_SOL_SER_ID,
  													  V_CODIGO_MENSAJE,
  													  V_TEXTO_MENSAJE,
  													  V_REC_SECUENCIAL);
  
  IF V_REC_SECUENCIAL IS NOT NULL THEN
  	P_BUSCAR_RECLAMO(V_REC_SECUENCIAL, :GLOBAL.COD_COMPANIA);
  END IF;
  
  
END;

-- ====================================================================

-- PROGRAM UNIT: P_INSERTA_NUMERO_CUENTA
-- Tipo: Procedure
-- --------------------------------------------------------------------
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

-- ====================================================================

-- PROGRAM UNIT: P_LLENAR_BLOQUE_MOTIVO_RECHAZO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_LLENAR_BLOQUE_MOTIVO_RECHAZO IS
  -- OMARLIS GOMEZ, FOREBRA, (ABRIL,2023). PROGRAMACION DEL BLOQUE
	
	V_MOTIVO_RECHAZO_ID    NUMBER;
	V_DESC_COBERTURA_SALUD VARCHAR2(500);
	V_DESC_MOTIVO_RECHAZO  VARCHAR2(500);	
	V_CONTADOR             NUMBER := 1;
	
	CURSOR CUR_COBERTURA_SOLICITADA IS
	  SELECT ID, COBERTURA_ID 
	    FROM COBERTURA_SOLICITADA 
	  WHERE SOLICITUD_SERVICIO_ID = :RESUMEN_RECLAMOS.ID;
	
	CURSOR CUR_COB_SOL_MOTIVO_RECHAZO(P_COBERTURA_SOLICITADA_ID NUMBER) IS
	  SELECT MOTIVO_RECHAZO_ID 
	    FROM COBERTURA_SOL_MOTIVO_RECHAZO 
	  WHERE COBERTURA_SOLICITADA_ID = P_COBERTURA_SOLICITADA_ID;
	  
	CURSOR CUR_DESC_COBERTURA_SALUD(P_COBERTURA_ID VARCHAR) IS
	  SELECT DESCRIPCION 
	    FROM COBERTURA_SALUD 
	  WHERE CODIGO = P_COBERTURA_ID;
	  
	CURSOR CUR_DESC_MOTIVO_RECHAZO(P_MOTIVO_RECHAZO_ID NUMBER) IS
	  SELECT NOMBRE 
	    FROM MOTIVO_RECHAZO 
	  WHERE ID = P_MOTIVO_RECHAZO_ID;    
	
BEGIN
	set_block_property('MOTIVOS_RECHAZO', INSERT_ALLOWED,PROPERTY_TRUE);
	CLEAR_BLOCK;
	FOR X IN CUR_COBERTURA_SOLICITADA LOOP		
		
		FOR L IN CUR_COB_SOL_MOTIVO_RECHAZO(X.ID) LOOP
		break;
			
			IF V_CONTADOR = 1 THEN
				FIRST_RECORD;
			ELSE	
				NEXT_RECORD;	
			END IF;	
			
			:MOTIVOS_RECHAZO.SOLICITUD_SERVICIO := :RESUMEN_RECLAMOS.ID;		
		  :MOTIVOS_RECHAZO.COBERTURA          := X.COBERTURA_ID;
				
			OPEN  CUR_DESC_COBERTURA_SALUD(X.COBERTURA_ID);
			FETCH CUR_DESC_COBERTURA_SALUD INTO :MOTIVOS_RECHAZO.DESC_COBERTURA;
			CLOSE CUR_DESC_COBERTURA_SALUD;
			
			OPEN  CUR_DESC_MOTIVO_RECHAZO(L.MOTIVO_RECHAZO_ID);
			FETCH CUR_DESC_MOTIVO_RECHAZO INTO :MOTIVOS_RECHAZO.MOTIVO_RECHAZO;
			CLOSE CUR_DESC_MOTIVO_RECHAZO;
						
			V_CONTADOR := V_CONTADOR + 1; 
			
		END LOOP;
		
	END LOOP;	
	
	set_block_property('MOTIVOS_RECHAZO', INSERT_ALLOWED,PROPERTY_FALSE);
	
	GO_ITEM('MOTIVOS_RECHAZO.BTN_VOLVER');
	
END;

-- ====================================================================

-- PROGRAM UNIT: P_LLENA_CARNET_AFI
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_LLENA_CARNET_AFI(P_ASEGURADO IN NUMBER, P_SECUENCIA IN NUMBER) IS
	CURSOR CUR_CARNET IS
		SELECT NUM_PLA
		FROM AFILIADO_PLASTICOS AP
		WHERE AP.ASEGURADO = P_ASEGURADO
		AND AP.SECUENCIA = P_SECUENCIA
		AND AP.FEC_VER =
		    (SELECT MAX(Z.FEC_VER)
		        FROM AFILIADO_PLASTICOS Z
		     WHERE Z.ASEGURADO = AP.ASEGURADO
		        AND Z.SECUENCIA = AP.SECUENCIA
		        AND (TRUNC(Z.FEC_VER) <= TRUNC(SYSDATE) ))
		AND AP.FEC_U_ACT =
		    (SELECT MAX(Z.FEC_U_ACT) D
		        FROM AFILIADO_PLASTICOS Z
		     WHERE Z.ASEGURADO = AP.ASEGURADO
		        AND Z.SECUENCIA = AP.SECUENCIA
		        AND Z.FEC_VER = AP.FEC_VER)
	union all
			SELECT NUM_PLA
		FROM AFILIADO_PLASTICOS_int AP
		WHERE AP.COD_ASE_LOC  = P_ASEGURADO
		  AND nvl(AP.SEC_DEP_LOC,0)  = P_SECUENCIA
		  AND AP.FEC_VER =
		    (SELECT MAX(Z.FEC_VER)
		        FROM AFILIADO_PLASTICOS_int Z
		     WHERE Z.COD_ASE_LOC = AP.COD_ASE_LOC
		        AND nvl(z.SEC_DEP_LOC,0) = nvl(AP.SEC_DEP_LOC,0)
		        AND (TRUNC(Z.FEC_VER) <= TRUNC(SYSDATE)
		         ))
		        AND AP.FEC_U_ACT =
		    (SELECT MAX(Z.FEC_U_ACT) D
		        FROM AFILIADO_PLASTICOS_int Z
		     WHERE Z.COD_ASE_LOC = AP.COD_ASE_LOC
		        AND nvl(AP.SEC_DEP_LOC,0) = nvl(AP.SEC_DEP_LOC,0)
		        AND Z.FEC_VER = AP.FEC_VER);
        		
BEGIN
  OPEN CUR_CARNET;
  FETCH CUR_CARNET INTO :SOLICITUD_SERVICIO.NUMERO_CARNET;
  CLOSE CUR_CARNET;
END;

-- ====================================================================

-- PROGRAM UNIT: P_LLENA_DATOS_DETALLE
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_LLENA_DATOS_DETALLE IS
	CURSOR C_DATOS_DETALLE IS
		SELECT monto, cantidad, comentario
		 FROM SOLICITUD_PAGO_DETALLE
		WHERE SOLICITUD_PAGO_ID = :RADICACION.NUMERO_SOLICITUD
		;
BEGIN
  OPEN C_DATOS_DETALLE;
  FETCH C_DATOS_DETALLE INTO :SOLICITUD_PAGO_DETALLE.MONTO, 
  													 :SOLICITUD_PAGO_DETALLE.CANTIDAD,
  													 :SOLICITUD_PAGO_DETALLE.OBSERVACION;
	CLOSE C_DATOS_DETALLE;
END;

-- ====================================================================

-- PROGRAM UNIT: P_LLENA_TABLAS_TEMPORALES_TABS
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_LLENA_TABLAS_TEMPORALES_TABS IS
BEGIN
  
	declare
		V_NOMBRES						VARCHAR2(500);
		V_APELLIDOS  				VARCHAR2(500);
		V_CED_ACT						VARCHAR2(200);
		V_SEXO							VARCHAR2(100);
		V_ESTATUS						VARCHAR2(100);
		V_CARNET						NUMBER;
		V_ESTADO_PLASTICO		NUMBER;
		V_EDAD							NUMBER;
		V_TIPO							VARCHAR2(100);
		P_ROWS_UPDATED_BP	number;
		P_ROWS_UPDATED_BPD	number;
		P_ROWS_UPDATED_BEL	NUMBER;
		P_ROWS_UPDATED_BEI	NUMBER;
		P_ROWS_UPDATED_BIA	NUMBER;
		P_ROWS_UPDATED_BD		NUMBER;
		P_ROWS_UPDATED_BACP	NUMBER;
		P_ROWS_UPDATED_BT		NUMBER;
		P_ROWS_UPDATED_BC		NUMBER;
		P_ROWS_UPDATED_BL		NUMBER;
	begin
	  
	 REEMBOLSO.PKG_BUSCA_INFO_ASE.P_ELIMINA_TABLAS_TEMPORALES(USER);  -- ELIMINA LA TABLAS TEMPORALES POR USUARIOS
			
	  REEMBOLSO.PKG_BUSCA_INFO_ASE.P_BUSCA_DATOS_ASEG2(:CG$CTRL.ASEGURADO, :CG$CTRL.SECUENCIA_AFI, :CG$CTRL.ASEGURADO,  V_NOMBRES, V_APELLIDOS,       
	  																			V_CED_ACT, 
				                                  V_SEXO,   V_ESTATUS, V_CARNET,  V_ESTADO_PLASTICO, V_EDAD, 
				                                  V_TIPO,   P_ROWS_UPDATED_BIA);  --BUSCA_DATOS_ASEG; 
				                                  
		
		--LCALCANO 1-AGO-23
		IF V_ESTATUS IS NOT NULL THEN
			SET_ITEM_PROPERTY('CG$CTRL.ESTATUS_ASE_POL', VISIBLE, PROPERTY_TRUE);
			:CG$CTRL.ESTATUS_ASE_POL := V_ESTATUS;
		ELSE
			:CG$CTRL.ESTATUS_ASE_POL := NULL;
			SET_ITEM_PROPERTY('CG$CTRL.ESTATUS_ASE_POL', VISIBLE, PROPERTY_TRUE);
		END IF;
		--END
		
		DELETE REEMBOLSO.TEM_PLAN_ASEGURADO WHERE USUARIO = USER;  -- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (05/02/2024). AGREGA DELETE
    DELETE REEMBOLSO.TEM_PLAN_DENTAL    WHERE USUARIO = USER;  -- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (05/02/2024). AGREGA DELETE
  
		PKG_BUSCA_INFO_ASE.P_BUSCA_PLANES(:CG$CTRL.ASEGURADO, :CG$CTRL.SECUENCIA_AFI, P_ROWS_UPDATED_BP); --LLENA_PLANES;
		go_block('PLANES');
		execute_query;
		
		PKG_BUSCA_INFO_ASE.P_BUSCA_PLANES_DENTALES(P_ROWS_UPDATED_BPD);--LLENA_PLANES_DENTALES;
		go_block('PLAN_DENTAL');
		execute_query;
		
		PKG_BUSCA_INFO_ASE.P_BUSCA_ENDOSO_LOCAL(:CG$CTRL.ASEGURADO, :CG$CTRL.SECUENCIA_AFI, P_ROWS_UPDATED_BEL);--LLENA_ENDOSO_LOCAL;
		go_block('ENDOSOS_LOC');
		execute_query;
		
		PKG_BUSCA_INFO_ASE.P_BUSCA_ENDOSO_INT(:CG$CTRL.ASEGURADO, P_ROWS_UPDATED_BEI);  --LLENA_ENDOSO_INT;
		go_block('ENDOSOS_INT');
		execute_query;
		
		IF :ENDOSOS_LOC.POLIZA IS NOT NULL OR :ENDOSOS_INT.POLIZA IS NOT NULL  THEN
			SET_ITEM_PROPERTY('CG$CTRL.TIENE_ENDOSO_LBL', VISIBLE, PROPERTY_TRUE);
		ELSE
			SET_ITEM_PROPERTY('CG$CTRL.TIENE_ENDOSO_LBL', VISIBLE, PROPERTY_FALSE);
		END IF;
		
		PKG_BUSCA_INFO_ASE.P_BUSCA_DEPENDIENTES(:CG$CTRL.ASEGURADO, P_ROWS_UPDATED_BD);--LLENA_DEPENDIENTES;
		go_block('DEPENDIENTE');
		execute_query;
		
		PKG_BUSCA_INFO_ASE.P_BUSCA_AFI_CONTACTO_PREF(V_CARNET, P_ROWS_UPDATED_BACP);--BUSCA_AFI_CONTACTO_PREF;
		go_block('AFILIADO_CONTACTO_PREFERENCIA');
		execute_query;
		
		PKG_BUSCA_INFO_ASE.P_BUSCA_TELEFONOS(:CG$CTRL.ASEGURADO, V_CARNET,P_ROWS_UPDATED_BT);--LLENA_TELEFONOS;
		go_block('TELEFONO');
		execute_query;
		
		PKG_BUSCA_INFO_ASE.P_BUSCA_CORREOS(:CG$CTRL.ASEGURADO, V_CARNET,P_ROWS_UPDATED_BC); --LLENA_CORREOS;
		go_block('CORREO');
		execute_query;
		
		PKG_BUSCA_INFO_ASE.P_BUSCA_LIMITE_MEDICAMENTOS(V_CARNET); 
		go_block('LIMITES_MEDICAMENTOS');
		execute_query;
		
		 --BUSCA_LIMITE_MEDICAMENTOS; --FOREBRA CAMBIO LA BUSQUEDAD POR CARNET Y
		-- PUSO EL AFILIADO QUE ES POOR DONDE SE BUSCA 15082023
		PKG_BUSCA_INFO_ASE.P_BUSCA_LIMITES(:CG$CTRL.ASEGURADO, :CG$CTRL.NO_AFI, P_ROWS_UPDATED_BL); --BUSCA_LIMITES;
		go_block('LIMITES');
		execute_query;
		
	end;
END;

-- ====================================================================

-- PROGRAM UNIT: P_LLENA_TABLA_TMP_PLAN
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_LLENA_TABLA_TMP_PLAN IS
BEGIN
  IF :CG$CTRL.ASEGURADO IS NOT NULL THEN
	  P_INSERTA_PLA_AFI_REEMB_SERV(:CG$CTRL.ASEGURADO, 
	  														 0, 
	  														 :SOLICITUD_SERVICIO.FECHA_SERVICIO, 
	  														 :GLOBAL.COD_COMPANIA);
	END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_MANEJA_HABILITA_COB_ESTATUS
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_MANEJA_HABILITA_COB_ESTATUS(P_HABILITA	VARCHAR2) IS
BEGIN
  IF P_HABILITA = 'S' THEN
  	SET_ITEM_INSTANCE_PROPERTY('SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID', CURRENT_RECORD, UPDATE_ALLOWED, PROPERTY_TRUE);
  	SET_ITEM_INSTANCE_PROPERTY('SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID', CURRENT_RECORD, INSERT_ALLOWED, PROPERTY_TRUE);
  ELSE
  	SET_ITEM_INSTANCE_PROPERTY('SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID', CURRENT_RECORD, UPDATE_ALLOWED, PROPERTY_FALSE);
  	SET_ITEM_INSTANCE_PROPERTY('SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID', CURRENT_RECORD, INSERT_ALLOWED, PROPERTY_FALSE);
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_MON_CONS_TEMP_IN_UP
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_MON_CONS_TEMP_IN_UP(P_TIPO_COBERTURA NUMBER,P_COBERTURA NUMBER,P_MONTO NUMBER)  

IS

CURSOR CUR_EXISTE IS 
SELECT 1 
FROM REEMBOLSO.MONTO_CONSUMIDO_TEMP
WHERE COBERTURA=P_COBERTURA;


CURSOR CUR_BUSCA_SEC IS
SELECT SEQ_FRECUENCIA_CONSUMIDA_TEMP.NEXTVAL
FROM DUAL;

V_SECUENCIA NUMBER;
V_EXISTE NUMBER;

BEGIN
	
	OPEN CUR_BUSCA_SEC;
	FETCH CUR_BUSCA_SEC INTO V_SECUENCIA;
	CLOSE CUR_BUSCA_SEC;
	
	OPEN CUR_EXISTE;
	FETCH CUR_EXISTE INTO V_EXISTE;
  CLOSE CUR_EXISTE;
		 
	IF V_EXISTE=1 THEN 
		 		UPDATE REEMBOLSO.MONTO_CONSUMIDO_TEMP
			  SET TIPO_COBERTURA=P_TIPO_COBERTURA,MONTO_COBERTURA=NVL(P_MONTO,0)
			  WHERE COBERTURA=P_COBERTURA
			  AND   TIPO_COBERTURA=P_TIPO_COBERTURA;
			  	      --PKG_GENERAL.P_INSERTA_ERROR('P_MON_CONS_TEMP_IN_UP', sqlcode, sqlerrm, 'UPDACOBERTURA:'||P_COBERTURA||'TIPO_COBERTURA'||P_TIPO_COBERTURA||'MONTO'||P_MONTO);
	ELSE 
		 	  		INSERT INTO REEMBOLSO.MONTO_CONSUMIDO_TEMP(TIPO_COBERTURA,MONTO_COBERTURA,COBERTURA,ID)  
			      VALUES (P_TIPO_COBERTURA,NVL(P_MONTO,0) ,P_COBERTURA,V_SECUENCIA);
			      		        
			      
			     -- PKG_GENERAL.P_INSERTA_ERROR('P_MON_CONS_TEMP_IN_UP', sqlcode, sqlerrm, 'INSERTCOBERTURA:'||P_COBERTURA||'TIPO_COBERTURA'||P_TIPO_COBERTURA||'MONTO'||P_MONTO);
	END IF;

	

	
	
  
END;

-- ====================================================================

-- PROGRAM UNIT: P_RECONSULTA_ENDOSOS_AFILIADO
-- Tipo: Procedure
-- --------------------------------------------------------------------
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

-- ====================================================================

-- PROGRAM UNIT: P_RESTRICCIONES_SERV
-- Tipo: Procedure
-- --------------------------------------------------------------------
--Tommy Pereyra Enfoco 11/11/2024
PROCEDURE p_restricciones_serv(p_mensaje out varchar2) IS
  cursor cur_tip_pla is
  select tip_pla 
  from plan
  where codigo = :resumen_reclamos.plan;

  cursor cur_spool is --(vtipplan number, vplan number, vaseg number, vdepe number, vser number, vtipcob number, vcob number, vcia number) is
	select estatus_spool, accion, c.descripcion accion_des, tipo_nivel, a.causa_accion, comentario
	from REEMBOLSO.REEMB_RESTRIC_NIV_SPOOL a, accion_a_tomar c
  where numero_solicitud = :radicacion.numero_solicitud
  and a.accion = c.codigo
  and estatus_spool != F_OBTEN_PARAMETRO_SEUS('ST_APROB_SPOOL_REEMB'); --1-Aprobado
	/*where (tipo_plan = vtipplan or tipo_plan = 0)
	and plan = vplan
	and asegurado = vaseg
	and dependiente = vdepe
	and servicio = vser
	and tipo_cobertura = vtipcob
	and cobertura = vcob
	and compania = vcia
	and a.accion = c.codigo
  and a.fecha_spool = (select max(b.fecha_spool) from REEMB_RESTRIC_NIV_SPOOL b
                        where a.tipo_nivel = b.tipo_nivel
                        and a.tipo_plan = b.tipo_plan
                        and a.plan = b.plan
                        and a.asegurado = b.asegurado
                        and a.dependiente = b.dependiente
                        and a.servicio = b.servicio
                        and a.diagnostico = b.diagnostico
                        and a.tipo_cobertura = b.tipo_cobertura
                        and a.cobertura = b.cobertura
                        and a.compania = b.compania);	*/

  cursor cur_cob is
  select cobertura_id
  from cobertura_solicitada
  where solicitud_servicio_id = :resumen_reclamos.id;

  vspool cur_spool%ROWTYPE;
  v_tip_pla number;	
  vAse number := to_number(SUBSTR(:resumen_reclamos.CODIGO_AFILIADO,1,7));
  vDep number := to_number(SUBSTR( :resumen_reclamos.CODIGO_AFILIADO,8,3));
  v_tip_cob number;
  v_cob number;
  v_mensaje varchar2(1000);

begin	
  open cur_tip_pla;
  fetch cur_tip_pla into v_tip_pla;
  close cur_tip_pla;

  open cur_cob;
  fetch cur_cob into v_cob;
  close cur_cob;
  		  
  v_tip_cob := INNOVACORE.PKG_INNOVA.FDP_DET_TIPO_COB(:resumen_reclamos.TIPO_SERVICIO, v_cob);

   open cur_spool;--(v_tip_pla, :resumen_reclamos.plan, vAse, vDep, :resumen_reclamos.tipo_servicio, v_tip_cob, v_cob, :GLOBAL.COD_COMPANIA);
   fetch cur_spool into vspool;
     if cur_spool%found then
   	   	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EDITAR_MON', ENABLED, PROPERTY_FALSE);
   	   	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_COBR_INDE', ENABLED, PROPERTY_FALSE);
   	   	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EXCEPCION_NEGOCIO', ENABLED, PROPERTY_FALSE);
   	   	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_TARIFA_INCORECTA', ENABLED, PROPERTY_FALSE);
   	   	SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_NEGOCIACION_PRESTADOR', ENABLED, PROPERTY_FALSE);             

        if vspool.accion != F_OBTEN_PARAMETRO_SEUS('APROBAR_REEMB') --1    
           then         				   	 				   	 
			     if vspool.tipo_nivel = F_OBTEN_PARAMETRO_SEUS('AS_RESTRINCIONES') then
		 			    p_mensaje := F_OBTEN_PARAMETRO_SEUS('MSG_REST_REEMB_ASE')||' '||F_OBTEN_PARAMETRO_SEUS('ACCION')||' '||vspool.accion_des
		 					                                  ||' '||F_OBTEN_PARAMETRO_SEUS('CAUSA_ACCION')||' '||vspool.causa_accion
		 					                                  ||' '||F_OBTEN_PARAMETRO_SEUS('COMEN_ACCION')||' '||vspool.comentario;				   	 				   	 
			     elsif vspool.tipo_nivel = F_OBTEN_PARAMETRO_SEUS('GE_RESTRINCIONES') then
		 			    p_mensaje := F_OBTEN_PARAMETRO_SEUS('MSG_REST_REEMB_COB')||' '||F_OBTEN_PARAMETRO_SEUS('ACCION')||' '||vspool.accion_des
		 					                                  ||' '||F_OBTEN_PARAMETRO_SEUS('CAUSA_ACCION')||' '||vspool.causa_accion
		 					                                  ||' '||F_OBTEN_PARAMETRO_SEUS('COMEN_ACCION')||' '||vspool.comentario;				   	 				   	 
			     elsif vspool.tipo_nivel = F_OBTEN_PARAMETRO_SEUS('PL_RESTRINCIONES') then
		 			    p_mensaje := F_OBTEN_PARAMETRO_SEUS('MSG_REST_REEMB_PLA')||' '||F_OBTEN_PARAMETRO_SEUS('ACCION')||' '||vspool.accion_des
		 					                                  ||' '||F_OBTEN_PARAMETRO_SEUS('CAUSA_ACCION')||' '||vspool.causa_accion
		 					                                  ||' '||F_OBTEN_PARAMETRO_SEUS('COMEN_ACCION')||' '||vspool.comentario;				   	 				   	 
		       end if; --p_tipo_nivel
        end if; --vspool.accion
     end if;  --cur_spool%found 
   close cur_spool;                
END;

-- ====================================================================

-- PROGRAM UNIT: P_ROLLBACK_FALLECIDO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_ROLLBACK_FALLECIDO(P_CAMPO VARCHAR2) IS
-- Encofo(GM) 23/10/2024.- Proyecto Cobertura Exgratia 
  v_selec_n  VARCHAR2(5) := F_OBTEN_PARAMETRO_SEUS('P_SELECCION_N', :GLOBAL.COD_COMPANIA);
  v_selec_s  VARCHAR2(5) := F_OBTEN_PARAMETRO_SEUS('P_SELECCION_S', :GLOBAL.COD_COMPANIA);
BEGIN
  IF NAME_IN(P_CAMPO) = v_selec_s THEN
     COPY(v_selec_n, P_CAMPO);
  ELSE
     Copy(v_selec_s, P_CAMPO);
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_SPOOL_EXGRATIA
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_SPOOL_EXGRATIA IS
  -- Proyecto Exgratia.- Enfoco 01/09/2024.
  -- Proceso que valida si la cobertura es de Ex-Gracia para enviar al spool y asignar el estatus de Pendiete Spool a la solicitud
  v_cob_exgratia  VARCHAR2(256) := F_OBTEN_PARAMETRO_SEUS('COB_EXGRATIA', :GLOBAL.COD_COMPANIA);
  v_row_exg       SPOOL_EXGRATIA%ROWTYPE;
  v_error         NUMBER(2);
  v_msg_id        NUMBER(10) := F_OBTEN_PARAMETRO_SEUS('SPOOL_EXGRATIA.MSG2', :GLOBAL.COD_COMPANIA);
  v_est_sp_pend   NUMBER(5)  := F_OBTEN_PARAMETRO_SEUS('SPOOL_EXGRATIA.EST_P', :GLOBAL.COD_COMPANIA);
  v_est_sl_pend   NUMBER(5)  := F_OBTEN_PARAMETRO_SEUS('SOL_SER_REEMB.EST_PE', :GLOBAL.COD_COMPANIA);
BEGIN
  IF INSTR(v_cob_exgratia,'*'||:SOLICITUD_SERVICIO_DETALLE.COBERTURA||'*') > 0 THEN
     /*v_row_exg.No_solicitud   := :RADICACION.NUMERO_SOLICITUD;
     v_row_exg.NO_SOLICITUD_SERVICIO := :SOLICITUD_SERVICIO.ID;
     v_row_exg.Compania       := :GLOBAL.COD_COMPANIA;
     v_row_exg.Ramo           := :SOLICITUD_SERVICIO.RAMO;
     v_row_exg.Sec_pol        := :SOLICITUD_SERVICIO.SECUENCIAL;
     v_row_exg.Asegurado      := :CG$CTRL.ASEGURADO;
     v_row_exg.Dependiente    := :CG$CTRL.SECUENCIA_AFI;
     v_row_exg.Provedor       := :SOLICITUD_SERVICIO_DETALLE.PROVEEDOR_ID;
     v_row_exg.Usuario_aprob  := :SOLICITUD_SERVICIO_DETALLE.USU_APROB;
     v_row_exg.Comentario     := :SOLICITUD_SERVICIO_DETALLE.COMENT_SOL_SPOOL;
     v_row_exg.Cobertura      := :SOLICITUD_SERVICIO_DETALLE.COBERTURA;
     v_row_exg.Tip_cob        := :SOLICITUD_SERVICIO_DETALLE.COBERTURA_TIPO;
     v_row_exg.Mon_rec        := :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO;
     v_row_exg.Mon_pag        := :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR;
     v_row_exg.Estatus        := v_est_sp_pend; -- Estatus Spool Pendiente
     v_row_exg.Usuario        := USER;
     v_row_exg.Fec_tra        := SYSDATE;*/
     --
     P_INSERT_SPOOL_EXGRATIA(:RADICACION.NUMERO_SOLICITUD,
												     :SOLICITUD_SERVICIO.ID,
												     :GLOBAL.COD_COMPANIA,
												     :SOLICITUD_SERVICIO.RAMO,
												     :SOLICITUD_SERVICIO.SECUENCIAL,
												     :CG$CTRL.ASEGURADO,
												     :CG$CTRL.SECUENCIA_AFI,
												     :SOLICITUD_SERVICIO_DETALLE.PROVEEDOR_ID,
												     :SOLICITUD_SERVICIO_DETALLE.USU_APROB,
												     :SOLICITUD_SERVICIO_DETALLE.COMENT_SOL_SPOOL,
												     :SOLICITUD_SERVICIO_DETALLE.COBERTURA,
												     :SOLICITUD_SERVICIO_DETALLE.COBERTURA_TIPO,
												     :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO,
												     :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR,
												     v_est_sl_pend, -- Estatus Spool Pendiente
                             v_error);
     --
     IF NVL(v_error, 0) > 0 THEN
        p_imprime_mensaje(v_msg_id, null);
     ELSE
     	  :SOLICITUD_SERVICIO.ESTATUS := v_est_sl_pend; -- Estatus Solicitud Pendiente Spool
     END IF;
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_SPOOL_REEMB_POLIZA_SUSP
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_SPOOL_REEMB_POLIZA_SUSP IS
  -- Proyecto Exgratia.- Enfoco 01/09/2024.
  -- Proceso que valida si la cobertura es de Ex-Gracia para enviar al spool y asignar el estatus de Pendiete Spool a la solicitud
  v_dummy         NUMBER(2) := 0;
  v_found         BOOLEAN;
  v_respuesta     NUMBER(2);
  v_row_exg       REEMBOLSO.SPOOL_REEMB_POLIZAS_SUSP%ROWTYPE;
  --
  v_msg_id        NUMBER(10)  := F_OBTEN_PARAMETRO_SEUS('REEMB_PAGO.MSG1', :GLOBAL.COD_COMPANIA);
  v_tip_ver_susp  VARCHAR2(2) := F_OBTEN_PARAMETRO_SEUS('P_TIP_VER_POL_S', :GLOBAL.COD_COMPANIA);
  v_est_sol_p     NUMBER(5)   := F_OBTEN_PARAMETRO_SEUS('SOL_SER_REEM.EST_PAC', :GLOBAL.COD_COMPANIA); -- Pendiente Autoriz Cobros
  --
  Cursor cur_spool_exgratia is 
    Select 1
      from Spool_exgratia 
     where no_solicitud = :RADICACION.NUMERO_SOLICITUD
       and no_solicitud_servicio =  :SOLICITUD_SERVICIO.ID;
  --
  Cursor cur_pol_susp is
    Select 1
      From Poliza P
     Where P.Compania   = :GLOBAL.COD_COMPANIA
       And P.Ramo       = :SOLICITUD_SERVICIO.RAMO
       And P.Secuencial = :SOLICITUD_SERVICIO.SECUENCIAL
       And P.Tip_ver    = v_tip_ver_susp
       And P.Fec_ver = (Select max(f.fec_ver)
                          from poliza f
                         where f.compania   = p.compania
                           and f.ramo       = p.ramo
                           and f.secuencial = p.secuencial
                           and f.fec_ver   <= trunc(:SOLICITUD_SERVICIO.FECHA_SERVICIO));
BEGIN
  OPEN cur_spool_exgratia;
  FETCH cur_spool_exgratia INTO v_dummy;
  v_found := cur_spool_exgratia%FOUND;
  CLOSE cur_spool_exgratia;
  --
  IF NOT(v_found) THEN 
     v_dummy := 0;
     OPEN cur_pol_susp;
     FETCH cur_pol_susp INTO v_dummy;
     CLOSE cur_pol_susp;
     --
     IF v_dummy > 0 THEN
        /*v_row_exg.No_solicitud := :RADICACION.NUMERO_SOLICITUD;
        v_row_exg.No_solicitud_servicio := :SOLICITUD_SERVICIO.ID;
        v_row_exg.Fec_ser      := :SOLICITUD_SERVICIO.FECHA_SERVICIO;
        v_row_exg.Compania     := :GLOBAL.COD_COMPANIA;
        v_row_exg.Ramo         := :SOLICITUD_SERVICIO.RAMO;
        v_row_exg.Sec_pol      := :SOLICITUD_SERVICIO.SECUENCIAL;
        v_row_exg.Asegurado    := :CG$CTRL.ASEGURADO;
        v_row_exg.Dependiente  := :CG$CTRL.SECUENCIA_AFI;
        v_row_exg.Usuario      := USER;
        v_row_exg.Fec_tra      := SYSDATE;*/
        --
        --REEMBOLSO.P_INSERT_SPOOL_POL_SUSP_REEMB(v_row_exg, v_respuesta);
        REEMBOLSO.P_INSERT_SPOOL_POL_SUSP_REEMB(:RADICACION.NUMERO_SOLICITUD,
        																				:SOLICITUD_SERVICIO.ID,
																				        :SOLICITUD_SERVICIO.FECHA_SERVICIO,
																				        :GLOBAL.COD_COMPANIA,
																				        :SOLICITUD_SERVICIO.RAMO,
																				        :SOLICITUD_SERVICIO.SECUENCIAL,
																				        :CG$CTRL.ASEGURADO,
																				        :CG$CTRL.SECUENCIA_AFI,
                                                v_respuesta);
        --
        IF NVL(v_respuesta,0) > 0 THEN
           p_imprime_mensaje(v_msg_id, null);
        ELSE
        	 :SOLICITUD_SERVICIO.ESTATUS := v_est_sol_p; -- Estatus Solicitud Pendiente autorizacion cobros
        END IF;
     END IF;
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDARCOBERTURASAUTOMATICAS
-- Tipo: Procedure
-- --------------------------------------------------------------------
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

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_ACT_ESTATUS_COB
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_VALIDA_ACT_ESTATUS_COB IS
BEGIN
  if nvl(:solicitud_servicio_detalle.RECHAZO_AUTOMATICO,'N') = 'S' then
		P_MANEJA_HABILITA_COB_ESTATUS('N');
	ELSIF nvl(:solicitud_servicio_detalle.RECHAZO_AUTOMATICO,'N') = 'N' THEN
		IF :SOLICITUD_SERVICIO_DETALLE.ID IS NULL THEN
			P_MANEJA_HABILITA_COB_ESTATUS('S');
		ELSIF :SOLICITUD_SERVICIO_DETALLE.ID IS NOT NULL THEN
			IF NVL(:SOLICITUD_SERVICIO_DETALLE.MONTO_FREC_EDITADO,'N') = 'S' OR NVL(:SOLICITUD_SERVICIO_DETALLE.HUBO_EXCEPCION,'N') = 'S' THEN
				P_MANEJA_HABILITA_COB_ESTATUS('S');
			ELSE
				P_MANEJA_HABILITA_COB_ESTATUS('N');
			END IF;
		END IF;
	end if;
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_ASEGURADO_BAN
-- Tipo: Procedure
-- --------------------------------------------------------------------
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

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_ASEGURADO_BAN_V2
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_VALIDA_ASEGURADO_BAN_V2 IS  
-- Enfoco(GM) 18/11/2024.- Proyecto Lista Negra. se duplico el proceso para incluir modificaciones varias
  v_baneado            NUMBER;
  v_nombre_completo    VARCHAR2(2000);
  v_beneficiario_id    VARCHAR2(200);
  v_estado_blacklist   NUMBER;
  v_motivo_adj         VARCHAR2(3000);
  v_fec_tra_bloq       DATE; 
  v_usuario_bloq       VARCHAR2(30);
  --
  CURSOR CUR_BLACKLIST IS
    SELECT BANEADO, NOMBRE_COMPLETO, ESTADO, CODIGO_ASEGURADO, FEC_TRA, USUARIO
      FROM BLACKLIST_ASEGURADOS
     WHERE CODIGO_ASEGURADO = :CG$CTRL.NO_AFI;
  --
  CURSOR CUR_POL_VIG IS 
    SELECT COMPANIA, RAMO, SECUENCIAL, PLAN
      FROM ASE_POL01_V A, ESTATUS B
     WHERE B.CODIGO    = A.ESTATUS
       AND B.VAL_LOG   = 'T'
       AND A.ASEGURADO = :CG$CTRL.ASEGURADO
       AND A.COMPANIA  = :GLOBAL.COD_COMPANIA
     ORDER BY FEC_VER DESC;
  --
  ROW_POL_VIG  CUR_POL_VIG%ROWTYPE;
BEGIN
  OPEN CUR_BLACKLIST;
  FETCH CUR_BLACKLIST INTO v_baneado, v_nombre_completo, v_estado_blacklist, v_beneficiario_id, v_fec_tra_bloq, v_usuario_bloq;
  CLOSE CUR_BLACKLIST;
  --
  IF NVL(v_baneado,0) = :FRMVAR.BANEADO THEN     
     --
     P_BUSCA_MOTIVO_BLOQUEO_ASE(:FRMVAR.STR_ASEGURADO, --'ASEGURADO',
                                :CG$CTRL.ASEGURADO,
                                :CG$CTRL.SECUENCIA_AFI);
     --
     IF :MSG_BLOQUEO.MOTIVO IS NOT NULL THEN
     	  ROW_POL_VIG := NULL;
     	  OPEN CUR_POL_VIG;
     	  FETCH CUR_POL_VIG INTO ROW_POL_VIG;
     	  CLOSE CUR_POL_VIG;
        --
     	  PKG_MOT_BLOQUEO.SET_VARIABLE(ROW_POL_VIG.COMPANIA, 
     	                               ROW_POL_VIG.RAMO, 
     	                               ROW_POL_VIG.SECUENCIAL);
     	  -- Enfoco 03/02/2025.- Mejoras Notificacion
        PKG_MOT_BLOQUEO.P_ENVIA_NOTIFICACION_BLOQUEO(:GLOBAL.COD_COMPANIA, 
                                                     :FRMVAR.STR_ASEGURADO, --'ASEGURADO',
                                                     :RADICACION.NUMERO_SOLICITUD,
                                                     :CG$CTRL.NO_AFI,
                                                     ROW_POL_VIG.PLAN,
                                                     v_usuario_bloq, 
                                                     v_fec_tra_bloq, 
                                                     :BUSCA_SERVICIO.TIPO_PRESTADOR_ADD,
                                                     :SOLICITUD_SERVICIO.PROVEEDOR_ID,
                                                     NULL, --P_DIAGNOSTICO
                                                     NULL, --P_SERVICIO
                                                     NULL, --P_TIP_COB
                                                     NULL);-- P_COBERTURA
     END IF;
     --
     DECLARE
       V_DSP_ACT VARCHAR2(512) := 'El usuario '||user||' intenta registrarle un reembolso al afiliado bloqueado '||
                                  V_NOMBRE_COMPLETO||', '||'('||V_BENEFICIARIO_ID||')'||', '||'en la fecha '||SYSDATE;
     BEGIN
       -- SE INSERTA EN EL HISTORICO TAMBIEN 
       INSERT INTO REEMBOLSO.HISTORICO_FRAUDES
         (FECHA,  DESCRIPCION_ACTIVIDAD,  FEC_TRA, 
          USUARIO, ESTADO)
       VALUES
         (TRUNC(SYSDATE), V_DSP_ACT, SYSDATE,
          USER, V_ESTADO_BLACKLIST);
     EXCEPTION WHEN OTHERS THEN
       DBAPER.PKG_GENERAL.P_INSERTA_ERROR('REEMB_PAGO.FMB/PU/P_VALIDA_ASEGURADO_BAN',SQLCODE, SUBSTR(SQLERRM, 1, 500),
                                          'ERROR CREANDO HISTORICO_FRAUDES-EN-P_VALIDA_ASEGURADO_BAN: '||SQLERRM);
     END;
     --
     :SYSTEM.MESSAGE_LEVEL := '25';
     COMMIT;  
     :SYSTEM.MESSAGE_LEVEL := '0';
     --           
     RAISE FORM_TRIGGER_FAILURE;
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_ASEGURADO_PLAN_VIG
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_VALIDA_ASEGURADO_PLAN_VIG IS
	V_EXISTE	NUMBER;
	vAse			NUMBER;
	vDep			NUMBER;
	
	CURSOR C_AFI_VIG IS
		SELECT 1
		  FROM ASEGURADO A, ASE_POL AP
		 WHERE     AP.ASEGURADO = vAse
		       AND AP.COMPANIA = :SOLICITUD_SERVICIO.COMPANIA
		       AND AP.RAMO = :SOLICITUD_SERVICIO.RAMO
		       AND AP.SECUENCIAL = :SOLICITUD_SERVICIO.SECUENCIAL
		       AND AP.PLAN = :SOLICITUD_SERVICIO.CODIGO_PLAN
		       AND AP.FEC_VER =
		              (SELECT MAX (A1.FEC_VER)
		                 FROM ASE_POL A1
		                WHERE     A1.COMPANIA = AP.COMPANIA
		                      AND A1.RAMO = AP.RAMO
		                      AND A1.SECUENCIAL = AP.SECUENCIAL
		                      AND A1.ASEGURADO = AP.ASEGURADO
		                      AND A1.FEC_VER <= :SOLICITUD_SERVICIO.FECHA_SERVICIO)
           AND AP.FEC_TRA =
                  (SELECT MAX (A1.FEC_TRA)
                     FROM ASE_POL A1
                    WHERE     A1.COMPANIA = AP.COMPANIA
                          AND A1.RAMO = AP.RAMO
                          AND A1.SECUENCIAL = AP.SECUENCIAL
                          AND A1.ASEGURADO = AP.ASEGURADO
                          AND A1.FEC_VER = AP.FEC_VER)
		       AND AP.ESTATUS IN (SELECT CODIGO
		                            FROM ESTATUS
		                           WHERE TIPO = 'ASE_POL' AND VAL_LOG = 'T')
		       AND A.CODIGO = AP.ASEGURADO
		       AND AP.ASEGURADO = vAse
		       AND vDep = 0
		UNION ALL
		SELECT 1
		  FROM DEPENDIENTE D, DEP_POL AP
		 WHERE     AP.ASEGURADO = vAse
		       AND AP.COMPANIA = :SOLICITUD_SERVICIO.COMPANIA
		       AND AP.RAMO = :SOLICITUD_SERVICIO.RAMO
		       AND AP.SECUENCIAL = :SOLICITUD_SERVICIO.SECUENCIAL
		       AND AP.PLAN = :SOLICITUD_SERVICIO.CODIGO_PLAN
		       AND AP.FEC_VER =
		              (SELECT MAX (A1.FEC_VER)
		                 FROM DEP_POL A1
		                WHERE     A1.COMPANIA = AP.COMPANIA
		                      AND A1.RAMO = AP.RAMO
		                      AND A1.SECUENCIAL = AP.SECUENCIAL
		                      AND A1.ASEGURADO = AP.ASEGURADO
		                      AND A1.DEPENDIENTE = AP.DEPENDIENTE
		                      AND A1.FEC_VER <= :SOLICITUD_SERVICIO.FECHA_SERVICIO)
           AND AP.FEC_TRA =
                  (SELECT MAX (A1.FEC_TRA)
                     FROM DEP_POL A1
                    WHERE     A1.COMPANIA = AP.COMPANIA
                          AND A1.RAMO = AP.RAMO
                          AND A1.SECUENCIAL = AP.SECUENCIAL
                          AND A1.ASEGURADO = AP.ASEGURADO
                          AND A1.DEPENDIENTE = AP.DEPENDIENTE
                          AND A1.FEC_VER = AP.FEC_VER)
		       AND AP.ESTATUS IN (SELECT CODIGO
		                            FROM ESTATUS
		                           WHERE TIPO = 'DEP_POL' AND VAL_LOG = 'T')
		       AND D.ASEGURADO = AP.ASEGURADO
		       AND D.SECUENCIA = AP.DEPENDIENTE
		       AND D.ASEGURADO = vAse
		       AND D.SECUENCIA = vDep
		       ;
BEGIN
	 
	IF NVL(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,:CG$CTRL.NO_AFI) IS NOT NULL
		AND :SOLICITUD_SERVICIO.FECHA_SERVICIO IS NOT NULL
		AND :SOLICITUD_SERVICIO.CODIGO_PLAN IS NOT NULL
		AND :SOLICITUD_SERVICIO.CODIGO_AFILIADO IS NOT NULL
		AND :SOLICITUD_SERVICIO.COMPANIA IS NOT NULL
		AND :SOLICITUD_SERVICIO.RAMO IS NOT NULL
		AND :SOLICITUD_SERVICIO.SECUENCIAL IS NOT NULL
	THEN
		vAse:= to_number(SUBSTR(NVL(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,:CG$CTRL.NO_AFI),1,7));
		vDep:= to_number(SUBSTR(NVL(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,:CG$CTRL.NO_AFI),8,3));
	
	  OPEN C_AFI_VIG;
	  FETCH C_AFI_VIG INTO V_EXISTE;
	  IF C_AFI_VIG%NOTFOUND THEN
			p_imprime_mensaje(27, NULL);
	  END IF;
	  CLOSE C_AFI_VIG;
	END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_BLACKLIST_ASEGURADO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_VALIDA_BLACKLIST_ASEGURADO IS
	/*CREADO POR: OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (03/02/2024)*/
		
	V_BANEADO NUMBER;
	
	CURSOR CUR_BLACKLIST IS
		SELECT BANEADO
			FROM BLACKLIST_ASEGURADOS
		WHERE CODIGO_ASEGURADO = :SOLICITUD_SERVICIO.CODIGO_AFILIADO;
		
BEGIN
  
	OPEN  CUR_BLACKLIST;
  FETCH CUR_BLACKLIST INTO V_BANEADO;
  CLOSE CUR_BLACKLIST;
  
  IF NVL(V_BANEADO,0) = 1 THEN
		MSG_ALERT('Las reclamaciones de reembolsos de este afiliado no pueden ser editadas su Monto a Pagar.','E',TRUE);			  						
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_COB_TIPO_BLOQUEADO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_VALIDA_COB_TIPO_BLOQUEADO IS
	-- Enfoco 23/11/2024.- Proyecto Lista Negra
  v_estatus      NUMBER(2);
	v_tip_cob      NUMBER(5);
	v_tip_ser_alto_costo  NUMBER := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('ALTO_COSTO',:GLOBAL.COD_COMPANIA);
	v_tip_ser_alto_renal  NUMBER := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('SERVICIO_RENAL',:GLOBAL.COD_COMPANIA);
	v_usuario_bloq  VARCHAR2(30); 
  v_fec_tra_bloq  DATE;
	--
	Cursor cur_baneado_tc is
    Select P.baneado, P.usuario, P.fec_tra
      from REEMBOLSO.BLACKLIST_ASE_PERTINENCIA P
     where P.codigo_asegurado = :SOLICITUD_SERVICIO.CODIGO_AFILIADO
       and P.Tipo_bloqueo     = :FRMVAR.STR_TIP_COB
       and P.tip_cob          = v_tip_cob--:SOLICITUD_SERVICIO_DETALLE.COBERTURA_TIPO
       and P.servicio is null;
	--
	Cursor cur_baneado_cob is
    Select P.baneado, P.usuario, P.fec_tra
      from REEMBOLSO.BLACKLIST_ASE_PERTINENCIA P
     where P.codigo_asegurado = :SOLICITUD_SERVICIO.CODIGO_AFILIADO
       and P.Tipo_bloqueo     = :FRMVAR.STR_COBERTURA
       and P.servicio         = :SOLICITUD_SERVICIO.TIPO_SERVICIO
       and P.tip_cob          = v_tip_cob --:SOLICITUD_SERVICIO_DETALLE.COBERTURA_TIPO
       and P.cobertura        = :SOLICITUD_SERVICIO_DETALLE.COBERTURA;
BEGIN
  -- Se utiliza la misma funcionalidad que esta en el proceso REEMBOLSO.P_VALIDARCOBERTURASAUT_FORMA
  If :SOLICITUD_SERVICIO.TIPO_SERVICIO IN (v_tip_ser_alto_costo, v_tip_ser_alto_renal) THEN
     v_tip_cob := :SOLICITUD_SERVICIO.SUB_GRUPO_SERVICIO;
  Else
     v_tip_cob := INNOVACORE.PKG_INNOVA.FDP_DET_TIPO_COB(:SOLICITUD_SERVICIO.TIPO_SERVICIO,
                                                         :SOLICITUD_SERVICIO_DETALLE.COBERTURA);
  End if;
  --v_tip_cob := :SOLICITUD_SERVICIO_DETALLE.COBERTURA_TIPO;
  --
	v_estatus := 0;
	Open cur_baneado_tc;
  Fetch cur_baneado_tc into v_estatus, v_usuario_bloq, v_fec_tra_bloq;
  Close cur_baneado_tc;
  --
  If v_estatus = :FRMVAR.BANEADO then
     :SOLICITUD_SERVICIO_DETALLE.FRECUENCIA    := 1;
     :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO := 0.1;
     --
     P_BUSCA_MOTIVO_BLOQUEO_PERTIN(:FRMVAR.STR_TIP_COB,
                                   :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                   NULL, --P_DIAGNOSTICO 
                                   NULL, --P_SERVICIO
                                   v_tip_cob, --P_TIP_COB
                                   NULL); --P_COBERTURA
     --
     PKG_MOT_BLOQUEO.SET_VARIABLE(:SOLICITUD_SERVICIO.COMPANIA,
     	                            :SOLICITUD_SERVICIO.RAMO, 
     	                            :SOLICITUD_SERVICIO.SECUENCIAL);
     -- Enfoco 03/02/2025.- Mejoras Notificacion
     PKG_MOT_BLOQUEO.P_ENVIA_NOTIFICACION_BLOQUEO(:GLOBAL.COD_COMPANIA, 
                                                  :FRMVAR.STR_TIP_COB,
                                                  :RADICACION.NUMERO_SOLICITUD,
                                                  :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                                  :SOLICITUD_SERVICIO.CODIGO_PLAN,
                                                  v_usuario_bloq, 
                                                  v_fec_tra_bloq, 
                                                  :BUSCA_SERVICIO.TIPO_PRESTADOR_ADD,
                                                  :SOLICITUD_SERVICIO.PROVEEDOR_ID,
                                                  NULL, --P_DIAGNOSTICO
                                                  NULL, --P_SERVICIO
                                                  v_tip_cob, --P_TIP_COB
                                                  NULL);-- P_COBERTURA
     RAISE FORM_TRIGGER_FAILURE;
  Else
     Open cur_baneado_cob;
     Fetch cur_baneado_cob into v_estatus, v_usuario_bloq, v_fec_tra_bloq;
     Close cur_baneado_cob;
     --
     If v_estatus = :FRMVAR.BANEADO then
     	  :SOLICITUD_SERVICIO_DETALLE.FRECUENCIA    := 1;
     	  :SOLICITUD_SERVICIO_DETALLE.MONTO_RECLAMO := 0.1;
     	  --
        P_BUSCA_MOTIVO_BLOQUEO_PERTIN(:FRMVAR.STR_COBERTURA,
                                      :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                      NULL,      --P_DIAGNOSTICO 
                                      :SOLICITUD_SERVICIO.TIPO_SERVICIO,
                                      v_tip_cob, --P_TIP_COB
                                      :SOLICITUD_SERVICIO_DETALLE.COBERTURA);
        -- Envia notificacion de email.
        PKG_MOT_BLOQUEO.SET_VARIABLE(:SOLICITUD_SERVICIO.COMPANIA,
     	                               :SOLICITUD_SERVICIO.RAMO, 
     	                               :SOLICITUD_SERVICIO.SECUENCIAL);
        -- Enfoco 03/02/2025.- Mejoras Notificacion
        PKG_MOT_BLOQUEO.P_ENVIA_NOTIFICACION_BLOQUEO(:GLOBAL.COD_COMPANIA, 
                                                     :FRMVAR.STR_COBERTURA,
                                                     :RADICACION.NUMERO_SOLICITUD,
                                                     :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                                     :SOLICITUD_SERVICIO.CODIGO_PLAN,
                                                     v_usuario_bloq, 
                                                     v_fec_tra_bloq, 
                                                     :BUSCA_SERVICIO.TIPO_PRESTADOR_ADD,
                                                     :SOLICITUD_SERVICIO.PROVEEDOR_ID,
                                                     NULL, --P_DIAGNOSTICO
                                                     :SOLICITUD_SERVICIO.TIPO_SERVICIO,
                                                     v_tip_cob, --P_TIP_COB
                                                     :SOLICITUD_SERVICIO_DETALLE.COBERTURA);
        RAISE FORM_TRIGGER_FAILURE;
     End if;
  End if;
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_COB_VACUNA
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_VALIDA_COB_VACUNA IS
	CURSOR C_EDAD(X_ASE NUMBER, X_DEP NUMBER) IS
		SELECT EDAD
		FROM ASE_DEP02_V
		WHERE ASEGURADO = X_ASE
		AND SECUENCIA = X_DEP;
		
	VASE    		NUMBER;
	VDEP    		NUMBER;	
	V_EDAD_AFI	NUMBER;
	V_COB_INFLU	VARCHAR2(100) := PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('COD_COB_VACUNA_INFLU',:GLOBAL.COD_COMPANIA);
	V_EDAD_MAX	NUMBER	:=	TO_NUMBER(PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('EDAD_MAX_VACU_INFLU',:GLOBAL.COD_COMPANIA));
		
BEGIN
	IF :SOLICITUD_SERVICIO_DETALLE.COBERTURA = V_COB_INFLU THEN
		VASE:= TO_NUMBER(SUBSTR(NVL(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,:CG$CTRL.NO_AFI),1,7));
		VDEP:= TO_NUMBER(SUBSTR(NVL(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,:CG$CTRL.NO_AFI),8,3));
	
	  OPEN C_EDAD(VASE,VDEP);
	  FETCH C_EDAD INTO V_EDAD_AFI;
	  CLOSE C_EDAD;
	  
	  IF V_EDAD_AFI > V_EDAD_MAX THEN
			:SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID := PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('EST_REC_COB_SOL_REMB',:GLOBAL.COD_COMPANIA);
			:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR:=0;
			:SOLICITUD_SERVICIO_DETALLE.MONTO_COASEGURO:=0;
			:SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA :=:SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL;	
			--P_MANEJA_HABILITA_COB_ESTATUS('N');
			
			MSG_ALERT('La cobertura no corresponde con la edad '||V_EDAD_AFI||' del Asegurado. Este servicio aplica para un rango de 0 a '||V_EDAD_MAX||' años.','E',false);
		END IF; 	
	END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_DATOS_REEMBOLSO
-- Tipo: Procedure
-- --------------------------------------------------------------------
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

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_DIAGNOSTICO_BLOQUEADO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_VALIDA_DIAGNOSTICO_BLOQUEADO IS
-- Enfoco 23/11/2024.- Proyecto Lista Negra
  v_baneado       NUMBER(2) := 0;
  v_fec_tra_bloq  DATE;
  v_usuario_bloq  VARCHAR2(30);
	--
	Cursor cur_baneado_diag is
    Select P.baneado, P.Fec_tra, P.Usuario
      from REEMBOLSO.BLACKLIST_ASE_PERTINENCIA P
     where P.codigo_asegurado = :SOLICITUD_SERVICIO.CODIGO_AFILIADO
       and P.Tipo_bloqueo     = :FRMVAR.STR_DIAGNOSTICO
       and P.Diagnostico      = UPPER(:SOLICITUD_SERV_DIAG.COD_DIAGNOSTICO);
  --
BEGIN
  Open cur_baneado_diag;
  Fetch cur_baneado_diag into v_baneado, v_fec_tra_bloq, v_usuario_bloq;
  Close cur_baneado_diag;
  --
  If v_baneado = :FRMVAR.BANEADO then
     P_BUSCA_MOTIVO_BLOQUEO_PERTIN(:FRMVAR.STR_DIAGNOSTICO, 
                                   :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                   UPPER(:SOLICITUD_SERV_DIAG.COD_DIAGNOSTICO),
                                   NULL, --P_SERVICIO
                                   NULL, --P_TIP_COB
                                   NULL); --P_COBERTURA
     --
     PKG_MOT_BLOQUEO.SET_VARIABLE(:SOLICITUD_SERVICIO.COMPANIA,
     	                            :SOLICITUD_SERVICIO.RAMO, 
     	                            :SOLICITUD_SERVICIO.SECUENCIAL);
     -- Enfoco 03/02/2025.- Mejoras Notificacion
     PKG_MOT_BLOQUEO.P_ENVIA_NOTIFICACION_BLOQUEO(:GLOBAL.COD_COMPANIA, 
                                                  :FRMVAR.STR_DIAGNOSTICO,
                                                  :RADICACION.NUMERO_SOLICITUD,
                                                  :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                                  :SOLICITUD_SERVICIO.CODIGO_PLAN,
                                                  v_usuario_bloq, 
                                                  v_fec_tra_bloq, 
                                                  :BUSCA_SERVICIO.TIPO_PRESTADOR_ADD,
                                                  :SOLICITUD_SERVICIO.PROVEEDOR_ID,
                                                  UPPER(:SOLICITUD_SERV_DIAG.COD_DIAGNOSTICO),
                                                  NULL, --P_SERVICIO
                                                  NULL, --P_TIP_COB
                                                  NULL);-- P_COBERTURA
     RAISE FORM_TRIGGER_FAILURE;
  End if;
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_GRUPO_COB
-- Tipo: Procedure
-- --------------------------------------------------------------------
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

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_MONTO_PAGAR
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE p_valida_monto_pagar is
	 -- *****************************************************************
	 -- Creado por: Citser./Proyecto. Tarifas URA	 
	 -- Fecha.  26-Nov.-2024
	 -- *****************************************************************	 
	 
	 -- variables
	 v_tarifa_configurada			number(14,2) := 0;	 

-- cuerpo
begin
	 --
	 if (nvl(:solicitud_servicio_detalle.monto_pagar,0) > 0) then
	 	   
	 	   -- buscar el valor de la tarifa URA configurada 
	 	   v_tarifa_configurada  := F_BUSCA_TARIFA_URA(:CG$CTRL.codigo_compania         ,
											                             :solicitud_servicio.ramo				  ,
											                             :solicitud_servicio.codigo_plan  ,
											                             :solicitud_servicio.tipo_servicio,
											                             :solicitud_servicio_detalle.cobertura_tipo,
											                             :busca_servicio.grupo_cobertura  ,
											                             :solicitud_servicio_detalle.cobertura,
											                             :solicitud_servicio.fecha_servicio );
	 	   
	 	   --
	 	   if (nvl(v_tarifa_configurada,0) > 0) then
			 	   --
			 	   if (nvl(:solicitud_servicio_detalle.monto_pagar,0) > nvl(v_tarifa_configurada,0)) then
			 	   	  p_alerta_mensaje('Para este plan, el monto a pagar excede la tarifa URA máxima establecida, la cual es (RD$ '||to_char(v_tarifa_configurada,'9,999,999.99')||'., debe ir a Revision Medica', 'N');
		      		:SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR  		 := v_tarifa_configurada;
		      		:SOLICITUD_SERVICIO_DETALLE.MONTO_DIFERENCIA := :SOLICITUD_SERVICIO_DETALLE.MONTO_TOTAL - :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR;  -- Citser. 26.02.2025 / Tarifas URA
		      		:SOLICITUD_SERVICIO_DETALLE.MONTO_COASEGURO  := 0;
		      		--	 
			 	   	  if not F_USUARIO_AUTORIZADO() then
			 	   	     -- habilita item para permitirle enviar solicitud a Revision y colocar Service Desk
			 	   	     set_block_property('BK_SOLICITUD_REV_MEDICA' , update_allowed, property_true);
							   set_block_property('BK_SOLICITUD_REV_MEDICA' , insert_allowed, property_true);
							   --
							   set_item_property('BK_SOLICITUD_REV_MEDICA.IND_REVISION_MEDICA'   , enabled, property_true);
							   set_item_property('BK_SOLICITUD_REV_MEDICA.NO_SERVICE_DESK'   	 	 , enabled, property_true);
							   set_item_property('BK_SOLICITUD_REV_MEDICA.COMENTARIO'   				 , enabled, property_true);
				  			 --
			 	   	  end if;	 	   	
			 	   		--
			 	   end if;	 	   
			 	   --
	 	   end if;
	 	   --
	 	
	 end if;  -- (nvl(:solicitud_servicio_detalle.monto_pagar,0) > 0)
	 --

end;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_NUM_CTA_ELIMINADA
-- Tipo: Procedure
-- --------------------------------------------------------------------
-- Enfoco 20/12/2024.- Mejoras Reembolso.
PROCEDURE P_VALIDA_NUM_CTA_ELIMINADA(P_TIP_PRO     IN VARCHAR2,
                                     P_PROPETARIO  IN NUMBER, 
                                     P_TIPO_CTA    IN VARCHAR2,
                                     P_BANCO       IN NUMBER,
                                     P_NUMCTA      IN VARCHAR2,
                                     P_PROPIETARIO_TIPO_ID IN VARCHAR2,
                                     P_PROPIETARIO_NUM_ID  IN VARCHAR2) IS
  --
  v_msg_cuenta_elim VARCHAR2(500) := F_OBTEN_PARAMETRO_SEUS('MSG_CUENTA_ELIMI');
  v_existe          NUMBER(2);
  v_tipo_cuenta     VARCHAR2(2);
  --
  CURSOR CUR_CUENTA_ELIMINADA IS
    SELECT 1
      FROM NUMERO_CUENTA_ELIMINADA A, 
           NUMERO_CUENTA_INFO_ELI B
     WHERE A.TIP_PRO     = P_TIP_PRO
       AND A.PROPIETARIO = P_PROPETARIO
       AND A.TIP_CTA     = v_tipo_cuenta
       AND A.BANCO       = P_BANCO
       AND A.NUM_CTA     = P_NUMCTA
       AND B.CODIGO      = A.CODIGO 
       AND B.CONTRATANTE_TIPO_ID = P_PROPIETARIO_TIPO_ID
       AND B.CONTRATANTE_CED = P_PROPIETARIO_NUM_ID;
BEGIN
  SELECT DECODE(P_TIPO_CTA,'AHOR','A','C') INTO v_tipo_cuenta
    FROM DUAL;
  --     
  v_existe := 0;
  OPEN CUR_CUENTA_ELIMINADA;
  FETCH CUR_CUENTA_ELIMINADA INTO V_EXISTE;
  CLOSE CUR_CUENTA_ELIMINADA;
  --
  IF v_existe > 0 THEN
     MSG_ALERT(V_MSG_CUENTA_ELIM,'E', FALSE);
     RAISE FORM_TRIGGER_FAILURE;
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_PLAN
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_VALIDA_PLAN IS
	CURSOR C_EXISTE(X_PLAN NUMBER) IS
		SELECT DESCRIPCION, COMPANIA, RAMO, SECUENCIAL
		FROM TEMP_PLANES_ASE_REEMB_SERV
		WHERE CODIGO = X_PLAN;
BEGIN
	P_LLENA_TABLA_TMP_PLAN;
			
	OPEN C_EXISTE(:SOLICITUD_SERVICIO.CODIGO_PLAN);
	FETCH C_EXISTE INTO :SOLICITUD_SERVICIO.DSP_PLAN, :SOLICITUD_SERVICIO.COMPANIA, :SOLICITUD_SERVICIO.RAMO, :SOLICITUD_SERVICIO.SECUENCIAL;
	IF C_EXISTE%NOTFOUND THEN
		MSG_ALERT('Este plan no es valido para el asegurado a la fecha de servicio seleccionada.','E',TRUE);
	END IF;
	CLOSE C_EXISTE;
	
	:SOLICITUD_SERVICIO.DSP_INTERMEDIARIO := F_BUSCA_NOMBRE_INTERMED(:SOLICITUD_SERVICIO.COMPANIA, 
																																	 :SOLICITUD_SERVICIO.RAMO, 
																																	 :SOLICITUD_SERVICIO.SECUENCIAL)
																				  	|| ' / '
																 						||F_BUSCA_NOMBRE_GERENTE(:SOLICITUD_SERVICIO.COMPANIA, 
																																	 :SOLICITUD_SERVICIO.RAMO, 
																																	 :SOLICITUD_SERVICIO.SECUENCIAL);
																																	 
	IF :SOLICITUD_SERVICIO.CODIGO_AFILIADO IS NULL THEN
		:SOLICITUD_SERVICIO.CODIGO_AFILIADO := :CG$CTRL.NO_AFI;
		:SOLICITUD_SERVICIO.DSP_AFILIADO := :CG$CTRL.NOMBRE_AFILIADO;
	END IF;																																 
	
	

	
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_REEMBOLSO_USUARIO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_VALIDA_REEMBOLSO_USUARIO IS
  v_compania    NUMBER := :GLOBAL.COD_COMPANIA; -- Aquí asigna el valor correspondiente de la compañía
  v_usuario     VARCHAR2(50) := USER; --'OHEREDIA'; -- Aquí asigna el usuario correspondiente
  v_asegurado   NUMBER(10) := to_number(SUBSTR(NVL(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,:CG$CTRL.NO_AFI),1,7));
  v_encontrado  NUMBER;
  v_mensaje     VARCHAR2(300);
  v_msg_id      NUMBER(10) := 0;
BEGIN
  -- Llamada al procedimiento P_VALIDAR_NUCLEO_REEMBOLSO
  REEMBOLSO.P_VALIDAR_NUCLEO_REEMBOLSO(P_COMPANIA   => v_compania,
                                       P_USUARIO    => v_usuario,
                                       P_ASEGURADO  => v_asegurado,
                                       P_ENCONTRADO => v_encontrado,
                                       P_MENSAJE    => v_mensaje
                                       );
  -- Mostrar resultados
  IF v_encontrado != F_OBTEN_PARAMETRO_SEUS('P_RESPUESTA_OK', v_compania) THEN
     p_imprime_mensaje(v_msg_id, v_mensaje);
     RAISE FORM_TRIGGER_FAILURE;
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_ROL_USUARIO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_VALIDA_ROL_USUARIO IS
	V_ROLE number;
BEGIN
  IF F_VALIDAR_PERMISO(:GLOBAL.COD_COMPANIA,USER,'RECP_SOL_RAD',9) THEN 
  	:RADICACION.TIPO_PAGO := 'ORDINARIO' ;
  ELSE 
  	:RADICACION.TIPO_PAGO := 'EXPRESO' ;
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_SERVICIO_BLOQUEADO
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_VALIDA_SERVICIO_BLOQUEADO IS
	-- Enfoco 23/11/2024.- Proyecto Lista Negra
  v_baneado       NUMBER(2) := 0;
  v_fec_tra_bloq  DATE; 
  v_usuario_bloq  VARCHAR2(30);
	--
	Cursor cur_baneado_ser is
    Select P.baneado, P.fec_tra, P.usuario
      from REEMBOLSO.BLACKLIST_ASE_PERTINENCIA P
     where P.codigo_asegurado = :SOLICITUD_SERVICIO.CODIGO_AFILIADO
       and P.Tipo_bloqueo     = :FRMVAR.STR_SERVICIO
       and P.servicio         = :SOLICITUD_SERVICIO.TIPO_SERVICIO;

BEGIN
	Open cur_baneado_ser;
  Fetch cur_baneado_ser into v_baneado, v_fec_tra_bloq, v_usuario_bloq;
  Close cur_baneado_ser;
  --
  If v_baneado = :FRMVAR.BANEADO then
     P_BUSCA_MOTIVO_BLOQUEO_PERTIN(:FRMVAR.STR_SERVICIO, 
                                   :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                   NULL, --P_DIAGNOSTICO 
                                   :SOLICITUD_SERVICIO.TIPO_SERVICIO,
                                   NULL, --P_TIP_COB
                                   NULL); --P_COBERTURA
     --
     PKG_MOT_BLOQUEO.SET_VARIABLE(:SOLICITUD_SERVICIO.COMPANIA,
     	                            :SOLICITUD_SERVICIO.RAMO, 
     	                            :SOLICITUD_SERVICIO.SECUENCIAL);
     -- Enfoco 03/02/2025.- Mejoras Notificacion
     PKG_MOT_BLOQUEO.P_ENVIA_NOTIFICACION_BLOQUEO(:GLOBAL.COD_COMPANIA, 
                                                  :FRMVAR.STR_SERVICIO,
                                                  :RADICACION.NUMERO_SOLICITUD,
                                                  :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                                  :SOLICITUD_SERVICIO.CODIGO_PLAN,
                                                  v_usuario_bloq, 
                                                  v_fec_tra_bloq, 
                                                  :BUSCA_SERVICIO.TIPO_PRESTADOR_ADD,
                                                  :SOLICITUD_SERVICIO.PROVEEDOR_ID,
                                                  NULL,
                                                  :SOLICITUD_SERVICIO.TIPO_SERVICIO,
                                                  NULL, --P_TIP_COB
                                                  NULL);-- P_COBERTURA
     --
     RAISE FORM_TRIGGER_FAILURE;
  End if;  
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_SOLICITUD_DUPLICADA
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE p_valida_solicitud_duplicada(P_COBERTURA_ID_ADD	VARCHAR2 DEFAULT NULL) IS
	v_existe_n	number;
	v_existe	boolean := false;
	v_existe_diagnostico	boolean := false;
	v_existe_cobertura	boolean := false;
  v_est_anul_ss		number := PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('P_EST_ANU_948',:global.cod_compania);
  v_est_rech_ss		number := PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('P_EST_REC_945',:global.cod_compania);	
	
	cursor c_existe_Solicitud_base is
		select ss.id
			from solicitud_servicio ss
		where ss.fecha_servicio = :solicitud_servicio.fecha_Servicio
		 and ss.SERVICIO_TIPO_ID = :solicitud_servicio.tipo_servicio
		 and ss.id <> nvl(:solicitud_servicio.id,0)
		 and ss.AFILIADO_NUMERO=:solicitud_servicio.CODIGO_AFILIADO
		 and ss.estatus not in (v_est_anul_ss, v_est_rech_ss) --lcalcano forebra 10-jul-23 para que no tome en cuenta las sol rechazadas o anuladas al momento de trabajar con una sol duplicada
		 ;
			
	cursor c_existe_diagnostico(l_solicitudservid	number, l_diagnostico	varchar2) is
		select 1
			from SOLICITUD_SERVICIO_DIAGNOSTICO d
		where SOLICITUD_SERVICIO_ID = l_solicitudservid
		 and d.CODIGO_DIAGNOSTICO = l_diagnostico;
		 
	cursor c_existe_cobertura(l_solicitudservid	number, l_cobertura	varchar2) is
		select 1
			from COBERTURA_SOLICITADA d
		where SOLICITUD_SERVICIO_ID = l_solicitudservid
		 and d.COBERTURA_ID = l_cobertura;
		 
begin	
		
		for i in c_existe_Solicitud_base loop
				v_existe := false;
				v_existe_diagnostico := false;
				v_existe_cobertura := false;
				
				go_block('SOLICITUD_SERV_DIAG');
				first_record;
				if :SOLICITUD_SERV_DIAG.COD_DIAGNOSTICO is not null then
					loop
						open c_existe_diagnostico(i.id, :SOLICITUD_SERV_DIAG.COD_DIAGNOSTICO);
						fetch c_existe_diagnostico into v_existe_n;
						if c_existe_diagnostico%found then
							v_existe_diagnostico := true;
						end if;
						close c_existe_diagnostico;
						exit when :system.last_Record = 'TRUE' or v_existe_diagnostico = true;
						next_record;
					end loop;
					first_record;
				else
					v_existe_diagnostico := false;		
				end if;
				
				go_block('SOLICITUD_SERVICIO_DETALLE');
				first_record;
				if NVL(P_COBERTURA_ID_ADD,:SOLICITUD_SERVICIO_DETALLE.COBERTURA) IS NOT NULL then
					loop
						open c_existe_cobertura(i.id, NVL(P_COBERTURA_ID_ADD,:SOLICITUD_SERVICIO_DETALLE.COBERTURA));
						fetch c_existe_cobertura into v_existe_n;
						if c_existe_cobertura%found then
							v_existe_cobertura := true;
						end if;
						close c_existe_cobertura;
						exit when :system.last_Record = 'TRUE' or v_existe_cobertura = true;
						next_record;
					end loop;
					first_record;
				else
					v_existe_cobertura := false;
				end if;
				
				if v_existe_cobertura and v_existe_diagnostico then
					v_existe := true;
				end if;
				
				if v_existe then
					exit;
				end if;
		end loop;
		
	if v_existe then
		p_imprime_mensaje(404, NULL);
		RAISE FORM_TRIGGER_FAILURE;	
	end if;
	
end;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_SOLICITUD_DUPLI_COB
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE p_valida_solicitud_dupli_cob(P_COBERTURA_ID_ADD	VARCHAR2 DEFAULT NULL) IS
  -- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (27/01/2024). INTEGRACION
	v_existe_n	number;
	v_existe	boolean := false;
	v_existe_diagnostico	boolean := false;
	v_existe_cobertura	boolean := false;
  V_RECORD                    NUMBER := :SYSTEM.CURSOR_RECORD;
  v_est_anul_ss		number := PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('P_EST_ANU_948',:global.cod_compania);
  v_est_rech_ss		number := PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('P_EST_REC_945',:global.cod_compania);
  V_EXISTE_RECLAMACION NUMBER;
	
	cursor c_existe_Solicitud_base is
		select ss.id
			from solicitud_servicio ss
		where ss.fecha_servicio = :solicitud_servicio.fecha_Servicio
	--OF23012024	 and ss.SERVICIO_TIPO_ID = :solicitud_servicio.tipo_servicio
		 and ss.id <> nvl(:solicitud_servicio.id,0)
		 and ss.AFILIADO_NUMERO=:solicitud_servicio.CODIGO_AFILIADO
		 and ss.estatus not in (v_est_anul_ss, v_est_rech_ss) --lcalcano forebra 10-jul-23 para que no tome en cuenta las sol rechazadas o anuladas al momento de trabajar con una sol duplicada
		 ;
			
	cursor c_existe_diagnostico(l_solicitudservid	number, l_diagnostico	varchar2) is
		select 1
			from SOLICITUD_SERVICIO_DIAGNOSTICO d;
				--OF23012024
	/*	where SOLICITUD_SERVICIO_ID = l_solicitudservid
		 and d.CODIGO_DIAGNOSTICO = l_diagnostico;*/
		 
	cursor c_existe_cobertura(l_solicitudservid	number, l_cobertura	varchar2) is
		select 1
			from COBERTURA_SOLICITADA d
		where SOLICITUD_SERVICIO_ID = l_solicitudservid
		 and d.COBERTURA_ID = l_cobertura;
		        
       	cursor c_existe is
        SELECT 1 FROM RECLAMACION Y 
        WHERE Y.ASE_USO=TO_NUMBER(SUBSTR(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,1,7)) 
        AND NVL(Y.DEP_USO,0)=to_number(SUBSTR(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,8,3))
        AND Y.FEC_SER =:SOLICITUD_SERVICIO.FECHA_SERVICIO
        AND Y.ESTATUS NOT IN (183,600,801,523,300,180) -- DAGUZMAN #205510 07-MAYO-2024 COLOCAMOS EL ESTATUS 180 PARA QUE NO TOME EN CUENTA LOS RECLAMOS QUE ESTAN DECLINADO
        AND EXISTS ( SELECT 1 FROM REC_C_SAL X 
                     WHERE X.ANO=Y.ANO 
                     AND X.COMPANIA=Y.COMPANIA 
                     AND X.RAMO=Y.RAMO
                     AND X.SECUENCIAL=Y.SECUENCIAL
                     AND X.COBERTURA= :SOLICITUD_SERVICIO_DETALLE.COBERTURA);
		 
		 
begin	
	V_RECORD  := :SYSTEM.CURSOR_RECORD;
		
		for i in c_existe_Solicitud_base loop
		
				v_existe := false;
				v_existe_diagnostico := true;
				v_existe_cobertura := false;
				
				/*go_block('SOLICITUD_SERV_DIAG');
				first_record;
				if :SOLICITUD_SERV_DIAG.COD_DIAGNOSTICO is not null then
					loop
						open c_existe_diagnostico(i.id, :SOLICITUD_SERV_DIAG.COD_DIAGNOSTICO);
						fetch c_existe_diagnostico into v_existe_n;
						if c_existe_diagnostico%found then
							v_existe_diagnostico := true;
						end if;
						close c_existe_diagnostico;
						exit when :system.last_Record = 'TRUE' or v_existe_diagnostico = true;
						next_record;
					end loop;
					first_record;
				else
					v_existe_diagnostico := false;		
				end if;*/
				
			--	go_block('SOLICITUD_SERVICIO_DETALLE');
			--	first_record;
		--	GO_RECORD(V_RECORD);
				if NVL(P_COBERTURA_ID_ADD,:SOLICITUD_SERVICIO_DETALLE.COBERTURA) IS NOT NULL then
				--	loop
						open c_existe_cobertura(i.id, NVL(P_COBERTURA_ID_ADD,:SOLICITUD_SERVICIO_DETALLE.COBERTURA));
						fetch c_existe_cobertura into v_existe_n;
						if c_existe_cobertura%found then
							v_existe_cobertura := true;
						end if;
						close c_existe_cobertura;
				--		exit when :system.last_Record = 'TRUE' or v_existe_cobertura = true;
				--		next_record;
				--	end loop;
				--	first_record;
				else
					v_existe_cobertura := false;
				end if;
				
				if v_existe_cobertura and v_existe_diagnostico then
					v_existe := true;
				end if;
				
				if v_existe then
					exit;
				end if;
		end loop;
		
		
		OPEN c_existe;
		FETCH c_existe INTO v_existe_reclamacion;
		CLOSE c_existe;
		
	if (v_existe or v_existe_reclamacion=1) then
--		p_imprime_mensaje(404, NULL);
		 	:SOLICITUD_SERVICIO_DETALLE.COBERTURA := NULL;
			:SOLICITUD_SERVICIO_DETALLE.DSP_COBERTURA := NULL;
	MSG_ALERT('Cobertura Inválida: Ha solicitado esta cobertura para este día.','E',TRUE);
		
	else 
		:CG$CTRL.IND_VALIDATE_COB_RECORD := 'S';
	--	go_item('SOLICITUD_SERVICIO_DETALLE.cobertura');
		
	end if;
end;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_USUARIO_APROB
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_VALIDA_USUARIO_APROB(P_BLOQUE VARCHAR2, P_RAISE IN BOOLEAN) IS
  --  Proyecto Exgratia.- Enfoco 01/09/2024
  v_cob_exgratia  VARCHAR2(256) := F_OBTEN_PARAMETRO_SEUS('COB_EXGRATIA', :GLOBAL.COD_COMPANIA);
  --
  v_msg_id3        NUMBER(10) := F_OBTEN_PARAMETRO_SEUS('SPOOL_EXGRATIA.MSG3', :GLOBAL.COD_COMPANIA);
  v_msg_id4        NUMBER(10) := F_OBTEN_PARAMETRO_SEUS('SPOOL_EXGRATIA.MSG4', :GLOBAL.COD_COMPANIA);
  v_est_cob_apr   NUMBER(10) := F_OBTEN_PARAMETRO_SEUS('EST_APR_COB_SOL_REMB', :GLOBAL.COD_COMPANIA);
  v_mon_max_apr   NUMBER(12,2) := 0;
  --
  Cursor cur_usu_apr is
    Select a.mon_max 
      from reemb_usuario_aprobacion a,
           usu_s_per b
      where a.compania = :GLOBAL.COD_COMPANIA
        and a.cod_usuario = b.codigo 
        and b.descripcion = :SOLICITUD_SERVICIO_DETALLE.USU_APROB; 
BEGIN
  IF P_BLOQUE = 'SOLICITUD_SERVICIO_DETALLE' THEN
     IF :SYSTEM.RECORD_STATUS IN('NEW','INSERT') AND :SOLICITUD_SERVICIO_DETALLE.COBERTURA IS NOT NULL THEN
        IF INSTR(v_cob_exgratia,'*'||:SOLICITUD_SERVICIO_DETALLE.COBERTURA||'*') > 0 
        AND (:SOLICITUD_SERVICIO_DETALLE.USU_APROB IS NULL OR :SOLICITUD_SERVICIO_DETALLE.COMENT_SOL_SPOOL IS NULL)
        AND :SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID = v_est_cob_apr THEN
            p_imprime_mensaje(v_msg_id3, null); -- 'Debe indicar el usuario aprobador para coberturas de Exgratias.'
            IF P_RAISE THEN
               RAISE FORM_TRIGGER_FAILURE;
            END IF;
        END IF;
     END IF;
     --
     IF :SOLICITUD_SERVICIO_DETALLE.USU_APROB IS NOT NULL THEN
        OPEN cur_usu_apr;
        FETCH cur_usu_apr INTO v_mon_max_apr;
        CLOSE cur_usu_apr;
        --
        IF :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR > NVL(v_mon_max_apr,0) THEN
           p_imprime_mensaje(v_msg_id4, null); -- 'Usuario excede monto maximo de aprobacion'
        END IF;
     END IF;
  ELSE 
     GO_BLOCK('SOLICITUD_SERVICIO_DETALLE');   
     FIRST_RECORD;
     LOOP
       IF INSTR(v_cob_exgratia,'*'||:SOLICITUD_SERVICIO_DETALLE.COBERTURA||'*') > 0
       AND (:SOLICITUD_SERVICIO_DETALLE.USU_APROB IS NULL OR :SOLICITUD_SERVICIO_DETALLE.COMENT_SOL_SPOOL IS NULL)
       AND :SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID = v_est_cob_apr THEN
          p_imprime_mensaje(v_msg_id3, null); -- 'Debe indicar el usuario aprobador para coberturas de Exgratias.'
          GO_ITEM('SOLICITUD_SERVICIO_DETALLE.USU_APROB');
          IF P_RAISE THEN
             RAISE FORM_TRIGGER_FAILURE;
          END IF;
          --
       END IF;
       --
       IF :SOLICITUD_SERVICIO_DETALLE.USU_APROB IS NOT NULL THEN
           OPEN cur_usu_apr;
           FETCH cur_usu_apr INTO v_mon_max_apr;
           CLOSE cur_usu_apr;
           --
           IF :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR > NVL(v_mon_max_apr,0) THEN
              p_imprime_mensaje(v_msg_id4, null); -- 'Usuario excede monto maximo de aprobacion'
              IF P_RAISE THEN
                 RAISE FORM_TRIGGER_FAILURE;
              END IF;
           END IF;
       END IF;
       --
       EXIT WHEN :SYSTEM.LAST_RECORD = 'TRUE';
       NEXT_RECORD;   
     END LOOP;
  END IF;
END;

-- ====================================================================

-- PROGRAM UNIT: P_VALIDA_VIG_ASE_FEC
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE P_VALIDA_VIG_ASE_FEC IS
	CURSOR C_ESTATUS_ASEG IS
		SELECT 1 
		FROM ASE_POL AP, ESTATUS E
		WHERE ASEGURADO = :CG$CTRL.ASEGURADO
		AND E.CODIGO =  AP.ESTATUS
		AND E.VAL_LOG = 'T'
		AND ap.fec_ver =
		    (SELECT MAX(b.fec_ver)
		     FROM ase_pol b
		     WHERE b.asegurado = ap.asegurado
		      AND b.compania = ap.compania
		      AND b.ramo = ap.ramo
		      AND b.secuencial = ap.secuencial
		      AND b.fec_ver <= TRUNC(:SOLICITUD_SERVICIO.FECHA_SERVICIO) + .99999)
		AND ap.FEC_TRA =
		    (SELECT MAX(b.fec_tra)
		     FROM ase_pol b
		     WHERE b.asegurado = ap.asegurado
		      AND b.compania = ap.compania
		      AND b.ramo = ap.ramo
		      AND b.secuencial = ap.secuencial
		      AND b.fec_ver = ap.fec_ver);
		      
		
	V_VIGENTE	NUMBER;
	
BEGIN
  OPEN C_ESTATUS_ASEG;
  FETCH C_ESTATUS_ASEG INTO V_VIGENTE;
  CLOSE C_ESTATUS_ASEG;
  
  IF V_VIGENTE IS NULL THEN
  	MSG_ALERT('Afiliado no posee plan vigente para la fecha de servicio seleccionada.','W',FALSE); --Edelcarmen-Forebra 13sep2023 Se coloco W, y False para que la alerta no detenga el flujo
  	--RAISE FORM_TRIGGER_FAILURE; --Edelcarmen-Forebra 13sep2023
  END IF;
  
END;

-- ====================================================================

-- PROGRAM UNIT: P_VERIFICAR_RESTRICCIONES
-- Tipo: Procedure
-- --------------------------------------------------------------------
--Tommy Pereyra Enfoco 17/11/2024
PROCEDURE p_verificar_restricciones IS

v_mensaje varchar2(1000); 
v_tipo_nivel varchar2(5);
v_accion number;
v_MONTO_PAGAR number; 
v_estatus_COBERTURA number;

begin

  pkg_restric_reembolso.p_restricciones(:GLOBAL.COD_COMPANIA, 
                                        :solicitud_servicio.codigo_plan, 
                                        :SOLICITUD_SERV_DIAG.cod_diagnostico, 
                                        :SOLICITUD_SERVICIO.TIPO_SERVICIO,
                                        :SOLICITUD_SERVICIO_DETALLE.COBERTURA,
                                        :SOLICITUD_SERVICIO.CODIGO_AFILIADO,
                                        :SOLICITUD_SERVICIO.fecha_servicio, 
                                        :radicacion.numero_solicitud, 
                                        v_tipo_nivel,
                                        v_accion,
                                        v_mensaje, 
                                        v_MONTO_PAGAR, 
                                        v_estatus_COBERTURA);
  
  if v_accion = F_OBTEN_PARAMETRO_SEUS('APROBAR_REEMB') --1    
  	then         				   	 				   	 
    MSG_ALERT(v_mensaje, 'E',FALSE);
  	--:CG$CTRL.DESCRIPCION_MENSAJES := v_mensaje;				   	 				   	 
		--GO_ITEM('CG$CTRL.BTN_CERRAR');  
  elsif v_accion != F_OBTEN_PARAMETRO_SEUS('APROBAR_REEMB') --1 
  	and v_accion is not null
  	then         				   	 				   	 
	  :CG$CTRL.DESCRIPCION_MENSAJES := v_mensaje;				   	 				   	 
   	GO_ITEM('CG$CTRL.BTN_CERRAR');  
   	 
   	--antes de empezar este proceso verificar si los botones estan enable, para que se queden asi si aplica					   	  
	  SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EDITAR_MON', ENABLED, PROPERTY_FALSE);
	  SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_COBR_INDE', ENABLED, PROPERTY_FALSE);
	  SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_EXCEPCION_NEGOCIO', ENABLED, PROPERTY_FALSE);
	  SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_TARIFA_INCORECTA', ENABLED, PROPERTY_FALSE);
	  SET_ITEM_PROPERTY('SOLICITUD_SERVICIO_DETALLE.BTN_NEGOCIACION_PRESTADOR', ENABLED, PROPERTY_FALSE);
     
    :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR := v_MONTO_PAGAR;
    :SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID := v_estatus_COBERTURA;
  end if;


end;

-- ====================================================================

-- PROGRAM UNIT: QUERY_MASTER_DETAILS
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE Query_Master_Details(rel_id Relation,detail VARCHAR2) IS
  oldmsg VARCHAR2(2);  -- Old Message Level Setting
  reldef VARCHAR2(5);  -- Relation Deferred Setting
BEGIN
  --
  -- Initialize Local Variable(s)
  --
  reldef := Get_Relation_Property(rel_id, DEFERRED_COORDINATION);
  oldmsg := :System.Message_Level;
  --
  -- If NOT Deferred, Goto detail and execute the query.
  --
  IF reldef = 'FALSE' THEN
    Go_Block(detail);
    Check_Package_Failure;
    :System.Message_Level := '10';
    Execute_Query;
    :System.Message_Level := oldmsg;
  ELSE
    --
    -- Relation is deferred, mark the detail block as un-coordinated
    --
    Set_Block_Property(detail, COORDINATION_STATUS, NON_COORDINATED);
  END IF;

EXCEPTION
    WHEN Form_Trigger_Failure THEN
      :System.Message_Level := oldmsg;
      RAISE;
END Query_Master_Details;

-- ====================================================================

-- PROGRAM UNIT: SHOW_CALENDAR
-- Tipo: Procedure
-- --------------------------------------------------------------------
PROCEDURE Show_Calendar IS
Begin
	
  calendar.setup;
  calendar.show;
End;

-- ====================================================================

-- PROGRAM UNIT: TOOLBAR_ACTIONS
-- Tipo: Procedure
-- --------------------------------------------------------------------
-- This procedure implements the toolbar functionality. The logic reads
-- the pressed button name and then calls the appropriate function. If
-- you want to change the toolbar then make sure the if statement below
-- has one entry for each button.
PROCEDURE TOOLBAR_ACTIONS IS
    button_name varchar2(61);
    button      varchar2(31);
BEGIN
      del_timer('bubble_delay');
      show_window(get_view_property(get_item_property(
	name_in('SYSTEM.CURSOR_ITEM'), item_canvas), window_name));
      button_name := name_in('SYSTEM.TRIGGER_ITEM');
      button      := substr(button_name, instr(button_name, '.')+1);
      if    (button = 'SAVE')          	then
	IF :SYSTEM.FORM_STATUS = 'CHANGED' THEN
           DO_KEY('COMMIT_FORM');
	ELSE
	   MSG_ALERT('No Existen Datos a Grabar', 'I',TRUE);
        END IF;
      elsif (button = 'PRINT')		then do_key('PRINT');
      elsif (button = 'CLEAR_FORM') 	then do_key('CLEAR_FORM');
      elsif (button = 'QUERY_FIND')	then 
        if (name_in('SYSTEM.MODE') != 'ENTER-QUERY') then do_key('ENTER_QUERY');
        else do_key('EXECUTE_QUERY');
        end if;
      elsif (button = 'INSERT_RECORD')  then do_key('CREATE_RECORD');
      elsif (button = 'DELETE_RECORD')  then do_key('DELETE_RECORD');
      elsif (button = 'CLEAR_RECORD')   then do_key('CLEAR_RECORD');
      elsif (button = 'LIST')           then do_key('LIST_VALUES');
      elsif (button = 'EDIT')		then do_key('EDIT_FIELD');
      elsif (button = 'HELP')           then do_key('HELP');
      elsif (button = 'ANTERIOR')       then do_key('SCROLL_UP');
      elsif (button = 'PROXIMO')        then do_key('SCROLL_DOWN');
      elsif (button = 'SALIR')	        then do_key('ABORT_QUERY');
					     do_key('EXIT_FORM');
	
      end if;
END;

-- ====================================================================

