# TECHNICAL LOGIC EXTRACTION
## Formulario: rep_aprobarechazo_fmb

**Documento:** Extracción de lógica de negocio desde XML  
**Para:** Sage (Backend ORDS), Nova (Frontend React), Ivy (QA)  
**Fecha:** 2026-06-12

---

## 1. ESTRUCTURA GENERAL

### Bloques (Blocks)

```
1. CONSULTA (Input filters block)
   - Filtros: FEC_INI, FEC_INI, OFICIAL, GERENTE, INTERMEDIARIO
   - Botones: B_BUSCAR, B_REPORTE, PUSH_BUTTON331 (Jasper export)
   - Display items: NOMBRE_OFICIAL, NOMBRE_GERENTE, NOMBRE_INTERMEDIARIO
   - Helpers: B_OFICIAL, B_GERENTE, B_INTERMED (LOV buttons)

2. TRANS (Results block)
   - 22+ columnas de transacciones
   - 16 rows display count (scrollable)
   - Primary key: ID_TRANSACCION
   - Sorting: ORDER BY fec_tra, id_transaccion
   - Checkbox: SELECCION (para marcar registros)
   - Buttons: B_MARCAR, B_DESMARCAR

3. CONTROL (Unused, audit functions)
4. CG$CTRL (Global control block)
5. WEBUTIL (External library - OLE automation)
```

---

## 2. VALIDACIONES (TRIGGERS)

### 2.1 FEC_INI WHEN-VALIDATE-ITEM

**Location:** CONSULTA.FEC_INI  
**Trigger Type:** WHEN-VALIDATE-ITEM  
**Raw Code:**
```plsql
begin
  if :consulta.fec_fin is not null and :consulta.fec_ini is not null then
    --
    if (:consulta.fec_ini > :consulta.fec_fin) then
      mensaje('alerta_error', 'Fecha Desde no puede ser mayor que Fecha Hasta, favor verificar..!');
      raise form_trigger_failure;
    end if;
    --
  end if;
  --
end;
```

**Logic:**
- **When:** User leaves FEC_INI field
- **Check:** IF FEC_FIN is NOT NULL AND FEC_INI is NOT NULL THEN
- **Validate:** IF FEC_INI > FEC_FIN → ERROR
- **Error Msg:** "Fecha Desde no puede ser mayor que Fecha Hasta, favor verificar..!"
- **Action:** Block form submission (raise form_trigger_failure)

**React Implementation:**
```typescript
// Real-time validation as user types
const validateFecIni = (fecIni: Date, fecFin: Date) => {
  if (fecFin && fecIni > fecFin) {
    return "Fecha Desde no puede ser mayor que Fecha Hasta";
  }
  return null;
};
```

**ORDS Implementation:**
```sql
-- Validation at REST endpoint (defense in depth)
BEGIN
  IF p_fec_ini > p_fec_fin THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fecha Desde > Fecha Hasta');
  END IF;
END;
```

---

### 2.2 FEC_FIN WHEN-VALIDATE-ITEM

**Location:** CONSULTA.FEC_FIN  
**Trigger Type:** WHEN-VALIDATE-ITEM  
**Raw Code:**
```plsql
begin
  if :consulta.fec_fin is not null and :consulta.fec_ini is not null then
    --
    if (:consulta.fec_fin < :consulta.fec_ini) then
      mensaje('alerta_error', 'Fecha Hasta no puede ser menor que Fecha Desde, favor verificar..!');
      raise form_trigger_failure;
    end if;
    --
  end if;
  --
end;
```

**Logic:** Mirror of FEC_INI validation (inverse check)

---

### 2.3 OFICIAL WHEN-VALIDATE-ITEM (LOV Lookup)

**Location:** CONSULTA.OFICIAL  
**Trigger Type:** WHEN-VALIDATE-ITEM  
**Raw Code:**
```plsql
declare
  cursor c_datos is
    select substr(decode(clte.tipo,'C',clte.nom_emp,clte.pri_nom||' '||clte.pri_ape),1,100) nombre_oficial
    from cliente   clte,
         moficial   d
    where clte.codigo = d.cdperson
      and d.cdofic    = :consulta.oficial
      and d.estatus   = 76;  -- vigente

-- cuerpo
begin
  if :consulta.oficial is not null then
    open c_datos;
    fetch c_datos into :consulta.nombre_oficial;
    close c_datos;
    --
  else
    :consulta.nombre_oficial  := null;
  end if;
  --
end;
```

