---
name: migracion-forms-infoplan
description: Oracle Forms to React migration - AI Team Orchestration
---

# Instrucciones para Agentes AI — migracion-forms-infoplan

Este archivo configura los agentes AI disponibles para el proyecto.

## 🎭 Agentes Disponibles

### 1. **@Remy** (Productor)
- **Archivo:** `.agents/remy-producer.agent.md`
- **Rol:** Sprint planning, coordinación, PR merging
- **Úsalo cuando:** Necesites planificar, priorizar tareas, revisar PRs

**Prompt de ejemplo:**
```
@Remy

Read PROJECT_BRIEF.md (Section 7: Sprint Status)
Review docs/analysis-results/

TASK:
Create docs/sprint-1/plan.md with:
1. Top 3 forms to migrate
2. Task breakdown (effort estimates)
3. Success criteria
4. Risks & mitigations
```

---

### 2. **@Sage** (Backend Engineer)
- **Archivo:** `.agents/sage-backend.agent.md`
- **Rol:** ORDS, PL/SQL, API design
- **Úsalo cuando:** Necesites diseñar APIs, extraer lógica PL/SQL, validar arquitectura

**Prompt de ejemplo:**
```
@Sage

Analyze the extracted PL/SQL from rep_aprobarechazo_fmb.xml

TASK:
1. Rate complexity (1-5) for each procedure
2. Design ORDS API endpoints
3. Identify procedures too complex for Phase 1
4. Estimate backend effort
```

---

### 3. **@Nova** (Frontend Engineer)
- **Archivo:** `.agents/nova-frontend.agent.md`
- **Rol:** React components, state management, UI implementation
- **Úsalo cuando:** Necesites crear componentes React, diseñar estructura, implementar formularios

**Prompt de ejemplo:**
```
@Nova

You are working on Sprint 1: Migrate rep_aprobarechazo form

TASK:
1. Design React component structure
2. Set up React Hook Form + TanStack Query
3. Create API client for Sage's endpoints
4. Write initial component code
```

---

### 4. **@Kira** (Product Designer)
- **Archivo:** `.agents/kira-designer.agent.md`
- **Rol:** UX, user flows, form prioritization
- **Úsalo cuando:** Necesites priorizar formas, diseñar UX, mejorar flujos de usuario

**Prompt de ejemplo:**
```
@Kira

Review the extracted data: docs/analysis-results/*.json

TASK:
1. Rate each form by UI complexity
2. Create prioritization matrix
3. Recommend top 3 forms for Sprint 1
4. Identify UX improvements vs legacy Oracle Forms
```

---

### 5. **@Milo** (Visual Director)
- **Archivo:** `.agents/milo-design.agent.md`
- **Rol:** CSS, design system, visual polish
- **Úsalo cuando:** Necesites crear design system, estilizar componentes, mejorar accesibilidad

**Prompt de ejemplo:**
```
@Milo

Create a design system for the forms migration

TASK:
1. Define Tailwind component library (buttons, inputs, modals, tables)
2. Establish color palette and typography
3. Create form field layout patterns
4. Write accessibility guidelines (WCAG AA)
```

---

### 6. **@Ivy** (QA Engineer)
- **Archivo:** `.agents/ivy-qa.agent.md`
- **Rol:** Testing, equivalence validation, bug filing
- **Úsalo cuando:** Necesites estrategia de testing, diseñar pruebas Playwright, validar equivalencia

**Prompt de ejemplo:**
```
@Ivy

Design test strategy for Sprint 1 forms

TASK:
1. Create equivalence test matrix (legacy vs React)
2. Design Playwright test cases
3. Identify high-risk areas
4. Write test automation plan
```

---

### 7. **@Dash** (DevOps Engineer)
- **Archivo:** `.agents/dash-devops.agent.md`
- **Rol:** CI/CD, deployment, infrastructure
- **Úsalo cuando:** Necesites configurar pipelines, deployment strategy, infraestructura

