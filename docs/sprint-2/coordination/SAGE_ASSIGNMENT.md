# SAGE — Your Sprint 2 Assignment

**From:** Remy (Producer)  
**To:** Sage (Backend Engineer)  
**Sprint:** Sprint 2 - ORDS Handler Deployment  
**Your Role:** Deploy 5 ORDS handlers to production  
**Timeline:** 2.5 days (2026-06-15 to 2026-06-16)  
**Effort:** 2.5 days

---

## YOUR MISSION

Deploy 5 ORDS handlers for rep_aprobarechazo form. Total effort: **2.5 days**.

**What Success Looks Like:**
- ✅ All 5 handlers deployed to ORDS
- ✅ All endpoints respond HTTP 200 OK
- ✅ Postman smoke tests ready (Ivy will use them)
- ✅ 0 errors in ORDS logs
- ✅ docs/sprint-2/progress.md updated daily

---

## YOUR TASKS (In Order)

### **TASK 1: Create ORDS Module** (0.5 days)
**Deadline:** 2026-06-15 17:00 PM

**What to do:**
1. Connect to ORDS via SQLcl or APEX web console
2. Execute: `backend/ords/scripts/01_create_module.sql`
3. Verify: Module `facturacion-aprobaciones-rechazos-v1` exists in ORDS dashboard

**Success Criteria:**
- [ ] Module visible in ORDS dashboard
- [ ] Base path: `/aprobaciones-rechazos`
- [ ] Enabled: TRUE

**Blocker Resolution:**
- If "credentials not provided" → Ask Remy immediately
- If "connection timeout" → Check network, contact Dash (DevOps)
- If "module already exists" → Drop existing module first (script shows how)

**Update Progress:**
```markdown
# docs/sprint-2/progress.md → Task 1 section:
✅ Task 1: Create ORDS Module - DONE (2026-06-15 14:30)
  - Module created: facturacion-aprobaciones-rechazos-v1
  - Base path: /aprobaciones-rechazos
  - Status: Ready for handler deployment
```

---

### **TASK 2: Deploy transacciones/search Handler** (0.75 days)
**Deadline:** 2026-06-16 noon

**What to do:**
1. Execute: `backend/ords/scripts/02_handler_transacciones_search.sql`
2. Verify: Handler exists in ORDS
3. Test: POST to `/transacciones/search` with date range 2026-01-01 to 2026-01-31
4. Expected: 500+ rows returned (JSON array format)

**SQL Verification:**
```sql
SELECT * FROM user_ords_handlers 
WHERE module_name='facturacion-aprobaciones-rechazos-v1' 
AND uri_pattern='transacciones/search';
```

**Postman Test (for Ivy):**
```http
POST https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos/transacciones/search
Content-Type: application/json

{
  "fec_ini": "2026-01-01",
  "fec_fin": "2026-01-31",
  "cliente": null,
  "oficial": null,
  "gerente": null,
  "intermediario": null
}
```

**Expected Response Schema:**
```json
[
  {
    "id_transaccion": 1,
    "fecha": "2026-01-05",
    "cliente": "Client A",
    "monto": 1000.00,
    ...
  },
  ...
]
```

**Blocker Resolution:**
- If "ORA-01799 outer join error" → Already fixed in script with CTEs
- If "bind variable error" → Check parameter names (fec_ini, fec_fin, etc.)
- If "500 rows not returned" → Check date range in test data

**Update Progress:**
```markdown
# docs/sprint-2/progress.md → Task 2 section:
✅ Task 2: transacciones/search Handler - DONE (2026-06-16 12:00)
  - Handler deployed: POST /transacciones/search
  - Test result: 500 rows returned
  - Response schema: ✅ Matches SearchResponse[] in types.ts
```

---

### **TASK 3: Deploy oficiales/{codigo} Handler** (0.5 days)
**Deadline:** 2026-06-16 14:00

**What to do:**
1. Execute: `backend/ords/scripts/03_handler_oficiales.sql`
2. Verify: Handler exists in ORDS
3. Test: GET `/oficiales/1` (sample oficial)
4. Expected: Single row JSON with { codigo, nombre }

**Postman Test:**
```http
GET https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos/oficiales/1
```

**Expected Response:**
```json
{
  "codigo": 1,
  "nombre": "Official Name"
}
```

**Update Progress:**
```markdown
✅ Task 3: oficiales/{codigo} Handler - DONE (2026-06-16 14:00)
  - Handler deployed: GET /oficiales/:codigo_oficial
  - Test result: ✅ Lookup working
```

---

### **TASK 4: Deploy LOV Handlers (gerentes & intermediarios)** (0.5 days)
**Deadline:** 2026-06-16 15:30

**What to do:**
1. Execute: `backend/ords/scripts/04_handler_lovs.sql`
2. Verify: 2 handlers exist in ORDS (gerentes + intermediarios)
3. Test: Both endpoints return arrays with DISTINCT entries

**Postman Tests:**
```http
# Gerentes
GET https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos/gerentes

# Intermediarios
GET https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos/intermediarios
```

**Expected Response (both):**
```json
[
  { "codigo": 1, "nombre": "Gerente Name 1" },
  { "codigo": 2, "nombre": "Gerente Name 2" },
  ...
]
```

**Expected Counts:**
- Gerentes: ~58 unique entries
- Intermediarios: ~500+ unique entries

**Update Progress:**
```markdown
✅ Task 4: gerentes & intermediarios LOV - DONE (2026-06-16 15:30)
  - Handler deployed: GET /gerentes (58 entries)
  - Handler deployed: GET /intermediarios (500+ entries)
```

---

### **TASK 5: Deploy seleccion/{M|D} Handler** (0.5 days)
**Deadline:** 2026-06-16 17:00 PM

