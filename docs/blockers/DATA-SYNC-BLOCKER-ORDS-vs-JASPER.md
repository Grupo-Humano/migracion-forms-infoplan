# Data Sync Blocker: ORDS Mock vs Jasper Database Mismatch

**Status:** 🚨 BLOCKED (Sprint 1 Closure)  
**Date Found:** 2026-06-15  
**Owner:** Sage (Backend) + Dash (DevOps)  
**Priority:** HIGH (blocks export testing)

---

## Problem Statement

**Symptom:** 
- React search (ORDS) returns 2 mock records for date range 2026-06-01 to 2026-06-15
- Jasper export (same date range) returns **empty Excel** (~4KB template, no data)
- Jasper export with broader range (2026-01-01 to 2026-06-15) returns **1.8 MB Excel with data**

**Root Cause:**
- ORDS mock schema (`01_mock_schema.sql`) only contains **2 hardcoded records** (IDs 900001, 900002)
- Jasper production database contains **~166+ records** distributed across JAN-JUN 2026
- Data ranges don't overlap in a meaningful way:
  - ORDS: 2 records with synthetic dates (SYSDATE-2, SYSDATE-1)
  - Jasper: Full month range, hundreds of records

**Impact:**
- Cannot test Jasper export functionality with typical data volume
- Users see empty exports when filtering narrow date ranges
- Demonstrates data sync is not production-ready

---

## Technical Analysis

### What's in Each System

| Aspect | ORDS Mock | Jasper Real |
|--------|-----------|-------------|
| Record Count | 2 | ~166+ |
| Date Range | 2026-06-13 to 2026-06-14 (synthetic) | 2026-01-01 to 2026-06-15 |
| IDs | 900001, 900002 | 900001 to ~900166 |
| Status Variety | 2 (APR, RECH) | 5+ (APR, RECH, PEN, etc.) |
| File Size | N/A | 1.8 MB |

### Why It Fails

When user searches in React with range `2026-06-01` to `2026-06-15`:
1. ORDS returns: 2 records (900001, 900002) ✅
2. React displays: 2 records in UI ✅
3. User clicks "Exportar Jasper" ✅
4. Jasper server receives: `PDESDE=01-JUN-2026&PHAS=15-JUN-2026` ✅
5. Jasper queries its DB: **No records match this date range** ❌
6. Jasper returns: Empty Excel template (4608 bytes) ❌

**Proof:** When user uses broader range `2026-01-01` to `2026-06-15`:
- Jasper finds matching records ✅
- Excel is 1.8 MB with data ✅

---

## Solutions (Pick One)

### Option A: Expand ORDS Mock Data (RECOMMENDED - 1 hour)

Generate ~166 mock records in ORDS for range 2026-01-01 to 2026-06-15.

**Script Ready:** `backend/ords/sql/01b_expand_mock_data.sql`

```sql
-- Generates records for each day JAN-JUN 2026
-- Rotates through different statuses, officials, gerentes, intermediarios
-- Creates realistic data volume (~1.8 MB equivalent)
```

**Pros:**
- ✅ Quick to implement
- ✅ Matches Jasper data distribution
- ✅ Enables full feature testing
- ✅ Doesn't change production Jasper

**Cons:**
- ❌ Still mock data (not production)
- ❌ Doesn't solve production data sync

**Steps:**
```bash
cd backend/ords
sqlplus ... @sql/01b_expand_mock_data.sql
# Verify: SELECT COUNT(*) FROM mock_transacciones;  
# Expected: ~166 records
```

### Option B: Sync Jasper to ORDS Range (2-4 hours)

Modify Jasper report definition or create a Jasper mock to return data for 2026-06-01 to 2026-06-15.

**Pros:**
- ✅ Tests exact feature scenario
- ✅ Documents Jasper behavior

**Cons:**
- ❌ Requires Jasper admin access
- ❌ Changes production environment
- ❌ Needs DBAs

### Option C: Accept Blocker (Ongoing)

Document that Jasper export requires broader date ranges until production data is available.

**Pros:**
- ✅ No dev effort

**Cons:**
- ❌ Blocks feature acceptance
- ❌ Poor user experience in demo

---

## Recommendation

**Use Option A (Expand ORDS Mock)** for Sprint 1 closure:

1. Execute `01b_expand_mock_data.sql` in dev/test ORDS
2. Re-test Jasper export with full pipeline
3. Verify Excel contains expected volume
4. Document in git (commit message with this blocker reference)
5. Add to Sprint 1 "done.md" as resolved blocker

**For Production Planning:**
- Assign `data-sync-production` issue to DevOps
- Coordinate with Jasper/DB admins to align real data ranges
- Target: Sprint 2 or 3

---

## Escalation Path

| Level | Action | Owner |
|-------|--------|-------|
| **Dev Team (now)** | Run 01b_expand_mock_data.sql | Sage |
| **Remy (Producer)** | Close blocker after test | Remy |
| **CEO** | Approve data expansion | Cesar |
| **Production** | Sync real Jasper DB | Dash + DBA |

---

## Related Issues

- GitHub: (create issue with tag `data-sync-blocker` if not exists)
- Docs: See `PROJECT_BRIEF.md` section 9.2 "External Dependencies & Data Sync Rules"
- Checklist: `docs/governance/JASPER-EXTRACTION-CHECKLIST.md` → rep_aprobaciones_rechazos → "Data Sync Validation"

---

## Testing After Resolution

```bash
# Test 1: Narrow range (should now have data)
Fecha: 2026-06-01 a 2026-06-15
Expected: Multiple records in ORDS, Jasper Excel with data

# Test 2: Broad range (already works)
Fecha: 2026-01-01 a 2026-06-15
Expected: Large Excel export

# Test 3: With filters
Fecha: 2026-02-01 a 2026-02-15, Gerente: "Laura Medina"
Expected: Filtered records in both ORDS and Jasper
```

---

## Sign-Off Checklist

- [ ] 01b_expand_mock_data.sql executed successfully
- [ ] SELECT COUNT(*) returns ~166 records
- [ ] React search with 2026-06-01 to 2026-06-15 shows multiple records
- [ ] Jasper export with same range returns non-empty Excel
- [ ] Blocker documented in commit message
- [ ] Remy approves closure
- [ ] Added to Sprint 1 done.md

