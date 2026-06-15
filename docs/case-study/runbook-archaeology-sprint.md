# RUNBOOK: Archaeology Sprint (Sprint 0, Week 1)
**Objective:** Recover undocumented logic from rep_aprobarechazo_fmb before ORDS design

**Duration:** 1 week (5 days)  
**Team:** Sage (Backend lead) + Oracle DBA + Product Owner  
**Budget:** Included in $45K Sprint 0 allocation  
**Output:** 5 artifacts enabling ORDS design

---

## DAY 1-2: Recover Stored Procedures

### Task 1.1: Get BUSCA_TRANSACCIONES Full Source

**Why:** XML shows this procedure truncated. It contains the main search logic (filters, table joins, dynamic SQL).

**Steps:**

1. Connect to Oracle as SYS or DBA user
   ```sql
   sqlplus username/password@database
   ```

2. Get source code from USER_SOURCE:
   ```sql
   SELECT line, text
   FROM user_source
   WHERE name = 'BUSCA_TRANSACCIONES'
   ORDER BY line;
   ```

3. Export to text file:
   ```
   Output: BUSCA_TRANSACCIONES.sql
   ```

4. Review for:
   - [ ] Main transaction table name (e.g., TRANSACCIONES, PAGO_TX, BOVEDA_TRX)
   - [ ] All WHERE clause filters (dates, oficial, gerente, intermediario)
   - [ ] Dynamic SQL construction (risk of SQL injection?)
   - [ ] All table joins (which tables are joined?)
   - [ ] Any undocumented business rules (e.g., estatus filtering)

**Deliverable:** BUSCA_TRANSACCIONES.sql (full, untruncated)

---

### Task 1.2: Get GENERA_REPORTE Full Source

**Why:** XML shows this procedure truncated. It generates Excel export via OLE.

**Steps:**

1. Get source code:
   ```sql
   SELECT line, text
   FROM user_source
   WHERE name = 'GENERA_REPORTE'
   ORDER BY line;
   ```

2. Export to text file:
   ```
   Output: GENERA_REPORTE.sql
   ```

3. Review for:
   - [ ] OLE automation calls (CLIENT_OLE2.OBJ_TYPE usage)
   - [ ] Column ordering (which columns exported, in what order?)
   - [ ] Excel formatting (bold headers? Frozen panes? Formulas?)
   - [ ] File naming convention
   - [ ] Error handling (what if export fails?)

**Deliverable:** GENERA_REPORTE.sql (full, untruncated)

---

### Task 1.3: Get P_JASPER_A_EXCEL Full Source

**Why:** Already visible in XML but verify parameters and Jasper report name.

**Steps:**

1. Get source code (verify completeness):
   ```sql
   SELECT line, text
   FROM user_source
   WHERE name = 'P_JASPER_A_EXCEL'
   ORDER BY line;
   ```

2. Review for:
   - [ ] Jasper server URL (hardcoded or from config?)
   - [ ] Report name (rep_aprobaciones_rechazos?)
   - [ ] Parameters passed (fec_ini, fec_fin, oficial, gerente, intermediario, compania)
   - [ ] Output file format (XLS? XLSX? PDF?)
   - [ ] Temp directory (C:\temp\? Or database?)

3. Verify Jasper server details:
   ```
   Questions for Ops:
   - Is Jasper still maintained?
   - SLA / uptime %?
   - Can we retire it in 12 months?
   ```

**Deliverable:** P_JASPER_A_EXCEL.sql (verified)

---

## DAY 2-3: Identify Transaction Table

### Task 2.1: Reverse-Engineer Main Transaction Table

**Why:** BUSCA_TRANSACCIONES doesn't name its source table. Must discover.

**Steps:**

1. Search for table references in BUSCA_TRANSACCIONES SQL:
   ```sql
   -- Review BUSCA_TRANSACCIONES.sql for table aliases (t.*, a.*, b.*)
   -- Identify: "FROM t" or "FROM [TABLE_NAME] t"
   ```

