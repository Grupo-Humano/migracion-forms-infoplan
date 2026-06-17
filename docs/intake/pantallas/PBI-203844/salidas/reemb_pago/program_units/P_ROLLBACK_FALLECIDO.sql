-- PROGRAM UNIT: P_ROLLBACK_FALLECIDO
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_ROLLBACK_FALLECIDO(P_CAMPO VARCHAR2) IS
-- Encofo(GM) 23/10/2024.- Proyecto Cobertura Exgratia 
  v_selec_n  VARCHAR2(5) := F_OBTEN_PARAMETRO_SEUS('P_SELECCION_N', :GLOBAL.COD_COMPANIA);
  v_selec_s  VARCHAR2(5) := F_OBTEN_PARAMETRO_SEUS('P_SELECCION_S', :GLOBAL.COD_COMPANIA);
BEGIN
  IF NAME_IN(P_CAMPO) = v_selec_s THEN
     COPY(v_selec_n, P_CAMPO);
  ELSE
     Copy(v_selec_s, P_CAMPO);
  END IF;
END;
