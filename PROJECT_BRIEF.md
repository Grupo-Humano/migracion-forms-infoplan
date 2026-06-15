# PROJECT_BRIEF.md
**Single Source of Truth for AI Team Orchestration**

---

## 1. Project Overview

**Project Name:** migracion-forms-infoplan

**CEO:** Cesar

**Status:** Phase 0 – Initialization (Brainstorm & Sprint Planning)

**Objective:** Modernize legacy Oracle Forms applications by migrating UI logic to React and backend business logic to ORDS (Oracle REST Data Services).

---

## 2. Concept / Product Description

### Problem Statement
Legacy Oracle Forms applications contain:
- Complex UI logic spread across form screens
- Business logic embedded in forms (triggers, validations)
- Technical debt from decades of maintenance
- Poor user experience and limited scalability

### Solution
1. **Frontend Migration**: Replace Oracle Forms UI with modern React components
2. **Backend Refactoring**: Extract form logic → ORDS REST APIs (Oracle Database-backed)
3. **Database**: Keep Oracle as source of truth, wrap with ORDS
4. **User Experience**: Modern, responsive UI with React

### Key Benefits
- Modern, maintainable codebase
- REST API-first architecture
- Easier testing and deployment
- Scalable for future enhancements

---

## 3. Tech Stack

**STATUS:** FINALIZED (not temporary anymore)

| Layer | Technology | Notes | Decision Date |
|-------|-----------|-------|----------------|
| **Frontend** | React 18.3+, TypeScript strict | SPA on Vite (not CRA) | 2026-06-12 |
| **State Mgmt** | TanStack Query | Native React 18 Suspense support | 2026-06-12 |
| **Form Library** | React Hook Form | Lightweight, Playwright-friendly | 2026-06-12 |
| **CSS** | Tailwind + Headless UI | Component consistency via design system | 2026-06-12 |
| **Bundler** | Vite | Faster than CRA for large SPA | 2026-06-12 |
| **Backend API** | ORDS (Oracle REST Data Services) | MVP: pure ORDS, no Node middleware (Phase 2 if needed) | 2026-06-12 |
| **Database** | Oracle 19c+ | Source of truth, accessed via ORDS | 2026-06-12 |
| **Testing - E2E** | Playwright 1.44+ | Multi-browser, component testing | 2026-06-12 |
| **Testing - Unit** | Jest 29+ + React Testing Library | 85% code coverage target | 2026-06-12 |
| **CI/CD** | GitHub Actions | Parallel testing, artifact storage | 2026-06-12 |
| **Deployment** | Static hosting (frontend) + TBD (backend) | Vercel/Netlify for React, cloud container for ORDS | 2026-06-12 |

**Rationale:** See [Architecture Decision Records (ADRs)](./docs/architecture-decisions/) for detailed trade-offs.

---

## 4. Architecture

**ARCHITECTURE DECISION:** Pure ORDS MVP (Phase 1), Node.js middleware Phase 2 if needed.

```
PHASE 1 (MVP): React + ORDS Direct

┌─────────────────────────────────────────────────────────┐
│                    USERS (Web Browser)                   │
└────────────────────────┬────────────────────────────────┘
                         │ HTTP/REST
┌────────────────────────▼────────────────────────────────┐
│                  REACT FRONTEND (SPA)                    │
│         (Components, State Mgmt via TanStack Query)      │
│         Hosted: Vercel/Netlify (Static)                 │
│         Port: 3000                                      │
└────────────────────────┬────────────────────────────────┘
                         │ REST API calls (direct)
┌────────────────────────▼────────────────────────────────┐
│   ORDS (Oracle REST Data Services)                       │
│   • REST endpoints wrapping PL/SQL procedures           │
│   • Built-in auth (OAuth via Oracle APEX optional)      │
│   • Rate limiting, logging (ORDS native features)       │
│   • Direct Oracle DB access                             │
│   Port: 8888                                            │
└────────────────────────┬────────────────────────────────┘
                         │ Native SQL
┌────────────────────────▼────────────────────────────────┐
│           ORACLE DATABASE (Legacy Forms DB)             │
│    • Source of truth for all business data              │
│    • Existing tables, sequences, triggers               │
│    • Version: Oracle 19c+ (ORDS compatible)             │
└─────────────────────────────────────────────────────────┘
```

**PHASE 2 (Optional):** Insert Node.js middleware if orchestration needed

