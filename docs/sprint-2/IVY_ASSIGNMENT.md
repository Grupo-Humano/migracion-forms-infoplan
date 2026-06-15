# IVY — Your Sprint 2 Assignment

**From:** Remy (Producer)  
**To:** Ivy (QA Engineer)  
**Sprint:** Sprint 2 - ORDS Handler Validation & QA Sign-off  
**Your Role:** Validate all endpoints + frontend integration + QA approval  
**Timeline:** 1.5 days (2026-06-16 to 2026-06-17)  
**Effort:** 1.5 days

---

## YOUR MISSION

Validate that 5 ORDS handlers work correctly. Provide QA sign-off with GO recommendation.

**What Success Looks Like:**
- ✅ All 5 handlers respond correctly to requests
- ✅ Response payloads match types.ts schema
- ✅ Postman smoke tests 6/6 passing
- ✅ Frontend integration test PASSING
- ✅ QA sign-off document filed with GO recommendation
- ✅ 0 Sev 1-2 defects

---

## YOUR TASKS (In Order)

### **TASK 6: Smoke Tests with Sage** (0.5 days)
**Deadline:** 2026-06-17 10:00 AM

**What to do:**
1. **Create Postman Collection** with Sage:
   - File: `backend/ords/tests/sprint-2/smoke-tests.postman_collection.json`
   - Format: Postman v2.1+ JSON format
   - Base URL: `https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos`

2. **Add 6 test requests** (in this order):
   ```
   1. GET /gerentes
      Expected: 58 rows, each { codigo, nombre }
      Assertions:
        - Status: 200
        - Body contains "items" array
        - Array length >= 58
   
   2. GET /intermediarios
      Expected: 500+ rows
      Assertions:
        - Status: 200
        - Array length >= 500
   
   3. POST /transacciones/search
      Expected: 500+ transactions for 2026-01-01 to 2026-01-31
      Body: { "fec_ini": "2026-01-01", "fec_fin": "2026-01-31", ... }
      Assertions:
        - Status: 200
        - Array length >= 500
        - Each row has 19 columns (id_transaccion, fecha, cliente, ... seleccionado)
   
   4. GET /oficiales/1
      Expected: Single oficial record
      Assertions:
        - Status: 200
        - Body has { codigo, nombre }
   
   5. POST /transacciones/seleccion/M
      Expected: Mark transaction (update 1 row)
      Body: { "ids": "1", "action": "M" }
      Assertions:
        - Status: 200
        - Body has { message: "success", updated: 1 }
   
   6. POST /transacciones/seleccion/D
      Expected: Unmark transaction (update 1 row)
      Body: { "ids": "1", "action": "D" }
      Assertions:
        - Status: 200
        - Body has { message: "success", updated: 1 }
   ```

3. **Run full collection:**
   - All 6 tests must pass ✅
   - No skips, no fails
   - Export results: `docs/sprint-2/smoke-test-results.json`

**Validation Checklist:**
- [ ] All responses are valid JSON
- [ ] All status codes = 200 OK
- [ ] No error responses (4xx, 5xx)
- [ ] Response schemas match types.ts definitions
- [ ] Data counts match expectations (58, 500+, 500+, 1, 1, 1)
- [ ] No timeouts (< 10 sec per request)

**Document Results:**
```markdown
# docs/sprint-2/smoke-tests.md

## Smoke Test Results

**Execution Date:** 2026-06-17 10:00 AM  
**Collection:** smoke-tests.postman_collection.json  
**Status:** ✅ ALL PASSING (6/6)

### Individual Test Results:

| # | Endpoint | Method | Status | Result | Notes |
|---|----------|--------|--------|--------|-------|
| 1 | /gerentes | GET | 200 ✅ | 58 rows | Valid array of { codigo, nombre } |
| 2 | /intermediarios | GET | 200 ✅ | 500+ rows | Valid array of { codigo, nombre } |
| 3 | /transacciones/search | POST | 200 ✅ | 500 rows | Valid SearchResponse[] schema |
| 4 | /oficiales/1 | GET | 200 ✅ | 1 row | Valid { codigo, nombre } |
| 5 | /transacciones/seleccion/M | POST | 200 ✅ | success | Updated 1 row |
| 6 | /transacciones/seleccion/D | POST | 200 ✅ | success | Updated 1 row |

### Data Validation:

- Response payloads ✅ Match types.ts schema
- Error handling ✅ No 4xx/5xx responses
- Performance ✅ All requests < 10 sec
- Timeout issues ✅ None detected

### Conclusion:

**READY FOR FRONTEND INTEGRATION** ✅
```

**Update Progress:**
```markdown
✅ Task 6: Smoke Tests - DONE (2026-06-17 10:00)
  - Postman collection created
  - All 6 tests passing: ✅ 6/6
  - Results documented in smoke-tests.md
  - Handed off to Nova + Ivy for integration testing
```

---

