# ORDS Scripts Index — Sprint 2 Deployment

**Status:** ✅ All 5 scripts ready for execution  
**Total Time:** ~30 minutes  
**Target:** Deploy 5 ORDS handlers for rep_aprobarechazo form

---

## Scripts Summary

| Script | Handler | Endpoint | Method | Type | Time | Status |
|--------|---------|----------|--------|------|------|--------|
| `01_create_module.sql` | Module | n/a | n/a | Module Creation | 5 min | ✅ Ready |
| `02_handler_transacciones_search.sql` | transacciones/search | POST /transacciones/search | POST | plsql/block | 5 min | ✅ Ready |
| `03_handler_oficiales.sql` | oficiales/{codigo} | GET /oficiales/{codigo_oficial} | GET | json/query | 3 min | ✅ Ready |
| `04_handler_lovs.sql` | gerentes & intermediarios | GET /gerentes + GET /intermediarios | GET | json/collection | 3 min | ✅ Ready |
| `05_handler_seleccion.sql` | seleccion/{M\|D} | POST /transacciones/seleccion/{M\|D} | POST | plsql/block | 5 min | ✅ Ready |

---

## Execution Order

### Step 1: Create Module (MUST BE FIRST)
```bash
# File: 01_create_module.sql
# Execution: ~5 minutes
# Purpose: Register ORDS module container for all handlers
@01_create_module.sql
```

### Step 2: Deploy All Handlers (in order)
```bash
# File: 02_handler_transacciones_search.sql
@02_handler_transacciones_search.sql

# File: 03_handler_oficiales.sql
@03_handler_oficiales.sql

# File: 04_handler_lovs.sql
@04_handler_lovs.sql

# File: 05_handler_seleccion.sql
@05_handler_seleccion.sql
```

**Total Execution Time:** ~20 minutes for all handlers

---

## What Each Script Does

### `01_create_module.sql`
- **What:** Creates ORDS module `facturacion-aprobaciones-rechazos-v1`
- **Where:** Registers base path `/aprobaciones-rechazos`
- **Why:** Container for all 5 handlers
- **Output:** Module visible in ORDS dashboard
- **Rollback:** `BEGIN ords.drop_module('facturacion-aprobaciones-rechazos-v1'); COMMIT; END; /`

---

### `02_handler_transacciones_search.sql`
- **What:** Creates POST endpoint for searching transactions
- **Endpoint:** `POST /transacciones/search`
- **Input (JSON):** `{ "fec_ini": "2026-01-01", "fec_fin": "2026-01-31", "cliente": null, "oficial": null, "gerente": null, "intermediario": null }`
- **Output (JSON):** Array of 500+ transaction rows with 19 columns each
- **Query:** Parameterized with CTEs (avoids ORA-01799 outer join errors)
- **Performance:** FETCH FIRST 500 ROWS for UI responsiveness
- **Data Source:** TRANSACCIONES_COBRO_RECURRENTE + lookups
- **Rollback:** Drop handler via ORDS admin

---

### `03_handler_oficiales.sql`
- **What:** Creates GET endpoint for official lookup
- **Endpoint:** `GET /oficiales/{codigo_oficial}`
- **Input:** Path parameter `{codigo_oficial}` (e.g., `1`)
- **Output (JSON):** `{ "codigo": 1, "nombre": "Official Name" }`
- **Status Code:** 200 OK on success, 404 Not Found if oficial doesn't exist
- **Data Source:** MOFICIAL table (estatus=76 for vigente only)

---

### `04_handler_lovs.sql`
- **What:** Creates TWO GET endpoints for dropdown population
- **Endpoint 1:** `GET /gerentes` → 58 unique entries
- **Endpoint 2:** `GET /intermediarios` → 500+ unique entries
- **Output (JSON):** `[ { "codigo": N, "nombre": "Name" }, ... ]`
- **Data Source:** INT_GER_DIR01_V (DISTINCT to avoid duplicates)
- **Use Case:** Frontend dropdowns for filtering

---

