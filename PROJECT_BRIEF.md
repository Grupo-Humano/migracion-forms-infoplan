# PROJECT_BRIEF.md
**Single Source of Truth for AI Team Orchestration**

---

## 1. Project Overview

**Project Name:** migracion-forms-infoplan

**CEO:** Cesar

**Status:** Sprint 2 - Execution & QA Closure

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
| **Testing - Unit** | Jest 29+ + React Testing Library | 90% code coverage target (ELEVATED from 85%) | 2026-06-15 |
| **Code Quality** | SonarQube Cloud | Static analysis, security hotspots, maintainability | 2026-06-15 |
| **Linting** | ESLint + TypeScript strict | 0 errors policy (warnings OK with justification) | 2026-06-15 |
| **CI/CD** | GitHub Actions | Parallel testing, coverage, SonarQube scan | 2026-06-12 |
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

**Current Sprint:** Sprint 3 (Certificacion ORDS vs Jasper)

**✅ COMPLETED SPRINTS:**

**Sprint 0 (Reinicio Estrategico):**
- ✅ Team and orchestration structure defined
- ✅ Architecture and stack decisions documented
- ✅ ORDS/Frontend baseline artifacts generated
- ✅ Process docs for orchestration and GitFlow created

**Sprint 1 (rep_aprobarechazo Real Data Integration):**
- ✅ SQL real queries created: transacciones/search, oficiales/{codigo}, gerentes, intermediarios
- ✅ React frontend updated with 19 columns (real schema with 5 new nullable fields)
- ✅ LOV dropdowns populated from ORDS endpoints (58 gerentes, 500+ intermediarios)
- ✅ Form validation working, date range filters functional
- ✅ QA sign-off: 8/8 critical cases PASS, 0 Sev 1-2 defects, GO recommendation
- ✅ Git: feature/sprint-1-rep-aprobarechazo branch pushed, ready for PR merge to develop
- ✅ Frontend: Dev server running on localhost:3000, all components rendering correctly

**Recently Completed (Sprint 2):**
- ✅ ORDS module and critical handlers published (`gerentes`, `intermediarios`, `transacciones/search`)
- ✅ Frontend connected to ORDS real with OAuth client credentials + Bearer
- ✅ UI smoke for core flow passing
- ✅ Reuse-first enrichment aplicado sin duplicar servicios (`gestion-poliza`, `clientes-polizas`)
- ✅ Campos antes vacios enriquecidos en UI (`estatus_poliza`, `frecuencia_pago`, `oficial`, `gerente`, `intermediario`)
- ✅ Sprint 2 cerrado en `docs/sprint-2/done.md` con GO condicional

**In Progress (Sprint 3 - ACTIVE):**
- 🔄 Certificacion campo-a-campo de data ORDS vs Jasper por `id_transaccion`
- 🔄 Alineacion de filtro Jasper para resolver diferencia de conteo
- 🔄 Consolidacion de evidencia para QA sign-off final de equivalencia

**Next Milestones:**
- Sprint 3: equivalencia ORDS/Jasper + acta QA final (`docs/qa/sprint-3-signoff.md`)
- Sprint 4: continuidad funcional post-certificacion

**Timeline:**
- Sprint 1: Completed ✅
- Sprint 2: Completed ✅
- Sprint 3 (current): certificacion de datos y cierre funcional final

---

## 8. Current State

**As of 2026-06-16 (Sprint 3 en ejecucion):**

- **Project Mode:** Certificacion final de datos ORDS vs Jasper (Dia 1 en curso).
- **Runtime Target:** Mantener integracion ORDS estable mientras se valida equivalencia.
- **Delivery Target:** Cerrar diferencias de conteo y valor campo-a-campo.
- **QA Ready:** Flujo principal estable; pendiente acta final de equivalencia.

**Sprint 1 Deliverables (Validated):**
- 500+ transaction records accessible via real ORDS queries (2026-01 through 2026-04 date range)
- React frontend with 19-column results table, all LOV dropdowns working
- 8/8 critical QA test cases passing (EQ-01 through EQ-07, EQ-10)
- 2 non-blocking pending tests (EQ-08 performance, EQ-09 keyboard navigation)
- 0 Sev 1-2 defects identified
- Git branch feature/sprint-1-rep-aprobarechazo pushed and ready for PR

