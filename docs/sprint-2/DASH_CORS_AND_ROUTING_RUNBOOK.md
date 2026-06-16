# Dash Runbook - ORDS CORS + Routing (Sprint 2)

## Goal
Unblock Task 7B by ensuring:
1. ORDS route is published and reachable (no 404).
2. Browser calls from local frontend origins are allowed.

## Inputs
- Active local origins:
  - http://localhost:3000
  - http://localhost:3001
  - http://localhost:3002
- Expected logical endpoints:
  - /gerentes
  - /intermediarios
  - /transacciones/search

## 1) Routing checks (must pass first)
- Verify ORDS is pointing to the schema where module was created.
- Verify module is PUBLISHED and enabled.
- Verify templates/handlers exist and method matches:
  - GET gerentes
  - GET intermediarios
  - POST transacciones/search
- If ORDS node cache is stale, restart/reload ORDS service.

## 2) CORS policy (definitive fix)
Allow these request patterns:
- Origins: localhost 3000/3001/3002
- Methods: GET, POST, OPTIONS
- Headers: Content-Type, Authorization, X-Requested-With

Expected response headers for preflight and normal responses:
- Access-Control-Allow-Origin: <origin>
- Access-Control-Allow-Methods: GET,POST,OPTIONS
- Access-Control-Allow-Headers: Content-Type,Authorization,X-Requested-With
- Access-Control-Allow-Credentials: true (only if needed)

## 3) Validation matrix
1. OPTIONS /transacciones/search -> 200/204 + CORS headers.
2. GET /gerentes -> 200 with JSON payload.
3. GET /intermediarios -> 200 with JSON payload.
4. POST /transacciones/search -> 200 with JSON payload.

## 4) Hand-off to Nova/Ivy
After routing + CORS pass:
- Nova reruns UI flow on localhost.
- Ivy validates Task 7B checklist and updates sprint tracker.

## 5) Evidence to record in progress tracker
- Date/time of ORDS reload/restart.
- Final resolved endpoint base path.
- Screenshots or logs of successful probes.
- Confirmation that browser console no longer shows CORS/404 for Task 7B.
