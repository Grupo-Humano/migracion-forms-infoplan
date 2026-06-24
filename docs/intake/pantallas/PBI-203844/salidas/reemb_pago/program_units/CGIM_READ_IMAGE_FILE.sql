-- PROGRAM UNIT: CGIM$READ_IMAGE_FILE
-- Tipo: Procedure
-- ====================================================================

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