**Logic:**
- **When:** User selects or enters OFICIAL code
- **Query Tables:**
  - `CLIENTE` (master cliente)
  - `MOFICIAL` (master oficiales/ejecutivos)
- **Join:** CLIENTE.CODIGO = MOFICIAL.CDPERSON
- **Filter:** MOFICIAL.CDOFIC = input value AND MOFICIAL.ESTATUS = 76 (vigente/active)
- **Output:** NOMBRE_OFICIAL (display name)
- **Logic:** 
  - IF type = 'C' (Corporate) → use NOM_EMP (company name)
  - ELSE → concatenate PRI_NOM || ' ' || PRI_APE (first name + last name)
  - Max 100 characters

**React Implementation:**
```typescript
// OnChange handler for OFICIAL select
const handleOficialChange = async (oficialCode: number) => {
  try {
    const response = await fetch(`/api/oficiales/${oficialCode}`);
    if (response.ok) {
      const data = await response.json();
      setNombreOficial(data.nombre);
    } else {
      setNombreOficial(''); // Reset if not found
    }
  } catch (error) {
    console.error('Error fetching oficial', error);
  }
};
```

**ORDS Implementation:**
```sql
-- Package/Procedure in ORDS
CREATE OR REPLACE PACKAGE PKG_CONSULTA AS
  PROCEDURE GET_OFICIAL_NOMBRE(
    p_cdofic IN NUMBER,
    p_nombre OUT VARCHAR2
  );
END PKG_CONSULTA;
/

CREATE OR REPLACE PACKAGE BODY PKG_CONSULTA AS
  PROCEDURE GET_OFICIAL_NOMBRE(
    p_cdofic IN NUMBER,
    p_nombre OUT VARCHAR2
  ) AS
  BEGIN
    SELECT SUBSTR(
      DECODE(clte.tipo, 'C', clte.nom_emp, clte.pri_nom || ' ' || clte.pri_ape),
      1, 100)
    INTO p_nombre
    FROM cliente clte, moficial d
    WHERE clte.codigo = d.cdperson
      AND d.cdofic = p_cdofic
      AND d.estatus = 76;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_nombre := NULL;
  END GET_OFICIAL_NOMBRE;
END PKG_CONSULTA;
/

-- ORDS Module
BEGIN
  ORDS.CREATE_MODULE(
    p_module_name => 'CONSULTA_MOD',
    p_base_path => '/consulta/v1',
    p_pattern => 'consulta',
    p_items_per_page => 25
  );

  ORDS.CREATE_HANDLER(
    p_module_name => 'CONSULTA_MOD',
    p_pattern => 'oficial/:cdofic',
    p_method => 'GET',
    p_source => 'BEGIN
      SELECT JSON_OBJECT(
        "nombre" VALUE SUBSTR(
          DECODE(clte.tipo, "C", clte.nom_emp, clte.pri_nom || " " || clte.pri_ape),
          1, 100))
      FROM cliente clte, moficial d
      WHERE clte.codigo = d.cdperson
        AND d.cdofic = :cdofic
        AND d.estatus = 76;
    END;'
  );
END;
/
```

---

### 2.4 GERENTE WHEN-VALIDATE-ITEM

**Location:** CONSULTA.GERENTE  
**Raw Code:**
```plsql
declare
  cursor c_datos is
    select distinct substr(n.nombre_gerente,1,100) nombre
    from int_ger_dir01_v n
    where n.COMPANIA = :CG$CTRL.CODIGO_COMPANIA
      and n.cod_ger  = :consulta.gerente;

-- cuerpo
begin
  if :consulta.gerente is not null then
    open c_datos;
    fetch c_datos into :consulta.nombre_gerente;
    close c_datos;
    --
  else
    :consulta.nombre_gerente  := null;
  end if;
  --
end;
```

**Logic:**
- **Query Table:** `INT_GER_DIR01_V` (view: intermediaries, gerentes, directores)
- **Filter:**
  - COMPANIA = :CG$CTRL.CODIGO_COMPANIA (company context)
  - COD_GER = input gerente code
- **Output:** NOMBRE_GERENTE (display name)

**React Implementation:** Same pattern as OFICIAL

