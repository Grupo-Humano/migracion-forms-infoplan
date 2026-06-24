-- PROGRAM UNIT: DEL_TIMER
-- Tipo: Procedure
-- ====================================================================

-- Standard delete timer procedure. Is part of iconic button tool tips.
PROCEDURE DEL_TIMER (tm_name Varchar2 )IS
  tm_id timer;
BEGIN
  tm_id := find_timer(tm_name);
  if not id_null(tm_id) then 
    delete_timer(tm_id);
  end if;
END;
