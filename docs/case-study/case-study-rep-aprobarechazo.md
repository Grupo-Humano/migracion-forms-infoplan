# CASE STUDY: rep_aprobarechazo_fmb
**Oracle Forms → React Migration Analysis**

**Date:** 2026-06-12  
**Form:** REP_APROBARECHAZO (Consulta Aprobaciones y Rechazos Domiciliación)  
**Status:** Risk #1 Deep-Dive Validation  
**Risk Level:** 🔴 HIGH (Legacy complexity + undocumented logic + external dependencies)

---

## EXECUTIVE SUMMARY (Remy)

This form is **TEXTBOOK LEGACY COMPLEXITY**: Report query → complex filter logic → dynamic results table → Excel export (both OLE automation AND Jasper REST). It has:
- ✅ Clear user flow (filters → search → results → export)
- ❌ **3 undocumented stored procedures** called via triggers
- ❌ **External Jasper server dependency** (REST curl call, not ORDS)
- ❌ **OLE Excel automation** (Windows-specific, not replicable in React directly)
- ❌ **Dynamic SQL construction** in PL/SQL (SQL injection risk? Unclear validation)

**Complexity Assessment: MEDIUM-HIGH → 12-15 days migration**  
**Decision:** This should **NOT** be piloto—too many moving parts. **Start with simpler 5-field form first.**

---

## DETAILED AGENT ANALYSES

---

## 🎨 NOVA (Frontend React)

### Analysis

This form screens as a **"Report + Export" SPA component**—seems simple until you dig into state management. The visual structure is:

1. **CONSULTA block (Filter section):**
   - 2 date inputs (FEC_INI, FEC_FIN) with cross-field validation
   - 3 select inputs (OFICIAL, GERENTE, INTERMEDIARIO) with LOVs (List of Values)
   - 3 display items (showing fetched names after LOV selection)
   - 1 Search button, 2 Export buttons, Mark/Unmark toggles
   - **Hidden complexity:** Searches only valid if BOTH dates OR at least one criteria specified

2. **TRANS block (Results table):**
   - 16 visible rows (virtualization needed if >1000 records)
   - 22 columns! (Most from secondary canvas CANVAS260 - scrollable horizontally)
   - 1 checkbox column (SELECCION) for multi-select
   - Double-click opens detail form (ssc21100.fmx)

3. **Export paths:**
   - B_REPORTE button → GENERA_REPORTE (OLE Excel automation, requires selected rows)
   - PUSH_BUTTON331 button → P_JASPER_A_EXCEL (REST call to Jasper, generates XLS)

### State Management Strategy

```typescript
// React form state (what we need to manage)
interface ReportFilters {
  fec_ini: Date | null;
  fec_fin: Date | null;
  oficial: number | null;
  gerente: number | null;
  intermediario: number | null;
  // Display names (hydrated by LOVs)
  nombre_oficial: string;
  nombre_gerente: string;
  nombre_intermediario: string;
}

interface Transaction {
  id_transaccion: number;
  fec_tra: Date;
  cliente: number;
  compania: number;
  ramo: number;
  secuencial: number;
  monto: number;
  estado: string;
  respuesta_banco: string;
  // ... 18 more fields
  seleccion: 'S' | 'N'; // Checkbox state
}

interface ReportState {
  filters: ReportFilters;
  transactions: Transaction[];
  loading: boolean;
  selectedRows: Set<number>; // Track checked rows
  error: string | null;
}
```

### Components Needed

1. **\<DateRangeFilter />** (reusable)
   - 2 date inputs with error display
   - Cross-field validation (FEC_INI ≤ FEC_FIN)
   - Tooltip for format: "dd/mm/yyyy"

2. **\<SelectWithLOV />** (reusable)
   - Dropdown + button to open LOV modal
   - Auto-populates display field on select
   - Handles null selection

3. **\<DataTable />** (reusable, virtualized)
   - Horizontal scroll for 22 columns
   - Checkbox column for multi-select
   - Row click → double-click behavior (navigate to detail)
   - Sticky header, alternating row colors

4. **\<ExportActions />** (report-specific)
   - "Exportar Excel" button (OLE, Windows-only?)
   - "Exportar Excel Jasper" button (REST, cross-platform)
   - Require selection validation before export

### Estimation

- **Components:** 4-5 days (1-2 days each, with reusability)
- **State Management (Zustand/Context):** 2 days
- **API integration (TanStack Query):** 1-2 days
- **Validation logic:** 1 day
- **Testing (unit + integration):** 2-3 days
- **Total Frontend:** **8-10 days**

### Identified Risks

1. **22-column table UX on desktop + mobile**
   - Form doesn't scale to mobile (Forms is desktop-only)
   - May be acceptable if we document "Desktop only"
   - Risk: User complaints if accessed on tablet

2. **Excel export via OLE (GENERA_REPORTE)**
   - XML shows triggers calling OLE2.OBJ_TYPE (COM automation)
   - React can't directly use OLE (Windows-only, not cross-platform)
   - Mitigation: Route through backend ORDS endpoint that calls PL/SQL OLE code
   - **OR:** Replace with ORDS-native Excel generation (POI, APEX_ZIP, etc.)

