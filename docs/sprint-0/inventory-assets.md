# Inventario de Activos Reutilizables

Fecha: 2026-06-15
Sprint: 0 (Reinicio)

## Backend reutilizable

### ORDS y SQL base
- backend/ords/sql/01_mock_schema.sql
- backend/ords/sql/02_pkg_rep_aprobarechazo_mock.sql
- backend/ords/sql/03_ords_rep_aprobarechazo_mock.sql
- backend/ords/sql/04_smoke_tests.sql

### Scripts de ejecucion/validacion
- backend/ords/run/run_sprint1_with_mcp.ps1
- backend/ords/run/connect_with_env.ps1
- backend/ords/run/test_api_mock.ps1
- backend/ords/run/quick_ords_check.ps1

### Runbooks
- backend/ORDS-SETUP-LOCAL.md
- backend/SAGE-EXECUTION-PLAN.md

## Frontend reutilizable

### Aplicacion React base
- frontend/src/App.tsx
- frontend/src/api/ordsClient.ts
- frontend/src/api/mockOrdsClient.ts (solo referencia historica)
- frontend/src/components/FiltersPanel.tsx
- frontend/src/components/ResultsTable.tsx
- frontend/src/types.ts

### Configuracion
- frontend/.env.example
- frontend/.env.local
- frontend/package.json
- frontend/vite.config.ts

## Documentacion reutilizable

### Gobierno y proceso
- docs/ORQUESTACION-PBI-ORDS-REACT.md
- docs/GITFLOW.md
- docs/SPRINT-MASTER-PLAN.md

### Contexto funcional y tecnico
- docs/EXPLICACION-FUNCIONAL-REP-APROBACIONES.md
- docs/TECHNICAL-LOGIC-EXTRACTION-rep-aprobaciones.md
- docs/case-study-rep-aprobarechazo.md
- docs/DECISION-rep-aprobarechazo-piloto.md
- docs/analysis-results/

## Riesgos de reutilizacion

1. Parte del backend sigue orientado a mock de baseline, requiere validacion contra ORDS real por endpoint.
2. Scripts de analisis Python aun tienen deuda de portabilidad Windows.
3. Frontend contiene restos de modo demo historico en cliente mock (se conserva solo como fallback de referencia).

## Decision de reutilizacion

- Reutilizar: estructura de proyecto, contratos base, scripts ORDS y componentes React.
- Ajustar: endpoints, payloads y validaciones contra ORDS real.
- Deprecar gradualmente: rutas y artefactos estrictamente mock en cuanto se complete Sprint 1 real.
