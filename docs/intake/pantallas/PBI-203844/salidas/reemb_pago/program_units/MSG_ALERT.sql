-- PROGRAM UNIT: MSG_ALERT
-- Tipo: Procedure
-- ====================================================================

procedure MSG_ALERT(
errm in char,           /* message */
errt in char,           /* message type */
rftf in boolean         /* raise form_trigger_failure ? */
) is      /* message parameters */
/*
* ----------------------------------------------------------------
* CHANGE HISTORY:
* DATE   PERSON      CHANGE
* ------ ----------- ---------------------------------------------
*
*/

alert_is alert;
alert_button number;

BEGIN
        
     IF (errt = 'F')
     THEN alert_is := FIND_ALERT('CFG_SYSTEM_ERROR');
     ELSIF (errt = 'E')
        THEN alert_is := FIND_ALERT('CFG_ERROR');
        ELSIF (errt = 'W')
           THEN alert_is := FIND_ALERT('CFG_WARNING_A');
              ELSIF (errt = 'I')
                 THEN alert_is := FIND_ALERT('CFG_INFORMATION');
                 ELSE MESSAGE(errm);
     end if;
     
     IF (errt IN ('F','E','W','I'))
     THEN SET_ALERT_PROPERTY(alert_is,ALERT_MESSAGE_TEXT,errm);
          alert_button := SHOW_ALERT(alert_is);
     END IF;

     IF (rftf)
     THEN
       RAISE FORM_TRIGGER_FAILURE;
     END IF;


END;