```
React → Node.js (auth, logging, cross-cutting) → ORDS → Oracle DB
```

**Decision Rationale:**
- ✅ Phase 1 simplicity: Fewer moving parts, easier deployment
- ✅ All business logic in PL/SQL (ORDS) = consistent enforcement
- ✅ React is "dumb" form renderer (calls ORDS endpoints)
- ⚠️ Tradeoff: ORDS handles orchestration (multi-procedure calls)
- 📋 If later need: Node slides in without React changes (abstraction layer ready)

See: [ADR-001: Backend Orchestration](./docs/adr/adr-001-backend-orchestration.md) (created in Sprint 0)

---

## 5. Key Files Map

```
migracion-forms-infoplan/
├── PROJECT_BRIEF.md              ← YOU ARE HERE (Single source of truth)
├── README.md                      (User-facing project guide)
├── frontend/                      (React SPA)
│   ├── src/
│   │   ├── pages/                (One per migrated form)
│   │   ├── components/           (Reusable UI components)
│   │   ├── services/             (API client)
│   │   └── hooks/                (Custom React hooks)
│   ├── package.json
│   └── tsconfig.json
├── backend/                       (ORDS + Node middleware)
│   ├── ords/
│   │   ├── modules/              (PL/SQL procedures as ORDS modules)
│   │   └── config/               (ORDS setup scripts)
│   ├── middleware/               (Node.js Express layer - optional)
│   │   ├── auth.js
│   │   └── logger.js
│   └── package.json
├── .github/
│   └── workflows/                (CI/CD pipelines)
│       ├── test.yml
│       ├── build.yml
│       └── deploy.yml
├── docs/
│   ├── architecture.md            (Detailed architecture)
│   ├── forms-inventory.md         (List of forms to migrate)
│   ├── sprint-0/
│   │   ├── plan.md               (Sprint 0 plan)
│   │   ├── progress.md           (Live status)
│   │   └── done.md               (Handoff doc)
│   └── qa/
│       └── sprint-N-signoff.md   (QA sign-offs)
└── .agents/
    ├── skills/
    └── AGENTS.md                 (Team definitions)
```

---

## 6. Team Roles

| Agent | Name | Role | Responsibilities |
|-------|------|------|---|
| **Producer** | **Remy** | Sprint Planning & Coordination | Scope control, task prioritization, PR merges, issue triage |
| **Product Designer** | **Kira** | UX/Feature Design | User flows, mockups, form prioritization for migration |
| **Visual/Art Director** | **Milo** | CSS & Visual Identity | Design system, component styling, accessibility |
| **Frontend Engineer** | **Nova** | React Development | React components, state management, API client |
| **Backend Engineer** | **Sage** | ORDS & Business Logic | PL/SQL procedures, ORDS modules, data migrations |
| **DevOps Engineer** | **Dash** | CI/CD & Deployment | GitHub Actions, artifact management, environment setup |
| **QA Engineer** | **Ivy** | Testing & Quality Assurance | E2E testing (Playwright), regression testing, bug filing |

---

## 7. Sprint Status

**Current Sprint:** Sprint 1 (Baseline Mock Hardening + Alignment)

**Completed:**
- ✅ Project brief created
- ✅ Team assembled (7 senior agents)
- ✅ **Brainstorm Phase 0 executed** (8 questions, 3 risks mitigated)
- ✅ Architecture decisions locked (ORDS MVP, no Node middleware)
- ✅ Tech stack finalized (Vite, TanStack Query, Tailwind, Playwright)
- ✅ Risk assessment & mitigation plan created ($45K investment)
- ✅ Sprint 1 technical baseline mock created (frontend + ORDS mock SQL)

**In Progress (Sprint 1 Week 1):**
- 🔄 Script hardening for Windows execution (Sage)
- 🔄 Analysis artifacts generation in docs/analysis-results (Sage + Remy)
- 🔄 Documentation alignment across brief/readme/decision docs (Remy)
- 🔄 Sprint tracking setup (`docs/sprint-1/plan.md`, `docs/sprint-1/progress.md`) (Remy)

**Upcoming:**
- **Sprint 1 Gate:** QA smoke + ORDS reproducible setup + Wave 1/Wave 2 scope decision
- **Sprint 2+:** Remaining forms (phased rollout)

**Timeline:** 
- **Sprint 0:** 8 weeks (validation + hiring + risk mitigation)
- **Sprint 1-8:** 18-24 months for all 200 forms (estimated post-brainstorm)

