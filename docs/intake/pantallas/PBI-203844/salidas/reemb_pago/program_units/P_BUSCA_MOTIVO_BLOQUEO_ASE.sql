-- PROGRAM UNIT: P_BUSCA_MOTIVO_BLOQUEO_ASE
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_BUSCA_MOTIVO_BLOQUEO_ASE(P_TIPO_BLOQUEO VARCHAR2, 
                                     P_ASEGURADO    IN NUMBER, 
                                     P_DEP_USO      IN NUMBER) IS
  v_respuesta  NUMBER(2);
  v_msg_bloq   VARCHAR2(512) := F_OBTEN_PARAMETRO_SEUS('BLACKLIST.MSG_BLOQ', :GLOBAL.COD_COMPANIA);
  v_row_mot    ASEGURADO_MOTIVO_BLOQUEO%ROWTYPE;
  --
  v_ok       NUMBER := F_OBTEN_PARAMETRO_SEUS('P_RESPUESTA_OK', :GLOBAL.COD_COMPANIA);
  v_fallido  NUMBER := F_OBTEN_PARAMETRO_SEUS('P_RESPUESTA_FALLIDA', :GLOBAL.COD_COMPANIA);
BEGIN
  IF P_TIPO_BLOQUEO = :FRMVAR.STR_ASEGURADO THEN
     :MSG_BLOQUEO.MENSAJE := v_msg_bloq;
     --
     PKG_MOT_BLOQUEO.P_BUSCA_MOT_BLOQ_ASEGURADO(:GLOBAL.COD_COMPANIA,
                                                P_ASEGURADO, 
                                                P_DEP_USO,
                                                v_row_mot.motivo,            --OUT
                                                v_row_mot.comentario,        --OUT
                                                v_row_mot.accion,            --OUT,
                                                v_row_mot.comentario_accion, --OUT
                                                v_respuesta                  --OUT
                                                );
     :MSG_BLOQUEO.MOTIVO     := PKG_MOT_BLOQUEO.F_BUSCA_DSP_MOTIVO(v_row_mot.motivo);
     :MSG_BLOQUEO.COMENTARIO := v_row_mot.comentario;
     :MSG_BLOQUEO.ACCION     := PKG_MOT_BLOQUEO.F_BUSCA_DSP_ACCION(v_row_mot.accion);
     --:MSG_BLOQUEO.COMENTARIO_ACCION := v_row_mot.comentario_accion;
     :MSG_BLOQUEO.TIPO_BLOQUEO := P_TIPO_BLOQUEO;
     --
     GO_ITEM('MSG_BLOQUEO.MOTIVO');
  END IF;
END;
