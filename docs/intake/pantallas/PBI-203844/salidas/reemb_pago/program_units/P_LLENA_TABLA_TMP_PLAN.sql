-- PROGRAM UNIT: P_LLENA_TABLA_TMP_PLAN
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_LLENA_TABLA_TMP_PLAN IS
BEGIN
  IF :CG$CTRL.ASEGURADO IS NOT NULL THEN
	  P_INSERTA_PLA_AFI_REEMB_SERV(:CG$CTRL.ASEGURADO, 
	  														 0, 
	  														 :SOLICITUD_SERVICIO.FECHA_SERVICIO, 
	  														 :GLOBAL.COD_COMPANIA);
	END IF;
END;