---

## 8. Current State

**As of 2026-06-15 (Remy orchestration checkpoint):**

- **Project:** Phase 0 complete with a Sprint 1 mock baseline running in frontend demo mode
- **Architecture:** DECIDED → Pure ORDS MVP (no Node.js middleware initially), React SPA on Vite
- **Tech Stack:** FINALIZED → React 18 + TypeScript strict, TanStack Query, Tailwind, Playwright, Jest
- **Team:** 11-person structure defined (design squad + dev squad + QA + DevOps + Producer)
- **Skills Gap:** ORDS expertise = HIGH PRIORITY → Hiring consultant for Week 1 Sprint 1
- **Risk Assessment:** 3 critical risks identified + mitigation plans ($45K investment, 6 weeks Sprint 0)
- **Next Actions:** 
  1. Fix extraction scripts for Windows-safe execution (Sage)
  2. Regenerate full XML analysis outputs (Sage + Remy)
  3. Run QA smoke baseline and register issues (Ivy)
  4. Publish ORDS local setup guidance for reproducible validation (Dash + Sage)
  5. Close product scope gate for rep_aprobarechazo (Remy + Kira + Sage)

**Blockers:** Script portability issues (encoding + hardcoded paths) and scope narrative mismatch (decision doc vs sprint baseline).

**Risks (Mitigated):**
1. **Undocumented Forms logic** → Archaeology sprint + legacy expert pairing (1 week)
2. **ORDS expertise gap** → Hire consultant + training ($15K, 3 weeks)
3. **Testing at scale** → Automation-heavy + 2 QA engineers ($30K, ongoing)

**Conditions for Sprint 1 Go/No-Go:**
- [ ] Program units/triggers/LOVs extraction working end-to-end on Windows
- [ ] QA smoke run completed with no blocker defects
- [ ] ORDS setup steps documented and reproducible
- [ ] Product scope decision documented (Wave 1 piloto vs Wave 2 complexity)

---

## 9. Security Rules

- **Authentication**: TBD (discuss with Sage + Dash in Sprint 0)
- **Database Access**: ORDS only via REST, no direct Oracle client connections
- **Secrets**: GitHub Secrets for DB credentials, API keys (Dash manages)
- **Input Validation**: React + ORDS validation on all form inputs
- **Compliance**: TBD (if forms handle sensitive data, discuss with Kira)

---

## 10. How to Run Locally

### Prerequisites
```bash
# Install Node.js 18+
# Install Oracle DB client (if direct SQL needed)
# Install git
```

### Setup (To be completed after Sprint 0)
```bash
# Clone three separate repos (one per team)
git clone <repo> project-dev    # Nova, Sage, Milo
git clone <repo> project-qa     # Ivy
git clone <repo> project-devops # Dash

# Frontend
cd project-dev/frontend
npm install
npm run dev          # Runs on http://localhost:3000

# Backend (ORDS + Node)
cd ../backend
npm install
npm run dev          # Node runs on http://localhost:3001
# ORDS runs separately (port 8888)

# Run tests
npm run test         # Unit tests
npm run test:e2e     # E2E tests with Playwright
```

---

## 11. How to Deploy

**TBD** — Dash will document after Sprint 0.

**Initial thoughts:**
- Frontend: Static hosting (Netlify, Vercel, or cloud CDN)
- Backend: Node.js container or serverless
- ORDS: Oracle Cloud or on-premises

---

## 12. Cross-Chat Handoff Protocol

### Context Survival Strategy

Each agent team works in a **separate VS Code window** with its own clone:
- **Dev Team** (`project-dev/`) — Nova, Sage, Milo collaborate
- **QA Team** (`project-qa/`) — Ivy works independently
- **DevOps** (`project-devops/`) — Dash (on demand)

**How Cesar (CEO) carries messages:**

1. **Before sprint**: Cesar reads `docs/sprint-N/plan.md` in each chat window
2. **During sprint**: Cesar carries progress updates via `docs/sprint-N/progress.md`
3. **At sprint end**: Cesar carries `docs/sprint-N/done.md` as handoff doc
4. **Recovery**: If chat context overflows, `project-brief.md + progress.md` = cold start

### Message Flow Example

