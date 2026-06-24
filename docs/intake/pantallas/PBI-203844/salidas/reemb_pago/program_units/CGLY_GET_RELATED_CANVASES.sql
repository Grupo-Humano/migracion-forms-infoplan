-- PROGRAM UNIT: CGLY$GET_RELATED_CANVASES
-- Tipo: Procedure
-- ====================================================================

/* CGLY$GET_RELATED_CANVASES */
PROCEDURE CGLY$GET_RELATED_CANVASES(
   P_CURRENT_CANVAS IN OUT VARCHAR2      /* Current canvas */
  ,P_BASE_CANVAS    IN OUT VARCHAR2) IS  /* Base canvas    */
/* Find the canvases associated with the current canvas and record whi */
/* base canvas is displayed in each window                             */
BEGIN
  P_BASE_CANVAS := P_CURRENT_CANVAS;
  IF (get_view_property(P_CURRENT_CANVAS, WINDOW_NAME) = 'DUMMY') THEN
    :CG$CTRL.DUMMY_PAGE := P_BASE_CANVAS;
  ELSIF (get_view_property(P_CURRENT_CANVAS, WINDOW_NAME) =
      'ROOT_WINDOW') THEN
    :CG$CTRL.ROOT_WINDOW_PAGE := P_BASE_CANVAS;
  END IF;
END;
