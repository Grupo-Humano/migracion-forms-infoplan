-- PROGRAM UNIT: P_ALERTA_MENSAJE
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_ALERTA_MENSAJE
(
  mensaje        in   varchar2, 
  tipo_mensaje   in   varchar2 
) IS
  -- 
  resultado    number;
BEGIN
  if tipo_mensaje = 'E' then
    set_alert_property( 'ALERTA_ERROR', alert_message_text, mensaje );
    resultado := Show_Alert( 'ALERTA_ERROR' ); 
  elsif tipo_mensaje = 'N' then
    set_alert_property( 'ALERTA_NOTA', alert_message_text, mensaje );
    resultado := Show_Alert( 'ALERTA_NOTA' ); 
  elsif tipo_mensaje = 'M' then
    set_alert_property( 'ALERTA_PRECAUCION', alert_message_text, mensaje );
    resultado := Show_Alert( 'ALERTA_PRECAUCION' ); 
  end if;
EXCEPTION
	when others then  	 	
       pkg_general.p_inserta_error(:CG$CTRL.programa||'P_ALERTA_MENSAJE', 
       															sqlcode, substr(sqlerrm ,1, 1000), 'Error proceso generar mensaje de alerta.');  
       --       															      
END P_ALERTA_MENSAJE;
