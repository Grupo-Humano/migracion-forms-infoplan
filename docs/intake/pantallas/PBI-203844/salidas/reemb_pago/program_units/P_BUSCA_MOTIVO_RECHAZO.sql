-- PROGRAM UNIT: P_BUSCA_MOTIVO_RECHAZO
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_BUSCA_MOTIVO_RECHAZO(P_ID_RECHAZO VARCHAR2) IS
  TYPE typ_row_mot IS RECORD (motivo            Number(10),
                              Comentario        Varchar2(512),
                              Accion            Number(10),
                              Comentario_accion Varchar2(512));
  v_row_mot typ_row_mot := null;
  --
  v_cod_ase    NUMBER(10) := to_number(SUBSTR(NVL(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,:CG$CTRL.NO_AFI),1,7));
  v_sec_dep    NUMBER(3)  := to_number(SUBSTR(NVL(:SOLICITUD_SERVICIO.CODIGO_AFILIADO,:CG$CTRL.NO_AFI),8,3));
  v_respuesta  NUMBER(2);
  v_id_aseg_bloq  VARCHAR2(100) := F_OBTEN_PARAMETRO_SEUS('BLACKLIST.IDASEBLOQ', :GLOBAL.COD_COMPANIA); -- '702'
  v_id_pres_bloq  VARCHAR2(100) := F_OBTEN_PARAMETRO_SEUS('BLACKLIST.IDPREBLOQ', :GLOBAL.COD_COMPANIA); -- '5093'
BEGIN
  IF P_ID_RECHAZO = v_id_aseg_bloq THEN
     PKG_MOT_BLOQUEO.P_BUSCA_MOT_BLOQ_ASEGURADO(:GLOBAL.COD_COMPANIA,
                                                v_cod_ase, 
                                                v_sec_dep,
                                                v_row_mot.motivo,            --OUT
                                                v_row_mot.comentario,        --OUT
                                                v_row_mot.accion,            --OUT,
                                                v_row_mot.comentario_accion, --OUT
                                                v_respuesta                  --OUT
                                                );
  END IF;
  --
  IF P_ID_RECHAZO = v_id_pres_bloq THEN
     PKG_MOT_BLOQUEO.P_BUSCA_MOT_BLOQ_PRESTADOR(:GLOBAL.COD_COMPANIA,
                                                0,--:SOLICITUD_SERVICIO_DETALLE.COD_PROV, 
                                                :SOLICITUD_SERVICIO_DETALLE.PROVEEDOR_ID,
                                                v_row_mot.motivo,            --OUT
                                                v_row_mot.comentario,        --OUT
                                                v_row_mot.accion,            --OUT,
                                                v_row_mot.comentario_accion, --OUT
                                                v_respuesta                  --OUT
                                                );
  END IF;
  --
  IF v_row_mot.motivo IS NOT NULL THEN
     :CG$CTRL.MOTIVO_RECHAZO     := PKG_MOT_BLOQUEO.F_BUSCA_DSP_MOTIVO(v_row_mot.motivo);
     :CG$CTRL.COMENTARIO_RECHAZO := v_row_mot.comentario;
     :CG$CTRL.ACCION_RECHAZO     := PKG_MOT_BLOQUEO.F_BUSCA_DSP_ACCION(v_row_mot.accion);
     --
     SET_ITEM_PROPERTY('CG$CTRL.MOTIVO_RECHAZO', VISIBLE, PROPERTY_TRUE);
     SET_ITEM_PROPERTY('CG$CTRL.MOTIVO_RECHAZO', ENABLED, PROPERTY_TRUE);
     SET_ITEM_PROPERTY('CG$CTRL.COMENTARIO_RECHAZO', VISIBLE, PROPERTY_TRUE);
     SET_ITEM_PROPERTY('CG$CTRL.COMENTARIO_RECHAZO', ENABLED, PROPERTY_TRUE);
     SET_ITEM_PROPERTY('CG$CTRL.ACCION_RECHAZO', VISIBLE, PROPERTY_TRUE);
     SET_ITEM_PROPERTY('CG$CTRL.ACCION_RECHAZO', ENABLED, PROPERTY_TRUE);
  END IF;
END;
