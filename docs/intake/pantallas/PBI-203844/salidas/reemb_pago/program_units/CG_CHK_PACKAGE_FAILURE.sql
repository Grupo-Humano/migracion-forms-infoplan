-- PROGRAM UNIT: CG$CHK_PACKAGE_FAILURE
-- Tipo: Procedure
-- ====================================================================

PROCEDURE CG$CHK_PACKAGE_FAILURE IS
/* If packaged procedure has failed then raise */
/* FORM_TRIGGER_FAILURE */
BEGIN
  IF NOT FORM_SUCCESS THEN
    RAISE FORM_TRIGGER_FAILURE;
  END IF;
END;