**ORDS Implementation:**
```sql
-- Similar to OFICIAL but uses INT_GER_DIR01_V view
ORDS.CREATE_HANDLER(
  p_module_name => 'CONSULTA_MOD',
  p_pattern => 'gerente/:cod_ger',
  p_method => 'GET',
  p_source => 'BEGIN
    SELECT JSON_OBJECT(
      "nombre" VALUE SUBSTR(n.nombre_gerente, 1, 100))
    FROM int_ger_dir01_v n
    WHERE n.compania = :compania
      AND n.cod_ger = :cod_ger;
  END;'
);
```

---

### 2.5 INTERMEDIARIO WHEN-VALIDATE-ITEM

**Location:** CONSULTA.INTERMEDIARIO  
**Pattern:** Same as GERENTE (uses INT_GER_DIR01_V, filters by INTERMEDIARIO code)

**ORDS Implementation:**
```sql
ORDS.CREATE_HANDLER(
  p_module_name => 'CONSULTA_MOD',
  p_pattern => 'intermediario/:intermediario_code',
  p_method => 'GET',
  p_source => 'BEGIN
    SELECT JSON_OBJECT(
      "nombre" VALUE SUBSTR(n.nombre_intermediario, 1, 100))
    FROM int_ger_dir01_v n
    WHERE n.compania = :compania
      AND n.intermediario = :intermediario_code;
  END;'
);
```

---

## 3. BUTTON ACTIONS (TRIGGERS)

### 3.1 B_BUSCAR (Search Button) WHEN-BUTTON-PRESSED

**Location:** CONSULTA.B_BUSCAR  
**Trigger Type:** WHEN-BUTTON-PRESSED  
**Status:** PARTIALLY TRUNCATED (see line ~120 of XML - ends with `:consulta.nombre_oficial [truncated]`)

**Visible Logic:**
```plsql
declare
   error_flag  VARCHAR2 (1)  := NULL;
   v_eleccion  number;
   al_id       Alert;
   al_button   Number;
   v_error     varchar2(500);
   v_ok        boolean := false;

-- cuerpo
begin
  --
  -- Validation 1: Dates are mandatory
  if :consulta.fec_ini is null or
     :consulta.fec_fin is null then
    mensaje('alerta_error', 'Dato Fecha es requerido para poder ejecutar la busqueda, favor verificar..!');
    raise form_trigger_failure;
    --
  end if;
  --

  -- Validation 2: ALL optional filters must not ALL be null simultaneously
  if :consulta.fec_ini is null and
     :consulta.fec_fin is null and
     :consulta.oficial is null and
     :consulta.gerente is null and
     :consulta.intermediario is null then
    --
    mensaje('alerta_error', 'Debe especificarse algún criterio de busqueda, favor verificar..!');
    raise form_trigger_failure;
    --
  end if;
  --


  -- Show confirmation dialog
  al_id := Find_Alert('ALERTA_SI_NO');
  Set_Alert_Property(al_id, alert_message_text, 'Seguro de iniciar con la Ejecución del proceso ?');
  v_eleccion := Show_Alert(al_id);
  --
  if (v_eleccion = ALERT_BUTTON1) then
    set_application_property(cursor_style,'busy');

    -- [TRUNCATED] - Presumably calls BUSCA_TRANSACCIONES stored procedure

  else
    mensaje('alerta_nota', 'Proceso cancelado..!');
  end if;
  --

end;
```

**Logic Flow:**
1. **Validate FEC_INI & FEC_FIN:** Both mandatory
2. **Validate criteria:** At least one filter must be complete (but logic seems contradictory - see below)
3. **Confirm:** Show "¿Seguro de iniciar con la Ejecución del proceso?" dialog
4. **If YES:** Set cursor to busy, execute BUSCA_TRANSACCIONES (TRUNCATED)
5. **If NO:** Show cancellation message

**Contradiction in Validation:**
```
Line 1: IF fec_ini IS NULL OR fec_fin IS NULL THEN error
  → Both dates mandatory

Line 2: IF fec_ini IS NULL AND fec_fin IS NULL AND oficial IS NULL 
        AND gerente IS NULL AND intermediario IS NULL THEN error
  → At least one MUST be complete

This is redundant: Line 1 already ensures dates are complete,
so Line 2 will never trigger.

Likely intent: Line 2 is vestigial code (copy-paste error)
OR dates alone are sufficient (no other filters needed).
```