```
Dev Chat (Nova + Sage):
  "Feature X done. PR #42 ready for merge."
  
Cesar carries to main chat:
  "Dev finished Feature X. Updating progress.md. QA, can you test?"
  
QA Chat (Ivy):
  "Testing Feature X... found bug in validation. Filing Issue #50."
  
Cesar carries back:
  "Ivy found validation bug. Sage, can you fix?"
```

---

## 13. Bug & Fix Tracking

**Single source of truth: GitHub Issues**

### Naming Convention
```bash
# File bugs with labels
- Label: bug, sprint-N, form-<name>
- Example: "Validation error on date input (form: InfoplanForms)"

# Commits reference issues
git commit -m "fix: date validation in InfoplanForms (Fixes #50)"
git commit -m "feat: add form X UI component (Closes #48)"
```

### Workflow
1. **QA files bug** → GitHub Issue (auto-labeled `sprint-N`)
2. **Dev discusses** → Comment on issue
3. **Dev fixes** → Commit mentions issue (`Fixes #NN`)
4. **Ivy verifies** → Closes issue with final test

---

## 14. Multi-Repo Setup

### Branch Strategy (GitFlow Operativo)
```
main                (production-ready only)
develop             (integration branch)
  ├── feature/<scope>-<short-name>
  ├── bugfix/<scope>-<short-name>
  ├── docs/<short-name>
  └── chore/<short-name>

release/<version>
hotfix/<version>
```

**Current activation plan (immediate):**
1. Create `develop` from current `main` baseline.
2. Move active sprint work to `feature/sprint-1-ords-real`.
3. Use small atomic PRs from feature/bugfix/docs branches into `develop`.
4. Merge `develop` -> `main` only through release or approved production hotfix.

### Merge Rules
1. **Regular delivery:** `feature/*` -> PR -> `develop`.
2. **Sprint closure:** cut `release/*` from `develop`, QA sign-off, then merge to `main` and back to `develop`.
3. **Emergency production fix:** `hotfix/*` from `main`, then merge to both `main` and `develop`.
4. Keep commits small and semantic (`feat`, `fix`, `docs`, `chore`, `refactor`, `test`).
5. Every functional commit must reference issue/work item when available (`Fixes #NN`).

### Clone Strategy
```bash
# Sprint 0: All teams clone same repo
git clone <repo> project-dev
git clone <repo> project-qa
git clone <repo> project-devops

# All fetch/pull from origin, but push to their feature branches
# Remy handles all merges to main
```

---

## References

- **Brainstorm Format**: See prompt for Phase 0
- **Sprint Plan Template**: See `docs/sprint-0/plan.md` (to be created)
- **Anti-Patterns**: Avoid batch commits, vague tasks, lost bugs in chat
- **PBI Orchestration Runbook**: See `docs/ORQUESTACION-PBI-ORDS-REACT.md`
- **GitFlow Standard**: See `docs/GITFLOW.md`

---

## 15. PBI Orchestration Model (NEW)

From 2026-06-15 onward, the default execution model for each Oracle Forms migration item is:

1. **Read PBI in Azure DevOps** (description, acceptance criteria, attachments, related links).
2. **Process functional video** (native transcript if available; otherwise frame-based extraction).
3. **Analyze Oracle Form artifact** (`.fmb/.fmx/.xml`), including blocks, items, LOVs, triggers, and program units.
4. **Assess existing ORDS coverage** and classify each operation as:
   - `REUTILIZABLE`
   - `ADAPTABLE`
   - `NUEVO`
5. **Mandatory human checkpoint after ORDS assessment** before endpoint design.
6. **Design ORDS endpoints** for `NUEVO` and `ADAPTABLE` operations.
7. **Plan sprint tasks in Azure DevOps** inferred from real form logic.
8. **Publish React/Next migration specification** mapped from Oracle blocks/triggers.

All generated artifacts and operational communication must be in Spanish.

---

## 16. Implementation Baselines (NEW)

- The orchestration prompt source has been incorporated from:
  - `prompts/awsome_prompt.md`
  - `prompts/agent_orchestration_prompt.html`
- Operationalized documentation:
  - `docs/ORQUESTACION-PBI-ORDS-REACT.md`
  - `docs/GITFLOW.md`
- Sprint execution alignment:
  - `docs/sprint-1/plan.md`
  - `docs/sprint-1/progress.md`

---

**Last Updated:** 2026-06-12 (Cesar, CEO)  
**Next Review:** After Brainstorm Phase 0