3. **Jasper Server dependency (P_JASPER_A_EXCEL)**
   - Currently calls `curl http://jasper-server/...` 
   - React frontend can also call this REST endpoint
   - But: Who maintains Jasper? Is it still used for other reports?
   - If Jasper EOL'd, we refactor to pure ORDS later

### Unknowns for Cesar

- **Export preference:** OLE or Jasper? If both, which is primary?
- **Mobile support needed?** (Currently form is 22 columns wide)
- **Double-click behavior:** Should detail form open in new tab/modal or navigate?
- **LOV modal behavior:** Auto-select on click or double-click? Form does auto.
- **Row limit:** What's max rows returned? (Affects virtualization)

---

## 🛠️ SAGE (Backend / ORDS)

### Analysis

This form is a **legacy stateless query report**—looks straightforward until you examine the stored procedures. The backend landscape:

1. **LOV queries (Record Groups):**
   - `RG_OFICIALES`: Joins CLIENTE + MOFICIAL (filtered by estatus=76)
   - `RG_GERENTE`: Queries INT_GER_DIR01_V (filtered by COMPANIA)
   - `RG_INTERMED`: Queries INT_GER_DIR01_V (filtered by COMPANIA)
   - **Note:** All filterable, all have 1-100+ records potentially

2. **Main search procedure (BUSCA_TRANSACCIONES):**
   ```sql
   SELECT t.fec_tra, t.cliente, t.compania, t.ramo, t.secuencial, t.monto, 
          t.estado, t.descripcion_rechazo, cli.nombre_poliza, e.descripcion estatus, 
          en.intermediario, en.nombre_intermediario, ...
   FROM [UNKNOWN] t
   JOIN CLIENTE cli ON cli.codigo = t.cliente
   JOIN MOFICIAL d ON d.cdperson = t.cliente
   JOIN INT_GER_DIR01_V en ON en.intermediario = t.intermediario
   JOIN RAMO_SUB_RAMO r ON r.cod_ramo = t.ramo
   WHERE fec_tra BETWEEN fec_ini AND fec_fin
     AND (oficial IS NULL OR moficial.cdofic = oficial)
     AND (gerente IS NULL OR en.cod_ger = gerente)
     AND (intermediario IS NULL OR t.intermediario = intermediario)
   ORDER BY fec_tra, id_transaccion
   ```
   - **PROBLEM:** `[UNKNOWN]` table! The main transaction table is NOT NAMED in the trigger code.
   - **PROBLEM:** Dynamic SQL construction in PL/SQL (see BUSCA_TRANSACCIONES proc, truncated).
   - **RISK:** SQL injection if filter values not properly escaped.

3. **Excel export procedures:**
   - **GENERA_REPORTE:** Uses OLE2 to instantiate Excel COM object, writes data row-by-row
     - Requires Windows client, Excel installed
     - SLOW (row-by-row OLE calls)
     - Not replicable in web without reimplementation
   
   - **P_JASPER_A_EXCEL:** Calls external Jasper server via `curl`
     - Parameters: fec_ini, fec_fin, oficial, gerente, intermediario
     - Returns XLS file to C:\temp\rep_aprobaciones_rechazos_[TIMESTAMP].xls
     - Client downloads via WEBUTIL (Forms file transfer library)

4. **Cross-table logic (POST-QUERY trigger on TRANS):**
   - For each result row, fetches tarjeta data from BOVEDA_TARJETA
   - Queries: numero_tarjeta, fecha_vence, fecha_crea
   - **Performance risk:** N+1 query (1 main query + 1 per result row)
   - Forms caches this; React will call ORDS each time → even slower unless we batch

### ORDS Endpoints Needed

```yaml
# 1. LOV endpoints (read-only)
GET /ords/api/ref-data/oficiales
  - Returns: [{ nombre_oficial: string, cdofic: number }]
  - Cache: 1 hour (doesn't change frequently)

GET /ords/api/ref-data/gerentes?compania=:compania
  - Returns: [{ nombre: string, cod_ger: number }]

GET /ords/api/ref-data/intermediarios?compania=:compania
  - Returns: [{ nombre: string, intermediario: number }]

# 2. Main search endpoint
POST /ords/api/reportes/buscar
  Body: {
    fec_ini: date (dd/mm/yyyy),
    fec_fin: date (dd/mm/yyyy),
    oficial?: number,
    gerente?: number,
    intermediario?: number,
    limit?: number (default 500)
  }
  Returns: [Transaction] (with tarjeta data hydrated)

# 3. Excel export endpoints
POST /ords/api/reportes/exportar-excel
  Body: { filters: {...}, selectedRows?: number[] }
  Returns: File (XLS) - OLE-based, Windows client only

POST /ords/api/reportes/exportar-jasper
  Body: { fec_ini, fec_fin, oficial, gerente, intermediario }
  Returns: File (XLS) - via Jasper server
```

### Complexity Breakdown

