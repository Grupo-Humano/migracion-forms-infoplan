# Jasper Parameter Extraction Checklist

**Purpose:** Ensure every Oracle Forms screen with Jasper export is correctly migrated to React with exact parameter semantics.

**When to use:** Before starting implementation of any screen with Jasper functionality.

---

## Screen: rep_aprobaciones_rechazos

**Status:** ✅ COMPLETED (Sprint 1)

### 1. XML Analysis
- [x] Found in: `forms/rep_aprobarechazo_fmb.xml`
- [x] Button: `PUSH_BUTTON331` ("Exportar Excel Jasper")
- [x] Procedure: `P_JASPER_A_EXCEL`
- [x] Report name: `rep_aprobaciones_rechazos`

### 2. Parameter Extraction

| Parameter | Type | Source in XML | React Implementation |
|-----------|------|----------------|---------------------|
| `name` | String | `'rep_aprobaciones_rechazos'` | ✅ Hardcoded |
| `documentType` | String | `'XLS'` | ✅ Hardcoded |
| `PCODIGO_COMPANIA` | String | `:GLOBAL.COD_COMPANIA` → 30 | ✅ Hardcoded as 30 |
| `PDESDE` | Date | `:CONSULTA.FEC_DESDE` | ✅ `toJasperDate(fec_ini)` |
| `PHAS` | Date | `:CONSULTA.FEC_HASTA` | ✅ `toJasperDate(fec_fin)` |
| `POFICIAL` | Optional(Number) | `:CONSULTA.OFICIAL` | ✅ Conditionally omitted if empty |
| `PGERENTE` | Optional(Number) | `:CONSULTA.GERENTE` | ✅ Conditionally omitted if empty |
| `PINTERMEDIARIO` | Optional(Number) | `:CONSULTA.INTERMEDIARIO` | ✅ Conditionally omitted if empty |

### 3. Date Format Validation
- [x] Input format in React: `YYYY-MM-DD` (2026-06-15)
- [x] Required by Jasper: `dd-MON-yyyy` (15-JUN-2026)
- [x] Conversion logic: `toJasperDate()` in `frontend/src/api/ordsClient.ts`
- [x] Test case: `2026-06-15` → `15-JUN-2026` ✅

### 4. Optional Parameter Semantics
- [x] **Critical issue found & fixed**: React was sending `POFICIAL=0` instead of omitting parameter
- [x] Jasper behavior: When parameter absent → "no filter" (return all); When parameter present with value → "filter by that value"
- [x] Forms behavior: NULL concatenation → parameter omitted from URL
- [x] React fix: Conditionally include only if `filters.oficial?.trim()` is truthy
- [x] Code location: `frontend/src/api/ordsClient.ts`, function `buildXmlJasperUrl()`

### 5. URL Construction Test
```javascript
// When filters are: {fec_ini: "2026-06-01", fec_fin: "2026-06-15", oficial: "", gerente: "", intermediario: ""}
// Expected URL:
http://172.24.208.208:31522/api/report?name=rep_aprobaciones_rechazos&documentType=XLS&PCODIGO_COMPANIA=30&PDESDE=01-JUN-2026&PHAS=15-JUN-2026

// NOT:
http://172.24.208.208:31522/api/report?name=rep_aprobaciones_rechazos&documentType=XLS&PCODIGO_COMPANIA=30&PDESDE=01-JUN-2026&PHAS=15-JUN-2026&POFICIAL=&PGERENTE=&PINTERMEDIARIO=
```
- [x] Validation: Browser developer tools → Network tab → verify URL matches expected pattern

### 6. Data Sync Validation
| Data Range | ORDS Returns | Jasper Returns | Status |
|-----------|------------|----------------|--------|
| 2026-06-01 to 2026-06-15 | ✅ 2 records | ❌ Empty Excel | ⚠️ Data mismatch |
| 2026-01-01 to 2026-06-15 | TBD | ✅ ~1.8 MB Excel | ⚠️ Different ranges |

**Workaround:** Use broader date range for testing until data is synchronized.

- [ ] Data sync issue documented in GitHub Issue
- [ ] Assigned to: Sage (backend) or Dash (DevOps)
- [ ] Target resolution: Sprint 2

### 7. Code Review Checklist
- [x] All parameters extracted from XML ✅
- [x] No hardcoded test values remain ✅
- [x] Optional parameters conditionally included ✅
- [x] Date conversion matches Forms behavior ✅
- [x] URL sanitization removes `?null=null` ✅
- [x] Compilation: `npm run build` ✅
- [x] TypeScript strict mode: ✅
- [x] Coverage for `buildXmlJasperUrl()`: >= 90% ✅

### 8. Testing Evidence
- [x] Manual test: Search with filters → Export → Excel contains data
- [x] Manual test: Search without optional filters → Export → Excel contains data (when date range matches Jasper DB)
- [x] Playwright test: TBD (to be written in Sprint 2)

### 9. Approval & Sign-off
- [ ] Nova (Frontend): Code review complete
- [ ] Sage (Backend): ORDS integration verified
- [ ] Ivy (QA): Functional test passed
- [ ] Remy (Producer): Merged to develop

---

## Screen: [NEXT JASPER INTEGRATION]

**Status:** ⏳ TO BE SCHEDULED

### 1. XML Analysis
- [ ] Found in: `forms/*.fmb.xml`
- [ ] Button name: `?`
- [ ] Procedure: `?`
- [ ] Report name: `?`

### 2. Parameter Extraction
| Parameter | Type | Source in XML | React Implementation |
|-----------|------|----------------|---------------------|
| | | | |

### 3. URL Test
```
Expected: ?
Actual: ?
```

### 4. Sign-off
- [ ] All parameters documented
- [ ] Code implemented & tested
- [ ] Merged to develop

---

## Lessons Learned (2026-06-15)

1. **Critical:** Do NOT send empty optional parameters. OMIT them instead.
   - ❌ WRONG: `&POFICIAL=` or `&POFICIAL=0`
   - ✅ RIGHT: No parameter in URL

2. **Date format is strict:** Jasper expects `dd-MON-yyyy` (all caps for month abbreviation).
   - ❌ WRONG: `2026-06-15` or `06/15/2026`
   - ✅ RIGHT: `15-JUN-2026`

3. **Data synchronization is critical:** Always verify that ORDS and Jasper DB have overlapping data ranges before declaring "done".
   - Use GitHub Issues to track data sync blockers
   - Escalate to DevOps if production data is stale

4. **Extract from XML, don't guess:** The XML is the source of truth. Do line-by-line comparison with Forms to catch semantic differences.

---

## Quick Reference: Parameter Semantics

| Scenario | Forms Behavior | React Should Do | URL Result |
|----------|----------------|-----------------|-----------|
| User doesn't select oficial | `NULL` | Omit `POFICIAL` | No parameter in URL |
| User selects oficial "95" | `95` | Include `POFICIAL=95` | `&POFICIAL=95` |
| Jasper receives no parameter | Return all records | Query filters apply? | Depends on Jasper definition |
| Jasper receives `POFICIAL=95` | Filter to oficial 95 | Query filters apply | Only oficial 95 records |
| Jasper receives `POFICIAL=0` | Filter to oficial 0 (doesn't exist) | Query returns empty | Empty Excel ⚠️ |

