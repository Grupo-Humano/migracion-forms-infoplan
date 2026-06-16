# Sprint 2 Team Orchestration — Ready for Execution

**Date:** 2026-06-15  
**Objective:** Deploy 5 ORDS handlers for rep_aprobarechazo form  
**Parallel Teams:** Dev (Sage), QA (Ivy), Frontend (Nova), Coordination (Remy)

---

## 🎯 Quick Start for Each Agent

### **REMY** — Producer/Coordinator (THIS CHAT)
- ✅ Read this document (you just did!)
- ✅ Confirm Sprint 2 plan in `docs/sprint-2/plan.md`
- ✅ Confirm PROJECT_BRIEF.md updated (sections 7+8)
- 📋 **NEXT: Dispatch teams to their specific chats/windows**

**Your Job:**
1. Monitor `docs/sprint-2/progress.md` daily (Sage will update)
2. Unblock Sage if DevOps questions arise
3. Carry messages between dev/qa/frontend chats (if parallel)
4. Merge PR when QA signs off

---

### **SAGE** — Backend Engineer (ORDS Deployment)
**READ THIS FIRST:**
- `docs/sprint-2/plan.md` — Full sprint scope
- `backend/ords/sql/01_transacciones_search_real.sql` — Main query
- `PROJECT_BRIEF.md` section 3 (Tech Stack) — ORDS details

**YOUR SPRINT 2 MISSION:**
Deploy 5 ORDS handlers for rep_aprobarechazo. Total ~2.5 days effort.

**Task Breakdown (execute in order):**

1. **Task 1 (0.5d): Create ORDS Module**
   - Connect to: `infoplan-web-dev.humano.local:8888/ords`
   - Create module: `facturacion-aprobaciones-rechazos-v1`
   - Base path: `/aprobaciones-rechazos`
   - Goal: Module visible in ORDS dashboard
   - File script: `backend/ords/scripts/01_create_module.sql` (create if missing)
   - Status: Update `docs/sprint-2/progress.md` Task 1 when done

2. **Task 2 (0.75d): transacciones/search handler**
   - Source SQL: `backend/ords/sql/01_transacciones_search_real.sql`
   - Type: plsql/block (parameterized query)
   - Endpoint: POST /transacciones/search
   - Test: Postman with date range 2026-01-01 to 2026-01-31
   - Expected: 500+ rows
   - File test: `backend/ords/tests/sprint-2/transacciones-search.http`

3. **Task 3 (0.5d): oficiales/{codigo} handler**
   - Source SQL: `backend/ords/sql/02_oficiales_real.sql` (create if missing)
   - Type: json/query
   - Endpoint: GET /oficiales/{codigo_oficial}
   - Test: Postman GET /oficiales/1
   - Expected: 1 record

4. **Task 4 (0.5d): gerentes & intermediarios handlers**
   - Query: INT_GER_DIR01_V (DISTINCT)
   - Type: json/collection
   - Endpoints: GET /gerentes (58), GET /intermediarios (500+)
   - Test: Postman both endpoints
   - File test: `backend/ords/tests/sprint-2/lovs.http`

5. **Task 5 (0.5d): seleccion/{M|D} handler**
   - Endpoint: POST /transacciones/seleccion/M (mark)
   - Endpoint: POST /transacciones/seleccion/D (unmark)
   - Test: Postman POST with sample IDs
   - Expected: { message, updated count }

6. **Task 6 (0.5d): Smoke Tests with Ivy**
   - Create Postman collection: `backend/ords/tests/sprint-2/smoke-tests.postman_collection.json`
   - Run all 6 endpoints in sequence
   - Document results: `docs/sprint-2/smoke-tests.md`
   - Target: 6/6 passing, 0 errors

**Deliverables (by 2026-06-17):**
- [ ] 5 ORDS handlers deployed
- [ ] All endpoints responding 200 OK
- [ ] Postman collection with smoke tests (6/6 passing)
- [ ] Handler config files in `backend/ords/modules/handlers/`
- [ ] docs/sprint-2/smoke-tests.md with results

