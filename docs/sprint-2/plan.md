# Sprint 2 Plan: ORDS Handlers Real Deployment

**Sprint Goal:** Execute SQL scripts to deploy 6 ORDS handlers for rep_aprobarechazo form. Validate all endpoints responding and integrate with Sprint 1 React frontend.

**Governance Rule (Reuse-First):** Reuse existing ORDS modules by default. Create a new module only when a functional/domain-fit module does not exist or reuse introduces unacceptable regression risk. Any new module must include explicit written justification in sprint artifacts.

**Sprint Owner:** Sage (Backend Engineer)  
**QA Owner:** Ivy  
**Coordination:** Remy (Producer)

**Duration:** ~2 days (2026-06-15 to 2026-06-17)

---

## 1. Scope

### Handlers to Deploy (6 total)

| Handler | Endpoint | Method | Status | Notes |
|---------|----------|--------|--------|-------|
| **transacciones/search** | POST /transacciones/search | POST | ✏️ READY | 500 real rows from TRANSACCIONES_COBRO_RECURRENTE |
| **oficiales/{codigo}** | GET /oficiales/{codigo_oficial} | GET | ✏️ READY | CLIENTE + MOFICIAL lookup |
| **gerentes** | GET /gerentes | GET | ✏️ READY | INT_GER_DIR01_V DISTINCT, 58 rows |
| **intermediarios** | GET /intermediarios | GET | ✏️ READY | INT_GER_DIR01_V DISTINCT, 500+ rows |
| **seleccion/{M\|D}** | POST /transacciones/seleccion/{M\|D} | POST | ✏️ READY | Mark/Unmark transactions for action |
| **exportaciones/{ole\|jasper}** | POST /exportaciones/{ole\|jasper} | POST | ✏️ MOCK | Sprint 1 intentional - will be real in Sprint 3 |

**Success Criteria:**
- ✅ All 5 handlers (excluding mock exportaciones) deployed to ORDS
- ✅ Each handler responds with HTTP 200 OK
- ✅ Response payloads match Sprint 1 frontend expectations (types in types.ts)
- ✅ Sprint 1 frontend still works when pointing to real ORDS handlers
- ✅ QA smoke tests all pass
- ✅ Zero data loss from Sprint 1 validation
- ✅ For each handler, target module decision documented (`reused` or `new-with-justification`)

---

## 2. Pre-Sprint Requirements

### What We Have (Sprint 1 Artifacts)

- ✅ SQL query files (in `backend/ords/sql/`)
  - `01_transacciones_search_real.sql` — main search query with CTEs
  - `02_oficiales_real.sql` — official lookup
  - LOV CTEs for gerentes/intermediarios

- ✅ Frontend code (React in `frontend/src/`)
  - All types defined in `types.ts`
  - API client in `api/ordsClient.ts` with function signatures
  - Components ready in `components/`

- ✅ Git branch
  - `feature/sprint-1-rep-aprobarechazo` pushed, QA sign-off complete

### What We Need (Sprint 2 Execution)

1. **ORDS Access:**
   - Host: infoplan-web-dev.humano.local
   - Port: 8888 (ORDS default)
   - Base URL: `https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos`
   - Authentication: TBD (Sage to confirm with DevOps)

2. **Oracle DB Access:**
   - User/password for creating modules and procedures (admin or app account)
   - Database version: Oracle 19c+

3. **ORDS Module Registration:**
   - Module name: `facturacion-aprobaciones-rechazos-v1`
   - Base path: `/aprobaciones-rechazos`
   - Handler template: JSON (json/collection, json/query, plsql/block)

---

## 3. Sprint 2 Tasks

### Task 1: Create ORDS Module (0.5d) — Sage

**Objective:** Register new module in ORDS for handlers

**Actions:**
1. Connect to ORDS admin interface (web console or SQLcl)
2. Create new module:
   - Name: `facturacion-aprobaciones-rechazos-v1`
   - Base path: `/aprobaciones-rechazos`
   - URI prefix: `/api/v1`
3. Verify module created via GET `/ords/info` or ORDS dashboard

**Definition of Done:**
- [ ] Module visible in ORDS dashboard
- [ ] Base URL accessible: `https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos`
- [ ] Module registered in docs/sprint-2/progress.md

