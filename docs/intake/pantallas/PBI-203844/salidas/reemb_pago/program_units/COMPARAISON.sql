-- PROGRAM UNIT: COMPARAISON
-- Tipo: Function
-- ====================================================================

Function COMPARAISON (val1 varchar2, val2 varchar2)

Return number

Is

   answer number := 0;

Begin

   if val1 = val2 then

      answer := 1;

   end if;

   return(answer);

End;