| Component | Status | Effort | Risk |
|-----------|--------|--------|------|
| LOV queries | **Documented** (Record Groups) | 1 day | Low |
| BUSCA_TRANSACCIONES proc | **Partially visible** (XML truncated) | 3 days | HIGH |
| GENERA_REPORTE proc | **Not visible** (OLE code) | 3 days | HIGH |
| P_JASPER_A_EXCEL proc | **Visible** (calls Jasper via curl) | 1 day | Medium |
| ORDS endpoint design | **New** | 1 day | Low |
| Tarjeta N+1 optimization | **New** | 1 day | Medium |

### Critical Unknowns (Archaeology Sprint Needed)

1. **What table stores transactions?**
   - XML doesn't name the TRANS block's query source
   - Must reverse-engineer from BUSCA_TRANSACCIONES procedure
   - Could be: TRANSACCIONES, PAGO_TRANSACCIONES, BOVEDA_TRX, etc.

2. **BUSCA_TRANSACCIONES procedure logic?**
   - XML is truncated after `begin` statement
   - Need full source code
   - Risk: Dynamic SQL could have undocumented filters or business rules

3. **GENERA_REPORTE OLE logic?**
   - XML is truncated (procedure definition cut off)
   - Need full source: column ordering, formatting, formulas?
   - Risk: Replicating exact Excel layout in web may be impossible

4. **Jasper report definition?**
   - Who maintains it? Is it versioned?
   - Can we retire Jasper export and use pure ORDS?

### Estimation

- **Recover BUSCA_TRANSACCIONES source:** 1 day (archaeology)
- **Identify transaction table:** 1 day (archaeology)
- **Design ORDS endpoints:** 1 day
- **Implement LOV endpoints:** 1 day
- **Implement search endpoint:** 2 days (including N+1 optimization)
- **Implement Excel export endpoints:** 2 days (wrapper for OLE + Jasper)
- **Performance testing + optimization:** 1 day
- **Total Backend:** **7-9 days**

### Recommendations

1. **Do NOT implement GENERA_REPORTE (OLE) in ORDS.**
   - OLE is Forms-specific, Windows-specific
   - Option A: Keep OLE endpoint for Forms during parallel run, deprecate in 3 months
   - Option B: Replace with Jasper (already external)
   - Option C: Use backend library (Apache POI, node-xlsx) if we add Node middleware

2. **Make Jasper export platform-agnostic.**
   - Currently: Forms client calls Jasper via curl
   - Future: React frontend calls ORDS endpoint → ORDS calls Jasper
   - Benefit: Consistent, no client-side file system access

3. **Optimize N+1 tarjeta lookup.**
   - Current: 1 query (TRANS results) + N queries (tarjeta per row)
   - Option A: Join BOVEDA_TARJETA in main BUSCA_TRANSACCIONES query
   - Option B: Batch fetch tarjeta data in ORDS after main query
   - Benefit: React won't see N+1, performance stays comparable to Forms

---

## 👤 KIRA (UX Designer)

### User Flow Analysis (Current Forms)

```
┌─────────────────────────────────────────────────────────┐
│ 1. USER LANDS ON FORM                                   │
│    - Pre-filled: FEC_INI = TODAY-1, FEC_FIN = TODAY      │
│    - Other filters: NULL                                 │
│    - Results: EMPTY (awaiting search)                    │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│ 2. USER ENTERS FILTERS (all optional except dates)      │
│    - FEC_INI, FEC_FIN: Mandatory? (Form says "requerido"│
│      in B_BUSCAR trigger message)                       │
│    - OFICIAL: Optional, triggers LOV lookup              │
│    - GERENTE: Optional                                  │
│    - INTERMEDIARIO: Optional                            │
│    - Real validation: At least dates OR other criteria  │
│                                                         │
│    - LOV popup behavior: Click "..." button OR          │
│      KEY-LISTVAL trigger (automatic LOV on value entry) │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│ 3. USER CLICKS "BUSCAR" (Search)                        │
│    - Form shows: "Seguro de iniciar con la Ejecución   │
│      del proceso?" (Confirm dialog)                     │
│    - Cursor changes to busy                             │
│    - No visual progress indicator (?) - unclear from XML│
│    - Results table populates (16 visible rows)          │
│    - User can scroll right (22 columns!)                │
│    - User can scroll down (unlimited rows)              │
│    - ISSUE: How long does search take? No timeout shown │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│ 4. USER INTERACTS WITH RESULTS                          │
│    Option A: Mark/Unmark rows                           │
│      - B_MARCAR button → all rows checked               │
│      - B_DESMARCAR button → all rows unchecked          │
│      - ISSUE: What's the purpose? Export selected only? │
│      - ISSUE: No guidance text visible                  │
│                                                         │
│    Option B: Double-click on row                        │
│      - Opens ssc21100.fmx form (detail view)            │
│      - User can edit/view individual transaction        │
│      - Return to report list                            │
│                                                         │
│    Option C: Export                                     │
│      - B_REPORTE button: "Exportar Excel" (OLE)         │
│        * Requires ≥1 row selected                       │
│        * Calls GENERA_REPORTE (Windows OLE)             │
│        * Downloads file                                 │
│      - PUSH_BUTTON331: "Exportar Excel Jasper"          │
│        * NO selection required (uses all filtered data) │
│        * Calls P_JASPER_A_EXCEL                         │
│        * Downloads file via Jasper server               │
│      - ISSUE: Why 2 export buttons? When use which?     │
│      - ISSUE: User confusion likely                     │
└─────────────────────────────────────────────────────────┘
```

