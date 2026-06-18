-- PROGRAM UNIT: CGHP$CALL_HELP_FORM
-- Tipo: Procedure
-- ====================================================================

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
