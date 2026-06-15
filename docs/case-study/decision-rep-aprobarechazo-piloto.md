# DECISION DOCUMENT: rep_aprobarechazo Case Study
**Migration Risk Validation - Sprint 0 Deep-Dive Complete**

**Date:** 2026-06-12  
**Prepared for:** Cesar (CEO)  
**Decision Required:** Form prioritization for Wave 1 piloto vs Wave 2

---

## EXECUTIVE SUMMARY (1 page)

We analyzed `rep_aprobarechazo_fmb` (Approval/Rejection Report) as a **CASE STUDY** to validate Risk #1: "Undocumented Forms logic." 

**Finding:** Risk #1 is **REAL and CRITICAL**. The form's XML contains **3 truncated stored procedures** that implement core logic—we can't see the code. This is **textbook legacy complexity**.

**Effort Estimate (if built today):**
- Backend (Sage): 8-10 days (including archaeology sprint)
- Frontend (Nova): 8-10 days
- QA (Ivy): 10-12 days
- UX (Kira): 7-9 days
- Design (Milo): 11-14 days
- Total: **51-65 person-days (~3 sprints for full team)**

**Recommendation: 🔴 DO NOT USE AS PILOTO**

This form is too complex and risky for the team's first migration. **Start with a simpler 5-field form first** (Wave 1 piloto), then tackle this (Wave 2) after team has 1-2 successes.

---

## DETAILED FINDINGS BY ROLE

### 🔴 NOVA (Frontend) — MEDIUM Complexity

**What we see:**
- 2 date filters + 3 select filters + 1 search button
- 2 export buttons (conflicting UX)
- 22-column results table (18 hidden, scrollable)
- Checkbox column for row selection
- Double-click row → opens detail form

**Effort:** 8-10 days (straightforward React if backend is clear)

**Risks:**
- 22-column table doesn't scale mobile (but Forms is desktop-only, so acceptable)
- OLE export can't be replicated in React directly (must route through ORDS)
- LOV LOV behavior unclear (modal vs dropdown?)

**Unknowns:** Export button priorities (when use OLE vs Jasper?), mobile support req'd?

---

### 🔴 SAGE (Backend) — HIGH Complexity

**What we see:**
- 3 LOV queries (OFICIALES, GERENTE, INTERMEDIARIO) — **documented** ✅
- BUSCA_TRANSACCIONES procedure — **truncated in XML** ❌
- GENERA_REPORTE procedure — **truncated in XML** ❌
- P_JASPER_A_EXCEL procedure — **visible** ✅

**Critical problems:**
1. **Main transaction table unknown** — BUSCA_TRANSACCIONES procedure doesn't name the source table
2. **Dynamic SQL construction** — Risk of SQL injection if not validated properly
3. **OLE automation undocumented** — GENERA_REPORTE calls OLE2 but logic not visible
4. **N+1 query on tarjeta lookup** — POST-QUERY trigger fetches tarjeta per row (performance risk)

**Effort:** 8-10 days (includes 2-3 days archaeology sprint to recover truncated code)

**Required archaeology sprint (1 week before coding):**
- [ ] Recover BUSCA_TRANSACCIONES full source
- [ ] Recover GENERA_REPORTE full source
- [ ] Identify main transaction table
- [ ] Confirm business rules on filter combinations
- [ ] Get export file specification (Excel column order, formatting)

**Unknowns:** What table stores transactions? What's the OLE export format spec? Is Jasper being retired?

---

### 👤 KIRA (UX Designer) — MEDIUM Complexity

**Issues found:**
- **2 export buttons confuse users** — "Exportar Excel" (OLE) vs "Exportar Excel Jasper" (REST)
  - When to use each? Form doesn't explain
  - Users will pick wrong one repeatedly
  - Recommendation: Consolidate to 1 button, backend routes to best option

- **Mark/Unmark buttons unclear** — Purpose not documented
  - Can we remove in React? Or is it core feature?
  - If core, add help text explaining what "select" does

- **No progress indicator on search** — Cursor shows "busy" but no ETA or cancel button
  - React should show progress bar with cancel option

- **Filter persistence missing** — Forms doesn't save filter state
  - React can persist to localStorage (big UX win)

- **22-column table doesn't fold** — No column visibility toggle
  - Desktop OK, mobile unusable (acceptable if desktop-only documented)

**Opportunities for improvement:**
- Real-time filter validation (show errors as user types, not at submit)
- Date picker instead of dd/mm/yyyy text input
- Responsive table or mobile card view (if mobile required)

**Effort:** 7-9 days (includes user research, wireframes, mockups)

**Unknowns:** Mobile support required? Which export button to keep? Can we remove mark/unmark?

---