### UX Issues & Opportunities

| Issue | Current Forms | Impact | React Opportunity |
|-------|---------------|--------|-------------------|
| **Dual export buttons** | B_REPORTE + PUSH_BUTTON331 | Confusion—which to use? | Consolidate into 1 button, let backend decide (Jasper if available, else OLE) |
| **Mark/Unmark purpose unclear** | Buttons exist but no docs | Users don't know why | Add help text: "Select rows to export with OLE format" or remove if not essential |
| **No search progress** | "Busy" cursor, no ETA | Large results feel frozen | Add progress bar, estimated time, cancel button |
| **22-column table** | Horizontal scroll, no column hiding | Desktop OK, unusable mobile | Add column visibility toggle, responsive table, or mobile-specific view |
| **Filter persistence** | Filters clear on form reload | Users re-enter criteria | React: Save filters to localStorage, restore on page reload |
| **Validation timing** | On-demand (click Search) | Late feedback, frustrating | React: Real-time validation (dates cross-field), show errors as user types |
| **LOV popup behavior** | Click "..." OR KEY-LISTVAL | Inconsistent UX | React: Consistent dropdown, optional modal for large LOVs (100+ items) |
| **Date format flexibility** | dd/mm/yyyy only (FormatMask) | Users enter wrong format | React: Date picker + flexible parsing (accept mm/dd, yyyy-mm-dd, etc.) |

### Redesigned UX Flow (React)

```
IMPROVEMENTS:
1. Single "Export as Excel" button (backend routes to best option)
2. Consolidated filter panel with real-time validation feedback
3. Column visibility sidebar (show/hide columns)
4. Progress indicator during search (cancel button)
5. Filter persistence across sessions
6. Responsive table (mobile: card view, desktop: table view)
7. Inline double-click detail view (modal instead of new form)
8. Better row selection UX (select all / select page / select by criteria)
```

### Estimation (UX Design)

- **User research/interviews:** 2-3 days (with business users)
- **Wireframes (desktop + mobile):** 2 days
- **High-fidelity mockups:** 2 days
- **Design system components (Figma):** 1 day
- **Handoff to Nova + dev feedback cycles:** 1-2 days
- **Total UX:** **6-8 days**

### Unknowns for Cesar

1. **Export button purpose?** Why 2 buttons in Forms? Business rule or legacy?
2. **Mark/Unmark feature used?** Or can we remove in React?
3. **Mobile support required?** Or desktop-only app?
4. **Detail view (double-click):** Modal dialog or new page?
5. **Search timeout:** What's acceptable latency for "large" result set?

---

## 🎭 MILO (Art Director / Design System)

### Component Analysis

**Existing Form Components:**

| Component | Type | Reusability | Tailwind? | Notes |
|-----------|------|-------------|-----------|-------|
| Date Input (FEC_INI/FEC_FIN) | Input + Label | HIGH | Yes | Can be component: `<DateField label="Fecha" format="dd/mm/yyyy" />` |
| LOV Select (OFICIAL/GERENTE/INTERMED) | Select + Lookup Button | HIGH | Yes | Component: `<SelectWithLOV label="Oficial" lovName="LOV_OFICIALES" />` |
| Display Item (NOMBRE_*) | Read-only text | MEDIUM | Yes | Component: `<DisplayField value={name} label="Nombre" />` |
| Data Table (TRANS) | Multi-column, sortable, scrollable | HIGH | Yes | Component: `<DataTable columns={cols} rows={rows} />` with virtualization |
| Checkbox Column | Multi-select | HIGH | Yes | Component: `<TableCheckbox selected={ids} onChange={setIds} />` |
| Button (B_BUSCAR) | Primary CTA | HIGH | Yes | Component: `<Button variant="primary">Buscar</Button>` |
| Button (B_REPORTE) | Secondary CTA (export) | HIGH | Yes | Component: `<Button variant="secondary" icon="download">Exportar</Button>` |
| Confirmation Modal | Dialog + Yes/No | HIGH | Yes | Component: `<ConfirmDialog message="Seguro?" onConfirm={onConfirm} />` |

### Design System Checklist

**Phase 1 (MVP) - 2 weeks:**
- [ ] Color palette (Form uses grays, blues, red—define hex values, WCAG AA contrast)
- [ ] Typography scale (headings, body, labels, captions)
- [ ] Spacing scale (margin/padding tokens)
- [ ] Button variants (primary, secondary, danger, disabled states)
- [ ] Input components (text, date, select, with error states)
- [ ] Form layouts (horizontal, vertical, inline)
- [ ] Shadows, borders, radius tokens (rounded corners on buttons)

