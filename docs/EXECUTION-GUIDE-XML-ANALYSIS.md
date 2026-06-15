# Ejecución: Análisis de XMLs y Nuevo Sprint Plan

**Cesar (CEO):** Usa esta guía para coordinar con Remy, Sage, Kira e Ivy en chats separados.

---

## Arquitectura de Chats

Cada agente AI trabaja en su propio chat. **Tú eres el bus de mensajes** entre ellos:

```
Chat 1: @ai-team-producer (Remy + Sage)
    ↓ Tú llevas resultados
Chat 2: @ai-team-designer (Kira)
    ↓ Tú consolidadas
Chat 3: @ai-team-qa (Ivy)
    ↓ Tú generas
docs/sprint-1/plan.md ← Remy redacta
```

---

## FASE 1: Script Review (Chat with Remy + Sage)

**Prompt para @ai-team-producer (Remy):**

```
You are Remy (Producer) and Sage (Backend Engineer).

CONTEXT:
- Read: PROJECT_BRIEF.md (Sections 1-7)
- Read: docs/SCRIPT-REVIEW-AND-ANALYSIS.md (full document)
- Location: scripts/ has three Python extractors for Oracle Forms XML

TASK:
1. Remy: Review the three scripts for correctness and usability
2. Sage: Validate PL/SQL extraction logic (especially clean_code() function)
3. Create an execution plan:
   - Which XML files to test?
   - Command sequence for batch analysis
   - Output directory structure
4. Document in: docs/analysis-results/README.md
5. Flag any blockers or edge cases

DELIVERABLE:
- Execution checklist (commands ready to run)
- Known limitations
- Recommended forms for pilot analysis (top 3)

Take your time, do it right.
```

**After Remy responds:**
- Copy Remy's execution checklist
- Ask: "Which 3 forms should we analyze first?" → Get file names

---

## FASE 2: Run Analysis (Your Terminal)

Once Remy gives you the go-ahead:

```bash
# Create output directory
mkdir -p docs/analysis-results

# Run the extractors on rep_aprobarechazo_fmb.xml (pilot form)
# (Use exact commands from Remy's checklist)

# Check results
ls -la docs/analysis-results/
```

**Save the outputs** — you'll need them for the next chats.

---

## FASE 3: Functional Impact (Chat with Kira)

**Prompt para @ai-team-designer (Kira):**

```
You are Kira (Product Designer).

CONTEXT:
- Read: PROJECT_BRIEF.md (Section 2: Concept)
- Read: docs/SCRIPT-REVIEW-AND-ANALYSIS.md (Stage 2-3)
- Analysis Results: [paste JSON snippets from docs/analysis-results/ into chat]

TASK:
From the extracted data (LOVs, complexity, procedures), answer:
1. Which forms appear to have high UI complexity?
2. Which forms are data-intensive (need pagination/filtering)?
3. Create a prioritization matrix:
   | Form Name | LOV Count | Trigger Count | Complexity | Priority (1-5) |
   |-----------|-----------|---------------|-----------|----------------|
   | ... | ... | ... | ... | ... |

4. Top 3 forms for Sprint 1 (based on UI design feasibility)

DELIVERABLE:
- Prioritization matrix (CSV or table)
- Recommended migration order with UI rationale

Take your time. Focus on what's achievable in 4 weeks.
```

**After Kira responds:**
- Copy the prioritization matrix
- Note: "Kira recommends these 3 forms for Sprint 1"

---

## FASE 4: API Architecture (Back to Sage Notes)

Sage (from Chat 1) already validated PL/SQL. Now ask Remy:

**Follow-up prompt to @ai-team-producer:**

```
Remy, based on Kira's prioritization:

TASK:
Consolidate findings from analysis:
1. For each of Kira's top-3 forms, create an ORDS API spec:
   - Procedures to wrap
   - Database tables accessed
   - Input parameters (from LOVs, form fields)
   - Expected response schema
   
2. Flag any PL/SQL that's too complex for direct ORDS wrapping
   (might need a Node.js middleware layer in Phase 2)

3. Create a table:
   | Form | Procedures | Tables | ORDS Complexity | Effort (story points) |
   |------|-----------|--------|-----------------|----------------------|
   | ... | ... | ... | ... | ... |

DELIVERABLE:
- API spec for each top-3 form
- Effort estimation
- Risks for Sprint 1
```

---

## FASE 5: QA Strategy (Chat with Ivy)

**Prompt para @ai-team-qa (Ivy):**

