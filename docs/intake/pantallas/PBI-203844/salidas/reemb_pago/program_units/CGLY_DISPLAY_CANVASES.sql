-- PROGRAM UNIT: CGLY$DISPLAY_CANVASES
-- Tipo: Procedure
-- ====================================================================

/* CGLY$DISPLAY_CANVASES */
PROCEDURE CGLY$DISPLAY_CANVASES(
   P_CANVAS_LIST    IN OUT VARCHAR2      /* List of displayed canvases */
  ,P_CURRENT_CANVAS IN     VARCHAR2      /* Current canvas             */
  ,P_BASE_CANVAS    IN     VARCHAR2) IS  /* Base canvas                */
/* Display the current canvas plus any others in the canvas list */
  canvas_list VARCHAR2(255);  /* List of displayed canvases */
  canvas_to_raise VARCHAR2(255);  /* Canvas to raise to the top */
BEGIN
  IF ( P_CURRENT_CANVAS = P_BASE_CANVAS) THEN
    P_CANVAS_LIST := P_CURRENT_CANVAS || ',';
  ELSE
    P_CANVAS_LIST := replace(P_CANVAS_LIST, P_CURRENT_CANVAS || ',');
    IF ( get_view_property(P_BASE_CANVAS, VISIBLE) = 'FALSE') THEN
      canvas_list := P_CANVAS_LIST;
      WHILE (canvas_list IS NOT NULL) LOOP
        canvas_to_raise := substr(canvas_list, 1, instr(canvas_list,
            ','));
        canvas_list := replace(canvas_list, canvas_to_raise);
        CGLY$RAISE_CANVAS(rtrim(canvas_to_raise, ','));
      END LOOP;
    END IF;
    P_CANVAS_LIST := P_CANVAS_LIST || P_CURRENT_CANVAS || ',';
  END IF;
  CAMBIA_COLOR_HEADER; --jose a. jimenez 15072020
  CGLY$RAISE_CANVAS(P_CURRENT_CANVAS);
END;
