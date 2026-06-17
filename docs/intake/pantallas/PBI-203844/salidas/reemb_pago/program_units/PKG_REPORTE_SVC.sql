-- PROGRAM UNIT: PKG_REPORTE_SVC
-- Tipo: Package Body
-- ====================================================================

PACKAGE BODY PKG_REPORTE_SVC IS
  PROCEDURE GENERAR(P_REPORTE IN VARCHAR2, P_DESCARGAR IN BOOLEAN default false) IS 
   -- v_host varchar2(100) := 'http://172.24.205.118:8090';                               
    
    v_paramDescarga VARCHAR2(20) := 'download=true';
  	v_url varchar2(4000);
  	v_params varchar2(2000) := '';
  	INVALID_ARGUMENT_EXCEPTION EXCEPTION;
    V_COMPANIA_30 NUMBER:=DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('COMPANIA_ASEGURADORA', 30);
    V_COMPANIA_96 NUMBER:=DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('COMPANIA_ARS', 96);
    V_FORMA_PAG VARCHAR2(100):=DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('FORMA_PAGO', :GLOBAL.COD_COMPANIA);
    v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('DIR_REP_INNOVA', :GLOBAL.COD_COMPANIA);

    
    CURSOR CUR_DESC_BANCO IS 
    SELECT DESCRIPCION  
    FROM BANCO_NUM_CTA 
    WHERE to_char(CODIGO)= :RADICACION.BANCO;
    
    V_BANCO VARCHAR2(1000);
    
    -- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (21/01/2023). CAMBIO DE ESTRUCTURA Y CAMPOS
    CURSOR CUR_BUSCA_SUC IS 
   	SELECT  S.NOMBRE 
		 FROM USUARIO_SUCURSAL_REEMBOLSO M, SUCURSAL_REEMBOLSO S
		WHERE M.SUCURSAL_ID = S.ID
		AND M.USUARIO = USER
		AND ROWNUM = 1;
    
    V_SUC VARCHAR2(1000);
    
    CURSOR CUR_TIP_CUENTA IS 
    SELECT DECODE(:RADICACION.TIPO_CUENTA,'A','AHORRO','CORRIENTE') 
    FROM DUAL;
    
    
   V_TIPO_CUENTA VARCHAR2(200);
   
   cursor CUR_PLAN is 
    SELECT    DISTINCT pl.codigo,
               pl.descripcion
          FROM Ase_Pol              Ap,
               Poliza               P,
               Asegurado            A,
               Cliente              C,
               Maestro_Grupo_Planes Ma,
               Plan                 Pl,
               Sub_Ramo             Sb,
               Estatus              E
         WHERE ap.compania = p.compania
           AND ap.ramo = p.ramo
           AND ap.secuencial = p.secuencial
           and ap.compania =v_compania_30 --nvl(:GLOBAL.COD_COMPANIA,ap.compania)
          -- AND ap.compania = nvl(vCia_ARSH,ap.compania)
           AND p.sub_ram = SB.CODIGO
           AND ap.estatus = e.codigo
           AND e.tipo = 'ASE_POL'
           AND e.val_log = 'T'
           AND ap.fec_ver =
               (SELECT MAX(b.fec_ver)
                  FROM ase_pol b
                 WHERE b.asegurado = ap.asegurado
                   AND b.compania = ap.compania
                   AND b.ramo = ap.ramo
                   AND b.secuencial = ap.secuencial
                   AND b.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.fec_ver =
               (SELECT MAX(p1.fec_ver)
                  FROM poliza p1
                 WHERE p1.compania = p.compania
                   AND p1.ramo = p.ramo
                   AND p1.secuencial = p.secuencial
                   AND p1.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.estatus IN (SELECT e2.codigo
                               FROM estatus e2
                              WHERE e2.tipo = 'POLIZA'
                                AND e2.val_log = 'T')
                               
           AND p.cliente = c.codigo
           AND ap.plan = pl.codigo
           AND ma.codigo = pl.tip_pla
           AND ap.asegurado = a.codigo
           AND ap.asegurado = :CG$CTRL.asegurado
           union all
            SELECT    DISTINCT pl.codigo,
               pl.descripcion
          FROM Ase_Pol              Ap,
               Poliza               P,
               Asegurado            A,
               Cliente              C,
               Maestro_Grupo_Planes Ma,
               Plan                 Pl,
               Sub_Ramo             Sb,
               Estatus              E
         WHERE ap.compania = p.compania
           AND ap.ramo = p.ramo
           AND ap.secuencial = p.secuencial
          and ap.compania =v_compania_96
          -- AND ap.compania = nvl(vCia_ARSH,ap.compania)
           AND p.sub_ram = SB.CODIGO
           AND ap.estatus = e.codigo
           AND e.tipo = 'ASE_POL'
           AND e.val_log = 'T'
           AND ap.fec_ver =
               (SELECT MAX(b.fec_ver)
                  FROM ase_pol b
                 WHERE b.asegurado = ap.asegurado
                   AND b.compania = ap.compania
                   AND b.ramo = ap.ramo
                   AND b.secuencial = ap.secuencial
                   AND b.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.fec_ver =
               (SELECT MAX(p1.fec_ver)
                  FROM poliza p1
                 WHERE p1.compania = p.compania
                   AND p1.ramo = p.ramo
                   AND p1.secuencial = p.secuencial
                   AND p1.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.estatus IN (SELECT e2.codigo
                               FROM estatus e2
                              WHERE e2.tipo = 'POLIZA'
                                AND e2.val_log = 'T')
                               
           AND p.cliente = c.codigo
           AND ap.plan = pl.codigo
           AND ma.codigo = pl.tip_pla
           AND ap.asegurado = a.codigo
           AND ap.asegurado = :CG$CTRL.asegurado
    union all
        SELECT DISTINCT 
               pl.codigo,
               pl.descripcion             
          FROM Dep_Pol              Dp,
               Poliza               P,
               Dependiente          A,
               Cliente              C,
               Maestro_Grupo_Planes Ma,
               Plan                 Pl,
               Sub_Ramo             Sb,
               Estatus              E
         WHERE Dp.compania = p.compania
           AND Dp.ramo = p.ramo
           AND Dp.secuencial = p.secuencial
          and dp.compania = v_compania_30
         --  AND Dp.compania = nvl(vCia_ARSH,Dp.compania)
           AND p.sub_ram = sb.codigo
           AND Dp.estatus = e.codigo
           AND e.tipo = 'DEP_POL'
           AND e.val_log = 'T'
           AND Dp.fec_ver =
               (SELECT MAX(b.fec_ver)
                  FROM dep_pol b
                 WHERE b.compania = Dp.compania
                   AND b.ramo = Dp.ramo
                   AND b.secuencial = Dp.secuencial
                   AND b.asegurado = Dp.asegurado
                   AND b.dependiente = Dp.dependiente
                   AND b.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.fec_ver =
               (SELECT MAX(p1.fec_ver)
                  FROM poliza p1
                 WHERE p1.compania = p.compania
                   AND p1.ramo = p.ramo
                   AND p1.secuencial = p.secuencial
                   AND p1.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.estatus IN (SELECT e2.codigo
                               FROM estatus e2
                              WHERE e2.tipo = 'POLIZA'
                                AND e2.val_log = 'T')
           AND p.cliente = c.codigo
           AND Dp.plan = pl.codigo
           AND ma.codigo = pl.tip_pla
           AND Dp.asegurado = a.asegurado
           AND Dp.dependiente = a.secuencia
           AND Dp.asegurado = :CG$CTRL.asegurado
           AND Dp.dependiente = :CG$CTRL.SECUENCIA_AFI
           union all
           SELECT DISTINCT 
               pl.codigo,
               pl.descripcion             
          FROM Dep_Pol              Dp,
               Poliza               P,
               Dependiente          A,
               Cliente              C,
               Maestro_Grupo_Planes Ma,
               Plan                 Pl,
               Sub_Ramo             Sb,
               Estatus              E
         WHERE Dp.compania = p.compania
           AND Dp.ramo = p.ramo
           AND Dp.secuencial = p.secuencial
           and dp.compania = v_compania_96
         --  AND Dp.compania = nvl(vCia_ARSH,Dp.compania)
           AND p.sub_ram = sb.codigo
           AND Dp.estatus = e.codigo
           AND e.tipo = 'DEP_POL'
           AND e.val_log = 'T'
           AND Dp.fec_ver =
               (SELECT MAX(b.fec_ver)
                  FROM dep_pol b
                 WHERE b.compania = Dp.compania
                   AND b.ramo = Dp.ramo
                   AND b.secuencial = Dp.secuencial
                   AND b.asegurado = Dp.asegurado
                   AND b.dependiente = Dp.dependiente
                   AND b.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.fec_ver =
               (SELECT MAX(p1.fec_ver)
                  FROM poliza p1
                 WHERE p1.compania = p.compania
                   AND p1.ramo = p.ramo
                   AND p1.secuencial = p.secuencial
                   AND p1.fec_ver <= TRUNC(:RADICACION.fecha_apertura) + .99999)
           AND p.estatus IN (SELECT e2.codigo
                               FROM estatus e2
                              WHERE e2.tipo = 'POLIZA'
                                AND e2.val_log = 'T')
           AND p.cliente = c.codigo
           AND Dp.plan = pl.codigo
           AND ma.codigo = pl.tip_pla
           AND Dp.asegurado = a.asegurado
           AND Dp.dependiente = a.secuencia
           AND Dp.asegurado = :CG$CTRL.asegurado
           AND Dp.dependiente = :CG$CTRL.SECUENCIA_AFI;
             
     V_PLAN VARCHAR2(5000);
     V_CODIGO_PLAN NUMBER;
    v_fecha_apertura DATE:=trunc(:RADICACION.FECHA_RECEPCION);    
		v_dias number;
		v_dias_sumado number:=0;
		v_dia_semana varchar(50);
		v_fecha_rec date;

  
     
     
     CURSOR C_CUR_USUARIO IS 
     SELECT PRI_NOM||' '||PRI_APE 
      FROM USU_S_PER 
      WHERE UPPER(DESCRIPCION)=UPPER(USER);
      
      V_USUARIO VARCHAR2(2000);
      
    -- OMARLIS GOMEZ Y ANGEL CASTILLO, FOREBRA (21/01/2023). CAMBIO DE ESTRUCTURA Y CAMPOS  
    CURSOR CUR_BUSCA_CANAL_ENTREGA IS 
	    SELECT NOMBRE 
	      FROM SUCURSAL_REEMBOLSO 
	    WHERE CODIGO = :RADICACION.SUCURSAL_CHEQUE;
    
    V_CANAL_ENTREGA VARCHAR2(500);
    
    cursor c_busca_fecha_rec is
    select trunc(FECHA_RECEPCION)
    from solicitud_pago 
    where id=:RADICACION.NUMERO_SOLICITUD;
		
     
  
  	BEGIN
  		BREAK;

  		IF(P_REPORTE IS NULL) THEN
  			RAISE INVALID_ARGUMENT_EXCEPTION;
  		END IF;
  		
  		OPEN CUR_DESC_BANCO;
  		FETCH CUR_DESC_BANCO INTO V_BANCO;
  		CLOSE CUR_DESC_BANCO; 	
  		
  		OPEN CUR_BUSCA_SUC;
  		FETCH CUR_BUSCA_SUC INTO V_SUC;
  		CLOSE CUR_BUSCA_SUC;
  		
  		OPEN CUR_TIP_CUENTA;
  		FETCH CUR_TIP_CUENTA  INTO V_TIPO_CUENTA;
  		CLOSE CUR_TIP_CUENTA;	
  		
  		OPEN C_CUR_USUARIO;
  		FETCH C_CUR_USUARIO INTO V_USUARIO; 
  		CLOSE C_CUR_USUARIO;
  		
  		OPEN CUR_BUSCA_CANAL_ENTREGA;
  		FETCH CUR_BUSCA_CANAL_ENTREGA INTO V_CANAL_ENTREGA;
  		CLOSE CUR_BUSCA_CANAL_ENTREGA;

  		
      for x in CUR_PLAN LOOP
      if V_PLAN is null then 
      	V_PLAN:=X.descripcion;	
      ELSE
      	V_PLAN:=V_PLAN||' / '||X.descripcion;		
      END IF;	
      END LOOP;
      
      open c_busca_fecha_rec;
      fetch c_busca_fecha_rec into v_fecha_rec;
      close c_busca_fecha_rec;
      
     
    
          --FECHA ESTIMADA GTP
    v_fecha_apertura:=reembolso.F_CALCULAR_FECHA(v_fecha_rec);

IF :RADICACION.MEDIO_PAGO=V_FORMA_PAG THEN 

v_url :=v_host
||'&fechaApertura='||to_char(v_fecha_rec,'dd/mm/yyyy')
||'&requestId='||:RADICACION.NUMERO_SOLICITUD
||'&SolicitudOriginal='||:RADICACION.NO_SOLICITUD_ORIGINAL -- Enfoco(GM) 10/09/2024.- Proyecto Completivo Documentacion.
||'&affiliate='||REPLACE(:CG$CTRL.NOMBRE_AFILIADO,' ','%20')
||'&cardNumber='||:CG$CTRL.NO_AFI
||'&planDescripcion='||REPLACE(V_PLAN,' ','%20')
||'&refundQuantity='||:SOLICITUD_PAGO_DETALLE.CANTIDAD
||'&refundAmount='||LTRIM(TO_CHAR(:SOLICITUD_PAGO_DETALLE.MONTO,'999,999,999.00'))
||'&fechaEstimada='||to_char(v_fecha_apertura,'dd/mm/yyyy')
||'&paymentMethod='||'Cheque'
||'&branch='||REPLACE(V_SUC,' ','%20')
||'&esTransferencia='||'N'
||'&sucursal='||REPLACE(V_CANAL_ENTREGA,' ','%20')
||'&codigoBarrasUrl='||REPLACE(:RADICACION.NUMERO_SOLICITUD,' ','%20')
||'&observaciones='||REPLACE(:SOLICITUD_PAGO_DETALLE.OBSERVACION,' ','%20')
||'&name='||'voucher_refund_request_2'
||'&createdBy='||REPLACE(V_USUARIO,' ','%20');



ELSE 

v_url :=v_host
||'&fechaApertura='||to_char(:RADICACION.FECHA_APERTURA,'dd/mm/yyyy')
||'&requestId='||:RADICACION.NUMERO_SOLICITUD
||'&SolicitudOriginal='||:RADICACION.NO_SOLICITUD_ORIGINAL -- Enfoco(GM) 10/09/2024.- Proyecto Completivo Documentacion.
||'&affiliate='||REPLACE(:CG$CTRL.NOMBRE_AFILIADO,' ','%20')
||'&cardNumber='||:CG$CTRL.NO_AFI
||'&planDescripcion='||REPLACE(V_PLAN,' ','%20')
||'&refundQuantity='||:SOLICITUD_PAGO_DETALLE.CANTIDAD
||'&refundAmount='||LTRIM(TO_CHAR(:SOLICITUD_PAGO_DETALLE.MONTO,'999,999,999.00'))
||'&fechaEstimada='||to_char(v_fecha_apertura,'dd/mm/yyyy')
||'&paymentMethod='||REPLACE('Transferencia Bancaria',' ','%20')
||'&createdBy='||REPLACE(V_USUARIO,' ','%20')
||'&branch='||REPLACE(V_SUC,' ','%20')
||'&accountNumber='||:RADICACION.NUMERO_CUENTA
||'&esTransferencia='||'S'
||'&accountType='||REPLACE(V_TIPO_CUENTA,' ','%20')
||'&bankName='||REPLACE(v_banco,' ','%20')
||'&codigoBarrasUrl='||REPLACE(:RADICACION.NUMERO_SOLICITUD,' ','%20')
||'&observaciones='||REPLACE(:SOLICITUD_PAGO_DETALLE.OBSERVACION,' ','%20')
||'&name='||'voucher_refund_request_2';

END IF;
	


  	 	   	

  	 	ABRIR_NAVEGADOR(V_URL);

  EXCEPTION 
  WHEN INVALID_ARGUMENT_EXCEPTION THEN
  	NULL;
  	--Lanzar alerta
  	--Debe especificar el nombre del reporte
  END GENERAR;
  
-----------------------------------------------------------------------------------------------------------------
 PROCEDURE ReclamosSolProcesadaPagos_INF(P_USER IN VARCHAR2 default USER,P_DESCARGAR IN BOOLEAN default false) IS 
   -- v_host varchar2(100) := 'http://172.24.205.118:8090';  
   --v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('Repos_innova', :GLOBAL.COD_COMPANIA);                             
    
    v_paramDescarga VARCHAR2(20) := 'download=true';
  	v_url varchar2(4000);
  	v_params varchar2(2000) := '';
  	INVALID_ARGUMENT_EXCEPTION EXCEPTION;
    v_reporte varchar2(100):='ReclamosSolicitudProcesadaPagos_INF';
    v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('DIR_REP_INNOVA', 30);

    
    
    	    
  

  
  

BEGIN


	


v_url :=v_host
||'&name='||REPLACE(v_reporte,' ','%20')
||'&pUsuario='||P_USER
||'&P_LOGO='||'30.png';






  	 	   	
  	 	ABRIR_NAVEGADOR(V_URL);

  

  EXCEPTION 
  WHEN INVALID_ARGUMENT_EXCEPTION THEN
  	NULL;
  	--Lanzar alerta
  	--Debe especificar el nombre del reporte
  END ReclamosSolProcesadaPagos_INF;
  -------------------------------------------------------------
  PROCEDURE ReclamosSolProcesadaPagos_pri(P_USER IN VARCHAR2 default USER,P_DESCARGAR IN BOOLEAN default false) IS 
   -- v_host varchar2(100) := 'http://172.24.205.118:8090';  
   --v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('Repos_innova', :GLOBAL.COD_COMPANIA);                             
    
    v_paramDescarga VARCHAR2(20) := 'download=true';
  	v_url varchar2(4000);
  	v_params varchar2(2000) := '';
  	INVALID_ARGUMENT_EXCEPTION EXCEPTION;
    v_reporte varchar2(100):='ReclamosSolicitudProcesadaPagos_pri';
    v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('DIR_REP_INNOVA', 96);
    


BEGIN


v_url :=v_host
||'&name='||REPLACE(v_reporte,' ','%20')
||'&pUsuario='||P_USER
||'&P_LOGO='||'96.png';
	





  	 	   	
  	 	ABRIR_NAVEGADOR(V_URL);
  

  

  EXCEPTION 
  WHEN INVALID_ARGUMENT_EXCEPTION THEN
  	NULL;
  	--Lanzar alerta
  	--Debe especificar el nombre del reporte
  END ReclamosSolProcesadaPagos_pri;
  -----------------------------------------------------------------
  
-------------------------------------------CARTA DE informacion
  PROCEDURE carta_informacion_inf(P_USER IN VARCHAR2 default USER,p_trato varchar2,P_FECHA_TRA DATE,
  																p_trato_completo varchar2,p_nombre_afiliado varchar2,p_numero_afiliado varchar2,
  																p_nombre_poliza varchar2,p_direccion varchar2,p_fecha_servicio date,p_numero_contracto varchar2,p_via_entrega varchar2,
  																p_fecha_limite date,
  																p_observacion varchar2, P_CONCEPTOS VARCHAR2,P_DOCUMENTOS VARCHAR2,p_nombre_afiliado2 varchar2,	P_FECHA_RECEPCION DATE,	
  																	p_label_observaciones varchar2 default null,																
  																P_DESCARGAR IN BOOLEAN default false) IS 
   -- v_host varchar2(100) := 'http://172.24.205.118:8090';                               
    
    v_paramDescarga VARCHAR2(20) := 'download=true';
  	v_url varchar2(4000);
  	v_params varchar2(2000) := '';
  	INVALID_ARGUMENT_EXCEPTION EXCEPTION;
    v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('DIR_REP_INNOVA', :GLOBAL.COD_COMPANIA);
    v_reporte varchar2(100):='carta_solicitud_informacion_inf';
    v_logo_humano VARCHAR2(20) := '30.png';
    v_logo_primera VARCHAR2(20) := '96.png';
  V_FECHA_SERVICIO varchar2(100) :=TO_char(p_fecha_servicio,'dd/mm/yyyy');
  V_FECHA_LIMITE varchar2(100) := TO_char(p_fecha_limite,'dd/mm/yyyy');
  V_FECHA_RECEPCION varchar2(100) := TO_char(P_FECHA_RECEPCION,'dd/mm/yyyy');
  V_FECHA_TRA varchar2(100) := TO_char(P_FECHA_TRA,'dd/mm/yyyy');
  
  

  


 --of26062023
	v_asegurado varchar2(100);
	v_ramo number;
	v_compania number;
	v_secuencial number;
	
/*	cursor c_poliza is 
	SELECT X.COMPANIA,X.RAMO,X.SECUENCIAL
  FROM ASE_POL X
 WHERE X.ASEGURADO=SUBSTR(p_numero_afiliado,1,7)
 AND X.SECUENCIA=0
 UNION ALL
  SELECT X.COMPANIA,X.RAMO,X.SECUENCIAL
  FROM DEP_POL X
 WHERE X.ASEGURADO=SUBSTR(p_numero_afiliado,1,7)
 AND X.DEPENDIENTE=SUBSTR(p_numero_afiliado,8,3);*/
                                                 
begin
	/*open c_poliza;
	fetch c_poliza into v_compania,v_ramo,v_secuencial;
	close c_poliza;*/
  


v_asegurado:=substr(p_numero_afiliado,1,7);


v_url :=v_host||'&name='||REPLACE(v_reporte,' ','%20')
||'&logoUrl='||REPLACE(v_logo_humano,' ','%20')
||'&P_TRATO='||REPLACE(REPLACE(REPLACE(p_trato,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_trato,' ','%20')
||'&P_FECHA_TRA='||V_FECHA_TRA
||'&P_TRATO_COMPLETO='||REPLACE(REPLACE(REPLACE(p_trato_completo,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_trato_completo,' ','%20')
||'&P_NOMBRE_AFILIADO='||REPLACE(REPLACE(REPLACE(p_nombre_afiliado,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_nombre_afiliado,' ','%20')
||'&P_NUMERO_AFILIADO='||REPLACE(REPLACE(REPLACE(p_numero_afiliado,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_numero_afiliado,' ','%20')
||'&P_NOMBRE_POLIZA='||REPLACE(REPLACE(REPLACE(p_nombre_poliza,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_nombre_poliza,' ','%20')
||'&P_DIRECCION_AFILIADO='||REPLACE(REPLACE(REPLACE(p_direccion,'%','%25'),' ','%20'),'&','%26')--REPLACE(REPLACE(p_direccion,' ','%20'),'&','%26')
||'&P_NUMERO_CONTRACTO='||REPLACE(REPLACE(REPLACE(p_numero_contracto,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_numero_contracto,' ','%20')
||'&P_VIA_ENTREGA='||REPLACE(REPLACE(REPLACE(nvl(p_via_entrega,''),'%','%25'),' ','%20'),'&','%26')--REPLACE(REPLACE(nvl(p_via_entrega,''),' ','%20'),'&','%26')
||'&P_FECHA_SERVICIO='||V_FECHA_SERVICIO
||'&P_FECHA_LIMITE='||V_FECHA_LIMITE
||'&P_OBSERVACION='||REPLACE(REPLACE(REPLACE(p_observacion,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_observacion,' ','%20')
||'&P_CONCEPTOS='||REPLACE(REPLACE(REPLACE(P_CONCEPTOS,'%','%25'),' ','%20'),'&','%26')--REPLACE(P_CONCEPTOS,' ','%20')
||'&P_DOCUMENTOS='||REPLACE(REPLACE(REPLACE(P_DOCUMENTOS,'%','%25'),' ','%20'),'&','%26')--REPLACE(P_DOCUMENTOS,' ','%20')
||'&P_NOMBRE_AFILIADO2='||REPLACE(REPLACE(REPLACE(P_NOMBRE_AFILIADO2,'%','%25'),' ','%20'),'&','%26')--REPLACE(P_NOMBRE_AFILIADO2,' ','%20')
||'&P_FECHA_RECEPCION='||V_FECHA_RECEPCION
||'&P_LABEL_OBSERVACION='||p_label_observaciones;



  	 	   	
  	 	ABRIR_NAVEGADOR(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_URL,'#','%23'),'+','%2B'),'[','%5B'),'{','%7B'),']','%5D'),'}','%7D'),'`','%60'));
  
  

  EXCEPTION 
  WHEN INVALID_ARGUMENT_EXCEPTION THEN
  	NULL;
  	--Lanzar alerta
  	--Debe especificar el nombre del reporte
  END carta_informacion_inf;

-------------------------------------------CARTA DE DECLINACION
  PROCEDURE carta_declinacion_inf(P_USER IN VARCHAR2 default USER,p_trato varchar2,P_FECHA_TRA DATE,
  																p_trato_completo varchar2,p_nombre_afiliado varchar2,p_numero_afiliado varchar2,
  																p_nombre_poliza varchar2,p_direccion varchar2,p_numero_contracto varchar2,p_via_entrega varchar2,
  																p_fecha_servicio date,
  																p_observacion varchar2, P_CONCEPTOS VARCHAR2,	P_MOTIVOS VARCHAR2,p_nombre_afiliado2 varchar2,	P_FECHA_RECEPCION DATE,		
  																p_label_observaciones varchar2 default null,													
  																P_DESCARGAR IN BOOLEAN default false) IS 
   -- v_host varchar2(100) := 'http://172.24.205.118:8090';                               
    
    v_paramDescarga VARCHAR2(20) := 'download=true';
  	v_url varchar2(4000);
  	v_params varchar2(2000) := '';
  	INVALID_ARGUMENT_EXCEPTION EXCEPTION;
    v_host       VARCHAR2(2000) := DBAPER.PKG_GENERAL.F_OBTEN_PARAMETRO_SEUS('DIR_REP_INNOVA', :GLOBAL.COD_COMPANIA);
    v_reporte varchar2(100):='carta_declinacion_inf';
    v_logo_humano VARCHAR2(20) := '30.png';
    v_logo_primera VARCHAR2(20) := '96.png';
  	v_fecha varchar2(100):=to_char(p_fecha_servicio,'dd/mm/yyyy');
  	V_FECHA_RECEPCION varchar2(100) := TO_char(P_FECHA_RECEPCION,'dd/mm/yyyy');
  	V_FECHA_TRA varchar2(100) := TO_char(P_FECHA_TRA,'dd/mm/yyyy');


  --of26062023
	v_asegurado varchar2(100);
	v_ramo number;
	v_compania number;
	v_secuencial number;
	
/*	cursor c_poliza is 
	SELECT X.COMPANIA,X.RAMO,X.SECUENCIAL
  FROM ASE_POL X
 WHERE X.ASEGURADO=SUBSTR(p_numero_afiliado,1,7)
 AND X.SECUENCIA=0
 UNION ALL
  SELECT X.COMPANIA,X.RAMO,X.SECUENCIAL
  FROM DEP_POL X
 WHERE X.ASEGURADO=SUBSTR(p_numero_afiliado,1,7)
 AND X.DEPENDIENTE=SUBSTR(p_numero_afiliado,8,3);*/
                                                 
begin
/*	open c_poliza;
	fetch c_poliza into v_compania,v_ramo,v_secuencial;
	close c_poliza;*/

	


v_asegurado:=substr(p_numero_afiliado,1,7);

v_url :=v_host||'&name='||REPLACE(v_reporte,' ','%20')
||'&logoUrl='||REPLACE(v_logo_humano,' ','%20')
||'&P_TRATO='||REPLACE(REPLACE(REPLACE(p_trato,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_trato,' ','%20')
||'&P_FECHA_TRA='||V_FECHA_TRA
||'&P_TRATO_COMPLETO='||REPLACE(REPLACE(REPLACE(p_trato_completo,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_trato_completo,' ','%20')
||'&P_NOMBRE_AFILIADO='||REPLACE(REPLACE(REPLACE(p_nombre_afiliado,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_nombre_afiliado,' ','%20')
||'&P_NUMERO_AFILIADO='||REPLACE(REPLACE(REPLACE(p_numero_afiliado,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_numero_afiliado,' ','%20')
||'&P_NOMBRE_POLIZA='||REPLACE(REPLACE(REPLACE(p_nombre_poliza,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_nombre_poliza,' ','%20')
||'&P_DIRECCION='||REPLACE(REPLACE(REPLACE(p_direccion,'%','%25'),' ','%20'),'&','%26')--REPLACE(REPLACE(p_direccion,' ','%20'),'&','%26')
||'&P_NUMERO_CONTRACTO='||REPLACE(REPLACE(REPLACE(p_numero_contracto,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_numero_contracto,' ','%20')
||'&P_VIA_ENTREGA='||REPLACE(REPLACE(REPLACE(nvl(p_via_entrega,' '),'%','%25'),' ','%20'),'&','%26')--REPLACE(REPLACE(nvl(p_via_entrega,' '),' ','%20'),'&','%26')
||'&P_FECHA_SERVICIO='||v_fecha
||'&P_OBSERVACION='||REPLACE(REPLACE(REPLACE(p_observacion,'%','%25'),' ','%20'),'&','%26')--REPLACE(p_observacion,' ','%20')
||'&P_conceptos='||REPLACE(REPLACE(REPLACE(P_CONCEPTOS,'%','%25'),' ','%20'),'&','%26')--REPLACE(P_CONCEPTOS,' ','%20')
||'&P_MOTIVOS='||REPLACE(REPLACE(REPLACE(P_MOTIVOS,'%','%25'),' ','%20'),'&','%26')--REPLACE(P_MOTIVOS,' ','%20')
||'&P_NOMBRE_AFILIADO2='||REPLACE(REPLACE(REPLACE(P_NOMBRE_AFILIADO2,'%','%25'),' ','%20'),'&','%26')--REPLACE(P_NOMBRE_AFILIADO2,' ','%20')
||'&P_FECHA_RECEPCION='||V_FECHA_RECEPCION
||'&P_LABEL_OBSERVACION='||p_label_observaciones;




 	   	
  	 --	ABRIR_NAVEGADOR(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_URL,'#','%23'),'+','%2B'),'[','%5B'),'{','%7B'),']','%5D'),'}','%7D'));
      ABRIR_NAVEGADOR(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_URL,'#','%23'),'+','%2B'),'[','%5B'),'{','%7B'),']','%5D'),'}','%7D'),'`','%60'));
  

  EXCEPTION 
  WHEN INVALID_ARGUMENT_EXCEPTION THEN
  	NULL;
  	--Lanzar alerta
  	--Debe especificar el nombre del reporte
  END carta_declinacion_inf;  
  
  PROCEDURE ABRIR_NAVEGADOR(P_URL IN VARCHAR2) IS
    V_TIPO VARCHAR2(1) := 'C'; --E (OLE2 Edge), C (Chrome HOST)
  BEGIN
  	
   IF V_TIPO = 'E' THEN
		declare
			v_url varchar2(2000);
			browser OLE2.OBJ_TYPE;
			args OLE2.LIST_TYPE;
		begin
		 	browser := OLE2.CREATE_OBJ('Shell.Application');
			args := OLE2.create_arglist;
			ole2.add_arg(args,'microsoft-edge:'||P_URL);
			ole2.invoke(browser,'ShellExecute',args);
			ole2.destroy_arglist(args);
			ole2.release_obj(browser);
		end;
   ELSIF V_TIPO = 'C' THEN
   	--	CLIENT_HOST ('"C:\Program Files\Google\Chrome\Application\chrome.exe" --force-app-mode --new-window '|| P_URL);
   	 	client_HOST('cmd /c start chrome "'||P_URL||'"');
   		
   END IF;
  	
  END ABRIR_NAVEGADOR;
  
END;