**Blockers to Resolve:**
- ORDS credentials → Ask Remy/DevOps
- Oracle DB connection → Confirm hostname/port/user
- CORS config → May need ORDS admin adjustment

**Status Updates:**
- Update `docs/sprint-2/progress.md` after each task
- Use format: `✅ Task N: DONE` or `🔄 Task N: In Progress (detail)`
- File any blockers in task notes

---

### **IVY** — QA Engineer (Validation)
**READ THIS FIRST:**
- `docs/sprint-2/plan.md` sections 1-2 (scope, handlers)
- `frontend/src/types.ts` — Response schema definitions
- `docs/sprint-2/smoke-tests.md` (will be created by Sage)

**YOUR SPRINT 2 MISSION:**
Validate all ORDS handlers working correctly. Ensure Sprint 1 frontend still works.

**Task Breakdown:**

1. **Task 6 (0.5d): Smoke Tests with Sage**
   - Collaborate with Sage on Postman collection
   - Run all 6 endpoints: gerentes, intermediarios, search, oficiales, seleccion M/D
   - Verify:
     - [ ] All respond HTTP 200 OK
     - [ ] Response JSON matches types.ts schema
     - [ ] Data counts correct (58 gerentes, 500+ intermediarios, 500+ transactions)
   - Document results: `docs/sprint-2/smoke-tests.md`

2. **Task 7 (0.5d): Frontend Integration Test**
   - Frontend env should point to: `https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos`
   - Launch: `cd frontend; npm run dev` on localhost:3000
   - Test Checklist:
     - [ ] Page loads (no 404 or CORS errors in console)
     - [ ] Gerente dropdown shows 58 entries (from GET /gerentes)
     - [ ] Intermediario dropdown shows 500+ entries (from GET /intermediarios)
     - [ ] Search with 2026-01-01 to 2026-01-31 returns 500+ rows
     - [ ] Results table displays all 19 columns correctly
     - [ ] No validation errors
     - [ ] Console clean (no warnings/errors)
   - Screenshot: Capture working page (same format as Sprint 1 demo)
   - File report: `docs/sprint-2/frontend-integration.md`

3. **Task 8 (0.5d): QA Sign-off**
   - Create: `docs/qa/sprint-2-deployment-signoff.md`
   - Content:
     ```
     # Sprint 2 QA Sign-off
     
     ## Handler Validation
     - Gerentes: 58 rows ✅
     - Intermediarios: 500+ rows ✅
     - Transacciones/search: 500+ rows ✅
     - Oficiales/{codigo}: lookup working ✅
     - Seleccion M/D: mark/unmark working ✅
     
     ## Frontend Integration
     - Form loads without errors ✅
     - LOV dropdowns populated ✅
     - Search functional ✅
     - Results display correctly ✅
     
     ## Data Integrity
     - No data loss from Sprint 1 ✅
     - All response payloads valid JSON ✅
     - Types match types.ts schema ✅
     
     ## Defects
     - None found ✅
     
     ## Recommendation
     **GO** — Ready for merge to develop and production deployment
     ```
   - File any bugs as GitHub Issues (with label: sprint-2)
   - Recommendation: GO or blockers

**Deliverables (by 2026-06-17):**
- [ ] Postman smoke test results (6/6 passing)
- [ ] Frontend integration test report
- [ ] QA sign-off document with GO recommendation
- [ ] Any defect bugs filed as GitHub Issues

**Success Criteria:**
- All 6 endpoints respond correctly
- Frontend integration test passes
- 0 data loss from Sprint 1
- QA sign-off: GO

---

### **NOVA** — Frontend Engineer (Integration)
**READ THIS FIRST:**
- `docs/sprint-2/plan.md` section Task 7 (Frontend Integration)
- `frontend/src/api/ordsClient.ts` — Current API client
- `frontend/.env` — Current environment variables

**YOUR SPRINT 2 MISSION:**
Update frontend to point to real ORDS handlers and validate integration.

**Task Breakdown:**