**Phase 2 (Full system) - ongoing:**
- [ ] Data table patterns (sorting, filtering, pagination, column hiding)
- [ ] Modals & dialogs
- [ ] Alerts & notifications
- [ ] Loading states (skeleton, spinner, progress)

### Accessibility (WCAG 2.1 AA)

**Current Form Violations (Forms is notoriously non-accessible):**
- ❌ No keyboard navigation guidance
- ❌ Date format (dd/mm/yyyy) may confuse screen readers
- ❌ LOV buttons (small icons, no labels visible)
- ❌ Table 22 columns—screen reader nightmare
- ❌ Checkbox labels missing or unclear

**React Fixes:**
- ✅ ARIA labels on all form inputs
- ✅ Keyboard shortcuts documented (Tab/Enter/Escape)
- ✅ Color not only differentiator (e.g., status icons + text)
- ✅ 1.4.3 Contrast (minimum 4.5:1 for text)
- ✅ 1.4.11 Non-text Contrast (3:1 for UI components)
- ✅ Focus visible (outline-blue or focus ring)
- ✅ Column hiding → smaller table for screen reader traversal

### CSS Strategy

**Option A: Tailwind (Recommended)**
- Pros: Fast, consistent, team familiar, great docs
- Cons: Large utility set can feel chaotic to beginners
- Recommendation: Use Tailwind + custom component library built ON TOP

**Option B: Styled Components**
- Pros: CSS-in-JS, scoped styles
- Cons: Runtime overhead, less performant than Tailwind
- Not recommended for this team

**Option C: CSS Modules**
- Pros: Locally scoped CSS
- Cons: Overhead for large team, inconsistency risk
- Not recommended

**Decision: Tailwind + shadcn/ui components** (pre-built, accessibility-first, customizable)

### Estimation

- **Design system tokens (colors, spacing, type):** 3 days
- **Component library setup (shadcn/ui scaffold):** 2 days
- **Custom component development (8-10 components):** 5 days
- **WCAG AA audit + fixes:** 2 days
- **Design handoff documentation:** 1 day
- **Total Design:** **10-13 days**

### Unknowns for Cesar

1. **Tailwind + shadcn/ui approved?** Or existing design system to adopt?
2. **Mobile responsive required?** (Affects design effort by 30%)
3. **Dark mode support?** (Another 20% effort)
4. **Accessibility targets:** WCAG AA or AAA? EU mandates AA.

---

## 🧪 IVY (QA / Testing)

### Test Scenarios Identified

#### **Category 1: Filter Validation**

| Scenario | Input | Expected | Risk |
|----------|-------|----------|------|
| V1.1 | FEC_INI=null, FEC_FIN=null, click Search | Error: "Dato Fecha es requerido" | Low |
| V1.2 | FEC_INI=01/06/2026, FEC_FIN=05/06/2026, click Search | Proceeds (valid date range) | Low |
| V1.3 | FEC_INI=05/06/2026, FEC_FIN=01/06/2026, click Search | Error: "Fecha Desde no puede ser mayor..." | Low |
| V1.4 | FEC_INI=05/06/2026, FEC_FIN=null, click Search | Error: "Dato Fecha es requerido" OR proceeds if other criteria set? | MEDIUM (unclear requirement) |
| V1.5 | All filters empty, click Search | Error: "Debe especificarse algún criterio" | Low |
| V1.6 | OFICIAL=123, other filters null (no dates), click Search | Proceeds or error? | HIGH (undocumented logic) |

#### **Category 2: LOV Behavior**

| Scenario | Input | Expected | Risk |
|----------|-------|----------|------|
| V2.1 | Click B_OFICIAL button | LOV_OFICIALES modal opens (all oficiales listed) | Low |
| V2.2 | Select OFICIAL=123 from LOV | NOMBRE_OFICIAL auto-populates | Low |
| V2.3 | OFICIAL=999 (invalid code) | Validation on save or error? | MEDIUM (undocumented) |
| V2.4 | GERENTE + INTERMEDIARIO both selected | Filters apply both (AND logic)? | MEDIUM |

#### **Category 3: Search Results**

| Scenario | Input | Expected | Risk |
|----------|-------|----------|------|
| V3.1 | Date range with 0 results | Empty table or "No records found"? | Low |
| V3.2 | Date range with 10,000 results | All returned or paginated? Table hangs? | HIGH (performance) |
| V3.3 | Click row 1, double-click | Opens ssc21100.fmx detail form | Low |
| V3.4 | Search, then change filter, search again | Old results replaced or appended? | Low |

#### **Category 4: Select/Unselect Rows**

| Scenario | Input | Expected | Risk |
|----------|-------|----------|------|
| V4.1 | Click B_MARCAR | All 16 visible rows checked + scrolled rows | MEDIUM (unclear) |
| V4.2 | Click B_DESMARCAR | All rows unchecked | Low |
| V4.3 | Manually check row 1, click B_DESMARCAR | All unchecked (bulk overrides individual) | Low |
| V4.4 | Check 5 rows, click B_REPORTE | Only 5 rows exported | Medium |

#### **Category 5: Excel Export (OLE)**