**Prompt de ejemplo:**
```
@Dash

Set up CI/CD for forms migration

TASK:
1. Design GitHub Actions pipeline
2. Configure frontend deployment (Vercel)
3. Plan backend deployment (ORDS)
4. Set up monitoring and alerts
```

---

## 🚀 Cómo Usar los Agentes en VS Code

### Opción 1: Abrir un Chat con un Agente Específico

1. **Abre Chat en VS Code** (`Ctrl+Shift+I` o `Cmd+Shift+I`)
2. **Selecciona un agente** o escribe `@` para ver la lista
3. **Elige el agente** que necesites (e.g., `@Remy`, `@Sage`)
4. **Escribe tu prompt** con contexto

**Ejemplo:**
```
@Remy

Read PROJECT_BRIEF.md

TASK: Create Sprint 1 plan
```

### Opción 2: Usar Agentes en Equipo (Recomendado para Proyectos Grandes)

Abre **múltiples VS Code windows** (uno por equipo):

```
Window 1: @Remy (Producer) — Planning & coordination
Window 2: @Nova + @Sage (Dev team) — Implementation
Window 3: @Ivy (QA) — Testing & validation
Window 4: @Dash (DevOps) — Infrastructure
```

**Flujo:**
1. Remy planifica en Window 1 → Genera `docs/sprint-1/plan.md`
2. Dev team lee el plan en Window 2 → Implementa
3. QA ejecuta pruebas en Window 3 → Valida
4. DevOps configura pipelines en Window 4 → Deploy
5. Remy revisa y merges PRs en Window 1

---

## 📋 Agentes por Fase de Proyecto

### Fase 1: Planificación (Esta Semana)
- **Usa:** @Remy + @Sage + @Kira
- **Output:** docs/sprint-1/plan.md

### Fase 2: Implementación (Sprints 1-8)
- **Usa:** @Nova + @Sage + @Milo (en parallel)
- **Output:** React components + ORDS APIs

### Fase 3: Testing (Parallel a Fase 2)
- **Usa:** @Ivy
- **Output:** Playwright tests, bug reports

### Fase 4: Deployment (Fin de Sprint)
- **Usa:** @Dash
- **Output:** CI/CD pipelines, deployed app

---

## 🔄 Flujo de Coordinación Recomendado

```
Tu rol: CEO/Orchestrador

1️⃣ Chat con @Remy
   "Crea el plan de Sprint 1"
   ↓ Resultado: docs/sprint-1/plan.md

2️⃣ Comparte plan con @Nova + @Sage
   "Implementen Sprint 1"
   ↓ Resultado: React components + APIs

3️⃣ Comparte con @Ivy
   "Haz pruebas de equivalencia"
   ↓ Resultado: Test cases + bugs

4️⃣ Comparte con @Dash
   "Configura deployment"
   ↓ Resultado: CI/CD pipeline listo

5️⃣ Vuelve a @Remy
   "Revisa PRs y mergea a main"
   ↓ Resultado: Sprint completado
```

---

## 💡 Tips para Mejores Resultados

### ✅ Haz:
- Nombrá cada agente explícitamente (e.g., "@Remy, crea el plan...")
- Proporciona contexto antes de pedir tareas
- Pide decisiones específicas, no genéricas
- Usa "Take your time, do it right" en prompts complejos
- Guarda resultados en docs/ para que otros agentes los lean

### ❌ NO hagas:
- Pidas a @Remy que escriba código (es productor, no dev)
- Mezcles roles en un solo chat (uno por especialidad)
- Uses frases vagas como "make the app better"
- Ignores los constraints de cada agente
- Saltes la validación de @Ivy antes de merges

---

## 📚 Referencias

- [PROJECT_BRIEF.md](../PROJECT_BRIEF.md) — Context completo del proyecto
- [AI Team Orchestration Skill](../.agents/skills/ai-team-orchestration/SKILL.md) — Guía detallada
- [docs/QUICK-START-XML-ANALYSIS.md](../docs/QUICK-START-XML-ANALYSIS.md) — Setup inicial

---

**Última actualización:** 2026-06-15  
**Owner:** Remy (Producer)  
**Status:** Agentes listos para usar