### **TASK 7: Frontend Integration Test** (0.5 days)
**Deadline:** 2026-06-17 14:00 PM

**What to do (with Nova):**
1. **Confirm frontend env updated:**
   - Frontend `.env` has: `VITE_ORDS_BASE_URL=https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos`
   - Verify with Nova before testing

2. **Launch frontend:**
   ```bash
   cd frontend
   npm run dev
   # Opens http://localhost:3000
   ```

3. **Test each component (checkout console for errors):**
   - [ ] Page loads without errors
   - [ ] No 404 errors (check browser console)
   - [ ] No CORS errors (check browser console)
   - [ ] No network timeout errors

4. **Test Gerente dropdown:**
   - [ ] Dropdown opens
   - [ ] 58 entries populated from GET /gerentes
   - [ ] Entries are real gerente names (not null/undefined)
   - [ ] Dropdown closes properly

5. **Test Intermediario dropdown:**
   - [ ] Dropdown opens
   - [ ] 500+ entries populated from GET /intermediarios
   - [ ] Entries are real intermediario names
   - [ ] Dropdown scrollable (test scroll performance)

6. **Test Search Functionality:**
   - [ ] Enter date range: 2026-01-01 to 2026-01-31
   - [ ] Click "Buscar" button
   - [ ] Observe network request (should be POST to /transacciones/search)
   - [ ] Results load: expect 500+ rows
   - [ ] Results table displays all 19 columns:
     - id_transaccion, fecha, cliente, cliente_poliza, compania, ramo, secuencial
     - monto, estado, estatus_poliza, cod_rechazo, respuesta_banco, num_autoriza
     - lote_id, frecuencia_pago, oficial, gerente, intermediario, seleccionado

7. **Test Results Display:**
   - [ ] First row displays correctly
   - [ ] Monto formatted as currency (with 2 decimals)
   - [ ] Dates formatted as DD-Mon-YYYY (or your format)
   - [ ] Scrolling works smoothly
   - [ ] No visual errors in table

8. **Browser Console Check:**
   - [ ] 0 errors
   - [ ] 0 warnings related to API/ORDS
   - [ ] All network requests return 200 OK

**Test Evidence (Screenshots):**
1. Form with gerentes dropdown populated (58 entries)
2. Form with intermediarios dropdown populated (500+ entries)
3. Search results table displaying 500+ rows
4. All 19 columns visible in results table
5. Browser console clean (no errors)

**Document Results:**
```markdown
# docs/sprint-2/frontend-integration.md

## Frontend Integration Test Results

**Execution Date:** 2026-06-17 14:00 PM  
**Environment:** localhost:3000  
**ORDS Base URL:** https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos

### Test Results:

| Component | Test | Result | Notes |
|-----------|------|--------|-------|
| Page Load | No 404/CORS errors | ✅ PASS | Console clean |
| Gerente Dropdown | 58 entries populate | ✅ PASS | Real data from GET /gerentes |
| Intermediario Dropdown | 500+ entries populate | ✅ PASS | Real data from GET /intermediarios |
| Date Range | 2026-01-01 to 2026-01-31 | ✅ PASS | Valid date inputs |
| Search Button | POST /transacciones/search | ✅ PASS | Returns 500 rows |
| Results Table | 19 columns display | ✅ PASS | All columns visible & formatted |
| Data Validation | Monto, dates, nulls | ✅ PASS | Proper formatting |
| Console | 0 errors, 0 warnings | ✅ PASS | No blocking issues |

### Screenshots:
- [Attached: form-with-gerentes.png]
- [Attached: form-with-intermediarios.png]
- [Attached: results-table-500-rows.png]
- [Attached: browser-console-clean.png]

### Conclusion:

**READY FOR QA SIGN-OFF** ✅
```

**Update Progress:**
```markdown
✅ Task 7: Frontend Integration - DONE (2026-06-17 14:00)
  - Frontend env updated to real ORDS
  - All components working
  - 500+ real transactions displayed
  - Console clean (0 errors)
  - Screenshots documented
  - Handed off to Ivy for final QA sign-off
```

---

