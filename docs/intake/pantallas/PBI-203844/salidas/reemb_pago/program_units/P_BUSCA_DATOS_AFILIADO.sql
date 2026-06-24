-- PROGRAM UNIT: P_BUSCA_DATOS_AFILIADO
-- Tipo: Procedure
-- ====================================================================

PROCEDURE P_BUSCA_DATOS_AFILIADO IS
	
	
	
	vAse NUMBER;
	vDep NUMBER;
	vIdent VARCHAR2(11);
	V_NUMERO_ANO NUMBER:= PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('P_NUMERO_ANO',:GLOBAL.COD_COMPANIA);
	V_EXISTE number;

		
		CURSOR CUR_PLASTICO(vIdent VARCHAR2) is 
		SELECT ASEGURADO, SECUENCIA
        FROM AFILIADO_PLASTICOS
        where   NUM_PLA = vIdent
     union all
     SELECT COD_ASE_LOC ASEGURADO, SEC_DEP_LOC SECUENCIA
        FROM AFILIADO_PLASTICOS_int
        where   NUM_PLA = vIdent;
        
        		--OF14092023 SE CREO ESTE CURSOR PARA BUSCAR QUE EXISTA UN ASEGURADO EN POLIZA DE HUMANO
		CURSOR C_BUSCA_ASE(P_ASEGURADO NUMBER) IS 
		SELECT 1 FROM ASE_POL
		WHERE ASEGURADO=P_ASEGURADO
		AND COMPANIA IN (30,96);
		
	  CURSOR C_BUSCA_DEP(P_ASEGURADO NUMBER,P_SECUENCIA NUMBER) IS
		SELECT 1 FROM DEP_POL
		WHERE ASEGURADO=P_ASEGURADO
		AND DEPENDIENTE=P_SECUENCIA
		AND COMPANIA IN (30,96);
        
   CURSOR CUR_DATOS_AFI IS
	  SELECT *
		FROM ASE_DEP01_V A
		WHERE A.Asegurado=vAse
		AND  A.secuencia =vDep;
		
		CURSOR CUR_BUSCA_CEDULA IS 	
		SELECT ase_dep, 
					Asegurado, 
        	Dependiente,
        	codigo_estatus,
        	codEstatusPlastico  
       FROM (SELECT 'ASEGURADO' ASE_DEP,
                       A.Codigo ASEGURADO,
                       0 DEPENDIENTE,
                       e.codigo codigo_estatus,
                       INNOVACORE.PKG_INNOVA.f_valida_plastico_fec_ser(TRUNC(SYSDATE),afi_pla.num_pla) codEstatusPlastico,
                       TRUNC(afi_pla.fec_ver) FechaPlastico,
                       AP.FEC_TRA FEC_TRA_VIGENCIA
                  FROM ASEGURADO A,
                       ASE_POL            Ap,
                       estatus            e,
                       afiliado_plasticos afi_pla
                 WHERE a.ced_act = vIdent
                   AND e.codigo = ap.Estatus
                   AND e.tipo = 'ASE_POL'
                   AND afi_pla.asegurado = A.CODIGO
                   AND afi_pla.secuencia = 0
                   and ap.compania = Nvl(:GLOBAL.COD_COMPANIA,ap.compania )
                   AND afi_pla.fec_ver =
                       (SELECT MAX(z.fec_ver)
                          FROM afiliado_plasticos z
                         WHERE z.asegurado = afi_pla.asegurado
                           AND z.secuencia = afi_pla.secuencia
                           AND z.num_pla = afi_pla.num_pla
                           AND (TRUNC(z.fec_ver) <= TRUNC(SYSDATE) 
                           		/*OR
                               EXTRACT(YEAR FROM z.fec_Ver) = V_NUMERO_ANO */
                               )
                               ) --3000
                   AND afi_pla.fec_u_act =
                       (SELECT MAX(z.fec_u_act) d
                          FROM afiliado_plasticos z
                         WHERE z.asegurado = afi_pla.asegurado
                           AND z.secuencia = afi_pla.secuencia
                           AND z.num_pla = afi_pla.num_pla
                           AND z.fec_ver = afi_pla.fec_ver
                           AND (TRUNC(z.fec_ver) <= TRUNC(SYSDATE) 
                           /*OR
                               EXTRACT(YEAR FROM z.fec_Ver) = V_NUMERO_ANO*/
                                ))
                   AND A.Codigo = Ap.Asegurado
                   AND Ap.Fec_Ver =
                       (SELECT MAX(A1.Fec_Ver)
                          FROM Ase_Pol A1
                         WHERE A1.Compania = Ap.Compania
                           AND A1.Ramo = Ap.Ramo
                           AND A1.Secuencial = Ap.Secuencial
                           AND A1.Asegurado = Ap.Asegurado
                           AND TRUNC(a1.fec_ver) <= TRUNC(SYSDATE))
                UNION ALL               
                SELECT 'DEPENDIENT' ASE_DEP,
                       D.ASEGURADO,
                       D.Secuencia DEPENDIENTE,
                        e.codigo codigo_estatus,
                       INNOVACORE.PKG_INNOVA.f_valida_plastico_fec_ser(TRUNC(SYSDATE),afi_pla.num_pla) codEstatusPlastico,
                       TRUNC(afi_pla.fec_ver) FechaPlastico,
                            DP.FEC_TRA FEC_TRA_VIGENCIA
                  FROM DEPENDIENTE D,
                       PARENTEZCO  P,
                       Dep_Pol            Dp,
                       Asegurado          A,
                       estatus            e,
                       afiliado_plasticos afi_pla
                 WHERE D.PARENTEZCO = P.Codigo
                   AND d.ced_act = vIdent
                   AND afi_pla.asegurado = d.ASEGURADO
                   AND afi_pla.secuencia = D.SECUENCIA
                   and dp.compania = Nvl(:GLOBAL.COD_COMPANIA,dp.compania)
                   AND afi_pla.fec_ver =
                       (SELECT MAX(z.fec_ver)
                          FROM afiliado_plasticos z
                         WHERE z.asegurado = afi_pla.asegurado
                           AND z.secuencia = afi_pla.secuencia
                           AND z.num_pla = afi_pla.num_pla
                           AND (TRUNC(z.fec_ver) <= TRUNC(SYSDATE) 
                           /*OR
                               EXTRACT(YEAR FROM z.fec_Ver) = V_NUMERO_ANO */
                               )) --3000
                   AND afi_pla.fec_u_act =
                       (SELECT MAX(z.fec_u_act) d
                          FROM afiliado_plasticos z
                         WHERE z.asegurado = afi_pla.asegurado
                           AND z.secuencia = afi_pla.secuencia
                           AND z.num_pla = afi_pla.num_pla
                           AND z.fec_ver = afi_pla.fec_ver)
                   AND A.codigo = D.Asegurado
                   AND D.Asegurado = Dp.Asegurado
                   AND D.Secuencia = Dp.Dependiente
                   AND e.codigo = Dp.Estatus
                   AND e.tipo = 'DEP_POL'
                   AND Dp.Fec_Ver =
                       (SELECT MAX(Dp1.Fec_Ver)
                          FROM Dep_Pol Dp1
                         WHERE Dp1.Compania = Dp.Compania
                           AND Dp1.Ramo = Dp.Ramo
                           AND Dp1.Secuencial = Dp.Secuencial
                           AND Dp1.Asegurado = Dp.Asegurado
                           AND Dp1.Dependiente = Dp.Dependiente
                           AND TRUNC(Dp1.fec_ver) <= TRUNC(SYSDATE)
                           )
   UNION ALL 
               SELECT 'ASEGURADO' ASE_DEP,
                       A.Codigo ASEGURADO,
                       0 DEPENDIENTE,
                       e.codigo codigo_estatus,
                       INNOVACORE.PKG_INNOVA.F_VALIDA_PLASTICO_FEC_SER_INT(TRUNC(SYSDATE),afi_pla.num_pla) codEstatusPlastico,
                       TRUNC(afi_pla.fec_ver) FechaPlastico,
                       AP.FEC_TRA FEC_TRA_VIGENCIA
                  FROM ASEGURADO A,
                       ASE_POL            Ap,
                       estatus            e,
                       afiliado_plasticos_int afi_pla
                 WHERE a.ced_act = vIdent
                   AND e.codigo = ap.Estatus
                   AND e.tipo = 'ASE_POL'
                   AND afi_pla.COD_ASE_LOC = A.CODIGO
                   AND afi_pla.SEC_DEP_LOC = 0
                   and ap.compania = Nvl(:GLOBAL.COD_COMPANIA,ap.compania )
                   AND afi_pla.fec_ver =
                       (SELECT MAX(z.fec_ver)
                          FROM afiliado_plasticos_int z
                         WHERE Z.COD_ASE_LOC = afi_pla.COD_ASE_LOC
		                   AND nvl(z.SEC_DEP_LOC,0) = nvl(afi_pla.SEC_DEP_LOC,0)
                           AND z.num_pla = afi_pla.num_pla
                           AND (TRUNC(z.fec_ver) <= TRUNC(SYSDATE) 
                           		/*OR
                               EXTRACT(YEAR FROM z.fec_Ver) = V_NUMERO_ANO */
                               )
                               ) --3000
                   AND afi_pla.fec_u_act =
                       (SELECT MAX(z.fec_u_act) d
                          FROM afiliado_plasticos_int z
                         WHERE Z.COD_ASE_LOC = afi_pla.COD_ASE_LOC
		                   AND nvl(z.SEC_DEP_LOC,0) = nvl(afi_pla.SEC_DEP_LOC,0)
                           AND z.num_pla = afi_pla.num_pla
                           AND z.fec_ver = afi_pla.fec_ver
                           AND (TRUNC(z.fec_ver) <= TRUNC(SYSDATE) 
                           /*OR
                               EXTRACT(YEAR FROM z.fec_Ver) = V_NUMERO_ANO*/
                                ))
                   AND A.Codigo = Ap.Asegurado
                   AND Ap.Fec_Ver =
                       (SELECT MAX(A1.Fec_Ver)
                          FROM Ase_Pol A1
                         WHERE A1.Compania = Ap.Compania
                           AND A1.Ramo = Ap.Ramo
                           AND A1.Secuencial = Ap.Secuencial
                           AND A1.Asegurado = Ap.Asegurado
                           AND TRUNC(a1.fec_ver) <= TRUNC(SYSDATE))
            UNION ALL               
                SELECT 'DEPENDIENT' ASE_DEP,
                       D.ASEGURADO,
                       D.Secuencia DEPENDIENTE,
                        e.codigo codigo_estatus,
                       INNOVACORE.PKG_INNOVA.f_valida_plastico_fec_ser(TRUNC(SYSDATE),afi_pla.num_pla) codEstatusPlastico,
                       TRUNC(afi_pla.fec_ver) FechaPlastico,
                            DP.FEC_TRA FEC_TRA_VIGENCIA
                  FROM DEPENDIENTE D,
                       PARENTEZCO  P,
                       Dep_Pol            Dp,
                       Asegurado          A,
                       estatus            e,
                       afiliado_plasticos_int afi_pla
                 WHERE D.PARENTEZCO = P.Codigo
                   AND d.ced_act = vIdent
                   AND afi_pla.COD_ASE_LOC = d.ASEGURADO
                   AND afi_pla.SEC_DEP_LOC = D.SECUENCIA
                   and dp.compania = Nvl(:GLOBAL.COD_COMPANIA,dp.compania)
                   AND afi_pla.fec_ver =
                       (SELECT MAX(z.fec_ver)
                          FROM afiliado_plasticos_int z
                         WHERE Z.COD_ASE_LOC = afi_pla.COD_ASE_LOC
		                   AND nvl(z.SEC_DEP_LOC,0) = nvl(afi_pla.SEC_DEP_LOC,0)
                           AND z.num_pla = afi_pla.num_pla
                           AND (TRUNC(z.fec_ver) <= TRUNC(SYSDATE) 
                           /*OR
                               EXTRACT(YEAR FROM z.fec_Ver) = V_NUMERO_ANO */
                               )) --3000
                   AND afi_pla.fec_u_act =
                       (SELECT MAX(z.fec_u_act) d
                          FROM afiliado_plasticos_int z
                         WHERE Z.COD_ASE_LOC = afi_pla.COD_ASE_LOC
		                   AND nvl(z.SEC_DEP_LOC,0) = nvl(afi_pla.SEC_DEP_LOC,0)
                           AND z.num_pla = afi_pla.num_pla
                           AND z.fec_ver = afi_pla.fec_ver)
                   AND A.codigo = D.Asegurado
                   AND D.Asegurado = Dp.Asegurado
                   AND D.Secuencia = Dp.Dependiente
                   AND e.codigo = Dp.Estatus
                   AND e.tipo = 'DEP_POL'
                   AND Dp.Fec_Ver =
                       (SELECT MAX(Dp1.Fec_Ver)
                          FROM Dep_Pol Dp1
                         WHERE Dp1.Compania = Dp.Compania
                           AND Dp1.Ramo = Dp.Ramo
                           AND Dp1.Secuencial = Dp.Secuencial
                           AND Dp1.Asegurado = Dp.Asegurado
                           AND Dp1.Dependiente = Dp.Dependiente
                           AND TRUNC(Dp1.fec_ver) <= TRUNC(SYSDATE)
                           )
                  )
         ORDER BY ase_dep,codigo_estatus, codEstatusPlastico desc;         
                  
	
	R_DATOS_AFI	CUR_DATOS_AFI%ROWTYPE;
  R_DATOS_AFI_CED	CUR_BUSCA_CEDULA%ROWTYPE;
  V_valida_ase VARCHAR2(20);