**Sprint 3 Active Next Actions:**
1. T-01 en ejecucion: baseline Jasper normalizado (`report6.xls` -> CSV comparable).
2. T-05 en ejecucion paralelo: lazy enrichment frontend para eliminar all-at-once.
3. T-02 pendiente de desbloqueo: replicar filtro Jasper exacto para alinear conteo final.
4. Publicar evidencia de diferencias y correcciones en `docs/sprint-3/progress.md`.
5. Completar checklist de equivalencia en `docs/sprint-2/checklist-equivalencia-ords-jasper.md`.
6. Emitir sign-off QA final en `docs/qa/sprint-3-signoff.md`.

**Intake Structure Policy (mandatory):**
- Each PBI uses a mother folder: `docs/intake/pantallas/PBI-<id_pbi>/`
- Inputs only in: `entradas/<nombre_pantalla>/`
- Team outputs only in: `salidas/<nombre_pantalla>/`
- Execution tracking in: `orquestacion/` (`plan.md`, `progress.md`, `done.md`)
- No PBI operational artifacts outside its mother folder.

**Current Blockers (Sprint 3):**
- Filtro Jasper exacto no documentado — Sage necesita `.jrxml` o SQL Jasper para replicar regla de negocio (diferencia 3913 vs 39284).
- GitHub CLI no instalado en workstation — Dash pendiente de instalacion para PR automation.

---

## 8.1. Lecciones Aprendidas — Retrospectiva Sprint 2 (2026-06-15)

### Lo que funcionó

| Practica | Impacto |
|---|---|
| Reuse-first: 3 endpoints existentes usados para enriquecer UI | Cero servicios duplicados en el sprint |
| Exploracion via `metadata-catalog` / `open-api-catalog` antes de implementar | Evito horas de prueba-error con rutas ORDS |
| Token refresh lock (`tokenRefreshPromise`) | Elimino la causa raiz del cuelgue de busqueda |
| XLS Jasper versionado en `data/jasper-reference/` | Trazabilidad auditable para Sprint 3 |
| Commit atomico al final del sprint con secciones por area | Historia limpia, PR aislado, 36 archivos organizados |

### Lo que necesita mejorar

| Problema | Causa raiz | Regla correctiva |
|---|---|---|
| Archivos XLS en raiz del repo durante dias | Sin regla de estructura para datos de referencia | **REGLA**: datos de referencia siempre a `data/<categoria>/` desde el primer dia |
| `MAX_ENRICHMENT_BATCH = 5` como parche temporal | Enrichment all-at-once en lugar de lazy | Sprint 3+: migrar a enrichment on-demand por pagina visible |
| Diferencia 3913 vs 39284 sin resolver al cierre | Filtro Jasper no documentado como prereq de inicio | **REGLA**: `.jrxml` o SQL Jasper es prerequisito formal de kickoff por pantalla |
| `telefono_3` = 0 en toda la DB real | Campo ausente o siempre nulo en produccion | Documentar como `N/D` permanente con nota funcional |
| Handler leyendo `mock_transacciones` detectado tarde | Sin smoke test de `source` en ORDS metadata al deploy | **REGLA**: en todo deploy ORDS, validar `user_ords_handlers.source` antes de marcar DONE |
| Docs proliferadas en `docs/SPRINT-2-*.md` raiz de docs | Sin convencion de nombres estricta | **REGLA**: solo `docs/sprint-N/` y `docs/qa/` como destinos validos para artefactos operativos |
| `done.md` quedo ABIERTO hasta cierre manual | No en checklist diario | **REGLA**: `done.md` = CERRADO es condicion obligatoria en Definition of Done antes del push |

### Definition of Done actualizado (aplica a todos los sprints futuros)

```
[ ] Todos los campos de la pantalla tienen fuente de dato real o N/D documentado
[ ] user_ords_handlers.source validado post-deploy (no mock)
[ ] Enrichment batch size con limit y test de carga
[ ] done.md marcado CERRADO
[ ] Todos los artefactos en docs/sprint-N/ o docs/qa/ (no en raiz docs/)
[ ] Datos de referencia en data/<categoria>/
[ ] Filtro Jasper documentado como prerequisito antes de implementar
[ ] Commit atomico con secciones por area tecnica
```