**What to do:**
1. Execute: `backend/ords/scripts/05_handler_seleccion.sql`
2. Verify: Handler exists in ORDS
3. Test: POST `/transacciones/seleccion/M` (mark) and `/D` (unmark)
4. Expected: { message: "success", updated: N }

**Postman Test:**
```http
# Mark transactions
POST https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos/transacciones/seleccion/M
Content-Type: application/json

{
  "ids": "1,2,3",
  "action": "M"
}

# Unmark transactions
POST https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos/transacciones/seleccion/D
Content-Type: application/json

{
  "ids": "1,2,3",
  "action": "D"
}
```

**Expected Response:**
```json
{
  "message": "success",
  "action": "M",
  "updated": 3
}
```

**Update Progress:**
```markdown
✅ Task 5: seleccion/{M|D} Handler - DONE (2026-06-16 17:00)
  - Handler deployed: POST /transacciones/seleccion/M (mark)
  - Handler deployed: POST /transacciones/seleccion/D (unmark)
  - Test result: ✅ Both actions working
```

---

### **TASK 6: Smoke Tests with Ivy** (0.5 days)
**Deadline:** 2026-06-17 10:00 AM

**What to do:**
1. Work with Ivy to create Postman collection: `backend/ords/tests/sprint-2/smoke-tests.postman_collection.json`
2. Test sequence:
   - GET /gerentes → expect 58 rows
   - GET /intermediarios → expect 500+ rows
   - POST /transacciones/search (2026-01-01 to 2026-01-31) → expect 500+ rows
   - GET /oficiales/1 → expect 1 row
   - POST /transacciones/seleccion/M (sample IDs) → expect success
   - POST /transacciones/seleccion/D (same IDs) → expect unmark success
3. All tests must pass: 6/6 ✅

**Output:**
- Postman collection saved: `backend/ords/tests/sprint-2/smoke-tests.postman_collection.json`
- Results documented: `docs/sprint-2/smoke-tests.md` (Ivy leads, you contribute)

**Update Progress:**
```markdown
✅ Task 6: Smoke Tests - DONE (2026-06-17 10:00)
  - Postman collection created: smoke-tests.postman_collection.json
  - All 6 tests passing: ✅ 6/6
  - Response payloads validated against types.ts
```

---

## DELIVERABLES (What Remy Will Check)

By **2026-06-17 10:00 AM**, I expect:
- [ ] All 5 handlers deployed to ORDS
- [ ] All endpoints responding 200 OK
- [ ] Postman smoke tests 6/6 passing
- [ ] docs/sprint-2/progress.md updated with all task completions
- [ ] Any GitHub Issues filed (with `sprint-2` label)
- [ ] Handoff to Ivy for integration testing

---

## DAILY UPDATES (Required)

**Update `docs/sprint-2/progress.md` at END OF EACH DAY with:**
1. % complete for each task (0%, 25%, 50%, 75%, 100%)
2. What was accomplished
3. What's planned for tomorrow
4. Any blockers

**Format Example:**
```markdown
### Task 2: transacciones/search Handler
- **Status:** 🔄 IN PROGRESS (75%)
- **Completed:** Script executed, handler deployed, SQL tests passing
- **In Progress:** Testing with Postman (sample dates)
- **Planned Tomorrow:** Full smoke test, validate response schema
- **Blockers:** None
```

---

## BLOCKER RESOLUTION

**If you hit a blocker:**
1. Document in progress.md immediately
2. Tell Remy right away (don't wait for standup)
3. I will escalate if needed (to Dash, DevOps, or Cesar)

**Examples of blockers:**
- ORDS credentials not provided → Remy escalates to Cesar
- Oracle DB connection timeout → Remy engages Dash (DevOps)
- Handler deployment error (ORA-xxxxx) → I may escalate to Oracle support or Dash
- Network connectivity issue → Remy coordinates with Dash

---

## SUCCESS LOOKS LIKE

**End of Task 6 (2026-06-17 10:00 AM):**
- ✅ 5 handlers deployed and live
- ✅ Postman tests ready for Ivy (6/6 passing)
- ✅ 0 errors in ORDS logs
- ✅ Handed off to Ivy + Nova for integration testing
- ✅ Remy reviews, confirms quality, proceeds to Task 7

**Your Effort:** 2.5 days of solid backend work  
**Your Impact:** Handlers live, ready for production  
**Next:** Frontend integration (Nova's job), QA validation (Ivy's job), my merge (Remy's job)

---

## CONTACT REMY IF...

- ❌ You need ORDS credentials (Remy gets them)
- ❌ Oracle DB connection issues (Remy escalates to Dash)
- ❌ Unclear task requirements (Remy clarifies)
- ❌ Blocker that's not technical (Remy handles)
- ✅ Task complete (Remy verifies, documents)

---

## YOUR EFFORT ESTIMATE

| Task | Hours | Days |
|------|-------|------|
| Task 1: Create Module | 3 | 0.5 |
| Task 2: transacciones/search | 6 | 0.75 |
| Task 3: oficiales | 4 | 0.5 |
| Task 4: LOVs | 4 | 0.5 |
| Task 5: seleccion | 4 | 0.5 |
| Task 6: Smoke Tests (with Ivy) | 4 | 0.5 |
| **TOTAL** | **25 hours** | **2.5 days** |

---

**READY TO START, SAGE?**

Let me know:
1. Do you have ORDS credentials?
2. When can you start Task 1?
3. Any questions about the scripts?

**Remy is here to unblock you. GO!**

---

*Assignment from Remy (Producer). Valid for Sprint 2. Follow docs/sprint-2/plan.md for full context.*