BEGIN

IF 	LENGTH(:CG$CTRL.NO_AFI) <= 10 THEN --ES ASEGURADO O CARNET 

	vAse:= to_number(SUBSTR(:CG$CTRL.NO_AFI,1,7));
	vDep:= to_number(SUBSTR( :CG$CTRL.NO_AFI,8,3));
  
  OPEN CUR_DATOS_AFI;
  FETCH CUR_DATOS_AFI INTO R_DATOS_AFI;
  CLOSE CUR_DATOS_AFI;
  
  if R_DATOS_AFI.CODIGO IS NULL then 
  	
  	 OPEN CUR_PLASTICO(LPAD(:CG$CTRL.NO_AFI, 20, '0')); 
     FETCH CUR_PLASTICO INTO vAse, vDep;
     IF CUR_PLASTICO%FOUND THEN 
     	  OPEN CUR_DATOS_AFI;
  			FETCH CUR_DATOS_AFI INTO R_DATOS_AFI;
  				IF CUR_DATOS_AFI%FOUND THEN 
  				:CG$CTRL.NO_AFI:=lpad(vAse,7,'0')||'000'; 
  				END IF;
  			CLOSE CUR_DATOS_AFI;
     END IF;
     CLOSE CUR_PLASTICO;
      	
  end if;
  
    IF R_DATOS_AFI.CODIGO IS NOT NULL AND R_DATOS_AFI.TIP_ASE='DEPENDIENT'  THEN
				vDep:=0;
				OPEN CUR_DATOS_AFI;
  			FETCH CUR_DATOS_AFI INTO R_DATOS_AFI;
  			CLOSE CUR_DATOS_AFI;		
  		:CG$CTRL.NO_AFI:=lpad(vAse,7,'0')||'000';	
   END IF;