```
You are Ivy (QA Engineer).

CONTEXT:
- Read: PROJECT_BRIEF.md (Section 3: Tech Stack → Playwright)
- Read: docs/SCRIPT-REVIEW-AND-ANALYSIS.md (Stage 3)
- Kira's top-3 forms for Sprint 1: [list names]

TASK:
1. For equivalence testing, design a test harness:
   - How to capture legacy form behavior (Oracle Forms on Oracle)?
   - How to replicate in Playwright (React SPA)?
   - Which test cases are high-risk? (LOV selections, validations)

2. Create a test strategy:
   - Unit tests for ORDS APIs
   - E2E tests for React components
   - Regression test baseline

3. Create: docs/qa/sprint-1-test-strategy.md

DELIVERABLE:
- Test strategy document
- Playwright test template (one form)
- Risk areas for QA focus

Take your time. Equivalence testing is hard — get it right.
```

---

## FASE 6: Create Sprint 1 Plan (Back to Remy)

**Final prompt para @ai-team-producer (Remy):**

```
You are Remy (Producer).

CONSOLIDATE all findings:
1. Kira's prioritization (top 3 forms)
2. Sage's API specs + effort estimates
3. Ivy's test strategy

CREATE: docs/sprint-1/plan.md with:

## Sprint 1 Plan (Weeks 1-4)

### Forms to Migrate (in order of priority)
1. [Form Name] — [Why: UI simplicity, dependencies, etc.]
2. [Form Name]
3. [Form Name]

### Task Breakdown
| Task | Owner | Effort | Dependencies |
|------|-------|--------|--------------|
| ORDS API for Form 1 | Sage | 8 pts | Schema ready |
| React Component Form 1 | Nova | 13 pts | API done |
| E2E Tests Form 1 | Ivy | 5 pts | Component done |
| ... | ... | ... | ... |

### Success Criteria
- All 3 forms migrated to React
- 100% test coverage (Playwright E2E + unit)
- Equivalence to legacy form verified
- Zero prod incidents (first 2 weeks post-deploy)

### Risks & Mitigations
| Risk | Mitigation |
|------|-----------|
| ORDS PL/SQL too complex | Spike on procedure wrapping |
| React form UX mismatch | Daily design review with Kira |
| ... | ... |

DELIVERABLE:
- docs/sprint-1/plan.md (ready for Sprint 1 kickoff)
```

---

## FASE 7: Execute Sprint 1 (After Plan Approved)

Once Remy creates `docs/sprint-1/plan.md`:

1. **Start Dev Chat:** 
   ```
   Read docs/sprint-1/plan.md
   You are Nova (Frontend) + Sage (Backend) + Milo (Design)
   Execute Sprint 1. Start with the first form.
   ```

2. **QA Runs in Parallel:**
   ```
   Read docs/sprint-1/plan.md
   You are Ivy (QA)
   Prepare equivalence test harness while Dev builds.
   ```

3. **Remy Merges PRs:** After dev finishes, Remy reviews + merges to main

---

## Timeline

| Phase | Time | Owner | Output |
|-------|------|-------|--------|
| 1. Script Review | 1 hr | Remy + Sage | Execution checklist |
| 2. Run Analysis | 30 min | Cesar (terminal) | JSON results |
| 3. Functional Impact | 1.5 hrs | Kira | Prioritization matrix |
| 4. API Architecture | 1.5 hrs | Remy + Sage | API specs + effort |
| 5. QA Strategy | 1 hr | Ivy | Test strategy doc |
| 6. Sprint 1 Plan | 1 hr | Remy | docs/sprint-1/plan.md |
| **TOTAL** | **~7 hours** | Team | **Ready for Sprint 1** |

---

## Checklist: Before Starting Sprint 1

- [ ] docs/SCRIPT-REVIEW-AND-ANALYSIS.md reviewed by Remy
- [ ] Execution commands tested (run on pilot form)
- [ ] docs/analysis-results/ populated with JSON
- [ ] Kira's prioritization matrix created
- [ ] Sage's API specs documented
- [ ] Ivy's test strategy drafted
- [ ] docs/sprint-1/plan.md created and approved
- [ ] All team members (Nova, Sage, Milo, Ivy) read the plan
- [ ] GitHub Issues filed for each task in plan

---

## If Stuck

**Question for Remy:** "Are there XML edge cases the scripts don't handle?"  
→ Sage reviews and flags → Remy updates docs

**Question for Kira:** "Is Form X really Sprint 1 material?"  
→ Kira reviews complexity → Remy adjusts plan

**Question for Ivy:** "Can we test Forms equivalence with Playwright alone?"  
→ Ivy designs harness → May need oracle-js-driver research

---

## References

- [AI Team Orchestration Skill](/.agents/skills/ai-team-orchestration/SKILL.md)
- [docs/SCRIPT-REVIEW-AND-ANALYSIS.md](./SCRIPT-REVIEW-AND-ANALYSIS.md)
- [PROJECT_BRIEF.md](./PROJECT_BRIEF.md)

---

**Owner:** Cesar (CEO)  
**Next Step:** Start Chat 1 with Remy + Sage  
**Date Created:** 2026-06-15
