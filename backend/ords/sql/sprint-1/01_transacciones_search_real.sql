-- =============================================================
-- Sprint 1: transacciones/search - SQL real validado
-- Modulo ORDS: facturacion-aprobaciones-rechazos-v1
-- Handler: transacciones/search (POST)
-- Validado via MCP el 2026-06-15 contra BD HUMANO_DESA
-- =============================================================
-- Parametros ORDS bind:
--   :fec_ini      VARCHAR2 'YYYY-MM-DD'
--   :fec_fin      VARCHAR2 'YYYY-MM-DD'
--   :cliente      NUMBER (nullable)
--   :oficial      NUMBER (nullable)
--   :gerente      NUMBER (nullable)
--   :intermediario NUMBER (nullable)
-- =============================================================

WITH poliza_info AS (
  SELECT pol.compania, pol.ramo, pol.secuencial,
         pol.estatus, pol.fre_pag
    FROM poliza01_v pol
),
pol_intermediario AS (
  SELECT pi.compania, pi.ramo, pi.secuencial, pi.intermediario
    FROM pol_int01_v pi
   WHERE NVL(pi.principal,'N') = 'S'
)
SELECT t.id_transaccion,
       TO_CHAR(t.fec_tra, 'YYYY-MM-DD')        AS fec_tra,
       t.cliente,
       t.compania,
       t.ramo,
       t.secuencial,
       t.monto,
       t.estado,
       t.codigo_rechazo,
       t.descripcion_rechazo                    AS respuesta_banco,
       t.num_autoriza,
       t.lote_id,
       pi.intermediario,
       SUBSTR(en.nombre_intermediario, 1, 100)  AS nombre_intermediario,
       SUBSTR(en.nombre_gerente, 1, 100)        AS nombre_gerente,
       SUBSTR(DECODE(clte.tipo,
                     'C', clte.nom_emp,
                     clte.pri_nom||' '||clte.pri_ape),
              1, 120)                            AS cliente_poliza,
       e.descripcion                             AS estatus_poliza,
       fp.descripcion                            AS frecuencia_pago,
       d.cdofic                                  AS oficial,
       SUBSTR(DECODE(clte2.tipo,
                     'C', clte2.nom_emp,
                     clte2.pri_nom||' '||clte2.pri_ape),
              1, 100)                            AS nombre_oficial,
       'N'                                       AS seleccion
FROM   transacciones_cobro_recurrente t
JOIN   cliente                        clte  ON clte.codigo = t.cliente
LEFT JOIN poliza_info                 pol   ON pol.compania   = t.compania
                                          AND pol.ramo       = t.ramo
                                          AND pol.secuencial = t.secuencial
LEFT JOIN estatus                     e     ON e.codigo = pol.estatus
                                          AND e.tipo   = 'POL'
LEFT JOIN pol_intermediario           pi    ON pi.compania   = t.compania
                                          AND pi.ramo       = t.ramo
                                          AND pi.secuencial = t.secuencial
LEFT JOIN int_ger_dir01_v             en    ON en.intermediario = pi.intermediario
                                          AND en.compania      = t.compania
LEFT JOIN frecuencia                  fp    ON fp.frepag_dias  = pol.fre_pag
LEFT JOIN moficial                    d     ON d.cdofic = pi.intermediario
LEFT JOIN cliente                     clte2 ON clte2.codigo = d.cdperson
WHERE  t.fec_tra BETWEEN TO_DATE(:fec_ini, 'YYYY-MM-DD')
                     AND TO_DATE(:fec_fin,  'YYYY-MM-DD') + 0.99999
  AND (:cliente       IS NULL OR t.cliente            = :cliente)
  AND (:oficial       IS NULL OR d.cdofic             = :oficial)
  AND (:gerente       IS NULL OR en.cod_ger           = :gerente)
  AND (:intermediario IS NULL OR pi.intermediario     = :intermediario)
ORDER BY t.fec_tra, t.id_transaccion
