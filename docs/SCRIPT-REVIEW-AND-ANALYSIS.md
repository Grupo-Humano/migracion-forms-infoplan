# Oracle Forms XML Analysis — Script Review & Coordination Document

**Date:** 2026-06-15  
**Status:** Ready for Team Review  
**Owner:** Remy (Producer) + Sage (Backend Engineer)

---

## Executive Summary

Cesar has placed **three Python extraction scripts** in `/scripts/` to analyze Oracle Forms XML files and extract key artifacts:

1. **`extract_program_units.py`** — Extract PL/SQL program units (procedures/functions)
2. **`extract_block_triggers.py`** — Extract form block triggers
3. **`extract_lovs_records.py`** — Extract List of Values (LOVs) and Record Groups

**Next Step:** Review these scripts, execute them against the legacy forms XML, and generate a prioritized sprint plan for form migration.

---

## Stage 1: Script Technical Review

### Remy (Producer) — Script Correctness & Execution Plan

**Tasks:**
1. **Review** each script for:
   - Command-line interface clarity (arguments, options)
   - Error handling robustness
   - Output format (JSON vs CSV vs text)
   - Dependencies (stdlib only vs external libraries?)

2. **Execution Plan:**
   - Which forms XML files to analyze first? (Start with 3-5 pilot forms)
   - Do we have the XML files in the repo? (Check `/forms/` directory)
   - Create a shell script to batch-run all three extractors
   - Output directory: `docs/analysis-results/`

3. **Document:**
   - Script README with usage examples
   - Known limitations or edge cases
   - Batch execution checklist

---

### Sage (Backend Engineer) — PL/SQL Extraction Validation

**Tasks:**
1. **Validate extraction logic:**
   - Does `clean_code()` in `extract_program_units.py` correctly decode HTML entities? (&#10; = newline)
   - Are triggers captured with full scope (block, item, form level)?
   - LOV extraction: Are query data sources properly identified?

2. **Flag migration complexity:**
   - Which PL/SQL constructs indicate high effort? (e.g., `CALL_FORM`, `GO_BLOCK`, package references)
   - Are there circular dependencies between procedures?
   - Which LOVs require custom ORDS modules vs. simple SQL?

3. **Output format review:**
   - Do JSON outputs match what ORDS will need for API design?
   - Any XML edge cases (nested namespaces, special characters)?

4. **Document:**
   - PL/SQL complexity scoring rubric (1-5 for each procedure)
   - ORDS wrapping strategy recommendations
   - Database dependencies matrix

---

## Stage 2: Form Analysis Execution

### Input Data
- **Forms Location:** `forms/rep_aprobarechazo_fmb.xml` (pilot form)
- **Output Directory:** `docs/analysis-results/` (create if not exists)

### Execution Commands (to be confirmed)

```bash
# Test on single form
python scripts/extract_program_units.py forms/rep_aprobarechazo_fmb.xml --json > docs/analysis-results/rep_aprobarechazo_program_units.json

python scripts/extract_block_triggers.py forms/rep_aprobarechazo_fmb.xml <BLOCK_NAME> > docs/analysis-results/rep_aprobarechazo_triggers.json

python scripts/extract_lovs_records.py forms/rep_aprobarechazo_fmb.xml --json > docs/analysis-results/rep_aprobarechazo_lovs.json
```

### Expected Outputs
1. **program_units.json** — List of all PL/SQL procedures with:
   - Name, signature, complexity score
   - Dependencies (tables, other procedures)
   - Estimated ORDS effort

2. **triggers.json** — All triggers organized by:
   - Block name, trigger type (WHEN-NEW-RECORD, etc.)
   - Action code (simplified)
   - Migration strategy

3. **lovs.json** — List of Values with:
   - LOV name, query source
   - Column mappings
   - Usage count (which items reference this LOV?)

---

## Stage 3: Functional Impact Assessment

### Kira (Product Designer) — UI Complexity Mapping

Based on analysis results:
1. Which forms have **high UI complexity?** (many LOVs, conditional displays)
2. Which forms are **data-intensive?** (large result sets, pagination needs)
3. Priority ranking for Sprint 1 (top 3-5 forms to migrate first)

### Sage (Backend Engineer) — API Design Implications

Based on analysis results:
1. How many distinct ORDS modules do we need? (group by database table/procedure)
2. Which procedures need multi-step wrapping? (transactions, error handling)
3. Database access patterns for React TanStack Query caching strategy

---

## Stage 4: Risk Assessment & Mitigation

### Remy (Producer) — Risk Matrix

Create a table for each form candidate:

| Form | Complexity | LOV Count | Procedure Count | Data Size | Risk Level | Mitigation |
|------|-----------|-----------|-----------------|-----------|------------|------------|
| rep_aprobarechazo | ? | ? | ? | ? | ? | ? |
| ... | ... | ... | ... | ... | ... | ... |

---

## Stage 5: Sprint 1 Planning Output

### Output Deliverable: `docs/sprint-1/plan.md`

After all analysis, create a new sprint plan with:
1. **Form Priority List** (top 3 forms for Sprint 1)
2. **Task Breakdown:**
   - ORDS API wrapper for procedures
   - React component design
   - Test strategy (equivalence testing)
   - Expected effort (story points)
3. **Success Criteria** (what "done" means)
4. **Risks & Mitigations**
5. **Team Assignments** (who owns which form)

---

## Communication Flow

```
Cesar (CEO) reads this doc → Shares key questions with:
├── Remy: "Are scripts ready? What's the execution plan?"
├── Sage: "Review PL/SQL extraction logic. Flag complexity indicators."
├── Kira: "After analysis, help prioritize forms by UI complexity."
└── Ivy: "Draft QA test strategy for equivalence testing."

Results flow back:
├── Remy consolidates findings → docs/sprint-1/plan.md
├── Sage provides ORDS architecture recommendations
├── Kira provides UI prioritization matrix
└── Ivy provides test baseline
```

---

## Checklist for Remy + Team

- [ ] **Remy:** Script review complete, execution plan documented
- [ ] **Sage:** PL/SQL validation complete, complexity rubric created
- [ ] **Remy:** Batch execution of extractors on pilot forms complete
- [ ] **Kira:** Forms prioritization matrix created
- [ ] **Sage:** ORDS API design strategy documented
- [ ] **Ivy:** QA equivalence testing strategy drafted
- [ ] **Remy:** Sprint 1 plan created (`docs/sprint-1/plan.md`)
- [ ] **Remy:** Risk matrix populated and mitigations documented

---

## Next Steps (After This Analysis)

1. **Sprint 1 Execution:** Dev team (@ai-team-dev with Nova + Sage + Milo) builds first migrated form
2. **QA Sign-Off:** Ivy (@ai-team-qa) tests equivalence to legacy form
3. **Iterate:** Lessons learned feed into Sprint 2-8

---

## Reference Links

- [AI Team Orchestration Skill](/.agents/skills/ai-team-orchestration/SKILL.md)
- [PROJECT_BRIEF.md](./PROJECT_BRIEF.md) — Architecture & team roles
- [Brainstorm Phase 0](./brainstorm-phase-0.md) — Risk assessment & tech stack decisions
- [Forms Inventory](./forms-inventory.md) — List of all forms to migrate (TBD)

---

**Owner:** Remy  
**Last Updated:** 2026-06-15  
**Status:** Awaiting team review and execution
