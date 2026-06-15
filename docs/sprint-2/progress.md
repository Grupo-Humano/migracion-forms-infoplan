# Sprint 2 Progress Tracker

**Sprint:** Sprint 2 - ORDS Handlers Real Deployment  
**Period:** 2026-06-15 to 2026-06-17  
**Owner:** Sage (Backend Engineer)  
**QA Owner:** Ivy (QA Engineer)  
**Coordination:** Remy (Producer)

---

## Live Task Status

### Task 1: Create ORDS Module (0.5d)
- **Status:** ✅ DONE
- **Owner:** Sage
- **Description:** Register new module in ORDS for handlers
- **Progress:**
  - [x] Connect to ORDS admin interface
  - [x] Create module: `facturacion-aprobaciones-rechazos-v1`
  - [x] Verify module in ORDS dashboard (DB metadata)
  - [x] Test base URL accessibility (route exists; now auth-gated)
- **Blockers:** None
- **ETA:** 2026-06-15
- **Notes:** Module creation usually fast (~15 min) once credentials confirmed

---

### Task 2: Deploy Handler - transacciones/search (0.75d)
- **Status:** ⏳ BLOCKED (waiting for Task 1)
- **Owner:** Sage
- **Description:** Deploy POST /transacciones/search handler with parameterized query
- **Progress:**
  - [ ] Load SQL from `backend/ords/sql/01_transacciones_search_real.sql`
  - [ ] Register as ORDS handler type: plsql/block
  - [ ] Configure bind variables (fec_ini, fec_fin, cliente, oficial, gerente, intermediario)
  - [ ] Test with Postman (date range 2026-01-01 to 2026-01-31)
  - [ ] Verify 500+ rows returned
- **Blockers:** Waiting for Task 1 module creation
- **ETA:** 2026-06-15 to 2026-06-16
- **Notes:** Most complex handler - has parameterized query with CTEs

---

### Task 3: Deploy Handler - oficiales/{codigo} (0.5d)
- **Status:** ⏳ BLOCKED (waiting for Task 1)
- **Owner:** Sage
- **Description:** Deploy GET /oficiales/{codigo_oficial} handler
- **Progress:**
  - [ ] Load SQL from `backend/ords/sql/02_oficiales_real.sql`
  - [ ] Register as json/query handler type
  - [ ] Configure path parameter: {codigo_oficial}
  - [ ] Test with Postman: GET /oficiales/1
- **Blockers:** Waiting for Task 1 module creation
- **ETA:** 2026-06-16
- **Notes:** Simple lookup handler

---

### Task 4: Deploy Handler - gerentes & intermediarios (0.5d)
- **Status:** ⏳ BLOCKED (waiting for Task 1)
- **Owner:** Sage
- **Description:** Deploy GET /gerentes and GET /intermediarios LOV handlers
- **Progress:**
  - [ ] Query INT_GER_DIR01_V for gerentes (DISTINCT, 58 rows expected)
  - [ ] Register GET /gerentes as json/collection
  - [ ] Register GET /intermediarios as json/collection
  - [ ] Test both with Postman
  - [ ] Verify response schema matches LovListResponse in types.ts
- **Blockers:** Waiting for Task 1 module creation
- **ETA:** 2026-06-16
- **Notes:** Two endpoints, one handler configuration

---

### Task 5: Deploy Handler - seleccion/{M|D} (0.5d)
- **Status:** ⏳ BLOCKED (waiting for Task 1)
- **Owner:** Sage
- **Description:** Deploy POST /transacciones/seleccion/{M|D} handler
- **Progress:**
  - [ ] Register POST /transacciones/seleccion/M (mark/approve)
  - [ ] Register POST /transacciones/seleccion/D (unmark)
  - [ ] Configure action logic (M = mark, D = unmark)
  - [ ] Test with Postman: POST with sample transaction IDs
- **Blockers:** Waiting for Task 1 module creation
- **ETA:** 2026-06-16
- **Notes:** Dual action handler

---

### Task 6: Smoke Test All Handlers (0.5d)
- **Status:** ⏳ BLOCKED (waiting for Tasks 2-5)
- **Owner:** Sage + Ivy
- **Description:** Validate all handlers working together with Postman
- **Progress:**
  - [ ] Create Postman collection: `smoke-tests.postman_collection.json`
  - [ ] Run all 6 endpoint tests
  - [ ] Verify 200 OK responses
  - [ ] Validate response payloads against types.ts
  - [ ] Document results in `docs/sprint-2/smoke-tests.md`