1. **Before Task 7: Update Environment (Quick)**
   - Check current `frontend/.env` or `vite.config.ts`
   - Update `VITE_ORDS_BASE_URL` to real ORDS:
     ```
     VITE_ORDS_BASE_URL=https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos
     ```
   - OR create `frontend/.env.sprint-2` if needed
   - Verify API client in `ordsClient.ts` still uses `import.meta.env.VITE_ORDS_BASE_URL`

2. **Task 7 (0.5d): Integration Test with Ivy**
   - Launch dev server: `cd frontend; npm run dev`
   - Confirm localhost:3000 loads
   - Work with Ivy to test:
     - [ ] Form loads without errors
     - [ ] Gerente dropdown fetches 58 entries from real ORDS
     - [ ] Intermediario dropdown fetches 500+ entries from real ORDS
     - [ ] Search with dates returns real transaction data (500+ rows)
     - [ ] Results table displays all 19 columns
     - [ ] No console errors (check for CORS, 404, etc.)
   - Capture screenshot with Ivy
   - File report: `docs/sprint-2/frontend-integration.md` (Ivy leads, Nova supports)

**Deliverables (by 2026-06-17):**
- [ ] Frontend env updated to real ORDS
- [ ] Dev server runs on localhost:3000 without errors
- [ ] All LOV endpoints working
- [ ] Integration test passing (with Ivy)
- [ ] Screenshot showing working form

**Success Criteria:**
- Frontend loads without errors
- All API calls return 200 OK
- Data displays correctly in 19-column table
- 0 console warnings/errors related to ORDS

---

## 📋 Execution Order & Dependency Chain

```
Day 1 (2026-06-15):
  ├─ Sage: Task 1 → Create ORDS module (0.5d) ✋ BLOCKER for all other tasks
  └─ Ivy: Prepare Postman template (no blockers)

Day 2 (2026-06-16):
  ├─ Sage: Tasks 2-5 → Deploy 4 handlers (2d)
  │  ├─ Task 2: transacciones/search (0.75d)
  │  ├─ Task 3: oficiales/{codigo} (0.5d)
  │  ├─ Task 4: gerentes & intermediarios (0.5d)
  │  └─ Task 5: seleccion/{M|D} (0.5d)
  ├─ Nova: Update frontend env (quick, parallel)
  └─ Ivy: Prepare QA test plans (no blockers)

Day 3 (2026-06-17):
  ├─ Sage + Ivy: Task 6 → Smoke tests (0.5d) ✋ BLOCKER for integration
  ├─ Nova + Ivy: Task 7 → Frontend integration (0.5d) — only after smoke tests passing
  ├─ Ivy: Task 8 → QA sign-off (0.5d) — only after integration test passing
  └─ Remy: Task 9 → Git & PR merge (0.5d) — only after QA sign-off

Critical Path: Task 1 → Tasks 2-5 → Task 6 → Task 7 → Task 8 → Task 9
```

---

## 🚀 Go/No-Go Criteria

### Pre-Execution (Blocker Resolution)
- [ ] ORDS credentials provided to Sage
- [ ] Oracle DB connection tested
- [ ] ORDS CORS headers verified (if needed)

### Daily Checkpoints
- **End of Day 1:** Module created, visible in ORDS dashboard
- **End of Day 2:** All 5 handlers deployed, Postman tests ready
- **End of Day 3:** Smoke tests 6/6 passing, frontend integration working, QA sign-off GO

### Sprint Exit Criteria (Go/No-Go)
- ✅ All 5 handlers deployed (search, oficiales, gerentes, intermediarios, seleccion)
- ✅ All endpoints respond HTTP 200 OK
- ✅ Postman smoke tests: 6/6 passing
- ✅ Frontend integration test: PASSING
- ✅ Sprint 1 QA results: 0 regression
- ✅ QA sign-off: GO recommendation
- ✅ Feature branch merged to develop

---

## 📞 Communication Protocol

**Remy (Coordinator) will:**
- Monitor `docs/sprint-2/progress.md` daily
- Escalate blockers immediately
- Carry messages between teams if working in parallel chats
- File any GitHub Issues that arise