**Files/Scripts:**
- `backend/ords/scripts/01_create_module.sql` (to create)
- `backend/ords/scripts/01_create_module.http` (Postman test)

---

### Task 2: Deploy Handler - transacciones/search (0.75d) — Sage

**Objective:** Deploy POST /transacciones/search handler

**Actions:**
1. Load SQL from `backend/ords/sql/01_transacciones_search_real.sql`
2. Register as ORDS handler type: `plsql/block` (parameterized query)
3. Bind variables: `:fec_ini`, `:fec_fin`, `:cliente`, `:oficial`, `:gerente`, `:intermediario` (all optional with NULL checks)
4. Response format: json/collection
5. Test with Postman: POST with date range 2026-01-01 to 2026-01-31
6. Verify response: 500 rows returned

**Definition of Done:**
- [ ] Handler registered in ORDS
- [ ] POST /transacciones/search returns HTTP 200 OK
- [ ] Response contains 500+ rows for 2026-01-01 to 2026-01-31
- [ ] Response JSON schema matches `SearchResponse[]` in types.ts
- [ ] Postman test saved to `backend/ords/tests/sprint-2/transacciones-search.http`

**Files:**
- Source SQL: `backend/ords/sql/01_transacciones_search_real.sql`
- ORDS Handler Config: `backend/ords/modules/handlers/transacciones-search.sql` (to create)
- Postman Test: `backend/ords/tests/sprint-2/transacciones-search.http` (to create)

---

### Task 3: Deploy Handler - oficiales/{codigo} (0.5d) — Sage

**Objective:** Deploy GET /oficiales/{codigo_oficial} handler

**Actions:**
1. Load SQL from `backend/ords/sql/02_oficiales_real.sql`
2. Register as ORDS handler type: `json/query`
3. Path parameter: `{codigo_oficial}` (required, integer)
4. Response format: json/query
5. Test with Postman: GET /oficiales/1 (sample data)
6. Verify response: single oficial record or 404 if not found

**Definition of Done:**
- [ ] Handler registered in ORDS
- [ ] GET /oficiales/{codigo_oficial} returns HTTP 200 OK
- [ ] Response contains 1 record with fields: codigo, nombre
- [ ] Postman test saved to `backend/ords/tests/sprint-2/oficiales.http`

**Files:**
- Source SQL: `backend/ords/sql/02_oficiales_real.sql`
- ORDS Handler Config: `backend/ords/modules/handlers/oficiales.sql` (to create)
- Postman Test: `backend/ords/tests/sprint-2/oficiales.http` (to create)

---

### Task 4: Deploy Handler - gerentes & intermediarios (0.5d) — Sage

**Objective:** Deploy GET /gerentes and GET /intermediarios handlers

**Actions:**
1. Query INT_GER_DIR01_V for gerentes (DISTINCT, 58 rows expected)
2. Register as ORDS handler type: `json/collection`
3. Response format: LovListResponse { items: LovItem[] }
4. Repeat for intermediarios (500+ rows expected)
5. Test both with Postman

**Definition of Done:**
- [ ] GET /gerentes returns 58 unique records
- [ ] GET /intermediarios returns 500+ records
- [ ] Response schema matches `LovListResponse` in types.ts
- [ ] Postman tests saved to `backend/ords/tests/sprint-2/lovs.http`

**Files:**
- ORDS Handler Config: `backend/ords/modules/handlers/lovs.sql` (to create, contains both endpoints)
- Postman Test: `backend/ords/tests/sprint-2/lovs.http` (to create)

---

### Task 5: Deploy Handler - seleccion/{M|D} (0.5d) — Sage

**Objective:** Deploy POST /transacciones/seleccion/{M|D} handler for marking/unmarking transactions

**Actions:**
1. Register POST /transacciones/seleccion/M (mark/approve)
2. Register POST /transacciones/seleccion/D (unmark/delete)
3. Path parameter: `{M|D}` determines action
4. Request body: { id_transaccion: number[], action: 'M' | 'D' }
5. Response: { message: "success", updated: N } or error
6. Test with Postman: POST with sample transaction IDs