END IF;	  

IF 	LENGTH(:CG$CTRL.NO_AFI) = 11 THEN--ES CEDULA O CARNET

  vIdent:=:CG$CTRL.NO_AFI;
  
  OPEN CUR_BUSCA_CEDULA;
  FETCH CUR_BUSCA_CEDULA INTO R_DATOS_AFI_CED;
  IF CUR_BUSCA_CEDULA%FOUND THEN 
  		vAse:= R_DATOS_AFI_CED.ASEGURADO;
	    vDep:=  R_DATOS_AFI_CED.Dependiente; 
  ELSE 	
  	 OPEN CUR_PLASTICO(LPAD(:CG$CTRL.NO_AFI, 20, '0')); 
     FETCH CUR_PLASTICO INTO vAse, vDep;
     CLOSE CUR_PLASTICO;
  END IF;
  CLOSE CUR_BUSCA_CEDULA;
  
  IF vAse IS NOT NULL THEN 
    :CG$CTRL.NO_AFI:=lpad(vAse,7,'0')||'000'; 
  	vDep:=0;
		OPEN CUR_DATOS_AFI;
  	FETCH CUR_DATOS_AFI INTO R_DATOS_AFI;
  	CLOSE CUR_DATOS_AFI;
  END IF; 
  
END IF;