### `05_handler_seleccion.sql`
- **What:** Creates POST endpoint for marking/unmarking transactions
- **Endpoint:** `POST /transacciones/seleccion/:action`
- **Actions:** `:action` = `M` (mark) or `D` (unmark)
- **Input (JSON):** `{ "ids": "1,2,3", "action": "M" }`
- **Output (JSON):** `{ "message": "success", "action": "M", "updated": 3 }`
- **Operation:** Updates `seleccionado` field in TRANSACCIONES_COBRO_RECURRENTE
- **Data Source:** TRANSACCIONES_COBRO_RECURRENTE table

---

## Pre-Execution Checklist

- [ ] ORDS credentials available (host, port, username, password)
- [ ] SQLcl installed OR APEX web console accessible
- [ ] Oracle DB admin account (or app account with PL/SQL privileges)
- [ ] Network connectivity to infoplan-web-dev.humano.local:8888
- [ ] All 5 scripts in `backend/ords/scripts/` directory
- [ ] README_ORDS_DEPLOYMENT.md reviewed

---

## Post-Execution Validation

### Smoke Test 1: Verify Module
```sql
SELECT name, base_path, enabled FROM user_ords_modules 
WHERE name = 'facturacion-aprobaciones-rechazos-v1';

-- Expected: 1 row, enabled=TRUE
```

### Smoke Test 2: Verify Handlers
```sql
SELECT module_name, uri_pattern, method FROM user_ords_handlers
WHERE module_name = 'facturacion-aprobaciones-rechazos-v1'
ORDER BY uri_pattern;

-- Expected: 5 rows (search, oficiales, gerentes, intermediarios, seleccion)
```

### Smoke Test 3: Verify Handler Count
```sql
SELECT COUNT(*) FROM user_ords_handlers
WHERE module_name = 'facturacion-aprobaciones-rechazos-v1';

-- Expected: 5
```

### Smoke Test 4: Test Endpoints (Postman)
- GET /gerentes → expect 58 rows
- GET /intermediarios → expect 500+ rows
- POST /transacciones/search (date range 2026-01-01 to 2026-01-31) → expect 500+ rows
- GET /oficiales/1 → expect 1 row
- POST /transacciones/seleccion/M → expect success

---

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Module already exists | Previous deployment | Drop module first: `BEGIN ords.drop_module(...); END; /` |
| Handler syntax error | PL/SQL syntax issue | Check ORDS logs, validate SQL in script |
| ORA-01799 outer join error | Subquery in FROM with (+) | ✅ Already fixed in script with CTEs |
| 404 Not Found | Handler not registered | Check handler registration in ORDS |
| CORS error in frontend | ORDS CORS headers not set | Contact DevOps to enable CORS |
| No rows returned | Data doesn't exist | Verify date range, check table contents |

---

## File Locations

```
backend/ords/scripts/
├── README_ORDS_DEPLOYMENT.md    ← Start here
├── INDEX.md                      ← This file
├── 01_create_module.sql
├── 02_handler_transacciones_search.sql
├── 03_handler_oficiales.sql
├── 04_handler_lovs.sql
└── 05_handler_seleccion.sql
```

---

## Next Steps After Deployment

1. **Postman Testing** (`backend/ords/tests/sprint-2/smoke-tests.postman_collection.json`)
   - Import collection
   - Run all 6 endpoint tests
   - Verify 6/6 passing

2. **Frontend Integration** (`frontend/` on localhost:3000)
   - Update `VITE_ORDS_BASE_URL` to real ORDS
   - Test LOV dropdowns populate
   - Test search with real data

3. **QA Sign-off** (`docs/qa/sprint-2-deployment-signoff.md`)
   - Document validation results
   - File any defects
   - Recommendation: GO or blockers

4. **Git & Merge** (feature branch → develop)
   - Commit scripts with message: "feat(sprint-2): Deploy 5 ORDS handlers"
   - Create PR with QA sign-off
   - Merge after approval

---

## Contact & Support

- **Questions about scripts?** Review inline comments in each .sql file
- **ORDS deployment issues?** Contact DevOps/Database team
- **Frontend integration issues?** Check `docs/sprint-2/frontend-integration.md`
- **Sprint coordination?** See `docs/sprint-2/ORCHESTRATION.md`

---

**Scripts Created:** 2026-06-15  
**Status:** ✅ Ready for Execution  
**Approval:** Cesar (CEO)  
**Target Completion:** 2026-06-17

---

**Next Action:** Execute scripts in order (01 → 02 → 03 → 04 → 05) using SQLcl or APEX
