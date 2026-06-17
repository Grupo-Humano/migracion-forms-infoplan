-- PROGRAM UNIT: CAMBIA_COLOR_HEADER
-- Tipo: Procedure
-- ====================================================================

PROCEDURE CAMBIA_COLOR_HEADER IS

  v_color varchar2(20) := f_obten_parametro_color(nvl(:GLOBAL.COD_COMPANIA,30),'COLOR_FORMA');

BEGIN
	SET_CANVAS_PROPERTY('CG$STACKED_HEADER_1', background_color, v_color);
END;
