-- PROGRAM UNIT: P_VALIDA_USUARIO_APROB
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_VALIDA_USUARIO_APROB(P_BLOQUE VARCHAR2, P_RAISE IN BOOLEAN) IS
  --  Proyecto Exgratia.- Enfoco 01/09/2024
  v_cob_exgratia  VARCHAR2(256) := F_OBTEN_PARAMETRO_SEUS('COB_EXGRATIA', :GLOBAL.COD_COMPANIA);
  --
  v_msg_id3        NUMBER(10) := F_OBTEN_PARAMETRO_SEUS('SPOOL_EXGRATIA.MSG3', :GLOBAL.COD_COMPANIA);
  v_msg_id4        NUMBER(10) := F_OBTEN_PARAMETRO_SEUS('SPOOL_EXGRATIA.MSG4', :GLOBAL.COD_COMPANIA);
  v_est_cob_apr   NUMBER(10) := F_OBTEN_PARAMETRO_SEUS('EST_APR_COB_SOL_REMB', :GLOBAL.COD_COMPANIA);
  v_mon_max_apr   NUMBER(12,2) := 0;
  --
  Cursor cur_usu_apr is
    Select a.mon_max 
      from reemb_usuario_aprobacion a,
           usu_s_per b
      where a.compania = :GLOBAL.COD_COMPANIA
        and a.cod_usuario = b.codigo 
        and b.descripcion = :SOLICITUD_SERVICIO_DETALLE.USU_APROB; 
BEGIN
  IF P_BLOQUE = 'SOLICITUD_SERVICIO_DETALLE' THEN
     IF :SYSTEM.RECORD_STATUS IN('NEW','INSERT') AND :SOLICITUD_SERVICIO_DETALLE.COBERTURA IS NOT NULL THEN
        IF INSTR(v_cob_exgratia,'*'||:SOLICITUD_SERVICIO_DETALLE.COBERTURA||'*') > 0 
        AND (:SOLICITUD_SERVICIO_DETALLE.USU_APROB IS NULL OR :SOLICITUD_SERVICIO_DETALLE.COMENT_SOL_SPOOL IS NULL)
        AND :SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID = v_est_cob_apr THEN
            p_imprime_mensaje(v_msg_id3, null); -- 'Debe indicar el usuario aprobador para coberturas de Exgratias.'
            IF P_RAISE THEN
               RAISE FORM_TRIGGER_FAILURE;
            END IF;
        END IF;
     END IF;
     --
     IF :SOLICITUD_SERVICIO_DETALLE.USU_APROB IS NOT NULL THEN
        OPEN cur_usu_apr;
        FETCH cur_usu_apr INTO v_mon_max_apr;
        CLOSE cur_usu_apr;
        --
        IF :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR > NVL(v_mon_max_apr,0) THEN
           p_imprime_mensaje(v_msg_id4, null); -- 'Usuario excede monto maximo de aprobacion'
        END IF;
     END IF;
  ELSE 
     GO_BLOCK('SOLICITUD_SERVICIO_DETALLE');   
     FIRST_RECORD;
     LOOP
       IF INSTR(v_cob_exgratia,'*'||:SOLICITUD_SERVICIO_DETALLE.COBERTURA||'*') > 0
       AND (:SOLICITUD_SERVICIO_DETALLE.USU_APROB IS NULL OR :SOLICITUD_SERVICIO_DETALLE.COMENT_SOL_SPOOL IS NULL)
       AND :SOLICITUD_SERVICIO_DETALLE.COBERTURA_SOL_ESTATUS_ID = v_est_cob_apr THEN
          p_imprime_mensaje(v_msg_id3, null); -- 'Debe indicar el usuario aprobador para coberturas de Exgratias.'
          GO_ITEM('SOLICITUD_SERVICIO_DETALLE.USU_APROB');
          IF P_RAISE THEN
             RAISE FORM_TRIGGER_FAILURE;
          END IF;
          --
       END IF;
       --
       IF :SOLICITUD_SERVICIO_DETALLE.USU_APROB IS NOT NULL THEN
           OPEN cur_usu_apr;
           FETCH cur_usu_apr INTO v_mon_max_apr;
           CLOSE cur_usu_apr;
           --
           IF :SOLICITUD_SERVICIO_DETALLE.MONTO_PAGAR > NVL(v_mon_max_apr,0) THEN
              p_imprime_mensaje(v_msg_id4, null); -- 'Usuario excede monto maximo de aprobacion'
              IF P_RAISE THEN
                 RAISE FORM_TRIGGER_FAILURE;
              END IF;
           END IF;
       END IF;
       --
       EXIT WHEN :SYSTEM.LAST_RECORD = 'TRUE';
       NEXT_RECORD;   
     END LOOP;
  END IF;
END;