**Definition of Done:**
- [ ] Both handlers registered in ORDS
- [ ] POST returns HTTP 200 OK
- [ ] Response includes updated count
- [ ] Postman tests saved to `backend/ords/tests/sprint-2/seleccion.http`

**Files:**
- ORDS Handler Config: `backend/ords/modules/handlers/seleccion.sql` (to create)
- Postman Test: `backend/ords/tests/sprint-2/seleccion.http` (to create)

---

### Task 6: Smoke Test All Handlers (0.5d) — Sage + Ivy

**Objective:** Validate all handlers working together

**Actions:**
1. Run Postman collection: `backend/ords/tests/sprint-2/smoke-tests.postman_collection.json`
2. Verify all endpoints: ✅ 200 OK, ❌ 0 errors
3. Check response payloads against types.ts schema
4. Document results in docs/sprint-2/smoke-tests.md

**Smoke Test Sequence:**
1. GET /gerentes → verify 58 records
2. GET /intermediarios → verify 500+ records
3. POST /transacciones/search (date range 2026-01-01 to 2026-01-31) → verify 500+ records
4. GET /oficiales/1 → verify 1 record
5. POST /transacciones/seleccion/M (sample ID) → verify success
6. POST /transacciones/seleccion/D (same sample ID) → verify unmark

**Definition of Done:**
- [ ] All 6 endpoints respond with 200 OK
- [ ] Response payloads match types.ts
- [ ] Postman collection passes all tests
- [ ] results saved to docs/sprint-2/smoke-tests.md

**Files:**
- Postman Collection: `backend/ords/tests/sprint-2/smoke-tests.postman_collection.json` (to create)
- Results Doc: `docs/sprint-2/smoke-tests.md` (to create)

---

### Task 7: Frontend Integration Test (0.5d) — Nova + Ivy

**Objective:** Validate Sprint 1 frontend works against real ORDS handlers

**Actions:**
1. Update frontend `vite.config.ts` or `.env` to point to real ORDS:
   - `VITE_ORDS_BASE_URL=https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos`
2. Launch frontend: `npm run dev` on localhost:3000
3. QA smoke test:
   - [ ] Page loads
   - [ ] Gerente dropdown shows 58 entries
   - [ ] Intermediario dropdown shows 500+ entries
   - [ ] Search with date range 2026-01-01 to 2026-01-31 returns 500+ rows
   - [ ] Results table displays 19 columns correctly
   - [ ] No 404 or CORS errors in console
4. Screenshot of working page (same as Sprint 1 demo)

**Definition of Done:**
- [ ] Frontend loads without errors
- [ ] All LOV dropdowns populated from real ORDS endpoints
- [ ] Search returns real data
- [ ] 0 console errors
- [ ] Screenshots in docs/sprint-2/frontend-integration.md

**Files:**
- Frontend env config: `frontend/.env.sprint-2` (to create, if needed)
- Test report: `docs/sprint-2/frontend-integration.md` (to create)

---

### Task 8: QA Sign-off (0.5d) — Ivy

**Objective:** Write QA deployment sign-off document

**Actions:**
1. Create `docs/qa/sprint-2-deployment-signoff.md`
2. Document:
   - All handler endpoints deployed and responding
   - Postman smoke tests passed (all 6 endpoints)
   - Frontend integration test passed
   - Response payloads match types.ts schema
   - 0 data loss from Sprint 1
   - Recommendation: GO for Sprint 3 or READY for production merge
3. File any bugs as GitHub Issues if found

**Definition of Done:**
- [ ] Sign-off document created and committed
- [ ] QA recommendation: GO or blockers documented
- [ ] GitHub Issues filed for any defects (with sprint-2 label)

**Files:**
- QA Sign-off: `docs/qa/sprint-2-deployment-signoff.md` (to create)

---

### Task 9: Git & Handoff (0.5d) — Remy

**Objective:** Merge Sprint 2 to develop, document for Sprint 3 planning

**Actions:**
1. Create PR: `feature/sprint-2-ords-deployment` → `develop`
   - Title: "feat(sprint-2): ORDS handlers real deployment + validation"
   - Description: Include all 6 handler endpoints, smoke test results, QA GO
   - Link to: docs/qa/sprint-2-deployment-signoff.md