### 🎭 MILO (Art Director / Design System) — HIGH Complexity

**Component inventory identified:**
- DateRangeFilter (reusable) ✅
- SelectWithLOV (reusable) ✅
- DataTable with virtualization (reusable) ✅
- ExportActions (report-specific) ⚠️
- ConfirmDialog (reusable) ✅

**Design system work needed (Phase 1):**
- Color palette (Form uses grays + blues + red—formalize hex, ensure WCAG AA contrast)
- Typography scale (headings, body, labels)
- Spacing system (margin/padding tokens)
- Button, input, table component specs
- Accessibility audit (Form is notoriously non-accessible; React should fix)

**WCAG 2.1 AA fixes required:**
- ARIA labels on all form inputs
- Keyboard navigation (Tab/Enter/Escape)
- Color + icon for status (not color-alone)
- 4.5:1 text contrast minimum, 3:1 for UI components
- Focus visible (outline or ring)

**Effort:** 11-14 days (includes component library, accessibility audit)

**Tech stack recommendation:**
- Tailwind CSS + shadcn/ui (pre-built, accessibility-first, customizable)
- Avoids: Styled Components (runtime overhead), CSS Modules (consistency risk)

**Unknowns:** Tailwind/shadcn approved? Mobile responsive required? Dark mode needed? WCAG AA or AAA target?

---

### 🧪 IVY (QA / Testing) — HIGH Complexity

**Test scenarios identified:**

| Category | Scenarios | Risk |
|----------|-----------|------|
| Filter validation | Date range checks, mandatory criteria | Low |
| LOV behavior | Modal pop-up, selection flow | Low |
| Search results | 0 results, 10K results, N+1 perf | HIGH |
| Export (OLE) | Selection required, file format validation | HIGH |
| Export (Jasper) | No selection required, file format validation | HIGH |
| Performance | Search latency, export time, virtualization | HIGH |

**Equivalence testing framework (React = Forms):**
- Same search filters → same result set
- Same column values (exact match)
- Same sort order (fec_tra ASC, id_transaccion ASC)
- Same export format (column order, headers, formulas)

**Regression test suite (minimal for 90% coverage):**
- 10 core Playwright tests (~10-15 min if fully automated, ~95 min if manual)
- Test data: 50 synthetic transactions (or anonymized production)

**Effort:** 10-12 days (test plan + automation)

**Risk:** Export file format unknown → can't validate equivalence until spec provided

**Unknowns:** Performance SLAs? Regression coverage target (90% or 100%)? Can we modify export format or must match exactly? Known bugs in Forms to avoid?

---

### 🚀 DASH (DevOps) — MEDIUM Complexity

**Infrastructure review needed:**
- [ ] ORDS deployment model (same box as DB? HA/failover? Load balancer?)
- [ ] Jasper server: Current SLA? Retire or keep?
- [ ] Database: Query plan for BUSCA_TRANSACCIONES? Indexes? Locking?
- [ ] React bundle size: Will 22-column table bloat package?

**Deployment strategy (3-month parallel run):**
- Month 1: React form in staging (internal testing)
- Month 2: Shadow mode in prod (no user traffic)
- Month 3: Canary rollout (5% → 25% → 100%)
- Rollback plan: < 15 min if error rate > 5% or latency > 2x baseline

**Monitoring & alerts:**
- ORDS search latency (p50, p95, p99)
- ORDS error rate (500s, timeouts)
- Jasper export latency
- React frontend errors (via Sentry)
- React bundle size per build

**Effort:** 5-7 days (infrastructure review, pipeline setup, monitoring)

**Unknowns:** Current ORDS setup? Performance SLAs? Max export file size? Rollback SLA (15 min or < 5 min)?

---

### 🎯 REMY (Producer) — GO/NO-GO Decision

**Complexity assessment:** MEDIUM-HIGH

**Why NOT piloto:**
1. ❌ Truncated procedures (can't see code—archaeology req'd)
2. ❌ External dependencies (ORDS, Jasper—new to team)
3. ❌ OLE export fragile (Windows-only, hard to debug)
4. ❌ Too many unknowns (export format, business rules, table names)
5. ❌ High risk of first-form failures (demoralizes team)

**Why use simpler piloto instead:**
- < 5 fields, no LOVs (or 1 LOV max)
- Well-documented backend (no truncated procedures)
- Single export path (CSV or no export)
- < 15 columns, simple joins
- Proven first, then tackle complex forms

**Estimated effort (if piloto fails and rework needed):** +3-4 weeks delay, +$100K budget overrun

**Estimated effort (if piloto succeeds):** Template reuse → this form drops to 8-10 days (not 15)

**Recommendation:** ✅ **GO for Sprint 1 (with conditions)**