- **Blockers:** Waiting for all handlers deployed
- **ETA:** 2026-06-16 to 2026-06-17
- **Test Sequence:**
  1. GET /gerentes → expect 58 records
  2. GET /intermediarios → expect 500+ records
  3. POST /transacciones/search (2026-01-01 to 2026-01-31) → expect 500+ records
  4. GET /oficiales/1 → expect 1 record
  5. POST /transacciones/seleccion/M (sample ID) → expect success
  6. POST /transacciones/seleccion/D (same ID) → expect success

---

### Task 7: Frontend Integration Test (0.5d)
- **Status:** 🔄 IN PROGRESS (7A DONE / 7B BLOCKED)
- **Owner:** Nova + Ivy
- **Description:** Validate Sprint 1 frontend works against real ORDS handlers
- **Progress:**
  - [x] Update frontend env to real ORDS: `https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos` (`frontend/.env.local`)
  - [x] Build verification: `npm run build` OK (Vite build successful)
  - [x] Launch frontend: `npm run dev` on localhost:3000
  - [ ] QA Smoke Test:
    - [ ] Page loads without errors
    - [ ] Gerente dropdown shows 58 entries
    - [ ] Intermediario dropdown shows 500+ entries
    - [ ] Search with date range returns 500+ rows
    - [ ] Results table displays 19 columns correctly
    - [ ] No 404 or CORS errors in console
  - [ ] Screenshot of working page
  - [ ] Document in `docs/sprint-2/frontend-integration.md`
- **Blockers:** ORDS now returns `403 Forbidden` on live calls after route correction/publish. Current blocker is authorization/policy (not routing).
- **ETA:** 2026-06-17
- **Notes:** Local CORS workaround applied (Vite proxy + relative base URL). After Sage publish + base path correction, error transitioned from `404` to `403` proving endpoint exists but requires access policy alignment.

---

### Task 8: QA Sign-off (0.5d)
- **Status:** ⏳ BLOCKED (waiting for Task 7 integration test passing)
- **Owner:** Ivy
- **Description:** Write QA deployment sign-off document
- **Progress:**
  - [ ] Create `docs/qa/sprint-2-deployment-signoff.md`
  - [ ] Document all handler endpoints deployed and responding
  - [ ] Document Postman smoke tests passed (6/6)
  - [ ] Document frontend integration test passed
  - [ ] Validate response payloads match types.ts schema
  - [ ] Confirm 0 data loss from Sprint 1
  - [ ] File any bugs as GitHub Issues (if found)
  - [ ] Recommendation: GO or blockers
- **Blockers:** Waiting for integration test
- **ETA:** 2026-06-17
- **Notes:** QA recommendation determines if Sprint 2 is complete

---

### Task 9: Git & Handoff (0.5d)
- **Status:** ⏳ BLOCKED (waiting for QA sign-off)
- **Owner:** Remy
- **Description:** Merge Sprint 2 to develop and document handoff
- **Progress:**
  - [ ] Create PR: `feature/sprint-2-ords-deployment` → `develop`
  - [ ] Title: "feat(sprint-2): ORDS handlers real deployment + validation"
  - [ ] Description includes all handler endpoints and test results
  - [ ] Link to QA sign-off document
  - [ ] Review and merge after QA approval
  - [ ] Create `docs/sprint-2/done.md` with handoff notes
  - [ ] Update PROJECT_BRIEF.md sections 7+8 for Sprint 3 planning
- **Blockers:** Waiting for QA sign-off
- **ETA:** 2026-06-17
- **Notes:** Final handoff for Sprint 3 planning

---

## Daily Standups

### Day 1 (2026-06-15)
**Standup:**
- [ ] Sage: ORDS module created? Credentials working?
- [ ] Ivy: Any blockers on test plans?
- [ ] Remy: Any external dependencies needed?

**Status:** 🔄 Starting

---

### Day 2 (2026-06-16)
**Standup:**
- [ ] Sage: All 5 handlers deployed? Smoke tests running?
- [ ] Ivy: Postman collection ready?
- [ ] Remy: Any PR review needed?

**Status:** 🔄 In Progress

---

### Day 3 (2026-06-17)
**Standup:**
- [ ] Ivy: Frontend integration test passed?
- [ ] Ivy: QA sign-off ready for signature?
- [ ] Remy: PR merged to develop?

**Status:** 🔄 Final Day

---

## Critical Blockers

