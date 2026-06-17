-- PROGRAM UNIT: P_BUSCA_RAZON_FALLEC
-- Tipo: Procedure
-- ====================================================================

-- Encofo(GM) 23/10/2024.- Proyecto Exgratia 
PROCEDURE P_BUSCA_RAZON_FALLEC(P_COD_ASE    IN NUMBER,   
                               P_COD_DEP    IN NUMBER, 
                               P_FALLECIDO OUT VARCHAR2, 
                               P_RAZON     OUT VARCHAR2,
                               P_FEC_TRA   OUT DATE,
                               P_USUARIO   OUT VARCHAR2) IS
  ROW_F  FALLECIDO_RAZON%ROWTYPE;
  --
  CURSOR CUR_FALLEC IS
    SELECT A.FALLECIDO, A.RAZON, A.FEC_TRA, A.USUARIO
      FROM FALLECIDO_RAZON A
     WHERE A.ASEGURADO = P_COD_ASE
       AND A.DEPENDIENTE = P_COD_DEP
       AND A.FEC_TRA = (SELECT MAX(F.FEC_TRA)
                          FROM FALLECIDO_RAZON F
                         WHERE F.ASEGURADO  = A.ASEGURADO
                           AND F.DEPENDIENTE = A.DEPENDIENTE);
BEGIN
  OPEN CUR_FALLEC;
  FETCH CUR_FALLEC INTO P_FALLECIDO, P_RAZON, P_FEC_TRA, P_USUARIO;
  CLOSE CUR_FALLEC;
END;