**Sage (Backend) will:**
- Update `docs/sprint-2/progress.md` after each task
- Notify Ivy when tasks ready for testing
- Report any ORDS deployment issues to Remy immediately

**Ivy (QA) will:**
- Update `docs/sprint-2/progress.md` with test results
- Provide real-time feedback to Sage on handler responses
- File defect issues with github if bugs found

**Nova (Frontend) will:**
- Keep env config synchronized with ORDS URL
- Support Ivy on integration testing
- Report any CORS or API errors to Sage

---

## 🎯 Success Example (What Winning Looks Like)

**End of Sprint 2 (2026-06-17):**

✅ Sage's update in progress.md:
```
Task 2: transacciones/search ✅ DONE
  - Handler deployed: POST /transacciones/search
  - Test result: 500 rows returned for 2026-01-01 to 2026-01-31
  - Postman test saved: backend/ords/tests/sprint-2/transacciones-search.http
  - Response schema: ✅ Matches SearchResponse[] in types.ts
```

✅ Ivy's integration test report:
```
**Frontend Integration Test — PASSING ✅**

- Form loads: ✅ No errors
- Gerente dropdown: ✅ 58 entries from GET /gerentes
- Intermediario dropdown: ✅ 500+ entries from GET /intermediarios
- Search 2026-01-01 to 2026-01-31: ✅ 500+ rows returned
- Results table: ✅ 19 columns displayed correctly
- Console: ✅ No errors/warnings
- Screenshot: ✅ Attached

**Recommendation:** GO for production merge
```

✅ PR merged to develop:
```
feat(sprint-2): ORDS handlers real deployment + validation

- 5 ORDS handlers deployed (search, oficiales, gerentes, intermediarios, seleccion)
- All endpoints responding 200 OK
- Postman smoke tests 6/6 passing
- Frontend integration test passing
- QA sign-off: GO

Fixes #XX (link to any tracked issues)
```

---

## 📍 File Locations (Quick Reference)

| File | Owner | Purpose |
|------|-------|---------|
| `docs/sprint-2/plan.md` | Remy | Detailed sprint scope |
| `docs/sprint-2/progress.md` | All | Live task tracker (UPDATE DAILY) |
| `backend/ords/sql/01_transacciones_search_real.sql` | Sage | Main search query |
| `backend/ords/scripts/01_create_module.sql` | Sage | Module creation script (TBD) |
| `backend/ords/modules/handlers/` | Sage | 5 handler config files (TBD) |
| `backend/ords/tests/sprint-2/smoke-tests.postman_collection.json` | Sage+Ivy | Postman collection (TBD) |
| `docs/sprint-2/smoke-tests.md` | Ivy | Smoke test results (TBD) |
| `docs/sprint-2/frontend-integration.md` | Nova+Ivy | Integration test report (TBD) |
| `docs/qa/sprint-2-deployment-signoff.md` | Ivy | QA sign-off document (TBD) |
| `docs/sprint-2/done.md` | Remy | Handoff doc for Sprint 3 (TBD) |

---

## ⚡ Troubleshooting Quick Links

- **ORDS Connection Failed?** → Ask Remy to contact DevOps
- **Handler Deployment Error?** → Check ORDS logs, validate SQL syntax
- **CORS Errors in Frontend?** → May need ORDS admin to adjust headers
- **Postman Test Failing?** → Verify response matches types.ts schema
- **Frontend Not Loading Real Data?** → Check env variable VITE_ORDS_BASE_URL

---

**Sprint 2 Orchestration Doc Created:** 2026-06-15  
**Ready to Execute:** ✅ YES  
**Approval:** Cesar (CEO)

---

### 🎬 NEXT STEPS:

1. **Sage** → Start Task 1 immediately (ORDS module creation)
2. **Remy** → Confirm ORDS credentials available
3. **Ivy** → Prepare Postman template
4. **Nova** → Check frontend env configuration

**ALL TEAMS:** Update `docs/sprint-2/progress.md` as you move through tasks!

---

*Sprint 2 Orchestration Ready. Waiting for Sage to begin ORDS handler deployment. Time is now!*
