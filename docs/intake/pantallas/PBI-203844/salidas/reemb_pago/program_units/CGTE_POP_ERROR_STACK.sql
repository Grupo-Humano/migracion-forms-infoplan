-- PROGRAM UNIT: CGTE$POP_ERROR_STACK
-- Tipo: Procedure
-- ====================================================================

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