---

## 9. Security Rules

- **Authentication**: OAuth client credentials for ORDS-protected endpoints (Bearer token from `/ords/infoplan/oauth/token`)
- **Database Access**: ORDS only via REST, no direct Oracle client connections
- **Secrets**: GitHub Secrets for DB credentials, API keys (Dash manages)
- **Input Validation**: React + ORDS validation on all form inputs
- **Compliance**: TBD (if forms handle sensitive data, discuss with Kira)

---

## 9.1. Jasper Parameter Extraction Protocol (MANDATORY for all exports)

**Objetivo:** Garantizar que cada pantalla migrada con Jasper extrae los parámetros exactos del XML original.

**Proceso de Extracción:**

1. **Identificar Jasper en XML Form**
   - Buscar en `forms/*.fmb.xml` cualquier referencia a `P_JASPER_A_EXCEL` o handler Jasper
   - Documentar nombre de reporte exacto: `rep_*` 
   - Documentar tipo de documento: `XLS`, `PDF`, etc.

2. **Extraer Parámetros Obligatorios**
   ```
   - name: rep_aprobaciones_rechazos
   - documentType: XLS
   - PCODIGO_COMPANIA: (compania ID, típicamente 30)
   - PDESDE: (fecha inicio, formato: dd-MON-YYYY, e.g., 01-JUN-2026)
   - PHAS: (fecha fin, formato: dd-MON-YYYY)
   ```

3. **Extraer Parámetros Opcionales**
   ```
   Parámetros que Jasper respeta si están presentes:
   - POFICIAL (oficial ID)
   - PGERENTE (gerente ID)
   - PINTERMEDIARIO (intermediario ID)
   
   REGLA CRÍTICA: 
   - Si parámetro ESTÁ VACÍO en forma: OMITIR del URL (NO enviar con valor "")
   - Si parámetro TIENE VALOR: INCLUIR en URL con ese valor
   - NUNCA enviar parámetro vacío como POFICIAL=0 (Jasper lo interpreta como "filtrar por ID 0")
   ```

4. **Validar Contra Jasper Server**
   ```bash
   # Test URL antes de mergear a main
   curl "http://172.24.208.208:31522/api/report?name=rep_aprobaciones_rechazos&documentType=XLS&PCODIGO_COMPANIA=30&PDESDE=01-JUN-2026&PHAS=15-JUN-2026"
   
   # Verificar: 
   # - HTTP 200 (no error)
   # - File size > 5000 bytes (contiene datos, no template vacío)
   # - Abrir en Excel: contiene al menos 1 fila de datos
   ```

5. **Documentar en Sprint Artifacts**
   ```markdown
   ### Jasper Integration Checklist
   - [x] Parámetro extraído del XML: `rep_aprobaciones_rechazos`
   - [x] Parámetros obligatorios: name, documentType, PCODIGO_COMPANIA, PDESDE, PHAS
   - [x] Parámetros opcionales: POFICIAL, PGERENTE, PINTERMEDIARIO (omitir si vacío)
   - [x] URL validada contra server (contiene datos)
   - [x] Frontend code implementado con omisión condicional
   ```

---

## 9.2. External Dependencies & Data Sync Rules

**Critical Constraint:** Esta aplicación depende de **dos sistemas distintos** que DEBEN estar sincronizados.

| System | URL | Purpose | Data Range | Status |
|--------|-----|---------|-----------|--------|
| **ORDS Backend** | `/ords/infoplan/aprobaciones-rechazos` | Search, filtering, selection | Mock: 2026-06-01 to 2026-06-15 | ✅ Working |
| **Jasper Reports** | `http://172.24.208.208:31522/api/report` | Excel/PDF exports | Production: 2026-01-01 to 2026-06-15 | ⚠️ Data mismatch |

**Known Issue (2026-06-15):**
- ORDS mock contiene datos para `2026-06-01` a `2026-06-15`
- Jasper NO contiene datos para ese rango específico (retorna Excel vacío)
- Jasper SÍ contiene datos para rango amplio (`2026-01-01` a `2026-06-15`)
- **Workaround**: Test con rango más amplio o sincronizar datos