IF 	LENGTH(:CG$CTRL.NO_AFI) > 11 THEN  --ES CARNET
  
  

  	 OPEN CUR_PLASTICO(LPAD(:CG$CTRL.NO_AFI, 20, '0')); 
     FETCH CUR_PLASTICO INTO vAse, vDep;
     CLOSE CUR_PLASTICO;
	 
	  IF vAse IS NOT NULL THEN 
		    :CG$CTRL.NO_AFI:=lpad(vAse,7,'0')||'000'; 
		  	vDep:=0;
				OPEN CUR_DATOS_AFI;
		  	FETCH CUR_DATOS_AFI INTO R_DATOS_AFI;
		  	CLOSE CUR_DATOS_AFI;
		END IF;
END IF;


  
  IF :cg$ctrl.no_afi is not null and R_DATOS_AFI.CODIGO IS NULL THEN
		p_imprime_mensaje(213, NULL);
		RAISE FORM_TRIGGER_FAILURE;
  END IF;
  
  
  --OF14092023
   IF R_DATOS_AFI.ASEGURADO > 0 AND R_DATOS_AFI.SECUENCIA=0 THEN 
  	
	  OPEN C_BUSCA_ASE(R_DATOS_AFI.ASEGURADO);
	  FETCH C_BUSCA_ASE INTO V_EXISTE;
	   IF C_BUSCA_ASE%NOTFOUND THEN
	   		MSG_ALERT('Este asegurado no posee una poliza de Humano','E',TRUE);
	   END IF;
	  CLOSE C_BUSCA_ASE;
	  
	   ELSIF R_DATOS_AFI.ASEGURADO > 0 AND R_DATOS_AFI.SECUENCIA > 0 THEN 
	   	
	  OPEN C_BUSCA_DEP(R_DATOS_AFI.ASEGURADO,R_DATOS_AFI.SECUENCIA);
	  FETCH C_BUSCA_DEP INTO V_EXISTE;
	   IF C_BUSCA_DEP%NOTFOUND THEN
	   		MSG_ALERT('Este asegurado no posee una poliza de Humano','E',TRUE);
	   END IF;
	  CLOSE C_BUSCA_DEP;
	END IF;
  
  :CG$CTRL.NUMERO_AFILIADO := R_DATOS_AFI.CODIGO;
  :CG$CTRL.NOMBRE_AFILIADO := R_DATOS_AFI.NOMBRE;
  :CG$CTRL.COD_CLIENTE_AFILIADO := R_DATOS_AFI.CDPERSON;
  :CG$CTRL.TIPO_AFILIADO := R_DATOS_AFI.TIP_ASE;
  :CG$CTRL.ASEGURADO := R_DATOS_AFI.ASEGURADO;
  :CG$CTRL.SECUENCIA_AFI := R_DATOS_AFI.SECUENCIA;
  :CG$CTRL.CED_ACT := R_DATOS_AFI.CED_ACT;
  :CG$CTRL.PASAPORTE := R_DATOS_AFI.PASAPORTE;
  :CG$CTRL.PRI_NOM := R_DATOS_AFI.PRI_NOM;
  :CG$CTRL.SEG_NOM := R_DATOS_AFI.SEG_NOM;
  :CG$CTRL.PRI_APE := R_DATOS_AFI.PRI_APE;
  :CG$CTRL.SEG_APE := R_DATOS_AFI.SEG_APE;
  
  /*para sincronizar el usuario en SAP ecruzc*/
  V_valida_ase := PKG_SYNC_CLIENTE_SAP.CODIGO_SAP(R_DATOS_AFI.ASEGURADO,'ASEGURADO');
  
  IF NVL(V_valida_ase,0) = 0 THEN
  	
   --MSG_ALERT('Usuario no esta sincronizado en SAP.', 'I',FALSE);
    
   REEMBOLSO.SINCRONIZA_ASEGURADO_BP(R_DATOS_AFI.ASEGURADO,'ASEGURADO');
   
  END IF;
  --
  -- Enfoco (GM) 23/10/2024.- Proyecto Exgratia
  P_BUSCA_RAZON_FALLEC(:CG$CTRL.ASEGURADO,
                       :CG$CTRL.SECUENCIA_AFI, 
                       :CG$CTRL.FALLECIDO,
                       :FALLEC.RAZON_FALLECIDO,
                       :FALLEC.FEC_MODIF_FALLEC,
                       :FALLEC.USU_MODIF_FALLEC);
END;