| Blocker | Impact | Owner | Status |
|---------|--------|-------|--------|
| ORDS credentials not provided | SPRINT BLOCKING | Sage + DevOps | ✅ RESOLVED (connected as DBAPER) |
| Oracle DB connection timeout | SPRINT BLOCKING | Sage + DevOps | 🔄 TBD |
| CORS headers not configured on ORDS | HIGH | Sage + DevOps | 🟡 MITIGATED LOCAL (Vite proxy in dev) |
| ORDS handlers/path mismatch (404 NotFound) | HIGH | Sage | ✅ RESOLVED (handlers published + corrected base path) |
| ORDS authorization/policy returns 403 | HIGH | Dash + Sage | 🔴 ACTIVE |
| Frontend env configuration error | MEDIUM | Nova | ✅ RESOLVED (`.env.local` configured, build OK) |

---

## Success Indicators

### Daily Metrics
- Handlers deployed: 0/5 → 1/5 → 3/5 → 5/5 ✅
- Postman tests passing: 0/6 → 2/6 → 4/6 → 6/6 ✅
- Frontend integration: Not Started → In Progress → Passing ✅

### Sprint-End Criteria (Go/No-Go)
- [ ] All 5 handlers deployed (excluding mock exportaciones)
- [ ] All endpoints respond HTTP 200 OK
- [ ] Postman smoke tests: 6/6 passing
- [ ] Frontend integration test: PASSING
- [ ] Sprint 1 QA results: 0 regression
- [ ] QA sign-off: GO recommendation

---

## Artifacts Created This Sprint

| Artifact | Owner | Status | Location |
|----------|-------|--------|----------|
| ORDS Module Config | Sage | ⏳ TBD | `backend/ords/modules/` |
| Handler Configs (5x) | Sage | ⏳ TBD | `backend/ords/modules/handlers/` |
| Postman Collection | Sage + Ivy | ⏳ TBD | `backend/ords/tests/sprint-2/smoke-tests.postman_collection.json` |
| Smoke Test Results | Ivy | ⏳ TBD | `docs/sprint-2/smoke-tests.md` |
| Frontend Integration Report | Nova + Ivy | ⏳ TBD | `docs/sprint-2/frontend-integration.md` |
| QA Sign-off | Ivy | ⏳ TBD | `docs/qa/sprint-2-deployment-signoff.md` |
| Handoff Doc | Remy | ⏳ TBD | `docs/sprint-2/done.md` |

---

## Notes & Lessons Learned

*To be populated as sprint progresses*

- 2026-06-15 08:00: Sprint 2 kickoff - awaiting ORDS credentials
- 2026-06-15 11:47: Task 7A validated - `frontend/.env.local` points to real ORDS and `npm run build` passed.
- 2026-06-15 11:48: Task 7B blocked - browser call to `/transacciones/search` failed by CORS preflight (`Access-Control-Allow-Origin` missing).
- 2026-06-15 11:52: Task 7B rerun with Vite proxy (`http://localhost:3002`) removed CORS preflight failure; backend now responds `404 NotFound` from ORDS route.
- 2026-06-15 11:56: ORDS route probe from terminal confirmed `404` on all candidate paths:
  - `/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos/gerentes`
  - `/ords/infoplan/aprobaciones-rechazos/gerentes`
  - `/ords/infoplan/aprobaciones-rechazos/transacciones/search`
  - `/ords/infoplan/facturacion/aprobaciones-rechazos/gerentes`
  - `/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos`
  Conclusion: module/handlers are not published (or not enabled) in target ORDS schema/environment.
- 2026-06-15 12:00: Recovery plan activated:
  1) Sage validates module + templates + handlers in DB metadata.
  2) Sage republishes endpoints using ORDS APIs compatible with current package version.
  3) Dash validates ORDS mapping/restart and definitive CORS policy.
  4) Nova + Ivy rerun Task 7B immediately after publish.
- 2026-06-15 12:08: Remy delivered execution artifacts for immediate action:
  - `backend/ords/scripts/06_sage_ords_validation_publish_checklist.sql`
  - `docs/sprint-2/DASH_CORS_AND_ROUTING_RUNBOOK.md`
  Next gate: Sage publishes reachable endpoints, then Nova/Ivy rerun Task 7B.
- 2026-06-15 12:12: Sage published minimum handlers in DBAPER (`gerentes`, `intermediarios`, `transacciones/search`) under module `facturacion-aprobaciones-rechazos-v1`.
- 2026-06-15 12:15: Nova switched dev base path to `/ords/infoplan/aprobaciones-rechazos`; browser rerun on `http://localhost:3002` now returns `403 Forbidden` (route exists, auth/policy pending).
- ...

---

**Last Updated:** 2026-06-15 (Task 7 delta applied)  
**Next Update:** After CORS fix + rerun Task 7B smoke checks  
**Prepared by:** Remy (Producer)
