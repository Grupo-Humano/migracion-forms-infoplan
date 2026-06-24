-- PROGRAM UNIT: CGTE$OTHER_EXCEPTIONS
-- Tipo: Procedure
-- ====================================================================

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
