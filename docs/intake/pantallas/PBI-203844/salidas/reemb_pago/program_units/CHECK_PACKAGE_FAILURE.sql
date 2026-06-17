-- PROGRAM UNIT: CHECK_PACKAGE_FAILURE
-- Tipo: Procedure
-- ====================================================================

Procedure Check_Package_Failure IS
BEGIN
  IF NOT ( Form_Success ) THEN
    RAISE Form_Trigger_Failure;
  END IF;
END;