2. Review and merge after QA sign-off
3. Create `docs/sprint-2/done.md` with handoff notes
4. Update PROJECT_BRIEF.md sections 7 + 8

**Definition of Done:**
- [ ] PR merged to develop
- [ ] docs/sprint-2/done.md written
- [ ] PROJECT_BRIEF.md updated with Sprint 2 completion
- [ ] Git log shows atomic commits per handler deployment

**Files:**
- Handoff Doc: `docs/sprint-2/done.md` (to create)
- Updated Brief: PROJECT_BRIEF.md sections 7+8 (already updated)

---

## 4. Success Criteria (Sprint 2 Overall)

### Must-Have (Go/No-Go)
- ✅ All 5 handlers deployed (excluding mock exportaciones)
- ✅ All endpoints respond HTTP 200 OK
- ✅ Postman smoke tests pass (6/6 endpoints)
- ✅ Frontend integration test passes
- ✅ Sprint 1 QA sign-off results still valid (0 regression)
- ✅ 0 data loss

### Nice-to-Have
- ✅ Handler deployment scripts documented for reuse (Wave 2 forms)
- ✅ Postman collection exportable for team
- ✅ ORDS handler versioning documented

### Acceptance Definition
Sprint 2 is **DONE** when:
1. All 5 ORDS handlers deployed and returning correct data
2. Sprint 1 frontend working against real handlers (localhost:3000)
3. QA sign-off document filed with GO recommendation
4. Feature branch merged to develop
5. Handoff doc ready for Sprint 3 planning

---

## 5. Risks & Mitigations

| Risk | Probability | Mitigation |
|------|-------------|-----------|
| ORDS connectivity issues | Medium | Test connection early; contact DevOps if blocked |
| Oracle DB credentials expired | Low | Confirm creds before sprint; store in GitHub Secrets |
| Handler deployment syntax errors | Medium | Test each handler in isolation before integration |
| CORS headers blocking frontend | Medium | Verify ORDS CORS config; update if needed |
| Data schema mismatch (frontend expects different JSON) | Low | Validate against types.ts; adjust handler response format |

---

## 6. Team Assignments

| Task | Owner | Duration | Start | End |
|------|-------|----------|-------|-----|
| Task 1: Create Module | Sage | 0.5d | 2026-06-15 | 2026-06-15 |
| Task 2: transacciones/search | Sage | 0.75d | 2026-06-15 | 2026-06-16 |
| Task 3: oficiales/{codigo} | Sage | 0.5d | 2026-06-16 | 2026-06-16 |
| Task 4: gerentes/intermediarios | Sage | 0.5d | 2026-06-16 | 2026-06-16 |
| Task 5: seleccion/{M\|D} | Sage | 0.5d | 2026-06-16 | 2026-06-16 |
| Task 6: Smoke Tests | Sage+Ivy | 0.5d | 2026-06-16 | 2026-06-17 |
| Task 7: Frontend Integration | Nova+Ivy | 0.5d | 2026-06-17 | 2026-06-17 |
| Task 8: QA Sign-off | Ivy | 0.5d | 2026-06-17 | 2026-06-17 |
| Task 9: Git & Handoff | Remy | 0.5d | 2026-06-17 | 2026-06-17 |

**Total Effort:** 5 days (Sage heavy lifting, Ivy validation, Nova support)

---

## 7. Acceptance & Go-Live

### Pre-Deployment Checklist
- [ ] All SQL scripts validated (no syntax errors)
- [ ] ORDS module created and registered
- [ ] 5 handlers deployed (searchback + LOVs + seleccion)
- [ ] Postman smoke tests 6/6 passing
- [ ] Frontend still works (no regression)
- [ ] QA sign-off: GO

### Post-Deployment Checklist
- [ ] Feature merged to develop
- [ ] Sprint 2 done.md handoff written
- [ ] All commits reference issues (if any)
- [ ] docs/qa/sprint-2-deployment-signoff.md accessible
- [ ] PROJECT_BRIEF.md updated

---

**Sprint 2 Plan Created:** 2026-06-15  
**Owner:** Sage (Backend) + Ivy (QA) + Remy (Coordination)  
**Approval:** Cesar (CEO) - ready to execute
