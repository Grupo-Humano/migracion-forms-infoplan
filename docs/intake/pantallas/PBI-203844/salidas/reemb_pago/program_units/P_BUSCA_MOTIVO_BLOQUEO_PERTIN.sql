-- PROGRAM UNIT: P_BUSCA_MOTIVO_BLOQUEO_PERTIN
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_BUSCA_MOTIVO_BLOQUEO_PERTIN(P_TIPO_BLOQUEO    IN VARCHAR2, 
                                        P_CODIGO_AFILIADO IN VARCHAR2,
                                        P_DIAGNOSTICO     IN VARCHAR2, 
                                        P_SERVICIO        IN NUMBER,
                                        P_TIP_COB         IN NUMBER, 
                                        P_COBERTURA       IN NUMBER) IS
  v_respuesta  NUMBER(2);
  v_cod_ase    NUMBER(10) := SUBSTR(P_CODIGO_AFILIADO, 1, LENGTH(P_CODIGO_AFILIADO)-3);
  v_sec_dep    NUMBER(3)  := SUBSTR(P_CODIGO_AFILIADO, -3);
  --
  TYPE lst_cur IS RECORD (Motivo            Number(10),
                          Comentario        Varchar2(512),
                          Accion            Number(10),
                          Comentario_accion Varchar2(512),
                          mensaje           Varchar2(512));
  v_row_mot  lst_cur;
  --
BEGIN
  PKG_MOT_BLOQUEO.P_BUSCA_MOT_BLOQ_PERTINENCIA (P_COMPANIA     => :GLOBAL.COD_COMPANIA,
                                                P_ASEGURADO    => v_cod_ase,
                                                P_DEP_USO      => v_sec_dep,
                                                P_TIPO_BLOQUEO => P_TIPO_BLOQUEO,
                                                P_DIAGNOSTICO  => P_DIAGNOSTICO,
                                                P_SERVICIO     => P_SERVICIO,
                                                P_TIP_COB      => P_TIP_COB,
                                                P_COBERTURA    => P_COBERTURA,
                                                P_MOTIVO       => v_row_mot.motivo, --OUT NUMBER,
                                                P_COMENTARIO   => v_row_mot.comentario, --OUT VARCHAR2,
                                                P_ACCION       => v_row_mot.ACCION, --OUT NUMBER,
                                                P_COMENTARIO_A => v_row_mot.comentario_accion, --OUT VARCHAR2,
                                                P_MENSAJE      => v_row_mot.mensaje, --OUT VARCHAR2,
                                                P_RESPUESTA    => v_respuesta); --OUT VARCHAR2) IS
   :MSG_BLOQUEO.TIPO_BLOQUEO := P_TIPO_BLOQUEO;
   :MSG_BLOQUEO.MOTIVO       := PKG_MOT_BLOQUEO.F_BUSCA_DSP_MOTIVO(v_row_mot.motivo);
   :MSG_BLOQUEO.COMENTARIO   := v_row_mot.comentario;
   :MSG_BLOQUEO.ACCION       := PKG_MOT_BLOQUEO.F_BUSCA_DSP_ACCION(v_row_mot.accion);
   :MSG_BLOQUEO.COMENTARIO_ACCION := v_row_mot.comentario_accion;
   :MSG_BLOQUEO.MENSAJE      :=  v_row_mot.mensaje;
   --
   IF P_DIAGNOSTICO IS NOT NULL THEN
      :MSG_BLOQUEO.COD_TIP_BLOQ := P_DIAGNOSTICO;
   END IF;
   --
   IF P_SERVICIO IS NOT NULL THEN
   	  :MSG_BLOQUEO.COD_TIP_BLOQ := P_SERVICIO;
   END IF;
   --
   IF P_TIP_COB IS NOT NULL THEN
   	  :MSG_BLOQUEO.COD_TIP_BLOQ := P_TIP_COB;
   END IF;
   --
   IF P_COBERTURA IS NOT NULL THEN
   	  :MSG_BLOQUEO.COD_TIP_BLOQ := P_COBERTURA;
   END IF;
   --
   IF P_TIPO_BLOQUEO = :FRMVAR.STR_ASEGURADO THEN
      SET_WINDOW_PROPERTY('CG$WIND_MENSAJE_BLOQ', POSITION, 2.5, 1.5); 
   ELSE
      SET_WINDOW_PROPERTY('CG$WIND_MENSAJE_BLOQ', POSITION, 2.5, 6);
      SET_ITEM_PROPERTY('MSG_BLOQUEO.COMENTARIO_ACCION', VISIBLE, PROPERTY_TRUE);
      SET_ITEM_PROPERTY('MSG_BLOQUEO.COMENTARIO_ACCION', ENABLED, PROPERTY_TRUE);
      SET_ITEM_PROPERTY('MSG_BLOQUEO.PB_VER_DETALLE', VISIBLE, PROPERTY_TRUE);
      SET_ITEM_PROPERTY('MSG_BLOQUEO.PB_VER_DETALLE', ENABLED, PROPERTY_TRUE);
   END IF;
   --
   GO_ITEM('MSG_BLOQUEO.MOTIVO');
END;

/*
IF :MSG_BLOQUEO.MOTIVO IS NOT NULL THEN
     	  ROW_POL_VIG := NULL;
     	  OPEN CUR_POL_VIG;
     	  FETCH CUR_POL_VIG INTO ROW_POL_VIG;
     	  CLOSE CUR_POL_VIG;
        --
     	  PKG_MOT_BLOQUEO.SET_VARIABLE(ROW_POL_VIG.COMPANIA, 
     	                               ROW_POL_VIG.RAMO, 
     	                               ROW_POL_VIG.SECUENCIAL);
     	  -- Enfoco 03/02/2025.- Mejoras Notificacion
        PKG_MOT_BLOQUEO.P_ENVIA_NOTIFICACION_BLOQUEO(:GLOBAL.COD_COMPANIA, 
                                                     'ASEGURADO',
                                                     :RADICACION.NUMERO_SOLICITUD,
                                                     :CG$CTRL.NO_AFI,
                                                     ROW_POL_VIG.PLAN,
                                                     v_usuario_bloq, 
                                                     v_fec_tra_bloq, 
                                                     :SOLICITUD_SERVICIO.PROVEEDOR_ID,
                                                     NULL, --P_DIAGNOSTICO
                                                     NULL, --P_SERVICIO
                                                     NULL, --P_TIP_COB
                                                     NULL);-- P_COBERTURA
     END IF;     */