**React Implementation:**
```typescript
const handleBuscar = async () => {
  // Validation 1: Dates mandatory
  if (!fecIni || !fecFin) {
    showError("Dato Fecha es requerido para poder ejecutar la busqueda, favor verificar..!");
    return;
  }

  // Validation 2: At least one filter (redundant but keep for safety)
  if (!fecIni && !fecFin && !oficial && !gerente && !intermediario) {
    showError("Debe especificarse algún criterio de búsqueda, favor verificar..!");
    return;
  }

  // Show confirmation
  const confirmed = await showConfirmDialog("¿Seguro de iniciar con la Ejecución del proceso?");
  if (!confirmed) {
    showInfo("Proceso cancelado..!");
    return;
  }

  // Call search API
  setLoading(true);
  try {
    const response = await fetch('/api/transacciones/search', {
      method: 'POST',
      body: JSON.stringify({
        fec_ini: fecIni,
        fec_fin: fecFin,
        oficial: oficial || null,
        gerente: gerente || null,
        intermediario: intermediario || null,
        cliente: cliente || null
      })
    });
    
    if (response.ok) {
      const data = await response.json();
      setResultados(data.records);
    } else {
      showError(await response.text());
    }
  } finally {
    setLoading(false);
  }
};
```

**ORDS Implementation (CRITICAL - TRUNCATED):**

The stored procedure `BUSCA_TRANSACCIONES` is NOT visible in XML. Must reverse-engineer.

**Expected signature:**
```sql
CREATE OR REPLACE PROCEDURE BUSCA_TRANSACCIONES(
  p_fec_ini      IN DATE,
  p_fec_fin      IN DATE,
  p_oficial      IN NUMBER DEFAULT NULL,
  p_gerente      IN NUMBER DEFAULT NULL,
  p_intermediario IN NUMBER DEFAULT NULL,
  p_cliente      IN NUMBER DEFAULT NULL,
  p_cursor       OUT SYS_REFCURSOR
) AS
BEGIN
  -- Dynamic query building based on filters
  -- Execute main transaction table query
  -- Return result set
END BUSCA_TRANSACCIONES;
```

**ORDS Module:**
```sql
ORDS.CREATE_HANDLER(
  p_module_name => 'CONSULTA_MOD',
  p_pattern => 'transacciones/search',
  p_method => 'POST',
  p_source => 'BEGIN
    BUSCA_TRANSACCIONES(
      p_fec_ini => :fec_ini,
      p_fec_fin => :fec_fin,
      p_oficial => :oficial,
      p_gerente => :gerente,
      p_intermediario => :intermediario,
      p_cliente => :cliente,
      p_cursor => :result_cursor
    );
    -- Return result_cursor as JSON array
  END;'
);
```

---

### 3.2 B_REPORTE (Export OLE) WHEN-BUTTON-PRESSED

**Location:** CONSULTA.B_REPORTE  
**Trigger Type:** WHEN-BUTTON-PRESSED  
**Raw Code:**
```plsql
declare
   error_flag  VARCHAR2 (1)  := NULL;
   v_eleccion  number;
   al_id       Alert;
   al_button   Number;
   v_error     varchar2(500);
   v_ok        boolean := false;

-- cuerpo
begin
  --
  if not(registro_seleccionado('trans')) then
    mensaje('alerta_error', 'Debe hacer una selección para poder generar el reporte, favor verificar..!');
    raise form_trigger_failure;
  end if;
  --
  al_id := Find_Alert('ALERTA_SI_NO');
  Set_Alert_Property(al_id, alert_message_text, 'Seguro de generar reporte ?');
  v_eleccion := Show_Alert(al_id);
  --
  if (v_eleccion = ALERT_BUTTON1) then
    set_application_property(cursor_style,'busy');

    -- proceder con la generacion poliza
    genera_reporte;  -- ← TRUNCATED PROCEDURE
    --

  else
    mensaje('alerta_nota', 'Proceso cancelado..!');
  end if;
  --

end;
```

**Logic:**
1. **Check selection:** Must have at least 1 row marked (SELECCION = 'S')
2. **Confirm:** "¿Seguro de generar reporte?"
3. **If YES:** Call GENERA_REPORTE procedure (TRUNCATED)
4. **If NO:** Cancel

**Problem:** GENERA_REPORTE is TRUNCATED in XML - cannot see implementation

**Known details:**
- Uses WEBUTIL (OLE automation) library
- Generates Excel file
- Downloads to user PC
- Includes all 22 columns