### **TASK 8: QA Sign-off** (0.5 days)
**Deadline:** 2026-06-17 16:00 PM (before Remy's merge)

**What to do:**
1. **Create QA Sign-off Document:**
   - File: `docs/qa/sprint-2-deployment-signoff.md`
   - Use template below

2. **Document All Results:**
   ```markdown
   # Sprint 2 QA Sign-off

   **Date:** 2026-06-17  
   **QA Engineer:** Ivy  
   **Sprint:** Sprint 2 - ORDS Handlers Deployment  
   **Overall Status:** ✅ GO

   ## Test Coverage

   ### Smoke Tests (Postman)
   - Gerentes endpoint: ✅ PASS (58 entries)
   - Intermediarios endpoint: ✅ PASS (500+ entries)
   - Transacciones/search: ✅ PASS (500 rows)
   - Oficiales lookup: ✅ PASS (1 row)
   - Mark transactions: ✅ PASS (success response)
   - Unmark transactions: ✅ PASS (success response)
   
   **Result:** 6/6 tests passing ✅

   ### Frontend Integration
   - Page loads: ✅ PASS (no 404/CORS errors)
   - Gerentes dropdown: ✅ PASS (58 real entries)
   - Intermediarios dropdown: ✅ PASS (500+ real entries)
   - Search functionality: ✅ PASS (500+ rows returned)
   - Results display: ✅ PASS (19 columns correct)
   - Console: ✅ PASS (0 errors)
   
   **Result:** Integration test PASSING ✅

   ### Data Integrity
   - No data loss from Sprint 1: ✅ VERIFIED
   - Response schemas match types.ts: ✅ VERIFIED
   - All response payloads valid JSON: ✅ VERIFIED
   - No regression: ✅ VERIFIED

   ## Defects Found
   - **Sev 1-2 Defects:** 0
   - **Sev 3-4 Issues:** 0
   - **Total Blockers:** 0

   ## Recommendation
   
   **GO** ✅ — Ready for merge to develop
   - All endpoints working correctly
   - Frontend integration successful
   - 0 defects or issues
   - Ready for production deployment
   
   **Next Steps:**
   - Merge feature/sprint-2-ords-deployment to develop
   - Deploy to production (handled by Dash)
   - Begin Sprint 3 (other forms)
   ```

3. **File Any Bugs:**
   - If defects found: Create GitHub Issues with:
     - Label: `sprint-2`
     - Label: `bug` or `issue`
     - Title: Clear description
     - Description: Steps to reproduce
     - Severity: Sev-1 (blocker), Sev-2 (major), Sev-3 (minor)
   - If NO defects: No issues to file

4. **Final QA Approval:**
   - Sign-off document committed to git
   - Recommendation: GO or CONDITIONAL

**Update Progress:**
```markdown
✅ Task 8: QA Sign-off - DONE (2026-06-17 16:00)
  - Smoke test results documented
  - Frontend integration test PASSING
  - 0 Sev 1-2 defects
  - QA sign-off document filed with GO recommendation
  - Ready for Remy to merge
```

---

## DELIVERABLES (What Remy Will Check)

By **2026-06-17 16:00 PM**, I expect:
- [ ] Postman smoke tests 6/6 passing
- [ ] smoke-tests.json collection exported
- [ ] docs/sprint-2/smoke-tests.md completed
- [ ] Frontend integration test PASSING
- [ ] docs/sprint-2/frontend-integration.md completed (with screenshots)
- [ ] docs/qa/sprint-2-deployment-signoff.md filed with GO recommendation
- [ ] 0 Sev 1-2 defects (or GitHub Issues filed if any)

---

## DAILY UPDATES (Required)

**Update `docs/sprint-2/progress.md` at END OF EACH DAY with:**
1. % complete for each task
2. What was tested
3. What's planned for tomorrow
4. Any blockers or issues

**Format Example:**
```markdown
### Task 6: Smoke Tests
- **Status:** 🔄 IN PROGRESS (75%)
- **Completed:** Created Postman collection, tests 1-4 passing
- **In Progress:** Testing requests 5-6 (mark/unmark)
- **Planned Tomorrow:** Validate all responses, export results
- **Blockers:** None
```

---

## SUCCESS LOOKS LIKE

**End of Task 8 (2026-06-17 16:00 PM):**
- ✅ All handlers validated and working
- ✅ Postman smoke tests 6/6 passing
- ✅ Frontend integration test PASSING
- ✅ QA sign-off document GO recommendation
- ✅ Ready for Remy to merge to develop

**Your Effort:** 1.5 days of QA work  
**Your Impact:** Production sign-off, ensuring quality delivery  
**Next:** Remy merges PR (final step), Sprint 2 COMPLETE

---

## CONTACT REMY IF...

- ❌ Endpoints returning errors (Remy escalates to Sage)
- ❌ CORS/network issues (Remy escalates to Dash)
- ❌ Unclear test requirements (Remy clarifies)
- ❌ Defects found (Remy creates GitHub Issues)
- ✅ Tests passing (Remy verifies, confirms)

---

## YOUR EFFORT ESTIMATE

| Task | Hours | Days |
|------|-------|------|
| Task 6: Smoke Tests (with Sage) | 4 | 0.5 |
| Task 7: Frontend Integration (with Nova) | 4 | 0.5 |
| Task 8: QA Sign-off | 4 | 0.5 |
| **TOTAL** | **12 hours** | **1.5 days** |

---

**READY TO START, IVY?**

Let me know:
1. When can you start Task 6?
2. Do you need Sage to brief on endpoint formats?
3. Any questions about the Postman collection structure?

**Remy is here to support you. LET'S GO!**

---

*Assignment from Remy (Producer). Valid for Sprint 2. Follow docs/sprint-2/plan.md for full context.*
