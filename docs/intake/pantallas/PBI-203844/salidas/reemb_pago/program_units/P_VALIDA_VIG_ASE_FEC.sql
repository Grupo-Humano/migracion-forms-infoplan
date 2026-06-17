-- PROGRAM UNIT: P_VALIDA_VIG_ASE_FEC
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_VALIDA_VIG_ASE_FEC IS
	CURSOR C_ESTATUS_ASEG IS
		SELECT 1 
		FROM ASE_POL AP, ESTATUS E
		WHERE ASEGURADO = :CG$CTRL.ASEGURADO
		AND E.CODIGO =  AP.ESTATUS
		AND E.VAL_LOG = 'T'
		AND ap.fec_ver =
		    (SELECT MAX(b.fec_ver)
		     FROM ase_pol b
		     WHERE b.asegurado = ap.asegurado
		      AND b.compania = ap.compania
		      AND b.ramo = ap.ramo
		      AND b.secuencial = ap.secuencial
		      AND b.fec_ver <= TRUNC(:SOLICITUD_SERVICIO.FECHA_SERVICIO) + .99999)
		AND ap.FEC_TRA =
		    (SELECT MAX(b.fec_tra)
		     FROM ase_pol b
		     WHERE b.asegurado = ap.asegurado
		      AND b.compania = ap.compania
		      AND b.ramo = ap.ramo
		      AND b.secuencial = ap.secuencial
		      AND b.fec_ver = ap.fec_ver);
		      
		
	V_VIGENTE	NUMBER;
	
BEGIN
  OPEN C_ESTATUS_ASEG;
  FETCH C_ESTATUS_ASEG INTO V_VIGENTE;
  CLOSE C_ESTATUS_ASEG;
  
  IF V_VIGENTE IS NULL THEN
  	MSG_ALERT('Afiliado no posee plan vigente para la fecha de servicio seleccionada.','W',FALSE); --Edelcarmen-Forebra 13sep2023 Se coloco W, y False para que la alerta no detenga el flujo
  	--RAISE FORM_TRIGGER_FAILURE; --Edelcarmen-Forebra 13sep2023
  END IF;
  
END;