**React Implementation (WITH WORKAROUND):**
```typescript
const handleExportExcel = async () => {
  // Check selection
  const selectedRows = resultados.filter(r => r.seleccion === 'S');
  if (selectedRows.length === 0) {
    showError("Debe hacer una selección para poder generar el reporte, favor verificar..!");
    return;
  }

  // Confirm
  const confirmed = await showConfirmDialog("¿Seguro de generar reporte?");
  if (!confirmed) {
    showInfo("Proceso cancelado..!");
    return;
  }

  // Call export API (no OLE needed in React!)
  setLoading(true);
  try {
    const response = await fetch('/api/transacciones/export/excel', {
      method: 'POST',
      body: JSON.stringify({
        registros: selectedRows.map(r => r.id_transaccion)
      })
    });
    
    if (response.ok) {
      const blob = await response.blob();
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `reporte_${new Date().toISOString().split('T')[0]}.xlsx`;
      a.click();
    } else {
      showError("Error generating Excel");
    }
  } finally {
    setLoading(false);
  }
};
```

**ORDS Implementation (MUST reverse-engineer GENERA_REPORTE):**
```sql
CREATE OR REPLACE PROCEDURE GENERA_REPORTE(
  p_trans_ids IN TABLE OF NUMBER
) AS
BEGIN
  -- Generate Excel from TRANS data for selected IDs
  -- Return file blob or file path
END GENERA_REPORTE;

-- ORDS Module
ORDS.CREATE_HANDLER(
  p_module_name => 'CONSULTA_MOD',
  p_pattern => 'transacciones/export/excel',
  p_method => 'POST',
  p_source => 'BEGIN
    GENERA_REPORTE(:registros);
    -- Return Excel as BLOB
  END;'
);
```

---

### 3.3 PUSH_BUTTON331 (Jasper Export) WHEN-BUTTON-PRESSED

**Location:** CONSULTA.PUSH_BUTTON331 (labeled "Exportar Excel Jasper")  
**Trigger Type:** WHEN-BUTTON-PRESSED  
**Raw Code:**
```plsql
declare
   error_flag  VARCHAR2 (1)  := NULL;
   v_eleccion  number;
   al_id       Alert;
   al_button   Number;
   v_error     varchar2(500);
   v_ok        boolean := false;

-- cuerpo
begin
  debug.suspend;
  -- confirmar accion del usuario, previo ejecucion
  al_id := Find_Alert('ALERTA_SI_NO');
  Set_Alert_Property(al_id, alert_message_text, 'Seguro de generar los datos en la fecha seleccionada ?');
  v_eleccion := Show_Alert(al_id);
  --
  if (v_eleccion = ALERT_BUTTON1) then
    --
    if (:CONSULTA.FEC_INI is null and :CONSULTA.FEC_FIN is null) then
      mensaje('alerta_error', 'Debe selecionar las fechas o periodos correspondientes para poder generar el reporte, favor verificar..!');
      raise form_trigger_failure;
    end if;

    -- proceder con la generacion poliza
    set_application_property(cursor_style,'busy');
    P_JASPER_A_EXCEL(:CONSULTA.FEC_INI,:CONSULTA.FEC_FIN);  -- ← VISIBLE
    set_application_property(cursor_style,'default');
    --
    alerta_mensaje('Proceso Terminó Exitosamente.', 'N');
    --

  else
    alerta_mensaje('Proceso cancelado.! ','N');
  end if;

END;
```

**Logic:**
1. **Confirm:** "¿Seguro de generar los datos en la fecha seleccionada?"
2. **Validate dates:** FEC_INI and FEC_FIN must be complete
3. **If YES:** Call P_JASPER_A_EXCEL (passes only dates, NOT filters)
4. **Success message:** "Proceso Terminó Exitosamente."

**Key Difference from B_REPORTE:**
- Does NOT require row selection
- Only uses date range (ignores OFICIAL, GERENTE, INTERMEDIARIO filters)
- Uses Jasper Report library (presumably)

**P_JASPER_A_EXCEL Signature:**
```sql
PROCEDURE P_JASPER_A_EXCEL(
  p_fec_ini IN DATE,
  p_fec_fin IN DATE
) AS
BEGIN
  -- Generate Jasper Report for date range
  -- Output as Excel
  -- Download to user
END P_JASPER_A_EXCEL;
```

