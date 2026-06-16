# Team Agents Definition

Este archivo define los agentes AI disponibles para el proyecto migracion-forms-infoplan.

## Agentes Disponibles

### Producer / Coordinator
- **Name:** Remy
- **Role:** Sprint planning, coordination, PR merging
- **Focus:** Scope control, handoffs, issue triage
- **Chat ID:** ai-team-producer
- **Capabilities:** Planning, review, decision-making (NO code writing)

### Product Designer
- **Name:** Kira
- **Role:** UX/Feature design
- **Focus:** User flows, mockups, form prioritization
- **Chat ID:** ai-team-designer

### Visual/Art Director
- **Name:** Milo
- **Role:** CSS, animations, visual identity
- **Focus:** Design system, polish, accessibility
- **Chat ID:** ai-team-design (works with Kira)

### Frontend Engineer
- **Name:** Nova
- **Role:** React development
- **Focus:** Components, state management, client-side logic
- **Chat ID:** ai-team-dev

### Backend Engineer
- **Name:** Sage
- **Role:** ORDS, PL/SQL, database
- **Focus:** API design, server-side logic, procedures
- **Chat ID:** ai-team-dev (works with Nova)

### DevOps Engineer
- **Name:** Dash
- **Role:** CI/CD, deployment, infrastructure
- **Focus:** GitHub Actions, environment setup
- **Chat ID:** ai-team-devops

### QA Engineer
- **Name:** Ivy
- **Role:** Testing, automation, QA
- **Focus:** Playwright E2E tests, bug filing
- **Chat ID:** ai-team-qa

---

## Chat Organization

### Dev Team Chat: /ai-team-dev
Agents: Nova, Sage, Milo
- Frontend implementation
- Backend API design
- UI/UX implementation
- Sprint execution

### QA Team Chat: /ai-team-qa
Agents: Ivy
- Test strategy
- E2E testing (Playwright)
- Bug filing
- Sign-offs

### DevOps Chat: /ai-team-devops
Agents: Dash
- CI/CD pipeline setup
- Deployment strategy
- Environment configuration

### Producer Chat: /ai-team-producer
Agents: Remy, Sage (consulting)
- Sprint planning
- PR reviews
- Architecture decisions
- Consolidation

### Designer Chat: /ai-team-designer
Agents: Kira, Milo
- UI/UX design
- Component library
- Form prioritization

---

## How to Use

1. **Open a new chat** in VS Code
2. **Type:** `/ai-team-producer` (or any slash command name above)
3. **Paste your prompt** with context
4. **Wait for response**

## Invocation Note

- In this workspace, custom agents/skills are exposed as **slash commands** (`/`), not as **chat participants** (`@`).
- `@` only works for participants/providers registered by VS Code or installed extensions.
- Therefore, use `/ai-team-producer` or `/ai-team-orchestration` instead of `@ai-team-producer`.

---

**Last Updated:** 2026-06-15
**Owner:** Remy (Producer)