2. If dynamic SQL, search for table keywords:
   ```sql
   -- Look for patterns like:
   -- 'SELECT ... FROM ' || table_name || ' WHERE'
   ```

3. Query Oracle for table existence:
   ```sql
   SELECT table_name FROM user_tables
   WHERE table_name LIKE '%TRANSACCION%'
      OR table_name LIKE '%PAGO%'
      OR table_name LIKE '%BOVEDA%'
      OR table_name LIKE '%TRX%';
   ```

4. Inspect candidate table structure:
   ```sql
   DESC TRANSACCIONES;
   -- or candidate table name
   ```

5. Verify columns match XML TRANS block:
   - fec_tra (transaction date)
   - cliente (customer code)
   - compania (company code)
   - ramo (line of business)
   - secuencial (policy sequential)
   - monto (amount)
   - estado (status)
   - descripcion_rechazo (rejection reason)
   - id_transaccion (primary key)

6. Check indexes:
   ```sql
   SELECT index_name, column_name
   FROM user_ind_columns
   WHERE table_name = 'TRANSACCIONES'
   ORDER BY index_name, column_position;
   ```

7. Estimate row count:
   ```sql
   SELECT COUNT(*) FROM TRANSACCIONES;
   SELECT COUNT(DISTINCT fec_tra) FROM TRANSACCIONES;
   ```

**Deliverable:** Transaction_Table_Schema.md
```markdown
# Transaction Table Definition

**Table Name:** TRANSACCIONES
**Primary Key:** ID_TRANSACCION
**Row Count:** ~X million
**Date Range:** YYYY-MM-DD to YYYY-MM-DD
**Indexes:**
  - IDX_TRANSACCIONES_FEC (on fec_tra)
  - IDX_TRANSACCIONES_CLIENTE (on cliente)
  ...

**Columns:**
- id_transaccion (NUMBER, PK)
- fec_tra (DATE)
- cliente (NUMBER, FK)
- compania (NUMBER, FK)
- ramo (NUMBER, FK)
- secuencial (NUMBER)
- monto (NUMBER(14,2))
- estado (VARCHAR2(5))
- descripcion_rechazo (VARCHAR2(500))
- ...

**Performance notes:**
- Typical query time: X seconds for 30-day range
- Typical page size: Y rows
```

---

## DAY 3-4: Document Business Rules

### Task 3.1: Extract Undocumented Business Rules

**Why:** Forms logic may have rules not obvious from code (e.g., "oficial must belong to compania").

**Steps:**

1. **Filter validation rules:**
   - [ ] Can user search with dates + official (AND logic)?
   - [ ] Can user search with ONLY gerente (no dates)?
   - [ ] Can user search with ALL filters empty?
   - [ ] Is there a max date range (e.g., 90 days only)?

2. **LOV filter rules:**
   - [ ] OFICIALES: Are they filtered by compania?
   - [ ] GERENTE: Filtered by compania? By intermediario?
   - [ ] INTERMEDIARIO: Any restrictions?

3. **Results display rules:**
   - [ ] Sort order: Always fec_tra ASC, id_transaccion ASC?
   - [ ] Max rows returned: Unlimited or capped at 1000?
   - [ ] Status values: What are valid ESTADO values?

4. **Export rules:**
   - [ ] B_REPORTE (OLE export): Requires selection (≥1 row)?
   - [ ] PUSH_BUTTON331 (Jasper export): Requires selection or exports all filtered?
   - [ ] Excel column order: Same as table display?

5. **Performance rules:**
   - [ ] Timeout: How long can search take?
   - [ ] Memory: If user selects all 10K rows, can system handle it?
   - [ ] Concurrent: Can 10 users search simultaneously?

**Interview Product Owner:**
```
Q1: What is the business purpose of this report?
    → Approve/reject payment transactions for recurring charges

Q2: Can user leave filter fields blank?
    → NO - at minimum, dates are required (error says "Dato Fecha es requerido")
    
Q3: What happens if search takes > 30 seconds?
    → User might retry (N+1 problem). No timeout documented.
    
Q4: Why 2 export buttons?
    → Legacy: OLE for old Excel, Jasper for newer. Might consolidate.
    
Q5: Mark/Unmark feature—how often used?
    → Unclear. Might be orphaned. QA to verify via usage logs.
```

