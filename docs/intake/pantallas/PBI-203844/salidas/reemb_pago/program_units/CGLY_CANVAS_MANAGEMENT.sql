-- PROGRAM UNIT: CGLY$CANVAS_MANAGEMENT
-- Tipo: Procedure
-- ====================================================================

/* CGLY$CANVAS_MANAGEMENT */
PROCEDURE CGLY$CANVAS_MANAGEMENT IS
/* Top level canvas management procedure */
  current_canvas VARCHAR2(61) := get_item_property(:SYSTEM.CURSOR_ITEM,
      ITEM_CANVAS);
  base_canvas VARCHAR2(61);
  canvas_list VARCHAR2(255);
BEGIN
  IF ( (:CG$CTRL.CG$LAST_CANVAS IS NULL) OR (:CG$CTRL.CG$LAST_CANVAS !=
      current_canvas) ) THEN
    :CG$CTRL.CG$LAST_CANVAS := current_canvas;
    set_window_property( get_view_property( current_canvas, WINDOW_NAME
        ), VISIBLE, PROPERTY_ON);
    CGLY$GET_RELATED_CANVASES(current_canvas, base_canvas);
    IF ( base_canvas = 'SOLICITUD_SERVICIO') THEN
      canvas_list := :CG$CTRL.CG$PAGE_1_LIST;
    END IF;
    CGLY$DISPLAY_CANVASES(canvas_list, current_canvas, base_canvas);
    IF ( base_canvas = 'SOLICITUD_SERVICIO') THEN
      :CG$CTRL.CG$PAGE_1_LIST := canvas_list;
    END IF;
  END IF;
END;
