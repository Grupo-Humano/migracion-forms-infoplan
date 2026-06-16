# ORDS Handlers Deployment Guide

**Purpose:** Step-by-step instructions to deploy 5 ORDS handlers for rep_aprobarechazo form.

**Target Environment:** 
- Host: `infoplan-web-dev.humano.local`
- Port: `8888`
- Base URL: `https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos`

**Execution Time:** ~30 minutes total

---

## Prerequisites

### Required
- [ ] ORDS admin access (SQLcl or APEX web console)
- [ ] Oracle DB admin or app account (can execute PL/SQL)
- [ ] Network access to infoplan-web-dev.humano.local:8888
- [ ] Postman or curl (for testing endpoints)

### Optional
- [ ] Git clone of this repo (for tracking changes)
- [ ] Text editor (to modify scripts if needed)

---

## Step 1: Create ORDS Module (5 min)

**File:** `01_create_module.sql`

### Option A: SQLcl CLI
```bash
# Connect to ORDS SQLcl
sqlcl /

# Run the module creation script
@01_create_module.sql

# Verify creation
SELECT * FROM user_ords_modules WHERE NAME='facturacion-aprobaciones-rechazos-v1';
```

### Option B: APEX Web Console
1. Navigate to: `https://infoplan-web-dev.humano.local/ords/apex_admin`
2. Login with ORDS admin credentials
3. Go to: **SQL Workshop → SQL Commands**
4. Copy contents of `01_create_module.sql` and run
5. Verify in: **ORDS Admin → Modules**

### Expected Result
```
Module Name: facturacion-aprobaciones-rechazos-v1
Base Path: /aprobaciones-rechazos
URI Prefix: /api/v1
Status: CREATED
```

---

## Step 2: Deploy 5 Handlers (25 min)

### Handler 1: transacciones/search (5 min)
**File:** `02_handler_transacciones_search.sql`

```bash
# Execute in SQLcl or APEX
@02_handler_transacciones_search.sql

# Verify
SELECT * FROM user_ords_handlers 
WHERE module_name='facturacion-aprobaciones-rechazos-v1' 
AND uri_pattern='transacciones/search';
```

**Test with Postman:**
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

**Expected Response:**
```json
{
  "items": [
    {
      "id_transaccion": 1,
      "fecha": "2026-01-05",
      "cliente": "Client A",
      ...
    },
    ...
  ]
}
```

---

### Handler 2: oficiales/{codigo} (3 min)
**File:** `03_handler_oficiales.sql`

```bash
@03_handler_oficiales.sql
```

**Test with Postman:**
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

---

### Handler 3: gerentes & intermediarios (3 min)
**File:** `04_handler_lovs.sql`

```bash
@04_handler_lovs.sql
```

**Test with Postman:**
```http
# Gerentes
GET https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos/gerentes

# Intermediarios
GET https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos/intermediarios
```

**Expected Response (both):**
```json
{
  "items": [
    { "codigo": 1, "nombre": "Name 1" },
    { "codigo": 2, "nombre": "Name 2" },
    ...
  ]
}
```

---

### Handler 4: seleccion/{M|D} (5 min)
**File:** `05_handler_seleccion.sql`

```bash
@05_handler_seleccion.sql
```

**Test with Postman:**
```http
# Mark transactions
POST https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos/transacciones/seleccion/M
Content-Type: application/json

{
  "ids": [1, 2, 3],
  "action": "M"
}
```

**Expected Response:**
```json
{
  "message": "success",
  "updated": 3
}
```

---

## Step 3: Smoke Tests (5 min)

### Postman Collection
Import `backend/ords/tests/sprint-2/smoke-tests.postman_collection.json`

**Run all tests:**
1. GET /gerentes → Expect 58 rows
2. GET /intermediarios → Expect 500+ rows
3. POST /transacciones/search (2026-01-01 to 2026-01-31) → Expect 500+ rows
4. GET /oficiales/1 → Expect 1 row
5. POST /transacciones/seleccion/M → Expect success
6. POST /transacciones/seleccion/D → Expect success

**Expected Result:**
```
✅ All 6 tests PASS
✅ 0 errors
✅ 0 timeouts
```

---

## Step 4: Validate Frontend Integration (5 min)

### Update Frontend Env
**File:** `frontend/.env` or `frontend/.env.sprint-2`

```env
VITE_ORDS_BASE_URL=https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos
```

### Launch Frontend
```bash
cd frontend
npm run dev
# Opens http://localhost:3000
```

### Test Checklist
- [ ] Page loads (no 404 or CORS errors in console)
- [ ] Gerente dropdown shows 58 entries
- [ ] Intermediario dropdown shows 500+ entries
- [ ] Search with 2026-01-01 to 2026-01-31 returns 500+ rows
- [ ] Results table displays 19 columns correctly
- [ ] No validation errors

---

## Troubleshooting

### ORDS Module Creation Failed
**Error:** `ORA-20000: Module already exists`
- Solution: Drop existing module first (or rename the new one)

**Error:** `ORA-20000: Base path already registered`
- Solution: Use different base path or module name

### Handler Deployment Failed
**Error:** `ORA-06550: Procedure or function not found`
- Solution: Check SQL syntax in handler file, validate PL/SQL block

**Error:** `RESTful Services module registration failed`
- Solution: Verify module was created in Step 1

### Frontend Cannot Connect to ORDS
**Error:** `CORS error` or `Failed to fetch`
- Solution: Check ORDS CORS headers configuration (may need ORDS admin adjustment)

**Error:** `404 Not Found`
- Solution: Verify base URL in env variable matches ORDS base path

### Postman Tests Fail
**Status:** `401 Unauthorized`
- Solution: Check ORDS authentication settings

**Status:** `500 Internal Server Error`
- Solution: Check ORDS logs for PL/SQL errors

---

## Rollback (If Needed)

### Drop All Handlers
```sql
BEGIN
  FOR handler IN (
    SELECT * FROM user_ords_handlers 
    WHERE module_name='facturacion-aprobaciones-rechazos-v1'
  ) LOOP
    ords.drop_handler(handler.module_name, handler.pattern);
  END LOOP;
  COMMIT;
END;
/
```

### Drop Module
```sql
BEGIN
  ords.drop_module('facturacion-aprobaciones-rechazos-v1');
  COMMIT;
END;
/
```

---

## Documentation

- **Sprint 2 Plan:** `docs/sprint-2/plan.md`
- **Progress Tracker:** `docs/sprint-2/progress.md`
- **Orchestration Guide:** `docs/sprint-2/coordination/ORCHESTRATION.md`
- **QA Sign-off Template:** `docs/qa/sprint-2-deployment-signoff.md` (to be created after deployment)

---

## Contact

- **Questions about scripts?** Check the .sql files in this directory
- **ORDS admin issues?** Contact DevOps/Database team
- **Frontend integration issues?** Check `frontend/.env` and console logs

---

**Last Updated:** 2026-06-15  
**Status:** Ready for Execution ✅  
**Execution Time:** ~30 minutes
