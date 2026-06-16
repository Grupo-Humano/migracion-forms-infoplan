# ORDS Local Setup Guide (Sprint 1)

**Objetivo:** Configurar ORDS en BD de desarrollo para validar mock endpoints y hardening de scripts.

**Prerequisitos:**
- ✅ Oracle Instant Client 23.4 encontrado en `C:\oracle\instantclient_23_4`
- ⏳ SQL Developer configurado con conexión a BD de desarrollo
- ⏳ ORDS instalado en BD (TBD)

---

## 🔧 QUICK START (MCP + SQLcl) — Para Sage

### Opción Rápida: Via PowerShell + MCP

```powershell
cd backend/ords/run

# Ejecutar con conexión guardada en SQL Developer
.\run_sprint1_with_mcp.ps1 -ConnectionName "HUMANO_DESA"

# O con conexión manual
.\run_sprint1_with_mcp.ps1 -ConnectionString "usuario/password@host:puerto/servicio"
```

**Requisitos:**
- SQLcl instalado y en PATH (desde Oracle Instant Client)
- Conexión HUMANO_DESA con contraseña guardada en SQL Developer

**Salida esperada:**
```
✓ Found: 01_mock_schema.sql
✓ Found: 02_pkg_rep_aprobarechazo_mock.sql
✓ Found: 03_ords_rep_aprobarechazo_mock.sql
✓ Found: 04_smoke_tests.sql
✅ Setup completed successfully!
```

---

## Fase 1: Discovery (Remy + Sage)

### Paso 1.1: Obtener detalles de conexión SQL Developer

En VS Code, abre SQL Developer extension y ejecuta:

```sql
SELECT * FROM v$version;
```

Captura:
- [ ] Oracle DB version
- [ ] Host/IP
- [ ] Port
- [ ] SID o SERVICE_NAME
- [ ] Usuario conectado

### Paso 1.2: Verificar ORDS en BD

```sql
-- Conectar como SYSDBA
sqlplus / as sysdba

-- Validar ORDS instalado
SELECT * FROM dba_registry WHERE comp_id = 'ORDS';
```

**Posibles resultados:**
- ✅ ORDS ya instalado → Ir a Fase 2 (Enable schema)
- ❌ ORDS no instalado → Solicitar instalación a DBA o usar Docker (ver Fase 3)

### Paso 1.3: Validar tablas mock existentes

```sql
-- Conectar como usuario propietario (ej: INFOPLAN)
SELECT COUNT(*) FROM user_tables WHERE table_name LIKE 'MOCK_%';
```

---

## Fase 2: Enable ORDS en BD (si ya está instalado)

### Paso 2.1: Enable schema INFOPLAN para REST

```sql
BEGIN
  ORDS.ENABLE_SCHEMA(
    p_enabled => TRUE,
    p_schema => 'INFOPLAN',
    p_url_mapping_type => 'BASE_PATH',
    p_url_mapping_pattern => 'infoplan',
    p_auto_rest_auth => FALSE
  );
  COMMIT;
END;
/
```

### Paso 2.2: Publicar mock module

```sql
-- Script: backend/ords/sql/03_ords_rep_aprobarechazo_mock.sql
-- Copiar contenido y ejecutar en sesión conectada como INFOPLAN
@backend/ords/sql/03_ords_rep_aprobarechazo_mock.sql
```

### Paso 2.3: Validar endpoints

```sql
-- Verificar módulo publicado
SELECT module_name, base_path FROM user_ords_modules;

SELECT pattern, method FROM user_ords_handlers WHERE module_name = 'rep-aprobarechazo';
```

---

## Fase 3: Docker Oracle + ORDS (Alternativa reproducible)

Si BD Oracle no disponible en local, usar contenedor:

```bash
# Descargar imagen Oracle 23c
docker pull container-registry.oracle.com/database/enterprise:latest

# Correr contenedor con ORDS preinstalado
docker run -d \
  --name oracle-23c-ords \
  -p 1521:1521 \
  -p 8080:8080 \
  -e ORACLE_PWD=Oracle123 \
  -e ORACLE_ORDS_ENABLED=true \
  container-registry.oracle.com/database/enterprise:latest

# Esperar ~5 min para inicialización
```

**URL acceso ORDS:**
- Base: http://localhost:8080/ords/
- Mock endpoints: http://localhost:8080/ords/infoplan/rep-aprobarechazo/search

---

## Fase 4: Validar Contrato Endpoints Mock

### Test 1: GET /oficial/{codigo}

```bash
curl -X GET "http://localhost:8080/ords/infoplan/rep-aprobarechazo/oficial/501" \
  -H "Content-Type: application/json"
```

**Respuesta esperada:**
```json
{
  "codigo": 501,
  "nombre": "Juan Perez"
}
```

### Test 2: POST /search

```bash
curl -X POST "http://localhost:8080/ords/infoplan/rep-aprobarechazo/search" \
  -H "Content-Type: application/json" \
  -d '{
    "fec_ini": "2024-01-01",
    "fec_fin": "2024-12-31",
    "cliente": null,
    "oficial": null,
    "gerente": null,
    "intermediario": null
  }'
```

**Respuesta esperada:**
```json
{
  "items": [
    {
      "id_transaccion": 1,
      "fec_tra": "2024-01-15",
      "cliente": 100,
      ...
    }
  ]
}
```

---

## Fase 5: Integración con Frontend Mock

Una vez ORDS activo, cambiar frontend a modo real:

### Paso 5.1: Desactivar demo mode

```bash
cd frontend
export VITE_DEMO_MODE=false
export VITE_ORDS_BASE_URL="http://localhost:8080/ords/infoplan/rep-aprobarechazo"
npm run dev
```

### Paso 5.2: Validar en navegador

- Abrir http://localhost:3000
- Deshabilitar checkbox "Modo Demo"
- Completar filtros y hacer búsqueda
- Confirmar respuesta desde ORDS real vs mock

---

## Troubleshooting

| Problema | Causa | Solución |
|----------|-------|----------|
| ORDS no reconoce módulo | Sintaxis SQL o usuario | Verificar ejecución script en SYSDBA, luego en schema INFOPLAN |
| Error CORS en navegador | Frontend no puede acceder ORDS | Configurar CORS en ORDS: `BEGIN ORDS.DEFINE_HANDLER(..., p_cors => TRUE); END;` |
| Conexión rechazada en localhost:8080 | ORDS no corriendo | Verificar `SELECT * FROM dual;` en BD y reintentar enable schema |

---

## Siguiente paso

Una vez Fase 1-2 completadas, Remy actualiza [docs/sprint-1/progress.md](docs/sprint-1/progress.md) y Sage puede ejecutar scripts hardening con BD real.

**Owner:** Sage (Backend) + Dash (DevOps)  
**Status:** 🔄 In Progress  
**Last updated:** 2026-06-15  
**MCP Integration:** ✅ Configured (run_sprint1_with_mcp.ps1 ready)
