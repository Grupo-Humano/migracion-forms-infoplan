# migracion-forms-infoplan

## Governance and Delivery Standards

- PBI orchestration lifecycle: `docs/governance/process/orquestacion-pbi-ords-react.md`
- GitFlow operating model: `docs/governance/process/gitflow.md`

## Sprint 1 - ORDS Mock (rep_aprobarechazo)

This repository now includes a Sprint 1 baseline to simulate Oracle Forms logic in ORDS.

### Created assets

- `backend/ords/sql/01_mock_schema.sql`
- `backend/ords/sql/02_pkg_rep_aprobarechazo_mock.sql`
- `backend/ords/sql/03_ords_rep_aprobarechazo_mock.sql`
- `backend/ords/sql/04_smoke_tests.sql`
- `backend/ords/tests/rep_aprobarechazo_mock.http`
- `backend/ords/run/run_sprint1.ps1`

### Local execution order

Run in order using SQL*Plus:

1. `01_mock_schema.sql`
2. `02_pkg_rep_aprobarechazo_mock.sql`
3. `03_ords_rep_aprobarechazo_mock.sql`
4. `04_smoke_tests.sql`

Or execute all with PowerShell:

```powershell
cd backend/ords/run
.\run_sprint1.ps1 -ConnectionString "user/password@host:port/service"
```

### API smoke test

After ORDS is published, run requests from:

- `backend/ords/tests/rep_aprobarechazo_mock.http`

Or run scripted API smoke tests with PowerShell:

```powershell
cd backend/ords/run
.\test_api_mock.ps1 -BaseUrl "http://localhost:8080/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos"
```

Base URL used in file:

- `http://localhost:8080/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos`

### Notes

- Export endpoints currently return JSON mock payloads.
- Replace mock export payload with real XLSX/Jasper integration in Sprint 2.

## Frontend React Mock Consumer (Sprint 1)

A minimal React + TypeScript frontend was added in `frontend/` to consume the mock ORDS endpoints.

### Included frontend capabilities

- Filter form for `fec_ini`, `fec_fin`, `cliente`, `oficial`, `gerente`, `intermediario`
- Search against `POST /search`
- Oficial lookup against `GET /oficial/{codigo}`
- Mark/Unmark all via `POST /seleccion/M` and `POST /seleccion/D`
- Export mock actions for OLE and Jasper endpoints
- Results table rendering of the returned transaction payload

### Frontend run

```powershell
cd frontend
npm install
npm run dev
```

Open:

- `http://localhost:3000`

### Runtime mode

Frontend is configured to run against real ORDS endpoints.

1. Ensure `frontend/.env.local` points to the correct ORDS base URL:
   ```
   VITE_ORDS_BASE_URL=http://localhost:8080/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos
   VITE_DEMO_MODE=false
   ```

2. Ensure ORDS service is reachable on the configured host/port.

3. Restart frontend dev server after env changes.

Optional base URL override:

```powershell
$env:VITE_ORDS_BASE_URL = "http://localhost:8080/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos"
npm run dev
```