**React Implementation:**
```typescript
const handleExportJasper = async () => {
  // Confirm
  const confirmed = await showConfirmDialog("¿Seguro de generar los datos en la fecha seleccionada?");
  if (!confirmed) {
    showInfo("Proceso cancelado..!");
    return;
  }

  // Validate dates
  if (!fecIni || !fecFin) {
    showError("Debe seleccionar las fechas o periodos correspondientes...");
    return;
  }

  // Call Jasper export
  setLoading(true);
  try {
    const response = await fetch('/api/transacciones/export/jasper', {
      method: 'POST',
      body: JSON.stringify({
        fec_ini: fecIni,
        fec_fin: fecFin
      })
    });
    
    if (response.ok) {
      const blob = await response.blob();
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `reporte_jasper_${fecIni}_${fecFin}.xlsx`;
      a.click();
      showSuccess("Proceso Terminó Exitosamente.");
    }
  } finally {
    setLoading(false);
  }
};
```

---

### 3.4 B_MARCAR & B_DESMARCAR (Select All) WHEN-BUTTON-PRESSED

**Location:** CONSULTA.B_MARCAR, CONSULTA.B_DESMARCAR  
**Raw Code:**
```plsql
-- B_MARCAR
do_seleccionar('trans','M');

-- B_DESMARCAR
do_seleccionar('trans','D');
```

**Logic:**
- Calls helper function `do_seleccionar(block_name, action)`
  - Action = 'M' → Mark all (SELECCION = 'S')
  - Action = 'D' → Unmark all (SELECCION = 'N')

**Function definition (NOT in XML - in library):**
```plsql
PROCEDURE do_seleccionar(p_block VARCHAR2, p_action VARCHAR2) AS
BEGIN
  IF p_action = 'M' THEN
    UPDATE block SET seleccion = 'S' WHERE block = p_block;
  ELSIF p_action = 'D' THEN
    UPDATE block SET seleccion = 'N' WHERE block = p_block;
  END IF;
END do_seleccionar;
```

**React Implementation:**
```typescript
const handleMarcarTodas = () => {
  setResultados(
    resultados.map(r => ({ ...r, seleccion: 'S' }))
  );
};

const handleDesmarcarTodas = () => {
  setResultados(
    resultados.map(r => ({ ...r, seleccion: 'N' }))
  );
};
```

---

## 4. POST-QUERY TRIGGER (Results Population)

### 4.1 TRANS.POST-QUERY

**Location:** TRANS block (results block)  
**Trigger Type:** POST-QUERY  
**Raw Code:**
```plsql
declare
  --
  cursor c_datos_tarjeta is
    select numero_tarjeta, fecha_vence, fecha_crea
    from boveda_tarjeta b
    where b.cliente    = :trans.cliente
      and b.compania   = :trans.compania
      and b.ramo       = :trans.ramo
      and b.secuencial = :trans.secuencial
      and nvl(b.aprobado,'0') = '1'
      and nvl(b.vigente,'N')  = 'S'
      and b.token_id is not null;

-- cuerpo
begin
  -- buscar tipo tarjeta
  if :trans.compania   is not null and
     :trans.ramo       is not null and
     :trans.secuencial is not null then
    
    -- buscar informacion adicional de la tarjeta
    open c_datos_tarjeta;
    fetch c_datos_tarjeta into :trans.numero_tarjeta, :trans.fecha_vence, :trans.fecha_tokeniza;
    close c_datos_tarjeta;
    --
  end if;
  --

end;
```

**Logic:**
- **When:** After each result row is fetched from database
- **Query Table:** `BOVEDA_TARJETA` (card tokenization table)
- **Join on:** CLIENTE, COMPANIA, RAMO, SECUENCIAL
- **Filter:**
  - APROBADO = '1' (approved)
  - VIGENTE = 'S' (active/vigent)
  - TOKEN_ID IS NOT NULL (tokenized)
- **Populate:** NUMERO_TARJETA, FECHA_VENCE, FECHA_TOKENIZA

**Performance Concern:** This is N+1 query pattern (1 main query + 1 per row)
→ Could be slow with 10,000+ rows

**Recommended refactor (ORDS):**
```sql
-- Instead of POST-QUERY, join at query level
SELECT t.*, 
       b.numero_tarjeta, 
       b.fecha_vence, 
       b.fecha_crea as fecha_tokeniza
FROM transacciones t
LEFT JOIN boveda_tarjeta b ON 
  b.cliente    = t.cliente AND
  b.compania   = t.compania AND
  b.ramo       = t.ramo AND
  b.secuencial = t.secuencial AND
  NVL(b.aprobado,'0') = '1' AND
  NVL(b.vigente,'N') = 'S' AND
  b.token_id IS NOT NULL
WHERE t.fec_tra BETWEEN :fec_ini AND :fec_fin
  AND (t.oficial = :oficial OR :oficial IS NULL)
  AND (t.gerente = :gerente OR :gerente IS NULL)
  AND (t.intermediario = :intermediario OR :intermediario IS NULL)
ORDER BY t.fec_tra, t.id_transaccion;
```