**Escalation Rule:**
- Si datos ORDS no matchean con Jasper: "Levanta la mano" (comunicar bloqueador a CEO)
- No es responsabilidad del dev team sincronizar DBs en producción
- Documentar en GitHub Issues bajo etiqueta `data-sync-blocker`

**Resolution Options (pick one per sprint):**
```
A) Sincronizar ORDS mock data al rango que Jasper tiene (ene-jun)
B) Sincronizar Jasper database al rango que ORDS mockea (jun 01-15)
C) Crear mock en Jasper que devuelva datos como ORDS
D) Aceptar bloqueador y esperar disponibilidad real de Jasper en producción
```

---

## 9.3. Code Quality & Testing Standards (ELEVATED from 85% to 90%)

**Requirement:** Todo código mergeable MUST cumplir:

| Criteria | Target | Tool | Owner |
|----------|--------|------|-------|
| **Unit Test Coverage** | 90%+ | Jest + React Testing Library | Nova |
| **E2E Test Coverage** | Key user flows | Playwright | Ivy |
| **Code Quality** | Grade A (SonarQube) | SonarQube Cloud/Scanner | CI Pipeline |
| **Type Safety** | No `any` except escape hatches | TypeScript strict | Sage |
| **Accessibility** | WCAG 2.1 AA minimum | axe DevTools + manual | Kira |

**Pre-Merge Checklist (MANDATORY):**
```markdown
## Before `git push`
- [ ] `npm run test -- --coverage` reports >= 90% coverage
- [ ] SonarQube report shows **no Critical/High issues**
- [ ] `npm run build` completes without errors
- [ ] `npm run lint` (eslint) shows 0 errors (warnings OK with justification)
- [ ] E2E test: happy path works locally

## Before PR Merge
- [ ] GitHub Actions CI passes (tests + coverage + SonarQube)
- [ ] Code review approval (2 people minimum for critical paths)
- [ ] QA sign-off (Ivy) if user-facing feature
- [ ] Commit message follows semantic convention: `feat|fix|docs|test(scope): description`
```

**SonarQube Rules (Non-Negotiable):**
- ❌ Cognitive complexity > 15: BLOCKER
- ❌ Duplicated code blocks > 10 lines: BLOCKER
- ❌ Security hotspots: BLOCKER (must document or fix)
- ⚠️ Code smells: Must resolve or justify in PR comment

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
npm run build
npm run preview -- --host 0.0.0.0 --port 4173   # Demo estable cuando dev server tenga cache stale

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

**Required handoff locations for PBI execution:**
- Intake source: `docs/intake/solicitudes-pantallas.md` (minimal traceability)
- PBI mother folder: `docs/intake/pantallas/PBI-<id_pbi>/`
- Sprint-global context: `docs/sprint-N/plan.md`, `docs/sprint-N/progress.md`, `docs/sprint-N/done.md`

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
- **PBI Orchestration Runbook**: See `docs/governance/process/orquestacion-pbi-ords-react.md`
- **GitFlow Standard**: See `docs/governance/process/gitflow.md`
- **Master Sprint Roadmap**: See `docs/governance/process/sprint-master-plan.md`
- **Visual Project Flow (presentation)**: See `docs/governance/visual-flujo-proyecto.md`

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
  - Governance rule: `REUTILIZABLE` is always the default. Creating a new module is allowed only when no existing module with functional/domain fit can host the endpoint safely.
5. **Mandatory human checkpoint after ORDS assessment** before endpoint design.
  - Checkpoint outcome must include one of:
    - `REUSE_IN_EXISTING_MODULE` (preferred)
    - `CREATE_NEW_MODULE_WITH_JUSTIFICATION` (exception)
6. **Design ORDS endpoints** for `NUEVO` and `ADAPTABLE` operations.
7. **Plan sprint tasks in Azure DevOps** inferred from real form logic.
8. **Publish React/Next migration specification** mapped from Oracle blocks/triggers.

All generated artifacts and operational communication must be in Spanish.

### 15.1 Reuse-First Policy for ORDS Modules (MANDATORY)

