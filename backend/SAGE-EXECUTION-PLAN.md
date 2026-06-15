# Sprint 1 - Sage (Backend) Execution Instructions

**Fecha:** 2026-06-15  
**Owner:** Sage  
**Status:** 🔄 Ready to Execute  
**Objetivo:** Hardening scripts y validación de ORDS mock en BD real

---

## Fase 1: Verificar MCP + Conexión BD

### Paso 1.1: Confirmar SQLcl disponible

```powershell
sqlcl -version
```

**Esperado:**
```
SQLcl: Release 23.4.0 Build 23.4.0.019
```

### Paso 1.2: Confirmar conexión HUMANO_DESA

```powershell
sqlcl /nolog
# En prompt sqlcl:
CONNECT HUMANO_DESA
SHOW user
EXIT
```

**Esperado:**
```
Connected to: Oracle Database 19c ...
USER is INFOPLAN (o similar)
```

Si falla con "password given", guarda la contraseña en SQL Developer (Conexión → Edit → Save Password).

---

## Fase 2: Ejecutar Setup Mock (opción MCP)

```powershell
cd backend/ords/run
.\\run_sprint1_with_mcp.ps1 -ConnectionName "HUMANO_DESA"
```

**Salida esperada:**

```
[Sprint1-MCP] Initializing ORDS mock setup via SQLcl...
[Sprint1-MCP] Connection: HUMANO_DESA
[Sprint1-MCP] ✓ Found: 01_mock_schema.sql
[Sprint1-MCP] ✓ Found: 02_pkg_rep_aprobarechazo_mock.sql
[Sprint1-MCP] ✓ Found: 03_ords_rep_aprobarechazo_mock.sql
[Sprint1-MCP] ✓ Found: 04_smoke_tests.sql
[Sprint1-MCP] Executing setup script via sqlcl...

... (SQL output) ...

===== Sprint 1 Setup Summary =====
MOCK_TABLES        5
MOCK_PROCEDURES    2
MODULE_NAME        REP-APROBARECHAZO
BASE_PATH          /rep-aprobarechazo/

[Sprint1-MCP] ✅ Setup completed successfully!
```

Si falla, captura el error completo y reporta a Remy.

---

## Fase 3: Validar Endpoints ORDS

### Opción 3.1: Via SQLcl (local validation)

```sql
-- Conectar a BD
CONNECT HUMANO_DESA

-- Ver módulos publicados
SELECT module_name, base_path FROM user_ords_modules;

-- Ver handlers
SELECT pattern, method FROM user_ords_handlers WHERE module_name = 'rep-aprobarechazo';

-- Ver tablas mock
SELECT table_name FROM user_tables WHERE table_name LIKE 'MOCK_%' ORDER BY 1;

-- Ver procedimientos
SELECT object_name FROM user_procedures WHERE object_type = 'PACKAGE' AND object_name LIKE 'PKG_%' ORDER BY 1;
```

### Opción 3.2: Via HTTP (si ORDS corriendo en puerto 8080)

```bash
# Test endpoint GET /oficial/{codigo}
curl -X GET "http://localhost:8080/ords/infoplan/rep-aprobarechazo/oficial/501" \\
  -H "Content-Type: application/json"

# Test endpoint POST /search
curl -X POST "http://localhost:8080/ords/infoplan/rep-aprobarechazo/search" \\
  -H "Content-Type: application/json" \\
  -d '{"fec_ini": "2024-01-01", "fec_fin": "2024-12-31"}'
```

---

## Fase 4: Fix Scripts Windows (UnicodeEncodeError)

### Tarea: Actualizar extract_program_units.py y extract_block_triggers.py

**Problema:** Emojis en `print()` causan UnicodeEncodeError en CP1252.

**Solución:** Reemplazar emojis con textos ASCII o usar encoding UTF-8 forzado.

**Archivos a modificar:**
- `scripts/extract_program_units.py` → reemplazar emojis en líneas: 174, 182, 184, 227, 242, 268, 282, 297
- `scripts/extract_block_triggers.py` → reemplazar emojis en líneas: 85, 119, 123
- `scripts/xml trace.py` → reemplazar emojis + refactor XML_PATHS

**Cambios específicos:**
```python
# Before:
print(f"📖 Leyendo: {xml_file}")

# After:
print(f"[INFO] Leyendo: {xml_file}")
```

### Alternativa: Usar encoding UTF-8 forzado

```python
import sys
import io

# Al inicio del script
if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
```

---

## Fase 5: Re-ejecutar Extracción de XML

Una vez scripts fijos, ejecutar:

```powershell
cd c:\\Projects\\migracion-forms-infoplan

# Crear output dir
if (-not (Test-Path "docs\\analysis-results")) { 
  New-Item -ItemType Directory -Path "docs\\analysis-results" | Out-Null 
}

# Ejecutar extractores (ahora sin errores de encoding)
python scripts/extract_program_units.py forms/rep_aprobarechazo_fmb.xml --json > docs/analysis-results/rep_aprobarechazo_program_units.json

python scripts/extract_block_triggers.py forms/rep_aprobarechazo_fmb.xml CONSULTA --json > docs/analysis-results/rep_aprobarechazo_triggers_consulta.json

python scripts/extract_lovs_records.py forms/rep_aprobarechazo_fmb.xml --json --output docs/analysis-results/rep_aprobarechazo_lovs.json
```

**Validar outputs:**
```powershell
Get-Content docs/analysis-results/rep_aprobarechazo_program_units.json | Measure-Object -Line

# Esperado: > 0 lineas (no vacío)
```

---

## Fase 6: Reportar a Remy

Actualizar [docs/sprint-1/progress.md](../../../docs/sprint-1/progress.md):

| # | Task | Status | Notes |
|---|------|--------|-------|
| 3 | Ejecutar extraccion completa | ✅ Done | Program units, triggers, LOVs generados exitosamente |
| 2 | Hardening scripts Windows | ✅ Done | Emojis reemplazados, encoding UTF-8 validado |

---

## Troubleshooting

| Error | Causa | Solución |
|-------|-------|----------|
| ORA-01005: null password | Contraseña no guardada en SQL Developer | Conecta manualmente en SQL Developer y marca "Save Password" |
| FileNotFoundError: 01_mock_schema.sql | Script no encontrado | Verifica que estés en `backend/ords/run/` |
| UnicodeEncodeError | Emojis en consola CP1252 | Ejecuta: `chcp 65001` antes de python (UTF-8 mode) |
| ORDS endpoints no responden | ORDS no corriendo o no habilitado | Ejecuta `mcp_pgsql-tools_pgsql_get_dashboard_server_config` para verificar estado |

---

## Next Steps (después de completar)

1. Remy: Actualiza progress.md y cierra bloqueadores
2. Nova: Integra frontend real con ORDS (desactiva VITE_DEMO_MODE)
3. Ivy: Ejecuta QA smoke baseline
4. Dash: Verifica ORDS está publicado en puerto 8080

**Commit:** `feat: sprint-1-hardening scripts and ORDS mock setup (Refs #sprint-1-sage)`