---

## 5. LOVs (List of Values)

### 5.1 LOV_OFICIALES

**Source:** Record group RG_OFICIALES  
**Title:** "Listado Ejecutivos de Cobros"  
**Columns:**
- NOMBRE_OFICIAL → returns to CONSULTA.NOMBRE_OFICIAL (display)
- (implied CODE column) → returns to CONSULTA.OFICIAL (value)

**React Implementation (API endpoint):**
```typescript
// GET /api/oficiales
const fetchOficiales = async () => {
  const response = await fetch('/api/oficiales');
  const data = await response.json();
  return data.map(o => ({
    value: o.cdofic,
    label: o.nombre_oficial
  }));
};
```

### 5.2 LOV_GERENTE

**Source:** INT_GER_DIR01_V view  
**Filtered by:** COMPANIA = :CG$CTRL.CODIGO_COMPANIA

### 5.3 LOV_INTERMED

**Source:** INT_GER_DIR01_V view  
**Filtered by:** COMPANIA = :CG$CTRL.CODIGO_COMPANIA

---

## 6. DOUBLE-CLICK TRIGGER (Detail Navigation)

### 6.1 TRANS.WHEN-MOUSE-DOUBLECLICK

**Location:** TRANS block (results table)  
**Trigger Type:** WHEN-MOUSE-DOUBLECLICK  
**Raw Code:**
```plsql
declare
  pl_id       ParamList;
  v_ruta      varchar2(100) := 'C:\Trabajo\';
  P_MODULE_NAME varchar2(50) := 'ssc21100.fmx';

-- cuerpo
begin
  --
  :GLOBAL.CG$POLIZA_COMPANIA  := :TRANS.COMPANIA;
  :GLOBAL.CG$POLIZA_RAMO      := :TRANS.RAMO;
  :GLOBAL.CG$POLIZA_SECUENCIAL := :TRANS.SECUENCIAL;
  --    
  pl_id := Get_Parameter_List('tempdata');
  IF NOT Id_Null(pl_id) THEN
    Destroy_Parameter_List(pl_id);
  END IF;
  --
  hide_window('principal');
  --
  pl_id := Create_Parameter_List('tempdata');
  CALL_FORM(lower(P_MODULE_NAME),NO_HIDE,DO_REPLACE, no_query_only, pl_id);
  --
  IF NOT form_success THEN
    message('Error: Unable to call module'||' '||P_MODULE_NAME);
    RAISE FORM_TRIGGER_FAILURE;
  END IF;

end;
```

**Logic:**
- **When:** User double-clicks a result row
- **Store globals:** Set GLOBAL variables with policy details
  - CG$POLIZA_COMPANIA = COMPANIA
  - CG$POLIZA_RAMO = RAMO
  - CG$POLIZA_SECUENCIAL = SECUENCIAL
- **Navigate:** Open form `ssc21100.fmx` (policy maintenance form)
- **Parameters:** Pass via parameter list

**React Implementation:**
```typescript
const handleRowDoubleClick = (row: Transaccion) => {
  // Store policy details in state/context
  setPolicyContext({
    compania: row.compania,
    ramo: row.ramo,
    secuencial: row.secuencial
  });
  
  // Navigate to detail page
  navigate(`/poliza-maintenance/${row.compania}/${row.ramo}/${row.secuencial}`);
};
```

---

## 7. DATA SOURCE COLUMNS (From XML)

**Block:** TRANS, **Query Data Source:** DUAL (meaning query is dynamic, not based on table)

