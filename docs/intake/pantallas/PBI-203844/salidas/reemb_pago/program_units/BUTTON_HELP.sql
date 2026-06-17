-- PROGRAM UNIT: BUTTON_HELP
-- Tipo: Procedure
-- ====================================================================

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