**Deliverable:** Business_Rules.md
```markdown
# Business Rules: rep_aprobarechazo

## Filter Rules
- FEC_INI and FEC_FIN: MANDATORY
- OFICIAL, GERENTE, INTERMEDIARIO: Optional
- If all filters empty: Error (user must specify dates or criteria)
- Max date range: No documented limit (infer from performance)

## LOV Rules
- OFICIALES: Filtered by estatus = 76 (vigente)
- GERENTE: Filtered by compania = CG$CTRL.CODIGO_COMPANIA
- INTERMEDIARIO: Filtered by compania = CG$CTRL.CODIGO_COMPANIA

## Export Rules
- OLE export (B_REPORTE): Requires ≥1 selected row
- Jasper export (PUSH_BUTTON331): Uses filtered results (selection ignored)

## Performance Notes
- Typical search (30-day range): X seconds
- Large result set (1000+ rows): Consider pagination
- OLE export (500 rows): ~Y seconds (slow, row-by-row COM calls)
```

---

### Task 3.2: Get Query Performance Baseline

**Why:** React needs to match or exceed Forms performance. If Forms query takes 10 seconds, React can't be 30 seconds.

**Steps:**

1. Connect to Oracle:
   ```sql
   SET TIMING ON;
   ```

2. Run search with typical parameters:
   ```sql
   CALL BUSCA_TRANSACCIONES(
     p_fec_ini => TO_DATE('01/06/2026', 'dd/mm/yyyy'),
     p_fec_fin => TO_DATE('30/06/2026', 'dd/mm/yyyy'),
     p_oficial => 123,
     p_gerente => NULL,
     p_intermediario => NULL
   );
   ```

3. Record results:
   - [ ] Query time: X ms
   - [ ] Rows returned: Y
   - [ ] Memory used: Z MB

4. Test worst case (1000+ rows):
   - [ ] Query time: X ms
   - [ ] Rows returned: 1000+
   - [ ] Client render time (Forms): Y seconds

**Deliverable:** Performance_Baseline.md
```markdown
# Performance Baseline

## Search Query (30-day range, with oficial)
- Query time: 500 ms
- Rows returned: 127
- Memory: 2 MB

## Search Query (90-day range, no filters)
- Query time: 5000 ms
- Rows returned: 10234
- Memory: 50 MB
- Forms render: Slow (user sees lag)

## OLE Export (500 rows)
- Time: 30000 ms (30 seconds)
- Limitation: Row-by-row COM calls
- React replacement: Must be < 15 seconds (or risk timeout)

## Jasper Export (500 rows)
- Time: 8000 ms (8 seconds)
- Network latency: Jasper server response

React targets:
- Search: < 2 seconds (for 500 rows)
- Export: < 15 seconds (for 500 rows)
```

---

## DAY 4-5: Create Forms Inventory & Finalize Specs

### Task 4.1: Create Oracle Forms Inventory

**Why:** Sprint 0 said "inventory TBD by Kira." Can't plan Waves 2-3 without knowing scope.

**Steps:**

1. List all FMB files in Forms directory:
   ```bash
   ls -la *.fmb
   ```

2. For each form, extract metadata:
   - Form name (MODULE Name from XML)
   - Block count
   - Approximate complexity (simple/medium/complex)
   - Key features (report, data entry, lookup, etc.)
   - External dependencies (Jasper, WEBUTIL, custom libs)
   - Attached libraries

3. Interview Product Owner / Users:
   - Usage frequency (daily? weekly? monthly?)
   - Business criticality (must have? nice-to-have?)
   - User count
   - Known issues / pain points