1. Do not create modules "just in case".
2. If an existing module makes functional and ownership sense, endpoints must be created there.
3. A new module requires explicit written justification in sprint artifacts, including:
  - Why existing modules cannot be reused safely.
  - Compatibility and regression risk analysis.
  - Migration/backout plan.
4. Every ORDS endpoint proposal must document target module and reason (`reused` or `new-with-justification`).
5. Producer (Remy) cannot approve endpoint design without this evidence.

### 15.2 Human-in-the-Loop ORDS Checkpoint (MANDATORY)

Before designing or creating new ORDS endpoints/modules, the team must:

1. Use SQL Developer MCP to list available ORDS modules and endpoints.
2. Compare extracted form logic against existing GET/POST/PUT/DELETE endpoints.
3. Publish reuse matrix (`REUTILIZABLE`, `ADAPTABLE`, `NUEVO`).
4. Present analysis to human checkpoint (CEO/owner) and stop.

Allowed outcomes:
- `REUSE_IN_EXISTING_MODULE` (default)
- `CREATE_NEW_MODULE_WITH_JUSTIFICATION` (exception)
- `EN_ESPERA_APROBACION_HUMANA` (no implementation allowed)

Hard rule:
- No new ORDS module creation is allowed without explicit checkpoint approval.

### 15.3 Endpoint Canonical and Pagination Control (MANDATORY)

Before finalizing frontend integration and QA sign-off, the team must:

1. Declare one canonical ORDS endpoint per core UI operation.
2. Explicitly classify each evaluated endpoint as `REAL`, `MOCK`, or `DESCARTADO`.
3. Store SQL evidence of handler source for the canonical search endpoint.
4. Validate ORDS pagination contract (`items`, `hasMore`, `limit`, `offset`) and document UI behavior.
5. Report search results in QA with clear scope: first page vs full dataset.

Hard rule:
- Production-like validation cannot rely on mock endpoints unless the objective is an explicit mock-only test case.

### 15.4 Exploracion Continua y No Duplicacion (MANDATORY)

Esta regla aplica siempre, en todos los sprints y antes de cerrar cualquier pantalla:

1. Explorar `metadata-catalog` y `open-api-catalog` de ORDS como primer paso tecnico.
2. Intentar resolver campos faltantes reutilizando endpoints ya existentes antes de crear SQL nuevo.
3. Si existe endpoint funcional en otro modulo, reutilizarlo (directo o por orquestacion) y registrar evidencia.
4. Solo se permite crear servicio nuevo cuando la matriz de exploracion demuestre brecha real.
5. El cierre del sprint requiere evidencia de esta exploracion y de la decision de reutilizacion.

Hard rule:
- "No duplicar servicio" es una restriccion de arquitectura, no una recomendacion.

---

## 16. Implementation Baselines (NEW)

- The orchestration prompt source has been incorporated from:
  - `prompts/awsome_prompt.md`
  - `prompts/agent_orchestration_prompt.html`
- Operationalized documentation:
  - `docs/governance/process/orquestacion-pbi-ords-react.md`
  - `docs/governance/process/gitflow.md`
- Sprint execution alignment:
  - `docs/sprint-1/plan.md`
  - `docs/sprint-1/progress.md`

---

## 17. Reinicio e Intake de Plantillas (MANDATORY)

Desde este punto, cuando el CEO indique "migrar plantilla X", el equipo (Remy, Nova, Sage, Milo, Ivy) debe responder con solicitud estructurada de insumos antes de cualquier ejecucion tecnica.

### 17.1 Solicitud obligatoria al iniciar plantilla

Registro central obligatorio:
- `docs/intake/solicitudes-pantallas.md`

Plantilla de detalle:
- `docs/templates/plantilla-intake-migracion.md`

1. Plantilla objetivo.
2. Insumos de descripcion y criterios de aceptacion.
3. Recursos de apoyo (pruebas, transcripcion funcional, videos, evidencias).
4. Estimacion de esfuerzo y estimacion de sprint por formulario.
5. Estimacion de pantallas nuevas o cambios de pantalla.
6. Cualquier informacion adicional relevante para ejecucion segura.

### 17.2 Politica de ejecucion

