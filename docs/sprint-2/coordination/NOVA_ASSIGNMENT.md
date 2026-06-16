# NOVA — Your Sprint 2 Assignment

**From:** Remy (Producer)  
**To:** Nova (Frontend Engineer)  
**Sprint:** Sprint 2 - Frontend Integration with Real ORDS  
**Your Role:** Update env + integration testing  
**Timeline:** 0.5 days (2026-06-17)  
**Effort:** 0.5 days

---

## YOUR MISSION

Update frontend to point to real ORDS. Validate that all API calls work correctly.

**What Success Looks Like:**
- ✅ Frontend env updated to real ORDS base URL
- ✅ Dev server runs on localhost:3000 without errors
- ✅ All LOV dropdowns populate from real ORDS endpoints
- ✅ Search returns real transaction data (500+ rows)
- ✅ Results table displays all 19 columns correctly
- ✅ No console errors or warnings

---

## YOUR TASKS (In Order)

### **TASK 7A: Update Frontend Environment** (Quick - 15 min)
**Deadline:** 2026-06-17 08:00 AM

**What to do:**
1. Check current `frontend/.env` or `vite.config.ts`
2. Update `VITE_ORDS_BASE_URL` to real ORDS:
   ```env
   VITE_ORDS_BASE_URL=https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos
   ```
3. Or create `frontend/.env.sprint-2` if you need to keep demo config
4. Verify API client in `src/api/ordsClient.ts` uses:
   ```typescript
   const baseUrl = import.meta.env.VITE_ORDS_BASE_URL;
   ```

**Validation:**
- [ ] Frontend builds without errors: `npm run build`
- [ ] TypeScript compiles clean: `npx tsc --noEmit`
- [ ] Env variable accessible in ordsClient.ts

**Update Progress:**
```markdown
✅ Task 7A: Update Frontend Env - DONE (2026-06-17 08:00)
  - VITE_ORDS_BASE_URL updated to real ORDS
  - Build clean: npm run build ✅
  - TypeScript: 0 errors ✅
```

---

### **TASK 7B: Integration Test (with Ivy)** (0.5 days)
**Deadline:** 2026-06-17 14:00 PM

**What to do (coordinate with Ivy):**
1. **Launch frontend dev server:**
   ```bash
   cd frontend
   npm run dev
   # Opens http://localhost:3000
   ```

2. **Test Components (with Ivy observing):**
   - [ ] Page loads (title = "Rep Aprobaciones/Rechazos")
   - [ ] No 404 errors in console
   - [ ] No CORS errors (critical! if yes → escalate to Remy/Dash)
   - [ ] All form fields rendered

3. **Test API Calls:**
   - [ ] Gerente dropdown loads: 58 entries from GET /gerentes
   - [ ] Intermediario dropdown loads: 500+ entries from GET /intermediarios
   - [ ] Search with dates 2026-01-01 to 2026-01-31 returns 500+ rows
   - [ ] Results table shows all 19 columns

4. **Test User Interactions (with Ivy):**
   - [ ] Click Gerente dropdown → opens (no errors)
   - [ ] Select a gerente → updates filter
   - [ ] Click "Buscar" → POST request sent to /transacciones/search
   - [ ] Results load in table → all columns visible
   - [ ] Click "Marcar todas" → expected to mark all rows
   - [ ] Click "Desmarcar todas" → expected to unmark all rows

5. **Browser Console (Critical):**
   - [ ] 0 errors
   - [ ] 0 warnings about ORDS/API
   - [ ] All network requests return 200 OK
   - [ ] No 404 responses
   - [ ] No 500 errors

6. **Take Screenshots (for Ivy's report):**
   - Form with gerentes dropdown populated
   - Form with intermediarios dropdown populated
   - Results table with 500+ rows displayed
   - Browser console showing no errors

**Expected Behavior:**
```
Frontend → GET /gerentes → 58 entries ✅
Frontend → GET /intermediarios → 500+ entries ✅
Frontend → POST /transacciones/search → 500 rows ✅
Frontend → Display results table (19 columns) ✅
Console → 0 errors ✅
```

**Blocker Resolution:**
- If "CORS error" → Escalate to Remy immediately (need DevOps)
- If "Cannot find host" → Verify VITE_ORDS_BASE_URL is correct
- If "404 Not Found" → Verify endpoint path matches ORDS handler
- If "Response format mismatch" → Collaborate with Sage to fix handler response

**Update Progress:**
```markdown
✅ Task 7B: Frontend Integration - DONE (2026-06-17 14:00)
  - Frontend loads without errors
  - LOV dropdowns populate correctly (58 + 500+)
  - Search returns real data (500 rows)
  - Results table displays all 19 columns
  - Console clean (0 errors)
  - Screenshots documented for QA report
  - Handed off to Ivy for sign-off
```

---

## DELIVERABLES (What Remy Will Check)

By **2026-06-17 14:00 PM**, I expect:
- [ ] Frontend env updated to real ORDS
- [ ] Dev server runs on localhost:3000 without errors
- [ ] All API calls working (no 404/CORS errors)
- [ ] LOV dropdowns populated from real ORDS
- [ ] Search returns real transaction data
- [ ] Results table displays 19 columns correctly
- [ ] Screenshots provided for Ivy's report

---

## DAILY UPDATES (Required)

**Update `docs/sprint-2/progress.md` with:**
1. Status of env update
2. Status of integration test
3. Any issues found
4. Screenshots attached

---

## CONTACT REMY IF...

- ❌ Cannot build frontend (npm errors)
- ❌ CORS errors (need DevOps)
- ❌ API response doesn't match types.ts (need Sage to fix handler)
- ❌ Need to debug API client
- ✅ Integration test passing (Remy verifies)

---

## YOUR EFFORT ESTIMATE

| Task | Hours | Days |
|------|-------|------|
| 7A: Update Env | 0.5 | 0.125 |
| 7B: Integration Test (with Ivy) | 3.5 | 0.375 |
| **TOTAL** | **4 hours** | **0.5 days** |

---

**READY TO START, NOVA?**

Coordinate with Ivy on timing. When Sage finishes smoke tests (by 2026-06-17 10:00), you start Task 7.

Let me know:
1. Is your env config ready?
2. Any questions about the integration test?
3. When can you start?

**Remy supports you. GO!**

---

*Assignment from Remy (Producer). Valid for Sprint 2.*
