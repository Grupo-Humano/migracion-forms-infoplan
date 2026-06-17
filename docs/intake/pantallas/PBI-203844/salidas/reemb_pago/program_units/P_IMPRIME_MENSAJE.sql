-- PROGRAM UNIT: P_IMPRIME_MENSAJE
-- Tipo: Procedure
-- ====================================================================

PROCEDURE p_imprime_mensaje(p_codigo_mensaje  mensaje_alerta_forma.codigo%type, p_mensaje  varchar2) is

  -- variables    
    V_MENSAJE_TEXTO MENSAJE_ALERTA_FORMA.TEXTO_MENSAJE%TYPE;
    V_TIPO             MENSAJE_ALERTA_FORMA.TIPO%TYPE;
    V_VALOR_LOGICO  MENSAJE_ALERTA_FORMA.VALOR_LOGICO%TYPE;
    V_TEXTO1        MENSAJE_ALERTA_FORMA.TEXTO1%TYPE;
    V_TEXTO2        MENSAJE_ALERTA_FORMA.TEXTO2%TYPE;
    V_TEXTO3        MENSAJE_ALERTA_FORMA.TEXTO3%TYPE;
    V_TEXTO4        MENSAJE_ALERTA_FORMA.TEXTO4%TYPE;
    V_VAL_LOG         BOOLEAN := false; 
    VN_ERROR           number;
    VC_ERROR_DESC      varchar2(2000);

 -- cuerpo
begin
 -- proceso que busca el mensaje parametrizado
 if (nvl(p_codigo_mensaje,0) != 0) then
         PKG_PARAMETRO_GENERAL_PROCESO.P_CONFIG_MENSAJE_ALERT_FORMA ( :GLOBAL.COD_COMPANIA,
                                                                      p_codigo_mensaje,  -- codigo de mensaje en la tabla MENSAJE_ALERTA_FORMA
                                                                      V_MENSAJE_TEXTO ,  -- parametro salida
                                                                      V_TIPO                    ,     -- parametro salida
                                                                      V_VALOR_LOGICO    ,     -- parametro salida
                                                                      V_TEXTO1                ,     -- parametro salida
                                                                      V_TEXTO2                ,     -- parametro salida
                                                                      V_TEXTO3                ,     -- parametro salida
                                                                      V_TEXTO4,             -- parametro salida
                                                                      NULL); --Tommy Pereyra Enfoco 31/10/2024
 -- 
     V_VAL_LOG := DBAPER.F_CONVIERTE_CHAR_BOOLEAN (V_VALOR_LOGICO);
     MSG_ALERT( V_MENSAJE_TEXTO|| ' '||
                        V_TEXTO1             || ' '||
                        V_TEXTO2             || ' '||
                        V_TEXTO3             || ' '|| V_TEXTO4,
                        V_TIPO,
                        V_VAL_LOG);
 --
 else
         MSG_ALERT(p_mensaje, 'E', FALSE);
 end if;
 --
 
EXCEPTION
   WHEN OTHERS THEN
      VN_ERROR      := DBMS_ERROR_CODE;
         VC_ERROR_DESC := SUBSTR(DBMS_ERROR_TEXT,1,1000);
         pkg_general.p_inserta_error
                                     ('REEMB_PAGO.p_imprime_mensaje',
                                       sqlcode,
                                       substr(sqlerrm, 1, 500),
                                       'Error en proceso impresion mensaje'
                                     );
   --
end p_imprime_mensaje;