- Si falta cualquier insumo: estado `NO_GO_FALTAN_INSUMOS`.
- Si todos los insumos estan completos: estado `GO_INTAKE_COMPLETO` y comienza el flujo de `docs/governance/process/orquestacion-pbi-ords-react.md`.
- Remy no autoriza arranque de sprint por plantilla sin evidencia de intake.
- Si la plantilla ya tiene intake base aprobado, usar modo incremental (deltas) y evitar solicitar nuevamente todo el paquete.

### 17.2.1 Modo Continuidad (Delta-Only)

Cuando una plantilla ya fue iniciada, el equipo debe pedir solo cambios respecto al baseline:
1. Cambios en descripcion/criterios de aceptacion.
2. Nuevos recursos o evidencias funcionales.
3. Cambios de estimacion (esfuerzo/sprint/pantallas).
4. Nuevos riesgos/restricciones.

Estados permitidos en continuidad:
- `GO_CONTINUIDAD_DELTA`
- `NO_GO_FALTAN_DELTAS_CRITICOS`

### 17.3 Entregable minimo por plantilla

Antes del analisis tecnico, debe existir un artefacto de intake con:
- resumen de la plantilla,
- criterios de aceptacion consolidados,
- inventario de recursos,
- estimaciones (esfuerzo, sprint, pantallas),
- riesgos y supuestos.

Regla de usabilidad para CEO:
- No repetir informacion ya aprobada en intake previo.
- El equipo debe referenciar baseline y solicitar solo los deltas necesarios.

---

## 18. Gobernanza de Documentacion y Revision Multirol (MANDATORY)

Con el objetivo de evitar dispersion documental, todo sprint debe pasar por una revision multirol antes de cierre.

### 18.1 Fuente de verdad y estructura

- Indice documental oficial: `docs/README.md`.
- Cada tema debe tener una fuente de verdad unica.
- Si un documento cambia una decision vigente, debe actualizar explicitamente el artefacto canonico relacionado.

### 18.2 Revision por rol

La revision debe ejecutarse y quedar registrada en:
- `docs/sprint-N/revision-multiroles-documentacion.md`

Roles y foco minimo:
1. Kira: claridad funcional y criterios de aceptacion.
2. Milo: consistencia visual y accesibilidad.
3. Nova: coherencia doc vs frontend real (env, rutas, contratos).
4. Sage: coherencia doc vs ORDS/DB (handlers y payloads).
5. Dash: operacion, seguridad, despliegue, ACL/CORS.
6. Ivy: cobertura QA y decision GO/NO-GO.
7. Remy: trazabilidad, owners, blockers y handoff.

### 18.3 Gate de cierre documental

No se puede cerrar sprint si falta cualquiera de estos puntos:
1. `progress.md` actualizado con evidencia reciente.
2. sign-off QA final (o bloqueo explicitado con owner/fecha).
3. `done.md` publicado.
4. revision multirol registrada con estado de cierre.

---

## 19. Escalabilidad para 100+ Pantallas (MANDATORY)

Este programa debe operar con disciplina de escala. La referencia obligatoria es:
- `docs/governance/modelo-operativo-100-pantallas.md`

Reglas de eficiencia:
1. Sin intake no hay inicio de pantalla.
2. Sin evidencia endpoint+QA no hay cierre funcional.
3. Sin sign-off y done no hay cierre de sprint.
4. Sin metricas de flujo (lead time, retrabajo, severidad) no hay mejora continua.

Revision multirol obligatoria por sprint:
- Kira, Milo, Nova, Sage, Dash, Ivy y Remy deben dejar hallazgos/accion en `docs/sprint-N/revision-multiroles-documentacion.md`.

Controles anti-sobrecarga obligatorios:
1. Limites WIP por rol activos y auditables.
2. Tarjeta operativa por pantalla (`docs/templates/tarjeta-pantalla.md`).
3. Gate por pantalla (inicio, construccion, validacion, cierre) antes de abrir nuevo trabajo.
4. Plan de accion vigente: `docs/governance/plan-accion-anti-ahogo.md`.

---

**Last Updated:** 2026-06-15 (Cesar, CEO)  
**Next Review:** End of Sprint 2 closure