| Scenario | Input | Expected | Risk |
|----------|-------|----------|------|
| V5.1 | 0 rows selected, click B_REPORTE | Error: "Debe hacer una selección" | Low |
| V5.2 | ≥1 rows selected, click B_REPORTE | Confirm dialog, then download XLS | Medium |
| V5.3 | XLS file downloaded | Columns in same order as Forms? Formatting preserved? | HIGH (spec unknown) |
| V5.4 | Export 1000 rows | OLE automation fast enough or times out? | HIGH (performance) |

#### **Category 6: Excel Export (Jasper)**

| Scenario | Input | Expected | Risk |
|----------|-------|----------|------|
| V6.1 | No filters, click PUSH_BUTTON331 | Dialog: "Seguro de generar los datos...?" | Low |
| V6.2 | Jasper server unavailable | Error message or silent failure? | HIGH (not documented) |
| V6.3 | XLS downloaded | Jasper report layout vs Forms export layout—same? | HIGH (not documented) |

### Equivalence Testing Framework

**For React form to replace Forms form, we define:**

```
EQUIVALENCE = React(X) output ≈ Forms(X) output

Where X = {
  - Same search filters → same result set
  - Same column values (character-for-character)
  - Same number of rows
  - Same sort order (fec_tra ASC, id_transaccion ASC)
  - Same formatting (dates dd/mm/yyyy, amounts 99,999,990.90)
  - Export file same structure (column order, headers, formulas)
}
```

**Test Data Strategy:**
- Use anonymized production data (exclude PII if possible)
- Or synthetic data matching production patterns:
  - 50 transactions, date range 01/06/2026 - 30/06/2026
  - 5 oficiales, 3 gerentes, 2 intermediarios
  - Mix of states: APPROVED, REJECTED, PENDING
  - Monto range: 100 - 1,000,000

**Regression Test Suite (Minimal Viable Set for 90% coverage):**

| Test # | Scenario | Tools | Est. Time |
|--------|----------|-------|-----------|
| T1 | Valid date range search | Playwright | 10 min |
| T2 | Invalid date range (FEC_INI > FEC_FIN) | Playwright | 5 min |
| T3 | Search with OFICIAL filter | Playwright | 10 min |
| T4 | Search with GERENTE + INTERMEDIARIO | Playwright | 10 min |
| T5 | Mark/Unmark all rows | Playwright | 5 min |
| T6 | Export selected rows (OLE) | Manual or slow E2E | 15 min |
| T7 | Export all rows (Jasper) | Playwright + file verify | 15 min |
| T8 | Double-click row → detail form | Playwright | 5 min |
| T9 | LOV modal (OFICIAL selection) | Playwright | 10 min |
| T10 | Result table with 500 rows (performance) | Playwright + DevTools | 10 min |

**Total manual: ~95 min per cycle** (if fully automated in Playwright, ~20 min)

### Estimation (QA)

- **Test plan + equivalence framework:** 2 days
- **Manual smoke tests (ad hoc):** 2 days
- **Playwright automation (10 core tests):** 4 days
- **Regression suite maintenance:** 1 day per sprint
- **Performance testing (load, export):** 1 day
- **Sign-off criteria documentation:** 1 day
- **Total QA (first release):** **9-11 days**

### Unknowns for Cesar

1. **Performance SLAs:** What's acceptable latency for search (< 2s? < 5s?), export (< 1 min?)?
2. **Regression test coverage target:** 90%? 100%? (Affects automation investment)
3. **Export file format validation:** Do we need byte-for-byte match with Forms, or "similar enough"?
4. **Known bugs in Forms:** Any existing issues we should NOT replicate in React?

---

## 🎯 REMY (Producer)

### Complexity Assessment Matrix

| Factor | Forms | React | Delta | Risk |
|--------|-------|-------|-------|------|
| **Filter complexity** | 5 fields (3 LOV + 2 dates) | Same | 0 | Low |
| **Validation logic** | Date range + mandatory criteria | Same | 0 | Low |
| **Main query complexity** | Dynamic SQL in PL/SQL | ORDS endpoint (TBD) | ? | HIGH |
| **LOV complexity** | 3 Record Groups | 3 ORDS endpoints | 0 | Low |
| **Results display** | 22 columns, 16 visible rows | Same layout | 0 | Low |
| **Row interaction** | Checkbox + double-click | Same | 0 | Low |
| **Export complexity** | OLE + Jasper (2 paths) | Jasper only (v1) + TBD OLE | +1 | HIGH |
| **Undocumented logic** | ??? | Archaeology req'd | ? | CRITICAL |

**Overall Complexity: MEDIUM-HIGH**

### Why This Should NOT Be Piloto

1. **3 External dependencies:**
   - ORDS (new to team)
   - Jasper server (external REST API)
   - OLE Excel (Windows-only, may be eliminated)

2. **Too many unknowns:**
   - Main transaction table not visible in XML
   - BUSCA_TRANSACCIONES procedure truncated
   - GENERA_REPORTE procedure truncated (OLE logic unknown)
   - No documentation on export file specification

