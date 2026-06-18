-- PROGRAM UNIT: CGTE$STRIP_FIRST_ERROR
-- Tipo: Function
-- ====================================================================

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