**Conditions:**
1. [ ] Forms inventory finalized
2. [ ] Archaeology sprint complete (1 week: recover procedures, identify tables, doc rules)
3. [ ] ORDS consultant onboarded
4. [ ] 2 QA engineers hired
5. [ ] Simpler piloto form selected (NOT this one)
6. [ ] Tech stack POC working (React + ORDS + Playwright)
7. [ ] Deployment to staging working

---

## SUMMARY TABLE: Full Team Effort

| Role | Days | Critical Path | Dependencies |
|------|------|---------------|--------------|
| Sage (Backend) | 8-10 | 🔴 Yes | Archaeology 1st |
| Nova (Frontend) | 8-10 | 🔴 Yes | ORDS endpoints ready |
| Ivy (QA) | 10-12 | 🟡 Medium | Equivalence framework, test data |
| Kira (UX) | 7-9 | 🟡 Medium | Stakeholder interviews (parallel) |
| Milo (Design) | 11-14 | 🟡 Medium | Design system Phase 1 (parallel) |
| Remy (Producer) | 2-3 | 🟢 Low | Oversight only |
| Dash (DevOps) | 5-7 | 🟡 Medium | ORDS deployment path |
| **TOTAL** | **51-65** | | **~3 sprints (15 calendar days with full team)** |

---

## KEY BLOCKERS TO RESOLVE (Archaeology Sprint)

Before ANY migration work starts, complete:

**Week 1 Sprint 0 (5 days):**

| Day | Task | Responsible | Output |
|-----|------|-------------|--------|
| 1-2 | Recover BUSCA_TRANSACCIONES full source code | Sage + Oracle DBA | Procedure listing |
| 2-3 | Recover GENERA_REPORTE full source code | Sage + Oracle DBA | Procedure listing |
| 3-4 | Reverse-engineer transaction table schema | Sage | Table name, primary key, indexes |
| 4-5 | Document undocumented business rules | Sage + Product Owner | Business rules doc |
| 5 | Create "Oracle Forms Inventory" (all 50+ forms) | Kira + Sage | Forms spreadsheet (count, complexity, deps) |

**Outputs needed for ORDS design:**
- [x] Transaction table name & schema
- [x] All stored procedure logic (no truncations)
- [x] Business rules (filter combinations, validations)
- [x] Export file specification (Excel columns, formatting)
- [x] Performance baseline (Forms search + export timing)

---

## FINAL DECISION FOR CESAR

### Question: Should we use `rep_aprobarechazo_fmb` as Wave 1 piloto?

### Answer: 🔴 **NO**

### Why:
- Too complex (3 external integrations: ORDS, Jasper, OLE)
- Too risky (undocumented procedures, dynamic SQL)
- Too many unknowns (truncated XML, missing table names)
- Will demoralize team if first form fails

### What to do instead:

1. **Week 1-5 Sprint 0:** Archaeology sprint + simpler piloto selection
2. **Week 6-8 Sprint 0:** ORDS MVP, equivalence testing framework POC
3. **Week 9-16 Sprint 1:** Migrate simpler piloto form (2-3 weeks)
4. **Week 17+:** Scale to Wave 2 forms (including this one)

### Timeline impact:
- **Option A (start with this form):** +3-4 weeks delay if problems discovered → rescue mission mode
- **Option B (start with simpler form):** +0 delay, predictable, team learns, then scale

### Budget impact:
- **Option A (if things go wrong):** +$100K overrun (archaeology + rework)
- **Option B (planned approach):** $45K Sprint 0 (as approved in Phase 0)

---

## RECOMMENDATION

### 🟢 **GO to Sprint 1 with conditions:**

**Approve:**
- ✅ $45K investment (already approved)
- ✅ Archaeology sprint (1 week, Sage + Oracle DBA)
- ✅ Hire 1 ORDS consultant + 2 QA engineers (already approved)

**Defer:**
- ⏭️ `rep_aprobarechazo_fmb` → **Wave 2** (not Wave 1)
- ⏭️ Select simpler piloto form → **Wave 1**

**Next step:** Cesar approves, then:
1. Identify 3 candidate piloto forms (Kira + Sage, 1 day)
2. Rank by complexity (low-to-high)
3. Select Wave 1 piloto (1 day)
4. Kick off Archaeology Sprint 0 (Mon, Week 1)

---

## APPENDIX: Full Case Study Analysis

See: [case-study-rep-aprobarechazo.md](case-study-rep-aprobarechazo.md) for complete agent-by-agent breakdown.

---

**Prepared by:** Multi-agent team (Nova, Sage, Kira, Milo, Ivy, Remy, Dash)  
**Status:** DECISION READY — Awaiting Cesar approval  
**Next Review:** Post-archaeology sprint (2 weeks)