**Deliverable:** Forms_Inventory.xlsx
```
| Form Name | Type | Complexity | Features | Users | Criticality |
|-----------|------|-----------|----------|-------|-------------|
| rep_aprobarechazo | Report | Medium | Search+Export | 20 | High |
| con_clientes | Lookup | Simple | Search only | 100 | Critical |
| con_polizas | Lookup | Simple | Search only | 50 | Critical |
| ent_solicitud | Data Entry | Medium | Form validation | 30 | High |
| ... | ... | ... | ... | ... | ... |
```

---

### Task 4.2: Finalize Excel Export Specification

**Why:** If GENERA_REPORTE is undocumented, need to reverse-engineer exact format.

**Steps:**

1. Generate Excel export from Forms:
   - [ ] Run form, do search, select 5 rows, click B_REPORTE
   - [ ] Generate XLS file
   - [ ] Save as: EXPORT_FORMS_REFERENCE.XLS

2. Inspect file structure:
   ```
   Using Excel or OpenPyXL:
   - Sheet name
   - Column headers (order, formatting)
   - Data rows (number, formatting)
   - Formulas (if any)
   - Frozen panes (if any)
   - Font, colors, borders
   ```

3. Document specification:
   ```markdown
   # Excel Export Format (OLE)

   ## Sheet Structure
   - Sheet name: "Reporte"
   - Headers: Row 1, bold, blue background
   - Data: Rows 2+, alternating colors

   ## Columns (in order):
   1. Fec. Trans. (dd/mm/yyyy)
   2. Cliente (number)
   3. Compania (number)
   4. Ramo (number)
   5. Secuencial (number)
   6. Monto (99,999,990.90)
   7. Estado (text)
   8. Respuesta Banco (text)
   9. Grupo (text)
   10. ... (16 more)

   ## Formatting
   - All text left-aligned except numbers (right-aligned)
   - Dates: dd/mm/yyyy
   - Amounts: 99,999,990.90
   - Borders: All cells
   - Freeze: Header row
   ```

4. Verify Jasper export matches (if possible):
   - [ ] Generate Jasper export
   - [ ] Compare column order
   - [ ] Note any differences

**Deliverable:** Excel_Export_Specification.md

---

### Task 4.3: Finalize ORDS API Contract

**Why:** Frontend (Nova) needs to know exact API signatures before coding.

**Outputs (based on archaeology):**

1. **GET /ords/api/ref-data/oficiales**
   ```json
   {
     "data": [
       { "cdofic": 123, "nombre_oficial": "Juan Perez" },
       { "cdofic": 124, "nombre_oficial": "Maria Garcia" }
     ]
   }
   ```

2. **POST /ords/api/reportes/buscar**
   ```json
   Request: {
     "fec_ini": "2026-06-01",
     "fec_fin": "2026-06-30",
     "oficial": 123,
     "gerente": null,
     "intermediario": null
   }
   Response: {
     "data": [
       { "id_transaccion": 1, "fec_tra": "2026-06-05", "cliente": 456, ... },
       ...
     ],
     "count": 127,
     "timestamp": "2026-06-12T10:30:00Z"
   }
   ```

3. **POST /ords/api/reportes/exportar-excel**
   ```json
   Request: {
     "fec_ini": "2026-06-01",
     "fec_fin": "2026-06-30",
     "oficial": 123,
     "selectedRows": [1, 2, 5, 10]
   }
   Response: Binary XLS file (multipart/form-data)
   ```

**Deliverable:** ORDS_API_Specification.md

---

## DAY 5: Finalize & Sign-Off

### Task 5.1: Compile Archaeology Report

**Create single document combining all findings:**

**Deliverables Summary:**
1. ✅ BUSCA_TRANSACCIONES.sql (untruncated)
2. ✅ GENERA_REPORTE.sql (untruncated)
3. ✅ P_JASPER_A_EXCEL.sql (verified)
4. ✅ Transaction_Table_Schema.md
5. ✅ Business_Rules.md
6. ✅ Performance_Baseline.md
7. ✅ Forms_Inventory.xlsx
8. ✅ Excel_Export_Specification.md
9. ✅ ORDS_API_Specification.md

