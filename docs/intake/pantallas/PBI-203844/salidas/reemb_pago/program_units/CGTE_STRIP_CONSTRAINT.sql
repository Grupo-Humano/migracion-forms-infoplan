-- PROGRAM UNIT: CGTE$STRIP_CONSTRAINT
-- Tipo: Function
-- ====================================================================

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
