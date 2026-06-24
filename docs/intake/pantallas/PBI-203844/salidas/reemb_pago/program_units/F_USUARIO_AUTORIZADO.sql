-- PROGRAM UNIT: F_USUARIO_AUTORIZADO
-- Tipo: Function
-- ====================================================================

FUNCTION f_usuario_autorizado return boolean is
   -- variables
   v_resultado		boolean := false;
   
-- cuerpo   
begin
    v_resultado  := false;
    if (:CG$CTRL.usuario_autorizado = :CG$CTRL.valor_t) then
 	     v_resultado := true;
    end if;	
    return (v_resultado);
    --
    
end f_usuario_autorizado;
