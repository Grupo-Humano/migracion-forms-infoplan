-- PROGRAM UNIT: TOOLBAR_ACTIONS
-- Tipo: Procedure
-- ====================================================================

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