**Compile into single report:**
```
Archaeology_Sprint_Report.md (comprehensive)
  ├── Executive Summary (findings, risks mitigated, unknowns remaining)
  ├── Transaction Table Details (schema, performance, indexing)
  ├── Business Rules (filters, LOVs, exports)
  ├── Excel Format Spec (for developers)
  ├── ORDS API Contract (for Nova)
  ├── Forms Inventory (Wave planning)
  └── Risk Assessment Update (what changed from Phase 0?)
```

---

### Task 5.2: Risk Assessment Update

**Revisit Phase 0 Risk #1: "Undocumented Forms logic"**

**Before archaeology:**
- ❌ Main transaction table unknown
- ❌ BUSCA_TRANSACCIONES logic hidden (truncated XML)
- ❌ GENERA_REPORTE logic hidden (truncated XML)
- ❌ Excel export format undocumented

**After archaeology:**
- ✅ Transaction table identified + schema documented
- ✅ BUSCA_TRANSACCIONES logic recovered + business rules extracted
- ✅ GENERA_REPORTE logic recovered + OLE behavior documented
- ✅ Excel export format reverse-engineered + specification written

**Risk status:** 🟡 REDUCED (from 🔴 CRITICAL)

**Remaining unknowns:**
- [ ] (None critical—archaeology sprint resolved all blockers)

---

### Task 5.3: Sign-Off & Handoff to Sprint 1

**Checklist:**

- [ ] All 9 artifacts completed
- [ ] Archaeology report reviewed by Sage (Backend lead)
- [ ] Product Owner confirms business rules accuracy
- [ ] Oracle DBA verifies transaction table schema
- [ ] Artifacts uploaded to repo (docs/archaeology-sprint/)
- [ ] Kickoff meeting scheduled: Sprint 1, Week 1 Monday
  - Sage presents ORDS API contracts
  - Nova gets frontend requirements locked down
  - Ivy gets test specification
  - Remy confirms timeline (3-sprints this form)

**Success criteria:**
- ✅ No surprises when ORDS development starts
- ✅ Frontend can start without backend delays
- ✅ QA has clear equivalence framework

---

## TIMELINE (5 days, full-time Sage + Oracle DBA)

```
Mon: Tasks 1.1 - 1.3 (recover procedures) → 1 day
Tue: Task 2.1 (find transaction table) → 1 day
Wed: Task 3.1 - 3.2 (business rules + performance) → 1 day
Thu: Task 4.1 - 4.3 (inventory + specs) → 1 day
Fri: Task 5.1 - 5.3 (finalize + sign-off) → 1 day
```

**Output ready Monday, Sprint 1 Week 2** (or sooner if team works parallel)

---

## SUCCESS CRITERIA

Archaeology sprint succeeds if:

- ✅ All truncated procedures fully recovered & documented
- ✅ Transaction table identified with schema + performance data
- ✅ Business rules documented (no surprises during ORDS design)
- ✅ Excel export format specified (Ivy can validate equivalence)
- ✅ ORDS API contracts finalized (Nova unblocked)
- ✅ Forms inventory complete (Wave planning enabled)
- ✅ Risk #1 status downgraded from CRITICAL to RESOLVED

---

## IF BLOCKERS OCCUR

| Blocker | Mitigation | Time Impact |
|---------|-----------|------------|
| Procedures not in USER_SOURCE | Check DBMS_METADATA.GET_DDL | +1 day |
| Source code compiled only | Decompile with tool | +1 day |
| Transaction table not found | Search table names, ask DBA | +1 day |
| Jasper server offline | Get from ops/archive | +1 day |
| Excel export file corrupted | Re-generate from Forms | +1 day |

**Contingency:** Allocate +1 week if blockers occur (keep in budget)

---

**Prepared by:** Remy (Producer), Sage (Backend)  
**Status:** READY TO EXECUTE  
**Approval:** Awaiting Cesar sign-off on Sprint 0 budget