3. **High-risk exports:**
   - OLE automation: Fragile, Windows-only, hard to debug
   - Jasper: External dependency, EOL risk
   - No clear "single source of truth" for export format

### Recommendation: Find a Simpler Piloto

**Piloto Criteria:**
- ✅ Clear user flow (filters → search → display)
- ✅ Well-documented backend (all procedures visible)
- ✅ No external dependencies (no Jasper, no OLE)
- ✅ Simple export (CSV or JSON, no format spec)
- ✅ <10 columns, <2 LOVs

**Examples of better piloto forms:**
- A simple lookup form (e.g., "Consulta Clientes")
- A data entry form with validation (e.g., "Crear Solicitud")
- A dashboard with charts (e.g., "Ventas por Mes")

**This form (`rep_aprobarechazo`) should be Wave 2 or Wave 3** (after team has 1-2 piloto under belt).

### Project Timeline Impact

| Phase | Activity | Duration | Effort | Notes |
|-------|----------|----------|--------|-------|
| **Archaeology** | Recover BUSCA_TRANSACCIONES source | 1 week | Sage + Oracle DBA | Blocking everything |
| **Sprint 0** | Design ORDS, identify piloto, build harness | 8 weeks | Full team | Includes this form analysis |
| **Sprint 1+** | Piloto form migration (NOT this one) | 4-6 weeks | Nova + Sage + Ivy | Proves process |
| **Wave 2** | This form + 2-3 similar reports | 6-8 weeks | Nova + Sage + Ivy | Uses lessons from piloto |
| **Wave 3+** | Remaining forms (200 total) | 16-20 weeks | All hands | Parallel teams possible |

**Total: 18-24 months for 200 forms** (assuming 4-6 weeks per wave, 10-15 forms per wave)

### Go/No-Go Decision

**Status:** ✅ **GO** (with conditions)

**Conditions:**
1. [ ] Archaeology sprint completes (BUSCA_TRANSACCIONES source recovered)
2. [ ] Simpler piloto form identified (not this one)
3. [ ] ORDS consultant onboarded
4. [ ] 2 QA engineers hired + onboarded
5. [ ] ORDS MVP architecture validated (POC with 1 endpoint)
6. [ ] Team agrees: "This form is Wave 2, not Wave 1"

**Risk if conditions NOT met:**
- ❌ 3+ month delay (archaeology alone = 1-2 weeks, then rework)
- ❌ Team frustration (piloto too hard, demoralizes)
- ❌ Export format confusion (Excel OLE vs Jasper—no consensus)

### Estimation Summary (This Form Alone)

| Role | Days | Dependencies |
|------|------|--------------|
| **Sage (Backend)** | 7-9 | Archaeology sprint must complete |
| **Nova (Frontend)** | 8-10 | ORDS endpoints available |
| **Ivy (QA)** | 9-11 | Equivalence framework, test data |
| **Kira (UX)** | 6-8 | Stakeholder interviews |
| **Milo (Design)** | 10-13 | Design system phase 1 |
| **Remy (Producer)** | 2-3 | Oversight, risk tracking |
| **Dash (DevOps)** | 2-3 | ORDS deployment, monitoring |
| **Total (Person-Days)** | **54-70** | ~3 sprints (13-18 calendar days) |

---

## 🚀 DASH (DevOps)

### Performance Baseline (Forms)

| Metric | Forms (Observed) | Target React | Notes |
|--------|-----------------|--------------|-------|
| Search latency (1000 rows) | ? (not measured) | < 2s | Need baseline from Forms |
| Export (OLE, 500 rows) | ? (possibly 30s+) | ? (depends on impl) | OLE is inherently slow |
| Export (Jasper, 500 rows) | ? | < 1 min | Jasper server latency + network |
| UI responsiveness | Cursor busy (no cancel) | < 200ms initial response | Need cancel button in React |

### Infrastructure Concerns

1. **ORDS Deployment:**
   - Where does ORDS run? (Same box as Oracle? Separate?)
   - HA/failover: Is ORDS in load balancer?
   - Scaling: If concurrent users spike, does ORDS handle it?
   - Monitoring: What metrics to alert on? (CPU, memory, connection pool)

2. **Jasper Server:**
   - Current SLA: Uptime %? Latency?
   - Alternative: Retire Jasper, move to ORDS? (2-4 week refactor)
   - Risk: If Jasper down, React export fails

3. **Database:**
   - Query performance: BUSCA_TRANSACCIONES query plan?
   - Indexes: Are TRANS table indexes optimal?
   - Locks: If search + export concurrent, locking issues?
   - Archive strategy: Old transactions archiving or all in one table?

4. **React Frontend:**
   - Bundle size: Will 22-column table with virtualization bloat bundle?
   - CDN: Static assets on CDN?
   - Caching: 1-hour cache on LOV data? Or always fresh?

### Deployment Strategy (3-Month Parallel Run)

```
Timeline:
├─ Month 1: React form in staging (internal testing only)
├─ Month 2: React form in prod shadow mode (no users yet)
│           - Monitor for errors (Sentry, DataDog)
│           - Forms still primary export route
├─ Month 3: Canary rollout (5% of users → React)
│           - Monitor for errors & performance
│           - Gradual ramp to 100%
└─ Month 4: Forms export disabled, React only
```