**Columns in DataSourceColumn:**
```
CLIENTE           (NUMBER, 10)
COMPANIA          (NUMBER, 3)
RAMO              (NUMBER, 3)
SECUENCIAL        (NUMBER, 8)
TOKEN_ID          (VARCHAR2, 50)
MONTO             (NUMBER, 14.2)
ITBIS             (NUMBER, 14.2)
FEC_TRA           (DATE)
ESTADO            (VARCHAR2, 5)
CODIGO_RECHAZO    (VARCHAR2, 20)
DESCRIPCION_RECHAZO (VARCHAR2, 500)
COMENT            (VARCHAR2, 500)
USER_CREA         (VARCHAR2, 15)
FECHA_CREA        (DATE)
USER_ACTUALIZA    (VARCHAR2, 15)
FECHA_ACTUALIZA   (DATE)
TERMINAL          (VARCHAR2, 100)
USER_OS           (VARCHAR2, 50)
NUM_AUTORIZA      (VARCHAR2, 20)
FECHA_APLICACION  (DATE)
MENSAJE           (VARCHAR2, 500)
CANAL             (VARCHAR2, 20)
FORMA_PAGO        (VARCHAR2, 1)
ID_TRANSACCION    (NUMBER, PRIMARY KEY)
LOTE_ID           (NUMBER, 10)
```

---

## 8. MISSING/TRUNCATED PROCEDURES

**CRITICAL UNKNOWNS:**

| Proc | Status | Impact | Needed for |
|------|--------|--------|-----------|
| BUSCA_TRANSACCIONES | ❌ TRUNCATED | Main search logic | ORDS design |
| GENERA_REPORTE | ❌ TRUNCATED | OLE Excel export | export feature |
| P_JASPER_A_EXCEL | ⚠️ PARTIAL | Jasper export | export feature |
| do_seleccionar | ❌ NOT IN XML | Mark/unmark logic | selection feature |
| mensaje | ❌ NOT IN XML | Display messages | error handling |
| registro_seleccionado | ❌ NOT IN XML | Check selection count | validation |

**Sprint 0 Archaeology Task:**
- [ ] Recover BUSCA_TRANSACCIONES source code (Sage)
- [ ] Recover GENERA_REPORTE source code (Sage)
- [ ] Find where do_seleccionar, mensaje defined (Sage + DBA)
- [ ] Document main transaction table name (DBA)

---

## 9. ALERTS/MESSAGES

**Alert Dialogs defined in XML:**

```plsql
ALERTA_SI_NO → "Sí" / "No" with title "Confirmacion"
ALERTA_ERROR → Error alert (single OK button)
ALERTA_NOTA → Note/info alert
ALERTA_PRECAUCION → Caution alert
MENSAJE → Generic message dialog
```

**Messages used in triggers:**
```
"Fecha Desde no puede ser mayor que Fecha Hasta, favor verificar..!"
"Fecha Hasta no puede ser menor que Fecha Desde, favor verificar..!"
"Dato Fecha es requerido para poder ejecutar la busqueda, favor verificar..!"
"Debe especificarse algún criterio de busqueda, favor verificar..!"
"Seguro de iniciar con la Ejecución del proceso ?"
"Debe hacer una selección para poder generar el reporte, favor verificar..!"
"Seguro de generar reporte ?"
"Seguro de generar los datos en la fecha seleccionada ?"
"Debe selecionar las fechas o periodos correspondientes para poder generar el reporte, favor verificar..!"
"Proceso Terminó Exitosamente."
"Proceso cancelado..!"
"Proceso cancelado.!"
```

---

## 10. SUMMARY: WHAT NEEDS TO BE BUILT IN ORDS & REACT

### ORDS Endpoints (Sage)

| Endpoint | Method | Params | Returns |
|----------|--------|--------|---------|
| `/consulta/v1/oficial/:cdofic` | GET | cdofic | {nombre} |
| `/consulta/v1/gerente/:cod_ger` | GET | cod_ger | {nombre} |
| `/consulta/v1/intermediario/:code` | GET | intermediario_code | {nombre} |
| `/consulta/v1/transacciones/search` | POST | {fec_ini, fec_fin, oficial?, gerente?, intermediario?, cliente?} | {records: [...], total} |
| `/consulta/v1/transacciones/export/excel` | POST | {registros: [id_trans...]} | BLOB (Excel file) |
| `/consulta/v1/transacciones/export/jasper` | POST | {fec_ini, fec_fin} | BLOB (Excel file) |

### React Components (Nova)

| Component | Purpose |
|-----------|---------|
| `DateRangeFilter` | FEC_INI + FEC_FIN with validation |
| `SelectWithLOV` | OFICIAL, GERENTE, INTERMEDIARIO with async lookup |
| `ResultsTable` | 22-column virtualized table with checkbox |
| `ExportActions` | Buttons for Excel export (OLE & Jasper) |
| `ConfirmDialog` | Modal confirmations |

---

**Document completed: Ready for Sage, Nova, Ivy**

