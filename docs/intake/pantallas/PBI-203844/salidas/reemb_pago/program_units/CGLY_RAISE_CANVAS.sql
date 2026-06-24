-- PROGRAM UNIT: CGLY$RAISE_CANVAS
-- Tipo: Procedure
-- ====================================================================

/* CGLY$RAISE_CANVAS */
PROCEDURE CGLY$RAISE_CANVAS(
   P_CANVAS IN VARCHAR2) IS  /* Current canvas */
/* Raise the current canvas, plus any dependant canvases to the top */
BEGIN
  set_view_property(P_CANVAS, VISIBLE, PROPERTY_ON);
  IF ( P_CANVAS = 'SOLICITUD_SERVICIO') THEN
    set_view_property('CG$STACKED_HEADER_1', VISIBLE, PROPERTY_ON);
    set_view_property('CG$STACKED_FOOTER_1', DISPLAY_POSITION, 0, 8.499);
    set_view_property('CG$STACKED_FOOTER_1', VISIBLE, PROPERTY_ON);
    set_view_property('ASEGURADO', VISIBLE, PROPERTY_ON);
  END IF;
END;