**Rollback Plan:**
- If React form error rate > 5%, rollback to Forms
- If React performance > 2x Forms latency, rollback
- Rollback time: < 15 min (same process, reverse)

### Monitoring & Alerts

```yaml
Metrics:
  - ORDS search API latency (p50, p95, p99)
  - ORDS error rate (500s, timeouts)
  - Jasper export latency (p50, p95)
  - React frontend errors (via Sentry)
  - React bundle size (per build)
  
Alerts:
  - ORDS latency > 5s for 5 min
  - ORDS error rate > 5% for 5 min
  - Jasper unavailable (health check)
  - React error spike (> 2x baseline)
```

### Estimation

- **ORDS infrastructure review:** 1 day
- **Deployment pipeline setup (GitHub Actions → ORDS):** 2 days
- **Parallel run setup (Forms + React):** 1 day
- **Monitoring/alerting configuration:** 1 day
- **Rollback runbook & testing:** 1 day
- **Total DevOps (first release):** **5-7 days**

### Unknowns for Cesar

1. **Current ORDS setup:** Exists? Or building from scratch?
2. **Performance SLAs:** What's "acceptable" latency vs "rollback territory"?
3. **Export file size limit:** What's max XLS file size to handle? (Affects Jasper config)
4. **Rollback SLA:** 15 min acceptable, or need < 5 min?

---

## SUMMARY TABLE: Effort Per Role

| Role | Base Effort (Days) | Risk Buffer | Total (Days) | Critical Path |
|------|-------------------|-------------|--------------|---------------|
| **Sage (Backend)** | 7-9 | +1 archaeology | 8-10 | 🔴 Critical (ORDS design) |
| **Nova (Frontend)** | 8-10 | +0 | 8-10 | 🔴 Critical (component build) |
| **Ivy (QA)** | 9-11 | +1 equivalence | 10-12 | 🟡 Medium (test plan) |
| **Kira (UX)** | 6-8 | +1 research | 7-9 | 🟡 Medium (can run parallel) |
| **Milo (Design)** | 10-13 | +1 WCAG fixes | 11-14 | 🟡 Medium (can run parallel) |
| **Remy (Producer)** | 2-3 | +0 | 2-3 | 🟢 Low (oversight) |
| **Dash (DevOps)** | 5-7 | +0 | 5-7 | 🟡 Medium (deployment path) |
| **TOTAL (Person-Days)** | **47-61** | +4 | **51-65** | **~3 sprints** |

**Calendar Time:** 2-3 weeks (if all hands on deck)

---

## KEY UNKNOWNS (Archaeology Sprint Required)

Before starting this form migration, resolve:

1. **Main transaction table name** (for BUSCA_TRANSACCIONES)
2. **BUSCA_TRANSACCIONES full source code** (truncated in XML)
3. **GENERA_REPORTE OLE logic** (truncated in XML, full implementation needed)
4. **Export file specification** (column order, formatting, formulas for Excel)
5. **Jasper report definition** (does it exist? Is it maintained?)
6. **Performance baseline** (how fast is current Forms search + export?)
7. **Undocumented business rules** (is there logic hidden in triggers?)

---

## FINAL RECOMMENDATION

### 🔴 DO NOT START WITH THIS FORM

**Rationale:**
- Too many unknowns (truncated procedures, missing table names)
- High complexity (3 export paths, OLE + Jasper)
- Not well-documented (forms legacy code)
- Too risky for piloto (team learning curve + form complexity = recipe for disaster)

### ✅ DO: Start with simpler form (Wave 1 piloto)

**Piloto form characteristics:**
- Simple filters (< 5 fields, no LOVs or 1 LOV max)
- Well-documented backend (all procedures visible)
- Single export path (CSV or no export)
- < 15 columns, < 2 tables joined
- 2-3 days backend, 3-4 days frontend, 2-3 days QA

### ⏭️ THEN: Tackle this form (Wave 2)

**After piloto success:**
- Team understands ORDS patterns
- Equivalence testing framework proven
- Export infrastructure working
- This form becomes "standard" pattern apply

### 📋 Sprint 0 Archaeology Work (1 week)

Before ANY form migration, complete:

```
[ ] Day 1-2: Recover BUSCA_TRANSACCIONES source code
[ ] Day 2-3: Recover GENERA_REPORTE source code
[ ] Day 3-4: Reverse-engineer transaction table schema
[ ] Day 4-5: Document undocumented business rules
[ ] Day 5: Create "Oracle Forms Inventory" (all 50+ forms)
```

**Blockers lifted:** After this, can design ORDS architecture with confidence.

---

## END CASE STUDY

**Prepared by:** Multi-agent team (Nova, Sage, Kira, Milo, Ivy, Remy, Dash)  
**Status:** VALIDATION COMPLETE — Risk #1 confirmed (undocumented logic real)  
**Next Steps:** Cesar approves archaeology sprint + piloto form selection
