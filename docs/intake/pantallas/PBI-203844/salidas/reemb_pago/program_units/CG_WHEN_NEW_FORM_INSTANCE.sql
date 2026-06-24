-- PROGRAM UNIT: CG$WHEN_NEW_FORM_INSTANCE
-- Tipo: Procedure
-- ====================================================================

/* CG$WHEN_NEW_FORM_INSTANCE */
PROCEDURE CG$WHEN_NEW_FORM_INSTANCE IS
BEGIN
/* CGGN$GET_DATE_AND_USER */
/* Get the current user and date; store in items for general use */
BEGIN
  DECLARE
    CURSOR C IS
      SELECT  SYSDATE, USER
      FROM    SYS.DUAL;
  BEGIN
    OPEN C;
    FETCH C
    INTO    :CG$CTRL.CGU$SYSDATE, :CG$CTRL.CGU$USER;
    IF C%NOTFOUND THEN
      message('Internal Error: No row in table SYS.DUAL');
      RAISE FORM_TRIGGER_FAILURE;
    END IF;
    CLOSE C;
  EXCEPTION
    WHEN OTHERS THEN
      CGTE$OTHER_EXCEPTIONS;
  END;
END;

/* CGLY$COPY_USER_DATE */
/* Values from USER and DATE items on page 0 in the control */
/* block will be "fired" to all other USER and DATE items   */
/* on other pages.                                          */
BEGIN
  :CG$CTRL.CG$DT := :CGU$SYSDATE;
  :CG$CTRL.CG$US := :CGU$USER;
END;

/* CGLY$INIT_CANVASES */
/* Call procedure to ensure correct canvases are visible */
	BEGIN
		CGLY$CANVAS_MANAGEMENT;
	END;

END;
