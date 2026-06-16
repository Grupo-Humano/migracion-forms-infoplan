# Sprint 2 Runtime Browser Sign-off (Ivy QA)

Date: 2026-06-15
Environment: http://localhost:4173/
Scope: End-to-end browser validation for consulta + paginacion + action-state stability

## Executive Result

Status: BLOCKED (backend dependency)

Frontend behavior is stable under failure and does not hang.
Functional pagination over real data cannot be validated because ORDS endpoints are failing.

## Test Cases Executed

1. Open application and verify base UI state
- Expected: Search form available, pagination defaults to page size 25, no rows.
- Result: PASS

2. Run search with date range
- Inputs: Fecha desde 2026-01-01, Fecha hasta 2026-06-15
- Expected: Busy state appears, request completes, results or actionable error shown.
- Result: PARTIAL PASS
- Notes: Busy state and recovery are correct; backend returns errors.

3. Verify action buttons during in-flight request
- Expected: Marcar/Desmarcar/OLE/Jasper disabled while searching.
- Result: PASS

4. Verify recovery after failed search
- Expected: Buscar returns to enabled state, controls are coherent, no stuck loading.
- Result: PASS

5. Validate data pagination path (Siguiente over loaded data)
- Expected: If data available, page advances and row window updates.
- Result: BLOCKED
- Blocker: Search endpoint failures prevent data retrieval.

6. Validate oficial lookup action (Cargar nombre)
- Input: Oficial = 12345, then click Cargar nombre.
- Expected: Name resolved or clear recoverable error.
- Result: PARTIAL PASS
- Notes: UI remains stable and recoverable; backend endpoints for oficial lookup fail (404 + connection refused on localhost alternatives).

7. Validate Jasper export flow
- Input: valid date range + click Exportar Jasper + confirm modal.
- Expected: confirmation prompt, popup/report launch or actionable warning.
- Result: PASS
- Notes: Confirmation modal appears correctly. Browser popup block warning is shown clearly when popup is blocked.

8. Validate error readability under HTML backend responses
- Expected: long HTML error pages should not flood on-screen diagnostics.
- Result: PASS (fixed during this run)
- Notes: HTTP details are now compact/sanitized and truncated for readability.

## Observed Errors

- HTTP 403 on /ords/infoplan/aprobaciones-rechazos/transacciones/search
  - Message indicates SQL-referenced function is inaccessible or does not exist.
- HTTP 404 on /ords/infoplan/aprobaciones-rechazos/search
- HTTP 404/NET failures on oficial lookup routes during Cargar nombre.
- Network failures (ERR_CONNECTION_REFUSED) on localhost:8080 ORDS alternatives.

Terminal probe confirmation:
- POST to all localhost:8080 candidate endpoints => Unable to connect to the remote server.

## Ownership and Next Actions

- Sage (Backend)
  - Fix ORDS handler dependency causing HTTP 403 (object/function privilege or existence).
  - Ensure canonical search route is deployed and returns 200 with payload.

- Dash (DevOps/Infra)
  - Restore ORDS service reachability on localhost:8080 or publish definitive remote base URL.
  - Remove dead/legacy endpoints from environment to avoid noisy fallback chain.

- Nova (Frontend)
  - Keep current resilience behavior (good): timeout + consolidated diagnostics + action gating.
  - Improvement applied in this run: sanitize/truncate verbose HTTP payloads to avoid huge HTML dumps in user messages.

## Sign-off Decision

- Frontend Runtime Stability: APPROVED
- End-to-End Functional Sign-off (search + pagination with data): NOT APPROVED (blocked by backend/infra)
